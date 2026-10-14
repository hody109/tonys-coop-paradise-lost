//=============================================================================
// CoopInvFix_CatnipInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_CatnipInv extends CatnipInv;

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	ignores Activate;

	function bool SmokeIt()
	{
		local P2Pawn CheckPawn;

		CheckPawn = P2Pawn(Owner);

		TurnOffHints();	// When you use it, turn off the hints

		if(P2Player(Pawn(Owner).Controller) != None)
		{
			P2Player(Pawn(Owner).Controller).ClientMessage("Not working in coop, sorry");
			return true;

			// Kamek 4-29 "Fear and Loathing"
			P2Player(Pawn(Owner).Controller).SmokeCatnip();
			PlayerController(Pawn(Owner).Controller).GetEntryLevel().GetAchievementManager().UpdateStatInt(PlayerController(Pawn(Owner).Controller),'CatnipSmoked',1,True);
		}
		ReduceAmount(1);
		return true;
	}
Begin:
	BlowSmoke();
	Owner.PlaySound(ExhaleSound);
	Sleep(Owner.GetSoundDuration(ExhaleSound));
	SmokeIt();
	GotoState('');
}

defaultproperties
{
	PickupClass=class'CoopInvFix_CatnipPickup'
}
