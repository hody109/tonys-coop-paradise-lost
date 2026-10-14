//=============================================================================
// CoopMiscTimerMulticast_InitialSetup.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopMiscTimerMulticast_InitialSetup extends CoopMiscTimerMulticast;

simulated function PostNetBeginPlay()
{
	SetTimer(1.1,false);
}

simulated function Timer()
{
	if( Role == ROLE_Authority )
	{
		if( Owner != None && CoopPlayerController(Pawn(Owner).Controller) != None )
			CoopPlayerController(Pawn(Owner).Controller).xClientApplyCurrentClothes();
	}
	if( Role < ROLE_Authority )
	{
		// if( P2MoCapPawn(Owner) != None ) // that was supposed to be working within client net chameleon tick
			// P2MoCapPawn(Owner).bInitialSetup = false;
		if( P2MoCapPawn(Owner) != None )
			P2MoCapPawn(Owner).bInitializeAnimation = false;
	}
}

defaultproperties
{
	LifeSpan=1.5
}
