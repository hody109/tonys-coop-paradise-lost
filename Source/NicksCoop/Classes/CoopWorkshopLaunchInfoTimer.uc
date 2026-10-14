//=============================================================================
// CoopWorkshopLaunchInfoTimer.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopWorkshopLaunchInfoTimer extends Actor;

var localized string CantLoadGameMsg1;
var localized string CantLoadGameMsg2;

var localized string NotCompPlatformMsg1;
var localized string NotCompPlatformMsg2;

var string DefWorkshopGameINIPath;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1.0, false);
}

function Timer()
{
	local int n;
	local string sGameINIPath;
	local string sOSDebugMsg;

	sGameINIPath = DefWorkshopGameINIPath;

	if( PlatformIsUnix() )
		sOSDebugMsg = "Linux";
	else if( PlatformIsMacOS() )
		sOSDebugMsg = "MacOS";
	else sOSDebugMsg = "Windows";

	n = FileSize(sGameINIPath);

	if( n <= -1 )
	{
		log("can't load NicksCoop..."@sOSDebugMsg);
		P2GameInfoSingle(Owner).GetPlayer().ProgressCommand("menu:relaunch", CantLoadGameMsg1, CantLoadGameMsg2@sOSDebugMsg);
		return;
	}

	if( sOSDebugMsg != "Windows" )
	{
		log("can't load NicksCoop..."@sOSDebugMsg);
		P2GameInfoSingle(Owner).GetPlayer().ProgressCommand("menu:relaunch", NotCompPlatformMsg1, sOSDebugMsg@NotCompPlatformMsg2);
		return;
	}

	log("loading NicksCoop..."@sOSDebugMsg);
	ConsoleCommand("relaunch Startup false -INI="$sGameINIPath);
}

defaultproperties
{
	DefWorkshopGameINIPath="..\\WorkshopContent\\737631813\\Postal2CoOp.ini"

	CantLoadGameMsg1="Loading ERROR"
	CantLoadGameMsg2="NicksCoop loading error. Game can't find or/and load configuration file."

	NotCompPlatformMsg1="Loading ERROR"
	NotCompPlatformMsg2="is not compatible to launch NicksCoop via workshop. Check workshop mod page for more information."

	bAlwaysTick=true
	bHidden=true
}
