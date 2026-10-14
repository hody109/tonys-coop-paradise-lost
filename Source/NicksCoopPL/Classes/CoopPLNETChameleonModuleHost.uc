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
var float NextPLSkyCheck;

function NETChameleonClient(float DeltaTime)
{
    local DayBlocker Sky;
    Super.NETChameleonClient(DeltaTime);
    if(Level.TimeSeconds < NextPLSkyCheck) return;
    NextPLSkyCheck=Level.TimeSeconds+0.5;
    // The old extension hook below is not called by the 5025 base module.
    // bUnlit is not replicated; spawned day-specific sky domes otherwise
    // receive the dark lighting of their remote skybox on every client.
    foreach DynamicActors(class'DayBlocker',Sky)
        if(Sky.StaticMesh==CheckSkySphereSM && !Sky.bUnlit)
        {
            Sky.bUnlit=true;
            Log("PLSKY|restored-unlit|" $ Sky);
        }
}

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
