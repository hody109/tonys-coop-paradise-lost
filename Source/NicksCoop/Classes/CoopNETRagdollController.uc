//=============================================================================
// CoopNETRagdollController.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2020.
//=============================================================================

class CoopNETRagdollController extends Info;

var float fUpdateTime;
var float fInitialTime;
var float NetUpdateFrequencySleep;

const BONE_NUM = 13;
var byte NETBoneRemoved[BONE_NUM];
var rotator NETBoneRotation[BONE_NUM];
var const Name NETBoneName[BONE_NUM];

var bool bMissingBottomHalf;
var bool bMissingTopHalf;
var bool bInitialized;

var byte IsMissingBottomHalf;
var byte IsMissingTopHalf;

var int BoneRemovedCount;

const BONE_HEAD = 'MALE01 head';
const MAX_RENDER_TIME = 1.0;

const DIRTY_BONE = 10; // in case using the bottom part, 10 bone is hidden
const BONE_ROT_TOLERANCE = 91.0; // 65536/360=182 - one degree

replication
{
	unreliable if( Role == ROLE_Authority )
		NETBoneRotation, NETBoneRemoved;
}

static final function bool IsRotatorEqual(rotator A, rotator B, float Tolerance)
{
	local rotator UseA, UseB;

	UseA = Normalize(A);
	UseB = Normalize(B);

	if (UseA == UseB)
		return true;

	if (abs(UseA.Yaw-UseB.Yaw) < Tolerance 
		&& abs(UseA.Pitch-UseB.Pitch) < Tolerance 
		&& abs(UseA.Roll-UseB.Roll) < Tolerance)
		return true;

	return false;
}

function int GetBoneRemovedCount()
{
	local int i, Count;

	for( i = 0 ; i <= 7 ; i++ )
	{
		Count += NETBoneRemoved[i];
	}

	return Count;
}

function int GetBoneArrCount(AWPerson Pawn)
{
	local int i, Count;

	for( i = 0 ; i <= 7 ; i++ )
	{
		Count += abs(1-Pawn.BoneArr[i]);
	}

	return Count;
}

///steam 21/03/2017
static final function rotator xRotatorSpringInterpFixed(rotator Dest, rotator Current, float Delta, float SpringConst)
{
	local rotator ScrollDelta, ScrollAccel, ScrollVel;

	ScrollDelta = Normalize(Dest - Current);
	ScrollAccel = SpringConst * ScrollDelta;
	ScrollVel = ScrollAccel * Delta;

	return (Current + ScrollVel * Delta);
}

simulated function PostBeginPlay()
{
	// First 8 seconds don't let the sync slow down
	fInitialTime = Level.TimeSeconds + 8;

	Super.PostBeginPlay();
}

simulated function Tick(float DeltaTime)
{
	local int i, n;
	local P2MoCapPawn aRagdollBody;
	local AWPerson aAWRagdollBody;
	local rotator tempRotation;
	local rotator tempBoneRot;
	local bool bBonesDirty;

	aRagdollBody = P2MoCapPawn(Owner);
	if (aRagdollBody == None 
		|| aRagdollBody.bDeleteMe 
		// If the body has resurrected, deactivate ragdoll controller
		|| (Role == ROLE_Authority && aRagdollBody.Health > 0 && aRagdollBody.Physics != PHYS_KarmaRagDoll))
	{
		Disable('Tick');
		LifeSpan = 1.0f;
		return;
	}

	aAWRagdollBody = AWPerson(aRagdollBody);
	if( Level.TimeSeconds > fInitialTime)
	{
		if( Role == ROLE_Authority )
		{
			if( Level.TimeSeconds < fUpdateTime )
				return;

			// The delay calculation: T = 1/(2*default.NetUpdateFrequency) = 1/(2*100) = 0.005 (200Hz)
			fUpdateTime = Level.TimeSeconds + 1.0f/(2*NetUpdateFrequency);

			bBonesDirty = !IsRotatorEqual(aRagdollBody.GetBoneRotation(NETBoneName[DIRTY_BONE]), NETBoneRotation[DIRTY_BONE], BONE_ROT_TOLERANCE);
			if (!bBonesDirty && aAWRagdollBody != None)
			{
				n = GetBoneArrCount(aAWRagdollBody);
				bBonesDirty = ( n != BoneRemovedCount 
					|| aAWRagdollBody.bMissingBottomHalf != bMissingBottomHalf 
					|| aAWRagdollBody.bMissingTopHalf != bMissingTopHalf );
				BoneRemovedCount = n;
			}

			// Optimization, skip iteration if we have nothing to update
			if (!bBonesDirty)
			{
				NetUpdateFrequency = NetUpdateFrequencySleep;
				return;
			}
			else
			{
				NetUpdateFrequency = default.NetUpdateFrequency;
			}
		}
		else if( Role < ROLE_Authority )
		{
			// Copied from CoopNETChameleonModule.IsRendering()
			if( (Level.TimeSeconds - aRagdollBody.LastRenderTime) > MAX_RENDER_TIME )
				return;

			bBonesDirty = !IsRotatorEqual(aRagdollBody.GetBoneRotation(NETBoneName[DIRTY_BONE]), NETBoneRotation[DIRTY_BONE], BONE_ROT_TOLERANCE);
			if (!bBonesDirty && aAWRagdollBody != None)
			{
				n = GetBoneRemovedCount();
				bBonesDirty = ( n != BoneRemovedCount 
					|| NETBoneRemoved[8] != IsMissingBottomHalf 
					|| NETBoneRemoved[10] != IsMissingTopHalf );
				BoneRemovedCount = n;
			}

			// Optimization, skip iteration if we have nothing to update
			if (!bBonesDirty)
			{
				return;
			}

//			aRagdollBody.SetDrawScale(0.5 + FRand());
		}
	}

	// TODO: Add players (viewport) distance check

	if( Role == ROLE_Authority )
	{
		if (aAWRagdollBody != None)
		{
			for( i = 0 ; i < BONE_NUM ; i++ )
			{
				if( i <= 7 )
				{
					n = abs(1-AWPerson(aRagdollBody).BoneArr[i]);
					if( NETBoneRemoved[i] != n )
					{
						NETBoneRemoved[i] = n;
						continue;
					}
				}
				NETBoneRotation[i] = aRagdollBody.GetBoneRotation(NETBoneName[i]);
			}

			if( aAWRagdollBody.bMissingBottomHalf != bMissingBottomHalf )
			{
				if( aAWRagdollBody.bMissingBottomHalf )
				{
					NETBoneRemoved[8] = 1;
					NETBoneRemoved[9] = 1;
					NETBoneRemoved[12] = 1;
				}
				else
				{
					NETBoneRemoved[8] = 0;
					NETBoneRemoved[9] = 0;
					NETBoneRemoved[12] = 0;
				}

				bMissingBottomHalf = aAWRagdollBody.bMissingBottomHalf;
			}

			if( aAWRagdollBody.bMissingTopHalf != bMissingTopHalf )
			{
				if( aAWRagdollBody.bMissingTopHalf )
				{
					NETBoneRemoved[10] = 1;
					NETBoneRemoved[11] = 1;
				}
				else
				{
					NETBoneRemoved[10] = 0;
					NETBoneRemoved[11] = 0;
				}

				bMissingTopHalf = aAWRagdollBody.bMissingTopHalf;
			}
		}
		else
		{
			for( i = 0 ; i < BONE_NUM ; i++ )
			{
				NETBoneRotation[i] = aRagdollBody.GetBoneRotation(NETBoneName[i]);
			}
		}
	}
	else if( Role < ROLE_Authority )
	{
		if (!bInitialized)
		{
			if(PersonPawn(aRagdollBody) != None)
			{
				class'CoopNETChameleonModule'.static.PlayDyingFor(PersonPawn(Owner), true);
				class'CoopNETChameleonModule'.static.PlayDyingFor_InitRotation(PersonPawn(Owner), Owner.Rotation.Yaw, true);
				PersonPawn(Owner).PlaySound(class'LambController'.default.TermSound, SLOT_Talk, 0.01);
			}
			bInitialized = true;

			return;
		}

		// TODO: Add visibility condition
		if (aAWRagdollBody != None)
		{
			if (NETBoneRemoved[8] != IsMissingBottomHalf)
			{
				for (i = 0; i < aAWRagdollBody.Stumps.Length; i++)
				{
					if (aAWRagdollBody.Stumps[i] == None || aAWRagdollBody.Stumps[i].bDeleteMe)
						continue;
					for( n = 3 ; n <= 7 ; n++ )
					{
						if (aAWRagdollBody.Stumps[i].AttachmentBone == NETBoneName[n])
						{
							if (NETBoneRemoved[8] == 1)
								aAWRagdollBody.Stumps[i].SetDrawType(DT_None);
							else aAWRagdollBody.Stumps[i].SetDrawType(DT_StaticMesh);
						}
					}
				}

				// HACK: Fixes the code from AWPerson.ClientSetupStump(), causes unwanted legs bones being shown, the stump is also hidden
				SetTimer(MAX_RENDER_TIME, false);
				// End

				IsMissingBottomHalf = NETBoneRemoved[8];
			}

			if (NETBoneRemoved[10] != IsMissingTopHalf)
			{
				for (i = 0; i < aAWRagdollBody.Stumps.Length; i++)
				{
					if (aAWRagdollBody.Stumps[i] == None || aAWRagdollBody.Stumps[i].bDeleteMe)
						continue;
					for( n = 0 ; n <= 3 ; n++ )
					{
						if (aAWRagdollBody.Stumps[i].AttachmentBone == NETBoneName[n])
						{
							if (NETBoneRemoved[10] == 1)
								aAWRagdollBody.Stumps[i].SetDrawType(DT_None);
							else aAWRagdollBody.Stumps[i].SetDrawType(DT_StaticMesh);
						}
					}
				}
				IsMissingTopHalf = NETBoneRemoved[10];
			}
		}

		for( i = 0 ; i < BONE_NUM ; i++ )
		{
			if( NETBoneRemoved[i] == 0 )
			{
				tempBoneRot = aRagdollBody.GetBoneRotation(NETBoneName[i]);
				tempRotation = xRotatorSpringInterpFixed(NETBoneRotation[i], tempBoneRot, DeltaTime, 2048);
			}
//			tempRotation = NETBoneRotation[i];
			aRagdollBody.SetBoneDirection(NETBoneName[i], tempRotation, vect(0,0,0), abs(1-NETBoneRemoved[i]));
		}
		aRagdollBody.SetBoneDirection(BONE_HEAD, NETBoneRotation[11], vect(0,0,0), abs(1-NETBoneRemoved[11]));
	}
}

// HACK: Fixes the code from AWPerson.ClientSetupStump(), causes unwanted legs bones being shown, the stump is also hidden
simulated function Timer()
{
	local int i;
	local AWPerson aAWRagdollBody;

	aAWRagdollBody = AWPerson(Owner);
	if (aAWRagdollBody == None || aAWRagdollBody.bDeleteMe)
		return;

	if ( (Level.TimeSeconds - aAWRagdollBody.LastRenderTime) < MAX_RENDER_TIME )
	{
		for (i = 0; i < aAWRagdollBody.Stumps.Length; i++)
		{
			if (aAWRagdollBody.Stumps[i] == None || aAWRagdollBody.Stumps[i].bDeleteMe)
				continue;

			if (aAWRagdollBody.Stumps[i].AttachmentBone == aAWRagdollBody.BONE_MID_SPINE && aAWRagdollBody.Stumps[i].bHidden)
			{
				aAWRagdollBody.SetBoneScale(aAWRagdollBody.TORSO_INDEX, 1/aAWRagdollBody.SHRINK_PELVIS, aAWRagdollBody.BONE_PELVIS);
				aAWRagdollBody.SetBoneScale(aAWRagdollBody.TORSO_INDEX+1, aAWRagdollBody.SHRINK_PELVIS, aAWRagdollBody.TOP_TORSO);
				aAWRagdollBody.Stumps[i].bHidden = false;

				break;
			}
		}
	}
	else SetTimer(MAX_RENDER_TIME, false);
}
// End

defaultproperties
{
	NetUpdateFrequencySleep=10.0f
	NetUpdateFrequency=50.0f

	NETBoneRemoved(0)=0
	NETBoneRemoved(1)=0
	NETBoneRemoved(2)=0
	NETBoneRemoved(3)=0
	NETBoneRemoved(4)=0
	NETBoneRemoved(5)=0
	NETBoneRemoved(6)=0
	NETBoneRemoved(7)=0
	NETBoneRemoved(8)=0
	NETBoneRemoved(9)=0
	NETBoneRemoved(10)=0
	NETBoneRemoved(11)=0
	NETBoneRemoved(12)=0

	NETBoneName(0)="MALE01 L UpperArm"
	NETBoneName(1)="MALE01 L Forearm"
	NETBoneName(2)="MALE01 R UpperArm"
	NETBoneName(3)="MALE01 R Forearm"
	NETBoneName(4)="MALE01 L Thigh"
	NETBoneName(5)="MALE01 L Calf"
	NETBoneName(6)="MALE01 R Thigh"
	NETBoneName(7)="MALE01 R Calf"
	NETBoneName(8)="MALE01"
	NETBoneName(9)="MALE01 spine"
	NETBoneName(10)="MALE01 spine1"
	NETBoneName(11)="MALE01 spine2"
	NETBoneName(12)="MALE01 pelvis"

	RemoteRole=ROLE_SimulatedProxy
	bAlwaysTick=true
	bHidden=true

	// This actor must be moving within his Owner, otherwise it's not relevant
	// bAlwaysRelevant=true
	// bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=false
}
