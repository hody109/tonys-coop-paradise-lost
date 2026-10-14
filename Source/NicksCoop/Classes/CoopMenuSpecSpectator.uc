//=============================================================================
// CoopMenuSpecSpectator.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopMenuSpecSpectator extends ShellMenuCW;

var localized string MenuUseTitle;

var UWindowComboControl SwitchTypeCombo;
var localized string SwitchTypeText;
var localized string SwitchTypeHelp;

var ShellMenuChoice SwitchButtonChoice;
var localized string SwitchButtonText;
var localized string SwitchButtonHelp;

function CreateMenuContents()
{
	Super.CreateMenuContents();
	
	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	AddTitle(MenuUseTitle, TitleFont, TitleAlign);

	SwitchTypeCombo = AddComboBox(SwitchTypeText, SwitchTypeHelp, ItemFont);
	SwitchButtonChoice = AddChoice(SwitchButtonText, SwitchButtonHelp, ItemFont, ItemAlign);

	BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	LoadValues();
}

function LoadValues()
{
	SwitchTypeCombo.Clear();
	SwitchTypeCombo.SetButtons(true);
	SwitchTypeCombo.EditBoxWidth += 120;

	SwitchTypeCombo.AddItem("Spectate players");
	SwitchTypeCombo.AddItem("Spectate NPC");
	SwitchTypeCombo.AddItem("Control animals");

	SwitchTypeCombo.SetSelectedIndex(CoopPlayerController(GetPlayerOwner()).SpecSpectateType);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case SwitchButtonChoice:
						CoopPlayerController(GetPlayerOwner()).NETSpecSpectateSwitch(SwitchTypeCombo.GetSelectedIndex());
						HideMenu();
						break;
					case BackChoice:
						GoBack();
						break;
					}
			break;
		}
}

defaultproperties
{
	MenuWidth=350
	MenuUseTitle="Special Spectator"
	SwitchTypeText="Type"
	SwitchTypeHelp=""
	SwitchButtonText="Confrim"
	SwitchButtonHelp="Press to confirm"
}
