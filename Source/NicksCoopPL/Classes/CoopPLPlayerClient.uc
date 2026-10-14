//=============================================================================
// CoopPLPlayerClient.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLPlayerClient extends PLDudePlayer;

var int PLNarratedMask;
var int PLBriefingMask;
var int PLBriefingDay;
var bool bPLBriefingPending;
var config bool bPLDiagnostics;
var float NextPLDiagnostic;
// Server-owned; never accept a client-provided role or infer it from its IP.
var bool bPLSessionHost;
var bool bPLIntroLocked;
var bool bPLSkipVoted;
var float PLNextVoteAt;
var string PLSelectedSkin;
var string PLRememberedSkin;
var bool bPLSkinRemembered;
var array<Actor> PLCinematicHiddenActors;
var array<bool> PLCinematicOldHidden;


function DisplayMapErrands(optional string SendToURL, optional bool bWantFancyFadeIn)
{
    local int i,Mask;
    local CoopGameInfo G;
    local CoopPLPlayerClient C;
    G=CoopGameInfo(Level.Game);
    // Nick's Coop pre-marks errands as revealed when creating the server bot.
    // Track this presentation separately from its save/progression bookkeeping.
    if(G!=None && Buoyancy==75 && G.TheGameState!=None)
        for(i=0;i<G.GetCurrentDayBase().NumErrands() && i<31;i++)
            if((PLNarratedMask & (1<<i))==0 && G.GetCurrentDayBase().IsErrandActive(i)
                && !G.GetCurrentDayBase().Errands[i].bCompleted) Mask=Mask | (1<<i);
    PLNarratedMask=PLNarratedMask | Mask;
    Log("PLBRIEF|server-request|mask=" $ Mask);
    Super.DisplayMapErrands(SendToURL,bWantFancyFadeIn);
    if(Mask!=0)
        foreach DynamicActors(class'CoopPLPlayerClient',C)
            if(C.Player!=None && C.Buoyancy!=75) C.ClientPLBriefing(G.GetCurrentDay(),Mask);
}

simulated function ClientPLBriefing(int DayIndex,int Mask)
{
    PLBriefingDay=DayIndex;
    PLBriefingMask=Mask;
    bPLBriefingPending=true;
    Log("PLBRIEF|received|day=" $ DayIndex $ "|mask=" $ Mask);
}

function ServerPLVoteSkip()
{
    if(Level.TimeSeconds<PLNextVoteAt) return;
    PLNextVoteAt=Level.TimeSeconds+0.5;
    if(CoopPLGameInfo(Level.Game)!=None)
        CoopPLGameInfo(Level.Game).VoteToSkipPLIntro(self);
}

function PLHideDuplicateActor(Actor A)
{
    local int i;
    if(A==None) return;
    i=PLCinematicHiddenActors.Length;
    PLCinematicHiddenActors[i]=A;
    PLCinematicOldHidden[i]=A.bHidden;
    A.bHidden=true;
}

simulated function xSceneStarted()
{
    Super.xSceneStarted();
    // The scripted story Dude represents the host during dedicated-server scenes.
    if(Level.NetMode!=NM_DedicatedServer || !bPLSessionHost || Pawn==None
        || PLCinematicHiddenActors.Length>0) return;
    PLHideDuplicateActor(Pawn);
    if(P2MoCapPawn(Pawn)!=None) PLHideDuplicateActor(P2MoCapPawn(Pawn).MyHead);
    if(Pawn.Weapon!=None) PLHideDuplicateActor(Pawn.Weapon.ThirdPersonActor);
    Log("PLCINEMA|host-duplicate-hidden");
}

simulated function xSceneFinished()
{
    local int i;
    Super.xSceneFinished();
    for(i=0;i<PLCinematicHiddenActors.Length;i++)
        if(PLCinematicHiddenActors[i]!=None)
            PLCinematicHiddenActors[i].bHidden=PLCinematicOldHidden[i];
    if(PLCinematicHiddenActors.Length>0) Log("PLCINEMA|host-restored");
    PLCinematicHiddenActors.Length=0;
    PLCinematicOldHidden.Length=0;
}

simulated function ClientPLRememberSkin(string SelectedSkin)
{
    if(Player!=None) UpdateURL("Skin",SelectedSkin,true);
}

simulated function bool PLIntroInputLocked()
{
    return Left(Caps(string(Level)),9)=="PL-INTRO.";
}

function NETCoopWaitContinue()
{
    if (!bPLSessionHost)
    {
        ClientMessage("Waiting for the host to start.");
        Log("PLHOST|start-denied");
        return;
    }
    Log("PLHOST|start-accepted");
    Super.NETCoopWaitContinue();
}


replication
{
    reliable if(Role<ROLE_Authority) ServerPLVoteSkip;
	reliable if( Role == ROLE_Authority )
		xClientHitByFlashBang, bPLIntroLocked, PLSelectedSkin, ClientPLBriefing;
}

///steam 11/01/2018
function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	// If the dude is dumbass enough to walk into their own flashbang (or gets hit by an enemy flashbang)
	if( ClassIsChildOf(DamageType, class'FlashBangDamage') && Buoyancy != 75 )
		xClientHitByFlashBang();
	// PLDudePlayer accesses a local HUD on the server; the RPC above handles this effect.
	Super(PLPlayer).NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

///steam 11/01/2018
simulated function xClientHitByFlashBang()
{
	if(PLHud(MyHud)!=None) PLHud(MyHud).HitByFlashBang();
}

///steam 11/11/2017 - direct access to hands weapon removed
function ServerGetDown()
{
	local FPSPawn CheckP;
	local int peoplecount;
	local byte StateChange;

	if( CoopPostalDude(Pawn) != None 
		&& CoopPostalDude(Pawn).IsGameNowCinematic() )
		return;

	//mypawnfix
	if(P2Pawn(Pawn) == None)
		return;

	// don't allow this to unpause the game
	if ( Level.Pauser == PlayerReplicationInfo )
		return;

	if(!bStillTalking
		&& P2Pawn(Pawn).myDialog != None)
	{
		// If the dude is on the PL Hands Weapon, this behaves differently
		// FIXME also have this work with the photo and other "hands weapon" replacement.
		if (PLHandsWeapon(Pawn.Weapon) != None
			|| (Pawn.Weapon!=None && Pawn.Weapon.InventoryGroup == class'PLHandsWeapon'.Default.InventoryGroup))
		{
			SayTime = P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lDude_FuckYou) + 0.5;
			SetTimer(SayTime, false);
			bStillTalking = true;
			bShoutGetDown = 0;
			/**if (PLHandsWeapon(Pawn.Weapon) != None)
			{
				if (FRand() <= DOUBLE_DEUCE_CHANCE)
					PLHandsWeapon(Pawn.Weapon).PlayAltFiring();
				else
					PLHandsWeapon(Pawn.Weapon).PlayFiring();
				Pawn.Weapon.GotoState('ClientFiring');
			}
			else if (PLPostalDude(Pawn) != None && !P2Weapon(Pawn.Weapon).bHideFoot && PLPostalDude(Pawn).LeftHandBird != None && BucketWeapon(Pawn.Weapon) == None)
				PLPostalDude(Pawn).LeftHandBird.GotoState('NormalFire');**/
			MyPawn.PlayTellOffAnim();

			// FIXME maybe have nearby bystanders react and flip the Dude off, run scared, etc.
			// Now tell the people around you that it happened.

			// First send the message to people to get down. In the process,
			// count how many people heard me.
			peoplecount=0;
			ForEach RadiusActors(class'FPSPawn', CheckP, DUDE_SHOUT_GET_DOWN_RADIUS, Pawn.Location)
			{
				if(CheckP != Pawn
					&& LambController(CheckP.Controller) != None)
				{
					// Tell them who's shouting
					StateChange = 0;
					LambController(CheckP.Controller).RespondToTalker(MyPawn, P2Pawn(Enemy), TALK_fuckyou, StateChange);
					peoplecount++;
				}
			}
			// You could check peoplecount here and then say something
			// funny like "i'm talking to myself" if no one heard you.
		}
		// Otherwise, it behaves normally
		else
		{
			// shout it!
			//log("-----------------------dude dialogue: Get Down!");
			// This is about how long it takes him to shout this. So
			// don't let people shout it while he's already shouting it.
			if(Level.Game != None
				&& Level.Game.bIsSinglePlayer)
				SayTime = P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lGetDown) + 0.5;
			else
				SayTime = P2Pawn(Pawn).Say(P2Pawn(Pawn).myDialog.lGetDownMP) + 0.5;
			SetTimer(SayTime, false);
			bStillTalking=true;
			bShoutGetDown=0;
			// Now tell the people around you that it happened.

			// First send the message to people to get down. In the process,
			// count how many people heard me.
			peoplecount=0;
			ForEach RadiusActors(class'FPSPawn', CheckP, DUDE_SHOUT_GET_DOWN_RADIUS, Pawn.Location)
			{
				if(CheckP != Pawn
					&& LambController(CheckP.Controller) != None)
				{
					// Tell them who's shouting
					StateChange = 0;
					LambController(CheckP.Controller).RespondToTalker(MyPawn, P2Pawn(Enemy), TALK_getdown, StateChange);
					peoplecount++;
				}
			}
			// You could check peoplecount here and then say something
			// funny like "i'm talking to myself" if no one heard you.
		}
	}
}

// Dedicated servers have a story controller without a viewport.
function SetupInteractions()
{
    if (Player != None && Player.InteractionMaster != None)
        Super.SetupInteractions();
}

function SetupScreens()
{
    if (Player != None && Player.InteractionMaster != None)
        Super.SetupScreens();
}

function ForceMapUp()
{
    if (Player != None)
        Super.ForceMapUp();
}

protected function AddWeaponSelector()
{
    if (Player != None && Player.InteractionMaster != None)
        Super.AddWeaponSelector();
}

protected function AddInventorySelector()
{
    if (Player != None && Player.InteractionMaster != None)
        Super.AddInventorySelector();
}

exec function PLCoopStatus()
{
    local int i;
    local P2Screen S;
    Log("PLSTATUS|controller=" $ self $ "|state=" $ GetStateName()
        $ "|screen=" $ CurrentScreen $ "|map=" $ MyMapScreen $ "|stats=" $ MyStatsScreen);
    if (Player == None)
        return;
    for (i=0; i<Player.LocalInteractions.Length; i++)
    {
        S=P2Screen(Player.LocalInteractions[i]);
        if (S != None)
            Log("PLSTATUS|screen=" $ S $ "|state=" $ S.GetStateName()
                $ "|running=" $ S.IsRunning() $ "|render=" $ S.bEnableRender);
    }
}

simulated function PlayerTick(float DeltaTime)
{
    local int PLInteractionIndex;
    local CoopPLConsole PLConsole;
    if(Player!=None && Player.InteractionMaster!=None)
        for(PLInteractionIndex=0;PLInteractionIndex<Player.InteractionMaster.GlobalInteractions.Length;PLInteractionIndex++)
        {
            PLConsole=CoopPLConsole(Player.InteractionMaster.GlobalInteractions[PLInteractionIndex]);
            if(PLConsole!=None) PLConsole.PLInputPlayer=self;
        }
    if (Player!=None && Player.InteractionMaster!=None
        && (!bPLSkinRemembered || PLRememberedSkin!=PLSelectedSkin))
    {
        ClientPLRememberSkin(PLSelectedSkin);
        PLRememberedSkin=PLSelectedSkin;
        bPLSkinRemembered=true;
    }
    if (PLIntroInputLocked())
    {
        if (CoopHUD(MyHUD)!=None)
            CoopHUD(MyHUD).CoopWaitPlayersMessage2="Only the host can press ENTER to start.";
        // Also discard controls held before the lock began.
        aForward=0; aStrafe=0; aUp=0; aTurn=0; aLookUp=0;
        bFire=0; bAltFire=0; bDuck=0; bRun=0; bPressedJump=false;
    }
    Super.PlayerTick(DeltaTime);
    if(bPLBriefingPending && CoopPLMapInteraction(CoopMap)!=None
        && CoopGameReplicationInfo(GameReplicationInfo)!=None
        && CoopGameReplicationInfo(GameReplicationInfo).CurrentDay==PLBriefingDay)
    {
        CoopPLMapInteraction(CoopMap).BeginBriefing(PLBriefingMask);
        bPLBriefingPending=false;
    }
    if (bPLDiagnostics && Role == ROLE_Authority && Player != None
        && Player.InteractionMaster != None && Level.TimeSeconds >= NextPLDiagnostic)
    {
        NextPLDiagnostic = Level.TimeSeconds + 10;
        PLCoopStatus();
    }
}

defaultproperties
{
	///NETStatsInfoClass=class'CoopPLNETStatsInfo'
	NETChameleonModuleClass=class'CoopPLNETChameleonModuleHost'
	CoopMapClass="NicksCoopPL.CoopPLMapInteraction"
}

