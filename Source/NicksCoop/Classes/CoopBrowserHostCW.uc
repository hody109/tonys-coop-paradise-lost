//=============================================================================
// CoopBrowserHostCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserHostCW extends UTMenuBotmatchCW;

const SavedGameTime = "NicksCoop.CoopSaveSystem CoopSave_TimeElapsed";

var UWindowMessageBox NewGameWarningBox;
var localized string NewGameWarningTitle;
var localized string NewGameWarningText;

var localized string NoSaveWarningTitle;
var localized string NoSaveWarningText;

var localized string ServerText;

var config bool bServerLoadIntro;
var config bool bServerCoopDedicated;
var config bool bWorkshopLoad;

var UWindowPageControlPage ServerTab;

function CreatePages()
{
	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(true);
	ServerTab = Pages.AddPage(ServerText, class'CoopBrowserHostSetupSC');
}

function Created()
{
	local float UseGameTime;
	Super.Created();

	CloseButton.SetFont(F_SmallBold);
	StartButton.SetFont(F_SmallBold);

	UseGameTime = float(GetPlayerOwner().ConsoleCommand("get"@SavedGameTime));
	if (UseGameTime <= 0)
		StartButton.bDisabled = true;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	CloseButton.SetSize(68, 16);
	CloseButton.WinLeft = WinWidth-72;

	StartButton.SetSize(64, 16);
	StartButton.WinLeft = WinWidth-142;
}

function Notify(UWindowDialogControl C, byte E)
{
	local class<MapList> ML;

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
			case StartButton:
				//UTMenuStartMatchCW(UTMenuStartMatchSC(StartTab.Page).ClientArea).MapWindow.SaveConfigs();
				//UTServerSetupPage(UTServerSetupSC(ServerTab.Page).ClientArea).bDedicated
				StartPressed();
				return;
			case CloseButton:
				StartNewPressed();
				break;
			default:
				Super(UWindowDialogClientWindow).Notify(C, E);
				return;
		}
	default:
		Super(UWindowDialogClientWindow).Notify(C, E);
		return;
	}
}

/*function Close(optional bool bByParent) 
{
	///steam 17/03/2016
	///if(Root != None)
	///	Root.GoBack();

	Super.Close(bByParent);
}*/

///steam 10/04/2016
function Close(optional bool bByParent) 
{
	if(Root != None)
		Root.GoBack();

	Super(UWindowDialogClientWindow).Close(bByParent);
}

function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
	if(W == NewGameWarningBox && Result == MR_Yes)
	{
		CoopStartGame(false);
	}
}

function StartPressed()
{
	if (!StartButton.bDisabled)
		CoopStartGame(true);
	else MessageBox(NoSaveWarningTitle, NoSaveWarningText, MB_OK, MR_OK, MR_OK);
}

function StartNewPressed()
{
	local float UseGameTime;

	UseGameTime = float(GetPlayerOwner().ConsoleCommand("get"@SavedGameTime));
	if (UseGameTime > 0)
	{
		NewGameWarningBox = MessageBox(NewGameWarningTitle, NewGameWarningText, MB_YesNo, MR_No);
	}
	else CoopStartGame(false);
}

// bAutoSaveContinue:
// TRUE - continue game
// FALSE - new game
function CoopStartGame(optional bool bAutoSaveContinue)
{
	local string URL;
	local string LanPlay;
	local string AdminPW;
	local string ServerMap;
	local string ServerMutators;
	local class<CoopGameInfo> ServerGameType;
	local class<CoopMenu> CoopMenuClass;
	local class<CoopSaveSystem> CoopSaveClass;
	local CoopSaveSystem aCoopSaveSystem;

	///steam 03/03/2017 dedicated test
	if( bServerCoopDedicated )
	{
		CoopStartGame_Dedicated(bAutoSaveContinue);
		return;
	}

	CoopMenuClass = CoopShellRootWindow(Root).CoopMenuClass;
	if( CoopMenuClass == None )
		CoopMenuClass = class'CoopMenu';
	ServerGameType = class<CoopGameInfo>(CoopMenuClass.default.ServerGameType);
	CoopSaveClass = ServerGameType.default.CoopSaveSystemClass;
	if( CoopSaveClass != None && Root.ViewportOwner.Actor != None )
		aCoopSaveSystem = Root.ViewportOwner.Actor.spawn(CoopSaveClass);

	///NonDedicatedAutoSave 22/01/2018 - 18/04/2018
	if( !bAutoSaveContinue ) // NEW GAME
	{
		// reset any saves we did before
		if( aCoopSaveSystem != None )
			aCoopSaveSystem.EraseTravelInfo();
		ServerGameType.static.AutoSave_SetFirstRun(true);
	}
	else // CONTINUE
	{
		if( aCoopSaveSystem != None && aCoopSaveSystem.IsCoopSavedBefore() )
			aCoopSaveSystem.PressContinue_DiffChanged();
		if( CoopSaveClass != None )
			ServerMap = CoopSaveClass.static.GetServerNextMap();
	}

	if( ServerMap == "" || ServerMap == "None ")
	{
		ServerGameType.static.CoopSetTravelPortalName("");
		ServerMap = ServerGameType.static.CoopGetFirstMap();
	}
	if( ServerMap == "" || ServerMap == "None ")
		ServerMap = CoopMenuClass.default.ServerMap;

	URL = ServerMap $ "?Game="$ServerGameType$"?Mutator="$ServerMutators;

	AdminPW = class'UMenuBotmatchClientWindow'.default.AdminPassword;
	if(AdminPW != "")
		URL = URL $ "?AdminPassword="$AdminPW;
	URL = URL $ "?Listen";

	ParentWindow.Close();
	P2RootWindow(Root).HideMenu();
	log("CoopStartGame"@URL);
	GetPlayerOwner().ClientTravel(URL$LanPlay, TRAVEL_Absolute, false);
}

///steam 03/03/2017 dedicated test
function CoopStartGame_Dedicated(optional bool bAutoSaveContinue)
{
	local string URL, ServerMap, MutatorList;
	local string AdminPW;
	local string LanPlay;
	local class<CoopGameInfo> ServerGameType;
	local class<CoopMenu> CoopMenuClass;
	local string sGameINIPath;
	local int n;
	local class<CoopSaveSystem> CoopSaveClass;
	local CoopSaveSystem aCoopSaveSystem;

	CoopMenuClass = CoopShellRootWindow(Root).CoopMenuClass;
	if( CoopMenuClass == None )
		CoopMenuClass = class'CoopMenu';
	ServerGameType = class<CoopGameInfo>(CoopMenuClass.default.ServerGameType);
	CoopSaveClass = ServerGameType.default.CoopSaveSystemClass;
	if( CoopSaveClass != None && Root.ViewportOwner.Actor != None )
		aCoopSaveSystem = Root.ViewportOwner.Actor.spawn(CoopSaveClass);

	// UPD 21/04/2018 - fix continue and new
	if( !bAutoSaveContinue ) // NEW GAME
	{
		// reset any saves we did before
		ServerGameType.static.AutoSave_SetFirstRun(true);
		ServerGameType.static.CoopSetTravelPortalName("");
	}
	else // CONTINUE
	{
		if( aCoopSaveSystem != None && aCoopSaveSystem.IsCoopSavedBefore() )
			aCoopSaveSystem.PressContinue_DiffChanged();
	}

	ServerMap = ServerGameType.default.CoopServerMapLoader;
	if( ServerMap == "" || ServerMap == "None ")
		ServerMap = CoopMenuClass.default.ServerMap;

	URL = ServerMap $ "?Game="$ServerGameType$"?Mutator="$MutatorList;

	AdminPW = class'UMenuBotmatchClientWindow'.default.AdminPassword;
	if( AdminPW != "" )
		URL = URL $ "?AdminPassword="$AdminPW;

	ParentWindow.Close();
	if( bWorkshopLoad )
	{
		sGameINIPath = CoopMenuClass.default.DefWorkshopGameINIPath;
		n = FileSize(sGameINIPath);
		if( n > -1 )
			GetPlayerOwner().ConsoleCommand("RELAUNCH "$URL$LanPlay$" -INI="$sGameINIPath$" -server -log=Server.log");
	}
	else GetPlayerOwner().ConsoleCommand("RELAUNCH "$URL$LanPlay$" -server -log=Server.log");
}

defaultproperties
{
	NoSaveWarningTitle="Warning"
	NoSaveWarningText="No previously saved game detected. Press New game instead."

	NewGameWarningTitle="Confirmation"
	NewGameWarningText="Are you sure? The previously saved game will be deleted."

	StartText="Continue"
	BackText="New game"

	ServerText="Server"
	bNetworkGame=True
}
