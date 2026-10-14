//=============================================================================
// CoopInvFix_ShotGunWeapon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_ShotGunWeapon extends ShotGunWeapon;

///steam 28/07/2016
replication
{
	// Functions called by server on client
	reliable if( Role == ROLE_Authority )
		ClientForceSwapCat;
}

///steam 28/07/2016
simulated function ClientForceSwapCat(bool bState)
{
	if( bState )
	{
		LinkMesh(CatMesh, true);
		//LinkSkelAnim(GetDefaultAnim(SkeletalMesh(CatMesh)));
		Skins[CatSkinIndex] = CatSkin;
		CatOnGun = 1;
	}
	else
	{
		LinkMesh(default.Mesh);
		//LinkSkelAnim(GetDefaultAnim(SkeletalMesh(default.Mesh)));
		CatOnGun = 0;
		///steam 07/09/2016
		bPutCatOnGun = false;
	}
}

///steam 28/07/2016
function SetToPutCatOnGun()
{
	Super.SetToPutCatOnGun();
	ClientForceSwapCat(true);
	//ClientForceFinish();
	ForceFinish();
}

///steam 28/07/2016
function ShootOffCat()
{
	local vector StartLoc, X,Y,Z;
	local CatRocket catr;

	GetAxes(Instigator.Rotation,X,Y,Z);
	StartLoc = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartLoc, 2*AimError);
	X = vector(AdjustedAim);
	StartLoc += ((Instigator.CollisionRadius)*X*1.5);
	StartLoc.z+=(Instigator.CollisionRadius*1);

	// Record that we killed the cat
	if(P2GameInfoSingle(Level.Game) != None
		&& P2GameInfoSingle(Level.Game).TheGameState != None
		&& P2Pawn(Instigator) != None
		&& P2Pawn(Instigator).bPlayer)
	{
		P2GameInfoSingle(Level.Game).TheGameState.CatsKilled++;
	}

	catr = spawn(class'CoopInvFix_CatRocket',Instigator,,StartLoc,Rotator(X));
	if(catr != None)
	{
		catr.Instigator = Instigator;
		catr.AddRelativeVelocity(Instigator.Velocity);
		// put the right skin on it
		catr.Skins[0] = CatSkin;
		if(BounceCat != 0)
			catr.bDoBounces=true;
	}
	///steam 12/10/2016

	///Super.ShootOffCat();
	ClientForceSwapCat(false);
	ClientForceFinish();
	///steam 07/09/2016
	bPutCatOnGun = false;
}

///steam 28/07/2016
function SwapCatOn()
{
	Super.SwapCatOn();
	ClientForceSwapCat(true);
}

///steam 28/07/2016
function SwapCatOff()
{
	Super.SwapCatOff();
	ClientForceSwapCat(false);
}

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
