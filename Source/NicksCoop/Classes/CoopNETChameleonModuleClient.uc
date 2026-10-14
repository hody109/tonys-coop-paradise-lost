//=============================================================================
// CoopNETChameleonModuleClient.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopNETChameleonModuleClient extends CoopNETChameleonModule;

function NETChameleonClient_Pawn(float DeltaTime)
{
	local PersonPawn aChameleonPawn;
	local FPSPawn aPawn;

	foreach DynamicActors(class'FPSPawn', aPawn)
	{
		// HACK: allows to fool the dying timer (REMOVE_DEAD_START_TIME)
		if( aPawn.Health <= 0 && !aPawn.bTearOff )
		{
			if( (aPawn.TimerRate-aPawn.TimerCounter) < PawnDeadTimerHackLeft )
				aPawn.SetTimer(PawnDeadTimerHackRate, false);
			//ClientMessage(aPawn @ aPawn.TimerRate @ aPawn.TimerCounter);
		}

		// HACK! FIX FOR: BasePeople.AWPerson.Dying.BeginState - BasePeople.AWPerson.PlayDying - APawn::UpdateMovementAnimation - AFPSPawn::UpdateMovementAnimation
		// Theoretically, we must avoid calling bCollideWorld = true in the P2Pawn.Dying.BeginState:3881 (build 5024)
		// Needs be fixed in the new game build, see original STP code, also used in CoopPlayerController.GetNewRagdollSkel()
		// This one called to avoid potential non-ragdolled cases
		if (P2Pawn(aPawn) != None)
			P2Pawn(aPawn).bCompletedDeadSetup = true;

		if( !IsRendering(aPawn) )
			continue;

		aChameleonPawn = PersonPawn(aPawn);
		if( aChameleonPawn != None )
		{
			// We still wants to force the animation, just in case
			if( aChameleonPawn.Health <= 0 && !aChameleonPawn.bPlayer && !aPawn.bTearOff )
			{
				// Check and assign extra coop anims
				if (aChameleonPawn.ExtraCoopAnims == None)
				{
					aChameleonPawn.bInitializeAnimation = false;
					aChameleonPawn.LinkSkelAnim(ExtraCoopAnims);
					aChameleonPawn.ChangeAnimation();
					aChameleonPawn.Class.default.ExtraCoopAnims = ExtraCoopAnims;
				}

				PlayDyingFor(aChameleonPawn);
			}

			// FIXME!! Add the head fix coded...
		}
	}
}

function NETChameleonClient_Emitter(float DeltaTime)
{
	local int i;
	local Emitter aEmitter;

	foreach DynamicActors(class'Emitter', aEmitter)
	{
		///steam 21/05/2016
		if( aEmitter.Texture == TexEmitterHackOn || aEmitter.Texture == TexEmitterHackOff )
		{
			if( aEmitter.Emitters.Length > 0 )
			{
				if( aEmitter.Texture == TexEmitterHackOn )
				{
					//ClientMessage(aEmitter@"TexEmitterHackOn"@aEmitter.Emitters.Length);

					if( aEmitter.Buoyancy != 1 )
					{
						for( i = 0 ; i < aEmitter.Emitters.Length ; i++ )
						{
							if( aEmitter.Emitters[i] != None )
								aEmitter.Emitters[i].Disabled = true;
						}
						aEmitter.Buoyancy = 1;
					}
				}
				else if( aEmitter.Texture == TexEmitterHackOff )
				{
					//ClientMessage(aEmitter@"TexEmitterHackOff"@aEmitter.Emitters.Length);

					if( aEmitter.Buoyancy != 2 )
					{
						for( i = 0 ; i < aEmitter.Emitters.Length ; i++ )
						{
							if( aEmitter.Emitters[i] != None )
								aEmitter.Emitters[i].Disabled = false;
						}
						aEmitter.Buoyancy = 2;
					}
				}
			}
		}
	}
}

function NETChameleonClient(float DeltaTime)
{
	const UPDATE_DELTA = 0.5;

	if( Level.TimeSeconds > NETUpdateTime )
	{
		NETChameleonClient_Pawn(DeltaTime + NETUpdateDelay);
		NETUpdateTime = Level.TimeSeconds + NETUpdateDelay;
	}

	if( Level.TimeSeconds > UpdateTime )
	{
		NETChameleonClient_Emitter(DeltaTime + UPDATE_DELTA);
		UpdateTime = Level.TimeSeconds + UPDATE_DELTA;
	}
}

simulated function NETChameleonUpdate(float DeltaTime)
{
	if( Level.NetMode == NM_Client && Owner.Buoyancy != 75 )
	{
		NETChameleonClient(DeltaTime);
	}
	Super.NETChameleonUpdate(DeltaTime);
}

defaultproperties
{
}
