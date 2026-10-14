//=============================================================================
// CoopBrowserOpenWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserOpenWindow extends UBrowserOpenWindow;

///steam 18/03/2016 old SetSizePos
function SetSizePos()
{
	//SetSize(450, 120);
	SetSize(450, 150);

	WinLeft = Int((Root.WinWidth - WinWidth) / 2);
	WinTop = Int((Root.WinHeight - WinHeight) / 2);
}

/*function Close(optional bool bByParent) 
{
	if(Root != None)
		Root.GoBack();

	Super.Close(bByParent);
}*/

///steam 18/03/2016
function Close(optional bool bByParent) 
{
	if( Root != None && CoopShellRootWindow(Root) != None )
		CoopShellRootWindow(Root).GoToWindowClosed(self);
	Super.Close(bByParent);
}

function OpenURL(string URL)
{
	if( Left(URL, 7) ~= "http://" )
	{
		GetPlayerOwner().ConsoleCommand("start "$URL);
		Close();
		return;
	}
	else
// RWS Change, changed from unreal to postal2
	if( Left(URL, 10) ~= "postal2://" )
	{
//		P2RootWindow(Root).StartingGame();
		GetPlayerOwner().ClientTravel(URL, TRAVEL_Absolute, false);
	}
	else
// RWS Change, changed from unreal to postal2
	{
//		P2RootWindow(Root).StartingGame();
		GetPlayerOwner().ClientTravel("postal2://"$URL, TRAVEL_Absolute, false);
	}

	Close();
	Root.ConsoleClose();
}

/*function MouseMove(float X, float Y)
{
	bMoving = false;
	Super.MouseMove(X, Y);
}*/

defaultproperties
{
	WindowTitle="Join game"
	ClientClass=class'CoopBrowserOpenCW'
	OKText="Join"
}