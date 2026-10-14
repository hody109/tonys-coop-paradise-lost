//=============================================================================
// CoopMaterialTrigger.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMaterialTrigger extends Actor;

var int CurrentState;

var array<Material> MaterialsToTrigger;

var float fUpdateTime;

replication
{
	unreliable if( Role == ROLE_Authority )
		CurrentState;
}

simulated function Trigger( Actor Other, Pawn EventInstigator )
{
	if( CurrentState == 0 )
		CurrentState = 1;
	else CurrentState = 0;
}

simulated function Tick(float DeltaTime)
{
	local int i;

	if( Level.TimeSeconds > fUpdateTime )
	{
		for( i = 0 ; i < MaterialsToTrigger.Length ; i++ )
		{
			if( MaterialsToTrigger[i] != None 
				&& MaterialSwitch(MaterialsToTrigger[i]) != None 
				&& MaterialSwitch(MaterialsToTrigger[i]).Current != CurrentState )
			{
				MaterialSwitch(MaterialsToTrigger[i]).SetCurrent(CurrentState);
			}
		}
		fUpdateTime = Level.TimeSeconds + 1.01;
	}
}

defaultproperties
{
	bHidden=true
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
	bIgnoreOutOfWorld=true
}
