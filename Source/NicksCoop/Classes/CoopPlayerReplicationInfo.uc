//=============================================================================
// CoopPlayerReplicationInfo.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopPlayerReplicationInfo extends MpPlayerReplicationInfo;

//var float NETUpdTime;
var float NETHealth;
var vector NETLocation;

///steam 28/07/2017
var bool bCoopDedicatedHost;
var bool bCoopPlayerAFK;
var bool bCoopTeleportDisabled;

replication
{
	reliable if ( bNetDirty && (Role == Role_Authority) )
		NETHealth, NETLocation, bCoopDedicatedHost, bCoopPlayerAFK, bCoopTeleportDisabled;
}

function NETHealthUpdate()
{
	local FPSPawn P;
	local Controller C;
	local float fHealth;

	C = Controller(Owner);

	if( C != None )
		P = FPSPawn(C.Pawn);

	if( C == None || P == None )
	{
		NETHealth = 0;
		return;
	}

	///steam 30/04/2016 this feature moved to CoopPlayerController.Tick()
	NETLocation = P.Location;

	///return (100*Health)/HealthMax;
	fHealth = float(P.GetHealthPercent());
	if( fHealth == 0 )
		fHealth = 0.01*P.Health;
	NETHealth = fHealth;
}

///steam 30/04/2016 tick lags
/*function Tick(float DeltaTime)
{
	if( Level.TimeSeconds > NETUpdTime )
	{
		NETHealthUpdate();
		NETUpdTime = Level.TimeSeconds + 0.05;
	}
	Super.Tick(DeltaTime);
}*/

function UpdatePlayerLocation()
{
	NETHealthUpdate();
}

defaultproperties
{
	 ///RemoteRole=ROLE_SimulatedProxy
	 //NetUpdateFrequency=5.000000
	 ///NetUpdateFrequency=20.000000
}
