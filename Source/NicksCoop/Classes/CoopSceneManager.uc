//=============================================================================
// CoopSceneManager.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopSceneManager extends SceneManager
	notplaceable;

//const HOST_SCENE_END_MAXDIST = 4096;

var Pawn SceneHostPawn;

var bool bTriggerExecuted;

function xMoveSceneProperties(SceneManager oldSceneManager, SceneManager newSceneManager)
{
	local int i;

	for( i = 0 ; i < oldSceneManager.Actions.Length ; i++ )
	{
		newSceneManager.Actions[i] = oldSceneManager.Actions[i];
	}

	newSceneManager.Affect = oldSceneManager.Affect;
	newSceneManager.bLooping = oldSceneManager.bLooping;
	//newSceneManager.bCinematicView = oldSceneManager.bCinematicView;
	newSceneManager.bCinematicView = false;
	newSceneManager.PlayerScriptTag = oldSceneManager.PlayerScriptTag;
	newSceneManager.NextSceneTag = oldSceneManager.NextSceneTag;
	// newSceneManager.bLetPlayerSkip = oldSceneManager.bLetPlayerSkip;
	// newSceneManager.bLetPlayerFastForward = oldSceneManager.bLetPlayerFastForward;
	newSceneManager.PrecedingScenesPawn = oldSceneManager.PrecedingScenesPawn;
	newSceneManager.bForbidPausing = oldSceneManager.bForbidPausing;
	newSceneManager.Tag = oldSceneManager.Tag;
	oldSceneManager.Tag = 'coophack_unusedscene';

	// Scene skip is disabled in coop due to some bugs
	newSceneManager.bLetPlayerSkip = false;
	newSceneManager.bLetPlayerFastForward = false;
	newSceneManager.bLetPlayerSkipIfSeen = false;
}

function Trigger( actor Other, Pawn EventInstigator )
{
	//local PlayerController PC;
	//local Controller P;

	// RWS 5/15/15: Prevent these from starting with a dead player
	/*if (Affect == AFFECT_ViewportCamera)
	{
		// If the pawn does not exist (chunked up) or is dead, don't let the scene start here.
		// Exception: if a scene is already running (the player won't have a pawn)
		foreach DynamicActors(class'PlayerController', PC)
			if (PC.GetCurrentSceneManager() == None && (PC.Pawn == None || PC.Pawn.Health <= 0))
				return;
	}*/

	/*///steam 10/04/2016 try to move host to matinee start
	if( EventInstigator != None && EventInstigator.Controller != None && EventInstigator.Controller.Buoyancy != 75 )
	{
		for( P = Level.ControllerList ; P != None ; P = P.nextController )
		{
			if( P.IsA('PlayerController') && P.Pawn != None && P.Buoyancy == 75 )
			{
				P.Pawn.SetLocation(EventInstigator.Location);
				P2Player(P).ClientMessage("you're moved to"@EventInstigator.Location);
				break;
			}
		}
	}*/

	// This is a nasty hack to prevent Trigger loop crash
	if (bTriggerExecuted)
		return;
	bTriggerExecuted = true;

	CoopScene_TeleportHostPlayer(Other, EventInstigator);

	bIsRunning = true;
	bIsSceneStarted = false;
	Disable( 'Trigger' );
}

// Events
event SceneStarted()	// Called from C++ when the scene starts.
{
	local Controller P;
	local AIScript S;

	// Helpful log message
	Log(self @ "SceneStarted(): Tag='"$Tag$"' PlayerScriptTag='"$PlayerScriptTag$"' PrecedingScenesPawn="$PrecedingScenesPawn);

	// Turn off fast forward if the gameinfo forbids it
	if (!Level.Game.bAllowMatineeFastForward)
		bLetPlayerFastForward=false;

	///steam 11/04/2016
	xNotifyMatineeCamera(true);

	// Figure out who our viewer is.
	Viewer = None;
	if( Affect==AFFECT_Actor )
		Viewer = AffectedActor;
	else
	{
		for( P = Level.ControllerList ; P != None ; P = P.nextController )
			if( P.IsA('PlayerController') && P.Buoyancy == 75 )
			{
				Viewer = P;
				// RWS CHANGE: If there was a preceding scene then use it's pawn
				if ( PrecedingScenesPawn != None)
					OldPawn = PrecedingScenesPawn;
				else
					OldPawn = PlayerController(Viewer).Pawn;
				if ( OldPawn != None )
				{
					OldPawn.Velocity = vect(0,0,0);
					OldPawn.Acceleration = vect(0,0,0);

					// RWS CHANGE: Reset the player's spine to stand up straight
					OldPawn.SetTwistLook(0,0);
					OldPawn.bDoTorsoTwist=false;

					// RWS CHANGE: If there was no preceeding scene then do normal startup
					if (PrecedingScenesPawn == None)
						PlayerController(Viewer).UnPossess();
					if ( PlayerScriptTag != 'None' )
					{
						ForEach DynamicActors( class'AIScript', S, PlayerScriptTag )
							break;
						if ( S != None )
							S.TakeOver(OldPawn);
					}
				}

				// RWS CHANGE: If there was no preceeding scene then do normal startup
				if (PrecedingScenesPawn == None)
					PlayerController(Viewer).StartInterpolation();
				PlayerController(Viewer).MyHud.bHideHUD = true;

				// JWB: Moved cinematic view from c++
				PlayerController(Viewer).myHUD.bCinematicView = bCinematicView;
				
				// RWS CHANGE: Always clear to prepare for next time
				PrecedingScenesPawn = None;
				break;
			}
	}
	Viewer.StartCutscene();
	Viewer.StartInterpolation();
}

event SceneEnded()
{
	///steam 11/04/2016
	xNotifyMatineeCamera(false);
	Super.SceneEnded();
	///steam 02/05/2016
	CoopScene_TeleportClientPlayers();

	bTriggerExecuted = false;
}

///steam 11/04/2016
function xNotifyMatineeCamera(bool bStarted)
{
	local CoopMatineeCamera myCoopMatineeCamera;
	local Controller P;
	foreach DynamicActors(class'CoopMatineeCamera', myCoopMatineeCamera)
	{
		myCoopMatineeCamera.bNETUpdateViewport = bStarted;
		break;
	}
	for( P = Level.ControllerList ; P != None ; P = P.nextController )
	{
		if( CoopPlayerController(P) != None )
		{
			if( bStarted )
				CoopPlayerController(P).xSceneStarted();
			else CoopPlayerController(P).xSceneFinished();
		}
	}
}

///steam 01/05/2016
function CoopScene_TeleportHostPlayer(Actor Other, Pawn EventInstigator)
{
	if( CoopGameInfo(Level.Game) != None )
		CoopGameInfo(Level.Game).CoopScene_TeleportHostPlayer(self, Other, EventInstigator);
}

///steam 02/05/2016
function CoopScene_TeleportClientPlayers()
{
	if( CoopGameInfo(Level.Game) != None )
		CoopGameInfo(Level.Game).CoopScene_TeleportClientPlayers(self);
}

defaultproperties
{
	//bOnlyDirtyReplication=false
	//bSkipActorPropertyReplication=false

	Style=STY_Sprite
	Texture=S_SceneManager
	Affect=AFFECT_ViewportCamera
	SceneSpeed=1
	bLooping=False
	DrawScale=0.25
	bLetPlayerFastForward=true
}
