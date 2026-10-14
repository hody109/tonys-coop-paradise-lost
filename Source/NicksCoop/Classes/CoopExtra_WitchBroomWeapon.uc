//=============================================================================
// CoopExtra_WitchBroomWeapon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopExtra_WitchBroomWeapon extends PitchforkWeapon;

function DoHit(float Accuracy, float YOffset, float ZOffset)
{
	// We don't want this to do the work. We'll do it below

	// Do a sphere test around where the shovel projects, and try to hurt stuff there
	local vector markerpos, markerpos2;
	local bool secondary;
	
	// Weapon.TraceFire (modified to save where it hit inside LastHitLocation
	local vector HitLocation, HitNormal, StartTrace, EndTrace, StraightX, X,Y,Z, HitPoint;
	local actor FirstHit;
	local actor Victims;
	local FPSPawn LivePawnHit;
	local float dist, UseTime;
	local vector dir;
	local bool bDeliverDirectDamage;
	local bool bHitSomething, bHitSolid, bHitDoor;
	
	local float MinAngle;
	local vector TargetDir;
	local KActor KActor;

//	log(self$" DoHit");
	Owner.MakeNoise(1.0);
	GetAxes(Instigator.GetViewRotation(),X,Y,Z);
	StraightX = X;
	StartTrace = GetFireStart(X,Y,Z); 
	AdjustedAim = Instigator.AdjustAim(AmmoType, StartTrace, 2*AimError);
	EndTrace = StartTrace + (YOffset + Accuracy * (FRand() - 0.5 ) ) * Y * 1000
		+ (ZOffset + Accuracy * (FRand() - 0.5 )) * Z * 1000;
	X = vector(AdjustedAim);
	HitPoint = EndTrace + (2*UseMeleeDist * X);

	// This performs the collision but also records where it hit and records it
	FirstHit = Trace(LastHitLocation,HitNormal,HitPoint,StartTrace,True);
//	log(self$" trace returns "$FirstHit);
	if(FirstHit != None)
	{
		bDeliverDirectDamage=true;
		if(FirstHit.bStatic)
			bHitSolid=true;
		// If we hit a live pawn, record that too
		else if(FPSPawn(FirstHit) != None
			&& FPSPawn(FirstHit).Health > 0)
			LivePawnHit = FPSPawn(FirstHit);
		// If we hit a door, don't let us hurt a person who may be on the FirstHit side
		// as we kick it open, if we are indeed kicking it open. 
		else if(DoorMover(FirstHit) != None
			&& bStopAtDoor)
			bHitDoor=true;

		// Process the damage here
		AmmoType.ProcessTraceHit(self, FirstHit, LastHitLocation, HitNormal, X,Y,Z);
		bHitSomething=true;
	}

	// Hurt things halfway to the end of the trace, for the radius of the trace,
	// so the sphere is halfway along the melee weapon, hurting everything in between
	// It's a hurting line with a hurting ball covering the same area.
	HitPoint = StartTrace + (UseMeleeDist * StraightX);

	// If we don't care about hitting doors or we didn't hit one, check the
	// area around us too for a possible hit
	if(!bHitDoor)
	{
//		log(self$" VisibleCollidingActors ");
		foreach VisibleCollidingActors( class 'Actor', Victims, UseMeleeDist, HitPoint )
		{
//			log(self$" VisibleCollidingActors loop returns "$Victims);
			if( (Victims != self)
				&& (!Victims.bStatic)
				&& (Victims != Instigator) 
				&& (Victims.Role == ROLE_Authority) 
				&& (FirstHit != Victims)
				&& FastTrace(StartTrace, Victims.Location)	// Don't hit through walls, etc.
				)	// handle the straight forward hits below
			{
				// If it's friendly pawn, don't let this 'wide area collision check' hurt
				// them. Only let the above, direct check hurt them. If it's any other pawn
				// or anything else in general, hurt it. This is so it's harder to accidentally
				// hurt your friends with the wide bludgeoning attacks.
				if(FPSPawn(Victims) == None
					|| !FPSPawn(Victims).bPlayerIsFriend)
				{
					// Save the first thing we hit, so we can alert other people about the hit
					if(!bDeliverDirectDamage
						&& FirstHit == None)
					{
						FirstHit = Victims;
						LastHitLocation = Victims.Location;
					}

					// If we hit something really hard, record it
					if(Victims.bStatic)
						bHitSolid=true;
					// If we hit a live pawn, record that too
					else if(LivePawnHit == None
						&& FPSPawn(Victims) != None
						&& FPSPawn(Victims).Health > 0)
						LivePawnHit = FPSPawn(Victims);

					// Check to deliver damage
					dir = Victims.Location - HitLocation;
					dist = FMax(1,VSize(dir));
					dir = dir/dist;

					AmmoType.ProcessTraceHit(self, Victims, 
									Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
									HitNormal, X,Y,Z);
					bHitSomething=true;
				}
			} 
		}
		
		// Damage KActors in a cone in front of the player
		foreach RadiusActors(class'KActor', KActor, UseMeleeDist*2, StartTrace)
		{
			TargetDir = Normal(KActor.Location - Location);
			MinAngle = 1.0f - KActorHitAngle / 180.0f;
			
			if (TargetDir dot vector(Rotation) >= MinAngle)
			{				
//				log("Kicked: " $ KActor);
				AmmoType.ProcessTraceHit(self, KActor, KActor.Location, HitNormal, X, Y, Z);
				bHitSomething = true;
			}
		}
	}

	// If we hit a pawn, don't say it was a solid hit, even if we hit other stuff
	if(LivePawnHit != None)
		bHitSolid=false;

	//log(self$" shovel hit something 0, inst "$Instigator$" hit something "$bHitSomething$" role "$Role);
	// If we hit something, only then (not when we fire) do we shake the view
	if(bHitSomething)
	{
		if ( Instigator != None)
		{
			ClientShovelShake(bHitSolid);
		}
	}
	// If we didn't hit anything, we may want to do something about it
	//  That is, we want to tell people we were swinging/kicking in mid-air
	else
		HitNothing();

	// Go flying in enhanced mode
	// But only if we don't hit a person
	if((bHitSolid || !bHitSomething)
		&& Pawn(Owner).Controller.bIsPlayer)
		GoFlying(StartTrace, HitPoint);		
	
	// Say we just fired
	ShotCount++;
	
	// Set your enemy as the one you attacked.
	if(P2Player(Instigator.Controller) != None
		&& LivePawnHit != None)
	{
		P2Player(Instigator.Controller).Enemy = LivePawnHit;
	}

	// Only make a new danger marker if the consecutive fires were as high
	// as the max
	if(ShotCount >= ShotCountMaxForNotify
		&& Instigator.Controller != None)
		{
		// tell it we know this just happened, by recording it.
		ShotCount -= ShotCountMaxForNotify;
		
		// This is if a pawn is hit by a bullet (or hurt bad), so it's really scary
		if(LivePawnHit != None
			&& PawnHitMarkerMade != None)
			{
			PawnHitMarkerMade.static.NotifyControllersStatic(
				Level,
				PawnHitMarkerMade,
				FPSPawn(Instigator), 
				FPSPawn(Instigator), // We want the creator to be instigator also
				// because this is much more like a gunfire sort of thing, rather than a pawn hit by
				// a bullet
				PawnHitMarkerMade.default.CollisionRadius,
				LivePawnHit.Location);
			}
		}
}

function GoFlying(vector StartTrace, vector EndTrace)
{
	local vector VelAdd, GroundTest;
	
	const FLY_MAGNITUDE = 1000;
	const CEILING = 2000;
	const MAX_AIRSPEED = 1500;
	const MIN_AIRSPEED = -1500;

	// Don't allow unless already airborne
	if (Instigator.Physics != PHYS_Falling)
		return;

	// Do a quick trace to the ground
	GroundTest = StartTrace;
	GroundTest.Z -= CEILING;
	
	VelAdd = Normal(StartTrace - EndTrace);
	
	if (bAltFiring)
	{
		VelAdd.X = 0;
		VelAdd.Y = 0;
		VelAdd.Z = 1;
	}

	VelAdd *= FLY_MAGNITUDE;

	Instigator.Velocity += VelAdd;
	
	// Cap airspeed
	Instigator.Velocity.X = FClamp(Instigator.Velocity.X, MIN_AIRSPEED, MAX_AIRSPEED);
	Instigator.Velocity.Y = FClamp(Instigator.Velocity.Y, MIN_AIRSPEED, MAX_AIRSPEED);
	Instigator.Velocity.Z = FClamp(Instigator.Velocity.Z, MIN_AIRSPEED, MAX_AIRSPEED);

	// Don't let them gain any more Z velocity when too high off the ground
	if (FastTrace(GroundTest, StartTrace))
		Instigator.Velocity.Z = FMin(Instigator.Velocity.Z, 0);

	if (Instigator.Physics == PHYS_Walking)
		Instigator.SetPhysics(PHYS_Falling);
}

defaultproperties
{
	WeaponSpeedShoot1=2.0
	WeaponSpeedShoot2=2.0

	bCanThrow=false
	bCanThrowMP=false
	GroupOffset=96
	ThirdPersonRelativeLocation=(X=-3.0,Y=1.0,Z=4.0)
	FPAttachmentClass=class'CoopExtra_WitchBroomAttachmentFP'
	AttachmentClass=class'CoopExtra_WitchBroomAttachment'
	AmmoName=class'CoopExtra_WitchBroomAmmoInv'
	ItemName="Broom"
	OverrideHUDIcon=Texture'NicksCoop.Others.broom_hud'
}
