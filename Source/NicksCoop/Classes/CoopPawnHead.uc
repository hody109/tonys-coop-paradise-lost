//=============================================================================
// CoopPawnHead.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopPawnHead extends AWHead;

const REMOVE_DELAY = 60;

///steam 03/08/2016
simulated function TearOffNetworkConnection(class<DamageType> DamageType)
{
	bUpdateSimulatedPosition = true;
	bReplicateMovement = true;
}

state Dead
{
	simulated function Timer()
	{
		if (MyBody != None && !MyBody.bTearOff)
		{
			//SetTimer(REMOVE_DEAD_TIME, false);
			return;
		}
		Super.Timer();
	}
}

state RemoveMe
{
	ignores SetMood, AnimEnd;

	simulated function Timer()
	{
		if( !PlayerCanSeeMe() && Physics != PHYS_Projectile && (MyBody == None || MyBody.bDeleteMe) )
			Destroy();
		else SetTimer(REMOVE_DELAY, false);
	}

	simulated function BeginState()
	{
		Super.BeginState();

		// Check to mark me as a disembodied head for all to see.
		if(MyMarker == None)
			MyMarker = spawn(class'DeadHeadMarker',self,,Location);

		if( Role == ROLE_Authority )
			SetTimer(REMOVE_DELAY, false);
	}
}

function PlayAnimDead()
{
	Super.PlayAnimDead();

	// Change by NickP: MP fix
	if (bReplicateAnimations)
	{
		SimAnimChannel = 0;
	}
	// End
}

simulated function PostNetBeginPlay()
{
	local rotator rot;
	local vector v;

	Super.PostNetBeginPlay();
	if (PersonPawn(Owner) != None)
	{
		PersonPawn(Owner).AttachToBone(self, PersonPawn(Owner).BONE_HEAD);

		// Rotate head so it looks right (this is temporary until the editor's
		// animation browser supports attachment sockets)
		rot.Pitch = 0;
		rot.Yaw = -16384;	// -18000 looks better but leaves a gap at back of neck!
		rot.Roll = 16384;
		SetRelativeRotation(rot);

		// Push the heads down a hair to hide the seam
		v.x = PersonPawn(Owner).ADJUST_RELATIVE_HEAD_X;
		v.y = PersonPawn(Owner).ADJUST_RELATIVE_HEAD_Y;
		v.z = PersonPawn(Owner).ADJUST_RELATIVE_HEAD_Z;
		SetRelativeLocation(v);
	}
}

defaultproperties
{
	LODBias=2.0
}
