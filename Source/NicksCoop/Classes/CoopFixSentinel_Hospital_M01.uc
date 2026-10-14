//=============================================================================
// CoopFixSentinel_Hospital_M01.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopFixSentinel_Hospital_M01 extends Actor;

var Name GlitchMoverName;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(10.2, false);
}

function int CountPlayers()
{
	local Controller aCon;
	local int nCount;
	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
	{
		if( CoopPlayerController(aCon) != None 
			&& !CoopPlayerController(aCon).IsCoopDedicatedHost() 
			&& aCon.Pawn != None 
			&& !aCon.Pawn.bDeleteMe )
			nCount++;
	}
	return nCount;
}

function Timer()
{
	local CoopGameInfo myGame;
	local Mover aMover;

	myGame = CoopGameInfo(Level.Game);
	if( myGame != None )
	{
		if( CountPlayers() == 0 )
		{
			foreach DynamicActors(class'Mover', aMover)
			{
				if( aMover.Name == GlitchMoverName && !aMover.bClosed )
				{
					myGame.CoopRestartLevel();
					log(self @ "- Fixing elevator bug" @ aMover);
					SetTimer(10.2, false);///steam 30/10/2017 - in case restart has not worked
					return;
				}
			}
		}
		SetTimer(5.1, false);
	}
}

defaultproperties
{
	GlitchMoverName="Mover0"
	bHidden=true
}
