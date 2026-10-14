//=============================================================================
// CoopPostalDude.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015-2017.
//=============================================================================

class CoopPostalDude extends AWPostalDude;

const COMACT_FLIPBIRD = 'caFLIPBIRD';
const COMACT_DANCING = 'caDANCING';
const COMACT_SPECIAL = 'caSPECIAL';
const COMACT_LAUGH = 'caLAUGH';
const COMACT_ANGRY = 'caANGRY';
const COMACT_APPLAUSE = 'caAPPLAUSE';
const COMACT_SHOCK = 'caSHOCK';
const COMACT_SCREAM = 'caSCREAM';
const COMACT_THUMBUP = 'caTHUMBUP';
const COMACT_FLEAS = 'caFLEAS';
const COMACT_KISS = 'caKISS';
const COMACT_THATSME = 'caTHATSME';
const COMACT_OBSCENE = 'caOBSCENE';

const DISTANCE_TO_EXPLODE_HEAD = 1;

struct NETAnimStruct
{
	var float Rate;
	var Name Anim;
};
var NETAnimStruct NETAnim;
var Name NETMovementAnims[4];
var float NETAnimTime;
var float NETSkinUpdateTime;

var Name DanceAnim;
var Name BirdAnim;
var Name SpecialAnim;

var bool bCoopPlayer;
var bool bCoopPlayerDied;

///steam 15/06/2016
var Controller CoopOldController;

///steam 28/06/2016
var bool bSwitchHandsForced;

///steam 30/07/2016
var bool bCoopHaveSignaturesErrand;

///steam 02/08/2016 it will set true once Died() called, set false in TakeDamage()
var bool bCoopAlreadyDied;

///steam 12/10/2016
var string CoopCustomSkin;
var string CoopCustomFace;

///steam 30/06/2017
var class<Inventory> ClientMapInvClass;

///steam 28/07/2017
var bool bCoopDedicatedHost;

// UPD 20/04/2018 - separate wanted
var CoopMiscTimer_WantedStatus CoopWantedTimer;
var float CoopWantedStatus;

replication
{
	unreliable if( Role == ROLE_Authority )
		bCoopPlayer, bCoopPlayerDied, CoopWantedStatus;

	unreliable if( Role < ROLE_Authority )
		caNETFlipBird, caNETDancing, caNETSpecial, caNETLaugh, caNETAngry, caNETApplause, 
		caNETShock, caNETScream, caNETThumbup, caNETFleas, caNETKiss, caNETThatsMe, 
		caNETObscene;

	reliable if( Role == ROLE_Authority )
		xClientCallSwitchHands;
}

static final operator(24) bool isin(string a, string b)
{
	return (InStr(caps(b), caps(a)) != -1);
}

event FellOutOfWorld()
{
	if ( Role < ROLE_Authority )
		return;
	Health = -1;
	SetPhysics(PHYS_None);
//	Weapon = None;

	///steam 19/12/2018 update
	if( CoopPlayerController(Controller) != None && !bCoopAlreadyDied )
		CoopPlayerController(Controller).NotifyCrushedDeath();

	Died(None, class'Gibbed', Location);
}

simulated function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if( bCoopPlayer )
	{
		if( bCoopAlreadyDied )
			return;

		Health = 0;

		bCoopPlayerDied = true;

		///steam 13/06/2016
		if( Controller != None && Controller.PlayerReplicationInfo != None )
			Controller.PlayerReplicationInfo.Deaths += 1;

		///steam 31/07/2016 this should be covered by NotifyKilled() in games's CoopKilled(), but to be sure
		if( Killer != None && PersonController(Killer) != None )
		{
			PersonController(Killer).Enemy = None;
			PersonController(Killer).Attacker = None;
		}

		if( Level.Game != None && CoopGameInfo(Level.Game) != None )
			CoopGameInfo(Level.Game).CoopKilled(Killer, Controller, self, damageType);

		bCoopAlreadyDied = true;
	}
	else Super.Died(Killer, damageType, HitLocation);
}

///steam 02/08/2016 should be called when pawn got health
function xPostForceHealThePawn(float useHealth)
{
	bCoopAlreadyDied = false;
}

simulated function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
	Vector momentum, class<DamageType> damageType)
{
	//if( damageType == class'ShovelDamage' && bCoopPlayer )
	//	return;
	if( bCoopPlayer )
	{
		if( Health <= 0 )
		{
			Health = 0;
			return;
		}
		else bCoopAlreadyDied = false;
	}
	Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
}

///steam 31/07/2016 merged from xMpPawn.uc
simulated function Destroyed()
{
	if( CoopGameInfo(Level.Game) != None 
		&& CoopPlayerController(Controller) != None 
		&& Controller.Buoyancy != 75 ///NonDedicatedAutoSave 22/01/2018
		&& !CoopPlayerController(Controller).IsCoopDedicatedHost() 
		&& Inventory != None )
	{
		CoopGameInfo(Level.Game).PlayerLeave_UpdatePlayerTravelInfoFor(self);
	}

	// Notify other things that we were killed, because for some unknown (and
	// unknowable) reason, epic chose not to kill the pawn the usual way when
	// a player suddenly exits the game (using "exit" or "quit")
	if (Level.Game != None)
		Level.Game.NotifyKilled(None, Controller, self);

	// UPD 20/04/2018 - separate wanted
	if( CoopWantedTimer != None )
		CoopWantedTimer.Destroy();

	Super.Destroyed();
}

event EncroachedBy(actor Other);

event bool EncroachingOn( actor Other )
{
	return false;
}

///steam 27/10/2017
function bool IsGameNowCinematic()
{
	if( P2GameInfo(Level.Game) != None )
		return P2GameInfo(Level.Game).IsCinematic();
	return false;
}

///steam 27/10/2017
function ComActionTalkSome(out P2Dialog.SLine line, ETalk TalkType, optional bool bNotifyNPC)
{
	local CoopPlayerController aPC;
	local FPSPawn CheckP;
	local byte StateChange;

	if( IsGameNowCinematic() || Health <= 0 )
		return;

	aPC = CoopPlayerController(Controller);
	if( aPC == None )
		return;

	if( !aPC.bStillTalking )
	{
		aPC.SayTime = Say(line) + 0.5;
		aPC.SetTimer(aPC.SayTime, false);
		aPC.bStillTalking = true;

		if (bNotifyNPC)
		{
			foreach RadiusActors(class'FPSPawn', CheckP, aPC.DUDE_SHOUT_GET_DOWN_RADIUS, Location)
			{
				if(CheckP != self
					&& LambController(CheckP.Controller) != None)
				{
					// Tell them who's shouting
					StateChange = 0;
					LambController(CheckP.Controller).RespondToTalker(self, P2Pawn(aPC.Enemy), TalkType, StateChange);
				}
			}
		}
	}
}

exec function comMiddleFinger()
{
	caNETFlipBird();
}

exec function comDance()
{
	caNETDancing();
}

exec function comDoSpecial()
{
	caNETSpecial();
}

exec function comLaugh()
{
	caNETLaugh();
}

exec function comAngry()
{
	caNETAngry();
}

exec function comApplause()
{
	caNETApplause();
}

exec function comShock()
{
	caNETShock();
}

exec function comScream()
{
	caNETScream();
}

exec function comThumbup()
{
	caNETThumbup();
}

exec function comFleas()
{
	caNETFleas();
}

exec function comKiss()
{
	caNETKiss();
}

exec function comThatsMe()
{
	caNETThatsMe();
}

exec function comObscene()
{
	caNETObscene();
}

simulated function caNETFlipBird()
{
	SetAnimAction(COMACT_FLIPBIRD);
}

simulated function caNETDancing()
{
	SetAnimAction(COMACT_DANCING);
}

simulated function caNETSpecial()
{
	SetAnimAction(COMACT_SPECIAL);
}

simulated function caNETLaugh()
{
	SetAnimAction(COMACT_LAUGH);
}

simulated function caNETAngry()
{
	SetAnimAction(COMACT_ANGRY);
}

simulated function caNETApplause()
{
	SetAnimAction(COMACT_APPLAUSE);
}

simulated function caNETShock()
{
	SetAnimAction(COMACT_SHOCK);
}

simulated function caNETScream()
{
	SetAnimAction(COMACT_SCREAM);
}

simulated function caNETThumbup()
{
	SetAnimAction(COMACT_THUMBUP);
}

simulated function caNETFleas()
{
	SetAnimAction(COMACT_FLEAS);
}

simulated function caNETKiss()
{
	SetAnimAction(COMACT_KISS);
}

simulated function caNETThatsMe()
{
	SetAnimAction(COMACT_THATSME);
}

simulated function caNETObscene()
{
	SetAnimAction(COMACT_OBSCENE);
}

simulated function caDoLaugh()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('s_laugh', 1.1, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.llaughing, TALK_getdown);
}

simulated function caDoAngry()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('s_angry', 1.1, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lNegativeResponse, TALK_getdown);
}

simulated function caDoApplause()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('s_applause', 1.1, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lThanks, TALK_getdown);
}

simulated function caDoShock()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('s_shock', 1.1, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lGettingShocked, TALK_getdown);
}

simulated function caDoScream()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('s_scream', 1.1, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lscreaming, TALK_getdown);
}

simulated function caDoThumbup()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('pl_s_gesture_thumbup', 1.1, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lThanks, TALK_getdown);
}

simulated function caDoFleas()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('fr_removebandage', 2.2, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lGrunt, TALK_getdown);
}

simulated function caDoKiss()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('pl_kiss', 1.4, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lGettingShocked, TALK_getdown);
}

simulated function caDoThatsme()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('pl_gesture_thatsme2', 1.1, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lDude_NowIsDude, TALK_getdown);
}

simulated function caDoSpecial()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim(SpecialAnim, 1.4, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lPissOutFireOnSelf, TALK_getdown);
}

simulated function caDoDance()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim(DanceAnim, 1.4, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lYes, TALK_getdown);
}

simulated function caDoFlipBird()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim(BirdAnim, 1.4, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lNegativeResponse, TALK_FuckYou, true);
}

simulated function caObscene()
{
	AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
	PlayAnim('pl_gesture_hipthrust', 1.2, 0.1, WEAPONCHANNEL);
	if( myDialog != None )
		ComActionTalkSome(myDialog.lNegativeResponse, TALK_getdown);
}

simulated event SetAnimAction(name NewAction)
{
	AnimAction = NewAction;

	if ( AnimAction == 'sg_pull_pin' )
	{
		WeaponBlendTime = FIRING_BLEND_TIME;
		AnimBlendParams(WEAPONCHANNEL, 1.0, 0,0, BONE_BLENDFIRING);
		PlayAnim(NewAction, 1.0, 0.1, WEAPONCHANNEL);
	}

	else if(AnimAction == 's_suicide2')
		PlayAnim('s_suicide2', 1.5, 0.15);
	else if(AnimAction == GetAnimKick())
		PlayAnim(GetAnimKick(), 5.0, 0.15);
	else if(AnimAction == BURN_ACTION_MP)
		SwapToBurnVictim();
	else if(AnimAction == FOLLOW_ME)
		DoFollowMe();
	else if(AnimAction == STAY_HERE)
		DoStayHere();
	else if(AnimAction == COMACT_FLIPBIRD)
		caDoFlipBird();
	else if(AnimAction == COMACT_DANCING)
		caDoDance();
	else if(AnimAction == COMACT_SPECIAL)
		caDoSpecial();
	else if(AnimAction == COMACT_LAUGH)
		caDoLaugh();
	else if(AnimAction == COMACT_ANGRY)
		caDoAngry();
	else if(AnimAction == COMACT_APPLAUSE)
		caDoApplause();
	else if(AnimAction == COMACT_SHOCK)
		caDoShock();
	else if(AnimAction == COMACT_SCREAM)
		caDoScream();
	else if(AnimAction == COMACT_THUMBUP)
		caDoThumbup();
	else if(AnimAction == COMACT_FLEAS)
		caDoFleas();
	else if(AnimAction == COMACT_KISS)
		caDoKiss();
	else if(AnimAction == COMACT_THATSME)
		caDoThatsme();
	else if(AnimAction == COMACT_OBSCENE)
		caObscene();
}

///steam 30/04/2016 probably this tick doesn't work at all
simulated function Tick(float DeltaTime)
{
	if( Weapon == None )
		Weapon = None;

	if( SelectedItem == None )
		SelectedItem = None;

	Super.Tick(DeltaTime);
}

function ExplodeHead(vector HitLocation, vector Momentum)
{
	//STUB
}

simulated function CallForceAddDefaultInventory()
{
	spawn(class'CoopMiscTimer_ForceAddDefInv',self);
}

///steam 04/04/2016
simulated function CheckAdminInv()
{
	local CoopTravelAdminInv tempAdminLoginInv;

	tempAdminLoginInv = CoopTravelAdminInv(FindInventoryType(class'CoopTravelAdminInv'));

	if( tempAdminLoginInv != None )
		tempAdminLoginInv.CheckOwnedPass();
}

///steam 07/06/2016 called in CoopMiscTimer_ForceAddDefInv
simulated function ForceAddDefaultInventory()
{
	///steam 16/06/2016
	ClientAddDefaultInventory();

	///steam 04/04/2016
	CheckAdminInv();

	///steam 06/06/2016
	CheckPlayerInfoInv();

	///steam 19/06/2016
	ChangedWeapon();

	///steam 11/10/2016
	DudeCheckHeadSkin();///it calls from gameinfo in normal SP, but in coop here!

	///steam 12/10/2016
	CoopApplyCustomSkin();

	///steam 21/08/2017 - must call very important functions again after delay
	spawn(class'CoopMiscTimer_PostConnectInit',self);
}

///steam 21/08/2017 - must call very important functions after delay again from CoopMiscTimer_PostConnectInit.uc
simulated function CoopPostConnectInit()
{
//	ClientMessage(self @ "CoopPostConnectInit() called");
}

///steam 12/10/2016
simulated function CoopApplyCustomSkin()
{
	local Texture newInSkin;
	///log("CoopApplyCustomSkin() called for"@self@Controller);
	newInSkin = Texture(DynamicLoadObject(CoopCustomSkin, class'Texture'));
	if( newInSkin != None && Skins[0] == default.Skins[0] )///steam 02/01/2017 Skins[0] == default.Skins[0]
		Skins[0] = newInSkin;
}

///steam 12/10/2016
function CoopLoadCustomSkins()
{
	if( Controller != None && CoopPlayerController(Controller) != None )
	{
		CoopCustomSkin = CoopPlayerController(Controller).CoopCustomSkin;
		CoopCustomFace = CoopPlayerController(Controller).CoopCustomFace;
	}
}

///steam invreplace 23/02/2016
function Inventory CreateInventoryByClass(class<Inventory> MakeMe, optional out byte CreatedNow, optional bool bIgnoreDifficulty)
{
	if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).CoopBaseMutator != None )
		MakeMe = CoopGameInfo(Level.Game).CoopBaseMutator.GetInventoryObjClass(MakeMe);
	///log(self@"CreateInventoryByClass() detect CoopBaseMutator"@CoopGameInfo(Level.Game).CoopBaseMutator);

	return Super.CreateInventoryByClass(MakeMe, CreatedNow, bIgnoreDifficulty);
}
///steam invreplace 23/02/2016
function Inventory CreateInventory(string InventoryClassName, optional out byte CreatedNow)
{
	return Super.CreateInventory(InventoryClassName, CreatedNow);
}

simulated function FaceRotation( rotator NewRotation, float DeltaTime )
{
	if( bCoopPlayerDied )
	{
		NewRotation.Pitch = 0;
		SetRotation(NewRotation);
		return;
	}
	Super.FaceRotation(NewRotation, DeltaTime);
}

///steam 11/04/2016
simulated function PostBeginPlay()
{
	Tag = default.Tag;
	Super.PostBeginPlay();
}

///steam 01/05/2016
state Dying
{
	function BeginState()
	{
		if( bCoopPlayer )
		{
			if( Controller != None && CoopPlayerController(Controller) != None )
				CoopPlayerController(Controller).xForceReturnViewToPawn();
			GotoState('Living');
		}
		else Super.BeginState();
	}
}

///steam 18/06/2016
simulated function CoopTravelPlayerInfoInv GetCoopTravelPlayerInfo()
{
	local CoopTravelPlayerInfoInv tempPlayerInfoInv;

	tempPlayerInfoInv = CoopTravelPlayerInfoInv(FindInventoryType(class'CoopTravelPlayerInfoInv'));
	if( tempPlayerInfoInv == None )
		tempPlayerInfoInv = CoopTravelPlayerInfoInv(CreateInventoryByClass(class'CoopTravelPlayerInfoInv'));
	
	return tempPlayerInfoInv;
}

///steam 19/08/2017
simulated function string GetCoopTravelCheckSum()
{
	local CoopTravelPlayerInfoInv tempPlayerInfoInv;
	tempPlayerInfoInv = GetCoopTravelPlayerInfo();
	if( tempPlayerInfoInv != None )
		return tempPlayerInfoInv.GetTravelCheckSum();
	return "";
}
simulated function ResetCoopTravelCheckSum()
{
	local CoopTravelPlayerInfoInv tempPlayerInfoInv;
	tempPlayerInfoInv = GetCoopTravelPlayerInfo();
	if( tempPlayerInfoInv != None )
		tempPlayerInfoInv.ResetTravelCheckSum();
}

///steam 06/06/2016
simulated function CheckPlayerInfoInv(optional CoopTravelPlayerInfoInv usePlayerInfoInv)
{
	local CoopTravelPlayerInfoInv tempPlayerInfoInv;
	local Controller tempController;
	local bool bCustomClothes;

	if( usePlayerInfoInv != None )
		tempPlayerInfoInv = usePlayerInfoInv;
	else tempPlayerInfoInv = GetCoopTravelPlayerInfo();

	if( tempPlayerInfoInv != None )
	{
		tempPlayerInfoInv.CoopGetLastWeapon();
		if( Controller != None && PlayerController(Controller) != None )
			tempController = Controller;
		else if( CoopOldController != None )
			tempController = CoopOldController;
		if( tempController != None && tempController.PlayerReplicationInfo != None )
		{
			tempController.PlayerReplicationInfo.Score = tempPlayerInfoInv.xKills;
			tempController.PlayerReplicationInfo.Kills = tempPlayerInfoInv.xKills;
			tempController.PlayerReplicationInfo.Deaths = tempPlayerInfoInv.xDeaths;
		}

		///steam 29/07/2016
		CoopPlayerController(tempController).LoadCoopPlayersConfig(tempPlayerInfoInv.bXShowCoopPlayers);

		///steam 02/01/2017
		if( tempController.Buoyancy != 75 && CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).TheGameState != None )
		{
			if( tempPlayerInfoInv.xCurrentClothes != None )
				bCustomClothes = (tempPlayerInfoInv.xCurrentClothes.default.ActorID == 'custom_clothes');
			if( tempPlayerInfoInv.xCurrentClothesDay == CoopGameInfo(Level.Game).TheGameState.CurrentDay 
				|| bCustomClothes )
			{
				if( tempPlayerInfoInv.xCurrentClothes != None )
				{
					CoopPlayerController(tempController).CurrentClothes = tempPlayerInfoInv.xCurrentClothes;
					CoopPlayerController(tempController).SetClothes(CoopPlayerController(tempController).CurrentClothes);
				}
			}
			else
			{
				if( tempPlayerInfoInv.xCurrentClothes != None )
				{
					tempPlayerInfoInv.xCurrentClothes = None;
					tempPlayerInfoInv.xCurrentClothesDay = -1;
				}
				///steam 10/04/2017 - apply clothes clientside anyway
				CoopPlayerController(tempController).xClientApplyCurrentClothes();
			}
		}

		CoopWantedStatus = tempPlayerInfoInv.xWantedStatus;
		CoopWantedTimer_Recover();
	}
}

///steam 15/06/2016
function CoopSetupOldController(Controller aController)
{
	CoopOldController = aController;
}

///steam 03/06/2017
function xFindAndDeleteInventory(class<Inventory> aClass)
{
	local Inventory tempInv;
	if( aClass == None )
		return;
	tempInv = FindInventoryType(aClass);
	if( tempInv != None )
		DeleteInventory(tempInv);
}

///steam 16/06/2016 not a client function, means for clients
function ClientAddDefaultInventory()
{
	local CoopTravelPlayerInfoInv tempPlayerInfoInv;

	if( Controller != None 
		&& CoopPlayerController(Controller) != None ///steam 04/01/2017 host clipboard missing bug fixed
		&& Controller.Buoyancy != 75 )
	{
		AddDefaultInventory();

		///steam 01/08/2017 - instead of previous code, now it's pretty the same as Host
		if( CoopGameInfo(Level.Game) != None )
		{
			CoopGameInfo(Level.Game).CoopTakeInventoryFromPlayerFor(self);
			tempPlayerInfoInv = GetCoopTravelPlayerInfo();
			if( tempPlayerInfoInv != None )
				tempPlayerInfoInv.xCoopAddInStartingInv = CoopGameInfo(Level.Game).CoopAddInStartingInventoryFor(self, tempPlayerInfoInv.xCoopAddInStartingInv);
			else CoopGameInfo(Level.Game).CoopAddInStartingInventoryFor(self, -1);
		}

		if( !CoopPlayerController(Controller).bDisableClientCoopMap )
			CreateInventoryByClass(ClientMapInvClass);

		/*if( !bCoopHaveSignaturesErrand )
			xFindAndDeleteInventory(class'CoopInvFix_ClipboardWeapon');
		else CreateInventoryByClass(class'CoopInvFix_ClipboardWeapon');*/

		///steam 18/11/2017 - find and delete clipboard if standard game
		if( CoopGameInfo(Level.Game) != None 
			&& !CoopPlayerController(Controller).IsCoopDedicatedHost() 
			&& Level.Game.class == class'CoopGameInfo' )
		{
			if( !bCoopHaveSignaturesErrand )
				xFindAndDeleteInventory(class'CoopInvFix_ClipboardWeapon');
		}
	}
	///steam 30/10/2017
	if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).CoopBaseMutator != None )
		CoopGameInfo(Level.Game).CoopBaseMutator.AddCustomCoopInvStarting(self);
}

///steam 18/06/2016
function ChangedWeapon()
{
	///steam 02/08/2016 bot pawns uses original one
	if( bCoopPlayer )
	{
		///steam 28/06/2016
		if( Controller != None 
			&& CoopPlayerController(Controller) != None 
			&& Controller.Buoyancy != 75 )
		{
			if( !bSwitchHandsForced )
			{
				if( PendingWeapon != None && PendingWeapon.class == HandsClass )
				{
					bSwitchHandsForced = true;
				}
				else return;
			}
			///steam 18/06/2016
			else if( Weapon != None )
			{
				if( !CoopPlayerController(Controller).bPlayerReadyDetect )
				{
					return;
				}
			}
		}
	}
	Super.ChangedWeapon();
}

///steam 10/01/2016
function xClientCallSwitchHands(P2Weapon myHandsWeapon)
{
	if( myHandsWeapon != None )
	{
		if( myHandsWeapon.AmmoType == None )
			myHandsWeapon.GiveAmmo(self);
		myHandsWeapon.GotoState('Idle');

		///steam 04/04/2016
		PendingWeapon = myHandsWeapon;
		if( PendingWeapon == Weapon )
			PendingWeapon = None;
		if( PendingWeapon != None )
		{
			if( Weapon == None
				|| Weapon.bDeleteMe)
				ChangedWeapon();
			if ( Weapon != PendingWeapon
				&& PendingWeapon != None)
				Weapon.PutDown();
		}
		///steam 04/04/2016
	}
}

///steam 02/08/2016
function CoopForceTossWeapon(vector TossVel)
{
	local vector X,Y,Z;

	if(Weapon == None)
		return;

	// Really make it stop doing it's stuff
	// And don't drop things that can't be dropped
	if(!Weapon.bCanThrow
		|| (!P2Weapon(Weapon).bCanThrowMP
			&& !Level.Game.bIsSinglePlayer))
		return;

	// really make it stop doing it's stuff
	P2Weapon(Weapon).ForceEndFire();

	// make it go up in the air some, and away from him
	if(VSize(TossVel) == 0)
	{
		TossVel = vector(Rotation);
		TossVel = (FRand()*127)*Normal(TossVel);
		TossVel.z+=(FRand()*255);
	}
	Weapon.velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	// And make the weapon align with the direction of the throw
	Weapon.SetRotation(Rotation);
	//Weapon.DropFrom(Location + 0.3 * CollisionRadius * X + CollisionRadius * Z);
	CoopForceDropInvFrom(Weapon, Location + 0.3 * CollisionRadius * X + CollisionRadius * Z, TossVel);
}

///steam 02/08/2016
function CoopForceDropInvFrom(Inventory useInv, vector StartLocation, vector useVelocity)
{
	local Pickup P;

	if( useInv == None )
		return;

	// spawn it earlier, so the instigator isn't cleared yet.
	P = spawn(useInv.PickupClass,self,,StartLocation);

	if(P != None)
	{
		if(P != None)
			P.Instigator = self;

		if( P2Weapon(useInv) != None )
			P2Weapon(useInv).ClientWeaponThrown();

		if(P != None)
		{
			if( Weapon(useInv) != None )
				P2WeaponPickup(P).bTossedOut = true;
			P.InitDroppedPickupFor(useInv);
			if(!P.bDeleteMe)
				P.Velocity = useVelocity;
		}
	}
}

///steam 02/08/2016
function bool CoopForceTossThisInventory(vector TossVel, Inventory ThisInv)
{
	local vector X,Y,Z;
	local Rotator userot;
	local P2Weapon ThisWeap;

	debuglog("toss this inventory"@thisinv);

	if(ThisInv == None)
		return false;

	// Really make it stop doing it's stuff
	// And don't drop things that can't be dropped
	ThisWeap = P2Weapon(ThisInv);
	if(ThisWeap != None)
	{
		if(!ThisWeap.bCanThrow
			|| (!ThisWeap.bCanThrowMP
				&& !Level.Game.bIsSinglePlayer))
			return false;

		ThisWeap.ForceEndFire();
	}

	if(P2PowerupInv(ThisInv) != None)
	{
		debuglog(P2PowerupInv(ThisInv).bCanThrow@P2PowerupInv(ThisInv).Amount);
		if(!P2PowerupInv(ThisInv).bCanThrow
			// 1409 fix, make sure you have stuff to throw!
			// Before this, you could use a crack pipe, then throw it quickly as the
			// smoke was coming out, and you'd still get the health and the crack pipe back--fixed!
			|| P2PowerupInv(ThisInv).Amount <= 0)
			return false;
	}

	ThisInv.velocity = TossVel;
	userot = Rotation;
	userot.Yaw = FRAnd()*65535;
	GetAxes(userot,X,Y,Z);
	// And make the ThisWeap align with the direction of the throw
	ThisInv.SetRotation(userot);
	//ThisInv.DropFrom(Location + 0.3 * CollisionRadius * X + CollisionRadius * Z);
	CoopForceDropInvFrom(ThisInv, Location + 0.3 * CollisionRadius * X + CollisionRadius * Z, TossVel);
	return true;
}

///steam 05/08/2016
simulated function SwapToBurnVictim()
{
	if( bCoopPlayer )
	{
		MyBodyFire = None;
		return;
	}
	Super.SwapToBurnVictim();
}

///steam 05/08/2016
function PopOffHead(vector HitLocation, vector Momentum)
{
	if( bCoopPlayer )
		return;
	Super.PopOffHead(HitLocation, Momentum);
}

///steam 11/10/2016
simulated function SetupHead()
{
	Super.SetupHead();
	///steam 11/10/2016 change skin in ForceAddDefaultInventory
	if( MyHead != None )
		MyHead.Skins[1] = PreInjuryHeadSkin;
}

///steam 04/01/2017
function Inventory FindInventoryType(class DesiredClass)
{
	if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).CoopBaseMutator != None )
		DesiredClass = CoopGameInfo(Level.Game).CoopBaseMutator.GetInventoryObjClass(class<Inventory>(DesiredClass));
	return Super.FindInventoryType(DesiredClass);
}

///steam 07/03/2017
simulated function bool AllowBackpeddle()
{
	return IsHumanControlled();
}

///steam 07/03/2017
simulated function SetAnimRunning()
{
	local EWeaponHoldStyle hold;
	local name useanim1;

	if(mood == MOOD_Combat
		|| mood == MOOD_Scared)
		// Since we've got a weapon out, make sure to rotate faster now
		RotationRate = CombatRotationRate;
	else
		// Since we've *don't* a weapon out, make sure to rotate slower now
		RotationRate = default.RotationRate;

	hold = GetWeaponHoldStyle();
	if( IsHumanControlled() 
		&& MyBodyFire == None 
		&& !Controller.IsInState('RunningBlind') 
		&& hold == WEAPONHOLDSTYLE_Single 
		&& mood == MOOD_Combat )
	{
		useanim1='ss_run3';
		TurnLeftAnim = 'ss_base_singleframe';
		TurnRightAnim = 'ss_base_singleframe';
		MovementAnims[0] = useanim1;
		if(!AllowBackpeddle())
			MovementAnims[1]	= MovementAnims[0];
		else MovementAnims[1]	= 'ss_runback';
		MovementAnims[2]	= 'ss_strafel';
		MovementAnims[3]	= 'ss_strafer';
	}
	else Super.SetAnimRunning();
}

///steam 01/08/2017 - to avoid NPC anger by dedicated host or dead players
function ReportPlayerLooksToOthers(out array<P2Pawn> PawnsAroundMe, bool bRecordPawns, out byte InDoors)
{
	if( Health <= 0 || bCoopDedicatedHost )
		return;
	//log("ReportPlayerLooksToOthers"@self@Controller@Health);
	Super.ReportPlayerLooksToOthers(PawnsAroundMe, bRecordPawns, InDoors);
}

// UPD 20/04/2018 - separate wanted
function CoopWantedTimer_Recover()
{
	if( CoopWantedStatus > 0 )
	{
		if( CoopGameInfo(Level.Game) != None 
			&& CoopGameInfo(Level.Game).TheGameState.CopsWantPlayer() > 0 )
			CoopWantedTimer_Update(true);
		else CoopWantedStatus = 0;
	}
}
function CoopWantedTimer_Update(bool bInit)
{
	if( CoopWantedTimer == None )
		CoopWantedTimer = spawn(class'CoopMiscTimer_WantedStatus', self);
	if( CoopWantedTimer != None )
		CoopWantedTimer.CopRadio_Update(bInit);
}
function bool CoopWantedTimer_GetStatus()
{
	return ( CoopWantedStatus > 0 );
}

defaultproperties
{
	ClientMapInvClass=class'MapInv'
	UrethraClass=None

	 Tag="AWPostalDude"
	 HandsClass=class'CoopInvFix_HandsWeapon'
	 HandsClassEnhanced="NicksCoop.CoopInvFix_HandsWeapon"
	 HandsClassNormal="NicksCoop.CoopInvFix_HandsWeapon"
	 bHeadCanComeOff=false
	 bCoopPlayer=true
	 DanceAnim="s_dance2"
	 BirdAnim="s_midfinger"
	 SpecialAnim="s_shopkeeper"
	 bAllowStasis=false
}
