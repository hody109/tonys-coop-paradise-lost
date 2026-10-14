//=============================================================================
// CoopTestStartSpot.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopTestStartSpot extends Actor;

var bool bStucked;

event bool EncroachingOn( actor Other )
{
	if( Other != None && (Other.bBlockActors || Other.bBlockPlayers) )
		bStucked = true;
	return Super.EncroachingOn(Other);
}

/*event Touch( actor Other )
{
	if( Other != None && (Other.bBlockActors || Other.bBlockPlayers) )
		bStucked = true;
}*/

/*function Tick(float DeltaTime)
{
	P2Player(Owner).ClientMessage(bStucked);
}*/

defaultproperties
{
	CollisionRadius=29.0
	CollisionHeight=65.0
	bCollideActors=true
	bCollideWorld=true
	bHidden=true
}
