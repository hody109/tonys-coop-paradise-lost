//=============================================================================
// CoopPlayerController.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2014-2018.
//=============================================================================

class CoopPlayerController extends AWDudePlayer;//DudePlayer;

///steam 21/07/2016 also used in CoopSaveSystem.uc
var Pawn FirstPossessedPawn;

///steam 21/07/2016
var CoopNETChameleonModule NETChameleonModule;
var class<CoopNETChameleonModule> NETChameleonModuleClass;

var CoopMatineeCamera NETSceneCamera;
var class<CoopMatineeCamera> NETSceneCameraClass;
var CoopPawnDeadController myDeadController;
var transient CoopMapInteraction CoopMap;
///steam transient 06/12/2015

///steam songmusic support 22/01/2016
var string SongInfos_ClientSong[9];
var int SongInfos_ClientHandle[9];

var string sTeleportPawn;

var string CoopMapClass;

var bool bNETSceneViewFixed;
var bool bNETSceneViewNorm;
var bool bNETSceneViewBegin; ///steam 02/05/2016
var bool bBlockInput;
var bool bInputSpectating;
var bool bShowCoopPlayers;

///steam 29/07/2016 unused
//const ShowCoopPlayersPath = "NicksCoop.CoopPlayerController bShowCoopPlayersConfig";
//var globalconfig bool bShowCoopPlayersConfig;

var Weapon CoopLastWeaponPee;

///steam 11/04/2016
var rotator PreMatineeRot;
var bool bMatineeMoveUnlocked;

///steam 13/05/2016 spots test
//var CoopTestStartSpot CoopTestStartSpot;

///steam 14/06/2016
var string CoopDelayScreen_CurrentScreen;
var Name CoopDelayScreen_MyOldState;

///steam 28/06/2016
var rotator PlayerReadyRotDetect;
var bool bPlayerReadyDetect;
var float PlayerReadyDetectTime;

///steam 04/08/2016
//var bool bClientHeadInjury; - also should be REP

///steam 08/10/2016
var bool bCoopIsTyping;
var bool bCoopWasTyping;
var float CoopIsTypingTime;

///steam 12/10/2016
var string CoopCustomSkin;
var string CoopCustomFace;

///steam 22/11/2016
var bool bShowNETStatsInfo;
var CoopNETStatsInfo NETStatsInfo;
var class<CoopNETStatsInfo> NETStatsInfoClass;

///steam 10/04/2017
var bool bDisableClientCoopMap;
var bool bMuteSayMessages;
var float MuteSayMessagesTime;
var localized string ChatMutedMessage;

///steam 26/05/2017
var bool bClientMatineeShowDebug;

///steam 30/06/2017
var bool bClientWatchScene;

///steam 31/07/2017
var float fDedKillJobsUpdTime;

struct CoopSaveIDInfoStruct
{
	var() string PlayerID;
	var() string ServerID;
};
var globalconfig array<CoopSaveIDInfoStruct> CoopSaveIDInfo;
var string CoopSavePlayerID;
var string CoopSaveSystemID;
var globalconfig string CoopSaveIDSystemKey;

var bool bCoopLevelPreTravel;
var Sound CoopFartSounds[4];

///steam 11/08/2017
const IDLING_CHECK_AFK = 60;
var bool bIdlingCheckAFK;
var float IdlingCheckTime;
var rotator IdlingCheckRot;
var byte IdlingCheckCount;

///steam 13/08/2017
var byte SpecSpectateType;
var bool bSpecSpectateConOrder;
var Name SpecSpectateConOldState;
var float SpecSpectateConOrderTime;
var bool bSpecSpectIgnoresHearing;
var bool bSpecSpectIgnoresSenses;

///steam 18/08/2017
var globalconfig bool bCoopTeleportDisabled;

///steam 18/12/2017
//var globalconfig int CoopCurrentNetSpeed;

///steam 02/01/2018
var globalconfig bool bCoopPingOptimize;
var float CoopPingOptimizeTime;

///NonDedicatedAutoSave 22/01/2018
var bool bWaitForPlayerTravelInfo;

replication
{
	unreliable if( Role == ROLE_Authority )
		NETSceneCamera, bBlockInput, bMatineeMoveUnlocked, bShowCoopPlayers, bInputSpectating, 
		bShowNETStatsInfo, NETStatsInfo, SpecSpectateType;

	reliable if( Role < ROLE_Authority )
		NETLoadGame, NETSaveGame, NETRestartLevel, NETCallQuickSave, NETCallQuickLoad, 
		NETGotAdminInv, NETRememberLastWeap, NETSetCoopPlayerConfig, NETSetCoopConfig, 
		NETQueryPlayerID, NETSavePlayer, NETSpecSpectateSwitch, NETDisableCoopTeleport, 
		NETCoopLoadCustomMod, NETCoopLoadCustomMap, NETCoopResetVote;

	unreliable if( Role < ROLE_Authority )
		NETCoopTeleport, NETCoopSpectator, NETCoopWaitContinue, NETCoopSetTyping, 
		NETSpecSpectateAnimalDo;

	reliable if( Role == ROLE_Authority )
		xCoopCallShellMenu, xClientCallMapRequest, xClientPlayMusicExt, xClientPlayMusicAttenuateExt, 
		xClientStopMusicExt, xClientStopAllMusicExt, xClientPlayMovieScaled, xClientGetLastWeap, 
		xClientSetCoopConfig, xClientCoopStopFiring, xClientChangeToNewClothes, xClientApplyCurrentClothes, 
		xClientSpecialMessage, xCoopShowSubtitleByTag, xClientQueryPlayerID, xClientUpdateURL, xClientInitPingOptimize;

	unreliable if( Role == ROLE_Authority )
		xClientCheapBloodEffectsFor;
}

exec function Suicide();

exec function Fire( optional float F )
{
	if( bInputSpectating && bMatineeMoveUnlocked )
	{
		NETCoopSpectator(true);
		CoopHideWeaponSelector();
	}
	if( bBlockInput )
	{
		StopFiring();
		return;
	}
	Super.Fire(F);
}

exec function AltFire( optional float F )
{
	if( bInputSpectating && bMatineeMoveUnlocked )
	{
		NETCoopSpectator(false);
		CoopHideWeaponSelector();
	}
	if( bBlockInput )
	{
		StopFiring();
		return;
	}
	Super.AltFire(F);
}

///steam 21/07/2016 hack to return view forced
simulated function CallForceReturnView()
{
	NETCoopSpectator(false);
	///steam 01/08/2016 use CoopMiscTimer_ForceReturnViewDelayed.uc instead of CoopMiscTimer_ForceReturnView.uc to be sure
	spawn(class'CoopMiscTimer_ForceReturnViewDelayed',self);
}

///steam 21/07/2016 hack to get NKVehicle we're using now
simulated function Actor GetNKVehicleOwnedBy(Actor UsePawn)
{
	if( UsePawn != None && UsePawn.Base != None && UsePawn.Base.IsA('DriverBase') && UsePawn.Base.Owner != None )
		return UsePawn.Base.Owner;
	return None;
}

///steam 21/07/2016 hack to get NPVehicle we're using now
simulated function Actor GetNPVehicleOwnedBy(Actor UsePawn)
{
	if( UsePawn != None && UsePawn.IsA('NPVehicle') )
		return UsePawn;
	return None;
}

///steam 21/07/2016 hack to force leave NPVehicles
simulated function ForceLeaveNPVehicle()
{
	///ClientMessage("ForceLeaveNPVehicle entered");
	if( FirstPossessedPawn == None 
		|| FirstPossessedPawn == Pawn )
		return;
	Unpossess();
	FirstPossessedPawn.SetOwner(self);
	Possess(FirstPossessedPawn);
	MyHUD.bShowDebugInfo = False;
	FixFOV();
	ClientSetBehindView(false);
	bBehindView = false;
	ClientSetViewTarget(FirstPossessedPawn);
	PlayerReplicationInfo.SetWaitingPlayer(false);
	FirstPossessedPawn.SetCollision(true, true, true);
	FirstPossessedPawn.PlayWaiting();
	FirstPossessedPawn.bPhysicsAnimUpdate = FirstPossessedPawn.default.bPhysicsAnimUpdate;
	FirstPossessedPawn.Acceleration = vect(0, 0, 24000);
	FirstPossessedPawn.SetPhysics(PHYS_Falling);
	FirstPossessedPawn.SetBase(None);
	FirstPossessedPawn.bUpdateEyeHeight = true;
	FirstPossessedPawn.bHidden = false;
	bGodMode = false;
	///ClientMessage("ForceLeaveNPVehicle finished");
}

function NETCoopSpectator(bool bCoopSpectator)
{
	local Actor aPickView;
	local Controller con;
	local bool bFound;

	if( !bCoopSpectator )
	{
		if( Pawn != None )
			aPickView = Pawn;
		else aPickView = self;
	}
	else
	{
		for( con = Level.ControllerList; con != None; con = con.NextController )
		{
			if( CoopPlayerController(con) != None 
				&& !CoopPlayerController(con).IsCoopDedicatedHost() 
				&& con.Pawn != None 
				&& con.Pawn.Health > 0 
				&& con.Pawn != Pawn )
			{
				if( aPickView == None )
					aPickView = con.Pawn;
				if ( bFound )
				{
					aPickView = con.Pawn;
					break;
				}
				else bFound = ( ViewTarget == con.Pawn 
					///steam 21/07/2016 hack to spectate vehicles
					|| (GetNKVehicleOwnedBy(con.Pawn) != None && ViewTarget == GetNKVehicleOwnedBy(con.Pawn)) );
			}
		}
	}

	if( aPickView != None )
	{
		///steam 21/07/2016 hack to spectate vehicles
		if( GetNKVehicleOwnedBy(aPickView) != None )
			aPickView = GetNKVehicleOwnedBy(aPickView);
		SetViewTarget(aPickView);
		ClientSetViewTarget(aPickView);
		ClientSetBehindView(bCoopSpectator);
	}
}

exec function DoKick()
{
	if( bBlockInput )
		return;

	P2Pawn(Pawn).StopAcc();
	P2Pawn(Pawn).MyFoot.Fire(1.0);
	//ClientMessage(P2Pawn(Pawn).MyFoot);
}

exec function UseZipper( optional float F )
{
	if( !Pawn.Weapon.IsA('UrethraWeapon') )
	{
		CoopLastWeaponPee = Pawn.Weapon;
		if(Pawn.Weapon != None)
		{
			LastWeaponGroupPee = Pawn.Weapon.InventoryGroup;
			LastWeaponOffsetPee= Pawn.Weapon.GroupOffset;
		}
		else
		{
			LastWeaponGroupPee = 1;
			LastWeaponOffsetPee= 0;
		}

		Pawn.PendingWeapon = P2Pawn(Pawn).MyUrethra;
		P2Weapon(Pawn.PendingWeapon).SetReadyForUse(true);
		Pawn.Weapon.PutDown();
	}
	else if( Pawn.Weapon.IsA('UrethraWeapon') && !Pawn.Weapon.IsInState('NormalFire') )
	{
		bPee=0;
		if( CoopLastWeaponPee != None )
		{
			Pawn.PendingWeapon = CoopLastWeaponPee;
			P2Weapon(Pawn.PendingWeapon).SetReadyForUse(true);
			Pawn.Weapon.PutDown();
		}
	}
	//if( P2Pawn(Pawn).MyUrethra != None )
	//	Pawn.Destroy();
	//ClientMessage(P2Pawn(Pawn).MyUrethra);
}

///steam 01/05/2016 bCoopSpectating added
simulated function SetBlockPlayerInput(bool bCoopInputBlock, bool bCoopSpectating)
{
	bBlockInput = bCoopInputBlock;
	bInputSpectating = bCoopSpectating;
}

simulated function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	if( FirstPossessedPawn == None )
		FirstPossessedPawn = aPawn;

	if( CoopPostalDude(Pawn) != None )
	{
		CoopPostalDude(Pawn).bCoopPlayer = true;
		if( myDeadController == None )
			myDeadController = spawn(class'CoopPawnDeadController',Pawn,,Pawn.Location);
		myDeadController.myCoopPawn = CoopPostalDude(Pawn);
		myDeadController.myCoopPlayer = self;

		///steam 15/06/2016
		CoopPostalDude(Pawn).CoopSetupOldController(self);
	}

	if( IsCoopDedicatedHost() )
	{
		if( Pawn != None )
		{
			Pawn.SetCollision(false,false,false);
			Pawn.bHidden = true;
		}
	}

	///NonDedicatedAutoSave 22/01/2018
	if( bWaitForPlayerTravelInfo )
	{
		if( CoopSavePlayerID != "" && CoopSaveSystemID != "" )
			UpdatePlayerTravelInfo();
	}

	// If server, it will set up the pawns after they login. So instead of
	// travel post accept doing it, let's finish up the pawn here.
	// This only called for coop client players - FIX2018
	if(Role == ROLE_Authority && Buoyancy != 75)
	{
		P2Pawn(Pawn).bPlayerStarting = false;
		P2Pawn(Pawn).ClientPlayerStartingFinished();

		//P2Pawn(Pawn).PlayerStartingFinished();
		//log(self$" Possess, server finished setting up pawn");
	}
}

///////////////////////////////////////////////////////////////////////////////
// Startup
///////////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if( NETChameleonModuleClass == None )
		NETChameleonModuleClass = class'CoopNETChameleonModule';
	NETChameleonModule = spawn(NETChameleonModuleClass,self);

	if( myDeadController == None )
		myDeadController = spawn(class'CoopPawnDeadController',self,,Location);
		//myDeadController = spawn(class'CoopPawnDeadController',Pawn,,Pawn.Location);

	///steam 04/06/2016 reset level speed for client if possible
	if( Buoyancy != 75 )
		CoopSetGameSpeed(1.0);

	///steam 18/11/2016
	xClientSetCoopConfig();

	///steam 10/04/2017
	if( Role == ROLE_Authority )
		spawn(class'CoopMiscTimer_CheckTCC',self);

	///steam 21/08/2017
	CoopCallQuerySavePlayerID();

	///steam 18/12/2017
	CoopCallClientInitPingOptimize();

	///steam 21/08/2017 - must call very important functions after delay again
	spawn(class'CoopMiscTimer_PostConnectInit',self);
}

///steam 21/08/2017
simulated function CoopCallQuerySavePlayerID()
{
	if( Role == ROLE_Authority )
	{
		if( !IsCoopDedicatedHost() 
			/*&& Buoyancy != 75*/ )///steam 05/11/2017 - host condition causes bug
			spawn(class'CoopMiscTimer_QuerySavePlayerID',self);
	}
}

///steam 18/12/2017
simulated function CoopCallClientInitPingOptimize()
{
	if( Role == ROLE_Authority )
	{
		if( Buoyancy != 75 )
			spawn(class'CoopMiscTimer_ClientInitPingOptimize',self);
	}
}

///steam 21/08/2017 - must call very important functions after delay again from CoopMiscTimer_PostConnectInit.uc
simulated function CoopPostConnectInit() /// WARNING it calls twice, from server and client
{
	///steam 18/11/2016
	xClientSetCoopConfig();

	///steam 21/08/2017
	if( !CoopSaveIDDataLoaded() )
		CoopCallQuerySavePlayerID();

//	ClientMessage(self @ "CoopPostConnectInit() called");
}

simulated function Destroyed()
{
	///steam 31/07/2016
	if( myDeadController != None )
	{
		myDeadController.Destroy();
		myDeadController = None;
	}
	if( NETChameleonModule != None )
	{
		NETChameleonModule.Destroy();
		NETChameleonModule = None;
	}

	///steam 22/11/2016
	if( NETStatsInfo != None )
	{
		bShowNETStatsInfo = false;
		NETStatsInfo.Destroy();
		NETStatsInfo = None;
	}

	Super.Destroyed();
}

///steam 04/01/2017 moved from HOST class
simulated function CreateNETSceneCamera()
{
	if( NETSceneCamera == None )
		NETSceneCamera = spawn(NETSceneCameraClass,self,, Location, Rotation);
	CoopGameReplicationInfo(Level.Game.GameReplicationInfo).NETSceneCamera = NETSceneCamera;
}

///steam 04/01/2017 moved from HOST class
simulated function DeleteNETSceneCamera()
{
	if( NETSceneCamera != None )
	{
		NETSceneCamera.Destroy();
		NETSceneCamera = None;
	}
}

simulated function InitNETSceneCamera(CoopMatineeCamera HostNETSceneCamera)
{
	if( HostNETSceneCamera != None )
		NETSceneCamera = HostNETSceneCamera;
}

///steam 11/04/2016
simulated function PostInitNETSceneCamera()
{
	if( Buoyancy != 75 )
	{
		if( NETSceneCamera != None && NETSceneCamera.bNETUpdateViewport )
			return;
	}
	bMatineeMoveUnlocked = true;
}

///steam
event PreClientTravel()
{
	local int i;
	local P2Screen screen;

	///steam 25/08/2017
	if( Buoyancy != 75 )
	{
		// Tell screens
		for( i = 0 ; i < Player.LocalInteractions.Length ; i++ )
		{
			screen = P2Screen(Player.LocalInteractions[i]);
			if( screen != None )
				screen.PreTravel();
		}
	}

	// Disable the Menu for a level change
	P2RootWindow(Player.InteractionMaster.BaseMenu).DisableMenu();

	Super.PreClientTravel();
}

function SpawnDefaultHUD()
{
	///steam 20/05/2016 i don't really like this code
	///myHUD = spawn(class'MpHUDBase',self);
	if( myHUD == None )
		myHUD = spawn(class'CoopHUD',self);
}

state PlayerWaiting
{
	exec function Fire(optional float F)
	{
		//Super.Fire(F);
	}

	exec function AltFire( optional float F )
	{
	}
}

state PlayerPrepSave
{
	ignores PrepForSave, CheckPrepForSave,SeePlayer, HearNoise, KilledBy, NotifyBump, 
		HitWall, ActivateInventoryItem, 
		Jump, ThrowWeapon, PlayerMove, ThrowPowerup, PrevInvItem, NextInvItem, ActivateItem, 
		NotifyHeadVolumeChange, NotifyPhysicsVolumeChange, Falling, CheckMapReminder,
		DamageAttitudeTo, Suicide, UseZipper, DudeShoutGetDown, ToggleInvHints, ToggleToHands,
		QuickUseMap, DoKick, QuickSave, CanBeMugged, WeaponZoom, WeaponZoomIn, WeaponZoomOut,
		NextWeapon, PrevWeapon, Fire, AltFire, PressingFire, PressingAltFire, Pause, ReadyForCashier;

	function BeginState()
	{
		bDidPrepForSave = true;
	}
Begin:
	//Sleep(AUTO_SAVE_WAIT);

/*
	if (ScreenStillRunning() ||
		!P2GameInfoSingle(Level.Game).ReadyForSave(self) )
		Goto('Begin');
*/

	// We don't need to do this again
	bDidPrepForSave = true;

	// Go back to playing normally
	ExitPrepToSave();
}

event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
	if( NETSceneCamera != None && Buoyancy != 75 )
	{
		if( NETSceneCamera.bNETUpdateViewport )
		{
			SetViewTarget(NETSceneCamera);
			ViewActor = ViewTarget;
			CameraLocation = ViewTarget.Location;
			CameraRotation = ViewTarget.Rotation;

			if( !bNETSceneViewBegin )
			{
				bNETSceneViewFixed = false;
				bNETSceneViewNorm = false;
				bNETSceneViewBegin = true;
			}

			return;
		}
		else
		{
			if( ViewTarget != None && ViewTarget == NETSceneCamera )
			{
				if( Pawn != None && !Pawn.bDeleteMe )
					SetViewTarget(Pawn);
				else SetViewTarget(self);
			}
		}
	}
	Super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);
}

simulated function PlayerTick(float DeltaTime)
{
	//ClientMessage("CoopSavePlayerID:"@CoopSavePlayerID);

	///steam - 10/12/2015
	if( MyPawn == None && Pawn != None )
		MyPawn = P2MoCapPawn(Pawn);

	xDetectPlayerReady();

	if( Buoyancy != 75 )
	{
		NETSceneCameraUpdateView();
		CoopPingOptimize();
	}

	///steam 08/10/2016
	xDetectTypeStatus();

	Super.PlayerTick(DeltaTime);
}

simulated function xDetectPlayerReady()
{
	// The delay (1.5) depends on CoopMiscTimer_QuerySavePlayerID timer rate
	if( bPlayerReadyDetect )
		return;
	if( PlayerReadyDetectTime == 0 )
	{
		PlayerReadyRotDetect = Rotation;
		PlayerReadyDetectTime = Level.TimeSeconds + 1.5;
	}
	else if( Level.TimeSeconds > PlayerReadyDetectTime 
		&& PlayerReadyRotDetect != Rotation )
	{
		bPlayerReadyDetect = true;
		PlayerReadyDetectTime = 0;
	}
}

///steam 08/10/2016
simulated function xDetectTypeStatus()
{
	local Interaction OurConsole;
	if( Level.TimeSeconds > CoopIsTypingTime )
	{
		if( Player != None 
			&& Player.InteractionMaster != None 
			&& Player.InteractionMaster.Console != None )
		{
			OurConsole = Player.InteractionMaster.Console;
			bCoopIsTyping = (OurConsole.IsInState('Typing') || OurConsole.IsInState('ConsoleVisible') );
			if( bCoopIsTyping != bCoopWasTyping )
			{
				bCoopWasTyping = bCoopIsTyping;
				NETCoopSetTyping(bCoopIsTyping);
			}
		}
		CoopIsTypingTime = Level.TimeSeconds + 0.1;
	}
}

///steam 02/01/2018
simulated function CoopPingOptimize()
{
	local int iNewNetSpeed;
	if( !bCoopPingOptimize 
		|| CoopPingOptimizeTime == -1 
		|| CoopPingOptimizeTime > Level.TimeSeconds )
		return;

	if( PlayerReplicationInfo.Ping <= 120 )
		iNewNetSpeed = 5000;
	else iNewNetSpeed = 4000;

	if( iNewNetSpeed != 0 && Player.CurrentNetSpeed != iNewNetSpeed )
		ConsoleCommand("set Player CurrentNetSpeed" @ iNewNetSpeed);

	//ClientMessage("CoopPingOptimize" @ Player.CurrentNetSpeed);
	CoopPingOptimizeTime = Level.TimeSeconds + 8;
}

///steam 31/07/2017 - hack to fix KillJobs HUD on dedicated server
function CoopDedicatedKillJobsUpd()
{
	local int i, UseCount, UseMax, bPercentageDisplay;
	if( Level.TimeSeconds > fDedKillJobsUpdTime )
	{
		if( KillJobs.Length > 0 && IsCoopDedicatedHost() )
		{
			for( i = 0 ; i < KillJobs.Length ; i++ )
			{
				GetKillJobValues(i, UseCount, UseMax, bPercentageDisplay);
			}
		}
		fDedKillJobsUpdTime = Level.TimeSeconds + 0.3;
	}
}

///steam 21/07/2016
simulated function NETChameleonTick(float DeltaTime)
{
	if( Level.NetMode == NM_DedicatedServer )
	{
		if( Buoyancy == 75 )
			CoopDedicatedKillJobsUpd();
	}

	///steam 11/08/2017
	if( Role == ROLE_Authority )
		CoopCheckIdling();
}

///steam 11/08/2017
function CoopCheckIdling()
{
	local bool bAction;
	if( Level.TimeSeconds > IdlingCheckTime )
	{
		if( Pawn != None )
			bAction = Pawn.bWantsToCrouch || Pawn.Physics == PHYS_Falling;
		if( (IdlingCheckRot == Rotation) && !bAction )
			IdlingCheckCount = FMin(IdlingCheckCount+1,240);
		else IdlingCheckCount = 0;

		if( IdlingCheckCount >= IDLING_CHECK_AFK )
		{
			if( !bIdlingCheckAFK )
			{
				bIdlingCheckAFK = true;
				if( CoopPlayerReplicationInfo(PlayerReplicationInfo) != None )
					CoopPlayerReplicationInfo(PlayerReplicationInfo).bCoopPlayerAFK = true;
			}
		}
		else
		{
			if( bIdlingCheckAFK )
			{
				bIdlingCheckAFK = false;
				if( CoopPlayerReplicationInfo(PlayerReplicationInfo) != None )
					CoopPlayerReplicationInfo(PlayerReplicationInfo).bCoopPlayerAFK = false;
			}
		}

		IdlingCheckRot = Rotation;
		IdlingCheckTime = Level.TimeSeconds + 1;
//		ClientMessage("Idling time (s)" @ IdlingCheckCount);
	}
	else if( IdlingCheckCount > 0 )
	{
		if( Pawn != None )
			bAction = VSize(Pawn.Acceleration) > 0.1;
		else bAction = VSize(Acceleration) > 0.1;
		if( bAction )
			IdlingCheckCount = 0;
	}
}

///steam 13/08/2017
function bool IsCoopPlayerAFK()
{
	return bIdlingCheckAFK;
}

///steam 11/08/2017
function bool GetIdlingCheckStatus(optional int Seconds)
{
	if( Seconds == 0 )
		Seconds = 20;
	return (IdlingCheckCount >= Seconds);
}

///steam 12/08/2017
function bool GetIdlingCheckForArrest()
{
	return GetIdlingCheckStatus(25);
}

// UPD 20/04/2018 - check if we can be arrested
function bool xIsReadyForArrestFinal()
{
	return ( xIsReadyForArrest() && !GetIdlingCheckForArrest() );
}

// UPD 20/04/2018 - check if we can be arrested
function bool xIsReadyForArrest()
{
	local Controller aCon;
	local int i;

	if( Pawn == None 
		|| Pawn.bDeleteMe 
		|| Pawn.Health <= 0 )
		return false;

	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.nextController )
	{
		if( aCon.Pawn != None 
			&& !aCon.Pawn.bDeleteMe 
			&& aCon.Pawn != Pawn 
			&& CoopPlayerController(aCon) != None 
			&& !CoopPlayerController(aCon).IsCoopDedicatedHost() 
			&& !CoopPlayerController(aCon).IsCoopPlayerAFK() 
			&& aCon.Pawn.Health > 0 )
		{
			i++;
			if( VSize(Pawn.Location-aCon.Pawn.Location) < 512 && FastTrace(Pawn.Location, aCon.Pawn.Location) )
				return true;
		}
	}
	if( i == 0 )
		return true;
	return false;
}

///steam 12/08/2017
function float CommentOnGettingArrested()
{
	if( !xIsReadyForArrestFinal() ) //GetIdlingCheckForArrest() )
	{
		MyPawn.PlaySound(CoopFartSounds[Rand(ArrayCount(CoopFartSounds))], SLOT_Interact, 1.0,,128.0, MyPawn.GetRandPitch());
		return 1.0;
	}
	else SayTime = MyPawn.Say(MyPawn.myDialog.lDude_Arrested) + 0.5;
	SetTimer(SayTime, false);
	bStillTalking=true;
	return SayTime;
}

simulated function NETSceneCameraUpdateView()
{
	if( NETSceneCamera != None )
	{
		if( NETSceneCamera.bNETUpdateViewport )
		{
			if( !bNETSceneViewFixed )
			{
				PreMatineeRot = Rotation;
				bBehindView = false;
				if( MyHUD != None )
				{
					if( bClientMatineeShowDebug )
						MyHUD.bShowDebugInfo = true;
					///steam 29/06/2017
					MyHUD.bHideHUD = true;
				}
				bClientWatchScene = true;
				bNETSceneViewFixed = true;
				//ClientMessage("CINEMA FIXED");
			}
			bNETSceneViewNorm = false;

			SetLocation(NETSceneCamera.Location);
			SetRotation(NETSceneCamera.Rotation);
		}
		else
		{
			if( !bNETSceneViewNorm )
			{
				bBehindView = false;
				if( MyHUD != None )
				{
					if( bClientMatineeShowDebug )
						MyHUD.bShowDebugInfo = false;
					///steam 29/06/2017
					MyHUD.bHideHUD = false;
				}
				bClientWatchScene = false;
				bNETSceneViewNorm = true;
				if( PreMatineeRot != rot(0,0,0) ) ///steam 11/04/2016
					SetRotation(PreMatineeRot);
				//ClientMessage("CINEMA NORMAL");
			}
			bNETSceneViewFixed = false;
		}
	}
	else
	{
		///steam GameReplicationInfo != None added 06/12/2015
		if( GameReplicationInfo != None && CoopGameReplicationInfo(GameReplicationInfo).NETSceneCamera != None )
			InitNETSceneCamera(CoopGameReplicationInfo(GameReplicationInfo).NETSceneCamera);
	}
}

exec function CoopPlayers()
{
	//bShowCoopPlayers = !bShowCoopPlayers;
	NETSetCoopPlayerConfig();///steam 29/07/2016
}

///steam 29/07/2016
function LoadCoopPlayersConfig(bool bState)
{
	bShowCoopPlayers = bState;
	//ClientMessage("LoadCoopPlayersConfig"@bShowCoopPlayers);
}

///steam 29/07/2016
function NETSetCoopPlayerConfig()
{
	bShowCoopPlayers = !bShowCoopPlayers;

	if( bShowCoopPlayers )
		ClientMessage("ShowPlayers ON");
	else ClientMessage("ShowPlayers OFF");
}

function xClientCallMapRequest(optional bool bForceUseMap, optional Texture TexOverride)
{
	CoopQuickUseMap(bForceUseMap, TexOverride);
}

exec function CoopQuickUseMap(optional bool bForceUseMap, optional Texture TexOverride)
{
	local bool bFound;
	local int i;
	local class<CoopMapInteraction> useCoopMapClass;

	///steam 10/04/2017
	if( bDisableClientCoopMap )
		return;

	if( Buoyancy != 75 && CoopMap == None )
	{
		useCoopMapClass = class<CoopMapInteraction>(DynamicLoadObject(CoopMapClass, class'Class'));
		for(i = 0; i < Player.LocalInteractions.Length; i++)
		{
			if( Player.LocalInteractions[i].IsA('CoopMapInteraction') && Player.LocalInteractions[i].class == useCoopMapClass )
			{
				CoopMap = CoopMapInteraction(Player.LocalInteractions[i]);
//				ClientMessage("Found CoopMap" @ CoopMap);
				bFound = true;
				break;
			}
		}

		if(!bFound)
		{
			CoopMap = CoopMapInteraction(Player.InteractionMaster.AddInteraction(CoopMapClass, Player));//"NicksCoop.CoopMapInteraction"
//			ClientMessage("Created CoopMap" @ CoopMap);
		}
	}
	if( CoopMap != None )
	{
		if( TexOverride != None )
			CoopMap.TextureOverride = TexOverride;
		else CoopMap.TextureOverride = None;
		///steam 08/01/2016
		if( bForceUseMap )///steam 25/07/2016
			CoopMap.TryToEnableRenderForced(self);
		else CoopMap.TryToEnableRender(self);
	}
}

///steam 08/01/2016
function RequestMap()
{
	if( Buoyancy != 75 )
	{
		xClientCallMapRequest();
		return;
	}
	Super.RequestMap();
}

///steam 31/07/2016
function RequestNews()
{
	if( Buoyancy != 75 )
	{
		return;
	}
	Super.RequestNews();
}

///steam 31/07/2016
exec function RequestStats()
{
	if( Buoyancy != 75 )
	{
		return;
	}
	Super.RequestStats();
}

exec function QuickUseMap()
{
	if( Buoyancy != 75 )
	{
		CoopQuickUseMap();
		return;
	}
	Super.QuickUseMap();
}

state CoopPlayerWaiting extends PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)	
	{
		//STUB
	}

	function PlayerMove( float DeltaTime )
	{
		//STUB
	}

	simulated function BeginState()
	{
		if( myHUD != None )
		{
			myHUD.bHideHUD = true;
		}
		if( Pawn != None )
		{
			Pawn.Acceleration = vect(0,0,0);
			Pawn.Velocity = vect(0,0,0);
			Pawn.SetPhysics(PHYS_None);
		}
	}
}

simulated function bool GetCoopWaitStatus()
{
	if( CoopGameReplicationInfo(GameReplicationInfo) != None 
		&& CoopGameReplicationInfo(GameReplicationInfo).bCoopWaitPlayers )
		return true;
	return false;
}

///steam 11/04/2016
state PlayerWalking
{
	exec function Jump( optional float F )
	{
		if( GetCoopWaitStatus() )
		{
			NETCoopWaitContinue();
			return;
		}
		Super.Jump(F);
	}
	function PlayerMove( float DeltaTime )
	{
		if( !bMatineeMoveUnlocked )
		{
			aForward = 0;
			aStrafe = 0;
		}
		Super.PlayerMove(DeltaTime);
	}
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		if( !bMatineeMoveUnlocked )
		{
			bPressedJump = false;
		}
		Super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
	}
	function BeginState()
	{
		if( GetCoopWaitStatus() )
			bMatineeMoveUnlocked = false;
		Super.BeginState();
	}
}

///steam 29/05/2016
exec function ActivateItem()
{
	if( GetCoopWaitStatus() )
	{
		NETCoopWaitContinue();
		return;
	}
	if( Pawn != None && Pawn.Health <= 0 )
		return;
	Super.ActivateItem();
}
exec function Jump( optional float F )
{
	if( GetCoopWaitStatus() )
	{
		NETCoopWaitContinue();
	}
	Super.Jump(F);
}

///steam 11/04/2016
function UpdateRotation(float DeltaTime, float maxPitch)
{
	if( !bMatineeMoveUnlocked )
	{
		ViewShake(deltaTime);
		return;
	}
	Super.UpdateRotation(DeltaTime, maxPitch);
}

///steam 04/08/2016
/*exec */function TestGhost()
{
	if( Pawn.bCollideWorld )
	{
		Pawn.UnderWaterTime = -1.0;	
		ClientMessage("You feel free.");
		Pawn.SetCollision(false, false, false);
		Pawn.bCollideWorld = false;
		GotoState('PlayerFlying');
	}
	else
	{
		Pawn.UnderWaterTime = Pawn.Default.UnderWaterTime;	
		Pawn.SetCollision(true, true , true);
		Pawn.SetPhysics(PHYS_Walking);
		Pawn.bCollideWorld = true;
		GotoState('PlayerWalking');
	}
}

function NETCoopTeleport(string sPlayerName)
{
	local int i;
	local CoopGameReplicationInfo ReplicaInfo;
	local CoopPlayerReplicationInfo PRI;

	ReplicaInfo = CoopGameReplicationInfo(GameReplicationInfo);
	if( ReplicaInfo != None && Pawn != None && Pawn.Health > 0 )
	{
		for( i = 0 ; i < ReplicaInfo.PRIArray.Length ; i++ )
		{
			PRI = CoopPlayerReplicationInfo(ReplicaInfo.PRIArray[i]);
			if( PRI != None 
				&& PRI != PlayerReplicationInfo 
				&& PRI.NETHealth > 0 
				&& !PRI.bOnlySpectator ///steam 09/08/2017 - spectator test
				&& !PRI.bCoopDedicatedHost 
				&& (PRI.PlayerName == sPlayerName || sPlayerName == "") )
			{
				if( PRI.bCoopTeleportDisabled )
				{
					ClientMessage(PRI.PlayerName @ "restricted teleport");
					return;
				}
				Pawn.SetLocation(PRI.NETLocation);
				ClientMessage("You teleported to:" @ PRI.PlayerName);
				break;
			}
		}
	}
}

function NETLoadGame()
{
	if( PlayerReplicationInfo.bAdmin && !CoopGameInfo(Level.Game).bCoopDedicated )
		CoopGameInfo(Level.Game).LoadGame(0,false);
}

function NETSaveGame()
{
	if( PlayerReplicationInfo.bAdmin && !CoopGameInfo(Level.Game).bCoopDedicated )
		CoopGameInfo(Level.Game).SaveGame(0,false);
}

function NETRestartLevel()
{
	if( PlayerReplicationInfo.bAdmin )
		CoopGameInfo(Level.Game).CoopRestartLevel();
}

exec function CoopTeleport(optional string sPlayerName)
{
	if( sPlayerName == "" )
		sPlayerName = sTeleportPawn;
	NETCoopTeleport(sPlayerName);
}

simulated function xCoopCallShellMenu(string MenuClassName)
{
	local ShellRootWindow PlayerRootMenu;
	local class<ShellMenuCW> MenuClass;
	local class<ShellMenuCW> OldMenuClass;

	PlayerRootMenu = ShellRootWindow(Player.InteractionMaster.BaseMenu);

	MenuClass = class<ShellMenuCW>(DynamicLoadObject(MenuClassName, class'Class'));

	if( PlayerRootMenu == None 
		|| MenuClass == None )
		return;

	PlayerRootMenu.ShowMenu();
	///steam 21/04/2017 - new way to open menu
	if( PlayerRootMenu.MyMenu != None )
		OldMenuClass = PlayerRootMenu.MyMenu.class;
	else OldMenuClass = None;
	///PlayerRootMenu.CreateMenu(MenuClass);
	///PlayerRootMenu.MyMenu.ShowWindow();
	PlayerRootMenu.GoToMenu(OldMenuClass, MenuClass);
}

///steam music 23/01/2016
/// xClientPlayMusicExt , xClientPlayMusicAttenuateExt , xClientStopMusicExt , xClientStopAllMusicExt
function xClientPlayMusicExt(int SongHandle, string Song, float FadeInTime, optional float VolumeOverride, optional bool bAllowPause)
{
	if( Song != "" )
		SongInfos_ClientHandle[SongHandle] = PlayMusic(Song, FadeInTime, VolumeOverride, bAllowPause);
	///oggmusicdebug ClientMessage("xClientPlayMusicExt"@Song);
}
function xClientPlayMusicAttenuateExt(int SongHandle, actor Actor, string Song, float FadeInTime, optional float Volume, optional float Radius, optional float Pitch, optional float VolumeOverride, optional bool bLegacy)
{
	if( Actor != None && Song != "" )
		SongInfos_ClientHandle[SongHandle] = Actor.PlayMusicAttenuate(Song, FadeInTime, Volume, Radius, Pitch, VolumeOverride,, bLegacy);
	///oggmusicdebug ClientMessage("xClientPlayMusicAttenuateExt"@Song@Actor@Volume@Radius@bLegacy);
}
function xClientStopMusicExt(int SongHandle, float FadeOutTime)
{
	StopMusic(SongInfos_ClientHandle[SongHandle], FadeOutTime);
	SongInfos_ClientHandle[SongHandle] = 0;
	///oggmusicdebug ClientMessage("xClientStopMusicExt");
}
function xClientStopAllMusicExt(float FadeOutTime)
{
	local int i;
	StopAllMusic(FadeOutTime);
	for (i = 0; i < ArrayCount(SongInfos_ClientHandle); i++)
		SongInfos_ClientHandle[i] = 0;
	///oggmusicdebug ClientMessage("xClientStopAllMusicExt");
}

///steam 04/04/2016
function NETCallQuickSave()
{
	if( CoopGameInfo(Level.Game).bCoopDedicated 
		|| (CoopGameInfo(Level.Game).bNonDedicatedAutoSave && !PlayerReplicationInfo.bAdmin) ) ///NonDedicatedAutoSave 22/01/2018
	{
		CoopGameInfo(Level.Game).CoopManualSavePlayer(MpPawn(Pawn));
		return;
	}
	if( PlayerReplicationInfo.bAdmin )
		Super.QuickSave();
}
function NETCallQuickLoad()
{
	if( PlayerReplicationInfo.bAdmin && !CoopGameInfo(Level.Game).bCoopDedicated )
		Super.QuickLoad();
}
function NETGotAdminInv(string sPass)
{
	// local CoopTravelAdminInv tempAdminLoginInv;

	// if( sPass == "" || Pawn == None )
		// return;

	// tempAdminLoginInv = CoopTravelAdminInv(P2Pawn(Pawn).FindInventoryType(class'CoopTravelAdminInv'));

	// if( tempAdminLoginInv == None )
		// tempAdminLoginInv = CoopTravelAdminInv(P2Pawn(Pawn).CreateInventoryByClass(class'CoopTravelAdminInv'));

	// tempAdminLoginInv.xPassStr = sPass;
	//MpPawn(Pawn).ClientMessage("NETGotAdminInv"@tempAdminLoginInv@sPass);
}
exec function QuickSave()
{
	NETCallQuickSave();
}
exec function QuickLoad()
{
	NETCallQuickLoad();
}

simulated function bool xGetMatineeCameraStatus()
{
	if( NETSceneCamera != None )
		return NETSceneCamera.bNETUpdateViewport;
	return false;
}

///steam 11/04/2016
simulated function xSceneStarted()
{
	///steam 01/05/2016 bCoopSpectating added
	bInputSpectating = false;
	if( Buoyancy != 75 )
		bMatineeMoveUnlocked = false;
}
simulated function xSceneFinished()
{
	///steam 29/05/2016 for CoopWait action propper work
	///if( Buoyancy != 75 )
		bMatineeMoveUnlocked = true;
}

simulated function xForceReturnViewToPawn()
{
	//ClientMessage("xForceReturnViewToPawn called");
	if( Pawn != None )
	{
		SetViewTarget(Pawn);
		ClientSetViewTarget(Pawn);
	}
	ClientSetBehindView(false);
}

///steam 02/05/2016
function StartHeadInjury()
{
	if( Buoyancy != 75 )
	{
		Pawn.PlaySound(StartHeadSound, SLOT_Misc, 1.0,,TransientSoundRadius);
		if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).GetCoopPlayerHost() != None )
			CoopGameInfo(Level.Game).GetCoopPlayerHost().StartHeadInjury();
		//bClientHeadInjury = true;
		return;
	}
	Super.StartHeadInjury();
}
function StopHeadInjury()
{
	if( Buoyancy != 75 )
	{
		Pawn.PlaySound(EndHeadSound, SLOT_Misc, 1.0,,TransientSoundRadius);
		if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).GetCoopPlayerHost() != None )
			CoopGameInfo(Level.Game).GetCoopPlayerHost().StopHeadInjury();
		//bClientHeadInjury = false;
		return;
	}
	Super.StopHeadInjury();
}

///steam 02/05/2016
function StartKillCount(Texture HudPawnIcon, name TriggerTag, optional bool bPercentageDisplay)
{
	if( Buoyancy != 75 )
	{
		if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).GetCoopPlayerHost() != None )
			CoopGameInfo(Level.Game).GetCoopPlayerHost().StartKillCount(HudPawnIcon, TriggerTag, bPercentageDisplay);
		return;
	}
	Super.StartKillCount(HudPawnIcon, TriggerTag, bPercentageDisplay);
}

///steam 04/08/2016
function StartKillBoss(Texture HudPawnIcon, name EnemyTag, optional bool bPercentageDisplay, optional bool bWillow, optional string WillowText)
{
	if( Buoyancy != 75 )
	{
		if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).GetCoopPlayerHost() != None )
			CoopGameInfo(Level.Game).GetCoopPlayerHost().StartKillBoss(HudPawnIcon, EnemyTag, bPercentageDisplay, bWillow, WillowText);
		return;
	}
	Super.StartKillBoss(HudPawnIcon, EnemyTag, bPercentageDisplay, bWillow, WillowText);
}

///steam 11/05/2016 stucked moving bug fixed
function AdjustRadius(float MaxMove)
{
	// STUB
}

///steam 19/05/2016
simulated function xClientPlayMovieScaled(MovieTexture InMovie, string MovieFileName, float Left, float Top, float Right, float Bottom, bool UseSound, bool LoopMovie, optional bool Translucent)
{
	if( InMovie == None )
		InMovie = MovieTexture(DynamicLoadObject("MovieTextures.Generic", class'MovieTexture'));
	if( myHUD != None )
		myHUD.PlayMovieScaled(InMovie, MovieFileName, Left, Top, Right, Bottom, UseSound, LoopMovie, Translucent);
}

///steam 24/05/2016
exec function Pause()
{
	if( PlayerReplicationInfo.bAdmin )
		Super.Pause();
}

///steam 29/05/2016
function NETCoopWaitContinue()
{
	CoopGameInfo(Level.Game).CoopWaitContinue();
}

///steam 04/06/2016
simulated function CoopSetGameSpeed(float T)
{
	Level.TimeDilation = FMax(T, 0.1);
}

///steam 03/03/2017 - ugly fix of empty list when complete errand and never opened map before
function CoopForceAddRevealErrands()
{
	local int i, j;
	local bool bFound;
	local DayBase aDayBase;
	local GameState myGameState;

	myGameState = CoopGameInfo(Level.Game).TheGameState;
	aDayBase = CoopGameInfo(Level.Game).GetCurrentDayBase();

	if( myGameState == None 
		|| aDayBase == None )
		return;

	for( j = 0 ; j < aDayBase.NumErrands() ; j++ )
	{
		if( aDayBase.IsErrandActive(j) )
		{
			bFound = false;
			for( i = 0; i < myGameState.RevealedErrands.Length ; i++ )
			{
				if( myGameState.RevealedErrands[i].Day == myGameState.CurrentDay && myGameState.RevealedErrands[i].Errand == j )
				{
					bFound = true;
					break;
				}
			}
			if( !bFound )
			{
				i = myGameState.RevealedErrands.Length;
				myGameState.RevealedErrands.insert(i, 1);
				myGameState.RevealedErrands[i].Day = myGameState.CurrentDay;
				myGameState.RevealedErrands[i].Errand = j;

				i = myGameState.RevealedLocationTex.Length;
				myGameState.RevealedLocationTex.insert(i, 1);
				myGameState.RevealedLocationTex[i].Day = myGameState.CurrentDay;
				myGameState.RevealedLocationTex[i].Errand = j;
			}
		}
	}
}

///steam 28/07/2017
function CoopCallDelayedURLTravel(string sURL, float fTime)
{
	local CoopMiscTimer_DelayedURLTravel aDelayedURLTravel;
	aDelayedURLTravel = spawn(class'CoopMiscTimer_DelayedURLTravel',self);
	if( aDelayedURLTravel != None )
		aDelayedURLTravel.SetupTravelTimer(sURL, fTime);
	//log("CoopCallDelayedURLTravel"@sURL);
}

///steam 06/06/2016
function DisplayMapCrossOut(int ErrandIndex, name CompletionTrigger_In, optional String SendToURL)
{
	if( /*MyMapScreen != None &&*/ Pawn != None && !bInterpolating )
		CoopForceAddRevealErrands();
	Super.DisplayMapCrossOut(ErrandIndex, CompletionTrigger_In, SendToURL);
	CoopCallMapForClients();
	///steam 28/07/2017
	if( IsCoopDedicatedHost() && MyMapScreen == None && SendToURL != "" )
		CoopCallDelayedURLTravel(SendToURL, 4);
}

///steam 21/07/2016
function DisplayMapErrands(optional String SendToURL, optional bool bWantFancyFadeIn)
{
	if( IsCoopDedicatedHost() )
		CoopForceAddRevealErrands();
	Super.DisplayMapErrands(SendToURL, bWantFancyFadeIn);
	CoopCallMapForClients();
	///steam 28/07/2017
	if( IsCoopDedicatedHost() && MyMapScreen == None && SendToURL != "" )
		CoopCallDelayedURLTravel(SendToURL, 4);
}

///steam 28/07/2017
function DisplayMapHaters(optional String SendToURL)
{
	Super.DisplayMapHaters(SendToURL);
	if( IsCoopDedicatedHost() && MyMapScreen == None && SendToURL != "" )
		CoopCallDelayedURLTravel(SendToURL, 0.5);
}

///steam 28/07/2017
function DisplayStats(optional String URL)
{
	Super.DisplayStats(URL);
	if( IsCoopDedicatedHost() && MyMapScreen == None && URL != "" )
		CoopCallDelayedURLTravel(URL, 60);
}

///steam 28/07/2017
function DisplayLoad(DayBase day, String URL)
{
	Super.DisplayLoad(day, URL);
	if( IsCoopDedicatedHost() && MyMapScreen == None && URL != "" )
		CoopCallDelayedURLTravel(URL, 0.5);
}

///steam 06/06/2016
function CoopCallMapForClients()
{
	local controller con;

	if( Buoyancy != 75 )
		return;

	for(con = Level.ControllerList; con != None; con = con.NextController)
	{
		if( CoopPlayerController(con) != None && con != self )
			CoopPlayerController(con).xClientCallMapRequest(true);
	}
}

///steam 06/06/2016 lastweapfix
simulated function xClientGetLastWeap(int nLastWeaponGroupHands, int nLastWeaponOffsetHands)
{
	LastWeaponGroupHands = nLastWeaponGroupHands;
	LastWeaponOffsetHands = nLastWeaponOffsetHands;
}

///steam 07/06/2016 lastweapfix
function ClientToggleToHands(optional bool bForce)
{
	Super.ClientToggleToHands(bForce);
	NETRememberLastWeap(LastWeaponGroupHands, LastWeaponOffsetHands);
}

///steam 18/06/2016
function NETRememberLastWeap(int nLastWeaponGroupHands, int nLastWeaponOffsetHands)
{
	LastWeaponGroupHands = nLastWeaponGroupHands;
	LastWeaponOffsetHands = nLastWeaponOffsetHands;
}

///steam 14/06/2016
function bool CoopAnyScreenRunning()
{
	local int i;
	local P2Screen screen;
	for (i = 0; i < Player.LocalInteractions.Length; i++)
	{
		screen = P2Screen(Player.LocalInteractions[i]);
		if( screen != None && screen.IsRunning() )
			return true;
	}
	return false;
}

///steam 14/06/2016
function bool DecideToDelayScreenRequest(string sScreenRequest)
{
	if( sScreenRequest != "" 
		&& CoopDelayScreen_CurrentScreen == "" 
		&& CoopAnyScreenRunning() )
	{
		CoopDelayScreen_MyOldState = MyOldState;
		MyOldState = 'CoopDelayScreen_WaitScreen';
		CoopDelayScreen_CurrentScreen = sScreenRequest;
		///ClientMessage("DecideToDelayScreenRequest true");
		return true;
	}
	///else ClientMessage("DecideToDelayScreenRequest false");
	return false;
}

///steam 14/06/2016
state CoopDelayScreen_WaitScreen
{
	function CoopChangeScreen()
	{
		if( CoopDelayScreen_CurrentScreen != "" )
		{
			///ClientMessage("CoopDelayScreen_WaitScreen@CoopChangeScreen"@CoopDelayScreen_CurrentScreen);
			if( CoopDelayScreen_CurrentScreen == "DisplayVote" )
				DisplayVote();
			else if( CoopDelayScreen_CurrentScreen == "DisplayStats" )
				DisplayStats();
			else if( CoopDelayScreen_CurrentScreen == "DisplayNews" )
				DisplayNews();
			else if( CoopDelayScreen_CurrentScreen == "DisplayMap" )
				DisplayMap();
			else if( CoopDelayScreen_CurrentScreen == "DisplayMapErrands" )
				DisplayMapErrands();
			else if( CoopDelayScreen_CurrentScreen == "DisplayPick" )
				DisplayPick();
			MyOldState = CoopDelayScreen_MyOldState;
			CoopDelayScreen_CurrentScreen = "";
		}
		else GotoState(CoopDelayScreen_MyOldState);
	}
	function EndState()
	{
		MyOldState = CoopDelayScreen_MyOldState;
	}
Begin:
	Sleep(0.05);
	CoopChangeScreen();
}

///steam 16/06/2016 fixes bug with unworking weaps
/*function bool SwitchAfterOutOfAmmo()
{
	local bool bResult;
	bResult = Super.SwitchAfterOutOfAmmo();
	if( !bResult || Pawn.PendingWeapon == Pawn.Weapon || Pawn.PendingWeapon == None )
		SwitchToHands(true);
	return bResult;
}*/

///steam 18/06/2016
simulated function CallSavePlayerInfo(optional bool bRestart)
{
	local CoopTravelPlayerInfoInv tempPlayerInfo;
	local int nLastWeapGroup, nLastWeapOffset;

	///steam 06/06/2016 lastweapfix
	if( Pawn != None )
	{
		tempPlayerInfo = CoopPostalDude(Pawn).GetCoopTravelPlayerInfo();
		if( Buoyancy != 75 )
		{
			if( Pawn.Weapon != None && Pawn.Weapon.InventoryGroup != MyPawn.HandsClass.default.InventoryGroup )
			{
				nLastWeapGroup = Pawn.Weapon.InventoryGroup;
				nLastWeapOffset = Pawn.Weapon.GroupOffset;
			}
			else
			{
				nLastWeapGroup = LastWeaponGroupHands;
				nLastWeapOffset = LastWeaponOffsetHands;
			}
			if( tempPlayerInfo != None )
				tempPlayerInfo.CoopRememberLastWeapon(nLastWeapGroup, nLastWeapOffset);
		}
		if( tempPlayerInfo != None && PlayerReplicationInfo != None )
		{
			tempPlayerInfo.xKills = PlayerReplicationInfo.Kills;
			tempPlayerInfo.xDeaths = PlayerReplicationInfo.Deaths;
		}

		///steam 29/07/2016
		if( tempPlayerInfo != None )
			tempPlayerInfo.bXShowCoopPlayers = bShowCoopPlayers;
		//ClientMessage("bXShowCoopPlayers"@tempPlayerInfo.bXShowCoopPlayers);

		///steam 02/01/2017
		if( Buoyancy != 75 )
		{
			tempPlayerInfo.xCurrentClothes = CurrentClothes;
			if( CurrentClothes != DefaultClothes )
				tempPlayerInfo.xCurrentClothesDay = CoopGameInfo(Level.Game).TheGameState.CurrentDay;
			else tempPlayerInfo.xCurrentClothesDay = tempPlayerInfo.default.xCurrentClothesDay;
		}

		tempPlayerInfo.xWantedStatus = CoopPostalDude(Pawn).CoopWantedStatus;

		// UPD 21/04/2018 - allows to load saved items while travel
		if( bRestart )
			tempPlayerInfo.ResetTravelCheckSum();
	}
}

///steam 18/06/2016
simulated function CoopLevelPreTravel(optional bool bRestart)
{
	if( GetNPVehicleOwnedBy(Pawn) != None )
		ForceLeaveNPVehicle();
	CallSavePlayerInfo(bRestart);
	GotoState('CoopPlayerWaiting');
	bCoopLevelPreTravel = true;
}

///steam 27/07/2016
simulated function RequestClothes()
{
	if( Buoyancy != 75 )
	{
		Pawn.PlaySound(class'ClothesScreen'.default.ChangeClothesSound, SLOT_Misc);
		ChangeToNewClothes();
		return;
	}
	Super.RequestClothes();
}

///steam 08/10/2016
function NETCoopSetTyping(bool bTyping)
{
	bCoopIsTyping = bTyping;
}

///steam 12/10/2016
function CoopSetCustomSkins(string InSkin, string InFace)
{
	CoopCustomSkin = InSkin;
	CoopCustomFace = InFace;
}

///steam 18/11/2016
simulated function xClientSetCoopConfig()
{
	local bool bUseCoopDedicated;

	if( CoopGameReplicationInfo(GameReplicationInfo) != None )
		bUseCoopDedicated = CoopGameReplicationInfo(GameReplicationInfo).bCoopDedicated;

	if( NETChameleonModuleClass != None )
		NETChameleonModuleClass.static.SetDeadPoseOffset(bUseCoopDedicated);

	NETSetCoopConfig(bCoopTeleportDisabled);
}

///steam 18/11/2016
function NETSetCoopConfig(bool bUseCoopTpConfig)
{
	if( CoopPlayerReplicationInfo(PlayerReplicationInfo) != None )
		CoopPlayerReplicationInfo(PlayerReplicationInfo).bCoopTeleportDisabled = bUseCoopTpConfig;
}

///steam 20/11/2016
simulated function CoopLevelPreTravelEx(optional bool bRestart)
{
	if( myDeadController != None )
	{
		if( myDeadController.DeadFX != None && !myDeadController.DeadFX.bDeleteMe )
			myDeadController.DeadFX.bHidden = true;
	}

	if( !bCoopLevelPreTravel )
	{
		if( GetNPVehicleOwnedBy(Pawn) != None )
			ForceLeaveNPVehicle();
		CallSavePlayerInfo(bRestart);
		GotoState('CoopPlayerWaiting');
	}

	if( PlayerReplicationInfo.bOnlySpectator )
		Pawn = spawn(class'CoopSpectatorFakePawn',self,,Location);
}

///steam 20/11/2016
function xCallCoopStopFiring()
{
	StopFiring();
	xClientCoopStopFiring();
}

///steam 20/11/2016
simulated function xClientCoopStopFiring()
{
	StopFiring();
}

///steam 22/11/2016
simulated function SpawnNETStatsInfo()
{
	if( NETStatsInfoClass != None )
	{
		NETStatsInfo = spawn(NETStatsInfoClass,self);
		bShowNETStatsInfo = true;
	}
}

///steam 22/11/2016
simulated function bool RenderNETStatsInfo(Canvas C, FontInfo MyFont)
{
	if( bShowNETStatsInfo )
	{
		if( NETStatsInfo != None )
		{
			NETStatsInfo.RenderStats(C, MyFont);
			return true;
		}
	}
	return false;
}

///steam 02/01/2017
simulated function xClientChangeToNewClothes(class<Inventory> NewClothes)
{
	local class<ClothesInv> UseNewClass;

	if( Pawn != None )
	{
		P2MoCapPawn(Pawn).bInitializeAnimation = false;
		P2MoCapPawn(Pawn).ChangeAnimation();
	}

	if( NewClothes == None )
		return;

	UseNewClass = class<ClothesInv>(NewClothes);

	ChangeAllWeaponHandTextures(UseNewClass.default.HandsTexture, UseNewClass.default.FootTexture);

	P2Pawn(Pawn).HandsTexture = UseNewClass.default.HandsTexture;
	P2Pawn(Pawn).FootTexture = UseNewClass.default.FootTexture;

	P2Hud(MyHUD).ChangeHudSplats(UseNewClass.default.HudSplats);

	CurrentClothes = NewClothes;
}

///steam 10/04/2017 - to fix addon clientside standard hands bug
simulated function xClientApplyCurrentClothes()
{
	local class<ClothesInv> UseClothesClass;
	if( CurrentClothes == None )
		return;
	UseClothesClass = class<ClothesInv>(CurrentClothes);
	ChangeAllWeaponHandTextures(UseClothesClass.default.HandsTexture, UseClothesClass.default.FootTexture);
	P2Pawn(Pawn).HandsTexture = UseClothesClass.default.HandsTexture;
	P2Pawn(Pawn).FootTexture = UseClothesClass.default.FootTexture;
}

///steam 02/01/2017
function ChangeToNewClothes()
{
	Super.ChangeToNewClothes();

	if( Buoyancy != 75 )
		xClientChangeToNewClothes(CurrentClothes);

	///steam 13/05/2017
	if( Role == ROLE_Authority )
		spawn(class'CoopMiscTimerMulticast_InitialSetup',Pawn);

	if( CurrentClothes == DefaultClothes && CoopPostalDude(Pawn) != None )
		CoopPostalDude(Pawn).CoopApplyCustomSkin();
}

///steam 28/01/2017
simulated function CoopHideWeaponSelector()
{
	///steam 27/01/2017
	if( class'P2GameInfo'.Default.bUseWeaponSelector )
		HideWeaponSelector();
}

///steam 28/01/2017
simulated function xForceHealThePawn(float useHealth)
{
	if( myDeadController != None )
		myDeadController.xForceHealThePawn(useHealth);
}

/*exec function conftest()
{
	P2GameInfoSingle(Level.Game).EndOfGame(self);
}*/

function NotifyKilled(Controller Killer, Controller Killed, pawn Other)
{
	Super.NotifyKilled(Killer, Killed, Other);
	if( Other != None && !Other.bDeleteMe )
	{
		CallCoopCheapBloodEffectsFor(Other);
		xClientCheapBloodEffectsFor(Other);
	}
}

function CallCoopCheapBloodEffectsFor(Pawn Other)
{
	local P2MoCapPawn aPawn;

	if( Other == None )
		return;

	aPawn = P2MoCapPawn(Other);

	if( aPawn == None 
		|| aPawn.BloodPool != None )
		return;

	aPawn.BloodPool = spawn(class'CoopCheapBloodFeeder',aPawn,,aPawn.Location);
	aPawn.AttachToBone(aPawn.BloodPool, aPawn.BONE_PELVIS);
}

simulated function xClientCheapBloodEffectsFor(Pawn Other)
{
	if( Other == None 
		|| Level.NetMode != NM_Client )
		return;
	///Other.Weapon = None;
	CallCoopCheapBloodEffectsFor(Other);
	///ClientMessage("xClientCheapBloodEffectsFor()"@Other@P2MoCapPawn(Other).BloodPool);
}

///steam 10/04/2017
simulated function bool IsPlayerAllowedSendMsgs()
{
	return ( !bMuteSayMessages && (Level.TimeSeconds > MuteSayMessagesTime) );
}

exec function Say(string Msg)
{
	if( !IsPlayerAllowedSendMsgs() )
	{
		ClientMessage(ChatMutedMessage);
		return;
	}
	Super.Say(Msg);
}

exec function TeamSay(string Msg)
{
	if( !IsPlayerAllowedSendMsgs() )
	{
		ClientMessage(ChatMutedMessage);
		return;
	}
	Super.TeamSay(Msg);
}

///steam 01/07/2017
function DisplayNews()
{
	Super.DisplayNews();
	if( P2GameInfoSingle(Level.Game) != None )
	{
		///steam 01/07/2017 - hack to fix posttravel newspaper hold glitch
		if( MyNewsScreen != None )
			MyNewsScreen.bMustWait = false;
	}
}

///steam 28/07/2017
simulated function CoopDedicatedHostSetup()
{
	bIsPlayer = false;
	if( Pawn != None )
	{
		if( CoopPostalDude(Pawn) != None )
			CoopPostalDude(Pawn).bCoopDedicatedHost = true;
		Pawn.SetCollision(false,false,false);
		Pawn.bProjTarget = false;
		Pawn.bHidden = true;
	}
	if( PlayerReplicationInfo != None && CoopPlayerReplicationInfo(PlayerReplicationInfo) != None )
	{
		PlayerReplicationInfo.PlayerName = "ServerBot";
		///steam 02/08/2017 - bOnlySpectator disables Posses function (you can notice it after cut scenes)
		///PlayerReplicationInfo.bOnlySpectator = true;
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = true;
		PlayerReplicationInfo.bOutOfLives = true;
		CoopPlayerReplicationInfo(PlayerReplicationInfo).bCoopDedicatedHost = true;
	}
	if( myDeadController != None )
		myDeadController.bCoopDedicatedHost = true;
	CoopForceAddRevealErrands();
}

///steam 28/07/2017
simulated function bool IsCoopDedicatedHost()
{
	local CoopPlayerReplicationInfo CoopReplicaInfo;
	CoopReplicaInfo = CoopPlayerReplicationInfo(PlayerReplicationInfo);
	if( CoopReplicaInfo != None )
		return CoopReplicaInfo.bCoopDedicatedHost;
	return false;
}

///steam 28/07/2017
/*function DisplayVote()
{
	if( IsCoopDedicatedHost() )
	{
		return;
	}
	Super.DisplayVote();
}*/

///steam 28/07/2017
simulated function xClientSpecialMessage(string sMsg, optional bool bCritical)
{
	if( bCritical )
	{
		class'CoopSpecialLocalMessageCritical'.default.Message = sMsg;
		ReceiveLocalizedMessage(class'CoopSpecialLocalMessageCritical', 0, PlayerReplicationInfo);
	}
	else
	{
		class'CoopSpecialLocalMessage'.default.Message = sMsg;
		ReceiveLocalizedMessage(class'CoopSpecialLocalMessage', 0, PlayerReplicationInfo);
	}
}

///steam 05/08/2017
simulated function xCoopShowSubtitleByTag(string sSubTag)
{
	if( SubtitleManager != None )
		SubtitleManager.ShowSubtitle(sSubTag);
}

///steam 07/08/2017
function UpdatePlayerTravelInfo()
{
	// FIX 21/04/2018 - forbidden for dedicated host
	if( IsCoopDedicatedHost() )
		return;

	///NonDedicatedAutoSave 22/01/2018
	if( Pawn == None 
		&& Buoyancy == 75 
		&& bInterpolating )
		bWaitForPlayerTravelInfo = true;
	else bWaitForPlayerTravelInfo = false;

	if( MpPawn(Pawn) != None && CoopGameInfo(Level.Game) != None )
		CoopGameInfo(Level.Game).PostTravel_UpdatePlayerTravelInfoFor(MpPawn(Pawn));
}

///steam 21/08/2017
function bool CoopSaveIDDataLoaded()
{
	return (CoopSavePlayerID != "" && CoopSaveSystemID != "");
}

///steam 06/08/2017
function NETQueryPlayerID(string sPlayerID, string sSystemID)
{
	CoopSavePlayerID = sPlayerID;
	CoopSaveSystemID = sSystemID;
//	ClientMessage("NETQueryPlayerID()" @ "CoopSavePlayerID" @ CoopSavePlayerID @ "CoopSaveSystemID" @ CoopSaveSystemID);
	if( sPlayerID != "" && sSystemID != "" )
		UpdatePlayerTravelInfo();
}

///steam 08/08/2017
simulated function string CoopEnGenKey(string sData)
{
	local int i;
	local string sResult;
	for( i = 0 ; i < Len(sData) ; i++ )
	{
		sResult = sResult$rand(9);
	}
	return sResult;
}

///steam 08/08/2017 - asc range 42~90
function int CoopEnCapCharAsc(int nAsc)
{
	local int nMult;
	if( nAsc > 48 )
	{
		nMult = nAsc/48;
		nAsc = nAsc-(nMult*48);
	}
	return 42+nAsc;
}

///steam 08/08/2017
simulated function string CoopEnData(string sData, string sKey)
{
	local int i;
	local string sResult;
	for( i = 0 ; i < Len(sData) ; i++ )
	{
		sResult = sResult$Chr(CoopEnCapCharAsc(Asc(Mid(sData,i,1))^Asc(Mid(sKey,i,1))));
		//log(Mid(sData,i,1)@Chr(CoopEnCapCharAsc(Asc(Mid(sData,i,1))^Asc(Mid(sKey,i,1)))));
	}
	return sResult;
}

///steam 06/08/2017
simulated function xClientQueryPlayerID(string sPlayerID, string sServerID)
{
	local int i;
	local string sUsePlayerID;
	local string sUseSystemID;
	local bool bFound;

	if( CoopSaveIDSystemKey == "" )
		CoopSaveIDSystemKey = CoopEnGenKey(Level.ComputerName);
	if( CoopSaveIDSystemKey != "" )
		sUseSystemID = CoopEnData(Level.ComputerName, CoopSaveIDSystemKey);

//	ClientMessage("xClientQueryPlayerID() sPlayerID" @ sPlayerID @ "sServerID" @ sServerID @ "sUseSystemID" @ sUseSystemID);

	for( i = 0 ; i < CoopSaveIDInfo.Length ; i++ )
	{
		if( CoopSaveIDInfo[i].ServerID == sServerID )
		{
			sUsePlayerID = CoopSaveIDInfo[i].PlayerID;
			bFound = true;
			break;
		}
	}

	if( !bFound )
	{
		i = CoopSaveIDInfo.Length;
		CoopSaveIDInfo.Insert(i, 1);
		CoopSaveIDInfo[i].PlayerID = sPlayerID;
		CoopSaveIDInfo[i].ServerID = sServerID;
		sUsePlayerID = sPlayerID;
	}

	SaveConfig();
	NETQueryPlayerID(sUsePlayerID, sUseSystemID);
}

///steam 06/08/2017
function GetPlayerID(out string sPlayerID, out string sSystemID)
{
	/*if( CoopSavePlayerID == "" )
		Warn("FAILED TO LOAD CoopSavePlayerID");
	else if( CoopSaveSystemID == "" )
		Warn("FAILED TO LOAD CoopSaveSystemID");*/
	sPlayerID = CoopSavePlayerID;
	sSystemID = CoopSaveSystemID;
	return;
}

///steam 06/08/2017
function QueryPlayerID(string sPlayerID, string sServerID)
{
	xClientQueryPlayerID(sPlayerID, sServerID);
}

///steam 07/08/2017
function NETSavePlayer()
{
	local float CurTime;
	CurTime = Level.TimeSeconds;
	if( LastQuickSaveTime != 0 && CurTime - LastQuickSaveTime < 60 )
		MyPawn.Say(MyPawn.myDialog.lDude_SaveTooMuch);
	LastQuickSaveTime = CurTime;
	CoopGameInfo(Level.Game).CoopManualSavePlayer(MpPawn(Pawn));
}

///steam 13/08/2017
function bool xCanSpecSpectate(Pawn aPawn)
{
	if( aPawn.bDeleteMe 
//		|| aPawn.Health <= 0 
		|| aPawn.bHidden )
		return false;
	if( SpecSpectateType == 0 
		&& CoopPlayerController(aPawn.Controller) != None 
		&& !CoopPlayerController(aPawn.Controller).IsCoopDedicatedHost() 
		&& Level.Game.CanSpectate(self,true,aPawn.Controller) )
		return true;
	else if( SpecSpectateType == 1 && !aPawn.IsHumanControlled() && !aPawn.IsA('AnimalPawn') )
		return true;
	else if( SpecSpectateType == 2 && !aPawn.IsHumanControlled() && aPawn.IsA('AnimalPawn') )
		return true;
	return false;
}

///steam 13/08/2017
function bool xCanSpecSpectateAnimal(Pawn aPawn)
{
	if( aPawn.bDeleteMe 
		|| aPawn.Health <= 0 
		|| aPawn.bHidden 
		|| !aPawn.IsA('AnimalPawn') )
		return false;
	return ( SpecSpectateType == 2 );
}

///steam 13/08/2017
function bool xCanSpecSpectateAnimalControl(Pawn aPawn)
{
	if( xCanSpecSpectateAnimal(aPawn) )
		return ( aPawn.IsA('CatPawn') || aPawn.IsA('DogPawn') );
	return false;
}

///steam 13/08/2017 - it uses epic's movement replication not properly
function xSpecSpectateAnimalControl(Pawn aPawn, vector NewAccel, float DeltaTime)
{
	local AnimalController aCon;
	local rotator aPawnRot;
	local Name HoldState;

	if( aPawn.Health <= 0 
		|| aPawn.bDeleteMe )
		return;

	if( aPawn.IsA('CatPawn') && !aPawn.bCollideWorld )
	{
		if( aPawn.Physics != PHYS_None )
		{
			aPawn.SetPhysics(PHYS_None);
			aPawn.Velocity = vect(0,0,0);
			aPawn.Acceleration = vect(0,0,0);
		}
	}

	aCon = AnimalController(aPawn.Controller);
	if( aCon == None )
		return;

	///steam 21/08/2017 - there are wo controlable states to use HoldPosition and FallingStartDervish

	if( AWCatController(aCon) != None && AWCatController(aCon).bDervish )
	{
		if( aCon.IsInState('DervishAttach') )
			SpecSpectateAnimalDoNewOrder();
		HoldState = 'FallingStartDervish';
	}
	else HoldState = 'HoldPosition';

	if( bSpecSpectateConOrder )
		return;

	if( !aCon.IsInState('Dead') 
		&& !aCon.IsInState('ImOnFire') 
		&& !aCon.IsInState('RunOnFire') 
		&& !aCon.IsInState(HoldState) )
		aCon.GotoState(HoldState);

	if( aCon.IsInState(HoldState) )
	{
		SetLocation(aPawn.Location);
		if( aCon.IsInState('FallingStartDervish') )
			aPawn.SetPhysics(PHYS_Flying);
		aPawn.Acceleration = NewAccel;
	
		aCon.Focus = None;
		if( aCon.HomeList.node != None )
			aCon.HomeList.node = None;
		if( aCon.CurrentPathNode != None )
			aCon.CurrentPathNode = None;
		aCon.bMovePointValid = false;

		if( VSize(aPawn.Velocity) > 1 )
		{
			if( aCon.IsInState('HoldPosition') )
			{
				if( aPawn.bIsWalking )
					AnimalPawn(aPawn).SetAnimWalking();
				else AnimalPawn(aPawn).SetAnimRunning();
			}
			aPawnRot.Yaw = rotator(aPawn.Velocity).Yaw;
			aCon.FocalPoint = aPawn.Location + (vector(aPawnRot)*10);
			aCon.SetRotation(aPawnRot);
		}
		else
		{
			if( aCon.IsInState('HoldPosition') )
				AnimalPawn(aPawn).PlayWaiting();
			aPawnRot.Yaw = aPawn.Rotation.Yaw;
			aCon.FocalPoint = aPawn.Location + (vector(aPawnRot)*10);
			aCon.SetRotation(aPawnRot);
		}
	}
}

///steam 13/08/2017
function xSpecSpectateAnimalSetup(Pawn OldPawn, Pawn NewPawn)
{
	bSpecSpectateConOrder = false;
	if( OldPawn != None 
		&& OldPawn.IsA('AnimalPawn') 
		&& OldPawn.Health > 0 
		&& LambController(OldPawn.Controller) != None )
	{
		if( AWCatController(OldPawn.Controller) != None 
			&& AWCatController(OldPawn.Controller).bDervish )
		{
			if( OldPawn.Controller.IsInState('FallingStartDervish') )
			{
				AWCatController(OldPawn.Controller).TurnOffDervish(true);
				OldPawn.Controller.GotoState('FallingFar');
			}
		}
		else if( SpecSpectateConOldState != '' 
			&& SpecSpectateConOldState != 'None' 
			&& LambController(OldPawn.Controller).Attacker == None )
			OldPawn.Controller.GotoState(SpecSpectateConOldState);

		AnimalPawn(OldPawn).bIgnoresHearing = bSpecSpectIgnoresHearing;
		AnimalPawn(OldPawn).bIgnoresSenses = bSpecSpectIgnoresSenses;
	}
	if( NewPawn != None 
		&& NewPawn.IsA('AnimalPawn') 
		&& NewPawn.Health > 0 
		&& NewPawn.Controller != None )
	{
		bSpecSpectIgnoresHearing = AnimalPawn(NewPawn).bIgnoresHearing;
		bSpecSpectIgnoresSenses = AnimalPawn(NewPawn).bIgnoresSenses;
		SpecSpectateConOldState = NewPawn.Controller.GetStateName();
		AnimalPawn(NewPawn).bIgnoresHearing = true;
		AnimalPawn(NewPawn).bIgnoresSenses = true;
	}
}

///steam 13/08/2017
function NETSpecSpectateSwitch(byte NewType)
{
	SpecSpectateType = NewType;
}

///steam 13/08/2017
function SpecSpectateAnimalDoNewOrder()
{
	bSpecSpectateConOrder = true;
	SpecSpectateConOrderTime = Level.TimeSeconds + 1;
}

///steam 13/08/2017
function SpecSpectateAnimalDoOrderByState(AnimalController aCon, Name useState)
{
	if( aCon == None || useState == '' )
		return;
	aCon.GotoState(useState);
	ClientMessage(useState @ "order");
	SpecSpectateAnimalDoNewOrder();
}

///steam 13/08/2017
function NETSpecSpectateAnimalDo(optional byte Order)
{
	local Pawn aPawn, aEnemy;
	local AnimalController aCon;
	aPawn = Pawn(ViewTarget);
	if( aPawn == None 
		|| aPawn.bDeleteMe 
		|| aPawn.Controller == None 
		|| aPawn.Health <= 0 )
		return;
	aCon = AnimalController(aPawn.Controller);
	if( aCon == None )
		return;
	if( Level.TimeSeconds < SpecSpectateConOrderTime )
		return;
	if( bSpecSpectateConOrder )
	{
		bSpecSpectateConOrder = false;
		ClientMessage("Order removed");
		return;
	}
	if( aCon.IsA('CatController') )
	{
		if( aPawn.bCollideWorld )
		{
			if( aCon.IsA('AWCatController') && Order == 0 )
			{
				if( !AWCatController(aCon).bDervish )
				{
					AWCatController(aCon).MakePeopleScared(class'AnimalAttackMarker');
					AWCatController(aCon).TurnOnDervish(true); ///steam FIXME use DervishTime?
					aPawn.SetPhysics(PHYS_Flying);
					ClientMessage("Control dervish ON order");
				}
				else
				{
					SpecSpectateAnimalDoNewOrder();
					AWCatController(aCon).TurnOffDervish(true);
					aCon.GotoState('FallingFar');
					ClientMessage("Control dervish OFF order");
				}
			}
			else
			{
				if( aCon.IsA('AWCatController') && AWCatController(aCon).bDervish )
					return;
				switch( Order )
				{
					/**
					Thinking
					LetThemPetMe
					Hissing
					Pissing
					Covering
					Sitting
					WaitForButtSniff
					BeingShocked
					Standing
					**/
					case 1:
						SpecSpectateAnimalDoOrderByState(aCon, 'Sitting');
						break;
					case 2:
						SpecSpectateAnimalDoOrderByState(aCon, 'Hissing');
						break;
					case 3:
						SpecSpectateAnimalDoOrderByState(aCon, 'Pissing');
						break;
					case 4:
						SpecSpectateAnimalDoOrderByState(aCon, 'Covering');
						break;
					case 5:
						SpecSpectateAnimalDoOrderByState(aCon, 'WaitForButtSniff');
						break;
					case 6:
						SpecSpectateAnimalDoOrderByState(aCon, 'LetThemPetMe');
						break;
					case 7:
						SpecSpectateAnimalDoOrderByState(aCon, 'BeingShocked');
						break;
					case 8:
						SpecSpectateAnimalDoOrderByState(aCon, 'Standing');
						break;
					case 9:
						SpecSpectateAnimalDoOrderByState(aCon, 'Thinking');
						break;
				}
			}
		}
	}
	else if( aCon.IsA('DogController') )
	{
		if( Order == 0 )
		{
			aEnemy = CoopGameInfo(Level.Game).xGetValidPawnConFor(aCon).Pawn;
			if( FPSPawn(aEnemy) != None && !aEnemy.IsA('DogPawn') )
			{
				aCon.SetAttacker(FPSPawn(aEnemy));
				aCon.GotoState('AttackTarget');
				ClientMessage("Attack order" @ aEnemy.GetHumanReadableName());
				SpecSpectateAnimalDoNewOrder();
			}
		}
		else
		{
			switch( Order )
			{
				/**
				Thinking
				Pissing
				Sitting
				BeingShocked
				Standing
				Barking
				Growling
				TakeCrap
				**/
				case 1:
					SpecSpectateAnimalDoOrderByState(aCon, 'Sitting');
					break;
				case 2:
					SpecSpectateAnimalDoOrderByState(aCon, 'Growling');
					break;
				case 3:
					SpecSpectateAnimalDoOrderByState(aCon, 'Pissing');
					break;
				case 4:
					SpecSpectateAnimalDoOrderByState(aCon, 'Barking');
					break;
				case 5:
					SpecSpectateAnimalDoOrderByState(aCon, 'TakeCrap');
					break;
				case 6:
					SpecSpectateAnimalDoOrderByState(aCon, 'Thinking');
					break;
				case 7:
					SpecSpectateAnimalDoOrderByState(aCon, 'BeingShocked');
					break;
				case 8:
					SpecSpectateAnimalDoOrderByState(aCon, 'Standing');
					break;
				case 9:
					SpecSpectateAnimalDoOrderByState(aCon, 'Thinking');
					break;
			}
		}
	}
}

///steam 13/08/2017 - special spectating features implemented
state Spectating
{
	exec function AltFire(optional float F)
	{
		if( Pawn(ViewTarget) != None && xCanSpecSpectateAnimal(Pawn(ViewTarget)) )
		{
			if( xCanSpecSpectateAnimalControl(Pawn(ViewTarget)) )
				NETSpecSpectateAnimalDo();
			return;
		}
		Super.AltFire(F);
	}
	exec function SwitchWeapon(byte F)
	{
		if( Pawn(ViewTarget) != None && xCanSpecSpectateAnimal(Pawn(ViewTarget)) )
		{
			if( xCanSpecSpectateAnimalControl(Pawn(ViewTarget)) )
				NETSpecSpectateAnimalDo(F);
			return;
		}
		Super.SwitchWeapon(F);
	}
	function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
	{
		local Pawn aSpecPawn;
		local bool bSaveJump;

		aSpecPawn = Pawn(ViewTarget);
		if( aSpecPawn != None && xCanSpecSpectateAnimalControl(aSpecPawn) )
		{
			if (bPressedJump && aSpecPawn.CannotJumpNow())
			{
				bSaveJump = true;
				bPressedJump = false;
			}
			else
				bSaveJump = false;

			if (Role == ROLE_Authority)
			{
				xSpecSpectateAnimalControl(aSpecPawn, NewAccel, DeltaTime);
				if (bPressedJump)
					aSpecPawn.DoJump(bUpdating);
			}

			bPressedJump = bSaveJump;
		}
		else Super.ProcessMove(DeltaTime, NewAccel,DoubleClickMove, DeltaRot);
	}
	function HandleWalking()
	{
		Super.HandleWalking();
		if (Role == ROLE_Authority)
		{
			if( Pawn == None && Pawn(ViewTarget) != None && xCanSpecSpectateAnimalControl(Pawn(ViewTarget)) )
				Pawn(ViewTarget).SetWalking( (bRun != 0) && !Region.Zone.IsA('WarpZoneInfo') );
		}
	}
}

///steam 21/08/2017
function bool IsSpecSpectateAnimalUnderControl(Actor aActor)
{
	local Controller aCon;
	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
	{
		if( aCon != self 
			&& CoopPlayerController(aCon) != None 
			&& CoopPlayerController(aCon).ViewTarget != None 
			&& CoopPlayerController(aCon).ViewTarget == aActor )
			return true;
	}
	return false;
}

///steam 09/08/2017 - test spectator
function ServerViewNextPlayer()
{
	local Controller C;
	local Pawn Pick;
	local bool bFound, bRealSpec, bWasSpec;

    bRealSpec = PlayerReplicationInfo.bOnlySpectator;
    // RWS CHANGE: Merged from UT2003
	bWasSpec = !bBehindView && (ViewTarget != Pawn) && (ViewTarget != self);
    PlayerReplicationInfo.bOnlySpectator = true;

	// view next player
	for( C = Level.ControllerList ; C != None ; C = C.NextController )
	{
		if( C.Pawn != None 
			&& xCanSpecSpectate(C.Pawn) )
		{
			if( xCanSpecSpectateAnimalControl(C.Pawn) )
			{
				if( !IsSpecSpectateAnimalUnderControl(C.Pawn) )
					xSpecSpectateAnimalSetup(Pawn(ViewTarget), C.Pawn);
				else continue;
			}
			if ( Pick == None )
				Pick = C.Pawn;
			if ( bFound )
			{
				Pick = C.Pawn;
				break;
			}
			else
				bFound = ( ViewTarget == C.Pawn );
		}
	}
	SetViewTarget(Pick);
	// RWS Change: Set client view, from UT2003
    ClientSetViewTarget(Pick);
	// RWS CHANGE: Check if was spectating, from UT2003
    if ( (ViewTarget == self) || bWasSpec )
		bBehindView = false;
	else
		bBehindView = true; //bChaseCam;
    // RWS CHANGE: set client behindview too, from UT2003
	ClientSetBehindView(bBehindView);
    PlayerReplicationInfo.bOnlySpectator = bRealSpec;
}

///steam 09/08/2017 - test spectator
function ServerViewSelf()
{
	if( Pawn(ViewTarget) != None )
		SetLocation(ViewTarget.Location);
	Super.ServerViewSelf();
}

///steam 10/08/2017
simulated function xClientUpdateURL(string NewOption, string NewValue, bool bSaveDefault)
{
	UpdateURL(NewOption, NewValue, bSaveDefault);
}

///steam 10/08/2017
exec function Name( coerce string S )
{
	///STUB
}
exec function SetName( coerce string S)
{
	///STUB
}
function ChangeName( coerce string S )
{
	///STUB
}

///steam 18/08/2017
function CoopRequestNews()
{
	local Texture useNewsTex;
	useNewsTex = CoopGameInfo(Level.Game).GetNewsTexture();
	if( useNewsTex != None )
		xClientCallMapRequest(false, useNewsTex);
}

///steam 18/08/2017
simulated function bool DisableCoopTeleport()
{
	bCoopTeleportDisabled = !bCoopTeleportDisabled;
	SaveConfig();
	NETDisableCoopTeleport(bCoopTeleportDisabled);
	return bCoopTeleportDisabled;
}

///steam 18/08/2017
simulated function NETDisableCoopTeleport(bool bDisabled)
{
	CoopPlayerReplicationInfo(PlayerReplicationInfo).bCoopTeleportDisabled = bDisabled;
}

///steam 02/09/2017
function NETCoopLoadCustomMod(string ModName, int Idx)
{
	if( PlayerReplicationInfo.bAdmin )
		CoopGameInfo(Level.Game).CallCoopLoadCustomMod(ModName, Idx);
}

///steam 02/09/2017
function NETCoopLoadCustomMap(string URL)
{
	if( PlayerReplicationInfo.bAdmin )
		CoopGameInfo(Level.Game).LoadCustomMap(URL);
}

///steam 27/10/2017
function ServerGetDown()
{
	if( CoopPostalDude(Pawn) != None 
		&& (CoopPostalDude(Pawn).IsGameNowCinematic() || Pawn.Health <= 0) )
		return;
	Super.ServerGetDown();
}

exec function TCam()
{
	bFreeCamera = true;
	bBehindView = !bBehindView;
}

exec function BCam()
{
	bFreeCamera = false;
	bBehindView = !bBehindView;
}

/*exec function comnetspeed(int NewSpeed)
{
	ClientMessage("Player.CurrentNetSpeed" @ Player.CurrentNetSpeed);
	ConsoleCommand("set Player CurrentNetSpeed" @ NewSpeed);
}*/

///steam 18/12/2017 - calls from CoopMiscTimer_ClientInitPingOptimize.uc
simulated function xClientInitPingOptimize()
{
	local string UseInternetIP;

	if( PlayerReplicationInfo == None )
		return;

	//ClientMessage("xClientInitPingOptimize" @ Level.TimeSeconds);

	if( bCoopPingOptimize )
	{
		/// so lets check LAN range 192.168.*, 10.*, 172.16.* to avoid ping optimization for LAN clients
		UseInternetIP = Level.GetAddressURL();
		if( Left(UseInternetIP,8) != "192.168." 
			&& Left(UseInternetIP,7) != "172.16." 
			&& Left(UseInternetIP,3) != "10." )
		{
			///if( CoopCurrentNetSpeed != -1 )
			///	ConsoleCommand("set Player CurrentNetSpeed" @ FMax(CoopCurrentNetSpeed, 100));
			//ClientMessage("xClientInitPingOptimize");
			ConsoleCommand("NetSpeed 20000");
			CoopPingOptimizeTime = Level.TimeSeconds + 3;
		}
	}

	///steam 18/12/2017 - to restore actual name without secret code
	UpdateURL("Name", PlayerReplicationInfo.PlayerName, true);
}

function NETCoopResetVote()
{
	if( CoopGameInfo(Level.Game) != None )
		CoopGameInfo(Level.Game).xRegisterResetVote(self);
}

///steam 07/09/2018 - rendering subs over the client map
function ClientForceDrawSubs(Canvas Canvas)
{
	if( CoopHUD(myHUD) == None )
		return;
	CoopHUD(myHUD).ClientForceDrawSubs(Canvas);
}

///steam 19/12/2018 update
function NotifyCrushedDeath()
{
	if( myDeadController != None )
		myDeadController.NotifyCrushedDeath();
}

///steam 19/12/2018 update
function PawnIsInPain(PhysicsVolume PainVolume)
{
	if( CoopPostalDude(Pawn) != None && Pawn.Health <= 0 )
		NotifyCrushedDeath();
}

// 5024 change 2020: new method
simulated function NotifyPlayerValid()
{
	// NickP: Apply our sweet FOV when player is valid (from BeginPlay() doesn't work)
	if (HackedFOV != 0)
		FOV(HackedFOV);
	// End

	Super.NotifyPlayerValid();
}

exec function FOV(float F)
{
	local vector Res;

	// NickP: Try to ignore when resolution is not valid
	Res = GetResolution();
	if (Res.X <= 0 || Res.Y <= 0)
	{
		return;
	}

	Super.FOV(F);

	// ClientMessage("FOV:"@DefaultFOV);
	// log("FOV:"@DefaultFOV);
}

event ChangedResolution(int NewX, int NewY, bool bFullscreen)
{
	// Originally this code uses DesiredFOV which is wrong, needs to fix in the new postal builds
	if (HackedFOV != 0)
		FOV(HackedFOV);
}

simulated function KarmaParamsSkel GetNewRagdollSkel(FPSPawn NewPawn, name skelname)
{
	local P2MoCapPawn UsePawn;
	if (Role < ROLE_Authority)
	{
		UsePawn = P2MoCapPawn(NewPawn);
		if (UsePawn != None)
		{
			// HACK! FIX FOR: BasePeople.AWPerson.Dying.BeginState - BasePeople.AWPerson.PlayDying - APawn::UpdateMovementAnimation - AFPSPawn::UpdateMovementAnimation
			// Theoretically, we must avoid calling bCollideWorld = true in the P2Pawn.Dying.BeginState:3881 (build 5024)
			// Needs be fixed in the new game build, see original STP code, also used in the CoopNETChamaleonModuleClient.NETChameleonClient_Pawn()
			UsePawn.bCompletedDeadSetup = true;
		}
	}
	return Super.GetNewRagdollSkel(NewPawn, skelname);
}

// Scene skip is disabled in coop due to some bugs
simulated function StartCutscene()
{
	// STUB
}

simulated function bool SawCutscene(SceneManager InCutscene)
{
	return false;
}

simulated function RecordCutscene(SceneManager InCutscene)
{
	// STUB
}

// 11/10/22 - Temporary removed
exec function InventoryMenu()
{
	// STUB
}

defaultproperties
{
	//CoopCurrentNetSpeed=4000
	CoopPingOptimizeTime=-1
	bCoopPingOptimize=true

	CoopFartSounds(0)=Sound'AmbientSounds.fart1'
	CoopFartSounds(1)=Sound'AmbientSounds.fart3'
	CoopFartSounds(2)=Sound'AmbientSounds.fart4'
	CoopFartSounds(3)=Sound'AmbientSounds.fart5'
	ChatMutedMessage="You're muted, honey"

	NETSceneCameraClass=class'CoopMatineeCamera'

	NETStatsInfoClass=class'CoopNETStatsInfo'

	NETChameleonModuleClass=class'CoopNETChameleonModuleHost'

	bNeverSwitchOnPickup=true

	 HudArmorIcon=Texture'HUDPack.Icon_Special_Vest'
	 CoopMapClass="NicksCoop.CoopMapInteraction"
	 PlayerReplicationInfoClass=class'CoopPlayerReplicationInfo'
     GarySkins(0)=Texture'ChameleonSkins.Special.Gary'
     GarySkins(1)=Texture'MPSkins.BlueTeam.MB__136__Mini_M_Jacket_Pants'
     GarySkins(2)=Texture'MPSkins.RedTeam.MB__137__Mini_M_Jacket_Pants'
     BeepSound=Sound'MpSounds.Misc.Talk'
     DeathHints1(0)="Hmmm... looks like you're dying pretty quickly."
     DeathHints1(1)="Instead of just standing around enjoying the pain,"
     DeathHints1(2)="try running and hiding from your aggressors."
     DeathHints1(3)="Wait and hide from them and then attack them"
     DeathHints1(4)="when they come running around the corner to find you."
     DeathHints2(0)="Make sure to conserve your health powerups for the worst"
     DeathHints2(1)="fire-fights. Try to keep and eye on your health for the"
     DeathHints2(2)="best time for a health boost. Gather up lots of powerups"
     DeathHints2(3)="before going into a big battle."
     DeathHints3(0)="Take a slower pace when you get into fire-fights."
     DeathHints3(1)="If you rush through an area of people who are trying to"
     DeathHints3(2)="kill you, get ready for a lot of damage."
     DeathHints3(3)="Try moving along slowly, letting only a few of their"
     DeathHints3(4)="buddies know about you at once. They'll be easier to handle."
     FireDeathHints1(0)="That sure looks hot. I bet it hurts too."
     FireDeathHints1(1)="Did you know there's a way to put yourself out"
     FireDeathHints1(2)="when you're on fire? Yup... there sure is."
     FireDeathHints1(3)="Try thinking with you're lower half next time."
}
