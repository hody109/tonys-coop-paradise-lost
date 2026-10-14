//=============================================================================
// CoopNETChameleonModuleHost.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopNETChameleonModuleHost extends CoopNETChameleonModuleClient;

var float GameStateUpdateTime;
var float GameStateUpdateDelay;

function NETChameleonServer_Pawn(float DeltaTime)
{
	local P2MoCapPawn aChameleonPawn;
	local FPSPawn aPawn;

	foreach DynamicActors(class'FPSPawn', aPawn)
	{
		aPawn.bAllowStasis = false;

		aChameleonPawn = P2MoCapPawn(aPawn);
		if( aChameleonPawn != None )
		{
			if( !aChameleonPawn.bPlayer )
			{
				// HACK: allows to fool the dying timer (REMOVE_DEAD_START_TIME)
				if( !aPawn.bTearOff && aPawn.Health <= 0 )
				{
					if( (aPawn.TimerRate-aPawn.TimerCounter) < PawnDeadTimerHackLeft )
						aChameleonPawn.SetTimer(PawnDeadTimerHackRate, false);
					//ClientMessage(aPawn @ aPawn.TimerRate @ aPawn.TimerCounter);
				}
			}
		}
	}
}

function NETChameleonServer_Emitter(float DeltaTime)
{
	local Emitter aEmitter;

	foreach DynamicActors(class'Emitter', aEmitter)
	{
		///steam 21/05/2016
		if( aEmitter.Texture == TexEmitterHackOn || aEmitter.Texture == TexEmitterHackOff )
		{
			if( aEmitter.Emitters.Length > 0 )
			{
				if( !aEmitter.Emitters[0].Disabled )
					aEmitter.Texture = TexEmitterHackOff;
				else aEmitter.Texture = TexEmitterHackOn;
			}
		}
	}
}

function NETChameleonServer(float DeltaTime)
{
	const UPDATE_DELTA = 0.5;

	if( Level.TimeSeconds > NETUpdateTime )
	{
		NETChameleonServer_Pawn(DeltaTime + NETUpdateDelay);
		NETUpdateTime = Level.TimeSeconds + NETUpdateDelay;
	}

	if( Level.TimeSeconds > UpdateTime )
	{
		NETChameleonServer_Emitter(DeltaTime + UPDATE_DELTA);
		UpdateTime = Level.TimeSeconds + UPDATE_DELTA;
	}
}

///steam 24/11/2016
function NETUpdateGameState_Ext(GameState myGameState, CoopGameReplicationInfo myGameReplicaInfo, CoopPlayerController PC);

function NETUpdateGameState()
{
	local int i, j;
	local GameState myGameState;
	local CoopGameReplicationInfo myGameReplicaInfo;
	local CoopPlayerController PC;

	myGameState = CoopGameInfo(Level.Game).TheGameState;
	myGameReplicaInfo = CoopGameReplicationInfo(Level.Game.GameReplicationInfo);

	PC = CoopPlayerController(Owner);
	if( myGameState == None 
		&& PC.myMapScreen != None 
		&& PC.myMapScreen.gs != None )
		myGameState = PC.myMapScreen.gs;

	if( myGameState == None 
		|| myGameReplicaInfo == None )
		return;

	j = 0;
	for( i = 0 ; i < myGameState.CompletedErrands.Length ; i++ )
	{
		if( myGameState.CompletedErrands[i].Day == myGameState.CurrentDay )
		{
			if( j < myGameReplicaInfo.ERRANDS_MAX )
				myGameReplicaInfo.TodayCompletedErrands[j] = myGameState.CompletedErrands[i].Errand;
			j++;
		}
	}
	j = 0;
	for( i = 0 ; i < myGameState.RevealedErrands.Length ; i++ )
	{
		if( myGameState.RevealedErrands[i].Day == myGameState.CurrentDay )
		{
			if( j < myGameReplicaInfo.ERRANDS_MAX )
				myGameReplicaInfo.TodayActivatedErrands[j] = myGameState.RevealedErrands[i].Errand;
			j++;
		}
	}

	///steam 03/05/2016
	myGameReplicaInfo.KillJobsLength = FClamp(PC.KillJobs.Length,0,ArrayCount(myGameReplicaInfo.KillJobs));
	for( i = 0 ; i < myGameReplicaInfo.KillJobsLength ; i++ )
	{
		myGameReplicaInfo.KillJobs[i].HUDIcon = PC.KillJobs[i].HUDIcon;
		myGameReplicaInfo.KillJobs[i].ShakeKillTime = PC.KillJobs[i].ShakeKillTime;
		myGameReplicaInfo.KillJobs[i].bPercentageDisplay = PC.KillJobs[i].bPercentageDisplay;
		myGameReplicaInfo.KillJobs[i].bWillow = PC.KillJobs[i].bWillow;
		myGameReplicaInfo.KillJobs[i].WillowText = PC.KillJobs[i].WillowText;
		//myGameReplicaInfo.KillJobs[i].OldCount = PC.KillJobs[i].OldCount;
		//myGameReplicaInfo.KillJobs[i].StartTime = PC.KillJobs[i].StartTime;
		if( PC.KillJobs[i].BossPawn != None )
		{
			myGameReplicaInfo.KillJobs[i].UseCount = PC.KillJobs[i].BossPawn.Health;
			myGameReplicaInfo.KillJobs[i].UseMax = PC.KillJobs[i].BossPawn.HealthMax;
		}
		else if( PC.KillJobs[i].KillTrigger != None && AWTrigger(PC.KillJobs[i].KillTrigger) != None )
		{
			myGameReplicaInfo.KillJobs[i].UseMax = AWTrigger(PC.KillJobs[i].KillTrigger).TimesTillTrigger;
			myGameReplicaInfo.KillJobs[i].UseCount = AWTrigger(PC.KillJobs[i].KillTrigger).UseTimes;
		}
	}

	myGameReplicaInfo.CopRadioTime = myGameState.CopRadioTime;
	myGameReplicaInfo.CurrentDay = myGameState.CurrentDay;

	///steam 24/11/2016
	NETUpdateGameState_Ext(myGameState, myGameReplicaInfo, PC);
}

simulated function NETChameleonUpdate(float DeltaTime)
{
	if( Role == ROLE_Authority && Owner.Buoyancy == 75 )
	{
		if( Level.TimeSecondsAlways > GameStateUpdateTime )
		{
			NETUpdateGameState();
			GameStateUpdateTime = Level.TimeSecondsAlways + GameStateUpdateDelay;
		}
		NETChameleonServer(DeltaTime);
	}
	Super.NETChameleonUpdate(DeltaTime);
}

defaultproperties
{
	GameStateUpdateDelay=0.16
}
