//=============================================================================
// CoopInvFix_GrenadeLauncherWeapon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopInvFix_GrenadeLauncherWeapon extends GrenadeLauncherWeapon;

function SpawnCatRocket(Pawn Instigator, Vector StartLoc, Rotator StartRot)
{
	Super.SpawnCatRocket(Instigator, StartLoc, StartRot);
	P2AmmoInv(AmmoType).UseAmmoForShot();
}

defaultproperties
{
	CatRocketClass=class'CoopInvFix_CatRocketGrenade'
}
