//=============================================================================
// CoopBrowserJoinDirectWinTextArea.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopBrowserJoinDirectWinTextArea extends UBrowserUpdateServerTextArea;//UWindowHTMLTextArea;

var float AutoScrollTime;

function BeforePaint( Canvas C, float X, float Y )
{
	Super.BeforePaint(C, X, Y);
	if( AutoScrollTime != 0 )
	{
		if( GetLevel().Level.TimeSecondsAlways > AutoScrollTime + 0.02 )
		{
			VertSB.Pos = VertSB.MaxPos;
			AutoScrollTime = 0;
		}
	}
}

function SetHTML(string HTML)
{
	AddText(HTML);
	AutoScrollTime = GetLevel().Level.TimeSecondsAlways;
}

function ProcessURL(string URL)
{
	Log("Clicked Link: >>"$URL$"<<");

	if( Left(URL, 7) ~= "mailto:" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if( Left(URL, 7) ~= "http://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if( Left(URL, 6) ~= "ftp://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if( Left(URL, 9) ~= "telnet://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if( Left(URL, 9) ~= "gopher://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	if( Left(URL, 4) ~= "www." )
		GetPlayerOwner().ConsoleCommand("start http://"$URL);
	if( Left(URL, 4) ~= "ftp." )
		GetPlayerOwner().ConsoleCommand("start ftp://"$URL);
	if( Left(URL, 8) ~= "DWSetIP." )
		CoopBrowserJoinDirectWindow(GetParent(class'CoopBrowserJoinDirectWindow')).SetNewServerIP(Mid(URL,8,Len(URL)));
	else
// RWS Change, changed from unreal to postal2
	if( Left(URL, 10) ~= "postal2://" )
		LaunchUnrealURL(URL);
}

defaultproperties
{
}
