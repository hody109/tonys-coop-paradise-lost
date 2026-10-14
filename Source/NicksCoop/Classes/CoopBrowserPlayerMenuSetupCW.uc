//=============================================================================
// CoopBrowserPlayerMenuSetupCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserPlayerMenuSetupCW extends UMenuPageWindow;

var UWindowEditControl		NameSetupEditBox;
var localized string		NameSetupText;
var localized string		NameSetupHelp;

var UWindowComboControl		ConnectionCombo;
var localized string		ConnectionText;
var localized string		ConnectionHelp;
var localized string		ConnectionSpeeds[3];

/**var UWindowComboControl		ClientFPSCombo;
var localized string		ClientFPSText;
var localized string		ClientFPSHelp;
var localized string		ClientFPSTypes[3];**/
/*
2600 - 40FPS
3300 - 50FPS
4000 - 60FPS
*/

///steam 02/01/2018
var UWindowCheckBox PingOptimizeCheck;
var localized string PingOptimizeText;
var localized string PingOptimizeHelp;

var UWindowComboControl		SkinSetupCombo;
var localized string		SkinSetupText;
var localized string		SkinSetupHelp;
var CoopBrowserPlayerMenuSetupDW SetupDummyWindow;
var float SetupDummyWindowSize;

///steam 18/11/2016
var UWindowCheckBox NETRagdollsCheck;
var localized string NETRagdollsText;
var localized string NETRagdollsHelp;

var bool bInitialized;
var bool bAllowChangedEvents;

const NicksCoopClientNamePath = "NicksCoop.CoopMenu MultiPlayerName";
const NicksCoopHostNamePath = "NicksCoop.CoopMenu MultiPlayerHostName";
const NicksCoopSkinTypePath = "NicksCoop.CoopMenu MultiPlayerSkinType";
const NicksCoopRagdollsPath = "NicksCoop.CoopPlayerController bNETRagdollConfig";
//const NicksCoopNetSpeedPath = "NicksCoop.CoopPlayerController CoopCurrentNetSpeed";
const NicksCoopPingOptimizePath = "NicksCoop.CoopPlayerController bCoopPingOptimize";

function Created()
{
	bInitialized = False;

	Super.Created();

	/**ConnectionCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ConnectionCombo.SetButtons(True);
	ConnectionCombo.SetText(ConnectionText);
	ConnectionCombo.SetHelpText(ConnectionHelp);
	ConnectionCombo.SetFont(ControlFont);
	ConnectionCombo.SetEditable(False);
	ConnectionCombo.Align = TA_Left;
	ConnectionCombo.Clear();
	ConnectionCombo.AddItem(ConnectionSpeeds[0]);
	ConnectionCombo.AddItem(ConnectionSpeeds[1]);
	ConnectionCombo.AddItem(ConnectionSpeeds[2]);
	ControlOffset += (ControlHeight * 1.5);**/
	///steam 18/11/2017 - ConnectionCombo removed

	///steam 18/12/2017
	/**ClientFPSCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	ClientFPSCombo.SetButtons(True);
	ClientFPSCombo.SetText(ClientFPSText);
	ClientFPSCombo.SetHelpText(ClientFPSHelp);
	ClientFPSCombo.SetFont(ControlFont);
	ClientFPSCombo.SetEditable(False);
	ClientFPSCombo.Align = TA_Left;
	ClientFPSCombo.Clear();
	ClientFPSCombo.AddItem(ClientFPSTypes[0]);
	ClientFPSCombo.AddItem(ClientFPSTypes[1]);
	ClientFPSCombo.AddItem(ClientFPSTypes[2]);
	ControlOffset += (ControlHeight * 1.5);**/

	///steam 02/01/2018
	PingOptimizeCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	PingOptimizeCheck.SetText(PingOptimizeText);
	PingOptimizeCheck.SetHelpText(PingOptimizeHelp);
	PingOptimizeCheck.SetFont(ControlFont);
	PingOptimizeCheck.bChecked = GetPlayerOwner().ConsoleCommand("get"@NicksCoopPingOptimizePath) ~= "True";
	ControlOffset += (ControlHeight * 1.5);

	NameSetupEditBox = UWindowEditControl(CreateControl(class'UWindowEditControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	NameSetupEditBox.SetText(NameSetupText);
	NameSetupEditBox.SetHelpText(NameSetupHelp);
	NameSetupEditBox.SetFont(ControlFont);
	NameSetupEditBox.SetNumericOnly(False);
	NameSetupEditBox.SetMaxLength(205);
	NameSetupEditBox.SetDelayedNotify(True);
	NameSetupEditBox.SetValue(GetPlayerOwner().ConsoleCommand("get"@NicksCoopHostNamePath));
	ControlOffset += (ControlHeight * 1.5);
	//ControlOffset += ControlHeight;

	/*NETRagdollsCheck = UWindowCheckbox(CreateControl(class'UWindowCheckbox', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	NETRagdollsCheck.SetText(NETRagdollsText);
	NETRagdollsCheck.SetHelpText(NETRagdollsHelp);
	NETRagdollsCheck.SetFont(ControlFont);
	NETRagdollsCheck.bChecked = GetPlayerOwner().ConsoleCommand("get"@NicksCoopRagdollsPath) ~= "True";
	ControlOffset += (ControlHeight * 1.5);*/

	SkinSetupCombo = UWindowComboControl(CreateControl(class'UWindowComboControl', ControlLeft, ControlOffset, ControlWidth, ControlHeight));
	SkinSetupCombo.SetButtons(True);
	SkinSetupCombo.SetText(SkinSetupText);
	SkinSetupCombo.SetHelpText(SkinSetupHelp);
	SkinSetupCombo.SetFont(ControlFont);
	SkinSetupCombo.SetEditable(False);
	SkinSetupCombo.Align = TA_Left;
	SkinSetupCombo.Clear();
	//SkinSetupCombo.AddItem(ConnectionSpeeds[0]);
	//SkinSetupCombo.AddItem(ConnectionSpeeds[1]);
	//SkinSetupCombo.AddItem(ConnectionSpeeds[2]);
	xCoopLoadCustomSkins();
	ControlOffset += (ControlHeight * 1.5);

	///steam 23/10/2016
	SetupDummyWindow = CoopBrowserPlayerMenuSetupDW(CreateWindow(class'CoopBrowserPlayerMenuSetupDW', ControlLeft, ControlOffset, 100, 100));

	bInitialized = True;
	bAllowChangedEvents = true;
}

///steam 04/11/2016
function xCoopLoadCustomSkins()
{
	local int i;
	local class<CoopGameInfo> ServerGameType;

	///steam 04/11/2016
	if( CoopShellRootWindow(Root).CoopMenuClass != None )
	{
		ServerGameType = class<CoopGameInfo>(CoopShellRootWindow(Root).CoopMenuClass.default.ServerGameType);
		if( ServerGameType != None )
		{
			for( i = 0 ; i < ServerGameType.default.CoopCustomPlayerSkins.Length ; i++ )
			{
				if( ServerGameType.default.CoopCustomPlayerSkins[i] != "_end" )
					SkinSetupCombo.AddItem("Skin"@i,ServerGameType.default.CoopCustomPlayerSkins[i]);
				else break;
			}
		}
	}
}

function AfterCreate()
{
	local int i;
	local string CurrentSkinType;
	local class<CoopGameInfo> ServerGameType;

	Super.AfterCreate();

	/**i = class'Player'.default.ConfiguredInternetSpeed;
	if( i <= 6000 )
		ConnectionCombo.SetSelectedIndex(0);
	else if( i <= 10000 )
		ConnectionCombo.SetSelectedIndex(1);
	else ConnectionCombo.SetSelectedIndex(2);**/
	///steam 18/11/2017 - ConnectionCombo removed

	///steam 18/12/2017
	/**i = int(GetPlayerOwner().ConsoleCommand("get" @ NicksCoopNetSpeedPath));
	if( i == 2600 )
		ClientFPSCombo.SetSelectedIndex(0);
	else if( i == 3300 )
		ClientFPSCombo.SetSelectedIndex(1);
	else if( i == 4000 )
		ClientFPSCombo.SetSelectedIndex(2);
	i = 0;**/

	///steam 04/11/2016
	CurrentSkinType = GetPlayerOwner().ConsoleCommand("get"@NicksCoopSkinTypePath);
	if( CurrentSkinType != "" )
	{
		i = SkinSetupCombo.FindItemIndex2(CurrentSkinType, true);//FindItemIndex2
		if( i != -1 )
		{
			SkinSetupCombo.SetSelectedIndex(i);
			if( SetupDummyWindow != None )
				SetupDummyWindow.SetDummySkin(CurrentSkinType);
		}
		else
		{
			SkinSetupCombo.SetSelectedIndex(0);
			if( SetupDummyWindow != None )
				SetupDummyWindow.SetDummySkin(SkinSetupCombo.GetValue2());
		}
	}
	else
	{
		SkinSetupCombo.SetSelectedIndex(0);
		if( SetupDummyWindow != None )
			SetupDummyWindow.SetDummySkin(SkinSetupCombo.GetValue2());
	}

	///steam 25/11/2016
	if( CoopShellRootWindow(Root).CoopMenuClass != None )
	{
		ServerGameType = class<CoopGameInfo>(CoopShellRootWindow(Root).CoopMenuClass.default.ServerGameType);
		if( SetupDummyWindow != None && ServerGameType.default.CoopCustomPlayerSkinsM != None )
			SetupDummyWindow.SetDummyMesh(ServerGameType.default.CoopCustomPlayerSkinsM);
	}

	bInitialized = True;
}

function Notify(UWindowDialogControl C, byte E)
{
	if( !bAllowChangedEvents )
		return;
	if(bInitialized)
	{
		switch(E)
		{
		case DE_Change:
			switch(C)
			{
			case NameSetupEditBox:
				NameChanged();
				break;
			/**case ConnectionCombo:
				ConnectionChanged();
				break;**/
			///steam 18/11/2017 - ConnectionCombo removed
			///steam 18/12/2017
			/**case ClientFPSCombo:
				ClientFPSChanged();
				break;**/
			///steam 02/01/2018
			case PingOptimizeCheck:
				GetPlayerOwner().ConsoleCommand("set"@NicksCoopPingOptimizePath@PingOptimizeCheck.GetValue());
				break;
			case SkinSetupCombo:
				SkinSetupChanged();
				break;
			/*case NETRagdollsCheck:
				GetPlayerOwner().ConsoleCommand("set"@NicksCoopRagdollsPath@NETRagdollsCheck.GetValue());
				break;*/
			}
			break;
		}
	}
	Super.Notify(C, E);
}

function NameChanged()
{
	local string N;

	bAllowChangedEvents = false;

	N = NameSetupEditBox.GetValue();
	if ( Len(N) > 20 )
		N = left(N,20);
	ReplaceText(N, " ", "_");
	NameSetupEditBox.SetValue(N);

	bAllowChangedEvents = true;

	GetPlayerOwner().PlayerReplicationInfo.SetPlayerName(NameSetupEditBox.GetValue());
	GetPlayerOwner().UpdateURL("Name", NameSetupEditBox.GetValue(), True);

	///steam 12/10/2016 TEST
	//GetPlayerOwner().UpdateURL("Skin", "MPSkins.RedTeam.MW__008__Avg_Dude", True);

	///client
	GetPlayerOwner().ConsoleCommand("set" @ NicksCoopClientNamePath @ NameSetupEditBox.GetValue());
	///host
	GetPlayerOwner().ConsoleCommand("set" @ NicksCoopHostNamePath @ NameSetupEditBox.GetValue());
}

function ConnectionChanged()
{
	local int NewSpeed;

	switch(ConnectionCombo.GetSelectedIndex())
		{
		case 0:
			NewSpeed = 6000;
			break;
		case 1:
			NewSpeed = 10000;
			break;
		case 2:
			NewSpeed = 20000;
			break;
		}
	GetPlayerOwner().ConsoleCommand("NETSPEED" @ NewSpeed);
}

///steam 18/12/2017
/**function ClientFPSChanged()
{
	local int NewSpeed;

	switch( ClientFPSCombo.GetSelectedIndex() )
	{
		case 0:
			NewSpeed = 2600;
			break;
		case 1:
			NewSpeed = 3300;
			break;
		case 2:
			NewSpeed = 4000;
			break;
	}
	GetPlayerOwner().ConsoleCommand("set" @ NicksCoopNetSpeedPath @ NewSpeed);
}**/

///steam 04/11/2016
function SkinSetupChanged()
{
	local string NewSkinType;

	NewSkinType = SkinSetupCombo.GetValue2();

	if( NewSkinType != "" )
	{
		GetPlayerOwner().UpdateURL("Skin", NewSkinType, True);
		GetPlayerOwner().ConsoleCommand("set" @ NicksCoopSkinTypePath @ NewSkinType);
		if( SetupDummyWindow != None )
			SetupDummyWindow.SetDummySkin(NewSkinType);
	}
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	NameSetupEditBox.SetSize(ControlWidth, ControlHeight);
	NameSetupEditBox.WinLeft = ControlLeft;
	NameSetupEditBox.EditBoxWidth = EditWidth;
	NameSetupEditBox.SetTextColor(TC);

	/**ConnectionCombo.SetSize(ControlWidth, ControlHeight);
	ConnectionCombo.WinLeft = ControlLeft;
	ConnectionCombo.EditBoxWidth = EditWidth;
	ConnectionCombo.SetTextColor(TC);**/
	///steam 18/11/2017 - ConnectionCombo removed

	///steam 18/12/2017
	/**ClientFPSCombo.SetSize(ControlWidth, ControlHeight);
	ClientFPSCombo.WinLeft = ControlLeft;
	ClientFPSCombo.EditBoxWidth = EditWidth;
	ClientFPSCombo.SetTextColor(TC);**/

	///steam 02/01/2018
	PingOptimizeCheck.SetSize(CheckWidth, ControlHeight);
	PingOptimizeCheck.WinLeft = ControlLeft;
	PingOptimizeCheck.SetTextColor(TC);

	SkinSetupCombo.SetSize(ControlWidth, ControlHeight);
	SkinSetupCombo.WinLeft = ControlLeft;
	SkinSetupCombo.EditBoxWidth = EditWidth;
	SkinSetupCombo.SetTextColor(TC);

	/*NETRagdollsCheck.SetSize(CheckWidth, ControlHeight);
	NETRagdollsCheck.WinLeft = ControlLeft;
	NETRagdollsCheck.SetTextColor(TC);*/

	///steam 23/10/2016
	SetupDummyWindowSize = ((BodyHeight - (ControlOffset - BodyTop)) * 0.7) - 6;
	SetupDummyWindow.SetSize(SetupDummyWindowSize, SetupDummyWindowSize);
	SetupDummyWindow.WinLeft = (BodyWidth - SetupDummyWindowSize)*0.5;
}

function Close(optional bool bByParent)
{
	Super.Close(bByParent);
	///steam 23/10/2016
	SetupDummyWindow.Close(bByParent);
}

defaultproperties
{
	NETRagdollsText="Ragdolls synchronization"
	NETRagdollsHelp="FOR CLIENTS. If checked, ragdolls will be replicated in their real locations, as host can see that. If not, ragdolls will be simulated only in local game. Non-dedicated server only."

	SkinSetupText="Skin setup"
	SkinSetupHelp="Choose the skin you like."

	NameSetupText="Player name"
	NameSetupHelp="The name you want to use in the game. Choose your name once, it will linked to game saves, otherwise saves will be damaged."

	ConnectionText="Connection type"
	ConnectionHelp="Pick the closest match for your internet connection. Tip: Change connection if you have fixed 40 fps on client."
	ConnectionSpeeds(0)="ISDN"
	ConnectionSpeeds(1)="Cable or DSL"
	ConnectionSpeeds(2)="T1 or LAN"

	PingOptimizeText="Ping optimization"
	PingOptimizeHelp="Optimizes connection, makes ping lower. Tip: Has no effect for LAN."

	//ClientFPSText="Client FPS lock"
	//ClientFPSHelp="Lower FPS makes ping lower. Tip: choose lower FPS to play on high ping servers"
	//ClientFPSTypes(0)="40 FPS"
	//ClientFPSTypes(1)="50 FPS"
	//ClientFPSTypes(2)="60 FPS"

	PageHeaderText=""
	ControlWidthPercent=0.660000
}
