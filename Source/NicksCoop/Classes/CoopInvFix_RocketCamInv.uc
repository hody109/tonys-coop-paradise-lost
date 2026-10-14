//=============================================================================
// CoopInvFix_RocketCamInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_RocketCamInv extends RocketCamInv;

function SetPlayerVar(bool bSet)
{
	local P2Pawn CheckPawn;

	CheckPawn = P2Pawn(Owner);

	if(P2Player(CheckPawn.Controller) != None)
	{
		if( CheckPawn.Controller.Buoyancy == 75 )
			P2Player(CheckPawn.Controller).bUseRocketCameras = bSet;
		else P2Player(CheckPawn.Controller).ClientMessage("Only host can use it in coop, sorry");
	}
}

defaultproperties
{
}
