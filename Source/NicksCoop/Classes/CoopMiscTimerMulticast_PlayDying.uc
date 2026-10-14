//=============================================================================
// CoopMiscTimerMulticast_PlayDying.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2019.
//=============================================================================

class CoopMiscTimerMulticast_PlayDying extends CoopMiscTimerMulticast;

simulated function PostNetBeginPlay()
{
	if( Role < ROLE_Authority && PersonPawn(Owner) != None )
	{
		class'CoopNETChameleonModule'.static.PlayDyingFor(PersonPawn(Owner));
		class'CoopNETChameleonModule'.static.PlayDyingFor_InitRotation(PersonPawn(Owner), Owner.Rotation.Yaw);
		PersonPawn(Owner).PlaySound(class'LambController'.default.TermSound, SLOT_Talk, 0.01);
	}
}

defaultproperties
{
}
