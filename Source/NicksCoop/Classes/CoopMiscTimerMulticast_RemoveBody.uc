//=============================================================================
// CoopMiscTimerMulticast_RemoveBody.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2019.
//=============================================================================

class CoopMiscTimerMulticast_RemoveBody extends CoopMiscTimerMulticast;

simulated function RemoveBody(float Delay)
{
	if( P2MoCapPawn(Owner) != None )
		P2MoCapPawn(Owner).LifeSpan = P2MoCapPawn(Owner).REMOVE_DEAD_START_TIME - Delay;
}

simulated function PostNetBeginPlay()
{
	if( Role < ROLE_Authority )
		RemoveBody(0.0);
	SetTimer(0.5, false);
}

simulated function Timer()
{
	if( Level.NetMode == NM_DedicatedServer )
	{
		RemoveBody(0.5);
	}
	else if( Role < ROLE_Authority )
	{
		if( Owner != None )
			Owner.PlaySound(class'LambController'.default.TermSound, SLOT_Talk, 0.01);
	}
}

defaultproperties
{
}
