//=============================================================================
// CoopPLShellRootWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLShellRootWindow extends CoopShellRootWindow;

// A deliberate Quit Game returns to the external launcher.
// Keep forced end-of-campaign/menu travel separate from user-requested exit.
function CoopQuitCurrentGame()
{
    if (IsGameMenu())
        GetPlayerOwner().ConsoleCommand("quit");
}

defaultproperties
{
	CoopMenuClass=class'CoopPLMenu'
	//xMainMenuClass=class'CoopPLMenuMain'
	//xGameMenuClass=class'CoopTubeMenuGame'
	//xMultiMenuClass=class'CoopTubeMenuGameMulti'
}
