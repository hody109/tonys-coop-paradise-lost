//=============================================================================
// CoopCheapBloodFeeder.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopCheapBloodFeeder extends P2Emitter;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(LifeSpan/5,false);
}

function DripBloodPuddle()
{
	local vector HitNormal, StartTrace, EndTrace, vHitLoc;
	local Actor Other;

	EndTrace = Location - vect(0,0,200);

	Other = Trace(vHitLoc,HitNormal,EndTrace,Location,false);

	if( Other != None )
		spawn(class'CoopCheapBloodPuddle',Owner,,vHitLoc+vect(0,0,2));
}

function Timer()
{
	if( Owner != None )
		DripBloodPuddle();
	else return;
	SetTimer(LifeSpan/5,false);
}

defaultproperties
{
	RemoteRole=ROLE_None
	AutoDestroy=true
	LifeSpan=15
}
