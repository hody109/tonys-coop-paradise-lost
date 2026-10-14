//=============================================================================
// CoopMenuQuitExitConfirmationMulti.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMenuQuitExitConfirmationMulti extends CoopMenuQuitExitConfirmation;

/*function CoopExitGame()
{
	//ShellRootWindow(root).bLockErrorWindow = true;
	//CoopShellRootWindow(root).bDisableMainStatusMsg = true;
	GetPlayerOwner().ConsoleCommand("disconnect");
	ShellRootWindow(root).ExitApp();
}*/

defaultproperties
{
	ExitGameTextHeight="70"
	ExitGameText="Are you sure you want to Leave this server?"
}
