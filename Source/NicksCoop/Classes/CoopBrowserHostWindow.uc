//=============================================================================
// CoopBrowserHostWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserHostWindow extends UMenuStartGameWindow;

///steam 18/03/2016
function Close(optional bool bByParent) 
{
	if( Root != None && CoopShellRootWindow(Root) != None )
		CoopShellRootWindow(Root).GoToWindowClosed(self);
	Super.Close(bByParent);
}

///steam 30/04/2016
function MouseMove(float X, float Y)
{
	Super(UMenuFramedWindow).MouseMove(X, Y);
}

defaultproperties
{
	WindowTitle="Host Game"
	ClientClass=Class'CoopBrowserHostCW'
	//ClientClass=Class'UTMenuStartMatchCW'
}
