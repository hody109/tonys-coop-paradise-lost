//=============================================================================
// CoopMenuGameMulti.uc
// - 2017 some code moved to CoopMenuGame.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015-2017.
//=============================================================================

class CoopMenuGameMulti extends CoopMenuGame;//BaseMenuBig;

// Listen-server
/***
Show Players
Coop Teleport
Join Game
Admin Menu
Save Game
Restart Level
Options
Quit Game
Resume Game
***/

// Listen-server (spectator)
/***
Join Game
Admin Menu
Save Game
Restart Level
Spectator Menu
Options
Quit Game
Resume Game
***/

// Dedicated-server
/***
Show Players
Coop Teleport
Join Game
Admin Menu
Save Player
Restart Level (admin only)
Game Progress
Options
Quit Game
Resume Game
***/

// Dedicated-server (spectator)
/***
Join Game
Admin Menu
Restart Level (admin only)
Spectator Menu
Options
Quit Game
Resume Game
***/

function CreateMenuContents()
{
	local bool bOwnerIsAdmin;
	local bool bOwnerIsSpectator;
	local bool bCoopDed;
	local string sRestartHelp;
	local string LoadHelpText;
	local string SaveHelpText;
	local color useColor;
	local CoopPlayerReplicationInfo ReplicaInfo;

	Super(BaseMenuBig).CreateMenuContents();

	ReplicaInfo = CoopPlayerReplicationInfo(GetPlayerOwner().PlayerReplicationInfo);
	if( ReplicaInfo != None )
	{
		bOwnerIsAdmin = ReplicaInfo.bAdmin;
		bOwnerIsSpectator = ReplicaInfo.bOnlySpectator;
		bCoopTeleportDisabled = ReplicaInfo.bCoopTeleportDisabled;
	}

	AddTitleBitmap(TitleTexture);

	if( !bOwnerIsAdmin )
	{
		LoadHelpText = NotAdminHelp;
		SaveHelpText = NotAdminHelp;
		sRestartHelp = NotAdminHelp;
	}

	if( !bOwnerIsSpectator )
	{
		CoopPlayersChoice = AddChoice(CoopPlayersText, "", ItemFont, ItemAlign);
		CoopTeleportChoice = AddChoice_ByClass(class'CoopShellMenuChoice', CoopTeleportText, CoopTeleportHelp, ItemFont, ItemAlign);
	}

	JoinChoice = AddChoice(JoinAnotherText, JoinHelp, ItemFont, ItemAlign);

	if( bOwnerIsAdmin )
		AdminChoice	= AddChoice(AdminMenuText, "", ItemFont, ItemAlign);
	else AdminLoginChoice = AddChoice(AdminLoginText, "", ItemFont, ItemAlign);

	if( CoopGameReplicationInfo(GetPlayerOwner().GameReplicationInfo) != None )
		bCoopDed = CoopGameReplicationInfo(GetPlayerOwner().GameReplicationInfo).bCoopDedicated;
	if( !bCoopDed 
		&& bOwnerIsAdmin ) ///NonDedicatedAutoSave 22/01/2018
	{
		SaveChoice = AddChoice(SaveText, SaveHelpText, ItemFont, ItemAlign);
		///LoadChoice = AddChoice(LoadGameText, LoadHelpText, ItemFont, ItemAlign); ///NonDedicatedAutoSave 22/01/2018
	}
	else
	{
		if( !bOwnerIsSpectator )
			SavePlayerChoice = AddChoice(SavePlayerText, SavePlayerHelpText, ItemFont, ItemAlign);
	}

	///if( !bCoopDed || (bCoopDed && bOwnerIsAdmin) ) ///NonDedicatedAutoSave 22/01/2018
//	RestartChoice = AddChoice(RestartText, sRestartHelp, ItemFont, ItemAlign);

	if( bCoopDed )
		ResetGameChoice = AddChoice(ResetGameText, ResetGameHelpText, ItemFont, ItemAlign);

	if( bOwnerIsSpectator )
		SpecSpectatorChoice = AddChoice(SpecSpectatorText, SpecSpectatorHelpText, ItemFont, ItemAlign);

	OptionsChoice = AddChoice(OptionsText, "", ItemFont, ItemAlign);

	QuitChoice = AddChoice(QuitText, "", ItemFont, ItemAlign);
	ResumeChoice = AddChoice(ResumeText, "", ItemFont, ItemAlign);

	if( !bOwnerIsAdmin )
	{
		useColor.R = 100;
		useColor.G = 100;
		useColor.B = 100;
		if( SaveChoice != None )
		{
			SaveChoice.bActive = false;
			SaveChoice.SetTextColor(useColor);
		}
		if( LoadChoice != None )
		{
			LoadChoice.bActive = false;
			LoadChoice.SetTextColor(useColor);
		}
		if( RestartChoice != None )
		{
			RestartChoice.bActive = false;
			RestartChoice.SetTextColor(useColor);
		}
	}

	UpdateCoopTeleportChoice();
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
				if(ShellRootWindow(Root) != None && ShellRootWindow(Root).openWindow != None)
				{
					ShellRootWindow(Root).openWindow.Close();
					return true;
				}
				ResumeGame();
				return true;
			}
		}
	
	return false;
}

function xSaveChoicePressed()
{
	CoopPlayerController(GetPlayerOwner()).NETSaveGame();
	HideMenu();
}

function xLoadChoicePressed()
{
	CoopPlayerController(GetPlayerOwner()).NETLoadGame();
	HideMenu();
}

function xRestartChoicePressed()
{
	HideMenu();
	CoopPlayerController(GetPlayerOwner()).NETRestartLevel();
}

function xQuitChoicePressed()
{
	GoToMenu(class'CoopMenuQuitExitConfirmationMulti');
}

function xOptionsChoicePressed()
{
	GoToMenu(class'MenuOptionsMulti');
}

function xAdminLoginChoicePressed()
{
	GoToMenu(class'CoopMenuAdminLogin');
}

defaultproperties
{
}
