//=============================================================================
// CoopBrowserFAQCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserFAQCW extends UWindowDialogClientWindow;//UWindowClientWindow;

var UWindowPageControl		PageControl;
var UWindowPageControlPage	FAQPage;
var localized string		FAQName, ChangeLogName;
var string					FAQPageClass;
var UBrowserInfoWindow		InfoWindow;

function Created() 
{
	local class<CoopBrowserFAQPageWindow> MC;

	Super.Created();

	InfoWindow = UBrowserInfoWindow(Root.CreateWindow(class'UBrowserInfoWindow', 10, 40, 310, 170));
	InfoWindow.HideWindow();

	PageControl = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth, WinHeight));
	PageControl.SetMultiLine(True);

	MC = class<CoopBrowserFAQPageWindow>(DynamicLoadObject(FAQPageClass, class'Class'));
	FAQPage = PageControl.AddPage(FAQName, MC);
}

function SelectFAQPage()
{
	PageControl.GotoTab(FAQPage, True);
}

function Resized()
{
	Super.Resized();
	PageControl.SetSize(WinWidth, WinHeight);
}

function SaveConfigs()
{
	SaveConfig();
}

defaultproperties
{
	ChangeLogName="Change log"
	FAQName="FAQ"
	FAQPageClass="NicksCoop.CoopBrowserFAQPageWindow"
}
