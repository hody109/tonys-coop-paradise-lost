//=============================================================================
// CoopMenuMain.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopMenuMain extends BaseMenuBig;

var ShellMenuChoice		EnhancedChoice;
var localized string	EnhancedText;

var ShellMenuChoice		LoadChoice;

var ShellMenuChoice		CoopChoice;
var localized string	CoopText;
var localized string	CoopHelp;

var ShellMenuChoice		ExitChoice;
var localized string	ExitGameText;

function CreateMenuContents()
{
	Super.CreateMenuContents();
	AddTitleBitmap(TitleTexture);

	if(GetGameSingle() != None && GetGameSingle().VerifySeqTime(true))
		ShellRootWindow(Root).bVerified = true;
	// Only add this option in after you've beaten the game
	///if(ShellRootWindow(Root).bVerified)
	///	EnhancedChoice= AddChoice(EnhancedText,		"",									ItemFont, ItemAlign);
	///steam 10/04/2016

	CoopChoice   = AddChoice(CoopText,		CoopHelp,									ItemFont, ItemAlign);
	OptionsChoice = AddChoice(OptionsText,		"",									ItemFont, ItemAlign);
	ExitChoice    = AddChoice(ExitGameText,		"",									ItemFont, ItemAlign);

	// Reset this value. When MenuDifficultyPatch starts up, it's the only one that needs it
	// and it will set it when necessary.
	ShellRootWindow(Root).bFixSave=false;
}

function Notify(UWindowDialogControl C, byte E)
{
	local class<CoopMenu> CoopMenuClass;

	CoopMenuClass = CoopShellRootWindow(Root).CoopMenuClass;

	if( CoopMenuClass == None )
		CoopMenuClass = class'CoopMenu';

	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					/*case EnhancedChoice:
						SetSingleplayer();
						ShellRootWindow(Root).bVerifiedPicked=true;
						GotoMenu(class'MenuEnhanced');
						break;*/

					case CoopChoice:
						GotoMenu(CoopMenuClass);
						break;

					case OptionsChoice:
						GoToMenu(class'MenuOptions');
						break;

					case ExitChoice:
						GoToMenu(class'MenuQuitExitConfirmation');	// 01/21/03 JMI Now looks for confirmation.
						break;
					}
				break;
		}
}

///////////////////////////////////////////////////////////////////////////////
// Set temp options for singleplayer game
///////////////////////////////////////////////////////////////////////////////
function SetSingleplayer()
{
	///steam 24/02/2016
	ShellRootWindow(Root).bLaunchedMultiplayer = false;
	/*GetPlayerOwner().UpdateURL("Name", class'GameInfo'.Default.DefaultPlayerName, false);
	GetPlayerOwner().UpdateURL("Class", "People.PostalDude", false);*/
}

function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				// Only allow ESC to hide the main menu if it was also used to show it
				if (ShellRootWindow(root).bMainMenuShownViaESC)
					HideMenu();
				return true;
			}
		}
	
	return false;
}

defaultproperties
{
	 CoopText="Co-Op Game"
	 //CoopHelp="Cooperative game start"
     EnhancedText="Enhanced Game"
     ExitGameText="Exit"
     astrTextureDetailNames(0)="UltraLow"
     astrTextureDetailNames(1)="Low"
     astrTextureDetailNames(2)="Medium"
     astrTextureDetailNames(3)="High"
     bBlockConsole=False
}
