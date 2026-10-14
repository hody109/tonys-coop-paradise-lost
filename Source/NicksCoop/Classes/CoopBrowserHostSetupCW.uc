//=============================================================================
// CoopBrowserHostSetupCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserHostSetupCW extends UMenuPageWindow;
//UMenuServerSetupPage;

var bool bInitialized;
var bool bUpdate;

var UWindowCheckBox DedicatedCheck;
var localized string DedicatedText;
var localized string DedicatedHelp;
//var config bool bDedicated;

var UWindowCheckBox LoadIntroCheck;
var localized string LoadIntroText;
var localized string LoadIntroHelp;

var localized string DedicatedWarningTitle;
var localized string DedicatedWarningText;

var UWindowEditControl ServerNameEdit;
var localized string ServerNameText;
var localized string ServerNameHelp;

var UWindowCheckbox DoUplinkCheck;
var localized string DoUplinkText;
var localized string DoUplinkHelp;

var UWindowEditControl GamePasswordEdit;
var localized string GamePasswordText;
var localized string GamePasswordHelp;

var UWindowEditControl AdminPasswordEdit;
var localized string AdminPasswordText;
var localized string AdminPasswordHelp;

///steam 09/03/2016
var UWindowComboControl DifficultyCombo;
var localized string DifficultyText;
var localized string DifficultyHelp;

///steam 09/05/2016
var UWindowComboControl		StoryModeCombo;
var localized string		StoryModeText;
var localized string		StoryModeHelp;
var localized string		StoryModeTypes[3];

var Class IpServerClass;

///steam 12/11/2016
var UWindowHSliderControl FriendlyFireSlider;
var localized string FriendlyFireText;
var localized string FriendlyFireHelp;

///steam 21/11/2016
var UWindowHSliderControl PlayersLimitSlider;
var localized string PlayersLimitText;
var localized string PlayersLimitHelp;

///steam 17/08/2017
var UWindowHSliderControl SpectatorsLimitSlider;
var localized string SpectatorsLimitText;
var localized string SpectatorsLimitHelp;

///steam 12/11/2016
var UWindowCheckBox NoHolidaysCheck;
var localized string NoHolidaysText;
var localized string NoHolidaysHelp;

///steam 07/08/2016
var UWindowHSliderControl TravelPercentSlider;
var localized string TravelPercentText;
var localized string TravelPercentHelp;

var UWindowCheckBox RagdollSyncCheck;
var localized string RagdollSyncText;
var localized string RagdollSyncHelp;

var UWindowHSliderControl PawnGoalLimitSlider;
var localized string PawnGoalLimitText;
var localized string PawnGoalLimitHelp;

///var CoopBrowserJoinClientWindow CoopClientParentWindow;

///steam 25/11/2016
var bool bUseStoryCombo;

///steam 26/06/2017
var bool bUseLoadIntroCheckbox;
var bool bUseNoHolidaysCheckbox;
var bool bUseDedicatedCheckbox;

const GAME_PASSWORD_LOCATION = "Engine.AccessControl";
const ServerLoadIntroPath = "NicksCoop.CoopBrowserHostCW bServerLoadIntro";
const ServerNamePath = "Engine.GameReplicationInfo ServerName";
const ServerStoryModePath = "NicksCoop.CoopGameInfo CoopStoryModeType";
const ServerFriendlyFirePath = "NicksCoop.CoopGameInfo CoopFriendlyFireScale";
const ServerPlayersLimitPath = "Engine.GameInfo MaxPlayers";
const ServerNoHolidaysPath = "Postal2Game.P2GameInfoSingle bNoHolidays";
const ServerCoopDedicatedPath = "NicksCoop.CoopBrowserHostCW bServerCoopDedicated";
const ServerTravelPercentPath = "NicksCoop.CoopGameInfo CoopTravelAccessPercent";
const ServerSpectatorsLimitPath = "Engine.GameInfo MaxSpectators";
const ServerRagdollSyncPath = "NicksCoop.CoopGameInfo bCoopRagdollSync";
const PawnGoalLimitPath = "NicksCoop.CoopGameInfo CoopSliderPawnGoalMax";

///steam 09/03/2016
const c_strDifficultyPath = "Postal2Game.P2GameInfo GameDifficulty";
const c_strDifficultyNumberPath = "Postal2Game.P2GameInfo GameDifficultyNumber";
const LieberPath = "Postal2Game.P2GameInfo bLieberMode";
const HestonPath = "Postal2Game.P2GameInfo bHestonMode";
const TheyHateMePath = "Postal2Game.P2GameInfo bTheyHateMeMode";
const InsaneoPath = "Postal2Game.P2GameInfo bInsaneoMode";
const ExpertPath = "Postal2Game.P2GameInfo bExpertMode";
const LudicrousPath = "Postal2Game.P2GameInfo bLudicrousMode";
const CustomPath = "Postal2Game.P2GameInfo bCustomMode";

function Created()
{
	local class<CoopMenu> CoopMenuClass;

	bInitialized = false;

	Super.Created();

	///CoopClientParentWindow = CoopBrowserJoinClientWindow(GetParent(class'CoopBrowserJoinClientWindow'));

	CoopMenuClass = CoopShellRootWindow(Root).CoopMenuClass;

	if( CoopMenuClass == None )
		CoopMenuClass = class'CoopMenu';

	bUseDedicatedCheckbox = CoopMenuClass.default.bUseDedicatedCheckbox && !PlatformIsMacOS() && !PlatformIsUnix();

	if( bUseDedicatedCheckbox )
	{
	DedicatedCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	DedicatedCheck.SetText(DedicatedText);
	DedicatedCheck.SetHelpText(DedicatedHelp);
	DedicatedCheck.SetFont(ControlFont);
	//DedicatedCheck.SetValue(bDedicated);
	DedicatedCheck.bChecked = GetPlayerOwner().ConsoleCommand("get"@ServerCoopDedicatedPath) ~= "True";
	ControlOffset += (ControlHeight * 1.25);
	}

	///steam 04/01/2017
	bUseStoryCombo = CoopMenuClass.default.bUseStoryCombo;

	if( bUseStoryCombo )
	{
	StoryModeCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	StoryModeCombo.SetButtons(True);
	StoryModeCombo.SetText(StoryModeText);
	StoryModeCombo.SetHelpText(StoryModeHelp);
	StoryModeCombo.SetFont(ControlFont);
	StoryModeCombo.SetEditable(False);
	StoryModeCombo.Align = TA_Left;
	StoryModeCombo.Clear();
	StoryModeCombo.AddItem(StoryModeTypes[0]);
	StoryModeCombo.AddItem(StoryModeTypes[1]);
	StoryModeCombo.AddItem(StoryModeTypes[2]);
	StoryModeCombo.SetSelectedIndex(int(GetPlayerOwner().ConsoleCommand("get"@ServerStoryModePath)));
	ControlOffset += (ControlHeight * 1.25);
	}

	///steam 26/06/2017
	bUseLoadIntroCheckbox = CoopMenuClass.default.bUseLoadIntroCheckbox;

	if( bUseLoadIntroCheckbox )
	{
	LoadIntroCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	LoadIntroCheck.SetText(LoadIntroText);
	LoadIntroCheck.SetHelpText(LoadIntroHelp);
	LoadIntroCheck.SetFont(ControlFont);
	LoadIntroCheck.bChecked = GetPlayerOwner().ConsoleCommand("get"@ServerLoadIntroPath) ~= "True";
	ControlOffset += (ControlHeight * 1.25);
	}

	DifficultyCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	DifficultyCombo.SetButtons(True);
	DifficultyCombo.SetText(DifficultyText);
	DifficultyCombo.SetHelpText(DifficultyHelp);
	DifficultyCombo.SetFont(ControlFont);
	DifficultyCombo.SetEditable(False);
	DifficultyCombo.Align = TA_Left;
	ControlOffset += (ControlHeight * 1.25);

	DoUplinkCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	DoUplinkCheck.SetText(DoUplinkText);
	DoUplinkCheck.SetHelpText(DoUplinkHelp);
	DoUplinkCheck.SetFont(ControlFont);
	// Force IPServer to load!!!
	IPServerClass = Class(DynamicLoadObject("IpDrv.UdpServerUplink", class'Class'));
	DoUplinkCheck.bChecked = GetPlayerOwner().ConsoleCommand("get IpDrv.UdpServerUplink DoUplink") ~= "True";
	ControlOffset += (ControlHeight * 1.25);

	ServerNameEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ServerNameEdit.SetText(ServerNameText);
	ServerNameEdit.SetHelpText(ServerNameHelp);
	ServerNameEdit.SetFont(ControlFont);
	ServerNameEdit.SetNumericOnly(False);
	ServerNameEdit.SetMaxLength(205);
	ServerNameEdit.SetDelayedNotify(True);
	//ServerNameEdit.SetValue(class'Engine.GameReplicationInfo'.default.ServerName);
	ServerNameEdit.SetValue(GetPlayerOwner().ConsoleCommand("get"@ServerNamePath));
	ControlOffset += (ControlHeight * 1.25);

	GamePasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	GamePasswordEdit.SetText(GamePasswordText);
	GamePasswordEdit.SetHelpText(GamePasswordHelp);
	GamePasswordEdit.SetFont(ControlFont);
	GamePasswordEdit.SetNumericOnly(False);
	GamePasswordEdit.SetMaxLength(16);
	GamePasswordEdit.SetDelayedNotify(True);
	GamePasswordEdit.SetValue(GetPlayerOwner().ConsoleCommand("get" @ GAME_PASSWORD_LOCATION @ "GamePassword"));
	ControlOffset += (ControlHeight * 1.25);

	AdminPasswordEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	AdminPasswordEdit.SetText(AdminPasswordText);
	AdminPasswordEdit.SetHelpText(AdminPasswordHelp);
	AdminPasswordEdit.SetFont(ControlFont);
	AdminPasswordEdit.SetNumericOnly(False);
	AdminPasswordEdit.SetMaxLength(16);
	AdminPasswordEdit.SetDelayedNotify(True);
	//AdminPasswordEdit.SetValue(GetPlayerOwner().ConsoleCommand("get" @ GAME_PASSWORD_LOCATION @ "AdminPassword"));
	AdminPasswordEdit.SetValue(class'UMenuBotmatchClientWindow'.default.AdminPassword);
	ControlOffset += (ControlHeight * 1.25);

	///steam 12/11/2016
	FriendlyFireSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	FriendlyFireSlider.SetRange(0, 10, 1);
	FriendlyFireSlider.SetValue(float(GetPlayerOwner().ConsoleCommand("get"@ServerFriendlyFirePath))*10);
	FriendlyFireSlider.SetText(FriendlyFireText$" ("$(int(FriendlyFireSlider.GetValue()*10))$"%)");
	FriendlyFireSlider.SetHelpText(FriendlyFireHelp);
	FriendlyFireSlider.SetFont(ControlFont);
	ControlOffset += (ControlHeight * 1.25);

	///steam 21/11/2016
	PlayersLimitSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	PlayersLimitSlider.SetRange(2, 16, 1);
	PlayersLimitSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get"@ServerPlayersLimitPath)));
	PlayersLimitSlider.SetText(PlayersLimitText$" ("$(int(PlayersLimitSlider.GetValue()))$")");
	PlayersLimitSlider.SetHelpText(PlayersLimitHelp);
	PlayersLimitSlider.SetFont(ControlFont);
	ControlOffset += (ControlHeight * 1.25);

	///steam 17/08/2017
	SpectatorsLimitSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	SpectatorsLimitSlider.SetRange(0, 16, 1);
	SpectatorsLimitSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get"@ServerSpectatorsLimitPath)));
	SpectatorsLimitSlider.SetText(SpectatorsLimitText$" ("$(int(SpectatorsLimitSlider.GetValue()))$")");
	SpectatorsLimitSlider.SetHelpText(SpectatorsLimitHelp);
	SpectatorsLimitSlider.SetFont(ControlFont);
	ControlOffset += (ControlHeight * 1.25);

	///steam 07/08/2017
	TravelPercentSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	TravelPercentSlider.SetRange(0, 10, 1);
	TravelPercentSlider.SetValue(float(GetPlayerOwner().ConsoleCommand("get"@ServerTravelPercentPath))*10);
	TravelPercentSlider.SetText(TravelPercentText$" ("$(int(TravelPercentSlider.GetValue()*10))$"%)");
	TravelPercentSlider.SetHelpText(TravelPercentHelp);
	TravelPercentSlider.SetFont(ControlFont);
	ControlOffset += (ControlHeight * 1.25);

	///steam 26/06/2017
	bUseNoHolidaysCheckbox = CoopMenuClass.default.bUseNoHolidaysCheckbox;

	if( bUseNoHolidaysCheckbox )
	{
	NoHolidaysCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	NoHolidaysCheck.SetText(NoHolidaysText);
	NoHolidaysCheck.SetHelpText(NoHolidaysHelp);
	NoHolidaysCheck.SetFont(ControlFont);
	NoHolidaysCheck.bChecked = GetPlayerOwner().ConsoleCommand("get"@ServerNoHolidaysPath) ~= "True";
	ControlOffset += (ControlHeight * 1.25);
	}

	RagdollSyncCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	RagdollSyncCheck.SetText(RagdollSyncText);
	RagdollSyncCheck.SetHelpText(RagdollSyncHelp);
	RagdollSyncCheck.SetFont(ControlFont);
	RagdollSyncCheck.bChecked = GetPlayerOwner().ConsoleCommand("get"@ServerRagdollSyncPath) ~= "True";
	RagdollSyncCheck.bDisabled = DedicatedCheck.bChecked;
	ControlOffset += (ControlHeight * 1.25);

	PawnGoalLimitSlider = UWindowHSliderControl(CreateControl(class'UWindowHSliderControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	PawnGoalLimitSlider.SetRange(0, 30, 1);
	PawnGoalLimitSlider.SetValue(int(GetPlayerOwner().ConsoleCommand("get"@PawnGoalLimitPath)));
	PawnGoalLimitSlider.SetText(PawnGoalLimitText$" ("$(int(PawnGoalLimitSlider.GetValue()))$")");
	PawnGoalLimitSlider.SetHelpText(PawnGoalLimitHelp);
	PawnGoalLimitSlider.SetFont(ControlFont);
	ControlOffset += (ControlHeight * 1.25);

	bInitialized = true;
}

function AfterCreate()
{
	local P2GameInfoSingle psg;
	local int i, val;

	psg = P2GameInfoSingle(GetPlayerOwner().Level.Game);

	Super.AfterCreate();

	bUpdate = false;

	if( DifficultyCombo != None )
	{
		DifficultyCombo.Clear();

		for( i=0; i<ArrayCount(psg.DifficultyNames); i++ )
			DifficultyCombo.AddItem(psg.DifficultyNames[i]);

		///steam 22/04/2016
		val = int(GetPlayerOwner().ConsoleCommand("get"@c_strDifficultyNumberPath));///c_strDifficultyPath

		DifficultyCombo.SetValue(psg.DifficultyNames[val]);
	}

	bUpdate = true;
}

function Notify(UWindowDialogControl C, byte E)
{
	if(bInitialized && bUpdate)
	{
		switch(E)
		{
		case DE_Change:
			switch(C)
			{
			case DedicatedCheck:
				/*bDedicated = DedicatedCheck.bChecked;
				SaveConfigs();*/
				///if( DedicatedCheck.bChecked )
				///	CoopClientParentWindow.MessageBoxWindow = MessageBox(DedicatedWarningTitle, DedicatedWarningText, MB_OK, MR_OK);
				GetPlayerOwner().ConsoleCommand("set"@ServerCoopDedicatedPath@DedicatedCheck.GetValue());
				RagdollSyncCheck.bDisabled = DedicatedCheck.bChecked;
				break;
			case LoadIntroCheck:
				GetPlayerOwner().ConsoleCommand("set"@ServerLoadIntroPath@LoadIntroCheck.GetValue());
				break;
			case ServerNameEdit:
				//class'Engine.GameReplicationInfo'.default.ServerName = ServerNameEdit.GetValue();
				GetPlayerOwner().ConsoleCommand("set"@ServerNamePath@ServerNameEdit.GetValue());
				break;
			case DoUplinkCheck:
				if(DoUplinkCheck.bChecked)
					GetPlayerOwner().ConsoleCommand("set IpDrv.UdpServerUplink DoUplink True");
				else
					GetPlayerOwner().ConsoleCommand("set IpDrv.UdpServerUplink DoUplink False");
				IPServerClass.Static.StaticSaveConfig();
				break;
			///
			case GamePasswordEdit:
				GetPlayerOwner().ConsoleCommand("set" @ GAME_PASSWORD_LOCATION @ "GamePassword "$GamePasswordEdit.GetValue());
				break;
			case AdminPasswordEdit:
				//GetPlayerOwner().ConsoleCommand("set" @ GAME_PASSWORD_LOCATION @ "AdminPassword "$AdminPasswordEdit.GetValue());
				class'UMenuBotmatchClientWindow'.default.AdminPassword = AdminPasswordEdit.GetValue();
				class'UMenuBotmatchClientWindow'.static.StaticSaveConfig();
				break;
			case DifficultyCombo:
				DiffChanged();
				break;
			case StoryModeCombo:
				StoryModeTypeChanged();
				break;
			case FriendlyFireSlider:
				FriendlyFireChanged();
				break;
			case PlayersLimitSlider:
				PlayersLimitChanged();
				break;
			case PawnGoalLimitSlider:
				PawnGoalLimitChanged();
				break;
			case SpectatorsLimitSlider:
				SpectatorsLimitChanged();
				break;
			case TravelPercentSlider:
				TravelPercentChanged();
				break;
			case NoHolidaysCheck:
				GetPlayerOwner().ConsoleCommand("set"@ServerNoHolidaysPath@NoHolidaysCheck.GetValue());
				break;
			case RagdollSyncCheck:
				GetPlayerOwner().ConsoleCommand("set"@ServerRagdollSyncPath@RagdollSyncCheck.GetValue());
				break;
			}
			break;
		}
	}
	Super.Notify(C, E);
}

function StoryModeTypeChanged()
{
	GetPlayerOwner().ConsoleCommand("set"@ServerStoryModePath@StoryModeCombo.GetSelectedIndex());
}

function FriendlyFireChanged()
{
	GetPlayerOwner().ConsoleCommand("set"@ServerFriendlyFirePath@(FriendlyFireSlider.GetValue()/10));
	FriendlyFireSlider.SetText(FriendlyFireText$" ("$int(FriendlyFireSlider.GetValue()*10)$"%)");
}

function PlayersLimitChanged()
{
	GetPlayerOwner().ConsoleCommand("set"@ServerPlayersLimitPath@(PlayersLimitSlider.GetValue()));
	PlayersLimitSlider.SetText(PlayersLimitText$" ("$int(PlayersLimitSlider.GetValue())$")");
}

function PawnGoalLimitChanged()
{
	GetPlayerOwner().ConsoleCommand("set"@PawnGoalLimitPath@(PawnGoalLimitSlider.GetValue()));
	PawnGoalLimitSlider.SetText(PawnGoalLimitText$" ("$int(PawnGoalLimitSlider.GetValue())$")");
}

function SpectatorsLimitChanged()
{
	GetPlayerOwner().ConsoleCommand("set"@ServerSpectatorsLimitPath@(SpectatorsLimitSlider.GetValue()));
	SpectatorsLimitSlider.SetText(SpectatorsLimitText$" ("$int(SpectatorsLimitSlider.GetValue())$")");
}

function TravelPercentChanged()
{
	GetPlayerOwner().ConsoleCommand("set"@ServerTravelPercentPath@(TravelPercentSlider.GetValue()/10));
	TravelPercentSlider.SetText(TravelPercentText$" ("$int(TravelPercentSlider.GetValue()*10)$"%)");
}

function DiffChanged()
{
	local string diffname;
	local int val, diffnum;
	local P2GameInfoSingle psg;
	local bool bLieberMode, bHestonMode, bTheyHateMeMode, bInsaneoMode, bExpertMode;
	local bool bTheyHateMeWarning, bPOSTALWarning;
	local class<P2GameInfoSingle> GameClass;
	local class<CoopMenu> CoopMenuClass;

	CoopMenuClass = CoopShellRootWindow(Root).CoopMenuClass;

	if( CoopMenuClass == None )
		CoopMenuClass = class'CoopMenu';

	psg = P2GameInfoSingle(GetPlayerOwner().Level.Game);

	diffname = DifficultyCombo.GetValue();
	//log(self$" DiffChanged diffname after change "$diffname,'Debug');
	
	// Lieber Mode
	if(diffname == psg.DifficultyNames[0])
	{
		val = 0;
		diffnum = 0;
		bLieberMode = True;
	}
	else if(diffname == psg.DifficultyNames[1])
	{
		val = 1;
		diffnum = 1;
	}
	else if(diffname == psg.DifficultyNames[2])
	{
		val = 2;
		diffnum = 2;
	}
	else if(diffname == psg.DifficultyNames[3])
	{
		val = 3;
		diffnum = 3;
	}
	else if(diffname == psg.DifficultyNames[4])
	{
		val = 4;
		diffnum = 4;
	}
	else if(diffname == psg.DifficultyNames[5])
	{
		val = 5;
		diffnum = 5;
	}
	else if(diffname == psg.DifficultyNames[6])
	{
		val = 6;
		diffnum = 6;
	}
	else if(diffname == psg.DifficultyNames[7])
	{		
		val = 7;
		diffnum = 7;
	}
	else if(diffname == psg.DifficultyNames[8])
	{
		val = 8;
		diffnum = 8;
	}
	else if(diffname == psg.DifficultyNames[9])
	{
		val = 9;
		diffnum = 9;
	}
	// Heston Mode
	else if(diffname == psg.DifficultyNames[10])
	{
		val = 10;
		diffnum = 10;
		bHestonMode = True;
	}
	// Insaneo Mode
	// Game doesn't get any more difficult past this point in terms of AI --
	// just various bullshit things we throw at the player like NPC's with big guns.
	// Otherwise, POSTAL and Impossible mode would truly be impossible.
	else if(diffname == psg.DifficultyNames[11])
	{
		val = 10;
		diffnum = 11;
		bInsaneoMode = True;
	}
	// They Hate Me Mode
	else if(diffname == psg.DifficultyNames[12])
	{
		val = 10;
		diffnum = 12;
		bTheyHateMeMode = True;
		bTheyHateMeWarning = True;
	}
	// POSTAL mode - turns on Hestonworld, They Hate Me, and Expert
	else if(diffname == psg.DifficultyNames[13])
	{
		val = 10;
		diffnum = 13;
		bHestonMode = True;
		bTheyHateMeMode = True;
		bExpertMode = True;
		bPOSTALWarning = True;
	}
	// Impossible Mode - turns on Insaneo, They Hate Me, and Expert
	else if(diffname == psg.DifficultyNames[14])
	{
		val = 10;
		diffnum = 14;
		bInsaneoMode = True;
		bTheyHateMeMode = True;
		bExpertMode = True;
		bPOSTALWarning = True;
	}
	// Custom mode - reset to Average difficulty
	else
	{
		val = 5;
		diffnum = 5;
	}
	// set diff
	GameClass = class<P2GameInfoSingle>(CoopMenuClass.default.ServerGameType);
	//log(self$" DiffChanged"@GameClass@"diff value "$val@"diff num"@diffnum@"Lieber Heston Hate Insane Expert"@bLieberMode@bHestonMode@bTheyHateMeMode@bInsaneoMode@bExpertMode,'Debug');

	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyPath@val);
	GetPlayerOwner().ConsoleCommand("set"@c_strDifficultyNumberPath@diffnum);
	GetPlayerOwner().ConsoleCommand("set"@LieberPath@bLieberMode);
	psg.TheGameState.bLieberMode = bLieberMode;
	GameClass.Default.bLieberMode = bLieberMode;
	GetPlayerOwner().ConsoleCommand("set"@HestonPath@bHestonMode);
	psg.TheGameState.bHestonMode = bHestonMode;
	GameClass.Default.bHestonMode = bHestonMode;
	GetPlayerOwner().ConsoleCommand("set"@TheyHateMePath@bTheyHateMeMode);
	psg.TheGameState.bTheyHateMeMode = bTheyHateMeMode;
	GameClass.Default.bTheyHateMeMode = bTheyHateMeMode;
	GetPlayerOwner().ConsoleCommand("set"@InsaneoPath@bInsaneoMode);
	psg.TheGameState.bInsaneoMode = bInsaneoMode;
	GameClass.Default.bInsaneoMode = bInsaneoMode;
	GetPlayerOwner().ConsoleCommand("set"@ExpertPath@bExpertMode);
	psg.TheGameState.bExpertMode = bExpertMode;
	GameClass.Default.bExpertMode = bExpertMode;
	GetPlayerOwner().ConsoleCommand("set"@CustomPath@"false");
	psg.TheGameState.bCustomMode = false;
	GameClass.Default.bCustomMode = false;
	GetPlayerOwner().ConsoleCommand("set"@LudicrousPath@"false");
	psg.TheGameState.bLudicrousMode = False;
	GameClass.Default.bLudicrousMode = False;
	GameClass.StaticSaveConfig();
	psg.GameDifficulty = val;
	// Update the gamestate here, also, if we have one
	if(psg.TheGameState != None)
		psg.TheGameState.GameDifficulty = val;
}

function BeforePaint(Canvas C, float X, float Y)
{
	local Color RedTC;

	Super.BeforePaint(C, X, Y);

	if( bUseDedicatedCheckbox )
	{
	DedicatedCheck.SetSize(CheckWidth, ControlHeight);
	DedicatedCheck.WinLeft = ControlLeft;
	DedicatedCheck.SetTextColor(TC);
	}

	if( bUseLoadIntroCheckbox )
	{
	LoadIntroCheck.SetSize(CheckWidth, ControlHeight);
	LoadIntroCheck.WinLeft = ControlLeft;
	LoadIntroCheck.SetTextColor(TC);
	}

	ServerNameEdit.SetSize(ControlWidth, ControlHeight);
	ServerNameEdit.WinLeft = ControlLeft;
	ServerNameEdit.EditBoxWidth = EditWidth;
	ServerNameEdit.SetTextColor(TC);

	DoUplinkCheck.SetSize(CheckWidth, ControlHeight);
	DoUplinkCheck.WinLeft = ControlLeft;

	GamePasswordEdit.SetSize(ControlWidth, ControlHeight);
	GamePasswordEdit.WinLeft = ControlLeft;
	GamePasswordEdit.EditBoxWidth = EditWidth;
	GamePasswordEdit.SetTextColor(TC);

	AdminPasswordEdit.SetSize(ControlWidth, ControlHeight);
	AdminPasswordEdit.WinLeft = ControlLeft;
	AdminPasswordEdit.EditBoxWidth = EditWidth;
	AdminPasswordEdit.SetTextColor(TC);

	DifficultyCombo.SetSize(ControlWidth, ControlHeight);
	DifficultyCombo.WinLeft = ControlLeft;
	DifficultyCombo.EditBoxWidth = EditWidth;
	DifficultyCombo.SetTextColor(TC);

	if( bUseStoryCombo )
	{
	StoryModeCombo.SetSize(ControlWidth, ControlHeight);
	StoryModeCombo.WinLeft = ControlLeft;
	StoryModeCombo.EditBoxWidth = EditWidth;
	StoryModeCombo.SetTextColor(TC);
	}

	///steam 12/11/2016
	FriendlyFireSlider.SliderWidth = 90;
	FriendlyFireSlider.SetSize(ControlWidth-EditWidth+100, ControlHeight);
	FriendlyFireSlider.WinLeft = ControlLeft;
	FriendlyFireSlider.SetTextColor(TC);

	///steam 21/11/2016
	PlayersLimitSlider.SliderWidth = 90;
	PlayersLimitSlider.SetSize(ControlWidth-EditWidth+100, ControlHeight);
	PlayersLimitSlider.WinLeft = ControlLeft;
	PlayersLimitSlider.SetTextColor(TC);

	///steam 17/08/2017
	SpectatorsLimitSlider.SliderWidth = 90;
	SpectatorsLimitSlider.SetSize(ControlWidth-EditWidth+100, ControlHeight);
	SpectatorsLimitSlider.WinLeft = ControlLeft;
	SpectatorsLimitSlider.SetTextColor(TC);

	///steam 07/08/2017
	TravelPercentSlider.SliderWidth = 90;
	TravelPercentSlider.SetSize(ControlWidth-EditWidth+100, ControlHeight);
	TravelPercentSlider.WinLeft = ControlLeft;
	TravelPercentSlider.SetTextColor(TC);

	if( bUseNoHolidaysCheckbox )
	{
	NoHolidaysCheck.SetSize(CheckWidth, ControlHeight);
	NoHolidaysCheck.WinLeft = ControlLeft;
	NoHolidaysCheck.SetTextColor(TC);
	}

	RagdollSyncCheck.SetSize(CheckWidth, ControlHeight);
	RagdollSyncCheck.WinLeft = ControlLeft;
	RagdollSyncCheck.SetTextColor(TC);

	PawnGoalLimitSlider.SliderWidth = 90;
	PawnGoalLimitSlider.SetSize(ControlWidth-EditWidth+100, ControlHeight);
	PawnGoalLimitSlider.WinLeft = ControlLeft;
	if (int(PawnGoalLimitSlider.GetValue()) > 12)
	{
		RedTC.R = 255;
		RedTC.G = 0;
		RedTC.B = 0;
		RedTC.A = 0;
		PawnGoalLimitSlider.SetTextColor(RedTC);
	}
	else PawnGoalLimitSlider.SetTextColor(TC);
}

///start game Class<DeathMatch>(BotmatchParent.GameClass).Default.MaxPlayers = int(MaxPlayersEdit.GetValue());
/// Class<DeathMatch>(BotmatchParent.GameClass).Default.MaxSpectators = int(MaxSpectatorsEdit.GetValue());

defaultproperties
{
	PawnGoalLimitText="Bystanders limit"
	PawnGoalLimitHelp="How many bystanders are walking around, more than 12 may cause frequent CRASHES."

	RagdollSyncText="Ragdoll synchronization"
	RagdollSyncHelp="All players will be able to interact with corpses, they also will stay as long as you can set in options. Can be only used with Non-Dedicated."

	//bUseStoryCombo=true

	TravelPercentText="Travel access limit"
	TravelPercentHelp="How many players you need to travel between levels (more than value)."

	PlayersLimitText="Players num limit"
	PlayersLimitHelp="How many players can join your server (including host)."

	SpectatorsLimitText="Spectators num limit"
	SpectatorsLimitHelp="How many spectators can join your server."

	NoHolidaysText="No holiday events"
	NoHolidaysHelp="If checked, holidays events will be disabled."

	FriendlyFireText="Friendly Fire"
	FriendlyFireHelp="Sets how much damage other players will take from friendly fire."

	StoryModeText="Story mode"
	StoryModeHelp="Select story mode, as original POSTAL 2, Apocalypse Weekend add-on, or combined POSTAL 2 + AW"
	StoryModeTypes(0)="POSTAL 2"
	StoryModeTypes(1)="Apocalypse Weekend"
	StoryModeTypes(2)="A Week In Paradise"

	LoadIntroText="Load intro"
	LoadIntroHelp="Load intro map or start game immediately"
	DifficultyText="Difficulty"
	DifficultyHelp="Sets game difficulty.  Cannot be changed after game begins."
	DedicatedText="Dedicated Server"
	DedicatedHelp="Fully autonomous server. If checked, server will be launched as separate application."
	DedicatedWarningTitle="Dedicated Server"
	DedicatedWarningText="You have enabled Dedicated Server mode.\n\nIf you press START now, the server will appear as a small icon near the clock on your task bar.  You can right-click on the icon to control the server.\n\nRunning the game again while a Dedicated Server is already running will result in poor performance.  If you want to play and host a game at the same time then you should turn off the Dedicated Server option."
	ServerNameText="Server Name"
	ServerNameHelp="The name that will be listed when people are looking for games to join."
	DoUplinkText="Public Listing"
	DoUplinkHelp="Allows internet players to see your server when they are looking for games to join."
	PageHeaderText=""
	ControlWidthPercent=0.660000
	GamePasswordText="Game Password"
	GamePasswordHelp="If a game password is set then only players who know it will be able to join the game."
	AdminPasswordText="Admin Password"
	AdminPasswordHelp="If an admin password is set then any player who knows it can use admin commands during the game."
}
