//=============================================================================
// CoopNETChameleonModule.uc
// -base module
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopNETChameleonModule extends Actor;

var float UpdateTime;

var float NETUpdateTime;
var float NETUpdateDelay;
var float MaxRenderTime;

var bool bDeadPoseOffset;
var Name DeadPoseAnim;
var Name DeadPoseAnimOffset;

///steam 21/05/2016
var Material TexEmitterHackOn;
var Material TexEmitterHackOff;

///steam 08/01/2016
var MeshAnimation ExtraCoopAnims;

var float PawnDeadTimerHackRate;
var float PawnDeadTimerHackLeft;

simulated function NETChameleonUpdate(float DeltaTime)
{
	// STUB
}

simulated function Tick(float DeltaTime)
{
	if( CoopPlayerController(Owner) != None )
	{
		CoopPlayerController(Owner).NETChameleonTick(DeltaTime);
		NETChameleonUpdate(DeltaTime);
	}
}

simulated function ClientMessage(coerce string Msg)
{
	CoopPlayerController(Owner).ClientMessage(Msg);
}

static function SetDeadPoseOffset(bool bOffsetAnim)
{
	default.bDeadPoseOffset = bOffsetAnim;
}

///steam 16/11/2016
static function PlayDyingFor(PersonPawn aChameleonPawn, optional bool bNoDeadPoseAnim)
{
	if (!bNoDeadPoseAnim)
	{
		if( default.bDeadPoseOffset )
			aChameleonPawn.LoopAnim(default.DeadPoseAnimOffset, 100);
		else aChameleonPawn.LoopAnim(default.DeadPoseAnim, 100);
	}

	aChameleonPawn.StopAnimating();
	if( aChameleonPawn.bTearOff )
		return;

	aChameleonPawn.Velocity = vect(0,0,0);
	aChameleonPawn.Acceleration = vect(0,0,0);
	aChameleonPawn.SetPhysics(PHYS_None);
	aChameleonPawn.ShouldCrouch(false);
	aChameleonPawn.ShouldDeathCrawl(false);
}

///steam 16/11/2016
static function PlayDyingFor_InitRotation(PersonPawn aChameleonPawn, int Yaw, optional bool bNoDeadPoseAnim)
{
	local rotator UseRot;

	if( aChameleonPawn.bTearOff )
		return;

	if (!bNoDeadPoseAnim)
		UseRot = (rot(0,1,0)*Yaw)-rot(0,0,14500);
	else UseRot = (rot(0,1,0)*Yaw)-rot(-14500,0,14500);

	aChameleonPawn.SetBoneDirection('MALE01 pelvis', UseRot, vect(0,0,0));
}

static function TearOffNetworkConnectionFor(P2MoCapPawn aChameleonPawn, class<DamageType> damageType)
{
	aChameleonPawn.bReplicateMovementAnim = false;
	aChameleonPawn.bReplicateAnimations = false;
	aChameleonPawn.TearOffNetworkConnection(damageType);
	aChameleonPawn.LifeSpan = aChameleonPawn.REMOVE_DEAD_START_TIME;
	aChameleonPawn.spawn(class'CoopMiscTimerMulticast_RemoveBody',aChameleonPawn);
}

static function PawnDyingNetSync(P2MoCapPawn aChameleonPawn, optional bool bFullRagdollSync)
{
	local CoopNETRagdollController RagdollController;

	aChameleonPawn.bReplicateMovementAnim = false;
	aChameleonPawn.bReplicateAnimations = false;

	if (bFullRagdollSync)
	{
		RagdollController = aChameleonPawn.spawn(class'CoopNETRagdollController',aChameleonPawn,,aChameleonPawn.Location);
		if (RagdollController != None)
			RagdollController.SetBase(aChameleonPawn);
	}
	else aChameleonPawn.spawn(class'CoopMiscTimerMulticast_PlayDying',aChameleonPawn);
}

static function bool SafeDestroyActor(Actor aActor)
{
	if( aActor.LifeSpan == 0 || aActor.LifeSpan > 0.1 )
	{
		aActor.LifeSpan = 0.1;
		return true;
	}
	return false;
}

static function bool SafeDestroyActorExt(Actor aActor, float LifeTime)
{
	if( aActor.LifeSpan == 0 || aActor.LifeSpan > LifeTime )
	{
		aActor.LifeSpan = LifeTime;
		return true;
	}
	return false;
}

static function bool IsRendering(Actor aActor)
{
	return ( (aActor.Level.TimeSeconds - aActor.LastRenderTime) < default.MaxRenderTime );
}

defaultproperties
{
	PawnDeadTimerHackRate=600.0
	PawnDeadTimerHackLeft=0.1

	MaxRenderTime=1.0
	NETUpdateDelay=0.01
	DeadPoseAnim="nc_deadpose"
	DeadPoseAnimOffset="nc_deadpose2"

	ExtraCoopAnims=MeshAnimation'NicksCoop.NicksCoop_anims'
	TexEmitterHackOn=Texture'Engine.S_ClipMarker1'
	TexEmitterHackOff=Texture'Engine.S_ClipMarker2'
	bAlwaysTick=true
	bHidden=true
}
