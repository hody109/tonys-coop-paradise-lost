//=============================================================================
// CoopInvFix_PistolWeapon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2020.
//=============================================================================

class CoopInvFix_PistolWeapon extends PistolWeapon;

simulated function Fire( float Value )
{
	//log(self$" Fire, ammo "$AmmoType.AmmoAmount);
	if ( AmmoType == None
		|| !AmmoType.HasAmmo() )
	{
		ClientForceFinish();
		ServerForceFinish();
		return;
	}

	if ( !RepeatFire() )
		ServerFire();
	else if ( StopFiringTime < Level.TimeSeconds + 0.3 )
	{
		StopFiringTime = Level.TimeSeconds + 0.6;
		ServerRapidFire();
	}
	if ( Role < ROLE_Authority )
	{
		// Don't do reloadcount because we usually force reloads (grenades) or don't
		// do them at all (machinegun)
		//ReloadCount--;
		LocalFire();
		//log(self$" going to client firing");
		GotoState('CoopClientFiring');
	}
}

state CoopClientFiring extends ClientFiring
{
}

state CoopNormalFire extends NormalFire
{
	function ServerFire()
	{
		if(FPSPawn(Instigator).bPlayer
			&& bCanFireAgain)
		{
			if ( AmmoType == None )
			{
				// ammocheck
				log("WARNING "$self$" HAS NO AMMO!!!");
				GiveAmmo(Pawn(Owner));
			}
			if ( AmmoType.HasAmmo() )
			{
				//GotoState('NormalFire');
				GotoState('CoopNormalFire');
				if ( AmmoType.bInstantHit )
					TraceFire(TraceAccuracy,0,0);
				else
					ProjectileFire();
				LocalFire();
			}
		}
		else
			Super.ServerFire();
	}
}

function bool IsFiring()
{
	if(IsInState('NormalFire')
		|| IsInState('AltFireState')
		|| IsInState('CoopNormalFire'))
		return true;

	return false;
}

function ServerFire()
{
	DQShovel();

	// Double-fire glitch fix
	LastFireTimeSeconds=Level.TimeSeconds;

	if ( AmmoType == None )
	{
		// ammocheck
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}

	//log(self$" serverfire, ammo "$AmmoType.AmmoAmount$" get state "$GetStateName());

	if ( AmmoType.HasAmmo() )
	{
		//GotoState('NormalFire');
		GotoState('CoopNormalFire');

		// Don't do reloadcount because we usually force reloads (grenades) or don't
		// do them at all (machinegun)
		//ReloadCount--;
		if ( AmmoType.bInstantHit )
			TraceFire(TraceAccuracy,0,0);
		else
			ProjectileFire();
		LocalFire();
	}
}

function ServerAltFire()
{
	if ( AmmoType == None )
	{
		log("WARNING "$self$" HAS NO AMMO!!!");
		GiveAmmo(Pawn(Owner));
	}
	if ( AmmoType.HasAmmo()
		&& bUsesAltFire)
	{
		bAltFiring=true;

		//GotoState('NormalFire');
		GotoState('CoopNormalFire');
		ReloadCount--;
		if ( AmmoType.bInstantHit )
			TraceAltFire(TraceAccuracy,0,0);
		else
			ProjectileAltFire();
		LocalAltFire();
	}
}

defaultproperties
{
}
