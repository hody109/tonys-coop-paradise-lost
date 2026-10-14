//=============================================================================
// CoopBrowserTextArea.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserTextArea extends UBrowserUpdateServerTextArea;

function SetHTML(string HTML)
{
	local int i, nStart, nEnd;
	local string TempHTML;

	//bHTMLLoaded = true;

	Clear();

	ReplaceText(HTML, Chr(13)$Chr(10), " ");
	ReplaceText(HTML, Chr(13), " ");
	ReplaceText(HTML, Chr(10), " ");

	nStart = -1;
	nEnd = -1;
	TempHTML = HTML;
	while( i < len(HTML) )
	{
		TempHTML = Mid(HTML, i, 4);
		if( nStart == -1 && GetTag(TempHTML) == "UE"  )
		{
			nStart = i;
		}
		else if( nEnd == -1 && GetTag(TempHTML) == "/UE"  )
		{
			nEnd = i;
			break;
		}
		i++;
	}

	HTML = Mid(HTML, nStart, abs(nEnd-nStart));

	AddText(HTML);
}

function ProcessURL(string URL)
{
	Log("Clicked Link: >>"$URL$"<<");

	if( Left(URL, 7) ~= "mailto:" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 7) ~= "http://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 8) ~= "https://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 6) ~= "ftp://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 9) ~= "telnet://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 9) ~= "gopher://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 4) ~= "www." )
		GetPlayerOwner().ConsoleCommand("start http://"$URL);
	else if( Left(URL, 4) ~= "ftp." )
		GetPlayerOwner().ConsoleCommand("start ftp://"$URL);
	else if( Left(URL, 4) ~= "ubl." )
		CoopBrowserPageWindow(GetParent(class'CoopBrowserPageWindow')).OpenUnrealBrowserLink(int(Mid(URL,4,Len(URL))));
	else if( Left(URL, 6) ~= "concom" )
	{
		CoopBrowserPageWindow(GetParent(class'CoopBrowserPageWindow')).EnterCoopConsoleCommand(URL);
	}
	else
// RWS Change, changed from unreal to postal2
	if( Left(URL, 10) ~= "postal2://" )
		LaunchUnrealURL(URL);
}

function ProcessURL_Coop(string URL, string Text)
{
	Log("Clicked Link: >>"$URL$"<<");

	if( Left(URL, 7) ~= "mailto:" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 7) ~= "http://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 8) ~= "https://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 6) ~= "ftp://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 9) ~= "telnet://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 9) ~= "gopher://" )
		GetPlayerOwner().ConsoleCommand("start "$URL);
	else if( Left(URL, 4) ~= "www." )
		GetPlayerOwner().ConsoleCommand("start http://"$URL);
	else if( Left(URL, 4) ~= "ftp." )
		GetPlayerOwner().ConsoleCommand("start ftp://"$URL);
	else if( Left(URL, 4) ~= "ubl." )
		CoopBrowserPageWindow(GetParent(class'CoopBrowserPageWindow')).OpenUnrealBrowserLink(int(Mid(URL,4,Len(URL))));
	else if( Left(URL, 6) ~= "concom" )
	{
		CoopBrowserPageWindow(GetParent(class'CoopBrowserPageWindow')).EnterCoopConsoleCommand(Text);
	}
	else
// RWS Change, changed from unreal to postal2
	if( Left(URL, 10) ~= "postal2://" )
		LaunchUnrealURL(URL);
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);
	OverURL("");
}

function OverURL(string URL)
{
	CoopBrowserPageWindow(GetParent(class'CoopBrowserPageWindow')).CoopBrowserSelectLink(URL);
}

function string GetConComText(string InText)
{
	local int i, j;

	i = InStr(InText, ">")+1;
	j = InStr(Right(InText, Len(InText)-i), "<");

	return Mid(InText, i, j);
}

function float DrawTextLine(Canvas C, UWindowDynamicTextRow L, float Y)
{
	local float X, W, H, MouseX, MouseY;
	local HTMLStyle CurrentStyle;
	local float RowHeight;
	local Color OldColor;
	local int StylePos, DisplayPos, i;
	local string S;

	RowHeight = 0;

	CurrentStyle = UWindowHTMLTextRow(L).StartStyle;
	if(CurrentStyle.bCenter)
	{
		W = CalcHTMLTextWidth(C, L.Text, CurrentStyle);
		if(VertSB.bWindowVisible)
			X = int(((WinWidth - VertSB.WinWidth) - W) / 2);
		else
			X = int((WinWidth - W) / 2);
	}
	else
		X = 2;

	if(GetEntryLevel().TimeSeconds > LastBlinkTime + 0.5)
	{
		bShowBlink = !bShowBlink;
		LastBlinkTime = GetEntryLevel().TimeSeconds;
	}

	if(UWindowHTMLTextRow(L).DisplayString == "")
		SetCanvasStyle(C, CurrentStyle);
	else
	{
		while(DisplayPos < Len(UWindowHTMLTextRow(L).DisplayString))
		{
			i = ReadStyleText(UWindowHTMLTextRow(L).StyleString, StylePos, CurrentStyle);
			S = Mid(UWindowHTMLTextRow(L).DisplayString, DisplayPos, i);
			DisplayPos += i;					
			SetCanvasStyle(C, CurrentStyle);

			TextAreaTextSize(C, S, W, H);
			if(H > RowHeight)
				RowHeight = H;

			if(CurrentStyle.bLink)
			{
				GetMouseXY(MouseX, MouseY);
				if(X < MouseX && X + W > MouseX && Y < MouseY && Y + H > MouseY)
				{
					Cursor = Root.HandCursor;
					OverURL(CurrentStyle.LinkDestination);

					if(bMouseDown || bReleased)
					{
						if(bReleased)
						{
							ProcessURL_Coop(CurrentStyle.LinkDestination, GetConComText(UWindowHTMLTextRow(L).Text));
							bReleased = False;
						}
						else
							C.DrawColor = ALinkColor;
					}
				}
			}

			if(CurrentStyle.BGColor != BGColor)
			{	
				OldColor = C.DrawColor;
				C.DrawColor = CurrentStyle.BGColor;
				DrawStretchedTexture(C, X, Y, W, H, Texture'WhiteTexture');
				C.DrawColor = OldColor;
			}
			if(!CurrentStyle.bBlink || bShowBlink)
				TextAreaClipText(C, X, Y, S);
			if(CurrentStyle.bLink || CurrentStyle.bUnderline)
				DrawStretchedTexture(C, X, Y+H-1, W, 1, Texture'WhiteTexture');

			X += W;
		}
	}
	if(RowHeight == 0)
		TextAreaTextSize(C, "A", W, RowHeight);

	return RowHeight;
}

defaultproperties
{
	RowClass=class'UWindowHTMLTextRow'
	TextColor=(R=0,G=0,B=0,A=255)
	BGColor=(R=255,G=255,B=255,A=255)
	LinkColor=(R=0,G=0,B=255,A=255)
	ALinkColor=(R=255,G=0,B=0,A=255)
	bIgnoreLDoubleClick=True
	bAutoScrollbar=True
	bTopCentric=True
	bVariableRowHeight=True
}
