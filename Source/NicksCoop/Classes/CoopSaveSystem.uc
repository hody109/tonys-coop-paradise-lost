//=============================================================================
// CoopSaveSystem.uc
// - 27-06-2015 - saving loot system changed
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015-2017.
//=============================================================================

class CoopSaveSystem extends Actor
	notplaceable
	config(NicksCoopSave);

struct PlayerLootTravelInfoStruct
{
	var() string SaveID;
	var() string EquipmentClass;
	var() string EquipmentAmmo;///steam 13/06/2016 changed from INT to STRING
};

///steam 03/08/2017 - loot hold system
struct PlayerLootHoldInfoStruct
{
	var() string PlayerID;
	var() string SystemID;
	var() string SaveID;
	var() int SaveCycle;
	var() int SaveDate;
};

var GameState TheGameState;
var CoopGameInfo myCoopGameInfo;

var globalconfig string CoopSave_LastLevel;
var globalconfig int CoopSave_PeopleKilled;
var globalconfig int CoopSave_CopsKilled;
var globalconfig int CoopSave_ElephantsKilled;
var globalconfig int CoopSave_DogsKilled;
var globalconfig int CoopSave_CatsKilled;
var globalconfig int CoopSave_PistolHeadShot;
var globalconfig int CoopSave_ShotgunHeadShot;
var globalconfig int CoopSave_RifleHeadShot;
var globalconfig int CoopSave_CatsUsed;
var globalconfig int CoopSave_MoneySpent;
var globalconfig int CoopSave_PeeTotal;
var globalconfig int CoopSave_DoorsKicked;
var globalconfig int CoopSave_TimesArrested;
var globalconfig int CoopSave_DressedAsCop;
var globalconfig int CoopSave_DogsTrained;
var globalconfig int CoopSave_PeopleRoasted;
var globalconfig int CoopSave_CopsLuredByDonuts;
var globalconfig array<GameState.SErrand> CoopSave_CompletedErrands;
var globalconfig array<GameState.SErrand> CoopSave_ActivatedErrands;
var globalconfig array<GameState.SErrand> CoopSave_RevealedErrands;
var globalconfig array<GameState.SHater> CoopSave_CurrentHaters;
var globalconfig bool CoopSave_bAddedNewHaters;
var globalconfig int CoopSave_CurrentDay;
var globalconfig bool CoopSave_bFirstLevelOfGame;
var globalconfig bool CoopSave_bFirstLevelOfDay;
var globalconfig int CoopSave_JailCellNumber;
var globalconfig int CoopSave_LastJailCellNumber;
var globalconfig float CoopSave_CopRadioTime;
var globalconfig bool CoopSave_bArrestPlayerInJail;
var globalconfig bool CoopSave_bPlayerInCell;
var globalconfig bool CoopSave_bNiceDude;
var globalconfig float CoopSave_CatnipUseTime;
var globalconfig class<Inventory> CoopSave_HudArmorClass;
var globalconfig bool CoopSave_bEGameStart;
var globalconfig class<Inventory> CoopSave_CurrentClothes;
var globalconfig bool CoopSave_bIsApocalypse;
var globalconfig int CoopSave_GameDifficulty;
var globalconfig int CoopSave_GameDifficultyNumber;///steam 22/04/2016
var globalconfig array<PlayerLootTravelInfoStruct> CoopSave_PlayersLootTravelInfo;
var globalconfig int CoopSave_CoopStoryModeType; ///steam 09/05/2016
var globalconfig array<PlayerLootHoldInfoStruct> CoopSave_PlayersLootHoldInfo;///steam 03/08/2017 - loot hold system
//var globalconfig int CoopInfo_HoldSaveCyclesMax;
var globalconfig int CoopInfo_HoldSaveDateLimit;///steam 03/08/2017 - loot hold system
var globalconfig int CoopInfo_HoldStatsSaveDateLimit;///steam 20/04/2018 - hold stats for longer period
var globalconfig int CoopInfo_ItemsSaveNumMax;
var globalconfig int CoopInfo_HoldSaveSaveCyclesDays;
var globalconfig int CoopInfo_HoldSaveSaveCyclesMin;

/***
16/11 steam upd
***/
var globalconfig bool CoopSave_bCheated;
var globalconfig int CoopSave_ZombiesKilledOverall;
var globalconfig int CoopSave_HeadsLopped;
var globalconfig int CoopSave_LimbsHacked;
var globalconfig int CoopSave_ZombiesResurrected;
var globalconfig int CoopSave_BaseballHeads;
var globalconfig int CoopSave_FanaticsKilled;
var globalconfig int CoopSave_ArmyKilled;
var globalconfig int CoopSave_ChainsawKills;
var globalconfig bool CoopSave_bNightMode;
var globalconfig int CoopSave_BirdsFlipped;
var globalconfig array<GameState.SErrand> CoopSave_DeActivatedErrands;///???
var globalconfig bool CoopSave_bNoHolidays;
var globalconfig float CoopSave_TimeElapsed;
var globalconfig bool CoopSave_bUsedCheats;
var globalconfig bool CoopSave_bShovelEndingDQ;
var globalconfig bool CoopSave_bReadMondayPaper;
var globalconfig bool CoopSave_bReadTuesdayPaper;
var globalconfig bool CoopSave_bReadWednesdayPaper;
var globalconfig bool CoopSave_bReadThursdayPaper;
var globalconfig bool CoopSave_bReadFridayPaper;
var globalconfig int CoopSave_DressedAsGimp;
var globalconfig int CoopSave_CrackSmoked;
var globalconfig int CoopSave_CatnipSmoked;
/***
//16/11 steam upd
***/

///steam 01/08/2017 - dedicated server game state
var globalconfig bool CoopSave_bChangeDayPostTravel;
var globalconfig int CoopSave_NextDay;
var globalconfig int CoopSave_ErrandsCompletedToday;
var globalconfig string CoopSave_ServerNextLevel;
var globalconfig string CoopSave_TravelPortalName;

///steam 22/04/2016
const c_strDifficultyPath = "Postal2Game.P2GameInfo GameDifficulty";
const c_strDifficultyNumberPath = "Postal2Game.P2GameInfo GameDifficultyNumber";
const LieberPath = "Postal2Game.P2GameInfo bLieberMode";
const HestonPath = "Postal2Game.P2GameInfo bHestonMode";
const TheyHateMePath = "Postal2Game.P2GameInfo bTheyHateMeMode";
const InsaneoPath = "Postal2Game.P2GameInfo bInsaneoMode";
const ExpertPath = "Postal2Game.P2GameInfo bExpertMode";
const LudicrousPath = "Postal2Game.P2GameInfo bLudicrousMode";
const CustomPath = "Postal2Game.P2GameInfo bCustomMode";

///steam 09/05/2016
const CoopStoryModeTypePath = "NicksCoop.CoopGameInfo CoopStoryModeType";

// UPD 21/04/2018 - coop transfer items
struct TransferItemStruct
{
	var() class<Inventory> ItemClass;
	var() bool bDestroyAfterTransfer;
	var() float ItemAmount;
};
var array<TransferItemStruct> TransferItems;
var array<PlayerLootTravelInfoStruct> TransferItemsCache;
var array<string> TransferItemsFound;
var globalconfig bool CoopSave_bTakePlayerInventory;

function CoopPostLoadGame(int day, optional string CoopLoadURL)
{
	if( myCoopGameInfo != None )
		myCoopGameInfo.CoopPostLoadGame(CoopSave_CurrentDay, CoopSave_LastLevel);
}

function GetPlayerID(CoopPlayerController aPC, out string sPlayerID, out string sSystemID)
{
	if( aPC == None )
	{
		Warn("GETTING PLAYER ID WITHOUT PLAYER CONTROLLER");
		return;
	}
	aPC.GetPlayerID(sPlayerID, sSystemID);
	return;
}

function string GetSaveID(MpPawn SavingPlayer)
{
	local int i;
	i = FindPlayerHoldInfoEntry(SavingPlayer);
	if( i >= 0 )
		return CoopSave_PlayersLootHoldInfo[i].SaveID;
	return "";
}

function CoopLoadGame(optional bool bServerAutoSave)
{
	local int i;

	if( TheGameState == None )
	{
		if( Level.Game != None && CoopGameInfo(Level.Game) != None )
		{
			myCoopGameInfo = CoopGameInfo(Level.Game);
			TheGameState = CoopGameInfo(Level.Game).TheGameState;
		}
	}

	if( TheGameState == None )
		return;

	TheGameState.PeopleKilled = CoopSave_PeopleKilled;
	TheGameState.CopsKilled = CoopSave_CopsKilled;
	TheGameState.ElephantsKilled = CoopSave_ElephantsKilled;
	TheGameState.DogsKilled = CoopSave_DogsKilled;
	TheGameState.CatsKilled = CoopSave_CatsKilled;
	TheGameState.PistolHeadShot = CoopSave_PistolHeadShot;
	TheGameState.ShotgunHeadShot = CoopSave_ShotgunHeadShot;
	TheGameState.RifleHeadShot = CoopSave_RifleHeadShot;
	TheGameState.CatsUsed = CoopSave_CatsUsed;
	TheGameState.MoneySpent = CoopSave_MoneySpent;
	TheGameState.PeeTotal = CoopSave_PeeTotal;
	TheGameState.DoorsKicked = CoopSave_DoorsKicked;
	TheGameState.TimesArrested = CoopSave_TimesArrested;
	TheGameState.DressedAsCop = CoopSave_DressedAsCop;
	TheGameState.DogsTrained = CoopSave_DogsTrained;
	TheGameState.PeopleRoasted = CoopSave_PeopleRoasted;
	TheGameState.CopsLuredByDonuts = CoopSave_CopsLuredByDonuts;
	TheGameState.bAddedNewHaters = CoopSave_bAddedNewHaters;

	///steam 01/07/2017 - to avoid unwanted TakeFromPlayerList caused by wrong day
	///Warn("CoopLoadGame"@self@TheGameState.CurrentDay@CoopSave_CurrentDay);
	if( !bServerAutoSave )
	{
		if( TheGameState.CurrentDay == CoopSave_CurrentDay )
			TheGameState.CurrentDay = FMax(CoopSave_CurrentDay-1,0);
	}
	else TheGameState.CurrentDay = CoopSave_CurrentDay;

	TheGameState.bFirstLevelOfGame = CoopSave_bFirstLevelOfGame;
	TheGameState.bFirstLevelOfDay = CoopSave_bFirstLevelOfDay;
	TheGameState.JailCellNumber = CoopSave_JailCellNumber;
	TheGameState.LastJailCellNumber = CoopSave_LastJailCellNumber;
	TheGameState.CopRadioTime = CoopSave_CopRadioTime;
///	TheGameState.bArrestPlayerInJail = CoopSave_bArrestPlayerInJail;
	TheGameState.bNiceDude = CoopSave_bNiceDude;
	TheGameState.CatnipUseTime = CoopSave_CatnipUseTime;
	TheGameState.HudArmorClass = CoopSave_HudArmorClass;
	TheGameState.bEGameStart = CoopSave_bEGameStart;
	TheGameState.CurrentClothes = CoopSave_CurrentClothes;
	TheGameState.bIsApocalypse = CoopSave_bIsApocalypse;
	TheGameState.GameDifficulty = CoopSave_GameDifficulty;

	///steam 22/04/2016
	Load_DiffChanged(CoopSave_GameDifficulty, CoopSave_GameDifficultyNumber);

	///steam 09/05/2016
	//CoopGameInfo(Level.Game).CoopStoryModeType = CoopSave_CoopStoryModeType;
	ConsoleCommand("set"@CoopStoryModeTypePath@CoopSave_CoopStoryModeType);

///steam 25/07/2016
	if( CoopSave_bCheated )
		TheGameState.PlayerCheated("CHEATS");
	TheGameState.ZombiesKilledOverall = CoopSave_ZombiesKilledOverall;
	TheGameState.HeadsLopped = CoopSave_HeadsLopped;
	TheGameState.LimbsHacked = CoopSave_LimbsHacked;
	TheGameState.ZombiesResurrected = CoopSave_ZombiesResurrected;
	TheGameState.BaseballHeads = CoopSave_BaseballHeads;
	TheGameState.FanaticsKilled = CoopSave_FanaticsKilled;
	TheGameState.ArmyKilled = CoopSave_ArmyKilled;
	TheGameState.ChainsawKills = CoopSave_ChainsawKills;
	TheGameState.bNightMode = CoopSave_bNightMode;
	TheGameState.BirdsFlipped = CoopSave_BirdsFlipped;
	TheGameState.bNoHolidays = CoopSave_bNoHolidays;
	TheGameState.TimeElapsed = CoopSave_TimeElapsed;
///	TheGameState.bUsedCheats = CoopSave_bUsedCheats;
	TheGameState.bShovelEndingDQ = CoopSave_bShovelEndingDQ;
	TheGameState.bReadMondayPaper = CoopSave_bReadMondayPaper;
	TheGameState.bReadTuesdayPaper = CoopSave_bReadTuesdayPaper;
	TheGameState.bReadWednesdayPaper = CoopSave_bReadWednesdayPaper;
	TheGameState.bReadThursdayPaper = CoopSave_bReadThursdayPaper;
	TheGameState.bReadFridayPaper = CoopSave_bReadFridayPaper;
	TheGameState.DressedAsGimp = CoopSave_DressedAsGimp;
	TheGameState.CrackSmoked = CoopSave_CrackSmoked;
	TheGameState.CatnipSmoked = CoopSave_CatnipSmoked;

	///TheGameState.DeActivatedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( TheGameState.DeActivatedErrands.Length > 0 )
	{
		TheGameState.DeActivatedErrands.Remove(0,TheGameState.DeActivatedErrands.Length);
		TheGameState.DeActivatedErrands.Length = 0;
	}
	for( i = 0 ; i < CoopSave_DeActivatedErrands.Length ; i++ )
	{
		TheGameState.DeActivatedErrands.Insert(TheGameState.DeActivatedErrands.Length, 1.0);
		TheGameState.DeActivatedErrands[i].Day = CoopSave_DeActivatedErrands[i].Day;
		TheGameState.DeActivatedErrands[i].Errand = CoopSave_DeActivatedErrands[i].Errand;
	}
///steam 25/07/2016

	///TheGameState.CompletedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( TheGameState.CompletedErrands.Length > 0 )
	{
		TheGameState.CompletedErrands.Remove(0,TheGameState.CompletedErrands.Length);
		TheGameState.CompletedErrands.Length = 0;
	}
	for( i = 0 ; i < CoopSave_CompletedErrands.Length ; i++ )
	{
		TheGameState.CompletedErrands.Insert(TheGameState.CompletedErrands.Length, 1.0);
		TheGameState.CompletedErrands[i].Day = CoopSave_CompletedErrands[i].Day;
		TheGameState.CompletedErrands[i].Errand = CoopSave_CompletedErrands[i].Errand;
	}

	///TheGameState.ActivatedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( TheGameState.ActivatedErrands.Length > 0 )
	{
		TheGameState.ActivatedErrands.Remove(0,TheGameState.ActivatedErrands.Length);
		TheGameState.ActivatedErrands.Length = 0;
	}
	for( i = 0 ; i < CoopSave_ActivatedErrands.Length ; i++ )
	{
		TheGameState.ActivatedErrands.Insert(TheGameState.ActivatedErrands.Length, 1.0);
		TheGameState.ActivatedErrands[i].Day = CoopSave_ActivatedErrands[i].Day;
		TheGameState.ActivatedErrands[i].Errand = CoopSave_ActivatedErrands[i].Errand;
	}

	///TheGameState.RevealedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( TheGameState.RevealedErrands.Length > 0 )
	{
		TheGameState.RevealedErrands.Remove(0,TheGameState.RevealedErrands.Length);
		TheGameState.RevealedErrands.Length = 0;
	}
	for( i = 0 ; i < CoopSave_RevealedErrands.Length ; i++ )
	{
		TheGameState.RevealedErrands.Insert(TheGameState.RevealedErrands.Length, 1.0);
		TheGameState.RevealedErrands[i].Day = CoopSave_RevealedErrands[i].Day;
		TheGameState.RevealedErrands[i].Errand = CoopSave_RevealedErrands[i].Errand;
	}

	///TheGameState.CurrentHaters.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( TheGameState.CurrentHaters.Length > 0 )
	{
		TheGameState.CurrentHaters.Remove(0,TheGameState.CurrentHaters.Length);
		TheGameState.CurrentHaters.Length = 0;
	}
	for( i = 0 ; i < CoopSave_CurrentHaters.Length ; i++ )
	{
		TheGameState.CurrentHaters.Insert(TheGameState.CurrentHaters.Length, 1.0);
		TheGameState.CurrentHaters[i].ClassName = CoopSave_CurrentHaters[i].ClassName;
		TheGameState.CurrentHaters[i].DesTex = CoopSave_CurrentHaters[i].DesTex;
		TheGameState.CurrentHaters[i].PicTex = CoopSave_CurrentHaters[i].PicTex;
		TheGameState.CurrentHaters[i].Comment = CoopSave_CurrentHaters[i].Comment;
		TheGameState.CurrentHaters[i].Revealed = CoopSave_CurrentHaters[i].Revealed;
	}

	///steam 24/08/2017
	if( myCoopGameInfo != None )
		myCoopGameInfo.CoopTravelPortalName = CoopSave_TravelPortalName;

	if( bServerAutoSave )
	{
		TheGameState.bChangeDayPostTravel = CoopSave_bChangeDayPostTravel;
		TheGameState.NextDay = CoopSave_NextDay;
		TheGameState.ErrandsCompletedToday = CoopSave_ErrandsCompletedToday;
	}

	if( !bServerAutoSave )
		CoopPostLoadGame(CoopSave_CurrentDay, CoopSave_LastLevel);

	log(self @ "CoopLoadGame() Success, bServerAutoSave" @ bServerAutoSave);

///	Destroy();
}

function CoopSaveGame(optional bool bServerAutoSave)
{
	local int i;
	local int k;
	local bool bFoundEntry;

	if( TheGameState == None )
	{
		if( Level.Game != None && CoopGameInfo(Level.Game) != None )
		{
			myCoopGameInfo = CoopGameInfo(Level.Game);
			TheGameState = CoopGameInfo(Level.Game).TheGameState;
		}
	}

	if( TheGameState == None )
		return;

	if( myCoopGameInfo != None )
		CoopSave_LastLevel = myCoopGameInfo.GetURLMap();
	else CoopSave_LastLevel = "";

	CoopSave_PeopleKilled = TheGameState.PeopleKilled;
	CoopSave_CopsKilled = TheGameState.CopsKilled;
	CoopSave_ElephantsKilled = TheGameState.ElephantsKilled;
	CoopSave_DogsKilled = TheGameState.DogsKilled;
	CoopSave_CatsKilled = TheGameState.CatsKilled;
	CoopSave_PistolHeadShot = TheGameState.PistolHeadShot;
	CoopSave_ShotgunHeadShot = TheGameState.ShotgunHeadShot;
	CoopSave_RifleHeadShot = TheGameState.RifleHeadShot;
	CoopSave_CatsUsed = TheGameState.CatsUsed;
	CoopSave_MoneySpent = TheGameState.MoneySpent;
	CoopSave_PeeTotal = TheGameState.PeeTotal;
	CoopSave_DoorsKicked = TheGameState.DoorsKicked;
	CoopSave_TimesArrested = TheGameState.TimesArrested;
	CoopSave_DressedAsCop = TheGameState.DressedAsCop;
	CoopSave_DogsTrained = TheGameState.DogsTrained;
	CoopSave_PeopleRoasted = TheGameState.PeopleRoasted;
	CoopSave_CopsLuredByDonuts = TheGameState.CopsLuredByDonuts;
	CoopSave_bAddedNewHaters = TheGameState.bAddedNewHaters;
	CoopSave_CurrentDay = TheGameState.CurrentDay;
	CoopSave_bFirstLevelOfGame = TheGameState.bFirstLevelOfGame;
	CoopSave_bFirstLevelOfDay = TheGameState.bFirstLevelOfDay;
	CoopSave_JailCellNumber = TheGameState.JailCellNumber;
	CoopSave_LastJailCellNumber = TheGameState.LastJailCellNumber;
	CoopSave_CopRadioTime = TheGameState.CopRadioTime;
///	CoopSave_bArrestPlayerInJail = TheGameState.bArrestPlayerInJail;
	CoopSave_bNiceDude = TheGameState.bNiceDude;
	CoopSave_CatnipUseTime = TheGameState.CatnipUseTime;
	CoopSave_HudArmorClass = TheGameState.HudArmorClass;
	CoopSave_bEGameStart = TheGameState.bEGameStart;
	CoopSave_CurrentClothes = TheGameState.CurrentClothes;
	CoopSave_bIsApocalypse = TheGameState.bIsApocalypse;
	CoopSave_GameDifficulty = TheGameState.GameDifficulty;

	///steam 22/04/2016
	CoopSave_GameDifficultyNumber = int(ConsoleCommand("get"@c_strDifficultyNumberPath));///c_strDifficultyPath

	///steam 09/05/2016
	CoopSave_CoopStoryModeType = int(ConsoleCommand("get"@CoopStoryModeTypePath));

///steam 25/07/2016
	CoopSave_bCheated = TheGameState.DidPlayerCheat();
	CoopSave_ZombiesKilledOverall = TheGameState.ZombiesKilledOverall;
	CoopSave_HeadsLopped = TheGameState.HeadsLopped;
	CoopSave_LimbsHacked = TheGameState.LimbsHacked;
	CoopSave_ZombiesResurrected = TheGameState.ZombiesResurrected;
	CoopSave_BaseballHeads = TheGameState.BaseballHeads;
	CoopSave_FanaticsKilled = TheGameState.FanaticsKilled;
	CoopSave_ArmyKilled = TheGameState.ArmyKilled;
	CoopSave_ChainsawKills = TheGameState.ChainsawKills;
	CoopSave_bNightMode = TheGameState.bNightMode;
	CoopSave_BirdsFlipped = TheGameState.BirdsFlipped;
	CoopSave_bNoHolidays = TheGameState.bNoHolidays;
	CoopSave_TimeElapsed = TheGameState.TimeElapsed;
///	CoopSave_bUsedCheats = TheGameState.bUsedCheats;
	CoopSave_bShovelEndingDQ = TheGameState.bShovelEndingDQ;
	CoopSave_bReadMondayPaper = TheGameState.bReadMondayPaper;
	CoopSave_bReadTuesdayPaper = TheGameState.bReadTuesdayPaper;
	CoopSave_bReadWednesdayPaper = TheGameState.bReadWednesdayPaper;
	CoopSave_bReadThursdayPaper = TheGameState.bReadThursdayPaper;
	CoopSave_bReadFridayPaper = TheGameState.bReadFridayPaper;
	CoopSave_DressedAsGimp = TheGameState.DressedAsGimp;
	CoopSave_CrackSmoked = TheGameState.CrackSmoked;
	CoopSave_CatnipSmoked = TheGameState.CatnipSmoked;
	CoopSave_bTakePlayerInventory = TheGameState.bTakePlayerInventory;

	///CoopSave_DeActivatedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( CoopSave_DeActivatedErrands.Length > 0 )
	{
		CoopSave_DeActivatedErrands.Remove(0,CoopSave_DeActivatedErrands.Length);
		CoopSave_DeActivatedErrands.Length = 0;
	}
	for( i = 0 ; i < TheGameState.DeActivatedErrands.Length ; i++ )
	{
		CoopSave_DeActivatedErrands.Insert(CoopSave_DeActivatedErrands.Length, 1.0);
		CoopSave_DeActivatedErrands[i].Day = TheGameState.DeActivatedErrands[i].Day;
		CoopSave_DeActivatedErrands[i].Errand = TheGameState.DeActivatedErrands[i].Errand;
	}
///steam 25/07/2016

	///CoopSave_CompletedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( CoopSave_CompletedErrands.Length > 0 )
	{
		CoopSave_CompletedErrands.Remove(0,CoopSave_CompletedErrands.Length);
		CoopSave_CompletedErrands.Length = 0;
	}
	for( i = 0 ; i < TheGameState.CompletedErrands.Length ; i++ )
	{
		CoopSave_CompletedErrands.Insert(CoopSave_CompletedErrands.Length, 1.0);
		CoopSave_CompletedErrands[i].Day = TheGameState.CompletedErrands[i].Day;
		CoopSave_CompletedErrands[i].Errand = TheGameState.CompletedErrands[i].Errand;
	}

	///CoopSave_ActivatedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( CoopSave_ActivatedErrands.Length > 0 )
	{
		CoopSave_ActivatedErrands.Remove(0,CoopSave_ActivatedErrands.Length);
		CoopSave_ActivatedErrands.Length = 0;
	}
	for( i = 0 ; i < TheGameState.ActivatedErrands.Length ; i++ )
	{
		CoopSave_ActivatedErrands.Insert(CoopSave_ActivatedErrands.Length, 1.0);
		CoopSave_ActivatedErrands[i].Day = TheGameState.ActivatedErrands[i].Day;
		CoopSave_ActivatedErrands[i].Errand = TheGameState.ActivatedErrands[i].Errand;
	}

	///CoopSave_RevealedErrands.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( CoopSave_RevealedErrands.Length > 0 )
	{
		CoopSave_RevealedErrands.Remove(0,CoopSave_RevealedErrands.Length);
		CoopSave_RevealedErrands.Length = 0;
	}
	for( i = 0 ; i < TheGameState.RevealedErrands.Length ; i++ )
	{
		bFoundEntry = false;
		for( k = 0; k < CoopSave_RevealedErrands.Length; k++) // FIX 18/04/2018 - avoid cloning RevealedErrands entries...
		{
			if( CoopSave_RevealedErrands[k].Day == TheGameState.RevealedErrands[i].Day 
				&& CoopSave_RevealedErrands[k].Errand == TheGameState.RevealedErrands[i].Errand )
			{
				bFoundEntry = true;
				break;
			}
		}
		if( !bFoundEntry )
		{
		CoopSave_RevealedErrands.Insert(CoopSave_RevealedErrands.Length, 1.0);
		CoopSave_RevealedErrands[i].Day = TheGameState.RevealedErrands[i].Day;
		CoopSave_RevealedErrands[i].Errand = TheGameState.RevealedErrands[i].Errand;
		}
	}

	///CoopSave_CurrentHaters.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( CoopSave_CurrentHaters.Length > 0 )
	{
		CoopSave_CurrentHaters.Remove(0,CoopSave_CurrentHaters.Length);
		CoopSave_CurrentHaters.Length = 0;
	}
	for( i = 0 ; i < TheGameState.CurrentHaters.Length ; i++ )
	{
		CoopSave_CurrentHaters.Insert(CoopSave_CurrentHaters.Length, 1.0);
		CoopSave_CurrentHaters[i].ClassName = TheGameState.CurrentHaters[i].ClassName;
		CoopSave_CurrentHaters[i].DesTex = TheGameState.CurrentHaters[i].DesTex;
		CoopSave_CurrentHaters[i].PicTex = TheGameState.CurrentHaters[i].PicTex;
		CoopSave_CurrentHaters[i].Comment = TheGameState.CurrentHaters[i].Comment;
		CoopSave_CurrentHaters[i].Revealed = TheGameState.CurrentHaters[i].Revealed;
	}

	///steam 24/08/2017
	if( myCoopGameInfo != None )
		CoopSave_TravelPortalName = myCoopGameInfo.CoopTravelPortalName;
	else CoopSave_TravelPortalName = "";

	if( bServerAutoSave )
	{
		CoopSave_bChangeDayPostTravel = TheGameState.bChangeDayPostTravel;
		CoopSave_NextDay = TheGameState.NextDay;
		CoopSave_ErrandsCompletedToday = TheGameState.ErrandsCompletedToday;

		if( myCoopGameInfo != None )
		{
			if( myCoopGameInfo.CoopServerNextLevel != "" )
				CoopSave_ServerNextLevel = myCoopGameInfo.CoopServerNextLevel;
			else CoopSave_ServerNextLevel = myCoopGameInfo.GetURLMap();
		}
		else CoopSave_ServerNextLevel = "";
	}

	SaveConfig();

	log(self @ "CoopSaveGame() Success, bServerAutoSave" @ bServerAutoSave);

///	Destroy();
}

function SaveAllPlayerTravelInfo(optional bool bServerAutoSave)
{
	local int i;
	local controller aCon;
	local CoopPlayerController PC;
	local MpPawn SavingPawn;

	if( !bServerAutoSave ) ///steam 22/01/2018
	{
	///CoopSave_PlayersLootTravelInfo.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( CoopSave_PlayersLootTravelInfo.Length > 0 )
	{
		CoopSave_PlayersLootTravelInfo.Remove(0,CoopSave_PlayersLootTravelInfo.Length);
		CoopSave_PlayersLootTravelInfo.Length = 0;
	}
	if( CoopSave_PlayersLootHoldInfo.Length > 0 )
	{
		CoopSave_PlayersLootHoldInfo.Remove(0,CoopSave_PlayersLootHoldInfo.Length);
		CoopSave_PlayersLootHoldInfo.Length = 0;
	}
	}

	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
	{
		PC = CoopPlayerController(aCon);
		if( PC != None && PC.Pawn != None && !PC.IsCoopDedicatedHost() )
		{
			SavingPawn = MpPawn(PC.Pawn);

			///steam 21/07/2016 hack to save in vehicles
			if( PC.GetNPVehicleOwnedBy(PC.Pawn) != None && PC.FirstPossessedPawn != None )
			{
				PC.ClientMessage("SAVING YOUR DATA FAILED: Please leave vehicle and save again!");
				SavingPawn = MpPawn(PC.FirstPossessedPawn);
			}

			if( SavingPawn != None )
			{
				if( bServerAutoSave ) ///steam 22/01/2018
				{
					i = FindPlayerHoldInfoEntry(SavingPawn);
					if( i >= 0 )
						RemovePlayerLootTravelInfoBySaveID(CoopSave_PlayersLootHoldInfo[i].SaveID);
				}
				SavePlayerTravelInfo(SavingPawn);
			}
		}
	}

	SaveConfig();

	log(self @ "SaveAllPlayerTravelInfo() CoopSave_PlayersLootTravelInfo length:" @ CoopSave_PlayersLootTravelInfo.Length);

///	Destroy();
}

function bool SavePlayerTravelInfo(MpPawn SavingPlayer)
{
	local int i, sCount, nCount;
	local int AmmoCount;
	local int NumB;
	local CoopPlayerController PC;
	local string sPlayerID;
	local string sSystemID;
	local string sSaveID;
	local Inventory Inv;
	local bool bCTPIFound;

	if( SavingPlayer != None && !SavingPlayer.bDeleteMe )
		PC = CoopPlayerController(SavingPlayer.Controller);

	if( PC == None 
		|| PC.PlayerReplicationInfo == None )
		return false;

	GetPlayerID(PC, sPlayerID, sSystemID);

	if( sPlayerID == "" || sSystemID == "" )
	{
		Warn("SAVING TRAVEL INFO WITHOUT PLAYER ID");
		return false;
	}

	sSaveID = UpdatePlayerHoldInfoFor(sPlayerID, sSystemID);

	log(self @ "saving travel info for: "$sPlayerID$", STARTED, PC: "$PC);

	for( Inv = SavingPlayer.Inventory; Inv != None; Inv = Inv.Inventory )
	{
		if( (P2Weapon(Inv) != None || Powerups(Inv) != None || CoopTravelPlayerInfoInv(Inv) != None)
				&& GameState(Inv) == None 
				&& HandsWeapon(Inv) == None 
				&& UrethraWeapon(Inv) == None 
				&& FootWeapon(Inv) == None 
				&& CellPhoneWeapon(Inv) == None ///steam 04/04/2016
				&& CoopTravelAdminInv(Inv) == None ///steam 04/04/2016
				&& StatInv(Inv) == None ///steam 04/04/2016
				&& MapInv(Inv) == None 
				&& GaryHeadWeapon(Inv) == None ///steam 27/10/2017
				&& MatchesWeapon(Inv) == None )
		{
			if( Weapon(Inv) != None && Weapon(Inv).AmmoType != None )
				AmmoCount = Weapon(Inv).AmmoType.AmmoAmount;
			else if( P2PowerupInv(Inv) != None )
				AmmoCount = P2PowerupInv(Inv).Amount;

			NumB = CoopSave_PlayersLootTravelInfo.Length;
			CoopSave_PlayersLootTravelInfo.Insert(NumB, 1.0);
			CoopSave_PlayersLootTravelInfo[NumB].SaveID = sSaveID;
			CoopSave_PlayersLootTravelInfo[NumB].EquipmentClass = string(Inv.class);
			///steam 13/06/2016
			if( Inv.IsA('CoopTravelPlayerInfoInv') )
			{
				//CoopSave_PlayersLootTravelInfo[NumB].EquipmentAmmo = "K="$PC.PlayerReplicationInfo.Kills$"?"$"D="$int(PC.PlayerReplicationInfo.Deaths)$"?";
				CoopSave_PlayersLootTravelInfo[NumB].EquipmentAmmo = CoopTravelPlayerInfoInv(Inv).CryptInfo(PC);
				CoopTravelPlayerInfoInv(Inv).UpdateTravelCheckSum();
				bCTPIFound = true;
			}
			else CoopSave_PlayersLootTravelInfo[NumB].EquipmentAmmo = string(AmmoCount);

			//log("saving travel info for: "$sPlayerID$", obj num: "$nCount$" in list: "$sCount$", obj: "$string(Inv.class)$", ammo: "$AmmoCount);
			nCount++;

			///SaveConfig();
		}
		sCount++;

		if( (nCount >= CoopInfo_ItemsSaveNumMax && bCTPIFound) || sCount > 5000 )
			break;
	}

	///steam 27/10/2017
	if( SavingPlayer.Armor > 0 && PC.HudArmorClass != None )
	{
		NumB = CoopSave_PlayersLootTravelInfo.Length;
		CoopSave_PlayersLootTravelInfo.Insert(NumB, 1.0);
		CoopSave_PlayersLootTravelInfo[NumB].SaveID = sSaveID;
		CoopSave_PlayersLootTravelInfo[NumB].EquipmentClass = string(PC.HudArmorClass);
		CoopSave_PlayersLootTravelInfo[NumB].EquipmentAmmo = string(int(SavingPlayer.Armor));
	}

	log(self @ "saving travel info for: "$sPlayerID$", FINISHED, PC: "$PC$" items saved: "$nCount);

	return true;
}

function LoadAllPlayerTravelInfo()
{
	local Controller aCon;
	local CoopPlayerController PC;
	local MpPawn SavingPawn;

	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
	{
		PC = CoopPlayerController(aCon);
		if( PC != None && PC.Pawn != None && !PC.IsCoopDedicatedHost() )
		{
			SavingPawn = MpPawn(PC.Pawn);

			///steam 21/07/2016 hack to load in vehicles
			if( PC.GetNPVehicleOwnedBy(PC.Pawn) != None && PC.FirstPossessedPawn != None )
			{
				PC.ForceLeaveNPVehicle();
				SavingPawn = MpPawn(PC.FirstPossessedPawn);
			}

			if( SavingPawn != None && FindPlayerHoldInfoEntry(SavingPawn) != -1 )
				LoadPlayerTravelInfo(SavingPawn);
		}
	}

	//SaveConfig();

	log(self @ "LoadAllPlayerTravelInfo() Success");

///	Destroy();
}

// Better organization for inventory setup - 13/05/2018
function SetupLoadedInventoryFor(MpPawn UsePawn, Inventory UseInv, float UseAmount, optional bool bAccumulate)
{
	local CoopPlayerController PC;
	PC = CoopPlayerController(UsePawn.Controller);

	if( P2Weapon(UseInv) != None && P2Weapon(UseInv).AmmoType != None )
	{
		if( bAccumulate )
			P2Weapon(UseInv).AmmoType.AmmoAmount += UseAmount;
		else P2Weapon(UseInv).AmmoType.AmmoAmount = UseAmount;

		if( ClipboardWeapon(UseInv) != None )
		{
			if( ClipboardWeapon(UseInv).AmmoType.AmmoAmount < ClipboardWeapon(UseInv).AmmoType.MaxAmmo )
				P2AmmoInv(ClipboardWeapon(UseInv).AmmoType).AddedToPawnInv(UsePawn, PC);
		}
	}
	else if( P2PowerupInv(UseInv) != None )
	{
		if( KevlarInv(UseInv) != None )
		{
			if( !bAccumulate || UsePawn.Armor < UseAmount )
				UsePawn.Armor = UseAmount;
			UsePawn.UsingNewArmor(Texture(KevlarInv(UseInv).Icon), UseInv.class);
		}
		else
		{
			if( bAccumulate )
				P2PowerupInv(UseInv).SetAmount(P2PowerupInv(UseInv).Amount+UseAmount);
			else P2PowerupInv(UseInv).SetAmount(UseAmount);
		}
	}
}

function bool LoadPlayerTravelInfo(MpPawn SavingPlayer)
{
	local int i;
	local CoopPlayerController PC;
	local string sSaveID;
	local Inventory Inv;
	local bool bWrongTravelCheckSum;

	if( SavingPlayer != None && !SavingPlayer.bDeleteMe )
		PC = CoopPlayerController(SavingPlayer.Controller);

	if( PC == None || PC.PlayerReplicationInfo == None )
		return false;

	sSaveID = GetSaveID(SavingPlayer);
	if( sSaveID == "" )
		return false;

	for( i = 0 ; i < CoopSave_PlayersLootTravelInfo.Length; i++ )
	{
		if( CoopSave_PlayersLootTravelInfo[i].SaveID == sSaveID )
		{
			Inv = PersonPawn(SavingPlayer).CreateInventory(CoopSave_PlayersLootTravelInfo[i].EquipmentClass);
			if( Inv != None )
			{
				if( CoopTravelPlayerInfoInv(Inv) != None )
				{
					CoopTravelPlayerInfoInv(Inv).DecryptInfo(CoopSave_PlayersLootTravelInfo[i].EquipmentAmmo);
					CoopPostalDude(SavingPlayer).CheckPlayerInfoInv(CoopTravelPlayerInfoInv(Inv));
				}
				else SetupLoadedInventoryFor(SavingPlayer, Inv, float(CoopSave_PlayersLootTravelInfo[i].EquipmentAmmo));
			}
		}
	}

	return true;
}

function EraseTravelInfo()
{
	///CoopSave_PlayersLootTravelInfo.Length = 0;
	///steam 15/01/2017 arrays usage fixed
	if( CoopSave_PlayersLootTravelInfo.Length > 0 )
	{
		CoopSave_PlayersLootTravelInfo.Remove(0,CoopSave_PlayersLootTravelInfo.Length);
		CoopSave_PlayersLootTravelInfo.Length = 0;
	}
	if( CoopSave_PlayersLootHoldInfo.Length > 0 )
	{
		CoopSave_PlayersLootHoldInfo.Remove(0,CoopSave_PlayersLootHoldInfo.Length);
		CoopSave_PlayersLootHoldInfo.Length = 0;
	}
	SaveConfig();

	log(self @ "EraseTravelInfo() Success");
}

///steam update diff flags 22/04/2016
function Load_DiffChanged(int myGameDifficulty, int myGameDifficultyNumber)
{
	local bool bDiffUpdate, bLieberMode, bHestonMode, bTheyHateMeMode, bInsaneoMode, bExpertMode;

	ConsoleCommand("set" @ c_strDifficultyPath @ myGameDifficulty);
	ConsoleCommand("set" @ c_strDifficultyNumberPath @ myGameDifficultyNumber);

	if( myGameDifficultyNumber == 0 )
	{
		bLieberMode = true;
		bDiffUpdate = true;
	}
	else if( myGameDifficultyNumber >= 1 && myGameDifficultyNumber <= 9 )
	{
		bDiffUpdate = true;
	}
	else if( myGameDifficultyNumber == 10 )
	{
		bHestonMode = true;
		bDiffUpdate = true;
	}
	else if( myGameDifficultyNumber == 11 )
	{
		bInsaneoMode = true;
		bDiffUpdate = true;
	}
	else if( myGameDifficultyNumber == 12 )
	{
		bTheyHateMeMode = true;
		bDiffUpdate = true;
	}
	else if( myGameDifficultyNumber == 13 )
	{
		bHestonMode = true;
		bTheyHateMeMode = true;
		bExpertMode = true;
		bDiffUpdate = true;
	}
	// Impossible Mode - turns on Insaneo, They Hate Me, and Expert
	else if( myGameDifficultyNumber == 14 )
	{
		bInsaneoMode = true;
		bTheyHateMeMode = true;
		bExpertMode = true;
		bDiffUpdate = true;
	}

	if( bDiffUpdate )
	{
		ConsoleCommand("set" @ LieberPath @ bLieberMode);
		ConsoleCommand("set" @ HestonPath @ bHestonMode);
		ConsoleCommand("set" @ TheyHateMePath @ bTheyHateMeMode);
		ConsoleCommand("set" @ InsaneoPath @ bInsaneoMode);
		ConsoleCommand("set" @ ExpertPath @ bExpertMode);
		ConsoleCommand("set" @ CustomPath @ "false");
		ConsoleCommand("set" @ LudicrousPath @ "false");
	}

	if( myCoopGameInfo != None )
		myCoopGameInfo.SetupDifficultyOnce();
}

///steam 01/08/2017
function bool IsCoopSavedBefore()
{
	return (CoopSave_CompletedErrands.Length != 0 || CoopSave_ActivatedErrands.Length != 0 || CoopSave_RevealedErrands.Length != 0);
}

static function string GetServerNextMap()
{
	return default.CoopSave_ServerNextLevel;
}

function int GetDateDays()
{
	local vector vDateNow;
	vDateNow = Level.GetMillisecondsNow();
	return vDateNow.X;
}

///steam 03/08/2017 - loot hold system
function string UpdatePlayerHoldInfoFor(string sPlayerID, string sSystemID)
{
	local int i;
	local bool bFoundHoldEntry;

	bFoundHoldEntry = false;
	for( i = 0 ; i < CoopSave_PlayersLootHoldInfo.Length ; i++ )
	{
		if( CoopSave_PlayersLootHoldInfo[i].PlayerID == sPlayerID
			&& CoopSave_PlayersLootHoldInfo[i].SystemID == sSystemID )
		{
			//CoopSave_PlayersLootHoldInfo[i].HoldStatus = 1;
			if( CoopSave_PlayersLootHoldInfo[i].SaveDate != -1 ) ///steam 18/04/2018 - nonded ulimit saves
				CoopSave_PlayersLootHoldInfo[i].SaveDate = GetDateDays();

			bFoundHoldEntry = true;
			break;
		}
	}

	if( !bFoundHoldEntry )
	{
		i = CoopSave_PlayersLootHoldInfo.Length;
		CoopSave_PlayersLootHoldInfo.Insert(i, 1.0);
		CoopSave_PlayersLootHoldInfo[i].PlayerID = sPlayerID;
		CoopSave_PlayersLootHoldInfo[i].SystemID = sSystemID;
		CoopSave_PlayersLootHoldInfo[i].SaveID = CoopGameInfo(Level.Game).InitSaveEntryID();
		//CoopSave_PlayersLootHoldInfo[i].HoldStatus = 1;
		CoopSave_PlayersLootHoldInfo[i].SaveCycle = 0;
		CoopSave_PlayersLootHoldInfo[i].SaveDate = GetDateDays();

		///steam 18/04/2018 - nonded unlimit saves
		if( myCoopGameInfo != None && myCoopGameInfo.bNonDedicatedAutoSave )
			CoopSave_PlayersLootHoldInfo[i].SaveDate = -1;
	}
	return CoopSave_PlayersLootHoldInfo[i].SaveID;
}

///steam 03/08/2017 - loot hold system
function int FindPlayerHoldInfoEntry(MpPawn SavingPlayer)
{
	local int i;
	local CoopPlayerController PC;
	local string sPlayerID;
	local string sSystemID;

	if( SavingPlayer != None )
		PC = CoopPlayerController(SavingPlayer.Controller);

	if( PC != None && PC.PlayerReplicationInfo != None )
	{
		GetPlayerID(PC, sPlayerID, sSystemID);
		if( sPlayerID == "" || sSystemID == "" )
			return -1;
		for( i = 0 ; i < CoopSave_PlayersLootHoldInfo.Length ; i++ )
		{
			if( CoopSave_PlayersLootHoldInfo[i].PlayerID == sPlayerID 
				&& CoopSave_PlayersLootHoldInfo[i].SystemID == sSystemID )
				return i;
		}
	}
	return -1;
}

///steam 03/08/2017 - loot hold system
function PostTravel_UpdatePlayerTravelInfoFor(MpPawn SavingPlayer, optional bool bForceLoadLoot)
{
	local int i;
	local string sTravelCheckSum;

	i = FindPlayerHoldInfoEntry(SavingPlayer);
	if( i >= 0 )
	{
		sTravelCheckSum = CoopPostalDude(SavingPlayer).GetCoopTravelCheckSum();
		if( sTravelCheckSum != "1" || bForceLoadLoot )
		{
			SavingPlayer.ClientMessage("Player save loaded");
			LoadPlayerTravelInfo(SavingPlayer);
		}
		RemovePlayerLootTravelInfoBySaveID(CoopSave_PlayersLootHoldInfo[i].SaveID);

		// UPD 21/04/2018 - coop transfer items
		if( TransferItems.Length > 0 )
			RemoveTransferItems(SavingPlayer, CoopSave_PlayersLootHoldInfo[i].SaveID);
	}
	SavePlayerTravelInfo(SavingPlayer);

	SaveConfig();

	log(self @ "PostTravel_UpdatePlayerTravelInfoFor() for" @ SavingPlayer @ "found entry" @ i);

///	Destroy();
}

///steam 03/08/2017 - loot hold system
function RemovePlayerLootTravelInfoBySaveID(string sSaveID)
{
	local int i;

	if( sSaveID == "" )
		return;

	for( i = 0 ; i < CoopSave_PlayersLootTravelInfo.Length ; i++ )
	{
		if( CoopSave_PlayersLootTravelInfo[i].SaveID == sSaveID )
		{
			CoopSave_PlayersLootTravelInfo.Remove(i, 1);
			i--;
		}
	}
}

///steam 03/08/2017 - loot hold system
function PreTravel_RefreshPlayerHoldInfo()
{
	local int i;
	local Controller aCon;
	local CoopPlayerController PC;
	local string sUsePlayerID, sUseSystemID;
	local string sPlayerID, sSystemID;
	local bool bFoundPlayer;
	local bool bRemove;
	local bool bRemoveByCycles;
	local int RealDate;

	RealDate = GetDateDays();
	for( i = 0 ; i < CoopSave_PlayersLootHoldInfo.Length ; i++ )
	{
		bFoundPlayer = false;
		bRemove = false;
		bRemoveByCycles = false;
		sPlayerID = CoopSave_PlayersLootHoldInfo[i].PlayerID;
		sSystemID = CoopSave_PlayersLootHoldInfo[i].SystemID;
		for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
		{
			PC = CoopPlayerController(aCon);
			if( PC != None 
				&& !PC.IsCoopDedicatedHost() 
				&& PC.PlayerReplicationInfo != None )
			{
				GetPlayerID(PC, sUsePlayerID, sUseSystemID);
				if( sUsePlayerID != "" && sUsePlayerID == sPlayerID 
					&& sUseSystemID != "" && sUseSystemID == sSystemID )
				{
					bFoundPlayer = true;
					break;
				}
			}
		}

		if( !bFoundPlayer )
		{
			if( CoopSave_PlayersLootHoldInfo[i].SaveDate != -1 ) ///steam 18/04/2018 - nonded unlimit saves
			{
			if( CoopInfo_HoldSaveSaveCyclesDays > 0 && CoopInfo_HoldSaveSaveCyclesMin > 0 )
			{
				if( (RealDate-CoopSave_PlayersLootHoldInfo[i].SaveDate) > CoopInfo_HoldSaveSaveCyclesDays 
					&& CoopSave_PlayersLootHoldInfo[i].SaveCycle < CoopInfo_HoldSaveSaveCyclesMin )
					bRemoveByCycles = true;
			}

			if( !bRemoveByCycles && CoopInfo_HoldSaveDateLimit > 0 )
			{
				if( (RealDate-CoopSave_PlayersLootHoldInfo[i].SaveDate) > CoopInfo_HoldSaveDateLimit )
					bRemove = true;
			}
			}

			if( bRemove || bRemoveByCycles )
			{
				RemovePlayerLootTravelInfoBySaveID(CoopSave_PlayersLootHoldInfo[i].SaveID);

				///steam 20/04/2018 - hold stats for longer period
				if( bRemoveByCycles 
					|| (CoopInfo_HoldStatsSaveDateLimit > 0 
						&& (RealDate-CoopSave_PlayersLootHoldInfo[i].SaveDate) > CoopInfo_HoldStatsSaveDateLimit) )
				{
					CoopSave_PlayersLootHoldInfo.Remove(i, 1);
					i--;
				}
			}
		}
		else
		{
			CoopSave_PlayersLootHoldInfo[i].SaveCycle = FMin(CoopSave_PlayersLootHoldInfo[i].SaveCycle+1,100);
		}
	}

	SaveConfig();

	log(self @ "PreTravel_RefreshPlayerHoldInfo() Success");

///	Destroy();
}

// FIX 18/04/2018 - allows to fix diff while continue game
function PressContinue_DiffChanged()
{
	Load_DiffChanged(CoopSave_GameDifficulty, CoopSave_GameDifficultyNumber);
}

function xResetGameProgress_RemoveLoot()
{
	local int i;
	local controller aCon;
	local CoopPlayerController PC;
	local MpPawn SavingPawn;

	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
	{
		PC = CoopPlayerController(aCon);
		if( PC != None && PC.Pawn != None && !PC.IsCoopDedicatedHost() )
		{
			SavingPawn = MpPawn(PC.Pawn);

			///steam 21/07/2016 hack to save in vehicles
			if( PC.GetNPVehicleOwnedBy(PC.Pawn) != None && PC.FirstPossessedPawn != None )
			{
				PC.ClientMessage("SAVING YOUR DATA FAILED: Please leave vehicle and save again!");
				SavingPawn = MpPawn(PC.FirstPossessedPawn);
			}

			if( SavingPawn != None )
			{
				i = FindPlayerHoldInfoEntry(SavingPawn);
				if( i >= 0 )
				{
					if( CoopPostalDude(SavingPawn) != None )
						CoopPostalDude(SavingPawn).ResetCoopTravelCheckSum();
					RemovePlayerLootTravelInfoBySaveID(CoopSave_PlayersLootHoldInfo[i].SaveID);
				}
			}
		}
	}

	SaveConfig();

	log(self @ "xResetGameProgress_RemoveLoot() CoopSave_PlayersLootTravelInfo length:" @ CoopSave_PlayersLootTravelInfo.Length);

///	Destroy();
}

// UPD 21/04/2018 - coop transfer items
function xRegisterTransferItem(class<Inventory> aItemClass, bool bDestroyAfterTransfer, float UseItemAmount)
{
	local int i;
	i = TransferItems.Length;
	TransferItems.Insert(i, 1);
	TransferItems[i].ItemClass = aItemClass;
	TransferItems[i].bDestroyAfterTransfer = bDestroyAfterTransfer;
	TransferItems[i].ItemAmount = UseItemAmount;
}

function RemoveTransferItems(MpPawn aPawn, string sSaveID)
{
	local int i;
	local Inventory aInv;
	local int AmmoCount, NumB;

	if( aPawn.Controller == None 
		|| aPawn.Controller.Buoyancy == 75 )
		return;

	for( i = 0; i < TransferItemsFound.Length; i++ )
	{
		if( TransferItemsFound[i] ~= sSaveID )
			return;
	}

	for( i = 0; i < TransferItemsCache.Length; i++ )
	{
		if( TransferItemsCache[i].SaveID ~= sSaveID )
			return;
	}

	for( i = 0; i < TransferItems.Length; i++ )
	{
		aInv = aPawn.FindInventoryType(TransferItems[i].ItemClass);
		if( aInv != None && (aInv.IsA('P2PowerupInv') || aInv.IsA('P2Weapon')) )
		{
			if( !TransferItems[i].bDestroyAfterTransfer )
			{
				if( Weapon(aInv) != None && Weapon(aInv).AmmoType != None )
				{
					AmmoCount = Weapon(aInv).AmmoType.AmmoAmount;
					Weapon(aInv).AmmoType.AmmoAmount = 0; // fix old ammo amount after removing
				}
				else if( P2PowerupInv(aInv) != None )
				{
					AmmoCount = P2PowerupInv(aInv).Amount;
				}

				NumB = TransferItemsCache.Length;
				TransferItemsCache.Insert(NumB, 1.0);
				TransferItemsCache[NumB].SaveID = sSaveID;
				TransferItemsCache[NumB].EquipmentClass = string(aInv.class);
				TransferItemsCache[NumB].EquipmentAmmo = string(AmmoCount);
			}

			/*if( aInv.IsA('P2PowerupInv') )
				P2PowerupInv(aInv).ReduceAmount(P2PowerupInv(aInv).Amount);
			else */if( !aInv.bDeleteMe )
				aInv.Destroy();
		}
	}
}

function bool RecoverTransferItems(MpPawn aPawn)
{
	local int i, j;
	local string sSaveID;
	local Inventory Inv;

	if( aPawn.Controller == None 
		|| aPawn.Controller.Buoyancy == 75 )
		return false;

	j = FindPlayerHoldInfoEntry(aPawn);
	if( j < 0 )
		return false;
	sSaveID = CoopSave_PlayersLootHoldInfo[j].SaveID;

	for( i = 0; i < TransferItemsFound.Length; i++ )
	{
		if( TransferItemsFound[i] ~= sSaveID )
			return false;
	}

	for( i = 0 ; i < TransferItemsCache.Length ; i++ )
	{
		if( TransferItemsCache[i].SaveID == sSaveID )
		{
			Inv = PersonPawn(aPawn).CreateInventory(TransferItemsCache[i].EquipmentClass);
			if( Inv != None )
				SetupLoadedInventoryFor(aPawn, Inv, float(TransferItemsCache[i].EquipmentAmmo), true);
			TransferItemsCache.Remove(i, 1);
			i--;
		}
	}
	i = TransferItemsFound.Length;
	TransferItemsFound.Insert(i, 1.0);
	TransferItemsFound[i] = sSaveID;

	RemovePlayerLootTravelInfoBySaveID(sSaveID);
	SavePlayerTravelInfo(aPawn);

	SaveConfig();
	return true;
}

function SaveTransferItemsCache()
{
	local int i;
	local CoopPlayerController UsePC;
	local MpPawn UsePawn;
	local Inventory Inv;
	local int NumB;

	if( TransferItems.Length == 0 )
		return;

	if( CoopGameInfo(Level.Game) != None )
		UsePC = CoopPlayerController(CoopGameInfo(Level.Game).GetPlayer());
	if( UsePC != None 
		&& MpPawn(UsePC.Pawn) != None 
		&& UsePC.Buoyancy == 75 
		&& !UsePC.IsCoopDedicatedHost() )
	{
		UsePawn = MpPawn(UsePC.Pawn);
		for( i = 0; i < TransferItems.Length; i++ )
		{
			if( TransferItems[i].ItemAmount <= 0 )
				continue;
			Inv = PersonPawn(UsePawn).CreateInventoryByClass(TransferItems[i].ItemClass);
			if( Inv != None )
				SetupLoadedInventoryFor(UsePawn, Inv, TransferItems[i].ItemAmount);
		}
	}

	if( TransferItemsCache.Length == 0 )
		return;

	for( i = 0; i < TransferItemsCache.Length; i++ )
	{
		NumB = CoopSave_PlayersLootTravelInfo.Length;
		CoopSave_PlayersLootTravelInfo.Insert(NumB, 1.0);
		CoopSave_PlayersLootTravelInfo[NumB].SaveID = TransferItemsCache[i].SaveID;
		CoopSave_PlayersLootTravelInfo[NumB].EquipmentClass = TransferItemsCache[i].EquipmentClass;
		CoopSave_PlayersLootTravelInfo[NumB].EquipmentAmmo = TransferItemsCache[i].EquipmentAmmo;
	}

	SaveConfig();
}

defaultproperties
{
	CoopInfo_HoldSaveSaveCyclesDays=5
	CoopInfo_HoldSaveSaveCyclesMin=5

	CoopInfo_ItemsSaveNumMax=100
	CoopInfo_HoldSaveDateLimit=15
	CoopInfo_HoldStatsSaveDateLimit=30

	bHidden=true
}