//=============================================================================
// CoopInvFix_ClipboardAmmoInv.uc
// -use it only for clients
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_ClipboardAmmoInv extends ClipboardAmmoInv;

var bool bClipboardDisabled;

replication
{
	unreliable if( Role == ROLE_Authority )
		bClipboardDisabled;
}

function AddedToPawnInv(Pawn UsePawn, Controller UseCont)
{
	///STUB
	///steam 20/11/2017
	if( AmmoAmount >= MaxAmmo )
		bClipboardDisabled = true;
}

///steam 20/11/2017
simulated function bool HasAmmo()
{
	if( bClipboardDisabled )
		return false;
	return bReadyForUse;
}

///steam 20/11/2017
simulated function bool HasAmmoStrict()
{
	if( bClipboardDisabled )
		return false;
	return true;
}

defaultproperties
{
}
