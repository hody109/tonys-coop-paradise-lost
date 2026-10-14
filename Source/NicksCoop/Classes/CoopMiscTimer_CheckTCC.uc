//=============================================================================
// CoopMiscTimer_CheckTCC.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopMiscTimer_CheckTCC extends CoopMiscTimer;

var bool bTCC_Suspected;

simulated function PostBeginPlay()
{
	SetTimer(10+fRand(),false);
}

simulated function bool CheckTCC_UnrealFP()
{
	local CoopPlayerController myPlayer;
	local string sIP;

	myPlayer = CoopPlayerController(Owner);
	if( myPlayer == None )
		return false;

	sIP = myPlayer.GetPlayerNetworkAddress();
	if( myPlayer.PlayerReplicationInfo.Ping > 900000 )
	{
		Log(sIP @ myPlayer.PlayerReplicationInfo.PlayerName @ "USES UNREAL FP");
		if( CoopGameInfo(Level.Game) != None )
		{
			myPlayer.ClientMessage("You have been automatically banned for TCC action, contact admin for more information.");
			CoopGameInfo(Level.Game).xCoopReportLogF(sIP @ myPlayer.PlayerReplicationInfo.PlayerName @ " USES UNREAL FP");
			CoopGameInfo(Level.Game).CoopAddToBanList(sIP, true);
			return true;
		}
	}
	return false;
}

simulated function bool CheckTCC()
{
	return CheckTCC_UnrealFP();
}

simulated function Timer()
{
	if( bTCC_Suspected )
	{
		if( Owner != None )
		{
			Owner.LifeSpan = 0.1;
			SetTimer(1.0+frand(), false);
		}
		else LifeSpan = 1.0;
	}
	else if( CheckTCC() )
	{
		bTCC_Suspected = true;
		SetTimer(1.0+frand(), false);
	}
}

defaultproperties
{
	bHidden=true
}
