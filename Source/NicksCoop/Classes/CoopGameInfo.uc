//=============================================================================
// CoopGameInfo.uc
// - 05.04.2015 Changed PlayerTravelPortalURL to incomingName
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2014-2018.
//=============================================================================

class CoopGameInfo extends AWPGameInfo;//GameSinglePlayer;//P2GameInfoSingle;

var PlayerController NETPlayerHost;
var CoopSaveSystem CoopSaveSystem;
//var string NETIncomingName;
var class<CoopSaveSystem> CoopSaveSystemClass;
var string PlayerControllerHostClassName;

///steam 24/08/2017
var globalconfig string CoopTravelPortalName;
var NavigationPoint CoopTravelPortalNode;

///steam 27/02/2016
var StaticMesh SongActorModel;

///steam 05/01/2016
///steam 04/08/2016 moved to local in ReplaceSceneManagers()
//var array<SceneManager> ChameleonSceneManagers;

///steam 22/04/2016
var float xDisableLTT_InitTime;
var float xDisableLTT_WaitTime;
var float LastCoopSaveGameTime;
var float xDisableSave_InitTime;

///steam 09/05/2016 AW story game implementation
var globalconfig int CoopStoryModeType;
//-1 - custom
// 0 - 5 days P2
// 1 - 2 days AW
// 2 - 7 days AWP
var string AWStartFirstDayURL;

///steam 13/05/2016
var vector StartSpotInfo[7];

///steam 29/05/2016
var ScriptedController CoopWaitSC;

///steam 29/07/2016
struct CoopFixFXStruct
{
	var string CoopFixFXMap;
	var Name CoopFixFXName;
	var class<Emitter> CoopFixFXClass;
};
var array<CoopFixFXStruct> CoopFixFXReplace;

///steam 04/08/2016
var int StartSpotCorrectionNum;

///steam 04/08/2016
struct CoopFixMatTrigStruct
{
	var string CoopFixMatTrigMap;
	var Name CoopFixMatTrigName;
	var class<CoopMaterialTrigger> CoopFixMatTrigClass;
};
var array<CoopFixMatTrigStruct> CoopFixMatTrigReplace;

///steam 04/11/2016
var array<string> CoopCustomPlayerSkins;
var Mesh CoopCustomPlayerSkinsM;

///steam 12/11/2016
var globalconfig float CoopFriendlyFireScale;

///steam 22/11/2016
var bool bCoopEndOfGame;

///steam 28/01/2017 moved from CoopSceneManager.uc const HOST_SCENE_END_MAXDIST = 4096
var float CoopSceneTeleportCheckDist;

///steam 10/03/2017
var string CoopMutatorClass;
var CoopGameBaseMod CoopBaseMutator;

var const bool bUseDebugCmd;

///steam 29/06/2017
var string SongNoReplica;

///steam 28/07/2017
var bool bCoopDedicated;
var bool bAutoRestartLevel;

///steam 01/08/2017
var int nCoopTakeInvFromPlayer;
var int nCoopAddInStartingInv;
var string CoopServerNextLevel;
var string CoopServerMapLoader;

///steam 05/08/2017
var localized string CoopPlayerArrestAlertMsg;
var globalconfig string CoopSaveServerID;
var globalconfig float CoopTravelAccessPercent;
var globalconfig bool bCoopRagdollSync;

///steam 07/08/2017
struct CoopManualSaveInfoStruct
{
	var() string PlayerID;
	var() float SaveTime;
};
var array<CoopManualSaveInfoStruct> CoopManualSaveInfo;
var float fCoopManualSavePlayerTime;
var localized string CoopManualSaveMsg1;
var localized string CoopManualSaveMsg2;
var localized string CoopManualSaveMsg3;

var globalconfig string CoopHostNameID;

///steam 17/08/2017
var array<string> ReportLogStack;
var FileLog ReportLogFileInfo;
var globalconfig bool bReportLogEnabled;
var globalconfig string ReportLogFileType;

///steam 21/08/2017
var globalconfig int CoopSliderPawnGoalMax;

///steam 27/10/2017
struct BystandersRefillInfoStruct
{
	var Name SpawnID;
	var vector SpawnPos;
	var class<P2Pawn> SpawnClass;
};
var array<BystandersRefillInfoStruct> BystandersRefillInfo;
var globalconfig bool bUseBystandersRefill;
const SLIDER_PAWN_DIST_REFILL = 600;

///steam 19/11/2017
var float xLastErndCompltdTime;
var vector xLastErndCompltdLoc;

///NonDedicatedAutoSave 22/01/2018
var globalconfig bool bNonDedicatedAutoSave;

///NonDedicatedAutoSave 22/01/2018 - 18/04/2018
var globalconfig bool bAutoSave_FirstRun;

// UPD 18/04/2018 - reset vote menu
const RESET_VOTE_LIMIT = 60;
var float xResetVoteTimeLast;
var array<CoopPlayerController> xResetVoteRequests;
var globalconfig float xResetVoteTimeStamp;

// 13/05/2018
struct TransferBackpackStruct
{
	var string MapName;
	var vector SpawnLoc;
};
var array<TransferBackpackStruct> CoopTransferBackpacks;

var bool bCoopPendingRestart;

var class<CoopNETChameleonModule> NETChameleonModuleClass;

// UPD 18/04/2018 - reset vote menu
function int xResetVoteGetPlayersNum()
{
	local int nPlayersNum;
	local Controller aCon;
	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.nextController )
	{
		if( aCon.Pawn != None 
			&& !aCon.Pawn.bDeleteMe
			&& CoopPlayerController(aCon) != None 
			&& !CoopPlayerController(aCon).IsCoopDedicatedHost() 
			&& aCon.Pawn.Health > 0 )
			nPlayersNum++;
	}
	return nPlayersNum;
}
function xResetGameProgress()
{
	if( CoopSaveSystem != None )
		CoopSaveSystem.xResetGameProgress_RemoveLoot();
	CoopDedicatedEndGame();
	CoopSaveServerGameState();
	SendPlayerTo(GetPlayer(), CoopGetFirstMap());
}
function xRegisterResetVote(CoopPlayerController aPlayer)
{
	local int i, n, k;
	local string sIP;
	local float TimeStampNow;

	if( aPlayer == None 
		|| aPlayer.PlayerReplicationInfo == None 
		|| bAutoRestartLevel 
		|| bCoopEndOfGame )
		return;

	TimeStampNow = Level.GetMillisecondsNow().Y/60;
	if( xResetVoteTimeStamp != 0 )
	{
		k = TimeStampNow-xResetVoteTimeStamp;
		if( k < RESET_VOTE_LIMIT )
		{
			xCoopServerEventMessage("You can vote for game progress reset after:" @ (RESET_VOTE_LIMIT-k) @ "min");
			return;
		}
	}

	sIP = Left(aPlayer.GetPlayerNetworkAddress(), InStr(aPlayer.GetPlayerNetworkAddress(), ":"));
	n = xResetVoteGetPlayersNum();
	if( n <= 1 )
	{
		xCoopServerEventMessage("You need at least 1 more player to activate game progress reset!");
		return;
	}

	if( Level.TimeSeconds > xResetVoteTimeLast )
	{
		xResetVoteRequests.Remove(0,xResetVoteRequests.Length);
		xResetVoteRequests.Length = 0;
	}

	for( i = 0 ; i < xResetVoteRequests.Length ; i++ )
	{
		if( xResetVoteRequests[i] != None 
			&& !xResetVoteRequests[i].bDeleteMe )
		{
			if( xResetVoteRequests[i] == aPlayer 
				|| Left(xResetVoteRequests[i].GetPlayerNetworkAddress(), InStr(xResetVoteRequests[i].GetPlayerNetworkAddress(), ":")) ~= sIP )
				return;
		}
		else
		{
			xResetVoteRequests.Remove(i, 1);
			i--;
		}
	}

	i = xResetVoteRequests.Length;
	xResetVoteRequests.Insert(i, 1);
	xResetVoteRequests[i] = aPlayer;

	if( xResetVoteRequests.Length == n )
	{
		xCoopReportLogF("Game progress reset started...");
		xResetVoteTimeStamp = TimeStampNow;
		SaveConfig();
		xResetGameProgress();
	}
	else
	{
		xCoopReportLogF(aPlayer.PlayerReplicationInfo.PlayerName @ sIP @ "voted for game progress reset.");
		xCoopServerEventMessage(aPlayer.PlayerReplicationInfo.PlayerName @ "voted for game progress reset.");
		xCoopServerEventMessage(string(n-xResetVoteRequests.Length) @ "more players should vote to activate game progress reset!");
	}
	xResetVoteTimeLast = Level.TimeSeconds + 60;
}

function P2Player GetPlayer()
{
	local controller con;

	for(con = Level.ControllerList; con != None; con = con.NextController)
	{
		if(P2Player(con) != None && con.Buoyancy == 75)
		{
			return P2Player(con);
		}
	}
	return None;
}

///steam 02/05/2016
function CoopPlayerController GetCoopPlayerHost()
{
	if( NETPlayerHost != None )
		return CoopPlayerController(NETPlayerHost);
	return None;
}

///steam 18/06/2016 this should be a function
function CoopPlayersLevelPreTravel(string URL)
{
	local controller con;
	local bool bUseRestart;

	bUseRestart = bCoopPendingRestart;//CoopIsMap(Caps(Left(URL, InStr(URL, "#"))));

	for( con = Level.ControllerList ; con != None ; con = con.NextController )
	{
		if( CoopPlayerController(con) != None )
			CoopPlayerController(con).CoopLevelPreTravel(bUseRestart);
	}
}

///steam 10/08/2017
function CoopTravelNameInit(CoopPlayerController aPC)
{
	local string sName;

	if( aPC == None )
	{
		Warn("GENERATE TRAVEL NAME WITHOUT PLAYER CONTROLLER");
		return;
	}

	if( aPC.Buoyancy == 75 )
	{
		sName = LoadDefaultHostPlayerName();
	}
	else
	{
		sName = aPC.PlayerReplicationInfo.PlayerName;

		// 11/10/22 - Make sure the player has no NameID in his name, before adding another one
		if( Len(sName) >= 10 
			&& Mid(sName,Len(sName)-10,1) == "&" 
			&& Mid(sName,Len(sName)-5,1) == "_" )
		{
			sName = Left(sName,Len(sName)-10);
		}

		sName = sName$"&"$InitTravelNameID();
	}

//	log("CoopTravelNameInit()"@sName);

	aPC.xClientUpdateURL("Name", sName, true);
	aPC.PlayerReplicationInfo.PlayerName = sName;
}

///steam 10/08/2017
function string CoopTravelNameRestore(string sName, optional bool bReportStatus)
{
//	log("CoopTravelNameRestore()"@sName@Mid(sName,Len(sName)-10,1)@Mid(sName,Len(sName)-5,1));

	if( Len(sName) >= 10 
		&& Mid(sName,Len(sName)-10,1) == "&" 
		&& Mid(sName,Len(sName)-5,1) == "_" )
	{
		sName = Left(sName,Len(sName)-10);
		if( bReportStatus )
			Log(self @ "CoopTravelNameRestore() TRAVEL NAME RESTORED SUCCESSFULLY" @ sName);
	}
	else if( bReportStatus )
		Log(self @ "CoopTravelNameRestore() FAILED TO RESTORE TRAVEL NAME" @ sName);

//	log("CoopTravelNameRestore()"@sName);

	return sName;
}

///steam 04/08/2016 this make all players/pawns invisible to avoid loading flicker bug
function CoopPlayersLevelPreTravelEx(string URL)
{
	local controller con;
	local bool bUseRestart;

	bUseRestart = bCoopPendingRestart;//CoopIsMap(Caps(Left(URL, InStr(URL, "#"))));

	if( bUseRestart )
		CoopSaveSystem.SaveTransferItemsCache();

	for( con = Level.ControllerList ; con != None ; con = con.NextController )
	{
		///steam 12/10/2016
		if( con.Pawn != None && !con.Pawn.bDeleteMe )
			con.Pawn.bHidden = true;
		if( CoopPlayerController(con) != None )
		{
			CoopTravelNameInit(CoopPlayerController(con));
			CoopPlayerController(con).CoopLevelPreTravelEx(bUseRestart);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Called to send the player to a new level.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerTo(
	PlayerController player,
	String URL,
	optional bool bMaybePawnless)
{
	local PlayerController TravelPC;

	///steam 25/07/2016 ok, if URL is TrainingCamp2#camp, maybe need ?peer (TrainingCamp2#camp?peer)
	/// 02/05/21 - telepad portal name fail-safe
	if( "#" isin URL && !("?peer" isin URL) )
		URL = URL $ "?peer";

	if( CoopGameReplicationInfo(GameReplicationInfo) != None )
		CoopGameReplicationInfo(GameReplicationInfo).bCoopLevelLoading = true;

	if( player == None || (player != None && player.Buoyancy != 75) )
	{
		TravelPC = GetPlayer();
		if( TravelPC != None )
			player = TravelPC;
	}

	if(TheGameState == None)
		Warn("TheGameState=none");
	if (player == None)
		Warn("player=none");
	if (player.pawn == none && !bMaybePawnless)
		Warn("player.pawn=none");

	// Let player prepare to travel
	P2Player(Player).PreTravel();

	// Add GameState (and related items) to player's inventory to travel to next level
	// (unless we're heading to the main menu, in which case the game is over)
	if (!(MainMenuURL ~= URL) && (Player.Pawn != None))
	{
		// Remember the most recent slot
		TheGameState.MostRecentGameSlot = MostRecentGameSlot;

		// Let GameState prepare itself and then add it to the player's inventory
		TheGameState.PreLevelChange(P2Player(Player).MyPawn, ParseLevelName(Level.GetLocalURL()));
		if (player.pawn.AddInventory(TheGameState))
			Log(self @ "SendPlayerTo(): added GameState to player's inventory");
		else
			Warn("failed to add GameState to player inventory");
	}

	player.MyHUD.bHideHud = true;

	// coop freeze players.
	CoopPlayersLevelPreTravel(URL);
	ForceSetPause(true, player);

	// Check if a screen will be displayed during the transition or if it's a seamless
	// transition.  If a screen is used, it will ultimataly call SendPlayerEx(), too.
	if (bShowErrandsDuringLoad)
		P2Player(player).DisplayMapErrands(URL);
	else if(bShowHatersDuringLoad)
		P2Player(player).DisplayMapHaters(URL);
	else if (bShowDayDuringLoad)
		P2Player(player).DisplayLoad(Days[DayToShowDuringLoad], URL);
	else if (TheGameState.bPreGameMode)
		P2Player(player).DisplayLoad(Days[0], URL);
	else if (TheGameState.bChangeDayPostTravel)
		P2Player(player).DisplayLoad(Days[NextDay()], URL);
	else if (bShowStatsDuringLoad)
		P2Player(player).DisplayStats(URL);
	else
		SendPlayerEx(player, URL);

	///steam 01/08/2017
	if( bCoopDedicated || bNonDedicatedAutoSave ) ///NonDedicatedAutoSave 22/01/2018
	{
		if( CoopSaveSystem != None && CoopSaveSystem.TheGameState == None )
			CoopSaveSystem.TheGameState = TheGameState;
		///CoopSaveServerGameState();
	}

	TheGameState = None;
	Log(self @ "SendPlayerTo(): discarded TheGameState");
}

///////////////////////////////////////////////////////////////////////////////
// Send player to the first day
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToFirstDay(PlayerController player, optional bool bDontShowMap)
{
	local PlayerController TravelPC;

	if( player == None || (player != None && player.Buoyancy != 75) )
	{
		TravelPC = GetPlayer();
		if( TravelPC != None )
			player = TravelPC;
	}

	// Only do special movie in full game
	if(!bIsDemo)
	{
		if (!bDontShowMap)
			bShowErrandsDuringLoad = true;

		// If player doesn't have a pawn, it's probably because a scene is running
		if (player.pawn == None)
			StopSceneManagers();
	}

	TheGameState.bChangeDayPostTravel = true;
	TheGameState.NextDay = 0;
	SendPlayerTo(player, StartFirstDayURL);
}

///////////////////////////////////////////////////////////////////////////////
// Send player to jail.  Each time the player goes to jail, he's put in a
// different cell.  The jail map must contain a series of Telepads named
// "cell1" through "celln" where 'n' is LAST_JAIL_CELL_NUMBER.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToJail(PlayerController player)
{
	local P2Pawn ppawn;
	local PlayerController TravelPC;

	if( IsCinematic() )
	{
		return;
	}

	if( player == None || (player != None && player.Buoyancy != 75) )
	{
		TravelPC = GetPlayer();
		if( TravelPC != None )
			player = TravelPC;
	}

	// Keep using a higher jail cell number until we reach the last one
	if (TheGameState.JailCellNumber < TheGameState.LastJailCellNumber)
		TheGameState.JailCellNumber++;

	// This doesn't travel, but just say that the player is going to jail
	// for the SendPlayer function
	TheGameState.bSendingPlayerToJail=true;

	// Record that we were sent to jail
	TheGameState.TimesArrested++;

	// Mark his inventory to be taken on entry to the jail level
	TheGameState.bTakePlayerInventory=true;

	// Give him up to full health (not if he's already over 100%)
	ppawn = P2Pawn(Player.Pawn);
	if(ppawn != None
		&& ppawn.Health < ppawn.HealthMax)
		ppawn.Health = ppawn.HealthMax;

	// Reset the cop radio--you're not wanted anymore
	TheGameState.ResetCopRadioTime();

	//log(self$" cop radio time "$TheGameState.CopRadioTime);
	// Send player to the appropriate jail cell
	SendPlayerTo(player, JailURL $ TheGameState.JailCellNumber $ "?peer");
}

///steam 24/08/2017 - NextLevelName#TelepadInThereTag1?peer
function CoopDetectTravelPortalName(string URL)
{
	local int i, j;
	local string sResult;
	j = InStr(URL, "#");
	if( j != -1 )
	{
		for( i = j+1 ; i < Len(URL) ; i++ )
		{
			if( Mid(URL, i, 1) == "?" )
			{
				sResult = Mid(URL, j+1, i-(j+1));
				break;
			}
		}
	}
	CoopTravelPortalName = sResult;
	SaveConfig();
}

///steam 22/01/2018
static function CoopSetTravelPortalName(string URL)
{
	default.CoopTravelPortalName = URL;
	StaticSaveConfig();
}

///////////////////////////////////////////////////////////////////////////////
// Our lowest-level function for sending a player to a URL.
// You should normally call SendPlayerTo() instead of this.
///////////////////////////////////////////////////////////////////////////////
function SendPlayerEx(
	PlayerController player,
	String URL,
	optional ETravelType TravelType,
	optional ETravelItems TravelItems)
{
	local bool bTravelItems;
	local PlayerController TravelPC;

	///steam 24/08/2017
	CoopDetectTravelPortalName(URL);

	if( bCoopDedicated && bCoopEndOfGame)
	{
		if( URL ~= MainMenuURL )
			URL = CoopGetFirstMap();
		bQuitting = false;
		bGameIsOver = false;
	}

	///steam 01/08/2017
	CoopServerNextLevel = URL;
	if( bCoopDedicated )
	{
		if( bCoopEndOfGame )
			CoopDedicatedEndGame();
		///CoopSaveServerGameState(); ///NonDedicatedAutoSave 22/01/2018
	}
	///NonDedicatedAutoSave 22/01/2018
	if( bCoopDedicated || bNonDedicatedAutoSave )
		CoopSaveServerGameState();

	if( !bCoopEndOfGame )
		PreTravel_RefreshPlayerHoldInfo();

	if( CoopGameReplicationInfo(GameReplicationInfo) != None )
		CoopGameReplicationInfo(GameReplicationInfo).bCoopLevelTraveling = true;

	if( player == None || (player != None && player.Buoyancy != 75) )
	{
		TravelPC = GetPlayer();
		if( TravelPC != None )
			player = TravelPC;
	}

	///steam 22/11/2016
	if( bCoopEndOfGame )
	{
		if( CoopShellRootWindow(player.Player.InteractionMaster.BaseMenu) != None )
		{
			CoopShellRootWindow(player.Player.InteractionMaster.BaseMenu).CoopForceQuitCurrentGame();
			return;
		}
	}

	///steam 04/08/2016
	CoopPlayersLevelPreTravelEx(URL);

	/// 05.04.2015 - now incomingName overrrieds it
	//PlayerTravelPortalURL = URL;
	//SaveConfig();
	/// 05.04.2015 - now incomingName overrrieds it

	///steam 24/05/2016 now travel disables save'n'load
	xDisableLTT_InitTime = Level.TimeSeconds;
	xDisableSave_InitTime = Level.TimeSeconds;

	if (InStr(URL, "#") < 0)
		URL = URL $ "#";

	//if( Level.NetMode != NM_Client && player != None && player != NETPlayerHost )
	//	return;

	// If we're loading a game then it implies certain options
	if (InStr(URL, LOADGAME_URL) >= 0)
	{
		TravelType = TRAVEL_Absolute;
		TravelItems = TRAV_WithoutItems;
	};

	StopAllMusicExt(0.0);
	StopSceneManagers();

	if (TravelItems == TRAV_WithItems)
		bTravelItems = true;
	Level.ServerTravel( URL, bTravelItems );
	//Super.SendPlayerEx(player, URL, TravelType, TravelItems);
}

///steam 29/03/2016 to smoothly replace player start spot
function vector GetStartSpotLocation(NavigationPoint myStartSpot)
{
	local TelePad myTelePad;
	myTelePad = TelePad(myStartSpot);
	if( myTelePad != None && myTelePad.TMarker != None )
		return myTelePad.TMarker.Location;
	return myStartSpot.Location;
}

///steam 13/05/2016
function vector GetStartSpotCorrection(vector StartSpotLoc, Controller ThisPlayer)
{
	local int i;
	local vector TempStartLoc;
	local CoopTestStartSpot TestStartSpot;
	local bool bTested;

	if( ThisPlayer.Buoyancy == 75 )
		return StartSpotLoc;

	GetNextStartSpotCorrectionNum();
	bTested = false;

	while( !bTested && i < ArrayCount(StartSpotInfo) )
	{
		TempStartLoc = StartSpotLoc + StartSpotInfo[StartSpotCorrectionNum];
		TestStartSpot = spawn(class'CoopTestStartSpot',self,,TempStartLoc);
		if( TestStartSpot != None && !TestStartSpot.bDeleteMe )
		{
			bTested = (VSize(TestStartSpot.Location-TempStartLoc) == 0 && !TestStartSpot.bStucked);
			TestStartSpot.Destroy();
		}
		if( bTested )
			return TempStartLoc;
		else GetNextStartSpotCorrectionNum();
		i++;
	}
	return StartSpotLoc;
}

///steam 04/08/2016
function GetNextStartSpotCorrectionNum()
{
	StartSpotCorrectionNum++;
	if( StartSpotCorrectionNum > ArrayCount(StartSpotInfo) )
	{
		if( IsCinematic() )
			StartSpotCorrectionNum = 1;
		else StartSpotCorrectionNum = 0;
	}
}

///steam 01/08/2017
function bool IsDedicatedHostVacancy()
{
	return (bCoopDedicated && NETPlayerHost == None);
}

function string ModifyLoginInName(string sName)
{
	sName = Left(sName, 20);
	if( sName ~= "" )
		sName = DefaultPlayerName;
	return sName;
}

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local NavigationPoint StartSpot;
	local PlayerController NewPlayer;
	local class<Pawn> DesiredPawnClass;
	local Pawn      TestPawn;
	local string          InName, InPassword, InChecksum, InClass;
	local byte            InTeam;
	local bool bSpectator, bAdmin;
	///steam 12/10/2016
	local string InSkin, InFace;
	local bool bIsDedicatedHost;

	bSpectator = ( ParseOption( Options, "SpectatorOnly" ) ~= "true" );
	bAdmin = AccessControl.CheckOptionsAdmin(Options);

    // Make sure there is capacity except for admins. (This might have changed since the PreLogin call).
    if ( !bAdmin && AtCapacity(bSpectator) )
	{
		Error=GameMessageClass.Default.MaxedOutMessage;
		return None;
	}

	// If admin, force spectate mode if the server already full of reg. players
	if ( bAdmin && AtCapacity(false))
		bSpectator = true;

	BaseMutator.ModifyLogin(Portal, Options);

	// Get URL options.
	InName = ModifyLoginInName(CoopTravelNameRestore(ParseOption(Options, "Name"), true));
	InTeam = GetIntOption(Options, "Team", 255 ); // default to "no team"
	InPassword = ParseOption(Options, "Password");

	///steam 12/10/2016
	InSkin = ParseOption(Options, "Skin");
	InFace = ParseOption(Options, "Face");
	///steam 12/10/2016

	InChecksum = ParseOption(Options, "Checksum");

	log("Login:" @ InName);
	
	// Pick a team (if need teams)
	InTeam = PickTeam(InTeam,None);

	// Find a start spot.
	StartSpot = FindPlayerStart( None, InTeam, Portal );

	if( StartSpot == None )
	{
		Error = GameMessageClass.Default.FailedPlaceMessage;
		return None;
	}

	if( NETPlayerHost == None )
	{
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerHostClassName, class'Class'));
	}
	else //if( PlayerControllerClass == None )
	{
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, class'Class'));
	}

	///steam 01/08/2017
	if( IsDedicatedHostVacancy() )
		bIsDedicatedHost = true;

	///NewPlayer = spawn(PlayerControllerClass,,,StartSpot.Location,StartSpot.Rotation);
	///steam 29/03/2016
	NewPlayer = spawn(PlayerControllerClass,,,GetStartSpotLocation(StartSpot),StartSpot.Rotation);

	// Handle spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player controller of class "$PlayerControllerClass);
		Error = GameMessageClass.Default.FailedSpawnMessage;
		return None;
	}
	DudePlayer(NewPlayer).bFullyLoggedIn = true;
	DudePlayer(NewPlayer).bIntroFinished = true;

	if( NETPlayerHost != None )
	{
		//if( CoopPlayerController(NETPlayerHost) != None && CoopPlayerController(NETPlayerHost).NETSceneCamera != None )
			//CoopPlayerController(NewPlayer).InitNETSceneCamera(CoopPlayerController(NETPlayerHost).NETSceneCamera);
		if( CoopGameReplicationInfo(GameReplicationInfo).NETSceneCamera != None )
			CoopPlayerController(NewPlayer).InitNETSceneCamera(CoopGameReplicationInfo(GameReplicationInfo).NETSceneCamera);

		///steam 15/05/2016
		CoopCheckLevelGameOver(true);

		///steam 18/05/2016
		if( !bSpectator )
			CoopUpdateTravelDisableTimer();
	}
	///steam 11/04/2016
	CoopPlayerController(NewPlayer).PostInitNETSceneCamera();

	if( /*Level.NetMode == NM_ListenServer &&*/ NETPlayerHost == None )
	{
		NETPlayerHost = NewPlayer;
		NewPlayer.Buoyancy = 75;
	}

	///steam 12/10/2016
	//CoopPlayerController(NewPlayer).CoopSetCustomSkins(InSkin, InFace);
	CoopLoadCustomSkinFor(CoopPlayerController(NewPlayer), InSkin, InFace);

	NewPlayer.StartSpot = StartSpot;

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	NewPlayer.GotoState('Spectating');

	// Init player's name
	if( NewPlayer.Buoyancy == 75 )
	{
		InName = LoadDefaultHostPlayerName();
		if( !bIsDedicatedHost )
			InName = CoopTravelNameRestore(InName, true);
		ChangeName(NewPlayer, InName, false);
	}
	else ChangeName(NewPlayer, InName, false);

	// RWS CHANGE: Merged bOnlySpectator test from UT2003
	if( bSpectator || NewPlayer.PlayerReplicationInfo.bOnlySpectator )
	{
        NewPlayer.PlayerReplicationInfo.bOnlySpectator = true;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
        // RWS CHANGE: Merged bOutOfLives and PlayerID assignments from UT2003
		NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
	    NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;
		NumSpectators++;
//		xCoopServerEventMessage(NewPlayer.PlayerReplicationInfo.PlayerName$GameMessageClass.default.EnteredMessage @ "(spectator)");
		return NewPlayer;
	}

	// Setup player's pawn class
	InClass = ParseOption( Options, "Class" );
	if ( InClass != "" )
	{
		DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
		if ( DesiredPawnClass != None )
			NewPlayer.PawnClass = DesiredPawnClass;
	}

	// Change player's team.
	if ( !ChangeTeam(newPlayer, InTeam, false) )
	{
		Error = GameMessageClass.Default.FailedTeamMessage;
		return None;
	}

	// RWS CHANGE: Do real admin login in PostLogin
	// Init player's administrative privileges and log it
    //if (AccessControl.AdminLogin(NewPlayer, InPassword))
    //{
	//	AccessControl.AdminEntered(NewPlayer);
    //}

	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Log it.
	NewPlayer.ReceivedSecretChecksum = !(InChecksum ~= "NoChecksum");

	if( !bIsDedicatedHost )
		NumPlayers++;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);

	///steam 28/05/2016
	xCoopServerEventMessage(NewPlayer.PlayerReplicationInfo.PlayerName$GameMessageClass.default.EnteredMessage);

	// if delayed start, don't give a pawn to the player yet
	// Normal for multiplayer games
	if ( bDelayedStart )
	{
		NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;	
	}
	return newPlayer;
}

///steam
function ChangeName(Controller Other, coerce string S, bool bNameChange)
{
	local string InName;
	InName = S;
	if( Other.Buoyancy != 75 )
	{
		if( SearchSameNames(S, Other) )
		{
			InName = S$"_"$Rand(9)$Rand(9)$Rand(9);
			spawn(class'CoopPlayerEventTimer_SameName', Other);
		}
		CoopPlayerController(Other).xClientUpdateURL("Name", InName, true);
	}
	Super.ChangeName(Other, InName, bNameChange);
}

///steam
function bool SearchSameNames(string Name, Controller UseCon)
{
	local Controller con;

	if( Name == "" || UseCon == None )
		return false;

	for( con = Level.ControllerList; con != None; con = con.NextController )
	{
		if( UseCon != con
			&& con.PlayerReplicationInfo != None 
			&& con.PlayerReplicationInfo.PlayerName ~= Name )
			return true;
	}
	return false;
}

///steam invreplace 23/02/2016
function bool PickupQuery(Pawn Other, Pickup Item)
{
	if( CoopBaseMutator != None )
		Item.InventoryType = CoopBaseMutator.GetInventoryObjClass(Item.InventoryType);

	///MpPawn(Other).ClientMessage(Item@Item.InventoryType@"changed");
	return Super.PickupQuery(Other, Item);
}

///steam
function PostBeginPlay()
{
	Super.PostBeginPlay();

	if( CoopSaveSystem == None )
		CoopSaveSystem = spawn(CoopSaveSystemClass,self);

	///steam 05/01/2016
	ReplaceSceneManagers();

	///steam 17/04/2016
	xDisableLTT_InitTime = Level.TimeSeconds;
	xDisableLevelTravelTimer();

	///steam 18/05/2016
	xDisableSave_InitTime = Level.TimeSeconds;

	///steam 01/05/2016
	CoopChangeLevelObjects();

	///steam 29/07/2016
	CoopReplaceEffectsFixFX();

	CoopInitTriggerableEmitters();

	///steam 02/05/2016
	ReplaceMaterialTriggers();

	///steam 10/05/2016
	ReplaceScriptedActions();

	///steam 12/10/2016
	ReplacePawnSpawners();

	///steam 12/10/2016
	ReplaceCoopDefaultVariables();

	SetFluidSurfaceInfoDefaults();

	///steam 22/11/2016
	DetectCoopStoryModeTypeName();

	//if( myChameleon == None )
	//	myChameleon = spawn(ChameleonClass);
	//class'DogPawn'.default.bAllowStasis = false;

	///steam 03/03/2017 dedicated test
	if( bCoopDedicated )
		CoopDedicatedServer_SpawnHostPlayer();

	///steam 21/08/2017
	CheckSaveServerID();

	// Calls CoopDelayedBegin()
	spawn(class'CoopMiscTimer_DelayedBegin',self);
}

///steam 03/03/2017 dedicated test - a fake host player
function CoopDedicatedServer_SpawnHostPlayer()
{
	local string sOptions;
	local CoopPlayerController myHostPlayer;

	if( NETPlayerHost == None )
	{
		myHostPlayer = CoopPlayerController(Login("","?Name=HostAdmin?Team=255", sOptions));
		log("STARTING DEDICATED COOP"@sOptions);
		RestartPlayer(myHostPlayer);
		NETPlayerHost = myHostPlayer;
		CoopDedicatedPostTravel();
		myHostPlayer.CoopDedicatedHostSetup();
	}
}

///steam 03/03/2017 dedicated test
function StoreChams()
{
	if( bCoopDedicated )
		return;
	Super.StoreChams();
}

///steam 22/11/2016
function DetectCoopStoryModeTypeName()
{
	///steam 22/11/2016
	if( CoopStoryModeType == 0 )
		GameName = GameName@"(5 days)";
	else if( CoopStoryModeType == 1 )
		GameName = GameName@"(AW)";
	else if( CoopStoryModeType == 2 )
		GameName = GameName@"(7 days)";
}

///steam 12/10/2016
function ReplacePawnSpawners()
{
	local PawnSpawner aPawnSpawner;

	if( CoopBaseMutator != None 
		&& myChameleon != None 
		&& CoopChameleonPlus(myChameleon) != None )
	{
		foreach AllActors(class'PawnSpawner', aPawnSpawner)
		{
			if( aPawnSpawner.InitControllerClass != None )
				aPawnSpawner.InitControllerClass = CoopChameleonPlus(myChameleon).ReplaceCoopBotController(aPawnSpawner.InitControllerClass);
			if( aPawnSpawner.InitInventoryClass != None )
				aPawnSpawner.InitInventoryClass = CoopBaseMutator.GetInventoryObjClass(aPawnSpawner.InitInventoryClass);
		}
	}
}

///steam 12/10/2016
function ReplaceCoopDefaultVariables()
{
}

function SetFluidSurfaceInfoDefaults()
{
	// 14/10/22 - must be called both server and client game in order to make sure net code won't fail
	// called from CoopGameInfo and CoopGameInfoMenu
	ConsoleCommand("set FluidSurfaceInfo bNoDelete true");
}

///steam 05/01/2016
function ReplaceSceneManagers()
{
	local int i;
	local SceneManager aChameleonSceneManager;
	local CoopSceneManager aChameleonSceneManagerNew;
	local array<SceneManager> ChameleonSceneManagers;

	///ChameleonSceneManagers.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( ChameleonSceneManagers.Length > 0 )
	{
		ChameleonSceneManagers.Remove(0,ChameleonSceneManagers.Length);
		ChameleonSceneManagers.Length = 0;
	}

	foreach AllActors(class'SceneManager', aChameleonSceneManager)
	{
		if( !aChameleonSceneManager.IsA('CoopSceneManager') 
			&& aChameleonSceneManager.Affect != AFFECT_Actor 
			&& aChameleonSceneManager.Tag != 'coophack_unusedscene' )
		{
			ChameleonSceneManagers[i] = aChameleonSceneManager;
			i++;
		}
	}
	for( i = 0 ; i < ChameleonSceneManagers.Length ; i++ )
	{
		aChameleonSceneManager = ChameleonSceneManagers[i];
		if( aChameleonSceneManager != None )
		{
			aChameleonSceneManagerNew = spawn(class'CoopSceneManager',self,,aChameleonSceneManager.Location,aChameleonSceneManager.Rotation);
			aChameleonSceneManagerNew.xMoveSceneProperties(aChameleonSceneManager, aChameleonSceneManagerNew);
		}
	}

	///steam 04/08/2016 remove it after we used it
	///ChameleonSceneManagers.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( ChameleonSceneManagers.Length > 0 )
	{
		ChameleonSceneManagers.Remove(0,ChameleonSceneManagers.Length);
		ChameleonSceneManagers.Length = 0;
	}
}

///steam 30/06/2017
function NotifyClientPawnSignaturesErrand(pawn PlayerPawn)
{
	if( TheGameState != None && TheGameState.CurrentDay == 1 )
		CoopPostalDude(PlayerPawn).bCoopHaveSignaturesErrand = true;
}

function AddDefaultInventory( pawn PlayerPawn )
{
	Super.AddDefaultInventory(PlayerPawn);

	///steam 16/06/2016 AddDefaultInventory call replaced to cooppostaldude.uc's ForceAddDefaultInventory
	/*if( PlayerPawn.Controller != None && PlayerPawn.Controller.Buoyancy != 75 )
	{
		P2Pawn(PlayerPawn).AddDefaultInventory();
		//CoopPostalDude(PlayerPawn).CallForceAddDefaultInventory();//steam UPD
	}*/

	///steam 30/06/2017
	///if( TheGameState != None && TheGameState.CurrentDay == 1 )
	///	CoopPostalDude(PlayerPawn).bCoopHaveSignaturesErrand = true;
	NotifyClientPawnSignaturesErrand(PlayerPawn);

	///steam 07/06/2016 replaced
	CoopPostalDude(PlayerPawn).CallForceAddDefaultInventory();
}

function RestartPlayer(Controller aPlayer)
{
	local class<Pawn> DefaultPlayerClass;
	local CoopMiscTimer_NETCallRestoreMusic CoopMiscTimer_NETCallRestoreMusic;
	local vector StartSpotLoc;

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return;

	if( aPlayer == None )
	{
		log("RestartPlayer: WTF ghost player tried to spawn");
		return;
	}

	///steam 09/08/2017 - test spectator
	if( aPlayer.PlayerReplicationInfo.bOnlySpectator )
		return;

	///steam 24/08/2017 - to prevent spawning new pawn while cut-scenes, usually called from StartMatch()
	if( CoopPlayerController(aPlayer) != None 
		&& aPlayer.bInterpolating 
		&& aPlayer.Buoyancy == 75 
		&& CoopPlayerController(aPlayer).FirstPossessedPawn != None )
		return;

	if( aPlayer.PreviousPawnClass != None && aPlayer.PawnClass != aPlayer.PreviousPawnClass )
		BaseMutator.PlayerChangedClass(aPlayer);			

	/*if( aPlayer.PawnClass != None )
	{
		aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,aPlayer.Location,aPlayer.Rotation);
		//aPlayer.Pawn.SetCollision(aPlayer.Pawn.bCollideActors, aPlayer.Pawn.bBlockActors, false);
	}*/ //steam upd

	if( aPlayer.Pawn == None )
	{
		DefaultPlayerClass = class<Pawn>(DynamicLoadObject(DefaultPlayerClassName, class'Class'));
		///aPlayer.Pawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartSpot.Rotation);
		///steam 29/03/2016 how bout to set location it same as PC
		///aPlayer.Pawn = Spawn(DefaultPlayerClass,,,aPlayer.StartSpot.Location,aPlayer.StartSpot.Rotation);
		StartSpotLoc = GetStartSpotLocation(aPlayer.StartSpot);
		StartSpotLoc = GetStartSpotCorrection(StartSpotLoc, aPlayer); ///steam 13/05/2016
		aPlayer.Pawn = Spawn(DefaultPlayerClass,,,StartSpotLoc,aPlayer.StartSpot.Rotation);
	}
	if( aPlayer.Pawn == None )
	{
		log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$aPlayer.StartSpot);
		aPlayer.GotoState('Dead');
		return;
	}

	// RWS CHANGE: Merged anti-spawn-camping from UT2003
	aPlayer.Pawn.LastStartSpot = PlayerStart(aPlayer.StartSpot);
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
	aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

	aPlayer.Possess(aPlayer.Pawn);
	aPlayer.PawnClass = aPlayer.Pawn.Class;

	// RWS CHANGE: Merged fix from UT2003 to call pawn function instead of controller function
	aPlayer.Pawn.PlayTeleportEffect(true, true);
	aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
	AddDefaultInventory(aPlayer.Pawn);

	///steam 29/03/2016 ok we need triggerevent, but only for host PC
	if( aPlayer.Buoyancy == 75 && aPlayer.StartSpot != None )
	{
		// RWS CHANGE: Added log message to make debugging scripted stuff a little easier
		if (aPlayer.StartSpot.Event != '')
			Log("PlayerStart "$aPlayer.StartSpot$" is triggering event "$aPlayer.StartSpot.Event);
		TriggerEvent( aPlayer.StartSpot.Event, aPlayer.StartSpot, aPlayer.Pawn);
	}

	///steam 19/11/2016
	if( CoopPostalDude(aPlayer.Pawn) != None )
		CoopPostalDude(aPlayer.Pawn).CoopLoadCustomSkins();

	///steam music 22/01/2016
	CoopMiscTimer_NETCallRestoreMusic = spawn(class'CoopMiscTimer_NETCallRestoreMusic',self);
	CoopMiscTimer_NETCallRestoreMusic.myCoopPC = CoopPlayerController(aPlayer);
}

static final operator(24) bool isin(string a, string b)
{
	return (InStr(caps(b), caps(a)) != -1);
}

function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint N, BestStart;
	local Teleporter Tel;
	local float BestRating, NewRating;
	local byte Team;

	if ( GameRulesModifiers != None )
	{
		N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
		if ( N != None )
		    return N;
	}

	///steam 24/08/2017 - portal glitch fix
	if( CoopTravelPortalNode != None )
		return CoopTravelPortalNode;

	incomingName = CoopTravelPortalName;
	// if incoming start is specified, then just use it
	if( incomingName != "" )
	{
		foreach AllActors( class 'Teleporter', Tel )
		{
			if( string(Tel.Tag) ~= incomingName )
			{
				CoopTravelPortalNode = Tel;
				return Tel;
			}
		}
	}

	// use InTeam if player doesn't have a team yet
	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
	{
		if ( Player.PlayerReplicationInfo.Team != None )
			Team = Player.PlayerReplicationInfo.Team.TeamIndex;
		else
			Team = 0;
	}
	else
		Team = InTeam;

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		NewRating = RatePlayerStart(N,InTeam,Player);
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = N;
		}
	}

	if ( BestStart == None )
	{
		log("Warning - PATHS NOT DEFINED or NO PLAYERSTART");			
		foreach AllActors( class 'NavigationPoint', N )
		{
			NewRating = RatePlayerStart(N,0,Player);
			if ( NewRating > BestRating )
			{
				BestRating = NewRating;
				BestStart = N;	
			}
		}
	}

	return BestStart;
}

/*exec function daytst()
{
	GetPlayer().ClientMessage("CoopStoryModeType"@CoopStoryModeType);
	GetPlayer().ClientMessage("TheGameState.NextDay"@TheGameState.NextDay);
}*/

event PostTravel(P2Pawn PlayerPawn)
{
	local Mutator TestMutator;
	local class<HolidaySpawnerBase> HolidaySpawnerClass;
	local bool bIsCoopSavedBefore;

	if( PlayerPawn == None || PlayerPawn.bDeleteMe )
	{
		if( TheGameState == None )
			PlayerPawn = P2Pawn(GetPlayer().Pawn);
		Warn("PostTravel INVALID PlayerPawn"@self);
	}

	///steam 01/08/2017 - to avoid multiple PostTravel calls, green light for Host only
	if( PlayerPawn == None 
		|| PlayerPawn.Controller == None 
		|| PlayerPawn.Controller.Buoyancy != 75 )
		return;

	if (TheGameState != None)
	{
		// We loaded a saved game
		bLoadedSavedGame = true;
		Log(self$" PostTravel(): Loaded a saved game (using the loaded GameState)");
	}
	else
	{
		// Try to get GameState from player's inventory
		TheGameState = GameState(PlayerPawn.FindInventoryType(GameStateClass));///class'GameState'
		if (TheGameState != None)
		{
			PlayerPawn.DeleteInventory(TheGameState);
			Log(self$" PostTravel(): Continuing existing game (got GameState from player inventory)");
		}
		else
		{
			Log(self$" PostTravel(): Starting new game (creating new GameState)");
			TheGameState = spawn(GameStateClass);///class'GameState'

			if( bNonDedicatedAutoSave && !bAutoSave_FirstRun ) ///NonDedicatedAutoSave 22/01/2018
				bIsCoopSavedBefore = CoopLoadServerGameState();

			///NonDedicatedAutoSave 22/01/2018 - 18/04/2018
			if( bAutoSave_FirstRun )
			{
				bAutoSave_FirstRun = false;
				SaveConfig();
			}

			/*// We just created a new GameState, so if we're NOT on one of the
			// "pre game" maps then we must be testing a map by loading it directly.
			if (IsMainMenuMap() || IsIntroMap())
			{
				TheGameState.bPreGameMode = true;
				SetupDifficultyOnce();
			}
			else
			{*/
				// Start new game for testing
				///steam 09/05/2016 this is not actual testing
				///bTesting = true;
				TheGameState.bChangeDayPostTravel = true;

			if( !bNonDedicatedAutoSave || !bIsCoopSavedBefore ) ///NonDedicatedAutoSave 22/01/2018
			{
				/**if( CoopStoryModeType != 0 )
				{
					if( CoopStoryModeType == 1 )
					{
						TheGameState.NextDay = DAY_SATURDAY;
						SetDayAtLaunch();
					}
				}
				else TheGameState.NextDay = 0;**/

				if( CoopStoryModeType == 1 )///steam 21/10/2017 - fix fow AWP mode
				{
					TheGameState.NextDay = DAY_SATURDAY;
					SetDayAtLaunch();
				}
				else
				{
					TheGameState.NextDay = 0;
				}
			}
			else if( bNonDedicatedAutoSave ) ///NonDedicatedAutoSave 22/01/2018
				SetDayAtLaunch();

				P2RootWindow(GetPlayer().Player.InteractionMaster.BaseMenu).StartingGame();
				MostRecentGameSlot = -1; // This is unknown when testing
				SetupDifficultyOnce();
			//}
		}

/// steam 09/05/2016 this added from steam
			///if (bWorkshopGame)
			///	TheGameState.PlayerCheated("Workshop game");

			// Allows for testing enhanced game via command line
			if (bEGameStart)
				TheGameState.bEGameStart = true;
				
			// Turn on night mode if applicable
			if (IsHoliday(NIGHT_MODE_HOLIDAY))
				TheGameState.bNightMode = true;

			// Check the mutator chain. If the player added any Workshop game mods, consider the game cheated and ineligible for speedruns/achievements.
			for (TestMutator = BaseMutator; TestMutator != None; TestMutator = TestMutator.NextMutator)
			{
				if( String(TestMutator.Class) != MutatorClass 
					&& String(TestMutator.Class) != CoopMutatorClass )
				{
					TheGameState.PlayerCheated("Using Workshop game mod");
					break;
				}
			}
/// steam 09/05/2016 this added from steam

		// Check if we need to change the day (includes starting a new game)
		if (TheGameState.bChangeDayPostTravel)
		{
			// Check if starting a new game
			if (NextDay() == 0)
			{
				TheGameState.bFirstLevelOfGame = true;
				TheGameState.bPreGameMode = false;

				// Check for valid errand goals (only done once, reports errors to log)
				CheckForValidErrandGoals();
			}
			else
			{
				TheGameState.bFirstLevelOfGame = false;

				// Remove inventory player can't leave the current day with
				Days[TheGameState.CurrentDay].TakeInventoryFromPlayer(PlayerPawn);
				nCoopTakeInvFromPlayer = TheGameState.CurrentDay;
			}

			// Change the day
			TheGameState.CurrentDay = NextDay();
			TheGameState.bFirstLevelOfDay = true;
			TheGameState.ErrandsCompletedToday = 0;
			TheGameState.bChangeDayPostTravel = false;
			TheGameState.bChangeDayForDebug = false;
		}
		else
		{
			// Same day, so clear flag
			TheGameState.bFirstLevelOfDay = false;
		}

/// steam 09/05/2016 this added from steam
		// Bring in a holiday spawner, if used
		HolidaySpawnerClass = class<HolidaySpawnerBase>(DynamicLoadObject(HolidaySpawnerClassName, class'Class'));
		//log("Spawn"@HolidaySpawnerClass,'HolidaySpawner');
		if (HolidaySpawner == None && HolidaySpawnerClass != None)
			HolidaySpawner = Spawn(HolidaySpawnerClass);
/// steam 09/05/2016 this added from steam

		// GameInfo is now valid
		GameInfoIsNowValid();

		// Tell GameState the level has changed
		TheGameState.PostLevelChange(PlayerPawn, ParseLevelName(Level.GetLocalURL()));

		// Get most recent slot
		MostRecentGameSlot = TheGameState.MostRecentGameSlot;

		// Restore day and its errands
		RestoreDayAndErrands();
		
		// Restore pawns that teleported with the player
		TheGameState.RestoreAllTeleportedPawns(PlayerPawn);

		// Handle changing things because we're going to the first level of a new day
		if (TheGameState.bFirstLevelOfDay)
		{
			// Check if we need to give the player the starting inventory for this day
			Days[TheGameState.CurrentDay].AddInStartingInventory(PlayerPawn);
//			nCoopAddInStartingInv = TheGameState.CurrentDay;
/// steam 09/05/2016 this added from steam
			// Check to delete any dynamic variables expiring at the end of the day
			TheGameState.ClearDailyDynamicVariables();
/// steam 09/05/2016 this added from steam
		}
		nCoopAddInStartingInv = TheGameState.CurrentDay;

/// steam 09/05/2016 this added from steam
		// 30 Lives Cheat
		if (bContraMode)
		{
			P2Player(PlayerPawn.Controller).ContraCode();
			bContraMode = false;
			SaveConfig();
		}

		// See if the game mods want to do anything
		BaseMod.PostTravel(PlayerPawn);

		// See if holidays want to do anything
		PostTravelForHolidays(PlayerPawn);
/// steam 09/05/2016 this added from steam

		// Decide whether auto-save should be done (although it's not actually
		// done here).  We force an autosave at the start of the game's first level
		// even if autosave is disabled because we need something to go back to
		// when the player dies and wants to to restart (we can't assume he'll save
		// on his own).  We also force an autosave at the start of each day because
		// most players won't realize they'd have to go back to a previous day if
		// they don't manually save on a new day.
		bDoAutoSave = false;
		if (!bIsDemo && !IsFinishedDayMap())
			{
			if ((bUseAutoSave && !IsPreGame()) || TheGameState.bFirstLevelOfDay)
				{
				bDoAutoSave = true;
				AutoSaveSlot = AUTOSAVE_SLOT;
				if (TheGameState.bFirstLevelOfDay)
					bForcedAutoSave = true;
				}
			}
	}
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
		CompletionTrigger,SendToURL);	// OUT: name of trigger that must occur
	
	if(bCompleted)
		{
		///steam 19/11/2017
		if( ActionPawn != None && Level.TimeSeconds > xLastErndCompltdTime + 1 )
		{
			xLastErndCompltdLoc = ActionPawn.Location;
			xLastErndCompltdTime = Level.TimeSeconds;
			//xCoopServerEventMessage("xLastErndCompltd registered" @ ActionPawn @ ActionPawn.Controller @ xLastErndCompltdLoc);
		}

		TheGameState.ErrandsCompletedToday++;
		SaveCompletedErrand(TheGameState.CurrentDay, Errand);

		// Make sure to have a player when bringing up the map.
		//if(ThisPlayer == None)
			ThisPlayer = GetPlayer();

		// Display the map to cross out the errand
		ThisPlayer.DisplayMapCrossOut(Errand, CompletionTrigger);
		}
	
	return bCompleted;
}

///////////////////////////////////////////////////////////////////////////////
// The player has watched the last movie in the game and successfully beaten
// the game! Put up the stats screen as we load the main menu.
///////////////////////////////////////////////////////////////////////////////
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

	P2RootWindow(player.Player.InteractionMaster.BaseMenu).EndingGame();

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

	// Send player to main menu
	SendPlayerTo(player, MainMenuURL);
}

///steam 06/01/2017
function bool CoopRespawnThisPickup(Pickup Other)
{
	return ( Other != None && Other.IsA('GimpClothesPickupErrand') );
}

///steam 01/08/2016
function bool ShouldRespawn( Pickup Other )
{
	if( Other != None && CoopRespawnThisPickup(Other) )
		return ( Other.ReSpawnTime != 0.0 );

	return false;
}

/*function LoadGame(int Slot, bool bShowScreen)
{
	Log(self$" Coop LoadGame(): Slot="$Slot);
	SendPlayerTo(GetPlayer(), "Save"$Slot);
}*/

function bool IsSaveAllowed(P2Player player, optional bool bIsCheckpoint)
{
	if (/*bSafeToSave &&*/				// only if it's safe
		!bIsDemo &&					// not in demo
		!IsPreGame() &&				// only during actual game
		!IsFinishedDayMap()	&&		// not on finishedday map
		player != None &&			// only if there's a player
		player.IsSaveAllowed())		// only if player agrees
		return true;
	return false;
}

exec function comSaveGame()
{
	CoopSaveGame(bNonDedicatedAutoSave); ///NonDedicatedAutoSave 22/01/2018
}

exec function comSaveLut()
{
	CoopSaveLut(bNonDedicatedAutoSave); ///NonDedicatedAutoSave 22/01/2018
}

exec function comLoadGame()
{
	CoopLoadGame();
}

exec function comLoadLut()
{
	CoopLoadLut();
}

///steam 04/08/2016
/*exec */function Goto(String LevelName)
{
	Log("CHEAT: Goto() LevelName="$LevelName);

	SendPlayerTo(GetPlayer(), LevelName);
}

///steam 04/08/2016
/*exec */function comSTest()
{
	GetPlayer().ClientTravel(JailURL, TRAVEL_Absolute, false);
	//Level.ServerTravel( JailURL, false );
}

///steam 01/08/2016
function bool bCoopLoadAllowed()
{
	local SceneManager SM;

	if( NETPlayerHost != None )
		SM = NETPlayerHost.GetCurrentSceneManager();

	///steam 30/07/2016 to forbid saving while matinee
	if( SM != None 
		|| NETPlayerHost == None 
		|| NETPlayerHost.Pawn == None )
		return false;

	return true;
}

///steam 15/05/2016
function bool bCoopSaveAllowed()
{
	if( CoopGameReplicationInfo(GameReplicationInfo) != None )
		return bCoopLoadAllowed() && !CoopGameReplicationInfo(GameReplicationInfo).bCoopLevelGameOver;
	return bCoopLoadAllowed();
}

function bool SaveGame(int Slot, bool bShowMessage)
{
	if( xDecide_CoopSaveGame() )
	{
		CoopSaveGame(bNonDedicatedAutoSave); ///NonDedicatedAutoSave 22/01/2018
		CoopSaveLut(bNonDedicatedAutoSave);
	}
	return true;
}

function LoadGame(int Slot, bool bShowScreen)
{
	if( bNonDedicatedAutoSave )
	{
		return;
	}
	if( xDecide_CoopLoadGame() )
	{
		CoopLoadLut();
		CoopLoadGame();
	}
}

function CoopRestartLevel()
{
	local string sNextURL;

	if( !xDecide_CoopRestartLevel() )
		return;
	if( !bCoopLoadAllowed() )
	{
		xCoopServerEventMessage("CoopGame: can't restart now, please try later");
		return;
	}

	bCoopPendingRestart = true;

	///steam 01/09/2017 - NextLevelName#TelepadInThereTag1?peer
	sNextURL = GetURLMap();
	if( CoopTravelPortalName != "" )
		sNextURL = sNextURL $ "#" $ CoopTravelPortalName $ "?peer";
	SendPlayerTo(GetPlayer(), sNextURL);
}

///steam 20/05/2016 CoopPostalDude changed to CoopPlayerController
function xCoopServerEventMessage(string sMsg, optional bool bSpecialMsg, optional bool bCriticalMsg)
{
	local Controller P;

	if( Len(sMsg) <= 0 )
		return;

	for( P = Level.ControllerList ; P != None ; P = P.nextController )
	{
		if( P.IsA('CoopPlayerController') )
		{
			if( bSpecialMsg )
				CoopPlayerController(P).xClientSpecialMessage(sMsg, bCriticalMsg);
			else CoopPlayerController(P).ClientMessage(sMsg);
		}
	}
}

function CoopSaveGame(optional bool bServerAutoSave)
{
	if( !bCoopSaveAllowed() )
	{
		xCoopServerEventMessage("CoopGame: can't save now, please try later");
		return;
	}
	//GetPlayer().ClientMessage("CoopGame: saving game...");
	xCoopServerEventMessage("CoopGame: saving game...");

	CoopSaveSystem.CoopSaveGame(bServerAutoSave);
}

function CoopLoadGame()
{
	if( !bCoopLoadAllowed() )
	{
		xCoopServerEventMessage("CoopGame: can't load now, please try later");
		return;
	}
	//GetPlayer().ClientMessage("CoopGame: loading save...");
	xCoopServerEventMessage("CoopGame: loading save...");

	CoopSaveSystem.CoopLoadGame();
}

function CoopSaveLut(optional bool bServerAutoSave)
{
	if( !bCoopSaveAllowed() )
		return;
	//GetPlayer().ClientMessage("CoopGame: saving lut...");
	xCoopServerEventMessage("CoopGame: saving lut...");

	CoopSaveSystem.SaveAllPlayerTravelInfo(bServerAutoSave);
}

function CoopLoadLut()
{
	if( !bCoopLoadAllowed() )
		return;
	//GetPlayer().ClientMessage("CoopGame: loading lut...");
	xCoopServerEventMessage("CoopGame: loading lut...");

	CoopSaveSystem.LoadAllPlayerTravelInfo();
}

function CoopPostLoadGame(int day, optional string CoopLoadURL)
{
	CoopSetDay(day, CoopLoadURL);
}

///steam 04/08/2016
/*exec */function CoopSetDay(int day, optional string CoopLoadURL)
{
	if( CoopLoadURL == "" )
		CoopLoadURL = StartNextDayURL;

	// See if there's any more days
	if( day < Days.length )
	{
		TheGameState.bChangeDayPostTravel = true;
		TheGameState.NextDay = day;
		SendPlayerTo(GetPlayer(), CoopLoadURL);
	}
	else
	{
		// This shouldn't happen because the end-of-game movie
		// should end up calling EndOfGame() instead.  If it does
		// happen we'll treat it like a quit.
		QuitGame();
	}
}

function ForceSetPause(bool bPause, PlayerController P)
{
	if( P == None )
		P = GetPlayer();

	if( bPause )
		Level.Pauser = P.PlayerReplicationInfo;
	else Level.Pauser = None;
}

function LoadCustomMap(string URL)
{
	local P2Player p2p;

	if( IsCinematic() || Level.NextURL != "" )
		return;

	p2p = GetPlayer();

	if( p2p != None )
	{
		if( p2p.Pawn != None )
		{
			TheGameState.PlayerCheated("Using Workshop game mod");
			SendPlayerTo(p2p, URL);
		}
		else p2p.ClientMessage("At first host a game.");
	}
}

///steam 18/05/2016
function CallCoopLoadCustomMod(string ModName, int Idx)
{
	local int i;
	local bool bFound;

	for( i = 0 ; i < class'CoopBrowserModsListCW'.default.CoopMods.Length ; i++ )
	{
		if( i == Idx && class'CoopBrowserModsListCW'.default.CoopMods[i].ModName ~= ModName )
		{
			bFound = true;
			CoopLoadCustomMod(ModName, class'CoopBrowserModsListCW'.default.CoopMods[i].InventoryClasses);
			break;
		}
	}
	if( !bFound )
		xCoopServerEventMessage("CoopGame: server can't find" @ ModName);
}

///steam 18/05/2016
function CoopLoadCustomMod(string ModName, array<string> InventoryClasses)
{
	local Controller con;
	local int i;
	local bool bNoMod;
	local class<Inventory> InvClass;
	local Inventory aInv;

	if( IsCinematic() || Level.NextURL != "" )
		return;

	TheGameState.PlayerCheated("Using Workshop game mod");
	for( con = Level.ControllerList; con != None; con = con.NextController )
	{
		if( CoopPlayerController(con) != None && con.Pawn != None )
		{
			for( i = 0 ; i < InventoryClasses.Length ; i++ )
			{
				InvClass = class<Inventory>(DynamicLoadObject(InventoryClasses[i], class'Class'));
				if( InvClass == None )
				{
					bNoMod = true;
					break;
				}
				else
				{
					aInv = MpPawn(con.Pawn).CreateInventoryByClass(InvClass,,true);
					if( aInv != None )
					{
						if( P2PowerUpInv(aInv) != None )
							P2PowerUpInv(aInv).Amount += 1;
						else if( P2Weapon(aInv) != None && P2Weapon(aInv).AmmoType != None )
							P2Weapon(aInv).AmmoType.AmmoAmount += P2Weapon(aInv).AmmoType.MaxAmmo;
					}
				}
			}
			if( bNoMod )
				CoopPlayerController(con).ClientMessage("Can't load" $ ModName $ ", probably it's missing (subscribe/install it first)");
			else //if( con.Buoyancy != 75 )
				CoopPlayerController(con).ClientMessage(ModName $ "loaded");
		}
	}
}

function PreBeginPlay()
{
	///steam 07/01/2016
	LoadCoOpDefaults();
	Super.PreBeginPlay();
	if( bCoopDedicated && CoopGameReplicationInfo(GameReplicationInfo) != None )
		CoopGameReplicationInfo(GameReplicationInfo).bCoopDedicated = true;
}

/*function PrepSliderPawns()
{
	///steam 07/01/2016
	LoadCoOpDefaults();
	Super.PrepSliderPawns();
}*/

///steam 07/01/2016
function LoadCoOpDefaults()
{
	//if( SliderPawnGoal > CoopSliderPawnGoalMax )
	ConsoleCommand("set CoopGameInfo SliderPawnGoal" @ CoopSliderPawnGoalMax);

	if( BodiesSliderMax > 10 )
		ConsoleCommand("set CoopGameInfo BodiesSliderMax 10");

	/*if( bCoopDedicated )
	{
		ConsoleCommand("set CoopGameInfo bEnableDismemberment false");
		ConsoleCommand("set CoopGameInfo bEnableDismembermentPhysics false");
	}*/
}

///steam 07/01/2016
/*exec function comDefCp()
{
	GetPlayer().ClientMessage("SPG"@SliderPawnGoal@"BSM"@BodiesSliderMax@"bED"@bEnableDismemberment);
}*/

///steam music OGG client fix 22/01/2016
function xNETCallRestoreMusicBase(CoopPlayerController myCoopPC)
{
	local int i;

	if( myCoopPC != None && myCoopPC.Buoyancy != 75 )
	{
		for( i = 0 ; i < ArrayCount(SongInfos) ; i++ )
		{
			if( SongInfos[i].RealHandle != 0 && myCoopPC.SongInfos_ClientSong[i] != SongInfos[i].Song )
			{
				if( SongInfos[i].Actor != None )
				{
					///steam bLegacy added 27/02/2016
					myCoopPC.xClientPlayMusicAttenuateExt(i, SongInfos[i].Actor, SongInfos[i].Song, 0, SongInfos[i].Volume, SongInfos[i].Radius, SongInfos[i].Pitch, SongInfos[i].VolumeOverride, SongInfos[i].bLegacy);
					///oggmusicdebug myCoopPC.ClientMessage("xNETCallRestoreMusic"@i@SongInfos[i].Song@SongInfos[i].Actor);
				}
				else
				{
					///steam map_muzak.ogg 22/02/2016
					if( SongInfos[i].Song != SongNoReplica )
						myCoopPC.xClientPlayMusicExt(i, SongInfos[i].Song, 0, SongInfos[i].VolumeOverride);
					///oggmusicdebug myCoopPC.ClientMessage("xNETCallRestoreMusic"@i@SongInfos[i].Song);
				}
				myCoopPC.SongInfos_ClientSong[i] = SongInfos[i].Song;
			}
		}
	}
}

///steam music OGG client fix 22/01/2016 - calls from CoopMiscTimer_NETCallRestoreMusic.uc
function xNETCallRestoreMusic(CoopPlayerController thisCoopPC)
{
	local CoopPlayerController myCoopPC;

	if( thisCoopPC == None )
	{
		foreach AllActors(class'CoopPlayerController', myCoopPC)
		{
			xNETCallRestoreMusicBase(myCoopPC);
		}
	}
	else xNETCallRestoreMusicBase(thisCoopPC);
}

///steam music OGG client fix 22/01/2016
function xNETCallPlayMusicExt(int SongHandle, string Song, float FadeInTime, optional float VolumeOverride, optional bool bAllowPause)
{
	local CoopPlayerController myCoopPC;

	foreach AllActors(class'CoopPlayerController', myCoopPC)
	{
		if( myCoopPC.Buoyancy != 75 && myCoopPC.SongInfos_ClientSong[SongHandle] != Song )
		{
			///oggmusicdebug myCoopPC.ClientMessage("xNETCallPlayMusicExt"@Song);
			///steam map_muzak.ogg 22/02/2016
			if( Song != SongNoReplica )
				myCoopPC.xClientPlayMusicExt(SongHandle, Song, FadeInTime, VolumeOverride, bAllowPause);
			myCoopPC.SongInfos_ClientSong[SongHandle] = Song;
		}
	}
}
function int PlayMusicExt(string Song, float FadeInTime, optional float VolumeOverride, optional bool bAllowPause)
{
	local int i;
	local int handle;

	// Pass it on to the real function, preserving the info we need to restore song if necessary
	i = GetFreeSongInfo();
	SongInfos[i].RealHandle = PlayMusic(Song, FadeInTime, VolumeOverride, bAllowPause);

	///steam 28/07/2017
	if( bCoopDedicated )
		SongInfos[i].RealHandle = 1;

	if( SongInfos[i].RealHandle > 0 )
	{
		SongInfos[i].Actor = None;
		SongInfos[i].Song = Song;
		handle = i + 1;
		xNETCallPlayMusicExt(i, Song, FadeInTime, VolumeOverride, bAllowPause);
	}
//	Log("FPSGameInfo.PlayMusicExt(): Song="$Song$" FadeInTime="$FadeInTime$" RealHandle="$SongInfos[i].RealHandle$" returning handle="$handle);
	return handle;
}

///steam music OGG client fix 22/01/2016
function xNETCallPlayMusicAttenuateExt(int SongHandle, actor Actor, string Song, float FadeInTime, optional float Volume, optional float Radius, optional float Pitch, optional float VolumeOverride, optional bool bLegacy)
{
	local CoopPlayerController myCoopPC;

	foreach AllActors(class'CoopPlayerController', myCoopPC)
	{
		if( myCoopPC.Buoyancy != 75 && myCoopPC.SongInfos_ClientSong[SongHandle] != Song )
		{
			///oggmusicdebug myCoopPC.ClientMessage("xNETCallPlayMusicAttenuateExt"@Song);
			myCoopPC.xClientPlayMusicAttenuateExt(SongHandle, Actor, Song, FadeInTime, Volume, Radius, Pitch, VolumeOverride, bLegacy);
			myCoopPC.SongInfos_ClientSong[SongHandle] = Song;
		}
	}
}
function int PlayMusicAttenuateExt(actor Actor, string Song, float FadeInTime, optional float Volume, optional float Radius, optional float Pitch, optional float VolumeOverride, optional bool bLegacy)
{
	local int i;
	local int handle;
	local bool bDelayedStart;

	if (Actor != None)
	{
		// Pass it on to the real function, preserving the info we need to restore song if necessary
		i = GetFreeSongInfo();
		SongInfos[i].RealHandle = Actor.PlayMusicAttenuate(Song, FadeInTime, Volume, Radius, Pitch, VolumeOverride,, bLegacy);

		///steam 28/07/2017
		if( bCoopDedicated )
			SongInfos[i].RealHandle = 1;

		if( SongInfos[i].RealHandle > 0 )
		{
			if( Actor.bHidden )
			{
				Actor.bHidden = false;
				///Actor.SetDrawType(DT_Mesh);
				///steam 27/02/2016
				Actor.SetDrawType(DT_StaticMesh);
				Actor.SetStaticMesh(SongActorModel);
			}
			if( Actor.bSkipActorPropertyReplication 
				|| !Actor.bReplicateMovement )
				bDelayedStart = true;
			Actor.bSkipActorPropertyReplication = false;
			Actor.bAlwaysRelevant = true;
			Actor.bReplicateMovement = true;
			///steam 15/06/2016 hope it wont crash game
			Actor.bOnlyDirtyReplication = false;

			SongInfos[i].Actor = Actor;
			SongInfos[i].Song = Song;
			SongInfos[i].Volume = Volume;
			SongInfos[i].Radius = Radius;
			SongInfos[i].Pitch = Pitch;
			SongInfos[i].VolumeOverride = VolumeOverride;
			SongInfos[i].bLegacy = bLegacy;
			handle = i + 1;
			if( !bDelayedStart )
				xNETCallPlayMusicAttenuateExt(i, Actor, Song, FadeInTime, Volume, Radius, Pitch, VolumeOverride, bLegacy);
			else spawn(class'CoopMiscTimer_NETCallRestoreMusic',self);
		}
	}
	else
		Warn("Didn't specify Actor");

//	Log("FPSGameInfo.PlayMusicAttenuateExt(): Actor="$Actor$" Song="$Song$" FadeInTime="$FadeInTime$" Volume="$Volume$" Radius="$Radius$" Pitch="$Pitch$" RealHandle="$SongInfos[i].RealHandle$" returning handle="$handle);
	return handle;
}

///steam music OGG client fix 22/01/2016
function xNETCallStopMusicExt(int SongHandle, float FadeOutTime)
{
	local CoopPlayerController myCoopPC;

	foreach AllActors(class'CoopPlayerController', myCoopPC)
	{
		if( myCoopPC.Buoyancy != 75 )
		{
			///oggmusicdebug myCoopPC.ClientMessage("xNETCallStopMusicExt"@SongHandle);
			myCoopPC.xClientStopMusicExt(SongHandle, FadeOutTime);
			myCoopPC.SongInfos_ClientSong[SongHandle] = "";
		}
	}
}
function StopMusicExt(int SongHandle, float FadeOutTime)
{
	SongHandle--;
	xNETCallStopMusicExt(SongHandle, FadeOutTime);
	Super.StopMusic(SongInfos[SongHandle].RealHandle, FadeOutTime);
	SongInfos[SongHandle].RealHandle = 0;
//	Log("FPSGameInfo.StopAllMusicExt("$SongHandle$")");
}

///steam music OGG client fix 22/01/2016
function xNETCallStopAllMusicExt(float FadeOutTime)
{
	local int i;
	local CoopPlayerController myCoopPC;

	foreach AllActors(class'CoopPlayerController', myCoopPC)
	{
		if( myCoopPC.Buoyancy != 75 )
		{
			///oggmusicdebug myCoopPC.ClientMessage("xNETCallStopAllMusicExt");
			myCoopPC.xClientStopAllMusicExt(FadeOutTime);
			for (i = 0; i < ArrayCount(myCoopPC.SongInfos_ClientHandle); i++)
				myCoopPC.SongInfos_ClientSong[i] = "";
		}
	}
}
function StopAllMusicExt(float FadeOutTime)
{
	local int i;
	StopAllMusic(FadeOutTime);
	xNETCallStopAllMusicExt(FadeOutTime);
	for (i = 0; i < ArrayCount(SongInfos); i++)
		SongInfos[i].RealHandle = 0;
//	Log("FPSGameInfo.StopAllMusicExt()");
}

///steam 24/02/2016
function string LoadDefaultHostPlayerName()
{
	local string sName;
	sName = class'CoopMenu'.default.MultiPlayerHostName;
	if( CoopHostNameID == "" )
	{
		CoopHostNameID = InitTravelNameID();
		SaveConfig();
	}
	return sName$"&"$CoopHostNameID;
}

///////////////////////////////////////////////////////////////////////////////
// This function is called before any other scripts (including PreBeginPlay().
///////////////////////////////////////////////////////////////////////////////
event InitGame(out string Options, out string Error)
{
	///steam 03/03/2017 dedicated test
	if( Level.NetMode == NM_DedicatedServer )
		bCoopDedicated = true;

	///steam namechange 24/02/2016
	Super.InitGame(Options, Error);

	///steam 10/03/2017
	if( CoopMutatorClass != "" )
		AddMutator(CoopMutatorClass);

	Options = SetURLOption(Options, "Name",  LoadDefaultHostPlayerName());

	///steam 01/09/2017
	xCoopReportLogF("New level started:" @ Level.GetLocalURL());
}

///steam 17/04/2016
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
			aCoopTelepadBlocker = spawn(class'CoopTelepadBlocker', aTelepad,, aTelepad.Location);
			aCoopTelepadBlocker.ControlTelepadCollision(false);
			aCoopTelepadBlocker.SetCollisionSize(aTelepad.CollisionRadius, aTelepad.CollisionHeight);///*1.1 and *1.8
			//if( bCoopDedicated )
				aCoopTelepadBlocker.bSentinel = true;
			//aCoopTelepadBlocker.SetCollision(true, true, true);
		}
	}
}

///steam 18/05/2016
function float GetLevelTravelDelay()
{
	return FClamp((xDisableLTT_WaitTime+3)-(Level.TimeSeconds-xDisableLTT_InitTime),0,xDisableLTT_WaitTime);
}

///steam 18/05/2016
function float GetLevelSaveDelay()
{
	return FClamp((xDisableLTT_WaitTime+3)-(Level.TimeSeconds-xDisableSave_InitTime),0,xDisableLTT_WaitTime);
}

function bool xDecide_CoopSaveGame()
{
	local int fLifeTime;
	fLifeTime = GetLevelSaveDelay();
	if( fLifeTime > 0 )
	{
		xCoopServerEventMessage("Can't save game now, try after"@fLifeTime$"s");
		return false;
	}
	if( Level.TimeSeconds < LastCoopSaveGameTime + 1.0 )
		return false;
	LastCoopSaveGameTime = Level.TimeSeconds;
	return true;
}

function bool xDecide_CoopLoadGame()
{
	local int fLifeTime;
	fLifeTime = GetLevelTravelDelay();
	if( fLifeTime > 0 )
	{
		xCoopServerEventMessage("Can't load game now, try after"@fLifeTime$"s");
		return false;
	}
	return true;
}

function bool xDecide_CoopRestartLevel()
{
	local int fLifeTime;
	fLifeTime = GetLevelTravelDelay();
	if( fLifeTime > 0 )
	{
		xCoopServerEventMessage("Can't restart level now, try after"@fLifeTime$"s");
		return false;
	}
	return true;
}

///steam 21/05/2016
function bool CoopIsMap(string MapName)
{
	local string tempMapName;
	tempMapName = Caps(Left(""$Level$"", Len(MapName)));
	///Log("CoopIsMap"@MapName@tempMapName@Mid(""$Level$"", Len(MapName),1));
	return (tempMapName == Caps(MapName) && Mid(""$Level$"", Len(MapName),1) == ".");
}

///steam 01/05/2016
function CoopChangeLevelObjects()
{
	local Mover aMover;
	local Emitter aEmitter;
	local KActor aKActor;
	local Volume aVolume;
	local BlockingVolume aBlockingVolume;
	local GimpClothesPickupErrand aGimpClothesPickupErrand;
	local UseTrigger aUseTrigger;

	if( CoopIsMap("FOREST") )
	{
		foreach AllActors(class'Mover', aMover)
		{
			if( !aMover.bDeleteMe && !aMover.bNoDelete )
			{
				log("CoopCrap"@Level@aMover);
				aMover.Destroy();
			}
		}
	}
	else if( CoopIsMap("GREENBELT2") )
	{
		foreach AllActors(class'Emitter', aEmitter)
		{
			if( !aEmitter.bDeleteMe && !aEmitter.bNoDelete )
			{
				log("CoopCrap"@Level@aEmitter);
				aEmitter.Destroy();
			}
		}
	}
	else if( CoopIsMap("BREWERY") )
	{
		foreach AllActors(class'Mover', aMover)
		{
			if( aMover.Name == 'Mover5' )
			{
				log("CoopCrap"@Level@aMover);
				aMover.SetCollision(false,false,false);
				aMover.bHidden = true;
			}
		}
		foreach DynamicActors(class'GimpClothesPickupErrand', aGimpClothesPickupErrand)
		{
			if( aGimpClothesPickupErrand.Name == 'GimpClothesPickupErrand0' )
			{
				log("CoopCrap"@Level@aGimpClothesPickupErrand);
				aGimpClothesPickupErrand.ReSpawnTime = 0.1;
				aGimpClothesPickupErrand.SetCollisionSize(220, 220);
			}
		}
	}
	else if( CoopIsMap("DOGPOUND") )
	{
		foreach AllActors(class'Mover', aMover)
		{
			if( aMover.Name == 'Mover0' || aMover.Name == 'Mover1' )
			{
				log("CoopCrap"@Level@aMover);
				aMover.Tag = 'coophack_unusedmtest';
			}
		}
	}
	else if( CoopIsMap("HOSPITAL") )
	{
		if( bCoopDedicated )
			spawn(class'CoopFixSentinel_Hospital_M01',self);
		foreach AllActors(class'Mover', aMover)
		{
			if( aMover.Name == 'Mover0' )
			{
				log("CoopCrap"@Level@aMover);
				aMover.MoverEncroachType = ME_IgnoreWhenEncroach;
				aMover.InitialState = 'TriggerOpenTimed';
				aMover.bTriggerOnceOnly = true;
			}
			else if( aMover.Name == 'Mover20' )
			{
				log("CoopCrap"@Level@aMover);
				aMover.Tag = 'coophack_unusedmtest';
			}
		}
	}
	else if( CoopIsMap("MILITARYBASE3") )///steam 30/10/2017
	{
		if( bCoopDedicated )
			spawn(class'CoopFixSentinel_MilitaryBase3_M01',self);
		foreach AllActors(class'Mover', aMover)
		{
			if( aMover.Name == 'Mover8' )
			{
				log("CoopCrap"@Level@aMover);
				aMover.Tag = 'coophack_unusedmtest';
			}
			else if( aMover.Name == 'Mover9' )
			{
				log("CoopCrap"@Level@aMover);
				aMover.Tag = 'coophack_unusedmtest';
			}
		}
	}
	else if( CoopIsMap("EASTMALL") )
	{
		foreach AllActors(class'KActor', aKActor)
		{
			if( !aKActor.bDeleteMe && !aKActor.bNoDelete 
				&& (aKActor.Name == 'KActor131' || aKActor.Name == 'KActor226') )
			{
				log("CoopCrap"@Level@aKActor);
				aKActor.Destroy();
			}
		}

		// 02/05/21 - Set the "steme" cut-scene activated once
		foreach AllActors(class'UseTrigger', aUseTrigger)
		{
			if( aUseTrigger.Name == 'UseTrigger1' )
			{
				log("CoopCrap"@Level@aUseTrigger);
				aUseTrigger.bTriggerOnceOnly = true;
			}
		}
	}
	else if( CoopIsMap("SUBURBS-2") )
	{
		foreach AllActors(class'KActor', aKActor)
		{
			if( !aKActor.bDeleteMe && !aKActor.bNoDelete && aKActor.Name == 'KActor78' )
			{
				log("CoopCrap"@Level@aKActor);
				aKActor.Destroy();
			}
		}
	}
	else if( CoopIsMap("GAYFISH") )
	{
		foreach AllActors(class'BlockingVolume', aBlockingVolume)
		{
			if( !aBlockingVolume.bNoDelete 
				&& (aBlockingVolume.Name == 'BlockingVolume491' || aBlockingVolume.Name == 'BlockingVolume54') )
			{
				log("CoopCrap"@Level@aBlockingVolume);
				aBlockingVolume.KSetBlockKarma(false);
			}
		}
		foreach AllActors(class'Mover', aMover)
		{
			if( aMover.Name == 'Mover0' || aMover.Name == 'Mover3' )
			{
				log("CoopCrap"@Level@aMover);
				//aMover.SetLocation(aMover.Location-vect(0,0,100));
				aMover.SetCollision(false,false,false);
				aMover.bHidden = true;
			}
		}
	}
	else if( CoopIsMap("LOWERPARADISE") )
	{
		foreach AllActors(class'BlockingVolume', aBlockingVolume)
		{
			if( !aBlockingVolume.bNoDelete && aBlockingVolume.Name == 'BlockingVolume171' )
			{
				log("CoopCrap"@Level@aBlockingVolume);
				aBlockingVolume.KSetBlockKarma(false);
			}
		}
	}
	else if( CoopIsMap("GAYFISH2") )
	{
		foreach AllActors(class'BlockingVolume', aBlockingVolume)
		{
			if( !aBlockingVolume.bNoDelete && aBlockingVolume.Name == 'BlockingVolume214' )
			{
				log("CoopCrap"@Level@aBlockingVolume);
				aBlockingVolume.KSetBlockKarma(false);
			}
		}
	}
	else if( CoopIsMap("GREENBELT1") )
	{
		foreach AllActors(class'KActor', aKActor)
		{
			if( !aKActor.bDeleteMe && !aKActor.bNoDelete && aKActor.Name == 'KActor26' )
			{
				log("CoopCrap"@Level@aKActor);
				aKActor.Destroy();
			}
		}
	}
	else if( CoopIsMap("SUBURBS-1") )
	{
		foreach AllActors(class'Volume', aVolume)
		{
			if( aVolume.Tag == 'LeaveLEvel' )
			{
				log("CoopCrap"@Level@aVolume);
				aVolume.SetCollision(false);
			}
		}
	}
}

// Called from CoopMiscTimer_DelayedBegin
function CoopDelayedBegin()
{
	local DayBlocker aDayBlocker;
	local CashRegPoint aCashRegPoint;

	foreach DynamicActors(class'DayBlocker', aDayBlocker)
	{
		aDayBlocker.bAlwaysRelevant = true;
	}

	foreach DynamicActors(class'CashRegPoint', aCashRegPoint)
	{
		aCashRegPoint.bCanUseStasis = false;
	}
}

function CoopInitTriggerableEmitters()
{
	local Emitter aEmitter;

	foreach AllActors(class'Emitter', aEmitter)
	{
		if( aEmitter.Emitters.Length > 0 
			&& aEmitter.Emitters[0].Disabled )
		{
			aEmitter.Texture = NETChameleonModuleClass.default.TexEmitterHackOn;
			aEmitter.bAlwaysRelevant = true;
		}
	}
}

///steam 29/07/2016
function CoopReplaceEffectsFixFX()
{
	local int i;
	local Emitter aEmitter, newEmitter;

	///steam 29/07/2016
	for( i = 0 ; i < CoopFixFXReplace.Length ; i++ )
	{
		if( CoopIsMap(CoopFixFXReplace[i].CoopFixFXMap) )
		{
			foreach AllActors(class'Emitter', aEmitter)
			{
				if( !aEmitter.bDeleteMe 
					&& !aEmitter.bNoDelete )
				{
					if( aEmitter.Name == CoopFixFXReplace[i].CoopFixFXName )
					{
						newEmitter = spawn(CoopFixFXReplace[i].CoopFixFXClass,aEmitter.Owner,,aEmitter.Location,aEmitter.Rotation);
						newEmitter.Tag = aEmitter.Tag;
						newEmitter.Event = aEmitter.Event;
						newEmitter.Group = aEmitter.Group;
						newEmitter.LifeSpan = aEmitter.LifeSpan;
						//log("CoopFixFXReplace"@i@newEmitter@aEmitter);
						aEmitter.Destroy();
					}
				}
			}
		}
	}
}

///steam 02/05/2016
function ReplaceMaterialTriggers()
{
	local int i;
	local MaterialTrigger aMaterialTrigger;
	local CoopMaterialTrigger aNewMaterialTrigger;

	///steam 29/07/2016
	for( i = 0 ; i < CoopFixMatTrigReplace.Length ; i++ )
	{
		if( CoopIsMap(CoopFixMatTrigReplace[i].CoopFixMatTrigMap) )
		{
			foreach AllActors(class'MaterialTrigger', aMaterialTrigger)
			{
				if( aMaterialTrigger.Tag != 'coophack_unusedmattrigg' )
				{
					if( aMaterialTrigger.Name == CoopFixMatTrigReplace[i].CoopFixMatTrigName )
					{
						aNewMaterialTrigger = spawn(CoopFixMatTrigReplace[i].CoopFixMatTrigClass,aMaterialTrigger.Owner,,aMaterialTrigger.Location,aMaterialTrigger.Rotation);
						aNewMaterialTrigger.Tag = aMaterialTrigger.Tag;
						aNewMaterialTrigger.Event = aMaterialTrigger.Event;
						aNewMaterialTrigger.Group = aMaterialTrigger.Group;
						log("CoopFixMatTrigReplace"@i@aNewMaterialTrigger@aMaterialTrigger);
						aMaterialTrigger.Tag = 'coophack_unusedmattrigg';
					}
				}
			}
		}
	}
}

///steam 09/05/2016 AW story game implementation
///////////////////////////////////////////////////////////////////////////////
// Returns true if we're on Saturday or Sunday
///////////////////////////////////////////////////////////////////////////////
function bool IsWeekend()
{
	//log(self@"is weekend? current day is"@TheGameState.CurrentDay,'Debug');
	return (TheGameState.CurrentDay >= DAY_SATURDAY);
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if this game is only Saturday and Sunday
///////////////////////////////////////////////////////////////////////////////
function bool WeekendOnlyGame()
{
	return CoopStoryModeType == 1;
}

///////////////////////////////////////////////////////////////////////////////
// Returns true if this game includes Saturday and Sunday
///////////////////////////////////////////////////////////////////////////////
function bool WeekendGame()
{
	return CoopStoryModeType == 1 || CoopStoryModeType == 2;
}

///////////////////////////////////////////////////////////////////////////////
// Send player to the next day
///////////////////////////////////////////////////////////////////////////////
function SendPlayerToNextDay(PlayerController player)
{
	local int DaysLength;
	// See if there's any more days

	if( CoopStoryModeType == 0 )
		DaysLength = Days.Length-2;
	else DaysLength = Days.Length;

	if (TheGameState.CurrentDay + 1 < DaysLength)
	{
		TheGameState.bChangeDayPostTravel = true;
		TheGameState.NextDay = TheGameState.CurrentDay + 1;
//		log(self@"SendPlayerToNextDay: Next day is"@TheGameState.NextDay);
		if (TheGameState.NextDay == DAY_SATURDAY)
			StartWeekend(Player);
		else if (TheGameState.NextDay == DAY_SUNDAY)
			SendPlayerTo(player, SundayURL);
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
///steam 09/05/2016 AW story game implementation

function bool TryAutoSave(P2Player player, optional bool bIsCheckpoint)
{
	return false;
}
function bool TryCheckpointSave(P2Player player, optional bool bIsCheckpoint)
{
	return false;
}

///steam 10/05/2016
function ScriptedAction xConvertScriptedActions(ScriptedAction oldScriptedAction)
{
	local ACTION_P2Screen old_ACTION_P2Screen;
	local CoopFix_ACTION_P2Screen new_ACTION_P2Screen;
	local ACTION_PlayMovie old_ACTION_PlayMovie;
	local CoopFix_ACTION_PlayMovie new_ACTION_PlayMovie;
	local ACTION_ChangeWeapon new_ACTION_ChangeWeapon;
	local ACTION_ShowSubtitle old_ACTION_ShowSubtitle;
	local CoopFix_ACTION_ShowSubtitle new_ACTION_ShowSubtitle;

	local ACTION_PlayMusic old_ACTION_PlayMusic;
	local CoopFix_ACTION_PlayMusic new_ACTION_PlayMusic;

	if( oldScriptedAction.IsA('ACTION_P2Screen') )
	{
		old_ACTION_P2Screen = ACTION_P2Screen(oldScriptedAction);
		new_ACTION_P2Screen = new(Level) class'CoopFix_ACTION_P2Screen';
		if( new_ACTION_P2Screen == None )
			return oldScriptedAction;
		new_ACTION_P2Screen.Screen = old_ACTION_P2Screen.Screen;
		new_ACTION_P2Screen.bMapRevealErrands = old_ACTION_P2Screen.bMapRevealErrands;
		new_ACTION_P2Screen.bMapRevealHaters = old_ACTION_P2Screen.bMapRevealHaters;
		new_ACTION_P2Screen.ActionString = old_ACTION_P2Screen.ActionString;
		return new_ACTION_P2Screen;
	}
	else if( oldScriptedAction.IsA('ACTION_PlayMovie') )
	{
		old_ACTION_PlayMovie = ACTION_PlayMovie(oldScriptedAction);
		new_ACTION_PlayMovie = new(Level) class'CoopFix_ACTION_PlayMovie';
		if( new_ACTION_PlayMovie == None )
			return oldScriptedAction;
		new_ACTION_PlayMovie.MovieFileName = old_ACTION_PlayMovie.MovieFileName;
		new_ACTION_PlayMovie.Sound = old_ACTION_PlayMovie.Sound;
		new_ACTION_PlayMovie.bWaitUntilFinished = old_ACTION_PlayMovie.bWaitUntilFinished;
		new_ACTION_PlayMovie.ActionString = old_ACTION_PlayMovie.ActionString;
		return new_ACTION_PlayMovie;
	}
	else if( oldScriptedAction.IsA('ACTION_ChangeWeapon') )
	{
		new_ACTION_ChangeWeapon = ACTION_ChangeWeapon(oldScriptedAction);
		if( new_ACTION_ChangeWeapon.NewWeapon != None )
		{
			/*if( new_ACTION_ChangeWeapon.NewWeapon == class'HandsWeapon' )
			{
				new_ACTION_ChangeWeapon.NewWeapon = None;
				new_ACTION_ChangeWeapon.bSwitchToHands = true;
			}*/
			if( CoopBaseMutator != None )
				new_ACTION_ChangeWeapon.NewWeapon = class<Weapon>(CoopBaseMutator.GetInventoryObjClass(new_ACTION_ChangeWeapon.NewWeapon));
			return new_ACTION_ChangeWeapon;
		}
	}
	else if( oldScriptedAction.IsA('ACTION_ShowSubtitle') )
	{
		old_ACTION_ShowSubtitle = ACTION_ShowSubtitle(oldScriptedAction);
		new_ACTION_ShowSubtitle = new(Level) class'CoopFix_ACTION_ShowSubtitle';
		if( new_ACTION_ShowSubtitle == None )
			return oldScriptedAction;
		new_ACTION_ShowSubtitle.SubtitleTag = old_ACTION_ShowSubtitle.SubtitleTag;
		return new_ACTION_ShowSubtitle;
	}
	else if( oldScriptedAction.IsA('ACTION_PlayMusic') )
	{
		old_ACTION_PlayMusic = ACTION_PlayMusic(oldScriptedAction);
		new_ACTION_PlayMusic = new(Level) class'CoopFix_ACTION_PlayMusic';
		if( new_ACTION_PlayMusic == None )
			return oldScriptedAction;
		new_ACTION_PlayMusic.Song = old_ACTION_PlayMusic.Song;
		new_ACTION_PlayMusic.bAffectAllPlayers = old_ACTION_PlayMusic.bAffectAllPlayers;
		new_ACTION_PlayMusic.FadeInSongTime = old_ACTION_PlayMusic.FadeInSongTime;
		return new_ACTION_PlayMusic;
	}

	/*local ACTION_PlaySound old_ACTION_PlaySound;
	local CoopFix_ACTION_PlaySound new_ACTION_PlaySound;

	if( oldScriptedAction.IsA('ACTION_PlaySound') )
	{
		old_ACTION_PlaySound = ACTION_PlaySound(oldScriptedAction);
		new_ACTION_PlaySound = new(Level) class'CoopFix_ACTION_PlaySound';
		if( new_ACTION_PlaySound == None )
			return oldScriptedAction;
		new_ACTION_PlaySound.Sound = old_ACTION_PlaySound.Sound;
		new_ACTION_PlaySound.SoundList = old_ACTION_PlaySound.SoundList;
		new_ACTION_PlaySound.Volume = old_ACTION_PlaySound.Volume;
		new_ACTION_PlaySound.Pitch = old_ACTION_PlaySound.Pitch;
		new_ACTION_PlaySound.Radius = old_ACTION_PlaySound.Radius;
		new_ACTION_PlaySound.bAttenuate = old_ACTION_PlaySound.bAttenuate;
		new_ACTION_PlaySound.bNoOverride = old_ACTION_PlaySound.bNoOverride;
		new_ACTION_PlaySound.bRandomizeSounds = old_ACTION_PlaySound.bRandomizeSounds;
		new_ACTION_PlaySound.ActionString = old_ACTION_PlaySound.ActionString;
		return new_ACTION_PlaySound;
	}*/
	return None;
}

///steam 10/05/2016
function ReplaceScriptedActions()
{
	local int i;
	local ScriptedSequence aScriptedSequence;
	local ScriptedAction newScriptedAction;
	local CoopFix_ACTION_CoopWait CoopWaitAction;
	local CoopFix_ACTION_CoopWaitEnd CoopWaitActionEnd;

	foreach AllActors(class'ScriptedSequence', aScriptedSequence)
	{
		CoopWaitAction = None;
		CoopWaitActionEnd = None;
		for( i = 0 ; i < aScriptedSequence.Actions.Length ; i++ )
		{
			if( aScriptedSequence.Actions[i] != None  )
			{
				if( bInsertCoopWaitAction(aScriptedSequence.Actions[i]) && CoopWaitAction == None )
				{
					CoopWaitAction = new(Level) class'CoopFix_ACTION_CoopWait';
					CoopWaitActionEnd = new(Level) class'CoopFix_ACTION_CoopWaitEnd';
					if( CoopWaitAction != None && CoopWaitActionEnd != None )
					{
						aScriptedSequence.Actions.Insert(i, 1.0);
						aScriptedSequence.Actions[i] = CoopWaitActionEnd;
						aScriptedSequence.Actions.Insert(i, 1.0);
						aScriptedSequence.Actions[i] = CoopWaitAction;
						continue;
					}
				}
				newScriptedAction = xConvertScriptedActions(aScriptedSequence.Actions[i]);
				if( newScriptedAction != None )
					aScriptedSequence.Actions[i] = newScriptedAction;
			}
		}
	}
}

///steam 21/05/2016
function bool bInsertCoopWaitAction(ScriptedAction sAction)
{
	if( sAction == None )
		return false;
	return sAction.IsA('ACTION_PlayMovie') || (sAction.IsA('ACTION_TriggerEvent') && ACTION_TriggerEvent(sAction).Event == 'IntroScene' && CoopIsIntroLevel());
}

///steam 28/07/2017
function CallRestartLevelTimer()
{
	local CoopMiscTimer_AutoRestartLevel aAutoRestartLevel;
	if( !bAutoRestartLevel )
	{
		aAutoRestartLevel = spawn(class'CoopMiscTimer_AutoRestartLevel',self);
		bAutoRestartLevel = (aAutoRestartLevel != None);
	}
}

///steam 20/11/2017
function DecideAutoRestartLevel()
{
	if( !xDecide_CoopRestartLevel() || !bCoopLoadAllowed() )//this decides to start countdown over again
	{
		bAutoRestartLevel = false;
		CallRestartLevelTimer();
		return;
	}
	CoopRestartLevel();
}

///steam 15/05/2016
function CoopCheckLevelGameOver(optional bool bTurnOff)
{
	local controller con;
	local int PlayersNum;
	local int DeadPlayers;
	local CoopGameReplicationInfo CoopGameReplica;

	CoopGameReplica = CoopGameReplicationInfo(GameReplicationInfo);

	if( CoopGameReplica == None )
		return;

	if( bTurnOff )
	{
		CoopGameReplica.bCoopLevelGameOver = false;
		return;
	}

	for(con = Level.ControllerList; con != None; con = con.NextController)
	{
		if( CoopPlayerController(con) != None 
			&& !CoopPlayerController(con).IsCoopDedicatedHost() 
			&& con.Pawn != None 
			&& !con.Pawn.bDeleteMe )
		{
			if( con.Pawn.Health <= 0 )
				DeadPlayers++;
			PlayersNum++;
		}
	}
	if( PlayersNum != 0 )
		CoopGameReplica.bCoopLevelGameOver = (DeadPlayers >= PlayersNum);

	///NonDedicatedAutoSave 22/01/2018
	if( (bCoopDedicated || bNonDedicatedAutoSave) && CoopGameReplica.bCoopLevelGameOver )
		CallRestartLevelTimer();
}

///steam 18/05/2016
function CoopUpdateTravelDisableTimer()
{
	if( GetLevelTravelDelay() <= 0 )
	{
		xDisableLTT_InitTime = Level.TimeSeconds;
		xDisableLevelTravelTimer();
	}
}

///steam 21/05/2016
function bool CoopIsIntroLevel()
{
	return ( CoopIsMap(Left(IntroURL, abs(Len(IntroURL)-4))) || CoopIsMap(Left(WeekendStartURL, abs(Len(WeekendStartURL)-4))) );
}

///steam 28/05/2016
function Logout(Controller Exiting)
{
	local bool bMessage;
	local string sPlayerName;

	Super.Logout(Exiting);

	if( PlayerController(Exiting) != None )
	{
		bMessage = true;
		if( Exiting.PlayerReplicationInfo.bOnlySpectator )
			bMessage = false;

		sPlayerName = CoopTravelNameRestore(Exiting.PlayerReplicationInfo.PlayerName);
		if( bMessage && Exiting.Buoyancy != 75 )
			xCoopServerEventMessage(sPlayerName $ GameMessageClass.default.LeftMessage);

		xCoopReportLogF(sPlayerName @ "disconnected");
	}
}

///steam 29/05/2016
function bool SetCoopWaitSC(ScriptedController newCoopWaitSC)
{
	CoopWaitSC = newCoopWaitSC;
	if( CoopWaitSC != None )
		return true;
	return false;
}

///steam 29/05/2016
function CoopWaitContinue()
{
	if( CoopWaitSC != None )
	{
		if( GameReplicationInfo != None )
			CoopGameReplicationInfo(GameReplicationInfo).bCoopWaitContinue = false;
		xCoopServerEventMessage("CoopGame: please wait 8s");
		CoopWaitSC.SetTimer(8, false);
		CoopWaitSC = None;
	}
}

///steam 04/06/2016 trying out to set speed for all players
/*function SetGameSpeedNoSave( Float T )
{
	local controller con;

	for(con = Level.ControllerList; con != None; con = con.NextController)
	{
		if( CoopPlayerController(con) != None && con.Buoyancy != 75 )
			CoopPlayerController(con).xClientSetGameSpeed(T);
	}
	Super.SetGameSpeedNoSave(T);
}*/

///steam 31/07/2016
function CoopKilled( Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType )
{
	CoopPlayerDiedMessage(KilledPawn);

	///steam 31/07/2016
	NotifyKilled(Killer,Killed,KilledPawn);
}

///steam 04/08/2016 look for another valid target
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn )
{
	local Controller C;
	local PersonController PersonC;

	for ( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		C.NotifyKilled(Killer, Killed, KilledPawn);
		if( Killed != None && Killed.IsA('PlayerController') && PersonController(C) != None )
		{
			PersonC = PersonController(C);
			if( PersonC.MyPawn != None 
				&& !PersonC.MyPawn.bDeleteMe
				&& (PersonC.MyPawn.bPlayerIsEnemy || PersonC.MyPawn.PawnInitialState == PersonC.MyPawn.EPawnInitialState.EP_AttackPlayer) )
				xSetToAttackPlayerFor(PersonC);
		}
	}
}

///steam 04/08/2016 - we need to find nearest player
function P2Player xGetValidPlayerFor(LambController useController)
{
	local Controller aCon;
	local Controller LastCon;
	local float LastDist;
	if( useController != None && useController.Pawn != None && !useController.Pawn.bDeleteMe )
	{
		LastDist = -1;
		for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
		{
			if( CoopPlayerController(aCon) != None 
				&& !CoopPlayerController(aCon).IsCoopDedicatedHost() 
				&& aCon.Pawn != None 
				&& !aCon.Pawn.bDeleteMe 
				&& aCon.Pawn.Health > 0 )
			{
				if( LastDist == -1 || VSize(useController.Pawn.Location-aCon.Pawn.Location) < LastDist )
				{
					LastCon = aCon;
					LastDist = VSize(useController.Pawn.Location-aCon.Pawn.Location);
				}
			}
		}
	}
	if( LastCon != None )
		return P2Player(LastCon);
	return None;
}

///steam 04/08/2016 this hack is to upadte valid target, based on SetToAttackPlayer()
function xSetToAttackPlayerFor(PersonController PersonC)
{
	local P2Player OtherC;
	local FPSPawn keepp;

	if( PersonC == None )
		return;

	OtherC = xGetValidPlayerFor(PersonC);

	if( OtherC != None && OtherC.MyPawn != None && !OtherC.MyPawn.bDeleteMe )
		keepp = OtherC.MyPawn;

	if( keepp != None )
	{
		PersonC.SetAttacker(keepp);
		PersonC.MyPawn.DropBoltons(Velocity);
		PersonC.SetNextState('AssessAttacker');
	}
}

///steam 31/07/2016
simulated function CoopPlayerDiedMessage(Pawn DeadPawn)
{
	local CoopPostalDude OtherCoopPawn;

	foreach DynamicActors(class'CoopPostalDude', OtherCoopPawn)
	{
		if( OtherCoopPawn.bCoopPlayer && OtherCoopPawn != DeadPawn )
		{
			OtherCoopPawn.ClientMessage(DeadPawn.OwnerName$" died!");
		}
	}
}

///steam 04/08/2016
function xForceSetLocationFor(Pawn Other, vector newLocation)
{
	if( Other != None && !Other.bDeleteMe )
	{
		newLocation = GetStartSpotCorrection(newLocation, Other.Controller); ///steam 13/05/2016
		Other.SetLocation(newLocation);
	}
}

///steam 11/10/2016
function CheckDudeHeadskin()
{
	///STUB
}

///steam 12/10/2016 added Skin and Face traveling variables
function ProcessServerTravel( string URL, bool bItems )
{
	local playercontroller P, LocalPlayer;

	EndLogging("mapchange");

	// Notify clients we're switching level and give them time to receive.
	// We call PreClientTravel directly on any local PlayerPawns (ie listen server)
	log("ProcessServerTravel:"@URL);
	foreach DynamicActors( class'PlayerController', P )
		if( NetConnection( P.Player)!=None )
			P.ClientTravel( URL, TRAVEL_Relative, bItems );
		else
		{	
			LocalPlayer = P;
			P.PreClientTravel();
			// RWS CHANGE: Set loading texture for the listen server player
			if(P.Player != None)
				P.Player.InteractionMaster.BaseMenu.SetLoadingTexture(URL);
		}

	if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
		Level.NextURL = Level.NextURL
					 $"?Skin="$LocalPlayer.GetDefaultURL("Skin")	// RWS CHANGE: We don't use this
					 $"?Face="$LocalPlayer.GetDefaultURL("Face")	// RWS CHANGE: We don't use this
					 $"?Team="$LocalPlayer.GetDefaultURL("Team")
					 $"?Name="$LocalPlayer.GetDefaultURL("Name")
					 $"?Class="$LocalPlayer.GetDefaultURL("Class");	// RWS CHANGE: Add class from UT2003

	// Switch immediately if not networking.
	if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		Level.NextSwitchCountdown = 0.0;
}

///steam 12/11/2016
function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
	if( CoopPostalDude(instigatedBy) != None 
		&& CoopPostalDude(instigatedBy).bCoopPlayer 
		&& CoopPostalDude(injured) != None 
		&& CoopPostalDude(injured).bCoopPlayer 
		&& instigatedBy != injured )
	{
		if( CoopFriendlyFireScale == 0 )
			return 0;
		Damage *= CoopFriendlyFireScale;
	}
	return Super.ReduceDamage(Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
}

///steam 15/11/2016
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
	local P2MoCapPawn aPawn;

	aPawn = P2MoCapPawn(KilledPawn);
	if( aPawn != None && !aPawn.bPlayer )
	{
		if( aPawn.PawnInitialState == aPawn.EPawnInitialState.EP_Dead 
			|| (AWZombie(aPawn) != None && AWZombie(aPawn).bMissingBottomHalf) )
		{
			NETChameleonModuleClass.static.PawnDyingNetSync(aPawn, (Level.NetMode != NM_DedicatedServer && bCoopRagdollSync));

			if (aPawn.PawnInitialState == aPawn.EPawnInitialState.EP_Dead)
			{
				if( AWPerson(aPawn) != None )
					AWPerson(aPawn).bNoDismemberment = true;
			}
		}
		else
		{
			if (Level.NetMode != NM_DedicatedServer && bCoopRagdollSync)
			{
				NETChameleonModuleClass.static.PawnDyingNetSync(aPawn, true);
			}
			else
			{
				//NETChameleonModuleClass.static.PawnDyingNetSync(aPawn);

				NETChameleonModuleClass.static.TearOffNetworkConnectionFor(aPawn, damageType);
				aPawn.SetCollision(false);
				if( AWPerson(aPawn) != None )
					AWPerson(aPawn).bNoDismemberment = true;
			}
		}
	}

	Super.Killed(Killer, Killed, KilledPawn, damageType);
}

///steam 21/11/2016
function bool AtCapacity(bool bSpectator)
{
//	if ( Level.NetMode == NM_Standalone )
//		return false;
	if( bSpectator )
		return ( MaxSpectators == 0 || NumSpectators >= MaxSpectators );
		///return true;///steam 21/11/2016 we can not use spectators, because it's not tested yet =(
		//return ( (NumSpectators >= MaxSpectators) && ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );
	else return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

///steam 22/11/2016
function CoopCallNETStatsInfo()
{
	local controller con;
	for(con = Level.ControllerList; con != None; con = con.NextController)
	{
		if( CoopPlayerController(con) != None && con.Buoyancy != 75 )
			CoopPlayerController(con).SpawnNETStatsInfo();
	}
}

///steam 03/01/2017
exec function comGoto(String LevelName)
{
	local Pawn aPawnHost;

	Log("CHEAT: comGoto() LevelName="$LevelName);

	TheGameState.PlayerCheated("Cheat traveling");

	aPawnHost = GetPlayer().Pawn;

	if( aPawnHost == None || aPawnHost.bDeleteMe )
	{
		xCoopServerEventMessage("CoopGame: cheat traveling error, host player invalid");
		return;
	}

	xCoopServerEventMessage("CoopGame: cheat traveling to:"@LevelName);

	if( LevelName != "" && LevelName != "Entry.fuk" && DoesMapExist(LevelName) )
		SendPlayerTo(GetPlayer(), LevelName);
	else xCoopServerEventMessage("CoopGame: wrong map name, or map not found");
}

///steam 02/08/2017
function CoopScene_TeleportHostPlayerIntPoint(CoopSceneManager aSceneManager, CoopPlayerController aHostPlayer)
{
	local Controller con;
	local Pawn aLastPawn;
	local float LastDist;
	local vector CheckLoc;

	///steam 19/11/2017
	if( xLastErndCompltdTime != 0 
		&& Level.TimeSeconds < xLastErndCompltdTime + 1 )
	{
		//xCoopServerEventMessage("xLastErndCompltd uses location" @ xLastErndCompltdLoc);
		CheckLoc = xLastErndCompltdLoc;
	}
	else
	{
//		log("CoopScene_TeleportHostPlayerIntPoint"@aSceneManager@aSceneManager.Actions[0]@aSceneManager.Actions[0].IntPoint);
		if( aSceneManager.Actions.Length == 0 
			|| aSceneManager.Actions[0] == None 
			|| aSceneManager.Actions[0].IntPoint == None )
			return;
		CheckLoc = aSceneManager.Actions[0].IntPoint.Location;
	}

	LastDist = -1;
	for( con = Level.ControllerList; con != None; con = con.NextController )
	{
		if( CoopPlayerController(con) != None 
			&& !CoopPlayerController(con).IsCoopDedicatedHost() 
			//&& con != aHostPlayer 
			&& con.Pawn != None 
			&& !con.Pawn.bDeleteMe 
			&& con.Pawn.Health > 0 
			/*&& VSize(con.Pawn.Location-CheckLoc) < CoopSceneTeleportCheckDist*/ )
		{
			if( LastDist == -1 || VSize(CheckLoc - con.Pawn.Location) < LastDist )
				aLastPawn = con.Pawn;
			LastDist = VSize(CheckLoc - con.Pawn.Location);
		}
	}

//	log("CoopScene_TeleportHostPlayerIntPoint"@aLastPawn);
	if( aLastPawn != None && aHostPlayer.Pawn != aLastPawn )
		aHostPlayer.Pawn.SetLocation(aLastPawn.Location);
}

///steam 28/01/2017 CoopScene_TeleportHostPlayer() moved from CoopSceneManager.uc
///steam 01/05/2016
function CoopScene_TeleportHostPlayer(CoopSceneManager aSceneManager, Actor Other, Pawn EventInstigator)
{
	local CoopPlayerController aHostPlayer;

//	log("CoopScene_TeleportHostPlayer"@aSceneManager);

	if( aSceneManager == None )
		return;

	aHostPlayer = CoopPlayerController(GetPlayer());

//	log("CoopScene_TeleportHostPlayer"@aHostPlayer@aHostPlayer.Pawn);

	if( aHostPlayer == None 
		|| aHostPlayer.Pawn == None 
		|| aHostPlayer.Pawn.bDeleteMe )
		return;

	aSceneManager.SceneHostPawn = aHostPlayer.Pawn;

	if( aHostPlayer.Pawn.Health <= 0 )
		aHostPlayer.xForceHealThePawn(5);

	///aHostPlayer.ClientMessage(Other@EventInstigator);

	if( Other != None 
		&& Other.IsA('Trigger')
		&& EventInstigator != None
		&& EventInstigator != aHostPlayer.Pawn )
	{
		aHostPlayer.Pawn.SetLocation(EventInstigator.Location);
	}
	else
	{
		CoopScene_TeleportHostPlayerIntPoint(aSceneManager, aHostPlayer);
//		aHostPlayer.ClientMessage("FIX ME PLEASE CoopScene_TeleportHostPlayerIntPoint");
	}
}

///steam 28/01/2017 CoopScene_TeleportClientPlayers() moved from CoopSceneManager.uc
///steam 02/05/2016
function CoopScene_TeleportClientPlayers(CoopSceneManager aSceneManager)
{
	local controller con;
	local Pawn aSceneHostPawn;
	local bool bNoTeleport;

	if( aSceneManager == None )
		return;

	if( aSceneManager.SceneHostPawn == None 
		|| aSceneManager.SceneHostPawn.bDeleteMe )
		aSceneManager.SceneHostPawn = None;

	aSceneHostPawn = aSceneManager.SceneHostPawn;

	///steam 04/08/2016 crap hack to fix teleport when host haven't moved
	if( aSceneHostPawn != None && GetCoopPlayerHost() != None && GetCoopPlayerHost().StartSpot != None 
		&& VSize(GetStartSpotLocation(GetCoopPlayerHost().StartSpot)-aSceneHostPawn.Location) < (CoopSceneTeleportCheckDist*0.5) )
		bNoTeleport = true;

	for( con = Level.ControllerList; con != None; con = con.NextController )
	{
		if( CoopPlayerController(con) != None && con.Buoyancy != 75 && con.Pawn != None )
		{
			if( con.Pawn.Health <= 0 )
				CoopPlayerController(con).xForceHealThePawn(5);
			if( aSceneHostPawn != None && !bNoTeleport 
				&& VSize(aSceneHostPawn.Location-con.Pawn.Location) > CoopSceneTeleportCheckDist )
				xForceSetLocationFor(con.Pawn, aSceneHostPawn.Location);
		}
	}
}

///steam 10/03/2017 - CoopBaseMutator save added
function AddMutator(string mutname, optional bool bUserAdded)
{
    local class<Mutator> mutClass;
    local Mutator mut;

    mutClass = class<Mutator>(DynamicLoadObject(mutname, class'Class'));
    if (mutClass == None)
        return;

	/// merged from P2GameInfoSingle.uc
	if( class<P2GameMod>(mutClass) == None )
	{
		warn(MutName@" - Cannot use Mutator as parent class for single-player game mods. Please use P2GameMod instead.");
		return;
	}
	/// merged from P2GameInfoSingle.uc

	if( (mutClass.Default.GroupName != "") && (BaseMutator != None) )
	{
		// make sure no mutators with same groupname
		for ( mut=BaseMutator; mut!=None; mut=mut.NextMutator )
			if ( mut.GroupName == mutClass.Default.GroupName )
				return;
	}

    mut = Spawn(mutClass);
	// mc, beware of mut being none
	if (mut == None)
		return;

	///steam 10/03/2017
	if( mutname == CoopMutatorClass )
	{
		CoopBaseMutator = CoopGameBaseMod(mut);
		log(self@"AddMutator() CoopBaseMutator added!"@CoopBaseMutator);
	}

	// Meant to verify if this mutator was from Command Line parameters or added from other Actors
	mut.bUserAdded = bUserAdded;

    if (BaseMutator == None)
        BaseMutator = mut;
    else
        BaseMutator.AddMutator(mut);
}

///steam 10/04/2017
function CoopAddToBanList(string S, optional bool bTCC)
{
	if( CoopAccessControl(AccessControl) != None )
		CoopAccessControl(AccessControl).CoopAddToBanList(S, bTCC);
}

///steam 10/04/2017 - TESTING NEED TO REMOVE
exec function comConfTst()
{
	if( bUseDebugCmd )
		EndOfGame(P2Player(NETPlayerHost));
}

/**exec function GetModList()
{
	local string ModList;
	local Mutator M;
	local bool bFirst;
	
	// Skip the base mutator
	for (M = Level.Game.BaseMutator.NextMutator; M != None; M = M.NextMutator)
	{
		if (!bFirst)
			bFirst = true;
		else
			ModList = ModList $ ", ";
		ModList = ModList $ M.FriendlyName;
	}
	GetPlayer().ClientMessage(ModList);
}**/

function CoopStartApocalypseBlockTelepads()
{
	if( GetLevelTravelDelay() <= 0 )
		xDisableLevelTravelTimer();
}

state RunningApocalypse
{
	function BeginState()
	{
		Super.BeginState();
		CoopStartApocalypseBlockTelepads();
	}
}

///steam 19/11/2017
function PrepDifficulty()
{
	if( bCoopDedicated /*|| bNonDedicatedAutoSave*/ )///NonDedicatedAutoSave 22/01/2018
		return;
	Super.PrepDifficulty();
}

///steam 31/07/2017
function CoopDedicatedPostTravel()
{
	local Mutator TestMutator;
	local class<HolidaySpawnerBase> HolidaySpawnerClass;
	local P2Pawn PlayerPawn;
	local bool bIsCoopSavedBefore;

	if( TheGameState == None )
		TheGameState = spawn(GameStateClass);

	if( CoopIsMap(Left(CoopServerMapLoader, abs(Len(CoopServerMapLoader)-4))) )
	{
		CoopMapLoaderServerTravel();
		return;
	}

	PlayerPawn = P2Pawn(NETPlayerHost.Pawn);

	if( !bAutoSave_FirstRun ) // FIX 21/04/2018 - allows to start new game on dedicated
		bIsCoopSavedBefore = CoopLoadServerGameState();

	// FIX 21/04/2018 - allows to start new game on dedicated
	if( bAutoSave_FirstRun )
	{
		bAutoSave_FirstRun = false;
		SaveConfig();
	}

	//if( !CoopLoadServerGameState() )
	if( !bIsCoopSavedBefore )
	{
		Log(self$" CoopDedicatedPostTravel(): Starting new game");
		TheGameState.bChangeDayPostTravel = true;
		/**if( CoopStoryModeType != 0 )
		{
			if( CoopStoryModeType == 1 )
			{
				TheGameState.NextDay = DAY_SATURDAY;
				SetDayAtLaunch();
			}
		}
		else TheGameState.NextDay = 0;**/
		if( CoopStoryModeType == 1 )///steam 21/10/2017 - fix fow AWP mode
		{
			TheGameState.NextDay = DAY_SATURDAY;
			SetDayAtLaunch();
		}
		else
		{
			TheGameState.NextDay = 0;
		}
		///SetupDifficultyOnce(); ///steam 15/11/2017 - this must be called every time
	}
	else Log(self$" CoopDedicatedPostTravel(): Continuing existing game (game loaded from NicksCoopServerSave.ini)");

	///steam 15/11/2017 - this must be called every time
	SetupDifficultyOnce();

	// Allows for testing enhanced game via command line
	if (bEGameStart)
		TheGameState.bEGameStart = true;

	// Turn on night mode if applicable
	if (IsHoliday(NIGHT_MODE_HOLIDAY))
		TheGameState.bNightMode = true;

	// Check the mutator chain. If the player added any Workshop game mods, consider the game cheated and ineligible for speedruns/achievements.
	for (TestMutator = BaseMutator; TestMutator != None; TestMutator = TestMutator.NextMutator)
	{
		if( String(TestMutator.Class) != MutatorClass 
			&& String(TestMutator.Class) != CoopMutatorClass )
		{
			TheGameState.PlayerCheated("Using Workshop game mod");
			break;
		}
	}

	// Check if we need to change the day (includes starting a new game)
	if (TheGameState.bChangeDayPostTravel)
	{
		// Check if starting a new game
		if (NextDay() == 0)
		{
			TheGameState.bFirstLevelOfGame = true;
			TheGameState.bPreGameMode = false;

			// Check for valid errand goals (only done once, reports errors to log)
			CheckForValidErrandGoals();
		}
		else
		{
			TheGameState.bFirstLevelOfGame = false;

			// Remove inventory player can't leave the current day with
			Days[TheGameState.CurrentDay].TakeInventoryFromPlayer(PlayerPawn);
			nCoopTakeInvFromPlayer = TheGameState.CurrentDay;
		}

		// Change the day
		TheGameState.CurrentDay = NextDay();
		TheGameState.bFirstLevelOfDay = true;
		TheGameState.ErrandsCompletedToday = 0;
		TheGameState.bChangeDayPostTravel = false;
		TheGameState.bChangeDayForDebug = false;
	}
	else
	{
		// Same day, so clear flag
		TheGameState.bFirstLevelOfDay = false;
	}

	// Bring in a holiday spawner, if used
	HolidaySpawnerClass = class<HolidaySpawnerBase>(DynamicLoadObject(HolidaySpawnerClassName, class'Class'));
	//log("Spawn"@HolidaySpawnerClass,'HolidaySpawner');
	if (HolidaySpawner == None && HolidaySpawnerClass != None)
		HolidaySpawner = Spawn(HolidaySpawnerClass);

	// GameInfo is now valid
	GameInfoIsNowValid();

	// Tell GameState the level has changed
	TheGameState.PostLevelChange(PlayerPawn, ParseLevelName(Level.GetLocalURL()));

	// Get most recent slot
	MostRecentGameSlot = TheGameState.MostRecentGameSlot;

	// Restore day and its errands
	RestoreDayAndErrands();
		
	// Restore pawns that teleported with the player
	TheGameState.RestoreAllTeleportedPawns(PlayerPawn);

	// Handle changing things because we're going to the first level of a new day
	if (TheGameState.bFirstLevelOfDay)
	{
		// Check if we need to give the player the starting inventory for this day
		Days[TheGameState.CurrentDay].AddInStartingInventory(PlayerPawn);
//		nCoopAddInStartingInv = TheGameState.CurrentDay;
		// Check to delete any dynamic variables expiring at the end of the day
		TheGameState.ClearDailyDynamicVariables();
	}
	nCoopAddInStartingInv = TheGameState.CurrentDay;

	// See if the game mods want to do anything
	BaseMod.PostTravel(PlayerPawn);

	// See if holidays want to do anything
	PostTravelForHolidays(PlayerPawn);
}

///steam 31/07/2017
function bool CoopLoadServerGameState()
{
	local bool bResult;

	bResult = CoopSaveSystem.IsCoopSavedBefore();
	if( bResult )
		CoopSaveSystem.CoopLoadGame(true);

	return bResult;
}

///steam 31/07/2017
function CoopSaveServerGameState()
{
	CoopSaveSystem.CoopSaveGame(true);
}

///steam 01/08/2017
function int CoopAddInStartingInventoryFor(P2Pawn PlayerPawn, int xCoopAddInStartingInv)
{
	//PlayerPawn.ClientMessage("CoopAddInStartingInventoryFor"@PlayerPawn@nCoopAddInStartingInv@xCoopAddInStartingInv);
	if( PlayerPawn != None && nCoopAddInStartingInv != -1 && nCoopAddInStartingInv != xCoopAddInStartingInv )
	{
		Days[nCoopAddInStartingInv].AddInStartingInventory(PlayerPawn);
		return nCoopAddInStartingInv;
	}
	return -1;
}

///steam 01/08/2017
function CoopTakeInventoryFromPlayerFor(P2Pawn PlayerPawn)
{
	if( PlayerPawn != None && nCoopTakeInvFromPlayer != -1 )
		Days[nCoopTakeInvFromPlayer].TakeInventoryFromPlayer(PlayerPawn);
	//PlayerPawn.ClientMessage("CoopTakeInventoryFromPlayerFor"@PlayerPawn@nCoopTakeInvFromPlayer);
}

/**exec function comGetPCID()
{
	GetPlayer().ClientMessage(Level.ComputerName);
}**/

///steam 27/10/2017 - loot hold system
function PlayerLeave_UpdatePlayerTravelInfoFor(MpPawn SavingPlayer)
{
	if( (bCoopDedicated || bNonDedicatedAutoSave) ///NonDedicatedAutoSave 22/01/2018 - NOTE dont call this to host player!
		&& SavingPlayer != None 
		&& Level.NextURL == "" 
		&& CoopServerNextLevel == "" )
	{
		log(SavingPlayer @ "Player left the server, trying to save his lut.");
		PostTravel_UpdatePlayerTravelInfoFor(SavingPlayer);
	}
}

///steam 03/08/2017 - loot hold system
function PostTravel_UpdatePlayerTravelInfoFor(MpPawn SavingPlayer)
{
	if( (bCoopDedicated || bNonDedicatedAutoSave) ///NonDedicatedAutoSave 22/01/2018
		&& SavingPlayer != None )
	{
		CoopSaveSystem.PostTravel_UpdatePlayerTravelInfoFor(SavingPlayer);
	}
}

///steam 03/08/2017 - loot hold system
function PreTravel_RefreshPlayerHoldInfo()
{
	if( bCoopDedicated || bNonDedicatedAutoSave ) ///NonDedicatedAutoSave 22/01/2018
		CoopSaveSystem.PreTravel_RefreshPlayerHoldInfo();
}

///steam 04/08/2017
function CoopDedicatedEndGame()
{
	TheGameState = None;
	if( CoopSaveSystem != None )
		CoopSaveSystem.TheGameState = spawn(GameStateClass);
	//CoopSaveSystem.EraseTravelInfo();
}

///steam 07/08/2017
static function string CoopGetFirstMap()
{
	local string ServerMap;
	if( class'CoopBrowserHostCW'.default.bServerLoadIntro )
	{
		if( default.CoopStoryModeType == 1 )
			ServerMap = default.WeekendStartURL;
		else ServerMap = default.IntroURL;
	}
	else
	{
		if( default.CoopStoryModeType == 1 )
			ServerMap = default.AWStartFirstDayURL;
		else ServerMap = default.StartFirstDayURL;
	}
	return ServerMap;
}

///steam 04/08/2017 - loading after maploader
function CoopMapLoaderServerTravel()
{
	local string URL;

	if( !bAutoSave_FirstRun ) // FIX 21/04/2018 - allows to start new game on dedicated
		URL = CoopSaveSystem.GetServerNextMap();

	if( URL == "" )
	{
		URL = CoopGetFirstMap();
		///steam 22/01/2018
		CoopDetectTravelPortalName(URL);
	}

	log("CoopMapLoaderServerTravel()" @ CoopServerMapLoader @ "map detected, travel to the next map..." @ URL);

	PreTravel_RefreshPlayerHoldInfo();

	if (InStr(URL, "#") < 0)
		URL = URL $ "#";

	StopAllMusicExt(0.0);
	StopSceneManagers();

	Level.ServerTravel(URL, true);
}

///steam 05/08/2017 - calls from CoopConFix_PoliceController class
function CoopPlayerArrestAlert(MpPawn aSuspect)
{
	if( IsCinematic() )
		return;
	xCoopServerEventMessage(aSuspect.GetHumanReadableName() @ CoopPlayerArrestAlertMsg, true, true);
}

function string DecToHex(int dec, int size)
{
	const hex = "0123456789ABCDEF";
	local string s;
	local int i;
	for( i = 0 ; i < size*2 ; i++ )
	{
		s = mid(hex, dec & 0xf, 1) $ s;
		dec = dec >>> 4;
	}
	return s;
}

///steam 06/08/2017
function string InitTravelNameID()
{
	return DecToHex(Rand(65536),2)$"_"$DecToHex(Rand(65536),2);
}

///steam 06/08/2017
function string InitSaveEntryID()
{
	return DecToHex(Rand(65536),2)$"-"$DecToHex(Rand(65536),2)$"-"$DecToHex(Rand(65536),2);
}

///steam 06/08/2017
function string InitSavePlayerID()
{
	return DecToHex(Rand(65536),2)$"-"$DecToHex(Rand(65536),2)$"-"$DecToHex(Rand(65536),2);
}

///steam 06/08/2017
function string InitSaveServerID()
{
	return DecToHex(Rand(65536),2)$"-"$DecToHex(Rand(65536),2)$"-"$DecToHex(Rand(65536),2)$"-"$DecToHex(Rand(65536),2);
}

///steam 21/08/2017
function CheckSaveServerID()
{
	if( CoopSaveServerID == "" )
	{
		CoopSaveServerID = InitSaveServerID();
		SaveConfig();
	}
}

///steam 06/08/2017
function string GetSaveServerID()
{
	return CoopSaveServerID;
}

///steam 06/08/2017
function QuerySavePlayerID(CoopPlayerController aPC)
{
	local string sPlayerID, sServerID;
	if( aPC == None )
	{
		Warn("INIT PLAYER ID WITHOUT PLAYER CONTROLLER");
		return;
	}
	sPlayerID = InitSavePlayerID();
	sServerID = GetSaveServerID();
	aPC.QueryPlayerID(sPlayerID, sServerID);
}

///steam 07/08/2017
function CoopManualSavePlayer(MpPawn SavingPlayer)
{
	local int i;
	local string sPlayerID;
	local string sSystemID;
	local bool bFound;
	local bool bFailed;

	///steam 01/09/2017
	if( IsCinematic() 
		|| Level.NextURL != "" )
		return;

	if( SavingPlayer == None 
		|| SavingPlayer.bDeleteMe 
		|| CoopPlayerController(SavingPlayer.Controller) == None 
		|| Level.TimeSeconds < 10 )
		return;

	if( Level.TimeSeconds < fCoopManualSavePlayerTime )
	{
		SavingPlayer.ClientMessage(CoopManualSaveMsg2);
		return;
	}
	fCoopManualSavePlayerTime = Level.TimeSeconds + 0.5;

	CoopPlayerController(SavingPlayer.Controller).GetPlayerID(sPlayerID, sSystemID);

	if( sPlayerID == "" )
		return;

	for( i = 0 ; i < CoopManualSaveInfo.Length ; i++ )
	{
		if( CoopManualSaveInfo[i].PlayerID == sPlayerID )
		{
			bFound = true;
			if( Level.TimeSeconds < CoopManualSaveInfo[i].SaveTime + 5 )
			{
				SavingPlayer.ClientMessage(CoopManualSaveMsg3);
				bFailed = true;
			}
			CoopManualSaveInfo[i].SaveTime = Level.TimeSeconds;
		}
		else if( Level.TimeSeconds > CoopManualSaveInfo[i].SaveTime + 30 )
		{
			CoopManualSaveInfo.Remove(i, 1);
			i--;
		}
	}

	if( bFailed )
		return;

	if( !bFound )
	{
		i = CoopManualSaveInfo.Length;
		CoopManualSaveInfo.Insert(i, 1);
		CoopManualSaveInfo[i].PlayerID = sPlayerID;
		CoopManualSaveInfo[i].SaveTime = Level.TimeSeconds;
	}
	PostTravel_UpdatePlayerTravelInfoFor(SavingPlayer);
	SavingPlayer.ClientMessage(CoopManualSaveMsg1);
}

///steam 09/08/2017 - test spectator
function bool CanSpectate(PlayerController Viewer, bool bOnlySpectator, actor ViewTarget)
{
	if ( ViewTarget == None )
		return false;
	if ( Controller(ViewTarget) != None )
		return ( (Controller(ViewTarget).PlayerReplicationInfo != None)
			&& !Controller(ViewTarget).PlayerReplicationInfo.bOnlySpectator );
	return ( (Level.NetMode == NM_Standalone) || bOnlySpectator );
}

///steam 04/08/2016 we need to find nearest player
function Controller xGetValidPawnConFor(LambController useController)
{
	local Controller aCon;
	local Controller LastCon;
	local float LastDist;
	if( useController != None && useController.Pawn != None && !useController.Pawn.bDeleteMe )
	{
		LastDist = -1;
		for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
		{
			if( aCon != useController 
				&& (CoopPlayerController(aCon) == None || CoopPlayerController(aCon) != None && !CoopPlayerController(aCon).IsCoopDedicatedHost()) 
				&& aCon.Pawn != None 
				&& !aCon.Pawn.bDeleteMe 
				&& !aCon.Pawn.bHidden 
				&& aCon.Pawn.Health > 0 )
			{
				if( LastDist == -1 || VSize(useController.Pawn.Location - aCon.Pawn.Location) < LastDist )
				{
					LastCon = aCon;
					LastDist = VSize(useController.Pawn.Location - aCon.Pawn.Location);
				}
			}
		}
	}
	if( LastCon != None )
		return LastCon;
	return None;
}

///steam 17/08/2017
function string xGetLogFilename(string sLogName)
{
	local string sResult;
	sResult = sLogName;
	ReplaceText(sResult, "%Y", Right("0000"$string(Level.Year), 4));
	ReplaceText(sResult, "%M", Right("00"$string(Level.Month), 2));
	ReplaceText(sResult, "%D", Right("00"$string(Level.Day), 2));
	ReplaceText(sResult, "%H", Right("00"$string(Level.Hour), 2));
	ReplaceText(sResult, "%I", Right("00"$string(Level.Minute), 2));
	ReplaceText(sResult, "%W", Right("0"$string(Level.DayOfWeek), 1));
	ReplaceText(sResult, "%S", Right("00"$string(Level.Second), 2));
	return sResult;
}
function string xGetLogCurrentTime()
{
	return Right("00" $ string(Level.Hour), 2) $ ":" $ Right("00"$string(Level.Minute), 2) $ ":" $ Right("00"$string(Level.Second), 2);
}
function string xConvertReportLogInfo(string sInfo)
{
	return "["$xGetLogCurrentTime()$"]"@sInfo;
}
function xCoopReportLogF(string sInfo)
{
	local int i, j;
	if( bReportLogEnabled )
	{
		if( ReportLogFileInfo == None )
		{
			ReportLogFileInfo = spawn(class'CoopReportFileLog',self);
			if( ReportLogFileInfo != None )
			{
				ReportLogFileInfo.OpenLog(xGetLogFilename(ReportLogFileType));
				if( ReportLogStack.Length > 0 )
				{
					for( i = 0 ; i < ReportLogStack.Length ; i++ )
					{
						ReportLogFileInfo.LogF(ReportLogStack[i]);
					}
					ReportLogStack.Remove(0,ReportLogStack.Length);
					ReportLogStack.Length = 0;
				}
				ReportLogFileInfo.LogF(xConvertReportLogInfo(sInfo));
				ReportLogFileInfo.CloseLog();
				ReportLogFileInfo.LifeSpan = 0.01;
			}
			else warn("Report log cannot be spawned");
		}
		else
		{
			j = ReportLogStack.Length;
			ReportLogStack.Insert(j, 1);
			ReportLogStack[j] = xConvertReportLogInfo(sInfo);
		}
	}
	///else Log("ReportLog: ["$xGetLogCurrentTime()$"]"@sInfo);
}

event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode
)
{
	Super.PreLogin(Options, Address, Error, FailCode);
	xCoopReportLogF(Address @ "connected," @ "options:" @ Options);
	if( Error != "" || FailCode != "" )
		xCoopReportLogF(Address @ "rejected," @ "REASON:" @ Error @ FailCode);
}

///steam 24/08/2017
event Broadcast(Actor Sender, coerce string Msg, optional name Type)
{
	if( Level.NextURL != "" )
		return;
	Super.Broadcast(Sender, Msg, Type);
}

///steam 24/08/2017
function bool AllowBloodSpouts()
{
	return false;
}

///steam 02/09/2017
function CoopLoadCustomSkinFor(CoopPlayerController aPC, string InSkin, string InFace)
{
	local int i;

	if( aPC == None || InSkin == "" )
		return;

	for( i = 0 ; i < CoopCustomPlayerSkins.Length ; i++ )
	{
		if( CoopCustomPlayerSkins[i] == "_end" )
			return;
		else if( CoopCustomPlayerSkins[i] == InSkin )
		{
			aPC.CoopSetCustomSkins(InSkin, InFace);
			return;
		}
	}
}

///steam 21/10/2017 - DEF GUNS FIX - the same as BystanderController.ConvertToRiotMode(), but with CreateInventory instead of ByClass
function ConvertToRiotModeFor(PersonController pcont, optional string GunClass)
{
	local int randpick;
	local BystanderController aCon;

	if( pcont == None 
		|| BystanderController(pcont) == None )
		return;

	aCon = BystanderController(pcont);

	//  Give him a good weapon, even if he already has one
	// Every once in a while give him a big 'gun'
	if( GunClass != "" )
	{
		aCon.MyPawn.CreateInventory(GunClass);
	}
	else
	{
	if(Rand(aCon.RIOT_BIG_GUN_PICK_RAND) == 0)
	{
		randpick = Rand(aCon.RIOT_GUN_RAND);
		switch(randpick)
		{
			case 0:
				aCon.MyPawn.CreateInventory("Inventory.GrenadeWeapon");
				break;
			case 1:
				aCon.MyPawn.CreateInventory("Inventory.MolotovWeapon");
				break;
			case 2:
				aCon.MyPawn.CreateInventory("Inventory.LauncherWeapon");
				break;
		}
	}
	else	// Otherwise he gets a smaller gun
	{
		randpick = Rand(aCon.RIOT_GUN_RAND);
		switch(randpick)
		{
			case 0:
				aCon.MyPawn.CreateInventory("Inventory.PistolWeapon");
				break;
			case 1:
				aCon.MyPawn.CreateInventory("Inventory.ShotgunWeapon");
				break;
			case 2:
				aCon.MyPawn.CreateInventory("Inventory.MachineGunWeapon");
				break;
		}
	}
	}

	// Make them meaner and stronger
	if(aCon.MyPawn.Cajones < 1.0)
		aCon.MyPawn.Cajones = 1.0;
	if(aCon.MyPawn.PainThreshold < 1.0)
		aCon.MyPawn.PainThreshold = 1.0;
	aCon.MyPawn.Cowardice = 1.0-aCon.MyPawn.PainThreshold;
	if (aCon.MyPawn.BlockMeleeFreq < aCon.RIOT_MELEE_BLOCK)
		aCon.MyPawn.BlockMeleeFreq = aCon.RIOT_MELEE_BLOCK;

	// Up their health and the damage they do
	aCon.MyPawn.HealthMax *= aCon.RIOT_HEALTH_INCREASE;
	aCon.MyPawn.Health = aCon.MyPawn.HealthMax;
	aCon.MyPawn.DamageMult *= aCon.RIOT_DAMAGE_INCREASE;

	// And much crazier...(if you're not the dude's friend)
	if(!aCon.MyPawn.bPlayerIsFriend)
	{
		if(FRand() < aCon.RIOT_HATE_PLAYER)
			aCon.MyPawn.bPlayerIsEnemy=true;

		aCon.MyPawn.bGunCrazy=true;
	}
}

///steam 21/10/2017 - DEF GUNS FIX
///////////////////////////////////////////////////////////////////////////////
// Goes through the level and changes all NPCs to riot mode (done by controllers)
///////////////////////////////////////////////////////////////////////////////
function ConvertAllPawnsToRiotMode()
{
	local P2Pawn ppawn;
	local PersonController pcont;

	//log(self$" ConvertAllPawnsToRiotMode	00000000000000000000000000");
	// Find everyone in the level and zap them
	foreach DynamicActors(class'P2Pawn', ppawn)
	{
		pcont = PersonController(ppawn.Controller);
		if(pcont != None)
		{
			ConvertToRiotModeFor(pcont);///steam 21/10/2017 - DEF GUNS FIX
			///pcont.ConvertToRiotMode();
		}
	}
}

///steam 21/10/2017 - DEF GUNS FIX
///////////////////////////////////////////////////////////////////////////////
// Only to be used when fixing a saved game's difficulty. If we had a liebermode game
// and now the person is about to patch their save with a new difficulty, say average,
// we need to undo all the baton/shovel/taser things and give them their normal weapons.
// But not for the player. Leave him alone.
///////////////////////////////////////////////////////////////////////////////
function FixDifficultyInventories()
{
	local P2Pawn checkpawn;
	log(self$" FixDifficultyInventories");
	foreach DynamicActors(class'P2Pawn', checkpawn)
	{
		if(checkpawn.Health > 0
			&& checkpawn.Controller != None
			&& P2Player(checkpawn.Controller) == None)
		{
			//log(self$" checking "$checkpawn);
			// Remove everything they had
			checkpawn.DestroyAllInventory();
			// Reset them
			checkpawn.ResetGotDefaultInventory();
			// Add in all in again, but have the new difficulty (naturally) set everything
			checkpawn.AddDefaultInventory();
			// If they are in the apocalypse, make sure to get them ready for that.
			if(TheGameState.bIsApocalypse
				&& PersonController(checkpawn.Controller) != None)
				ConvertToRiotModeFor(PersonController(checkpawn.Controller));///steam 21/10/2017 - DEF GUNS FIX
				///PersonController(checkpawn.Controller).ConvertToRiotMode();
		}
	}
}

///steam 27/10/2017 - BystandersRefill system
function PrepSliderPawns()
{
	///steam 07/01/2016
	LoadCoOpDefaults();

	Super.PrepSliderPawns();

	///steam 27/10/2017 - BystandersRefill system
	if( bCoopDedicated || bUseBystandersRefill )
		InitBystandersRefill();
}

///steam 27/10/2017 - BystandersRefill system
function InitBystandersRefill()
{
	local P2Pawn aOther;
	local int i;

	if( BystandersRefillInfo.Length > 0 )
		return;

	foreach DynamicActors(class'P2Pawn', aOther)
	{
		if( aOther.bUsePawnSlider 
			&& aOther.bInnocent
			&& !aOther.bPersistent 
			&& aOther.PawnInitialState != aOther.EPawnInitialState.EP_Dead )
		{
			i = BystandersRefillInfo.Length;
			BystandersRefillInfo.Insert(i, 1.0);
			BystandersRefillInfo[i].SpawnID = aOther.Name;
			BystandersRefillInfo[i].SpawnPos = aOther.Location;
			BystandersRefillInfo[i].SpawnClass = aOther.class;
		}
	}
	log("InitBystandersRefill spawn count:" @ BystandersRefillInfo.Length);
}

///steam 27/10/2017 - BystandersRefill system
function UpdateBystandersRefill()
{
	local int i;
	local bool bFound;
	local P2Pawn aOldPawn, aPawn;

	if( SliderPawnsTotal >= SliderPawnGoal )
		return;

	for( i = 0 ; i < BystandersRefillInfo.Length ; i++ )
	{
		if( BystandersRefillInfo[i].SpawnID != '' 
			&& BystandersRefillInfo[i].SpawnClass != None )
		{
			if( SliderPawnsTotal >= SliderPawnGoal )
				break;
			bFound = false;
			foreach DynamicActors(class'P2Pawn', aOldPawn)
			{
				if( !aOldPawn.bDeleteMe 
					&& aOldPawn.Name == BystandersRefillInfo[i].SpawnID )
				{
					bFound = true;
					break;
				}
			}
			if( bFound )
				continue;
			if( !BystandersRefillSpotCheck(BystandersRefillInfo[i].SpawnPos) )
				continue;
			aPawn = spawn(BystandersRefillInfo[i].SpawnClass,,,BystandersRefillInfo[i].SpawnPos);
			if( aPawn == None )
				continue;
			if( aPawn.Controller == None )
				aPawn.SetupController();
			if( LambController(aPawn.Controller) != None )
				LambController(aPawn.Controller).GoIntoSliderStasis();
			BystandersRefillInfo[i].SpawnID = aPawn.Name;
			//xCoopServerEventMessage("BystandersRefill gotcha!" @ LambController(aPawn.Controller));
		}
	}
	//log("UpdateBystandersRefill");
}

///steam 27/10/2017 - BystandersRefill system
function bool BystandersRefillSpotCheck(vector SpotLocation)
{
	local Pawn pplayer;
	local float usedist, usedot;
	local Controller aCon;
	local int nPlayersTotal, nPlayersChecked;
	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
	{
		if( CoopPlayerController(aCon) != None 
			&& !CoopPlayerController(aCon).IsCoopDedicatedHost() 
			&& !CoopPlayerController(aCon).IsCoopPlayerAFK() 
			&& aCon.Pawn != None && !aCon.Pawn.bDeleteMe )
		{
			pplayer = aCon.Pawn;
			usedist = VSize(SpotLocation-pplayer.Location);
			usedot = Normal(SpotLocation-pplayer.Location) Dot vector(pplayer.Rotation);
			if( usedist > SLIDER_PAWN_DIST_REFILL 
				&& ((usedot) < VIEW_CONE_SLIDER_PAWN || !FastTrace(SpotLocation, pplayer.Location)) )
				nPlayersChecked++;
			nPlayersTotal++;
		}
	}
	return (nPlayersTotal > 0 && nPlayersChecked == nPlayersTotal);
}

///steam 27/10/2017 - BystandersRefill system
function CheckToRevivePawns()
{
	local FPSPawn fpawn;

	//log(self$" CheckToRevivePawns, active "$SliderPawnsActive$" goal "$SliderPawnGoal$" total "$SliderPawnsTotal);

	if(SliderPawnsActive < SliderPawnGoal
		&& SliderPawnsActive < SliderPawnsTotal)
	{
		//log(self$" trying to bring some back ");

		foreach DynamicActors(class'FPSPawn', fpawn)
		{
			//log(self$" checking "$fpawn);

			if(fpawn.bSliderStasis
				&& LambController(fpawn.Controller) != None)
			{
				if( BystandersRefillSpotCheck(fpawn.Location) )
				{
					LambController(fpawn.Controller).ComeOutOfSliderStasis();
					// If we've met our quota, then quit early
					if(SliderPawnsActive >= SliderPawnGoal
						|| SliderPawnsActive == SliderPawnsTotal)
					{
						//log(self$" STOPPING!");
						break;
					}
				}
			}
		}
	}
	///steam 27/10/2017 - BystandersRefill system
	if( bCoopDedicated || bUseBystandersRefill )
		UpdateBystandersRefill();
	//xCoopServerEventMessage("BystandersRefill sliders total:" @ SliderPawnsTotal @ "active:" @ SliderPawnsActive);
}

///steam 30/10/2017
function PossibleSetGameSpeed(float newspeed)
{
	///STUB
}

static function AutoSave_SetFirstRun(bool bToggle)
{
	default.bAutoSave_FirstRun = bToggle;
	StaticSaveConfig();
}

function CheckToTransferPlayerInventory()
{
	local P2PowerupPickup powerpick;
	local P2WeaponPickup weappick;
	local P2PowerupInv powerinv;
	local P2Weapon weapinv;
	local P2Player p2p;
	local P2Pawn usepawn, temppawn;
	local RobbedInv Robber;
	local bool bFound;
	local float Amount;
	local float ItemAmount;
	local int i;
	local bool bUseTakePlayerInventory;

	if( CoopSaveSystem == None )
	{
		Super.CheckToTransferPlayerInventory();
		return;
	}

	// Get the dude controller
	p2p = GetPlayer();

	// Get the pawn out of that controller
	usepawn = p2p.MyPawn;

	// If a movie starting up on level load or something has prevented getting the player controller
	// at least get
	if(usepawn == None)
	{
		foreach AllActors(class'P2Pawn', temppawn)
		{
			//log(self$" pawn "$temppawn$" player "$temppawn.bPlayer);
			if(temppawn.bPlayer)
			{
				p2p = P2Player(temppawn.Controller);
				usepawn = temppawn;
				break;
			}
		}
	}

	bUseTakePlayerInventory = TheGameState.bTakePlayerInventory || (bCoopDedicated && CoopSaveSystem.CoopSave_bTakePlayerInventory);
	CoopSaveSystem.CoopSave_bTakePlayerInventory = false;

	// If we're not transferring, just destroy all marked powerups
	if( !bUseTakePlayerInventory ) //if(!TheGameState.bTakePlayerInventory)
	{
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
		{
			if(powerpick.bForTransferOnly)
				powerpick.Destroy();
		}
		foreach DynamicActors(class'P2WeaponPickup', weappick)
		{
			if(weappick.bForTransferOnly)
				weappick.Destroy();
		}
	}
	else
	{
		// Go through all the powerups
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
		{
			// If you are to remove them, check if the dude has the powerup
			if(powerpick.bForTransferOnly)
			{
				powerinv = P2PowerupInv(usepawn.FindInventoryType(powerpick.InventoryType));

				ItemAmount = 0;
				//log(self$" checking for "$powerpick.InventoryType$" has this "$powerinv);
				// He has it, so leave it, but transfer the count over.
				if(powerinv != None)
				{
					// Force it to drop them all
					powerinv.bThrowIndividually=false;

					// Transfer info from the inv to the pickup
					powerpick.InitDroppedPickupFor(powerinv);
					// Make sure it's persistent
					powerpick.bPersistent = true;

					if( !powerpick.bDestroyAfterTransfer )
						ItemAmount = powerinv.Amount;

					// destroy the inventory for the dude
					powerinv.DetachFromPawn(powerinv.Instigator);
					usepawn.DeleteInventory(powerinv);

					CoopSaveSystem.xRegisterTransferItem(powerpick.InventoryType, powerpick.bDestroyAfterTransfer, ItemAmount);

					// If the powerup was marked to steal it from him, do so. This
					// means that for things like donuts or money, the cops will take
					// them from your inventory and you'll never get them back
					if(powerpick.bDestroyAfterTransfer)
						powerpick.Destroy();
				}
				else	// he doesn't so destroy it
				{
					CoopSaveSystem.xRegisterTransferItem(powerpick.InventoryType, powerpick.bDestroyAfterTransfer, ItemAmount);

					powerpick.Destroy();
				}
			}
		}
		// Go through all the weapons
		foreach DynamicActors(class'P2WeaponPickup', weappick)
		{
			// If you are to remove them, check if the dude has the weapon
			if(weappick.bForTransferOnly)
			{
				weapinv = P2Weapon(usepawn.FindInventoryType(weappick.InventoryType));

				ItemAmount = 0;
				//log(self$" checking for "$weappick.InventoryType$" has this "$weapinv);
				// He has it, so leave it, but transfer the count over.
				if(weapinv != None)
				{
					// transfer info from the inv to the pickup
					weappick.InitDroppedPickupFor(weapinv);
					// Make sure it's persistent
					weappick.bPersistent = true;

					if( !weappick.bDestroyAfterTransfer )
						ItemAmount = weapinv.AmmoType.AmmoAmount;

					// First remove the ammo for this weapon from the dude
					weapinv.AmmoType.DetachFromPawn(weapinv.Instigator);
					weapinv.AmmoType.Instigator.DeleteInventory(weapinv.AmmoType);
					// Then destroy the inventory for the dude
					weapinv.DetachFromPawn(weapinv.Instigator);
					usepawn.DeleteInventory(weapinv);

					CoopSaveSystem.xRegisterTransferItem(weappick.InventoryType, weappick.bDestroyAfterTransfer, ItemAmount);

					// If the powerup was marked to steal it from him, do so. This
					// means that for things like donuts or money, the cops will take
					// them from your inventory and you'll never get them back
					if(weappick.bDestroyAfterTransfer)
						weappick.Destroy();
				}
				else	// he doesn't so destroy it
				{
					CoopSaveSystem.xRegisterTransferItem(weappick.InventoryType, weappick.bDestroyAfterTransfer, ItemAmount);

					weappick.Destroy();
				}
			}
		}

		// Do anything special you need to, after your inventory and weapons have
		// been taken from you.
		p2p.CheckInventoryAfterItsTaken();

		// Kevlar is special because armor is in the usepawn, so strip any armor
		// from him too. And don't give any back
		usepawn.Armor = 0;

		// If you had a weapon you were currently using, it could have screwed up things
		// so just default to switching your hands (like if you're clipboard was taken and
		// was currently being used)
		if(p2p != None)
		{
			p2p.ResetHandsToggle();

			if(p2p.MyPawn != None)
				p2p.SwitchToHands(true);
		}

		// Make sure to reset this
		TheGameState.bTakePlayerInventory=false;
	}	
	
	// Handle dude robbery items
	if (usepawn != None)
	{
		Robber = RobbedInv(usepawn.FindInventoryType(class'RobbedInv'));
		// Search in powerups
		foreach DynamicActors(class'P2PowerupPickup', powerpick)
		{
			if (powerpick.bForRobberyOnly)
			{
				bFound = false;
				if (Robber != None)
				{
					// Find out how much the robber stole (if any) and put it into the pickup
					Amount = Robber.ReturnThisItem(powerpick.InventoryType);
					if (Amount != -1)
					{
						bFound = true;
						powerpick.AmountToAdd = Amount;
					}
				}
				// If the robber didn't steal this, destroy it.
				if (!bFound)
					powerpick.Destroy();
			}
		}
		// Search in weapons
		foreach DynamicActors(class'P2WeaponPickup', weappick)
		{
			if (weappick.bForRobberyOnly)
			{
				bFound = false;
				if (Robber != None)
				{
					// Find out how much the robber stole (if any) and put it into the pickup
					Amount = Robber.ReturnThisItem(weappick.InventoryType);
					if (Amount != -1)
					{
						bFound = true;
						weappick.AmmoGiveCount = int(Amount);
					}
				}
				// If the robber didn't steal this, destroy it.
				if (!bFound)
					weappick.Destroy();
			}
		}
	}

	if( CoopSaveSystem.TransferItems.Length > 0 && CoopTransferBackpacks.Length > 0 )
	{
		for( i = 0; i < CoopTransferBackpacks.Length; i++ )
		{
			if( CoopIsMap(CoopTransferBackpacks[i].MapName) )
				spawn(class'CoopTransferBackpack', self,, CoopTransferBackpacks[i].SpawnLoc, class'CoopTransferBackpack'.default.RelativeRotation);
		}
	}
}

defaultproperties
{
	NETChameleonModuleClass=class'CoopNETChameleonModuleHost'

	CoopTransferBackpacks(0)=(MapName="POLICE",SpawnLoc=(X=-4658.0,Y=-10376.0,Z=-5306.0))
	CoopTransferBackpacks(1)=(MapName="BREWERY",SpawnLoc=(X=-3035.0,Y=-835.0,Z=-266.0))
	CoopTransferBackpacks(2)=(MapName="HOSPITAL",SpawnLoc=(X=-9060.0,Y=-924.0,Z=-824.0))

	bNonDedicatedAutoSave=true
	bUseBystandersRefill=true
	bCoopRagdollSync=true

	CoopSliderPawnGoalMax=12
	bReportLogEnabled=false
	ReportLogFileType="ReportLog_D%D_M%M_Y%Y"
	CoopTravelAccessPercent=0.5
	CoopManualSaveMsg1="Save Player: Success"
	CoopManualSaveMsg2="Save Player: Failed - Try again later"
	CoopManualSaveMsg3="Save Player: Failed - Can't save too often."
	CoopPlayerArrestAlertMsg="is going to be arrested!"

	CoopServerMapLoader="NicksCoopMapLoader.fuk"
	nCoopTakeInvFromPlayer=-1
	nCoopAddInStartingInv=-1
	SongNoReplica="map_muzak.ogg"
	CoopSceneTeleportCheckDist=512
	CoopFriendlyFireScale=1.0

	CoopCustomPlayerSkinsM=None
	CoopCustomPlayerSkins(0)="ChameleonSkins.Special.Dude"
	CoopCustomPlayerSkins(1)="MPSkins.RedTeam.MW__008__Avg_Dude"
	CoopCustomPlayerSkins(2)="MPSkins.BlueTeam.MW__007__Avg_Dude"
	CoopCustomPlayerSkins(3)="NicksCoop.ExtraStuff.BetaNiceDude_Skin"
	CoopCustomPlayerSkins(4)="NicksCoop.ExtraStuff.HNDudeSanta_Skin"
	CoopCustomPlayerSkins(5)="NicksCoop.ExtraStuff.TalibDude_Skin"
	CoopCustomPlayerSkins(6)="ChameleonSkins.Scientists.MW__005__Avg_Dude"
	CoopCustomPlayerSkins(7)="ChameleonSkins.Scientists.MW__164__Avg_Dude"
	CoopCustomPlayerSkins(8)="NicksCoop.ExtraStuff.EDDude_Skin"
	CoopCustomPlayerSkins(9)="NicksCoop.ExtraStuff.SJDudeShtopor_Skin00"
	CoopCustomPlayerSkins(10)="NicksCoop.ExtraStuff.SJDudeShtopor_Skin01"
	CoopCustomPlayerSkins(11)="NicksCoop.ExtraStuff.P1Dude_Skin"
	CoopCustomPlayerSkins(12)="NicksCoop.ExtraStuff.P3Dude_Skin"
	CoopCustomPlayerSkins(13)="NicksCoop.ExtraStuff.PRDude_Skin"
	CoopCustomPlayerSkins(14)="NicksCoop.ExtraStuff.Punisher_Skin"

	CoopFixFXReplace(0)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter59")
	CoopFixFXReplace(1)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter3")
	CoopFixFXReplace(2)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter45")
	CoopFixFXReplace(3)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter1")
	CoopFixFXReplace(4)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter5")
	CoopFixFXReplace(5)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter46")
	CoopFixFXReplace(6)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter65")
	CoopFixFXReplace(7)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter32")
	CoopFixFXReplace(8)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter56")
	CoopFixFXReplace(9)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter47")
	CoopFixFXReplace(10)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire01',CoopFixFXName="FireSizeableEmitter0")
	CoopFixFXReplace(11)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire02',CoopFixFXName="FireSizeableEmitter54")
	CoopFixFXReplace(12)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire02',CoopFixFXName="FireSizeableEmitter57")
	CoopFixFXReplace(13)=(CoopFixFXMap="LIBRARY2",CoopFixFXClass=class'CoopFixFX_Library2_Fire03',CoopFixFXName="FireSizeableEmitter71")

	CoopFixFXReplace(14)=(CoopFixFXMap="INTRO",CoopFixFXClass=class'CoopFixFX_Intro_Fire01',CoopFixFXName="FireSizeableEmitter5")
	CoopFixFXReplace(15)=(CoopFixFXMap="INTRO",CoopFixFXClass=class'CoopFixFX_Intro_Smoke01',CoopFixFXName="P2Emitter2")
	CoopFixFXReplace(16)=(CoopFixFXMap="INTRO",CoopFixFXClass=class'CoopFixFX_Intro_Smoke02',CoopFixFXName="P2Emitter3")

	CoopFixFXReplace(17)=(CoopFixFXMap="LOWERPARADISE2",CoopFixFXClass=class'CoopFixFX_LowerParadise2_Feathers01',CoopFixFXName="Emitter14")

	CoopFixMatTrigReplace(0)=(CoopFixMatTrigMap="HOSPITAL",CoopFixMatTrigClass=class'CoopMaterialTrigger_Hospital',CoopFixMatTrigName="MaterialTrigger7")
	CoopFixMatTrigReplace(1)=(CoopFixMatTrigMap="GAYFISH",CoopFixMatTrigClass=class'CoopMaterialTrigger_GayFish',CoopFixMatTrigName="MaterialTrigger7")
	CoopFixMatTrigReplace(2)=(CoopFixMatTrigMap="LOWERPARADISE",CoopFixMatTrigClass=class'CoopMaterialTrigger_LowerParadise',CoopFixMatTrigName="MaterialTrigger0")
	CoopFixMatTrigReplace(3)=(CoopFixMatTrigMap="MILITARYBASE4",CoopFixMatTrigClass=class'CoopMaterialTrigger_MilitaryBase4',CoopFixMatTrigName="MaterialTrigger7")

	StartSpotInfo(0)=(X=0,Y=0,Z=0)
	StartSpotInfo(1)=(X=0,Y=64,Z=0)
	StartSpotInfo(2)=(X=0,Y=-64,Z=0)
	StartSpotInfo(3)=(X=64,Y=-32,Z=0)
	StartSpotInfo(4)=(X=64,Y=32,Z=0)
	StartSpotInfo(5)=(X=-64,Y=-32,Z=0)
	StartSpotInfo(6)=(X=-64,Y=32,Z=0)

	xDisableLTT_WaitTime=12.0
	MaxPlayers=5
	MaxSpectators=3

	SongActorModel=StaticMesh'ben_mesh.Misc.handCuffs_link_ben'

	SliderPawnGoal=10
	BodiesSliderMax=5
	//bEnableDismemberment=false
	//bEnableDismembermentPhysics=false
	bUseWeaponSelector=true

	DefaultPlayerClassName="NicksCoop.CoopPostalDude"
	MainMenuName="NicksCoop.CoopMenuMain"
	StartMenuName="NicksCoop.CoopMenuMain"
	GameMenuName="NicksCoop.CoopMenuGame"

	CoopSaveSystemClass=class'NicksCoop.CoopSaveSystem'
	HUDType="NicksCoop.CoopHUD"
	ScoreBoardType="NicksCoop.CoopScoreBoard"
	PlayerControllerHostClassName="NicksCoop.CoopPlayerControllerHost"
	PlayerControllerClassName="NicksCoop.CoopPlayerController"
	GameReplicationInfoClass=Class'NicksCoop.CoopGameReplicationInfo'
	//MutatorClass="NicksCoop.CoopMutator"
	//MutatorClass="NicksCoop.CoopGameBaseMod"
	ChameleonClass=class'CoopChameleonPlus'
	CoopMutatorClass="NicksCoop.CoopGameBaseMod"

	AWStartFirstDayURL="Hospital.fuk"
	IntroURL="Intro.fuk"
	StartFirstDayURL="Suburbs-3.fuk"
	StartNextDayURL="Suburbs-3.fuk"
	FinishedDayURL="HomeAtNight.fuk"
	JailURL="Police.fuk#cell"
	bAllowBehindView=true
	DefaultPlayerName="TheDude"
	GameName="NicksCoop P2"
	GameNameShort="NicksCoop P2"
	GameDescription="Postal 2 Week + Apocalypse Weekend cooperative story modes"
}
