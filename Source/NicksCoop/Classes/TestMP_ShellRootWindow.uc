//=============================================================================
// CoopShellRootWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class TestMP_ShellRootWindow extends ShellRootWindow
	config;

var class<BaseMenuBig> xMainMenuClass, xGameMenuClass, xMultiMenuClass;

function class<BaseMenuBig> GetMainMenuClass()
{
	return xMainMenuClass;
}

state GameMenuShowing
{
	function BeginState()
	{
		local String CurRes;

		bGameMenu = true;

		//Super.BeginState();

		if(P2GameInfoSingle(Root.GetLevel().Game) != None)
			CreateMenu(xGameMenuClass);
		else CreateMenu(xMultiMenuClass);

		bAllowConsole = false;

		// If current res is less than minimum res then switch to the min res
		// here and restore original resolution when state ends.
		CurRes = ViewportOwner.Actor.ConsoleCommand("GetCurrentRes");
		if (IsBelowMinRes(CurRes))
		{
			SetLowGameRes(CurRes);
			ViewportOwner.Actor.ConsoleCommand("SetRes "$MinRes);
		}

		if (!bAllowConsole && (MyMenu != None))
			MyMenu.ShowWindow();

		// Add code to initialize the uwindows system
	
		bVisible 		= true;
		bRequiresTick 	= true;
		
		bWindowVisible = True;
		bUWindowActive = true;

		ViewportOwner.bShowWindowsMouse = True;
		ViewportOwner.bSuspendPrecaching = True;

		// RWS CHANGE: Added flag to allow extended classes to block pausing
		if (ViewportOwner.Actor.Level.NetMode == NM_Standalone && !bDontPauseOrUnPause)
			ViewportOwner.Actor.SetPause( True );

		if (bAllowConsole && ConsoleWindow != None)
			ConsoleWindow.ShowWindow();
	}
}

defaultproperties
{
	xMainMenuClass=class'TestMP_MenuMain'
	xGameMenuClass=class'CoopMenuGame'
	xMultiMenuClass=class'CoopMenuGameMulti'
}
