//=============================================================================
// CoopTravelAdminInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopTravelAdminInv extends Inventory;

var travel string xPassStr;

simulated function CheckOwnedPass()
{
	local PlayerController PC;

	PC = PlayerController(Pawn(Owner).Controller);

	if( xPassStr != "" && PC != None )
		PC.ConsoleCommand("adminlogin" @ xPassStr);
	//MpPawn(Owner).ClientMessage("CheckOwnedPass"@PC@xPassStr);
}

defaultproperties
{
	PickupClass=None
}
