//=============================================================================
// CoopInvFix_ClipboardWeapon.uc
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

class CoopInvFix_ClipboardWeapon extends ClipboardWeapon;

function SwapBackToHands();

simulated function Fire( float Value )
{
	if( AmmoType != None && AmmoType.AmmoAmount >= AmmoType.MaxAmmo )
		return;
	Super.Fire(Value);
}

simulated function AltFire( float Value )
{
	if( AmmoType != None && AmmoType.AmmoAmount >= AmmoType.MaxAmmo )
		return;
	Super.AltFire(Value);
}

///steam 04/10/2016
state ClientFiring
{
	simulated function AltFire( float Value )
	{
		if( Level.NetMode == NM_Client )
		{
			if( !IsAnimating() )
			{
				GotoState('Idle');
				return;
			}
		}
		Super.AltFire(Value);
	}
}

function GiveTo(Pawn Other)
{
	Super(P2Weapon).GiveTo(Other);
}

simulated function PlayIdleAnim()
{
	local P2Player p2p;
	local P2GameInfoSingle checkg;

	if( Role == ROLE_Authority )
	{
		if( AmmoType != None && AmmoType.AmmoAmount >= AmmoType.MaxAmmo )
		{
			checkg = P2GameInfoSingle(Level.Game);
			p2p = P2Player(Instigator.Controller);
			if(checkg != None)
				checkg.CheckForErrandCompletion(self, None, None, p2p, false);
		}
	}
	Super(P2Weapon).PlayIdleAnim();
}

defaultproperties
{
	//WeaponSpeedShoot1Rand=0.01
	AmmoName=class'CoopInvFix_ClipboardAmmoInv'
}
