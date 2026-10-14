//=============================================================================
// CoopBrowserJoinInfoCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinInfoCW extends UBrowserInfoClientWindow;

function Created()
{
	Initialized = false;
	Super(UWindowClientWindow).Created();
	
	HSplitter = UWindowHSplitter(CreateWindow(class'UWindowHSplitter', 0, 0, WinWidth, WinHeight));
	VSplitter = UWindowVSplitter(HSplitter.CreateWindow(class'UWindowVSplitter', 0, 0, WinWidth, WinHeight));

	HSplitter.LeftClientWindow = VSplitter;
	HSplitter.RightClientWindow = UBrowserScreenshotCW(HSplitter.CreateWindow(class'CoopBrowserJoinScreenshotCW', 0, 0, WinWidth, WinHeight));
	HSplitter.bSizable = false;

	VSplitter.TopClientWindow = UBrowserPlayerGrid(VSplitter.CreateWindow(class'CoopBrowserJoinPlayerGrid', 0, 0, WinWidth, WinHeight));
	VSplitter.BottomClientWindow = UBrowserRulesGrid(HSplitter.CreateWindow(class'CoopBrowserJoinRulesGrid', 0, 0, WinWidth, WinHeight));;
}

defaultproperties
{
}