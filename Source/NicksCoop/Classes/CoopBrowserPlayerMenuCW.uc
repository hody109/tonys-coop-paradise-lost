//=============================================================================
// CoopBrowserPlayerMenuCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserPlayerMenuCW extends UWindowDialogClientWindow;

var localized string PlayerSetupTabText;
var localized string BackText;

var UMenuPageControl Pages;
var UWindowSmallButton CloseButton;
var UWindowPageControlPage PlayerSetupTab;

function CreatePages()
{
	Pages = UMenuPageControl(CreateWindow(class'UMenuPageControl', 0, 0, WinWidth, WinHeight));
	Pages.SetMultiLine(true);
	PlayerSetupTab = Pages.AddPage(PlayerSetupTabText, class'CoopBrowserPlayerMenuSetupSC');
	CloseButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', WinWidth-56, WinHeight-24, 48, 16));
	CloseButton.SetText(BackText);
	CloseButton.SetFont(F_SmallBold);
}

function Created()
{
	Super.Created();
	CreatePages();
}

function Resized()
{
	Pages.WinWidth = WinWidth;
	Pages.Winheight = WinHeight - 24;

	CloseButton.WinLeft = WinWidth-52;
	CloseButton.WinTop = WinHeight-20;
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);

	switch(E)
	{
	case DE_Click:
		switch (C)
		{
		case CloseButton:
			UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).Close();
			break;
		}
	}
}

function Paint(Canvas C, float X, float Y)
{
	local Texture T;

	T = GetLookAndFeelTexture();
	DrawUpBevel( C, 0, LookAndFeel.TabUnselectedM.H, WinWidth, WinHeight-LookAndFeel.TabUnselectedM.H, T);
}

///steam 10/04/2016
function Close(optional bool bByParent) 
{
	if(Root != None)
		Root.GoBack();

	Super.Close(bByParent);
}

defaultproperties
{
	BackText="Close"
	PlayerSetupTabText="Setup"
}
