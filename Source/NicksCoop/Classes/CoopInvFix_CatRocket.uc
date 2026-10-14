//=============================================================================
// CoopInvFix_CatRocket.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_CatRocket extends CatRocket;

/*simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	LoopAnim('fall');
}*/

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
}
