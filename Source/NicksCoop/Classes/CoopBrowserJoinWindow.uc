//=============================================================================
// CoopBrowserJoinWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinWindow extends UBrowserMainWindow;

///steam 15/01/2017
function BeginPlay()
{
	Super(UWindowFramedWindow).BeginPlay();
	WindowTitle = WindowTitleString;
}

///steam 15/01/2017
function WindowShown()
{
	Super(UWindowFramedWindow).WindowShown();
}

///steam 15/01/2017
function ResolutionChanged(float W, float H)
{
	Super(UWindowFramedWindow).ResolutionChanged(W, H);
}

///steam 15/01/2017
function Resized()
{
	Super(UWindowFramedWindow).Resized();
}

///steam 15/01/2017
function MouseMove(float X, float Y)
{
	Super(UMenuFramedWindow).MouseMove(X, Y);
}

defaultproperties
{
	WindowTitleString="Join Game"
	ClientClass=class'CoopBrowserJoinClientWindow';
}