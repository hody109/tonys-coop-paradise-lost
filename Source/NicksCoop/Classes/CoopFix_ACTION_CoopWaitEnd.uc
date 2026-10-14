//=============================================================================
// CoopFix_ACTION_CoopWaitEnd.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFix_ACTION_CoopWaitEnd extends LatentScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local SceneManager SM;
	local PlayerController P;

    C.CurrentAction = self;
	C.SetTimer(1, false);

	///CoopGameInfo(C.Level.Game).xCoopServerEventMessage("CoopGame: waiting players finished");

	if( C.Level.Game.GameReplicationInfo != None )
	{
		CoopGameReplicationInfo(C.Level.Game.GameReplicationInfo).bCoopWaitPlayers = false;
		CoopGameReplicationInfo(C.Level.Game.GameReplicationInfo).bCoopWaitContinue = false;
	}

	P = CoopGameInfo(C.Level.Game).GetPlayer();
	if( P != None )
	{
		SM = P.GetCurrentSceneManager();
		if( SM != None && SM.Buoyancy == 1 )
		{
			SM.bIsRunning = true;
			///P.ClientMessage(SM@"bIsRunning"@SM.bIsRunning);
		}
	}

	return true;
}

function bool CompleteWhenTimer()
{
	return true;
}

defaultproperties
{
	ActionString="Wait for coop players end"
}
