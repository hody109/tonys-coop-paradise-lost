//=============================================================================
// CoopTravelPlayerInfoInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopTravelPlayerInfoInv extends Inventory;

var travel int xLastWeaponGroupHands;///LG=
var travel int xLastWeaponOffsetHands;///LO=

///steam 13/06/2016
var travel int xKills;///K=
var travel int xDeaths;///D=

///steam 29/07/2016
var travel bool bXShowCoopPlayers;

///steam 02/01/2017
var travel int xCurrentClothesDay;///CD=
var travel class<Inventory> xCurrentClothes;///CC=

///steam 01/08/2017
var travel int xCoopAddInStartingInv;

///steam 01/08/2017
var travel string xCoopTravelCheckSum;

// UPD 20/04/2018
var travel float xWantedStatus;///WS=

///steam 06/06/2016 lastweapfix
function CoopRememberLastWeapon(int nLastWeaponGroupHands, int nLastWeaponOffsetHands)
{
	xLastWeaponGroupHands = nLastWeaponGroupHands;
	xLastWeaponOffsetHands = nLastWeaponOffsetHands;
	///MpPawn(Owner).ClientMessage("CoopRememberLastWeapon"@xLastWeaponGroupHands@xLastWeaponOffsetHands);
}

///steam 06/06/2016 lastweapfix
function CoopGetLastWeapon()
{
	local CoopPlayerController myPlayer;
	myPlayer = CoopPlayerController(Pawn(Owner).Controller);
	if( myPlayer != None && myPlayer.Buoyancy != 75 )
	{
		myPlayer.xClientGetLastWeap(xLastWeaponGroupHands, xLastWeaponOffsetHands);
		///myPlayer.ClientMessage("CoopGetLastWeapon"@xLastWeaponGroupHands@xLastWeaponOffsetHands);
	}
}

///steam 19/08/2017
function string DecryptInfoOption(string sInfo, string sKey)
{
	local int i, j, n;

	j = InStr(sInfo, sKey);
	if( j == -1 )
		return "";

	n = Len(sKey);
	for( i = j+n ; i < Len(sInfo) ; i++ )
	{
		if( Mid(sInfo, i, 1) == "?" )
			return Mid(sInfo, j+n, i-(j+n));
	}
	return "";
}

function string CryptInfo(CoopPlayerController aPC)
{
	local string sResult;
	local CoopPlayerReplicationInfo aReplicaInfo;
	local int UseHealth;

	if( aPC == None )
		return "";

	aReplicaInfo = CoopPlayerReplicationInfo(aPC.PlayerReplicationInfo);
	if( aReplicaInfo == None )
		return "";

	sResult = "K=" $ aReplicaInfo.Kills $ "?";
	sResult = sResult $ "D=" $ int(aReplicaInfo.Deaths) $ "?";

	if( Pawn(Owner) != None )
	{
		UseHealth = int(FMax(Pawn(Owner).Health,1));
		sResult = sResult $ "H=" $ UseHealth $ "?";
	}

	sResult = sResult $ "LG=" $ aPC.LastWeaponGroupHands $ "?";
	sResult = sResult $ "LO=" $ aPC.LastWeaponOffsetHands $ "?";

	if( aPC.CurrentClothes != None 
		&& aPC.CurrentClothes != aPC.DefaultClothes 
		&& CoopGameInfo(Level.Game).TheGameState != None )
	{
		sResult = sResult $ "CC=" $ string(aPC.CurrentClothes) $ "?";
		sResult = sResult $ "CD=" $ CoopGameInfo(Level.Game).TheGameState.CurrentDay $ "?";
	}

	if( CoopPostalDude(Owner) != None )
		sResult = sResult $ "WS=" $ CoopPostalDude(Owner).CoopWantedStatus $ "?";

	return sResult;
}

///steam 13/06/2016
function DecryptInfo(string sInfo)
{
	local class<Inventory> useInvClass;
	local float UseHealth;

	xKills = int(DecryptInfoOption(sInfo, "K="));
	xDeaths = int(DecryptInfoOption(sInfo, "D="));

	if( Pawn(Owner) != None )
	{
		UseHealth = int(DecryptInfoOption(sInfo, "H="));
		if( UseHealth >= 1 )
			Pawn(Owner).Health = UseHealth;
		xWantedStatus = float(DecryptInfoOption(sInfo, "WS="));
	}

	xLastWeaponGroupHands = int(DecryptInfoOption(sInfo, "LG="));
	xLastWeaponOffsetHands = int(DecryptInfoOption(sInfo, "LO="));

	useInvClass = class<Inventory>(DynamicLoadObject(DecryptInfoOption(sInfo, "CC="), class'Class'));
	if( useInvClass != None )
	{
		xCurrentClothes = useInvClass;
		xCurrentClothesDay = int(DecryptInfoOption(sInfo, "CD="));
	}
}

///steam 19/08/2017
function UpdateTravelCheckSum()
{
	xCoopTravelCheckSum = "1";
}
function ResetTravelCheckSum()
{
	xCoopTravelCheckSum = "0";
}

///steam 19/08/2017
function string GetTravelCheckSum()
{
	return xCoopTravelCheckSum;
}

defaultproperties
{
	xCoopTravelCheckSum="0"
	xCoopAddInStartingInv=-1
	xCurrentClothesDay=-1

	PickupClass=None
}
