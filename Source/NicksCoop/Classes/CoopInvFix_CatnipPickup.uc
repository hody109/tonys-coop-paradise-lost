//=============================================================================
// CoopInvFix_CatnipPickup.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopInvFix_CatnipPickup extends CatnipPickup;

function ConvertToUsed()
{
	Super.ConvertToUsed();
	LifeSpan = 10.0;
}

defaultproperties
{
	InventoryType=class'CoopInvFix_CatnipInv'
}
