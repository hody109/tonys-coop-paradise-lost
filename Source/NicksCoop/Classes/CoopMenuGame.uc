//=============================================================================
// CoopMenuGame.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopMenuGame extends BaseMenuBig;

var ShellMenuChoice		CoopPlayersChoice;
var localized string	CoopPlayersText;

var ShellMenuChoice		CoopTeleportChoice;
var localized string	CoopTeleportText;
var localized string	CoopTeleportHelp;
var localized string	CoopTeleportDisabledHelp;
var bool bCoopTeleportDisabled;

var ShellMenuChoice		CheatsChoice;
var localized string	CheatsText;
var localized string	CheatsHelp;

var localized string	DisabledForCinematicHelpText;
var localized string	DisabledNowText;

var ShellMenuChoice		ResumeChoice;
var localized string	ResumeText;

var ShellMenuChoice		JoinChoice;
var localized string	JoinAnotherText;

var ShellMenuChoice		PlayerChoice;

var ShellMenuChoice		AdminChoice;
var ShellMenuChoice		AdminLoginChoice;

var ShellMenuChoice		QuitChoice;
var localized string	QuitText;

///steam 20/03/2016
var ShellMenuChoice		LoadChoice;
var localized string	NotAdminHelp;

var ShellMenuChoice		SaveChoice;
var localized string	SaveText;

var ShellMenuChoice		SavePlayerChoice;
var localized string	SavePlayerText;
var localized string	SavePlayerHelpText;

var ShellMenuChoice		SpecSpectatorChoice;
var localized string	SpecSpectatorText;
var localized string	SpecSpectatorHelpText;

var ShellMenuChoice		RestartChoice;
var localized string	RestartText;

var ShellMenuChoice		ResetGameChoice;
var localized string	ResetGameText;
var localized string	ResetGameHelpText;

///steam 04/01/2017
var class<ShellMenuCW> NCAdminMenuClass;

///steam 15/01/2017
var UBrowserMainWindow JoinBrowserWindow;

/***
Show Players
Coop Teleport
Admin Menu
Save Game
Restart Level
Options
Quit Game
Resume Game
***/

///steam 18/08/2017 - the same as AddChoice, but class can be chosen
function ShellMenuChoice AddChoice_ByClass(class<ShellMenuChoice> useClass, String strText, String strHelp, int Font, TextAlign Align, optional bool bRespondToCancel)
{
	local ShellMenuChoice ctl;

	ctl = ShellMenuChoice(CreateControl(useClass,  GetNextItemPosX(), GetNextItemPosY(), ItemMaxWidth, ItemHeight));
	ctl.SetFont(Font);
	ctl.SetTextColor(ShellLookAndFeel(LookAndFeel).NormalTextColor);
	ctl.SetText(strText);
	ctl.SetHelpText(strHelp);
	ctl.Align = Align;
	ctl.bCancel = bRespondToCancel;
	AddItem(ctl, ItemHeight + ItemSpacingY);
	return ctl;
}

function UpdateCoopTeleportChoice()
{
	if( bCoopTeleportDisabled )
	{
		CoopTeleportChoice.SetHelpText(CoopTeleportDisabledHelp);
		if( HintItem != None && HintItem.Text ~= CoopTeleportHelp )
			HintItem.SetText(CoopTeleportDisabledHelp);
	}
	else
	{
		CoopTeleportChoice.SetHelpText(CoopTeleportHelp);
		if( HintItem != None && HintItem.Text ~= CoopTeleportDisabledHelp )
			HintItem.SetText(CoopTeleportHelp);
	}
}

function xJoinChoicePressed()
{
	local class<CoopMenu> CoopMenuClass;
	local class<CoopBrowserJoinWindow> BrowserJoinMenuWindow;

	CoopMenuClass = CoopShellRootWindow(Root).CoopMenuClass;

	if( CoopMenuClass == None )
		CoopMenuClass = class'CoopMenu';

	BrowserJoinMenuWindow = class<CoopBrowserJoinWindow>(DynamicLoadObject(CoopMenuClass.default.NCBrowserJoinWindowClass, class'Class'));
	JoinBrowserWindow = UBrowserMainWindow(Root.CreateWindow(BrowserJoinMenuWindow, 50, 30, 500, 300));
	JoinBrowserWindow.SelectInternet();
	GotoWindow(JoinBrowserWindow);
}

function CreateMenuContents()
{
	local string OptionsHelpText;
	local bool bOptionsActive;
	local string LoadHelpText;
	local string SaveHelpText;
	local bool bLoadActive;
	local bool bSaveActive;
	local bool bOwnerIsAdmin;
	local CoopPlayerReplicationInfo ReplicaInfo;

	Super.CreateMenuContents();

	ReplicaInfo = CoopPlayerReplicationInfo(GetPlayerOwner().PlayerReplicationInfo);
	if( ReplicaInfo != None )
	{
		bOwnerIsAdmin = ReplicaInfo.bAdmin;
		bCoopTeleportDisabled = ReplicaInfo.bCoopTeleportDisabled;
	}

	bOptionsActive = true;
	bLoadActive = true;
	bSaveActive = true;

	if (GetGameSingle().IsCinematic())
	{
		OptionsHelpText = DisabledForCinematicHelpText;
		LoadHelpText = DisabledForCinematicHelpText;
		SaveHelpText = DisabledForCinematicHelpText;
		bOptionsActive = false;
		bLoadActive = false;
		bSaveActive = false;
	}

	if (!GetGameSingle().IsSaveAllowed(P2Player(GetPlayerOwner())))
	{
		bSaveActive = false;
		SaveHelpText = DisabledNowText;
	}

	AddTitleBitmap(TitleTexture);
	CoopPlayersChoice = AddChoice(CoopPlayersText, "", ItemFont, ItemAlign);
	CoopTeleportChoice = AddChoice_ByClass(class'CoopShellMenuChoice', CoopTeleportText, CoopTeleportHelp, ItemFont, ItemAlign);
	///if(GetGameSingle() != None && GetGameSingle().FinallyOver())
	///	CheatsChoice	= AddChoice(CheatsText,	CheatsHelp,			ItemFont, ItemAlign);

	if( bOwnerIsAdmin )
		AdminChoice	= AddChoice(AdminMenuText, "", ItemFont, ItemAlign);
	else AdminLoginChoice = AddChoice(AdminLoginText, "", ItemFont, ItemAlign);

	SaveChoice = AddChoice(SaveText, SaveHelpText, ItemFont, ItemAlign);
	///LoadChoice = AddChoice(LoadGameText, LoadHelpText, ItemFont, ItemAlign);///NonDedicatedAutoSave 22/01/2018
//	RestartChoice = AddChoice(RestartText, "", ItemFont, ItemAlign);
	OptionsChoice = AddChoice(OptionsText, OptionsHelpText,	ItemFont, ItemAlign);
	QuitChoice = AddChoice(QuitText, "", ItemFont, ItemAlign);
	ResumeChoice = AddChoice(ResumeText, "", ItemFont, ItemAlign);

	// Enable/disable various options (only works with MenuChoice)
	OptionsChoice.bActive = bOptionsActive;
	SaveChoice.bActive = bSaveActive;
	if( LoadChoice != None )
		LoadChoice.bActive = bLoadActive;

	UpdateCoopTeleportChoice();
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_RClick:
			switch (C)
				{
				case CoopTeleportChoice:
					xCoopTeleportChoiceRPressed();
					break;
				}
			break;
		case DE_Click:
			switch (C)
				{
				case ResumeChoice:
					ResumeGame();
					break;
				///case CheatsChoice:
				///	GoToMenu(class'MenuCheats');
				///	break;
				case SaveChoice:
					xSaveChoicePressed();
					break;
				case LoadChoice:
					xLoadChoicePressed();
					break;
				case RestartChoice:
					xRestartChoicePressed();
					break;
				case ResetGameChoice:
					xResetGameChoicePressed();
					break;
				case QuitChoice:
					xQuitChoicePressed();
					break;
				case OptionsChoice:
					xOptionsChoicePressed();
					break;
				case AdminChoice:
					xAdminChoicePressed();
					break;
				case AdminLoginChoice:
					xAdminLoginChoicePressed();
					break;
				case CoopPlayersChoice:
					xCoopPlayersChoicePressed();
					break;
				case CoopTeleportChoice:
					xCoopTeleportChoicePressed();
					break;
				case JoinChoice:
					xJoinChoicePressed();
					break;
				case SavePlayerChoice:
					xSavePlayerChoicePressed();
					break;
				case SpecSpectatorChoice:
					xSpecSpectatorChoicePressed();
					break;
				}
			break;
		}
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	// 02/05/21 - Gamepad input fix
	if (HandleJoystick(Key, Action, Delta))
		return true;

	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				ResumeGame();
				return true;
			}
		}
	
	return false;
}

function ResumeGame()
{
	HideMenu();
}

function xSaveChoicePressed()
{
	//GoToMenu(class'MenuSave');
	CoopGameInfo(GetGameSingle()).SaveGame(0,false);
	HideMenu();
}

function xLoadChoicePressed()
{
	//GoToMenu(class'MenuLoad');
	CoopGameInfo(GetGameSingle()).LoadGame(0,false);
	HideMenu();
}

function xRestartChoicePressed()
{
	HideMenu();
	///GetGameSingle().SendPlayerTo(GetGameSingle().GetPlayer(), GetGameSingle().GetURLMap());
	///steam 04/04/2016
	CoopGameInfo(GetGameSingle()).CoopRestartLevel();
}

function xResetGameChoicePressed()
{
	HideMenu();
	CoopPlayerController(GetPlayerOwner()).NETCoopResetVote();
}

function xQuitChoicePressed()
{
	GoToMenu(class'CoopMenuQuitExitConfirmation');
}

function xOptionsChoicePressed()
{
	GoToMenu(class'MenuOptions');
}

function xAdminChoicePressed()
{
	GoToMenu(NCAdminMenuClass);
}

function xAdminLoginChoicePressed()
{
	GoToMenu(class'MenuAdminLogin');
}

function xCoopPlayersChoicePressed()
{
	CoopPlayerController(GetPlayerOwner()).CoopPlayers();
	HideMenu();
}

function xCoopTeleportChoicePressed()
{
	CoopPlayerController(GetPlayerOwner()).CoopTeleport();
	HideMenu();
}

function xSavePlayerChoicePressed()
{
	CoopPlayerController(GetPlayerOwner()).NETSavePlayer();
	HideMenu();
}

function xSpecSpectatorChoicePressed()
{
	GoToMenu(class'CoopMenuSpecSpectator');
}

function xCoopTeleportChoiceRPressed()
{
	bCoopTeleportDisabled = CoopPlayerController(GetPlayerOwner()).DisableCoopTeleport();
	UpdateCoopTeleportChoice();
}

defaultproperties
{
	NCAdminMenuClass=class'CoopMenuAdmin'

	ResetGameText="Game Progress"
	ResetGameHelpText="Reset current game progress"
	SpecSpectatorText="Spectator Menu"
	SpecSpectatorHelpText="Allows to switch spectator modes"
	SavePlayerText="Save Player"
	SavePlayerHelpText="Lut and stats manual save"
	NotAdminHelp="Login as admin"
	CoopTeleportHelp="Click to teleport. Other players CAN teleport to you, right click to DISABLE"
	CoopTeleportDisabledHelp="Click to teleport. Other players CAN'T teleport to you, right click to ENABLE"
	JoinAnotherText="Join New Game"

	CoopTeleportText="Coop teleport"
	CoopPlayersText="Show players"
	RestartText="Restart level"
	ResumeText="Resume Game"
	CheatsText="Cheats"
	CheatsHelp="Grant yourself various cheats for extra fun!"
	SaveText="Save Game"
	QuitText="Quit Game"
	DisabledForCinematicHelpText="Not available during cinematic"
	DisabledNowText="Not available in this state"
	bBlockConsole=false
}
