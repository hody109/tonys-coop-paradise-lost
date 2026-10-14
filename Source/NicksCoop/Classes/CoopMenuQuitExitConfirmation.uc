//=============================================================================
// CoopMenuQuitExitConfirmation.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMenuQuitExitConfirmation extends ShellMenuCW;

var localized string	ExitGameText;
var localized string	ExitGameTextHeight;
var ShellMenuChoice		YesChoice;

function CreateMenuContents()
{
	local array<string> tmparray;
	local Color TC;
	local ShellWrappedTextControl VerifyLeaveControl;

	TitleFont = F_FancyL;
	TitleAlign = TA_Center;
	ItemFont = F_FancyL;
	ItemAlign = TA_Center;

	//AddTitle(LeaveGameText, TitleFont, TitleAlign);

	VerifyLeaveControl = AddWrappedTextItem(tmparray, int(ExitGameTextHeight), F_Bold, ItemAlign);
	VerifyLeaveControl.Text = ExitGameText;

	TC.R = 155;
	TC.G = 155;
	TC.B = 155;
	TC.A = 255;
	VerifyLeaveControl.SetTextColor(TC);
	VerifyLeaveControl.bShadow = true;

	YesChoice  = AddChoice(YesText,	"", ItemFont, ItemAlign, false);
	BackChoice = AddChoice(NoText,	"", ItemFont, ItemAlign, true);
}

function Notify(UWindowDialogControl C, byte E)
{
	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			switch (C)
				{
				case BackChoice:
					GoBack();
					break;
				case YesChoice:
					CoopExitGame();
					break;
				}
			break;
		}
}

function CoopExitGame()
{
	//GetPlayerOwner().ConsoleCommand("disconnect");
	///ShellRootWindow(root).ExitApp();
	if( CoopShellRootWindow(root) != None )
		CoopShellRootWindow(root).CoopQuitCurrentGame();
	else ShellRootWindow(root).ExitApp();
}

defaultproperties
{
	ExitGameTextHeight="150"
	ExitGameText="You are hosting this server.  Ending this game will affect all players that joined it.\\n\\nAre you sure you want to Quit anyway?"
	MenuWidth=620
	MenuHeight=350
	ItemBorder=100
	bBlockConsole=false
}
