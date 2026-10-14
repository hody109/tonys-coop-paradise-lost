//=============================================================================
// CoopInvFix_StatInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopInvFix_StatInv extends StatInv;

var string DontUseThisCrapMsgs[4];

state Activated
{
	function LookAtIt()
	{
		local P2Player Player;

		Player = P2Player(P2Pawn(Owner).Controller);

		if( Player != None && Player.Buoyancy != 75 )
		{
			Player.ClientMessage(DontUseThisCrapMsgs[rand(ArrayCount(DontUseThisCrapMsgs))]);
			TurnOffHints();
			return;
		}

		if (Player != none)
		{
			TurnOffHints();
			Player.DisplayStats();
		}
	}

Begin:
	LookAtIt();
	GotoState('');
}

defaultproperties
{
	DontUseThisCrapMsgs(0)="Nope."
	DontUseThisCrapMsgs(1)="No way."
	DontUseThisCrapMsgs(2)="Are you kidding me?"
	DontUseThisCrapMsgs(3)="No way you freaking pinko!"
}
