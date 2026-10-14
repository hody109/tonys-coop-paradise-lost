//=============================================================================
// CoopMiscTimer_WantedStatus.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2018.
//=============================================================================

class CoopMiscTimer_WantedStatus extends CoopMiscTimer;

var GameState TheGameState;

simulated function PostBeginPlay()
{
	if( P2GameInfoSingle(Level.Game) != None )
		TheGameState = P2GameInfoSingle(Level.Game).TheGameState;
}

simulated function CopRadio_Update(bool bInit)
{
	local CoopPostalDude aOwner;

	aOwner = CoopPostalDude(Owner);

	if( bInit )
	{
		if( aOwner.CoopWantedStatus == 0 )
			aOwner.CoopWantedStatus = TheGameState.CopRadioBase;
	}
	else IncreaseCopRadioTime();
}

function float CopsWantPlayer()
{
	local CoopPostalDude aOwner;

	aOwner = CoopPostalDude(Owner);

	if( TheGameState.CopsWantPlayer() > 0 )
		return aOwner.CoopWantedStatus / TheGameState.CopRadioMax;
	return 0;
}

function IncreaseCopRadioTime()
{
	local CoopPostalDude aOwner;

	aOwner = CoopPostalDude(Owner);

	if(aOwner.CoopWantedStatus == 0)
		aOwner.CoopWantedStatus = TheGameState.CopRadioBase;
	else aOwner.CoopWantedStatus+=TheGameState.CopRadioInc;

	if(aOwner.CoopWantedStatus > TheGameState.CopRadioMax)
		aOwner.CoopWantedStatus = TheGameState.CopRadioMax;

	SetTimer(TheGameState.CopRadioTimerInterval, false);
}

function SetRadioTimer()
{
	local CoopPostalDude aOwner;

	aOwner = CoopPostalDude(Owner);

	if(aOwner.CoopWantedStatus < TheGameState.CopRadioBase
		&& TheGameState.CopsAfterPlayer.Length > 0)
	{
		//CopRadioFloorBase();
		if(aOwner.CoopWantedStatus < TheGameState.CopRadioBase)
			aOwner.CoopWantedStatus = TheGameState.CopRadioBase;
	}

	// if we're done, then don't reset the timer	
	if(aOwner.CoopWantedStatus <= 0)
	{
		//ResetCopRadioTime();
		aOwner.CoopWantedStatus = 0;
	}
	else
	{
		// if we have less time left than our decrement
		if(aOwner.CoopWantedStatus < TheGameState.CopRadioTimerInterval)
			SetTimer(aOwner.CoopWantedStatus, false);
		else
			SetTimer(TheGameState.CopRadioTimerInterval, false);
	}
}

function Timer()
{
	local CoopPostalDude aOwner;

	aOwner = CoopPostalDude(Owner);

	aOwner.CoopWantedStatus -= TheGameState.CopRadioDec;

	SetRadioTimer();
}

defaultproperties
{
	bHidden=true
}
