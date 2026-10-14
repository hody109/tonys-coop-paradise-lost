//=============================================================================
// CoopMenu.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2014-2017.
//=============================================================================

class CoopMenu extends ShellMenuCW
	config;

var class<GameInfo> ServerGameType;
var string ServerMutators;
var string ServerMap;

var localized string	TitleText;

var ShellMenuChoice		JoinChoice;

var ShellMenuChoice		FAQChoice;
var CoopBrowserFAQWindow FAQBrowserWindow;

var ShellMenuChoice		HostChoice;
var localized string	HostText;
var localized string	HostHelp;

var ShellMenuChoice		PlayerChoice;
var localized string	PlayerSetupText;
var localized string	PlayerSetupHelp;

var config string	MultiPlayerName;
var config string	MultiPlayerHostName;
var string			MultiPlayerClass;

///steam 04/11/2016
var config string	MultiPlayerSkinType;

///steam 19/11/2016
var string 			CoopMenuGameInfoClass;

///steam 04/01/2017
var bool bUseStoryCombo;
var string NCBrowserHostWindowClass;
var string NCBrowserPlayerMenuWindowClass;
var string NCBrowserOpenMenuWindowClass;
var string NCBrowserJoinWindowClass;

///steam 07/01/2017
var UBrowserMainWindow JoinBrowserWindow;

///steam 06/02/2017
var string NicksCoopBuildString;
var string NicksCoopAddonBuildString;

///steam 26/06/2017
var bool bUseLoadIntroCheckbox;
var bool bUseNoHolidaysCheckbox;
var bool bUseDedicatedCheckbox;

var string DefWorkshopGameINIPath;

var bool bUpdate;

function CreateMenuContents()
{
	Super.CreateMenuContents();

	bUpdate = false;

	TitleAlign = TA_Left;
	ItemAlign = TA_Left;

	AddTitle(TitleText, TitleFont, TitleAlign);

	ItemFont = F_FancyL;

	PlayerChoice	= AddChoice		(PlayerSetupText,	PlayerSetupHelp,	ItemFont, ItemAlign);
	JoinChoice		= AddChoice		(JoinText,			JoinHelp,			ItemFont, ItemAlign);
	HostChoice		= AddChoice		(HostText,			HostHelp,			ItemFont, ItemAlign);

//	FAQChoice		= AddChoice		("FAQ",			"",			ItemFont, ItemAlign);

	BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	// Set Multiplayer Options
	ShellRootWindow(Root).bLaunchedMultiplayer = true;

	bUpdate = true;
}

///////////////////////////////////////////////////////////////////////////////
// Handle notifications from controls
///////////////////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
	local class<CoopBrowserHostWindow> BrowserHostWindow;
	local class<CoopBrowserPlayerMenuWindow> BrowserPlayerMenuWindow;
	local class<CoopBrowserOpenWindow> BrowserOpenMenuWindow;
	local class<CoopBrowserJoinWindow> BrowserJoinMenuWindow;

	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case JoinChoice:
					///
					MultiPlayerClass = ServerGameType.default.DefaultPlayerClassName;
					GetPlayerOwner().PlayerReplicationInfo.SetPlayerName(MultiPlayerName);
					GetPlayerOwner().UpdateURL("Name", MultiPlayerName, True);
					GetPlayerOwner().UpdateURL("Class", MultiPlayerClass, True);
					GetPlayerOwner().UpdateURL("Team", GetPlayerOwner().GetDefaultURL("Team"), True);
					///
					/*BrowserOpenMenuWindow = class<CoopBrowserOpenWindow>(DynamicLoadObject(NCBrowserOpenMenuWindowClass, class'Class'));//"NicksCoop.CoopBrowserOpenWindow"
					GotoWindow(Root.CreateWindow(BrowserOpenMenuWindow, 300, 80, 100, 100, Self, True));*/
					//Root.ShowModal(Root.CreateWindow(BrowserOpenMenuWindow, 300, 80, 100, 100, self));
					BrowserJoinMenuWindow = class<CoopBrowserJoinWindow>(DynamicLoadObject(NCBrowserJoinWindowClass, class'Class'));
					JoinBrowserWindow = UBrowserMainWindow(Root.CreateWindow(BrowserJoinMenuWindow, 50, 30, 500, 300));
					JoinBrowserWindow.SelectInternet();
					GotoWindow(JoinBrowserWindow);
					break;
				case HostChoice:
					///
					MultiPlayerClass = ServerGameType.default.DefaultPlayerClassName;
					GetPlayerOwner().PlayerReplicationInfo.SetPlayerName(MultiPlayerHostName);
					GetPlayerOwner().UpdateURL("Name", MultiPlayerHostName, True);
					GetPlayerOwner().UpdateURL("Class", MultiPlayerClass, True);
					GetPlayerOwner().UpdateURL("Team", GetPlayerOwner().GetDefaultURL("Team"), True);
					///
					BrowserHostWindow = class<CoopBrowserHostWindow>(DynamicLoadObject(NCBrowserHostWindowClass, class'Class'));//"NicksCoop.CoopBrowserHostWindow"
					GotoWindow(Root.CreateWindow(BrowserHostWindow, 100, 100, 200, 200, Self, True));
					//Root.ShowModal(Root.CreateWindow(BrowserHostWindow, 100, 100, 200, 200, self));
					break;
				case FAQChoice:
					FAQBrowserWindow = CoopBrowserFAQWindow(Root.CreateWindow(class'CoopBrowserFAQWindow', 50, 30, 500, 300));
					FAQBrowserWindow.SelectFAQPage();
					GotoWindow(FAQBrowserWindow);
					break;
				case PlayerChoice:
					BrowserPlayerMenuWindow = class<CoopBrowserPlayerMenuWindow>(DynamicLoadObject(NCBrowserPlayerMenuWindowClass, class'Class'));//"NicksCoop.CoopBrowserPlayerMenuWindow"
					GotoWindow(Root.CreateWindow(BrowserPlayerMenuWindow, 100, 100, 200, 200, Self, True));
					//Root.ShowModal(Root.CreateWindow(BrowserPlayerMenuWindow, 100, 100, 200, 200, self));
					break;
				}
			break;
		}
}

///obsoleted game starting
function StartGame()
{
	local string URL;
	local string LanPlay;
	local string AdminPW;

	URL = ServerMap $ "?Game="$ServerGameType$"?Mutator="$ServerMutators;

	if(AdminPW != "")
		URL = URL $ "?AdminPassword="$AdminPW;
	URL = URL $ "?Listen";

	Root.SetLoadingTexture(ServerMap);

	ParentWindow.Close();
	P2RootWindow(Root).HideMenu();
	GetPlayerOwner().ClientTravel(URL$LanPlay, TRAVEL_Absolute, false);
}

///steam 09/02/2017 fixed glitchy close when you're typing
function execBackButton()
{
	if( ShellRootWindow(Root).OpenWindow != None )
		return;
	Super.execBackButton();
}

defaultproperties
{
	DefWorkshopGameINIPath="..\\WorkshopContent\\737631813\\Postal2CoOp.ini"

	bUseDedicatedCheckbox=true
	bUseLoadIntroCheckbox=true
	bUseNoHolidaysCheckbox=true

	NicksCoopBuildString="NicksCoop v1.4.3"

	NCBrowserJoinWindowClass="NicksCoop.CoopBrowserJoinWindow"

	NCBrowserHostWindowClass="NicksCoop.CoopBrowserHostWindow"
	NCBrowserPlayerMenuWindowClass="NicksCoop.CoopBrowserPlayerMenuWindow"
	NCBrowserOpenMenuWindowClass="NicksCoop.CoopBrowserOpenWindow"
	bUseStoryCombo=true

	CoopMenuGameInfoClass="NicksCoop.CoopGameInfoMenu"

     TitleText="Co-Op Game"
     MenuWidth=375.000000
     MenuHeight=325.000000
     TitleSpacingY=30.000000
     ItemSpacingY=8.000000

	 ServerGameType=Class'NicksCoop.CoopGameInfo'
	 ServerMap="suburbs-3.fuk"
	 ServerMutators=""

	 PlayerSetupText="Player setup"
	 PlayerSetupHelp="Name, skin, connection type."

     HostText="Host Game"
     HostHelp="Start a multiplayer game that other players can join"
     MultiPlayerName="Evil"
	 MultiPlayerHostName="Player"
     MultiPlayerClass="People.PostalDude"
     //MenuWidth=350.000000
     HintLines=4
     astrTextureDetailNames(0)="UltraLow"
     astrTextureDetailNames(1)="Low"
     astrTextureDetailNames(2)="Medium"
     astrTextureDetailNames(3)="High"
}
