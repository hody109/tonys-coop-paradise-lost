//=============================================================================
// CoopMiscTimer_ForceAddDefInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMiscTimer_ForceAddDefInv extends CoopMiscTimer;

simulated function PostBeginPlay()
{
	SetTimer(1,false);
}

simulated function Timer()
{
	local CoopPostalDude myCoopPawn;
	myCoopPawn = CoopPostalDude(Owner);
	if( myCoopPawn != None )
	{
		myCoopPawn.ForceAddDefaultInventory();
		log("CoopMiscTimer_ForceAddDefInv called to ForceAddDefaultInventory"@myCoopPawn.Controller);
	}
	else log("CoopMiscTimer_ForceAddDefInv called to ForceAddDefaultInventory FAILED, PAWN INVALID");
	LifeSpan = 0.1;
}

defaultproperties
{
	bHidden=true
}
