//=============================================================================
// CoopBrowserJoinDirectWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopBrowserJoinDirectWindow extends UBrowserPageWindow;

var UWindowSmallButton InfoButton;
var localized string InfoButtonName;
var localized string InfoButtonHelp;

/*var UWindowSmallButton StatusButton;
var localized string StatusButtonName;
var localized string StatusButtonHelp;*/

var UWindowSmallButton Join;
var localized string JoinName;
var localized string JoinHelp;

var UWindowComboControl OpenCombo;
var localized string OpenText;
var localized string OpenHelp;
var color OpenComboColor;
var float OpenComboHeight;
var config string OpenHistory[10];

var float BevelTop;
var float BevelHeight;
var float ButtonTextPadding;
var float ButtonSpacing;

var localized string MyHeaderText;

var CoopBrowserJoinDirectStatusLink ServerPing;
var bool bPinging;
var bool bPingFailed;
var bool bPinged;
//var bool bJoining;

var UBrowserUpdateServerTextArea TextArea;
var class<UBrowserUpdateServerTextArea> TextAreaClass;

var array<byte> PlayerListID;
var array<string> PlayerListInfo;

var bool				bLocalServer;
var float				Ping;
var string				HostName;
var int					GamePort;
var string				MapName;
var string				MapTitle;
var string				MapDisplayName;
var string				GameType;
var string				GameMode;
var int					NumPlayers;
var int					MaxPlayers;
var int					GameVer;
var int					MinNetVer;

const TEXTAREA_FRAME_INDENT = 70;
const TEXTAREA_FRAME_SIZE = 20;

function Created()
{
	local int i;

	PageHeaderText = MyHeaderText;

	Super.Created();

	// Bevel to contain some of the controls
	Beveltop = ControlOffset;
	ControlOffset += BevelHeight;

	TextArea = UBrowserUpdateServerTextArea(CreateControl(TextAreaClass, 0, 0, 0, 0, Self));

	Join = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, 0, ControlWidth, ControlHeight));
	Join.SetText(JoinName);
	Join.SetHelpText(JoinHelp);
	Join.SetFont(ControlFont);

	InfoButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, 0, ControlWidth, ControlHeight));
	InfoButton.SetText(InfoButtonName);
	InfoButton.SetHelpText(InfoButtonHelp);
	InfoButton.SetFont(ControlFont);

	/*StatusButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 0, 0, ControlWidth, ControlHeight));
	StatusButton.SetText(StatusButtonName);
	StatusButton.SetHelpText(StatusButtonHelp);
	StatusButton.SetFont(ControlFont);*/

	OpenCombo = UWindowComboControl(CreateControl(class'CoopBrowserOpenComboControl', 0, 0, ControlWidth, OpenComboHeight));
	OpenCombo.SetText(OpenText);
	OpenCombo.SetHelpText(OpenHelp);
	OpenCombo.SetFont(F_SmallBold);
	OpenCombo.SetEditable(True);
	for( i = 0 ; i < 10 ; i++ )
	{
		if( OpenHistory[i] != "" )
			OpenCombo.AddItem(OpenHistory[i]);
	}
	OpenCombo.SetTextColor(OpenComboColor);

	PrintStatusLine("Initialized");
	PrintStatusLine("Enter server IP");
	PrintStatusLine("Check master server page to find server: <a href=http://master.333networks.com/s/postal2>MasterServer page</a>");
	PrintStatusLine("Please, don't forget about GamePort!");
	PrintStatusLine("...");
}

///steam 13/01/2017 TEST
/*function TestUdpThing()
{
	local TestUBrowserUDP UDPLink;
	UDPLink = GetPlayerOwner().GetEntryLevel().Spawn(class'TestUBrowserUDP');
	UDPLink.StartQuery();
}*/

function Notify(UWindowDialogControl C, byte E)
{
	switch(E)
	{
	case DE_Click:
		switch(C)
		{
		case Join:
			CallServerJoining();
			break;
		case InfoButton:
			CallStartCollectServerInfo();
			break;
		/*case StatusButton:
			CallPingServer();
			break;*/
		}
		break;
	}
	Super.Notify(C, E);
}

///steam 15/01/2017
function CallStartCollectServerInfo()
{
	/*testLink = GetPlayerOwner().GetEntryLevel().Spawn(class'testUBrowserLocalLink');
	testLink.myOwnerFactory = Self;
	testLink.Start(GetServerIP());
	PrintStatusLine(""@testLink);*/

	if( GetServerIP() == "" )
	{
		PrintStatusLine("ERROR: wrong server IP");
		return;
	}
	else if( Left(GetFullServerIP(),1) ~= "_" )
	{
		if( GetServerIP() ~= "_clear" )
		{
			TextArea.Clear();
			SetNewServerIP("");
		}
		return;
	}
	else if( GetServerGamePort() ~= "" || ((Len(GetServerGamePort()) > 4 || Len(GetServerGamePort()) < 4)) )
	{
		if( Left(GetFullServerIP(),10) ~= "postal2://" )
			SetNewServerIP(Right(GetFullServerIP(),Len(GetFullServerIP())-10));
		else SetNewServerIP(GetServerIP()$":7777");
		//PrintStatusLine("ERROR: wrong game port, example 192.168.1.31:7777");
		//return;
	}

	if( !bPinging )
	{
		PrintSimpleLine();
		PrintStatusLine("- INFO -"@"("$GetFullServerIP()$")");
		PrintStatusLine("connecting...");
		StartCollectServerInfo();
	}
	else PrintStatusLine("...already connecting");
}

///steam 15/01/2017
function CallPingServer()
{
	if( InStr(GetServerIP(), ":") != -1 )
	{
		PrintStatusLine("ERROR: can't get information with port");
		return;
	}
	if( !bPinging )
	{
		PrintStatusLine("- STATUS -"@"("$GetServerIP()$")");
		if( GetServerIP() == "" )
			PrintStatusLine("ERROR WRONG IP");
		PingServer(false,false,false);
	}
	else PrintStatusLine("...already connecting");
}

///steam 15/01/2017
function CallServerJoining()
{
	if( GetServerIP() == "" )
	{
		PrintStatusLine("ERROR: wrong server IP");
		return;
	}
	else if( GetServerGamePort() != "" && (Len(GetServerGamePort()) > 4 || Len(GetServerGamePort()) < 4) )
	{
		PrintStatusLine("ERROR: wrong game port, example 192.168.1.31:7777");
		return;
	}
	OpenURL();
}

function OpenURL()
{
	local int i;
	local bool HistoryItem;
	local UWindowComboListItem Item;
	local string URL;

	///URL = OpenCombo.GetValue();
	///URL = GetServerIP();
	URL = GetFullServerIP();
	if(URL == "")
	{
		OpenCombo.BringToFront();
		return;
	}
	
	for (i=0; i<10; i++)
	{
		if (OpenHistory[i] ~= URL)
			HistoryItem = True;
	}
	if (!HistoryItem)
	{
		OpenCombo.InsertItem(URL);
		while(OpenCombo.List.Items.Count() > 10)
			OpenCombo.List.Items.Last.Remove();

		Item = UWindowComboListItem(OpenCombo.List.Items.Next);
		for (i=0; i<10; i++)
		{
			if(Item != None)
			{
				OpenHistory[i] = Item.Value;
				Item = UWindowComboListItem(Item.Next);
			}
			else
				OpenHistory[i] = "";
		}			
	}
	SaveConfig();

	OpenCombo.ClearValue();
	UBrowserMainWindow(GetParent(class'UBrowserMainWindow')).OpenURL(URL);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local UBrowserMainWindow W;

	Super.BeforePaint(C, X, Y);
	LayoutBevel(C);

	W = UBrowserMainWindow(GetParent(class'UBrowserMainWindow'));
	if( bPinging )
		W.DefaultStatusBarText("Connecting to"@GetServerIP());
	else W.DefaultStatusBarText("");
}

function LayoutBevel(Canvas C)
{
	local float XL, YL;
	local float EditWidth;

	C.Font = Root.Fonts[OpenCombo.Font];
	TextSize(C, OpenCombo.Text, XL, YL);
	EditWidth = WinWidth*0.5;
	OpenCombo.WinLeft = (WinWidth - EditWidth) / 2;
	//OpenCombo.WinTop = (WinHeight-OpenCombo.WinHeight) / 2;
	OpenCombo.WinTop = BevelTop + (BevelHeight - OpenComboHeight)/2;
	OpenCombo.SetSize(EditWidth, OpenComboHeight);
	OpenCombo.EditBoxWidth = OpenCombo.WinWidth - XL - 20;
	OpenCombo.SetTextColor(OpenComboColor);

	C.Font = Root.Fonts[ControlFont];

	C.StrLen(JoinName, XL, YL);
	Join.SetSize(XL + ButtonTextPadding, ControlHeight);
	Join.WinLeft = BodyLeft + 10;
	Join.WinTop = BevelTop + (BevelHeight - ControlHeight)/2;

	/*C.StrLen(StatusButtonName, XL, YL);
	StatusButton.SetSize(XL + ButtonTextPadding, ControlHeight);
	StatusButton.WinLeft = (BodyLeft + BodyWidth) - ButtonSpacing - StatusButton.WinWidth;
	StatusButton.WinTop = BevelTop + (BevelHeight - ControlHeight)/2;*/

	C.StrLen(InfoButtonName, XL, YL);
	InfoButton.SetSize(XL + ButtonTextPadding, ControlHeight);
	//InfoButton.WinLeft = StatusButton.WinLeft - ButtonSpacing - InfoButton.WinWidth;
	InfoButton.WinLeft = (BodyLeft + BodyWidth) - ButtonSpacing - InfoButton.WinWidth;
	InfoButton.WinTop = BevelTop + (BevelHeight - ControlHeight)/2;

	TextArea.SetSize(BodyWidth - TEXTAREA_FRAME_SIZE*2, BodyHeight - TEXTAREA_FRAME_SIZE*2 - HelpHeight);
	TextArea.WinTop = BodyTop + BevelHeight + TEXTAREA_FRAME_SIZE;
	TextArea.WinLeft = BodyLeft + TEXTAREA_FRAME_SIZE;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);
	DrawUpBevel(C, BodyLeft, BevelTop, BodyWidth, BevelHeight, GetLookAndFeelTexture());
}

///steam 14/01/2017
function string GetFullServerIP()
{
	return OpenCombo.GetValue();
}

///steam 01/03/2017
function string GetServerGamePort()
{
	local int i;
	local string sTemp;

	sTemp = GetFullServerIP();
	i = InStr(sTemp, ":");
	if( i != -1 )
		return Mid(sTemp, i+1, Len(GetFullServerIP()));

	return "";
}

///steam 14/01/2017
function string GetServerIP()
{
	local int i;
	local string sTemp;

	sTemp = GetFullServerIP();
	i = InStr(sTemp, ":");
	if( i != -1 )
		sTemp = Left(sTemp, i);

	return sTemp;
}

///steam 14/01/2017
function int GetQueryPort()
{
	return int(GetServerGamePort())+1;
}

///steam 14/01/2017
function PrintStatusLine(string sLine)
{
	sLine = ">"@sLine;
	TextArea.SetHTML(sLine);
}

///steam 02/03/2017
function PrintSimpleLine()
{
	TextArea.SetHTML("<center>-----------------------------------------------------------</center>");
}

///steam 14/01/2017
function PingServer(bool bInitial, bool bJustThisServer, bool bNoSort)
{
	PrintStatusLine("connecting...");

	// Create the UdpLink to ping the server
	ServerPing = GetPlayerOwner().GetEntryLevel().Spawn(class'CoopBrowserJoinDirectStatusLink');
	//ServerPing.Server = Self;
	ServerPing.DirectWindowOwner = self;
	ServerPing.StartQuery('GetInfo', 2);
	ServerPing.bInitial = bInitial;
	ServerPing.bJustThisServer = bJustThisServer;
	ServerPing.bNoSort = bNoSort;
	bPinging = True;
}

///steam 15/01/2017
function ServerStatus()
{
	PrintStatusLine("connecting...");

	// Create the UdpLink to ping the server
	ServerPing = GetPlayerOwner().GetEntryLevel().Spawn(class'CoopBrowserJoinDirectStatusLink');
	//ServerPing.Server = Self;
	ServerPing.DirectWindowOwner = self;
	ServerPing.StartQuery('GetStatus', 2);
	bPinging = True;
}

///steam 14/01/2017
function PrintStatusInfo()
{
	local int nMinNetVer, nGameVer;

	PrintStatusLine("Server information:");
	PrintStatusLine("ServerName:"@HostName);
	PrintStatusLine("GameType:"@GameType);
	PrintStatusLine("Ping:"@int(Ping));
	PrintStatusLine("GamePort:"@GamePort);
	PrintStatusLine("bLocalServer:"@bLocalServer);
	PrintStatusLine("MapName:"@MapName);
	PrintStatusLine("MapTitle:"@MapTitle);
	PrintStatusLine("MapDisplayName:"@MapDisplayName);
	PrintStatusLine("GameMode:"@GameMode);
	PrintStatusLine("NumPlayers:"@NumPlayers);
	PrintStatusLine("MaxPlayers:"@MaxPlayers);
	PrintStatusLine("GameVer:"@GameVer);
	PrintStatusLine("MinNetVer:"@MinNetVer);

	nMinNetVer = int(GetPlayerOwner().Level.MinNetVersion);
	nGameVer = int(GetPlayerOwner().Level.EngineVersion);
	if( MinNetVer > nGameVer || nMinNetVer > GameVer )
		PrintStatusLine("WARNING: This server is not compatible! Because your game version is:"@nGameVer);

	//PrintStatusLine("...");
}

///steam 14/01/2017
function ErrorConnectingServer()
{
	PrintStatusLine("ERROR: Failed to connect");
	PrintStatusLine("...");
}

///steam 14/01/2017
function PingDone(bool bInitial, bool bJustThisServer, bool bSuccess, bool bNoSort)
{
	// Destroy the UdpLink
	if(ServerPing != None)
		ServerPing.Destroy();

	ServerPing = None;

	bPinging = False;
	bPingFailed = !bSuccess;
	bPinged = True;

	//if( bJoining && bSuccess )
	//	OpenURL();

	if( !bSuccess )
		ErrorConnectingServer();

	//if( bJoining )
	//	bJoining = false;
}

///steam 14/01/2017
function StatusDone(bool bSuccess)
{
	// Destroy the UdpLink
	ServerPing.Destroy();
	ServerPing = None;

	bPinging = False;

	if( !bSuccess )
		ErrorConnectingServer();
}

///steam 15/01/2017
function PlayerListRemoveAllInfo()
{
	if( PlayerListID.Length > 0 )
	{
		PlayerListID.Remove(0,PlayerListID.Length);
		PlayerListID.Length = 0;
	}

	if( PlayerListInfo.Length > 0 )
	{
		PlayerListInfo.Remove(0,PlayerListInfo.Length);
		PlayerListInfo.Length = 0;
	}
}

///steam 15/01/2017
function PlayerListAddInfo(int nID, string sInfo)
{
	local int i;
	local bool bFound;

	for( i = 0 ; i < PlayerListID.Length ; i++ )
	{
		if( PlayerListID[i] == nID )
		{
			PlayerListInfo[i] = PlayerListInfo[i]@sInfo$",";
			bFound = true;
		}
	}
	if( !bFound )
	{
		i = PlayerListID.Length;
		PlayerListID.Insert(PlayerListID.Length, 1.0);
		PlayerListID[i] = nID;

		i = PlayerListInfo.Length;
		PlayerListInfo.Insert(PlayerListInfo.Length, 1.0);
		PlayerListInfo[i] = PlayerListInfo[i]@sInfo$",";
	}
}

///steam 15/01/2017
function PrintPlayerListInfo()
{
	local int i;

	PrintStatusLine("Players list:");

	if( PlayerListID.Length > 0 )
	{
		for( i = 0 ; i < PlayerListID.Length ; i++ )
		{
			PrintStatusLine(PlayerListInfo[i]);
		}
	}
	else PrintStatusLine("no players on this server");

	PrintStatusLine("...");
}

///steam 01/03/2017
/*function xFoundGamePort(bool bFoundGamePort, optional int newQueryPort)
{
	if( bFoundGamePort )
	{
		PrintStatusLine("success!");
		SetNewQueryPort(newQueryPort);
		ServerPing.StartCollectServerInfo();
		return;
	}

	PrintStatusLine("ServerIP: <a href=DWSetIP."$GetServerIP()$":"$GamePort$">"$GetServerIP()$":"$GamePort$"</a>");
	PrintStatusLine("ServerName:"@HostName);
	PrintStatusLine("GameType:"@GameType);

	PrintStatusLine("...");
}*/

///steam 01/03/2017
function StartCollectServerInfo()
{
	ServerPing = GetPlayerOwner().GetEntryLevel().Spawn(class'CoopBrowserJoinDirectStatusLink');
	ServerPing.DirectWindowOwner = self;
	ServerPing.StartQuery('CollectServerInfoStepI', 2);

	bPinging = True;
}

///steam 01/03/2017
function SetNewServerIP(string newIP)
{
	OpenCombo.SetValue(newIP);
	OpenCombo.EditBox.CaretOffset = Len(newIP);
}

defaultproperties
{
	TextAreaClass=class'CoopBrowserJoinDirectWinTextArea'

	OpenComboColor=(R=0,G=0,B=0,A=255)
	OpenComboHeight=25.0

	MyHeaderText="Direct join, enter/paste or choose server IP from history and press Join button"

	JoinName="Join"
	JoinHelp="Enter/paste or choose server IP from history then click this button to join it."

	InfoButtonName="Info"
	InfoButtonHelp="Press to get server information"

	//StatusButtonName="Status"
	//StatusButtonHelp="Press to get server status (main information, server name, ping, version, map, etc)"

	BevelHeight=30
	ButtonTextPadding=20
	ButtonSpacing=8
}
