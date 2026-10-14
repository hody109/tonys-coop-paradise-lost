//=============================================================================
// CoopMiscTimer_AutoRestartLevel.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMiscTimer_AutoRestartLevel extends CoopMiscTimer;

var int nRemaining;
var localized string RestartMsg;
var localized string RestartMsgSeconds;

simulated function PostBeginPlay()
{
	SetTimer(1.0,false);
}

simulated function Timer()
{
	CoopGameInfo(Level.Game).xCoopServerEventMessage(RestartMsg @ nRemaining @ RestartMsgSeconds, true);
	nRemaining--;
	if( nRemaining < 0 )
	{
		CoopGameInfo(Level.Game).DecideAutoRestartLevel();
		//CoopGameInfo(Level.Game).CoopRestartLevel();
	}
	else
	{
		SetTimer(1.0,false);
		return;
	}
	LifeSpan = 0.1;
}

defaultproperties
{
	RestartMsg="RESTART"
	RestartMsgSeconds="s"
	nRemaining=15
	bHidden=true
}
