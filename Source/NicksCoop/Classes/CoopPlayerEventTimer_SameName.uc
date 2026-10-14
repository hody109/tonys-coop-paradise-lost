//=============================================================================
// CoopPlayerEventTimer_SameName.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopPlayerEventTimer_SameName extends Actor;

simulated function PostBeginPlay()
{
	SetTimer(2,false);
}

simulated function Timer()
{
	local CoopPlayerController PunishedPC;

	PunishedPC = CoopPlayerController(Owner);

	PunishedPC.xCoopCallShellMenu("NicksCoop.CoopEventMenu_SameName");

	log("PlayerEventTimer_SameName_"@PunishedPC@"pc got menu");
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
}
