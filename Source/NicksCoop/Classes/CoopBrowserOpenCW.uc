//=============================================================================
// CoopBrowserOpenCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserOpenCW extends UBrowserOpenCW;

var ShellMenuChoice TextCombo;
var ShellMenuChoice TextComboPlus;

function Created()
{
	local float EditWidth;
	local int i;

	Super(UWindowDialogClientWindow).Created();

	EditWidth = WinWidth - 140;
	OpenCombo = UWindowComboControl(CreateControl(class'CoopBrowserOpenComboControl', 20, 20, EditWidth, 25));///UWindowComboControl
	OpenCombo.SetText(OpenText);
	OpenCombo.SetHelpText(OpenHelp);
	OpenCombo.SetFont(F_SmallBold);
	OpenCombo.SetEditable(True);
	for (i=0; i<10; i++)
		if (OpenHistory[i] != "")
			OpenCombo.AddItem(OpenHistory[i]);

	TextCombo = ShellMenuChoice(CreateControl(class'ShellMenuChoice', 20, 20, EditWidth, 25));
	TextCombo.SetText("Enter server IP to join the game");
	TextCombo.SetFont(F_SmallBold);
	TextCombo.bActive = false;

	TextComboPlus = ShellMenuChoice(CreateControl(class'ShellMenuChoice', 20, 20, EditWidth, 25));
	TextComboPlus.SetText("You can paste it or choose from history");
	TextComboPlus.SetFont(F_SmallBold);
	TextComboPlus.bActive = false;

	TC.R = 0;
	TC.G = 0;
	TC.B = 0;
	TC.A = 255;
	OpenCombo.SetTextColor(TC);
}

function BeforePaint(Canvas C, float X, float Y)
{
	local float EditWidth;
	local float XL, YL;

	C.Font = Root.Fonts[OpenCombo.Font];
	TextSize(C, OpenCombo.Text, XL, YL);

	EditWidth = WinWidth - 50;

	OpenCombo.WinLeft = (WinWidth - EditWidth) / 2;
	OpenCombo.WinTop = (WinHeight-OpenCombo.WinHeight) / 1.05;
	OpenCombo.SetSize(EditWidth, OpenCombo.WinHeight);
	OpenCombo.EditBoxWidth = OpenCombo.WinWidth - XL - 20;

	Super(UWindowDialogClientWindow).BeforePaint(C, X, Y);

	OpenCombo.SetTextColor(TC);

/// text info
	TextSize(C, TextCombo.Text, XL, YL);

	TextCombo.WinLeft = (WinWidth - EditWidth) / 2;
	TextCombo.WinTop = (WinHeight-TextCombo.WinHeight) / 8;
	TextCombo.SetSize(EditWidth, TextCombo.WinHeight);

	TextCombo.SetTextColor(TC);

/// text info
	TextSize(C, TextComboPlus.Text, XL, YL);

	TextComboPlus.WinLeft = (WinWidth - EditWidth) / 2;
	TextComboPlus.WinTop = (WinHeight-TextComboPlus.WinHeight) / 3;
	TextComboPlus.SetSize(EditWidth, TextComboPlus.WinHeight);

	TextComboPlus.SetTextColor(TC);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super(UWindowDialogClientWindow).Notify(C, E);

	if(ParentWindow == None || OpenCombo == None)
		return;

	if((C == OpenCombo && E == DE_EnterPressed) ||
	   (C == UBrowserOpenWindow(ParentWindow).OKButton && E == DE_Click))
		OpenURL();
	
	OpenCombo.SetTextColor(TC);
}

function OpenURL()
{
	local int i;
	local bool HistoryItem;
	local UWindowComboListItem Item;
	local string URL;

	URL = OpenCombo.GetValue();
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
	CoopBrowserOpenWindow(GetParent(class'UWindowFramedWindow')).OpenURL(URL);
}

///steam 17/03/2016
/*function Close(optional bool bByParent) 
{
	///steam 17/03/2016
	///if(Root != None)
	///	Root.GoBack();

	Super(UWindowWindow).Close(bByParent);
}*/

///steam 10/04/2016
function Close(optional bool bByParent) 
{
	if(Root != None)
		Root.GoBack();

	Super.Close(bByParent);
}

defaultproperties
{
	OpenText="Server URL"
	OpenHelp="Enter a standard URL, or select one from the URL history."
}