//=============================================================================
// CoopEventMenu_SameName.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopEventMenu_SameName extends ShellMenuCW;

var localized string TitleText;
var localized string TextChoice1Text;
var localized string TextChoice2Text;
var localized string TextChoice3Text;
var ShellMenuChoice TextChoice1, TextChoice2, TextChoice3;
var bool bNameChanged;

const NicksCoopClientNamePath = "NicksCoop.CoopMenu MultiPlayerName";
const NicksCoopHostNamePath = "NicksCoop.CoopMenu MultiPlayerHostName";

function CreateMenuContents()
{
	Super.CreateMenuContents();

	//ItemFont = F_FancyL;
	//ItemFont = 1;

	AddTitle(TitleText, TitleFont, TA_Left);

	TextChoice1 = AddChoice(TextChoice1Text,   "", ItemFont, TA_Left, true);
	TextChoice1.bActive = false;

	TextChoice2 = AddChoice(TextChoice2Text,   "", ItemFont, TA_Left, true);
	TextChoice2.bActive = false;

	TextChoice3 = AddChoice(TextChoice3Text,   "", ItemFont, TA_Left, true);
	TextChoice3.bActive = false;

	BackChoice = AddChoice("Ok",   "", ItemFont, TA_Left, true);
}

function Notify(UWindowDialogControl C, byte E)
{
	local int val;

	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				}
			break;
		}
}

function NameChanged()
{
	local string NewName;

	if( bNameChanged )
		return;
	bNameChanged = true;

	if( P2Player(GetPlayerOwner()) == None )
		return;

	NewName = P2Player(GetPlayerOwner()).PlayerReplicationInfo.PlayerName;

	GetPlayerOwner().ClientMessage("Name changed" @ NewName);
	GetPlayerOwner().ConsoleCommand("set" @ NicksCoopClientNamePath @ NewName);
	GetPlayerOwner().ConsoleCommand("set" @ NicksCoopHostNamePath @ NewName);
}

function GoBack()
{
	NameChanged();
	Super.GoBack();
	Close();
	HideMenu();
}

defaultproperties
{
	TitleText="Notice"
	TextChoice1Text="You are using existing name, it will"
	TextChoice2Text="be changed automaticaly, to change it,"
	TextChoice3Text="leave server and go to Player Options."
	MenuWidth=610.000000
	MenuHeight=400.000000
	TitleSpacingY=30.000000
	ItemSpacingY=15.000000
}
