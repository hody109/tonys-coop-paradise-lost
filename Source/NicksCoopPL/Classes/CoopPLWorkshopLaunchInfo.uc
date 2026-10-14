//=============================================================================
// CoopPLWorkshopLaunchInfo.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLWorkshopLaunchInfo extends P2GameInfoSingle;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	spawn(class'CoopPLWorkshopLaunchInfoTimer',self);
}

defaultproperties
{
	Begin Object Class=DayBase Name=PLWorkshopLaunchDay
		Description=""
		LoadTex="NicksCoop.Others.coop_load_tex"
	End Object
	Days(0)=DayBase'PLWorkshopLaunchDay'

	StartFirstDayURL="Startup"

	GameName="Nicks Coop PL"
	GameNameshort="Nicks Coop PL"
	GameDescription="Postal 2 NicksCoop ParadiseLost - cooperative version of PL. NOTE: Game will be reloaded."
}
