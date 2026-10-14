//=============================================================================
// CoopBrowserPageWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserPageWindow extends UBrowserPageWindow;

var array<int> nBrowserHistory;
var array<string> HTMLHeaders;
var array<string> HTMLPages;

var CoopBrowserPageButton BackButton;
var CoopBrowserPageButton HomeButton;

var CoopBrowserTextArea TextArea;

var class<CoopBrowserTextArea> TextAreaClass;

var localized string ConsoleCommandHelpText;

const TEXTAREA_FRAME_SIZE = 3;
const TEXTAREA_FRAME_TOP = 8;

function Created()
{
	Super.Created();

	TextArea = CoopBrowserTextArea(CreateControl(TextAreaClass, 0, 0, 0, 0, Self));
	SetAcceptsFocus();

	BackButton = CoopBrowserPageButton(CreateControl(class'CoopBrowserPageButton', WinWidth-56, WinHeight-24, 48, 16));
	BackButton.CustomTextureStr = "LnF_back";
	BackButton.SetText("");
	HomeButton = CoopBrowserPageButton(CreateControl(class'CoopBrowserPageButton', WinWidth-106, WinHeight-24, 48, 16));
	HomeButton.CustomTextureStr = "LnF_home";
	HomeButton.SetText("");

	ForceOpenUnrealBrowserLink(0);
}

function Resized()
{
	Super.Resized();

	BackButton.WinLeft = WinLeft+2;
	BackButton.WinTop = WinTop;
	HomeButton.WinLeft = WinLeft+52;
	HomeButton.WinTop = WinTop;
}

function Notify(UWindowDialogControl C, byte E)
{
	//Super.Notify(C, E);
	Super(UWindowPageWindow).Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
		case HomeButton:
			HomePressed();
			break;
		case BackButton:
			BackPressed();
			break;
		}
	}
}

function CoopBrowserSelectLink(string URL)
{
	if( helparea != None )
	{
		if( InStr(caps(URL), "UBL") >= 0 )
			helparea.SetText(HTMLHeaders[int(Mid(URL,4,Len(URL)-4))]);
		else if( InStr(caps(URL), "CONCOM") >= 0 )
			helparea.SetText(ConsoleCommandHelpText);
		else helparea.SetText(URL);
	}
}

function HomePressed()
{
	OpenUnrealBrowserLink(0);
}

function BackPressed()
{
	if( nBrowserHistory.Length == 0 )
	{
		ForceOpenUnrealBrowserLink(0);
		return;
	}
	nBrowserHistory.Remove(nBrowserHistory.Length-1, 1.0);
	ForceOpenUnrealBrowserLink(nBrowserHistory[nBrowserHistory.Length-1]);
}

function ForceOpenUnrealBrowserLink(int nURL)
{
	if( nURL < 0 )
		nURL = 0;
	SetHTML(HTMLPages[nURL]);
	PageHeaderText = HTMLHeaders[nURL];
	PageHeader.SetText(PageHeaderText);
}

function OpenUnrealBrowserLink(int nURL)
{
	local int nHistoryLength;
	nHistoryLength = nBrowserHistory.Length;
	nBrowserHistory.Insert(nHistoryLength, 1.0);
	nBrowserHistory[nHistoryLength] = nURL;
	ForceOpenUnrealBrowserLink(nURL);
	///BackButton.SetText(""$nURL);
}

function EnterCoopConsoleCommand(string TextCommand)
{
	local Console UseConsole;
	if (GetPlayerOwner().Player.InteractionMaster != None)
	{
		UseConsole = Console(GetPlayerOwner().Player.InteractionMaster.Console);
		if (UseConsole != None)
		{
			UseConsole.ConsoleOpen();
			UseConsole.TypedStr = TextCommand;
		}
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	TextArea.SetSize(BodyWidth- TEXTAREA_FRAME_SIZE*2, BodyHeight - TEXTAREA_FRAME_SIZE*2 - TEXTAREA_FRAME_TOP);
	TextArea.WinTop = BodyTop + TEXTAREA_FRAME_SIZE + TEXTAREA_FRAME_TOP;
	TextArea.WinLeft = BodyLeft + TEXTAREA_FRAME_SIZE;
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	//LookAndFeel.DrawFrame(self, C, BodyLeft, BodyTop, BodyWidth, BodyHeight);
}

function SetHTML(string HTML)
{
	TextArea.SetHTML(HTML);
}

function KeyDown(int Key, float X, float Y) 
{
	switch(Key)
	{
	case 0x74: // IK_F5;
		//TextArea.Clear();
		break;
	}
}

defaultproperties
{
	ConsoleCommandHelpText="Auto type the console command"
	PageHeaderText="Hello world"
	TextAreaClass=class'CoopBrowserTextArea'
	bHelpArea=true
}