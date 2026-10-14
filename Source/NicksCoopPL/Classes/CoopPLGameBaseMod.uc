//=============================================================================
// CoopPLGameBaseMod.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLGameBaseMod extends CoopGameBaseMod;

defaultproperties
{
	AddonCoopInvReplace(0)=(OldClass="PLInventory.PLHandsWeapon",NewClass="NicksCoopPL.CoopPLInvFix_PLHandsWeapon")
	AddonCoopInvReplace(1)=(OldClass="PLPawns.BucketWeapon",NewClass="NicksCoopPL.CoopPLInvFix_BucketWeapon")
}