//=============================================================================
// CoopInvFix_NewspaperInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_NewspaperInv extends NewspaperInv;

///////////////////////////////////////////////////////////////////////////////
// Active state: this inventory item is armed and ready to rock!
///////////////////////////////////////////////////////////////////////////////
state Activated
{
	function LookAtIt()
	{
		local CoopPlayerController Player;

		Player = CoopPlayerController(P2Pawn(Owner).Controller);

		if( Player != None && Player.Buoyancy != 75 )
		{
			if( Player.DesiredFOV == Player.DefaultFOV )
			{
				Player.CoopRequestNews();
				//Player.ClientMessage("Only host can use it in coop, sorry");
				TurnOffHints();
				return;
			}
		}

		// You can only look at the newspaper if you're not zoomed in (in sniper mode)
		if (Player != None
			&& Player.DesiredFOV == Player.DefaultFOV)
		{
			TurnOffHints();	// When you use it, turn off the hints

			Player.RequestNews();
		}
	}
	function EndState()
	{
		Super.EndState();
		bAutoActivate=false;
	}
Begin:
	LookAtIt();
	GotoState('');
}

function PickupFunction(Pawn Other)
{
	if( Other != None 
		&& Other.Controller != None 
		&& Other.Controller.Buoyancy != 75 )
		bAutoActivate = false;
	Super.PickupFunction(Other);
}

defaultproperties
{
}
