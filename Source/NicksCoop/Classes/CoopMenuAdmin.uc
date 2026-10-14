//=============================================================================
// CoopMenuAdmin.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMenuAdmin extends MenuAdmin;

var ShellMenuChoice		CustomMapChoice;
var localized string	CustomMapText;
var localized string	CustomMapHelp;
var int					CustomMapWidth;
var int					CustomMapHeight;

var ShellMenuChoice		CustomModChoice;
var localized string	CustomModText;
var localized string	CustomModHelp;

var ShellMenuChoice		AchChoice;
var localized string	AchText;
var localized string	AchHelpText;

var ShellMenuChoice		RestartChoice;
var localized string	RestartText;

function CreateMenuContents()
{
	Super(ShellMenuCW).CreateMenuContents();
	
	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	AddTitle(AdminMenuText, TitleFont, TitleAlign);

	RestartChoice = AddChoice(RestartText, "", ItemFont, ItemAlign);

	KickChoice			= AddChoice(KickText,			KickHelp,    ItemFont, ItemAlign);
	MessageChoice		= AddChoice(AdminMessageText,	MessageHelp, ItemFont, ItemAlign);

	CustomMapChoice	= AddChoice(CustomMapText,		CustomMapHelp,		ItemFont, ItemAlign);
	CustomModChoice	= AddChoice(CustomModText,		CustomModHelp,		ItemFont, ItemAlign);
	if( GetPlayerOwner().Buoyancy == 75 )
	{
		AchChoice		= AddChoice(AchText,			AchHelpText,		ItemFont, ItemAlign);

		if( GetGameSingle().IsCinematic() )
		{
			CustomMapChoice.bActive = false;
			CustomModChoice.bActive = false;
		}
	}

	BackChoice			= AddChoice(BackText,			"", ItemFont, ItemAlign, true);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case RestartChoice:
						xRestartChoicePressed();
						break;
					case CustomMapChoice:
						Root.ShowModal(Root.CreateWindow(class'CoopBrowserMapsListFrame', 
										(Root.WinWidth - CustomMapWidth) /2, 
										(Root.WinHeight - CustomMapHeight) /2, 
										CustomMapWidth, CustomMapHeight, self));
						break;
					case CustomModChoice:
						Root.ShowModal(Root.CreateWindow(class'CoopBrowserModsListFrame', 
										(Root.WinWidth - CustomMapWidth) /2, 
										(Root.WinHeight - CustomMapHeight) /2, 
										CustomMapWidth, CustomMapHeight, self));
						break;
					case AchChoice:
						GoToMenu(class'CoopMenuAchievementList');
						break;
					}
			break;
		}
}

function xRestartChoicePressed()
{
	HideMenu();
	CoopPlayerController(GetPlayerOwner()).NETRestartLevel();
}

defaultproperties
{
	RestartText="Restart level"

	AchText = "Achievements"
	AchHelpText = "View super-cool achievements."

	CustomModText	= "Custom/Workshop Mods"
	CustomModHelp	= "WARNING: Mods may cause random crashes and bugs! Achievements will be disabled!"
	CustomMapText	= "Custom/Workshop Maps"
	CustomMapHelp	= "WARNING: After load, no return to previous level! Achievements will be disabled!"
	CustomMapWidth	= 350
	CustomMapHeight	= 250

	MenuWidth	= 400
	ItemBorder = 0
	ItemHeight = 42
	ItemSpacingY = 4

	KickText	= "Kick/Ban a Player"
	KickHelp	= "Force a player to leave the game"
	MessageHelp	= "Send an administrator announcement to all the players"
}
