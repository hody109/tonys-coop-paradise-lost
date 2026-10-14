//=============================================================================
// CoopFix_ACTION_CoopWait.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFix_ACTION_CoopWait extends LatentScriptedAction;

function bool InitActionFor(ScriptedController C)
{
	local SceneManager SM;
	local PlayerController P;

	if( CoopGameInfo(C.Level.Game) == None )
		return false;

    C.CurrentAction = self;

	if( C.Level.Game.GameReplicationInfo != None )
		CoopGameReplicationInfo(C.Level.Game.GameReplicationInfo).bCoopWaitPlayers = true;

	if( CoopGameInfo(C.Level.Game).CoopIsIntroLevel() && CoopGameInfo(C.Level.Game).SetCoopWaitSC(C) )
	{
		if( C.Level.Game.GameReplicationInfo != None )
			CoopGameReplicationInfo(C.Level.Game.GameReplicationInfo).bCoopWaitContinue = true;
		CoopGameInfo(C.Level.Game).xCoopServerEventMessage("CoopGame: waiting other players");
		///log("CoopGame: waiting other players"@self);
		C.SetTimer(480, false);
	}
	else
	{
		CoopGameInfo(C.Level.Game).xCoopServerEventMessage("CoopGame: please wait 8s");
		C.SetTimer(8, false);
	}

	P = CoopGameInfo(C.Level.Game).GetPlayer();
	if( P != None )
	{
		SM = P.GetCurrentSceneManager();
		if( SM != None && SM.bIsRunning )
		{
			SM.bIsRunning = false;
			SM.Buoyancy = 1;
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
	ActionString="Wait for coop players"
}
