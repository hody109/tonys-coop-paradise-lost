//=============================================================================
// CoopEventMenu_IdlingWarning.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopEventMenu_IdlingWarning extends ShellMenuCW;

var localized string TitleText;
var localized string TextChoice1Text;
var localized string TextChoice2Text;
var localized string TextChoice3Text;
var ShellMenuChoice TextChoice1, TextChoice2, TextChoice3;
var bool bNameChanged;

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

function GoBack()
{
	Super.GoBack();
	Close();
	HideMenu();
}

defaultproperties
{
	TitleText="Warning"
	TextChoice1Text="You are standing too long without"
	TextChoice2Text="any actions, in that way you will be"
	TextChoice3Text="kicked from the server."
	MenuWidth=610.000000
	MenuHeight=400.000000
	TitleSpacingY=30.000000
	ItemSpacingY=15.000000
}
