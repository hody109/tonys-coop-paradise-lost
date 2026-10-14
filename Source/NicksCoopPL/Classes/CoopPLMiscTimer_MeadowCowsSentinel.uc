//=============================================================================
// CoopPLMiscTimer_MeadowCowsSentinel.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLMiscTimer_MeadowCowsSentinel extends Actor;

var vector CowPos[8];
var int PosCount;

simulated function PostBeginPlay()
{
	if(Role<ROLE_Authority) return;
	SetDrawType(DT_StaticMesh);
	SetTimer(60+frand(),false);
	SetLocation(CowPos[Rand(8)]);
}

function AddController(FPSPawn newcat)
{
	if ( newcat.Controller == None
		&& newcat.Health > 0 )
	{
		if ( (newcat.ControllerClass != None))
			newcat.Controller = spawn(newcat.ControllerClass);
		if ( newcat.Controller != None )
			newcat.Controller.Possess(newcat);
		// Check for AI Script
		newcat.CheckForAIScript();
	}
}

simulated function Timer()
{
	local PLCowPawn aCow;
	local int nCows;
	if(Role<ROLE_Authority) return;
	foreach DynamicActors(class'PLCowPawn',aCow)
	{
		if( aCow.Health > 0 && aCow.Tag == 'CoopCowHack' )
			nCows++;
	}
	//CoopGameInfo(Level.Game).xCoopServerEventMessage("Trying to spawn cows: " @ (LastRenderTime + 0.5 >= Level.TimeSeconds && nCows < 8));
	if( nCows < 8 && !(LastRenderTime + 0.5 >= Level.TimeSeconds) )
	{
		aCow = spawn(class'PLMadCowPawn',self,,Location);
		if( aCow != None )
		{
			AddController(aCow);
			aCow.Tag = 'CoopCowHack';
		}
	}
	SetTimer(6+frand(),false);
	SetLocation(CowPos[PosCount]);
	PosCount++;
	if( PosCount > 7 )
		PosCount = 0;
}

defaultproperties
{
	CowPos(0)=(X=-6206.0,Y=-726.0,Z=-1510.0)
	CowPos(1)=(X=2173.0,Y=-622.0,Z=-1110.0)
	CowPos(2)=(X=4925.0,Y=3641.0,Z=-1310.0)
	CowPos(3)=(X=2121.0,Y=5797.0,Z=-1642.0)
	CowPos(4)=(X=-1826.0,Y=6137.0,Z=-1750.0)
	CowPos(5)=(X=-4726.0,Y=1681.0,Z=-1534.0)
	CowPos(6)=(X=-1386.0,Y=-3322.0,Z=-946.0)
	CowPos(7)=(X=-766.0,Y=2617.0,Z=-1594.0)

	CollisionRadius=80
	bDirectional=true
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
	Texture=Texture'PostEd.Icons_256.Spawner'
	DrawScale=0.25
	bHidden=false
}
