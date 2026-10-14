//=============================================================================
// CoopInvFix_CatRocketGrenade.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopInvFix_CatRocketGrenade extends CatRocketGrenade;

auto state Flying
{
	simulated function BeginState()
	{
		Super.BeginState();
		LoopAnim('fall');
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( Level.NetMode == NM_DedicatedServer && Trail != None )
		Trail.LifeSpan = 1.0;
}

defaultproperties
{
	bNetTemporary=false
	bReplicateMovement=true
	bUpdateSimulatedPosition=true
}