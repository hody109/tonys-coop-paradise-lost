//=============================================================================
// CoopPLSaveSystem.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLSaveSystem extends CoopSaveSystem;

var globalconfig bool CoopSave_bKennelHack;
var globalconfig bool CoopSave_bWiseWangHack;
var globalconfig int CoopSave_SavedPriceBoard;
var globalconfig bool CoopSave_bFunzerking;
var globalconfig int CoopSave_CockAsianKills;
var globalconfig int CoopSave_PUKills;
var globalconfig int CoopSave_FarciiKills;
var globalconfig int CoopSave_RobotKills;
var globalconfig int CoopSave_BanditKills;
var globalconfig int CoopSave_SurvivalistKills;
var globalconfig int CoopSave_AnimalKills;
var globalconfig int CoopSave_MoneySpentOnVendors;
var globalconfig int CoopSave_SnowmenPeedOn;
var globalconfig int CoopSave_NutShots;
var globalconfig int CoopSave_ErrandsPeaceful;
var globalconfig bool CoopSave_bSpecialEnding;
var globalconfig int CoopSave_ExecutionKills;
var globalconfig int CoopSave_MonkeysLost;

function CoopLoadGame(optional bool bServerAutoSave)
{
	local int i;
	local PLGameState myPLGameState;

	if( TheGameState == None )
	{
		if( Level.Game != None && CoopGameInfo(Level.Game) != None )
		{
			myCoopGameInfo = CoopGameInfo(Level.Game);
			TheGameState = CoopGameInfo(Level.Game).TheGameState;
		}
	}

	myPLGameState = PLGameState(TheGameState);
	if( myPLGameState != None )
	{
		myPLGameState.bKennelHack = CoopSave_bKennelHack;
		myPLGameState.bWiseWangHack = CoopSave_bWiseWangHack;
		myPLGameState.SavedPriceBoard = CoopSave_SavedPriceBoard;
		myPLGameState.bFunzerking = CoopSave_bFunzerking;
		myPLGameState.CockAsianKills = CoopSave_CockAsianKills;
		myPLGameState.PUKills = CoopSave_PUKills;
		myPLGameState.FarciiKills = CoopSave_FarciiKills;
		myPLGameState.RobotKills = CoopSave_RobotKills;
		myPLGameState.BanditKills = CoopSave_BanditKills;
		myPLGameState.SurvivalistKills = CoopSave_SurvivalistKills;
		myPLGameState.AnimalKills = CoopSave_AnimalKills;
		myPLGameState.MoneySpentOnVendors = CoopSave_MoneySpentOnVendors;
		myPLGameState.SnowmenPeedOn = CoopSave_SnowmenPeedOn;
		myPLGameState.NutShots = CoopSave_NutShots;
		myPLGameState.ErrandsPeaceful = CoopSave_ErrandsPeaceful;
		myPLGameState.bSpecialEnding = CoopSave_bSpecialEnding;
		myPLGameState.ExecutionKills = CoopSave_ExecutionKills;
		myPLGameState.MonkeysLost = CoopSave_MonkeysLost;
	}

	Super.CoopLoadGame(bServerAutoSave);
}

function CoopSaveGame(optional bool bServerAutoSave)
{
	local int i;
	local PLGameState myPLGameState;

	if( TheGameState == None )
	{
		if( Level.Game != None && CoopGameInfo(Level.Game) != None )
		{
			myCoopGameInfo = CoopGameInfo(Level.Game);
			TheGameState = CoopGameInfo(Level.Game).TheGameState;
		}
	}

	myPLGameState = PLGameState(TheGameState);
	if( myPLGameState != None )
	{
		CoopSave_bKennelHack = myPLGameState.bKennelHack;
		CoopSave_bWiseWangHack = myPLGameState.bWiseWangHack;
		CoopSave_SavedPriceBoard = myPLGameState.SavedPriceBoard;
		CoopSave_bFunzerking = myPLGameState.bFunzerking;
		CoopSave_CockAsianKills = myPLGameState.CockAsianKills;
		CoopSave_PUKills = myPLGameState.PUKills;
		CoopSave_FarciiKills = myPLGameState.FarciiKills;
		CoopSave_RobotKills = myPLGameState.RobotKills;
		CoopSave_BanditKills = myPLGameState.BanditKills;
		CoopSave_SurvivalistKills = myPLGameState.SurvivalistKills;
		CoopSave_AnimalKills = myPLGameState.AnimalKills;
		CoopSave_MoneySpentOnVendors = myPLGameState.MoneySpentOnVendors;
		CoopSave_SnowmenPeedOn = myPLGameState.SnowmenPeedOn;
		CoopSave_NutShots = myPLGameState.NutShots;
		CoopSave_ErrandsPeaceful = myPLGameState.ErrandsPeaceful;
		CoopSave_bSpecialEnding = myPLGameState.bSpecialEnding;
		CoopSave_ExecutionKills = myPLGameState.ExecutionKills;
		CoopSave_MonkeysLost = myPLGameState.MonkeysLost;
	}

	Super.CoopSaveGame(bServerAutoSave);
}

defaultproperties
{
}