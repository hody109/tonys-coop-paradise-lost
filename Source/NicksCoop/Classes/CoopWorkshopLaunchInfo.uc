//=============================================================================
// CoopWorkshopLaunchInfo.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopWorkshopLaunchInfo extends P2GameInfoSingle;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	spawn(class'CoopWorkshopLaunchInfoTimer',self);
}

defaultproperties
{
	Begin Object Class=DayBase Name=CoopWorkshopLaunchDay
		Description=""
		LoadTex="NicksCoop.Others.coop_load_tex"
	End Object
	Days(0)=DayBase'CoopWorkshopLaunchDay'

	StartFirstDayURL="Startup"

	GameName="Nicks Coop"
	GameNameshort="Nicks Coop"
	//GameDescription="Postal 2 Coop, game will be reloaded"
	GameDescription="Postal 2 NicksCoop, fully working cooperative modification. NOTE: Game will be reloaded."
}
