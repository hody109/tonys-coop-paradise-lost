//=============================================================================
// CoopPLNETChameleonModuleHost.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLNETChameleonModuleHost extends CoopNETChameleonModuleHost;

var StaticMesh CheckSkySphereSM;

///steam 11/11/2017
simulated function xClientSetupChameleonExtended(Actor aChameleon)
{
	///steam 11/11/2017
	if( aChameleon.IsA('DayBlocker') )
	{
		if( !aChameleon.bUnlit 
			&& aChameleon.StaticMesh != None 
			&& aChameleon.StaticMesh == CheckSkySphereSM )
			aChameleon.bUnlit = true;
	}
}

///steam 11/11/2017
simulated function xServerUpdateChameleonExtended(Actor aChameleon)
{
	///steam 11/11/2017
	if( aChameleon.IsA('SuperChampFireballExplosion') )
	{
		if( Level.NetMode == NM_DedicatedServer )
		{
			if( aChameleon.Buoyancy != 1 )
			{
				aChameleon.LifeSpan = 10;
				aChameleon.Buoyancy = 1;
			}
		}
	}
}

defaultproperties
{
	CheckSkySphereSM=StaticMesh'PL_EnvMesh.sky.skydome_polar'
}
