//=============================================================================
// CoopPLPostalDude.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLPostalDude extends PLPostalDude;

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	Super(CoopPostalDude).Died(Killer, damageType, HitLocation);
}

///steam 24/08/2016
simulated function PostBeginPlay()
{
	Tag = default.Tag;
	Super.PostBeginPlay();
}

defaultproperties
{
	HandsClass=class'CoopPLInvFix_PLHandsWeapon'
	HandsClassEnhanced="NicksCoopPL.CoopPLInvFix_PLHandsWeapon"
	HandsClassNormal="NicksCoopPL.CoopPLInvFix_PLHandsWeapon"
	//HandsClass=class'PLInventory.PLHandsWeapon'
	Tag="PLPostalDude"
	bCoopPlayer=true
}
