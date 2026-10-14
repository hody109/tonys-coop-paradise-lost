//=============================================================================
// CoopPlayerControllerHost.uc
// - 20-06-2015 change - activated errands added to replication
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopPlayerControllerHost extends CoopPlayerController;

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

///steam 21/07/2016
simulated function NETChameleonTick(float DeltaTime)
{
	///steam 11/08/2017
	if( Role == ROLE_Authority )
		CoopCheckIdling();
}

defaultproperties
{
	Buoyancy=75.0
}
