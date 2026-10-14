//=============================================================================
// CoopTelepadBlockerSentinel.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopTelepadBlockerSentinel extends Actor;

var array<PersonPawn> RequestHolders;

var localized string TravelRequestMsg;
var localized string TravelRequestMsgPlayers1;
var localized string TravelRequestMsgPlayers2;
var localized string TravelAccessGranted;

function int GetLevelPlayersNum()
{
	local int nPlayersNum;
	local Controller aCon;
	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.nextController )
	{
		if( aCon.Pawn != None 
			&& !aCon.Pawn.bDeleteMe
			&& CoopPlayerController(aCon) != None 
			&& !CoopPlayerController(aCon).IsCoopDedicatedHost() 
			&& !CoopPlayerController(aCon).IsCoopPlayerAFK() 
			&& aCon.Pawn.Health > 0 )
			nPlayersNum++;
	}
	return nPlayersNum;
}

/**
>50%
1) +0 +
2) +1 +
3) +1 +
4) +2 +
5) +2 + 
6) +3 +
7) +3 +
8) +4 +
9) +4 +
**/
function int GetAccessPlayersNum()
{
	local int nPlayersNum;
	local float fAccessPercent;

	nPlayersNum = GetLevelPlayersNum();
	fAccessPercent = FMin(CoopGameInfo(Level.Game).CoopTravelAccessPercent,0.99);

	if( fAccessPercent == 0 )
		return 0;
	if( RequestHolders.Length > 0 && nPlayersNum > 0 )
		return FMax(((Floor(nPlayersNum*fAccessPercent)-RequestHolders.Length)+1),0);
	return -1;
}

function bool GetFinalAccess()
{
	return (GetAccessPlayersNum() == 0);
}

function NotifyRequestActivity(bool bActive)
{
	if( CoopTelepadBlocker(Owner) != None )
		CoopTelepadBlocker(Owner).bHidden = !bActive;
}

function TravelAccessControl(bool bGrantAccess)
{
	if( CoopTelepadBlocker(Owner) == None )
		return;

	CoopTelepadBlocker(Owner).TravelAccessControl(bGrantAccess);
	if( bGrantAccess )
		SetCollision(false);
	else SetCollision(true);
}

function GrantTravelAccess()
{
	local string sMsg;

	if( GetFinalAccess() )
	{
		TravelAccessControl(true);
		///CoopGameInfo(Level.Game).xCoopServerEventMessage(TravelAccessGranted, true);
	}
	else
	{
		NotifyRequestActivity(true);
		sMsg = TravelRequestMsg @ RequestHolders[0].GetHumanReadableName();
		if( RequestHolders.Length > 1 )
			sMsg = sMsg @ TravelRequestMsgPlayers1 @ (RequestHolders.Length-1) @ TravelRequestMsgPlayers2;
		CoopGameInfo(Level.Game).xCoopServerEventMessage(sMsg, true);
	}
	SetTimer(6.0, false);
}

function RegisterRequest(PersonPawn aPawn)
{
	local int i;

	if( aPawn == None 
		|| aPawn.bDeleteMe 
		|| aPawn.Controller == None 
		|| !aPawn.IsHumanControlled() 
		|| aPawn.Health <= 0 )
		return;

	//aPawn.ClientMessage("RegisterRequest"@aPawn);

	for( i = 0 ; i < RequestHolders.Length ; i++ )
	{
		if( RequestHolders[i] != None 
			&& !RequestHolders[i].bDeleteMe 
			&& RequestHolders[i].Health > 0 )
		{
			if( RequestHolders[i] == aPawn )
				return;
		}
		else
		{
			RequestHolders.Remove(i, 1);
			i--;
		}
	}

	i = RequestHolders.Length;
	RequestHolders.Insert(i, 1);
	RequestHolders[i] = aPawn;

	GrantTravelAccess();
}

function RemoveRequest(PersonPawn aPawn)
{
	local int i;

	if( aPawn == None 
		|| aPawn.bDeleteMe 
		|| aPawn.Controller == None 
		|| !aPawn.IsHumanControlled() 
		|| aPawn.Health <= 0 )
		return;

	//aPawn.ClientMessage("RemoveRequest"@aPawn);

	for( i = 0 ; i < RequestHolders.Length ; i++ )
	{
		if( RequestHolders[i] == None 
			|| RequestHolders[i].bDeleteMe 
			|| RequestHolders[i].Health <= 0 
			|| RequestHolders[i] == aPawn )
		{
			RequestHolders.Remove(i, 1);
			i--;
		}
	}
}

function Touch(Actor Other)
{
	if( Other != None && PersonPawn(Other) != None )
		RegisterRequest(PersonPawn(Other));
}

function UnTouch(Actor Other)
{
	if( Other != None && PersonPawn(Other) != None )
		RemoveRequest(PersonPawn(Other));
}

function Timer()
{
	local int i;
	for( i = 0 ; i < RequestHolders.Length ; i++ )
	{
		if( RequestHolders[i] == None 
			|| RequestHolders[i].bDeleteMe 
			|| RequestHolders[i].Health <= 0 )
		{
			RequestHolders.Remove(i, 1);
			i--;
		}
	}
	if( !GetFinalAccess() )
	{
		TravelAccessControl(false);
		if( RequestHolders.Length == 0 )
			NotifyRequestActivity(false);
	}
}

defaultproperties
{
	TravelRequestMsg="Travel requested by"
	TravelRequestMsgPlayers1="and"
	TravelRequestMsgPlayers2="more players"
	TravelAccessGranted="Travel access granted"

	bCollideWorld=false
	bCollideActors=true
	bBlockActors=false
	bBlockPlayers=false
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=true
	CollisionRadius=1.0
	CollisionHeight=1.0
	bStatic=false
	Texture=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame_un'
	bHidden=true
	DrawScale=0.38
}
