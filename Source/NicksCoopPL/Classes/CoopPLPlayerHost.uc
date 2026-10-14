//=============================================================================
// CoopPLPlayerHost.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLPlayerHost extends CoopPLPlayerClient;

simulated function PostBeginPlay()
{
	CreateNETSceneCamera();
	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	DeleteNETSceneCamera();
	Super.Destroyed();
}

defaultproperties
{
	Buoyancy=75.0
}
