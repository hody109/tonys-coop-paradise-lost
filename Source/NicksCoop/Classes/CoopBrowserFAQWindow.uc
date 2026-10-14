//=============================================================================
// CoopBrowserFAQWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserFAQWindow extends UWindowFramedWindow;

function SelectFAQPage()
{
	CoopBrowserFAQCW(ClientArea).SelectFAQPage();
}

function Created()
{
	MinWinWidth = 300;
	MinWinHeight = 300;
	ClientArea = CreateWindow(ClientClass, 4, 16, WinWidth - 8, WinHeight - 20, OwnerWindow);
	CloseBox = UWindowFrameCloseBox(CreateWindow(Class'UWindowFrameCloseBox', WinWidth-20, WinHeight-20, 11, 10));

	bSizable = true;
	SetSizePosDef();

	///steam 06/02/2017
	WindowTitle = CoopShellRootWindow(Root).GetNicksCoopBuild();
	if( WindowTitle == "" )
		WindowTitle = default.WindowTitle;
}

function SetSizePosDef()
{
	if(Root.WinHeight < 600)
		SetSize(Root.WinWidth - 10, Root.WinHeight - 10);
	else
		SetSize(Min(800, Root.WinWidth) - 20, Min(600, Root.WinHeight) - 20);

	WinLeft = Int((Root.WinWidth - WinWidth) / 2);
	WinTop = Int((Root.WinHeight - WinHeight) / 2);
}

///steam 18/03/2016
function Close(optional bool bByParent) 
{
	if( Root != None && CoopShellRootWindow(Root) != None )
		CoopShellRootWindow(Root).GoToWindowClosed(self);

	Super.Close(bByParent);
}

defaultproperties
{
	ClientClass=class'CoopBrowserFAQCW'
	WindowTitle="Browser"
}