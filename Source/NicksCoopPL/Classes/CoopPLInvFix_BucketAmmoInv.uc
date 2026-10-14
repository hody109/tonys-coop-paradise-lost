//=============================================================================
// CoopPLInvFix_BucketAmmoInv.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLInvFix_BucketAmmoInv extends BucketAmmoInv;

var bool bAmmoDisabled;

replication
{
	unreliable if( Role == ROLE_Authority )
		bAmmoDisabled;
}

function AddedToPawnInv(Pawn UsePawn, Controller UseCont)
{
	Super.AddedToPawnInv(UsePawn, UseCont);
	if( CoopGameInfo(Level.Game) != None )
		bAmmoDisabled = !CoopGameInfo(Level.Game).CoopIsMap("PL-MEADOW");
}

///steam 20/11/2017
simulated function bool HasAmmo()
{
	if( bAmmoDisabled )
		return false;
	return Super.HasAmmo();
}

///steam 20/11/2017
simulated function bool HasAmmoStrict()
{
	if( bAmmoDisabled )
		return false;
	return Super.HasAmmoStrict();
}

defaultproperties
{
}
