//=============================================================================
// CoopSpecialLocalMessage.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopSpecialLocalMessage extends GameEventPlus;

var string Message;

static simulated function ClientReceive( 
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
	if ( (Switch > 1) && (Switch < 5) 
		&& P.ViewTarget != None)
		P.PlayBeepSound();
}

static function string GetString(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return default.Message;
}

defaultproperties
{
	DrawColor(1)=(R=211,G=0,B=0,A=255)
	Lifetime=1
	bIsConsoleMessage=true
}