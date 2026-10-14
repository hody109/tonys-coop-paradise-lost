//=============================================================================
// CoopInvFix_RadarTargetInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_RadarTargetInv extends RadarTargetInv;

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function bool PlugIn()
	{
		local P2Pawn CheckPawn;

		CheckPawn = P2Pawn(Owner);

		if( P2Player(CheckPawn.Controller) != None && CheckPawn.Controller.Buoyancy != 75 )
			P2Player(CheckPawn.Controller).ClientMessage("Only host can use it in coop, sorry");

		if(P2Player(CheckPawn.Controller) != None
			&& CheckPawn.Controller.Buoyancy == 75)
		{
			if( P2Player(CheckPawn.Controller).StartRadarTarget() )///steam 21/10/2017
			{
				TurnOffHints();
				ReduceAmount(1);
				return true;
			}
		}
		return false;
	}
Begin:
	PlugIn();
	GotoState('');
}

defaultproperties
{
}
