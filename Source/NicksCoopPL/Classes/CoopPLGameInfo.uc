//=============================================================================
// CoopPLGameInfo.uc
//
// - PLBaseGameInfo > CoopGameInfo
// - PLHud > CoopHUD
// - PLDude > CoopPostalDude
// - PLPlayer > CoopPlayerController
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLGameInfo extends PLGameInfo;

var CoopPLIntroGate PLIntroGate;
var config string PLSessionHostKey;
var bool bPLIntroLocked;
var bool bPLIntroPlaying;
var bool bPLIntroSkipping;

struct PLPickupClaim
{
    var Pickup Item;
    var Controller PlayerController;
    var string PlayerID;
};
var array<PLPickupClaim> PLPickupClaims;
var Pawn PLPickupReceiver;
var Pickup PLPickupItem;

function LoadCoOpDefaults()
{
    // Honor the host's population setting without the legacy ten-body clamp.
    SliderPawnGoal=Max(0,CoopSliderPawnGoalMax);
}

function SetFluidSurfaceInfoDefaults()
{
    local FluidSurfaceInfo F;
    // These native visual surfaces are map-local. Replicating them after the
    // legacy server-only bNoDelete mutation crashes direct-connected clients.
    foreach AllActors(class'FluidSurfaceInfo',F)
        F.RemoteRole=ROLE_None;
}

function VoteToSkipPLIntro(CoopPLPlayerClient Voter)
{
    local CoopPLPlayerClient P;
    local int Votes, Players;
    local SceneManager SM;
    if(!CoopIsMap("PL-INTRO") || !bPLIntroPlaying || bPLIntroSkipping
        || Voter==None || Voter.Player==None) return;
    Voter.bPLSkipVoted=true;
    foreach DynamicActors(class'CoopPLPlayerClient', P)
        if(P.Player!=None && !P.bDeleteMe
            && !(Level.NetMode==NM_DedicatedServer && P.Buoyancy==75))
        {
            Players++;
            if(P.bPLSkipVoted) Votes++;
        }
    Log("PLSKIP|votes=" $ Votes $ "|players=" $ Players);
    xCoopServerEventMessage("Skip intro: " $ Votes $ "/" $ Players $ " votes. Press ENTER to agree.");
    if(Players==0 || Votes!=Players) return;
    bPLIntroSkipping=true;
    // End interpolation cleanly and use the map's original transition script.
    foreach AllActors(class'SceneManager',SM) SM.NextSceneTag='';
    StopSceneManagers();
    Log("PLSKIP|unanimous");
    TriggerEvent('SendPlayer',self,GetPlayer().Pawn);
}

function LockPLIntro()
{
    local CoopPLPlayerClient P;
    bPLIntroLocked = true;
    foreach DynamicActors(class'CoopPLPlayerClient', P)
        P.bPLIntroLocked = true;
}

// Remote controllers do not run PlayerTick on the dedicated server.
function bool PLSharedPickup(Pickup Item)
{
    if(Item.Tag=='PLVendorPurchase') return false;
    if(P2AmmoPickup(Item)!=None) return true;
    return P2WeaponPickup(Item)!=None && !P2WeaponPickup(Item).bForTransferOnly
        && !P2WeaponPickup(Item).bForRobberyOnly && !Item.IsA('P2WeaponPickupErrand');
}

function bool PLAlreadyClaimed(Pawn P,Pickup Item)
{
    local int i;
    local string ID;
    if(CoopPlayerController(P.Controller)!=None) ID=CoopPlayerController(P.Controller).CoopSavePlayerID;
    for(i=0;i<PLPickupClaims.Length;i++)
        if(PLPickupClaims[i].Item==Item && (PLPickupClaims[i].PlayerController==P.Controller
            || ((PLPickupClaims[i].PlayerController==None || PLPickupClaims[i].PlayerController.bDeleteMe)
                && ID!="" && PLPickupClaims[i].PlayerID==ID))) return true;
    return false;
}

function bool PickupQuery(Pawn Other,Pickup Item)
{
    // Spawn/SetLocation can call Touch before a purchase is configured. Only
    // its buyer may claim it, during the explicit transaction below.
    if(Item.Tag=='PLVendorPurchase' && (Other==None || CoopPLPlayerClient(Other.Controller)==None))return false;
    if(Item.Tag=='PLVendorPurchase' && (Item.Owner!=Other.Controller || CoopPLPlayerClient(Other.Controller).PLActiveVendorPickup!=Item))return false;
    PLPickupItem=None; PLPickupReceiver=None;
    if(PLSharedPickup(Item) && Other!=None && PlayerController(Other.Controller)!=None)
    {
        if(PLAlreadyClaimed(Other,Item)) return false;
        PLPickupItem=Item; PLPickupReceiver=Other;
        Item.RespawnTime=0.01;
    }
    return Super.PickupQuery(Other,Item);
}

function bool ShouldRespawn(Pickup Item)
{
    local int i;
    if(Item==PLPickupItem && PLPickupReceiver!=None && PLSharedPickup(Item))
    {
        // Called by the normal pickup success path, including inventory merges.
        // A failed pickup (for example, full ammo) never consumes the player's claim.
        if(!PLAlreadyClaimed(PLPickupReceiver,Item))
        {
            i=PLPickupClaims.Length;
            PLPickupClaims.Length=i+1;
            PLPickupClaims[i].Item=Item;
            PLPickupClaims[i].PlayerController=PLPickupReceiver.Controller;
            if(CoopPlayerController(PLPickupReceiver.Controller)!=None)
                PLPickupClaims[i].PlayerID=CoopPlayerController(PLPickupReceiver.Controller).CoopSavePlayerID;
            Log("PLPICKUP|claimed|item=" $ Item $ "|player=" $ PLPickupReceiver.Controller.PlayerReplicationInfo.PlayerName);
        }
        Item.RespawnTime=0.01;
        return true;
    }
    if(Item.Tag=='PLVendorPurchase') return false;
    return Super.ShouldRespawn(Item);
}

event Tick(float DeltaTime)
{
    local CoopPLPlayerClient P;
    Super.Tick(DeltaTime);
    if(Level.NetMode!=NM_DedicatedServer) return;
    foreach DynamicActors(class'CoopPLPlayerClient',P)
        if(P.bPLSessionHost && P.NETSceneCamera!=None)
        {
            if(P.NETSceneCamera.bNETUpdateViewport && P.Pawn!=None && P.PLCinematicHiddenActors.Length==0)
                P.xSceneStarted();
            else if(!P.NETSceneCamera.bNETUpdateViewport && P.PLCinematicHiddenActors.Length>0)
                P.xSceneFinished();
        }
}

function xDisableLevelTravelTimer()
{
	local Telepad aTelepad;
	local CoopTelepadBlocker aTelepadBlocker;
	local CoopTelepadBlocker aCoopTelepadBlocker;
	local string GroupString;

	///steam 31/07/2017 - remove all blocks before we will set new ones!
	foreach DynamicActors(class'CoopTelepadBlocker', aTelepadBlocker)
	{
		if( !aTelepadBlocker.bDeleteMe )
			aTelepadBlocker.CallSafeDestroy();
	}

	foreach AllActors(class'Telepad', aTelepad)
	{
		GroupString = Caps(aTelepad.Group);
		if( aTelepad.URL != "" && !(InStr(GroupString, 'DEMO') >= 0) )
		{
			aCoopTelepadBlocker = spawn(class'CoopPLTelepadBlocker', aTelepad,, aTelepad.Location);
			if(aCoopTelepadBlocker==None) continue;
			aCoopTelepadBlocker.ControlTelepadCollision(false);
			aCoopTelepadBlocker.SetCollisionSize(aTelepad.CollisionRadius, aTelepad.CollisionHeight);///*1.1 and *1.8
			//if( bCoopDedicated )
				aCoopTelepadBlocker.bSentinel = true;
			//aCoopTelepadBlocker.SetCollision(true, true, true);
		}
	}
}

event PlayerController Login(string Portal, string Options, out string Error)
{
    local PlayerController P;
    P = Super.Login(Portal, Options, Error);
    if (CoopPLPlayerClient(P) != None)
    {
        CoopPLPlayerClient(P).bPLIntroLocked = bPLIntroLocked;
        CoopPLPlayerClient(P).PLSelectedSkin = CoopPLPlayerClient(P).CoopCustomSkin;
        CoopPLPlayerClient(P).bPLSessionHost = Len(PLSessionHostKey) >= 32
            && ParseOption(Options, "PLHostKey") == PLSessionHostKey;
        Log("PLHOST|authorized=" $ CoopPLPlayerClient(P).bPLSessionHost);
    }
    return P;
}

function bool MapOkForCats(string MapName)
{
    if (MapName ~= "PL-intro" || MapName ~= "PL-intro.fuk") return false;
    return Super.MapOkForCats(MapName);
}


function CoopWaitContinue()
{
    if (PLIntroGate != None)
        PLIntroGate.RequestStart();
    else
        Super.CoopWaitContinue();
}


///steam 21/05/2016
function bool bInsertCoopWaitAction(ScriptedAction sAction)
{
	if( sAction == None )
		return false;
	return Super.bInsertCoopWaitAction(sAction) || (sAction.IsA('ACTION_TriggerEvent') && ACTION_TriggerEvent(sAction).Event == 'SceneManager_Intro' && CoopIsIntroLevel());
}

///steam 11/11/2016
function CoopChangeLevelObjects()
{
	local int nDay;
	local SunCorona scTest;
	local StaticMeshActor smaTest;
	local KActor kaTest;
	local BlockingVolume bvTest;
	local Telepad tpTest;
	local PlayerStart IntroStart;
	local DoorMover dmTest;

	Super.CoopChangeLevelObjects();

    // PL starts its first scene directly from PlayerStart.Event, not a script action.
    // Hold that event until connected players explicitly continue.
    if (CoopIsMap("PL-INTRO"))
    {
        Spawn(class'CoopPLIntroMaterialSync');
        PLIntroGate = Spawn(class'CoopPLIntroGate', self, 'PLCoopIntroGate');
        if (PLIntroGate != None)
            foreach AllActors(class'PlayerStart', IntroStart)
                if (IntroStart.Event == 'Intro1')
                    IntroStart.Event = 'PLCoopIntroGate';
    }


	foreach AllActors(class'SunCorona', scTest)
	{
		if( scTest != None && !scTest.bDeleteMe )
		{
			log("CoopCrap"@Level@scTest);
			scTest.Destroy();
		}
	}
	if( CoopIsMap("PL-HIGHLANDS") )
	{
		foreach AllActors(class'StaticMeshActor', smaTest)
		{
			if( smaTest != None && !smaTest.bDeleteMe && smaTest.Name == 'StaticMeshActor1058' )
			{
				log("CoopCrap"@Level@smaTest);
				smaTest.Destroy();
			}
		}
	}
	else if( CoopIsMap("PL-EASTMALL") )
	{
		foreach AllActors(class'StaticMeshActor', smaTest)
		{
			if( smaTest != None && !smaTest.bDeleteMe && smaTest.Name == 'StaticMeshActor976' )
			{
				log("CoopCrap"@Level@smaTest);
				smaTest.Destroy();
			}
		}
	}
	else if( CoopIsMap("PL-RWSBLOCK") )
	{
		foreach AllActors(class'KActor', kaTest)
		{
			if( kaTest != None && !kaTest.bDeleteMe && kaTest.Name == 'KActor69' )
			{
				log("CoopCrap"@Level@kaTest);
				kaTest.Destroy();
			}
		}
	}
	else if( CoopIsMap("PL-GREENBELT1") )
	{
		foreach AllActors(class'BlockingVolume', bvTest)
		{
			if( bvTest != None && !bvTest.bDeleteMe 
				&& (bvTest.Name == 'BlockingVolume267' || bvTest.Name == 'BlockingVolume328') )
			{
				log("CoopCrap"@Level@bvTest);
				bvTest.KSetBlockKarma(false);
			}
		}
	}
	else if( CoopIsMap("PL-GREENBELT2") )
	{
		nDay = class'CoopSaveSystem'.default.CoopSave_CurrentDay;
		if( nDay != 6 )
		{
			foreach AllActors(class'Telepad', tpTest)
			{
				if( tpTest != None && tpTest.Name == 'Telepad2' )
				{
					log("CoopCrap"@Level@tpTest);
					tpTest.SetLocation(tpTest.Location-vect(0,0,1000));
				}
			}
		}
	}
	else if( CoopIsMap("PL-SUBURBS-2") )
	{
		nDay = class'CoopSaveSystem'.default.CoopSave_CurrentDay;
		if( nDay == 2 || nDay == 3 || nDay == 4 || nDay == 6 )
		{
			foreach AllActors(class'DoorMover', dmTest)
			{
				if( dmTest != None && (dmTest.Name == 'DoorMover35' || dmTest.Name == 'DoorMover40') )
				{
					log("CoopCrap"@Level@dmTest);
					dmTest.LockedFront = false;
					dmTest.LockedBack = false;
					if( dmTest.DoorPathNode != None )
						dmTest.DoorPathNode.bBlocked = false;
					dmTest.Tag = 'coop_pl_hack_unused';
				}
			}
		}
	}
	else if( CoopIsMap("PL-ESTATES") )
	{
		foreach AllActors(class'StaticMeshActor', smaTest)
		{
			if( smaTest != None && !smaTest.bDeleteMe && smaTest.Name == 'StaticMeshActor659' )
			{
				log("CoopCrap"@Level@smaTest);
				smaTest.Destroy();
			}
		}
	}
	else if( CoopIsMap("PL-JUNKYARDARENA") )
	{
		spawn(class'CoopPLMiscTimer_JunkyardArenaTP',self);
	}
}

///steam 07/01/2017
function DetectCoopStoryModeTypeName()
{
	//STUB
}

///steam 30/06/2017
function NotifyClientPawnSignaturesErrand(pawn PlayerPawn)
{
	///STUB
}

/////***********************************
function bool IsWeekend()
{
	return false;
}

function bool WeekendOnlyGame()
{
	return false;
}

function bool WeekendGame()
{
	return false;
}

function CheckDudeHeadskin()
{
	///STUB
}

function bool CheckForErrandCompletion(
	Actor Other,
	Actor Another,
	Pawn ActionPawn,
	P2Player ThisPlayer,
	bool bPremature,
	optional string SendToURL)
{
	local bool bCompleted;
	local int Errand;
	local name CompletionTrigger;
	local name HateClass;
	local name HateDesTex;
	local name HatePicTex;
	local string SendPlayerURL;

	if(TheGameState == None)
		return false;

	// Check if the specified stuff has completed an errand.  Note that
	// this function will actually mark the errand as completed, so it's
	// a one-shot thing (it will return "true" once and then will return
	// "false" if called again with the same parameters).
	bCompleted = Days[TheGameState.CurrentDay].CheckForErrandCompletion(
		Other,
		Another,
		ActionPawn,
		bPremature,
		TheGameState,
		Errand,				// OUT: which errand was completed
		CompletionTrigger,	// OUT: name of trigger that must occur
		SendPlayerURL);		// OUT: URL to send player to
		
	// If the errand specified a send-to URL and we're not overriding it, set it now
	if (SendtoURL == "" && SendPlayerURL != "")
		SendToURL = SendPlayerURL;
		
	// HACK: swap out errand goals based on which errand we completed first.
	// If we completed the Kennel errand, change out the Wise Wang goal so the Dude
	// DOESN'T make a smarmy remark.
	if (bCompleted && TheGameState.CurrentDay == KENNEL_HACK_DAY
		&& Errand == KENNEL_HACK_ERRAND)
	{
		PLGameState(TheGameState).bWiseWangHack = true;	// Mark it in the game state
		Days[WANG_HACK_DAY].Errands[WANG_HACK_ERRAND].Goals[0] = WiseWangGoalAfterKennel;	// Swap out the goal
	}
	// If we completed the Wise Wang errand, change out the Kennel goal so the Dude
	// DOES make a smarmy remark.
	if (bCompleted && TheGameState.CurrentDay == WANG_HACK_DAY
		&& Errand == WANG_HACK_ERRAND)
	{
		PLGameState(TheGameState).bKennelHack = true;	// Mark it in the game state
		Days[KENNEL_HACK_DAY].Errands[KENNEL_HACK_ERRAND].Goals[0] = KennelGoalAfterWiseWang;
	}

	if(bCompleted)
	{
        // Preserve NC's completion location for recovery/teleport handling.
        if (ActionPawn != None)
        {
            xLastErndCompltdLoc = ActionPawn.Location;
            xLastErndCompltdTime = Level.TimeSeconds;
        }
		TheGameState.ErrandsCompletedToday++;
		SaveCompletedErrand(TheGameState.CurrentDay, Errand);

		// Make sure to have a player when bringing up the map.
///		if(ThisPlayer == None)
			ThisPlayer = GetPlayer();
        if (ThisPlayer == None)
            return bCompleted;
			
		// Display the map to cross out the errand
		// Don't allow map display on weekend
		if (!IsWeekend())
		{
			// SendToURL requires some special handling
			if (SendToURL != "")
			{
				bCrossOutErrandDuringLoad = true;
				ErrandCompletedDuringLoad = Errand;
                SendPlayerTo(ThisPlayer, SendToURL);
                // SendPlayerTo detaches TheGameState. Do not recurse into
                // another completion check until travel has finished.
                return true;
			}
			else
				ThisPlayer.DisplayMapCrossOut(Errand, CompletionTrigger);
		}

		// Check to see if this completes any errands
		if (TheGameState != None && ThisPlayer.Pawn != None)
			CheckForErrandCompletion(ThisPlayer, ThisPlayer, ThisPlayer.Pawn, ThisPlayer, False);
	}

	return bCompleted;
}

function EndOfGame(P2Player player)
{
	local P2Player TravelPC;

	if( player == None || (player != None && player.Buoyancy != 75) )
	{
		TravelPC = GetPlayer();
		if( TravelPC != None )
			player = TravelPC;
	}

	///steam 22/11/2016
	CoopCallNETStatsInfo();
	bCoopEndOfGame = true;

	if(player==None || TheGameState==None) return;
	if(player.Player!=None && player.Player.InteractionMaster!=None
        && P2RootWindow(player.Player.InteractionMaster.BaseMenu)!=None)
        P2RootWindow(player.Player.InteractionMaster.BaseMenu).EndingGame();

	// If we haven't called time yet, do so now
	TheGameState.TimeStop = Level.GetMillisecondsNow();

	// Set that you want the stats
	bShowStatsDuringLoad=true;

	// Only save sequence 'time' if beaten at average difficulty or higher
	// (Or if we've already unlocked it, give it to them again)
	if(GetDifficultyOffset() >= 0
		|| TheGameState.bEGameStart)
		InfoSeqTime = GetSeqTime();
	ConsoleCommand("set "@InfoSeqPath@InfoSeqTime);
	RecordEnding();
	log(self$" GameRefVal new InfoSeqTime "$InfoSeqTime$" GameRefVal "$GameRefVal$" fover "$FOver);

	// Grant achievement if we beat both AW and P2
	if (FinallyOver())
	{
		if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLFridayComplete');
	}

	// Grant achievements for beating the game in certain ways

	// Speedrun ending
	if (TheGameState.TimeElapsed <= PLGameState(TheGameState).SPEEDRUN_ACHIEVEMENT
		&& !VerifySeqTime())				// Can't be in Enhanced
		{
		if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLSpeedRun',true);
		}
	// Jesus ending
	if (TheGameState.PeopleKilled + PLGameState(TheGameState).AnimalKills == 0)
	{
		if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLJesusRun',true);
	}
	// Gone Wild ending
	if (InNightmareMode())		// Beat the game in nightmare mode
	{
		if(Level.NetMode != NM_DedicatedServer ) Player.GetEntryLevel().EvaluateAchievement(Player,'PLPOSTALRun',true);
	}
		
	// Shut off the apocalypse
	bQuitting = true;

	// Send player to main menu (set flag to indicate that pawn might be none)
	SendPlayerTo(GetPlayer(), MainMenuURL, true);
}

///steam 11/11/2017 dedicated test
function StoreChams()
{
	if( bCoopDedicated )
		return;
	Super.StoreChams();
}

///steam 13/11/2017
function SendPlayerToNextDay(PlayerController player)
{
	// See if there's any more days
	if (TheGameState.CurrentDay + 1 < Days.length)
	{
		TheGameState.bChangeDayPostTravel = true;
		TheGameState.NextDay = TheGameState.CurrentDay + 1;
//		log(self@"SendPlayerToNextDay: Next day is"@TheGameState.NextDay);
		if (Days[TheGameState.NextDay].StartDayURL != "")
			SendPlayerTo(player, Days[TheGameState.NextDay].StartDayURL);
		// Otherwise, send the player to the "next day" map
		else
			SendPlayerTo(player, StartNextDayURL);
	}
	else
	{
		// This shouldn't happen because the end-of-game movie
		// should end up calling EndOfGame() instead.  If it does
		// happen we'll treat it like a quit.
		QuitGame();
	}
}

function ScoreKill(Controller Killer, Controller Other)
{
    if (Other == None || Other.PlayerReplicationInfo == None)
        return;
    if (Killer != None && Killer.PlayerReplicationInfo == None)
        Killer = None;
    Super.ScoreKill(Killer, Other);
}

defaultproperties
{
    NETChameleonModuleClass=class'CoopPLNETChameleonModuleHost'
    CoopStoryModeType=0
    GameDescription="Paradise Lost co-op development build; campaign verification pending"

	CoopFixMatTrigReplace(0)=(CoopFixMatTrigMap="PL-RWSBLOCK",CoopFixMatTrigClass=class'CoopPLMaterialTrigger_rwsblock',CoopFixMatTrigName="MaterialTrigger1")

	CoopFixFXReplace(0)=(CoopFixFXMap="PL-WESTMALL",CoopFixFXClass=class'CoopPLFixFX_WestMall_NellyShit',CoopFixFXName="P2Emitter0")

	IntroURL			= "PL-intro.fuk"
	StartFirstDayURL	= "PL-highlands.fuk#PlayerStart"
	StartNextDayURL		= "PL-highlands"
	FinishedDayURL		= "PL-StartNextDay"
	JailURL				= "PL-Saloon.fuk#cell"

	CoopSliderPawnGoalMax=30
	GameName="NicksCoop PL"
	GameNameShort="NicksCoop PL"

	CoopMutatorClass="NicksCoopPL.CoopPLGameBaseMod"
	DefaultPlayerClassName="NicksCoopPL.CoopPLPostalDude"
	ChameleonClass=class'CoopChameleonPlus'
	PlayerControllerHostClassName="NicksCoopPL.CoopPLPlayerHost"
	PlayerControllerClassName="NicksCoopPL.CoopPLPlayerClient"
	CoopSaveSystemClass=class'NicksCoopPL.CoopPLSaveSystem'
}


