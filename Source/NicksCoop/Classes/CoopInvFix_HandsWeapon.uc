//=============================================================================
// CoopInvFix_HandsWeapon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopInvFix_HandsWeapon extends HandsWeapon;

function ServerFire()
{
	//if(!Level.Game.bIsSinglePlayer)
	//{
		P2MocapPawn(Instigator).ServerFollowMe();
		PlayFiring();
		GotoState('NormalFire');
	//}
}

function ServerAltFire()
{
	//if(!Level.Game.bIsSinglePlayer)
	//{
		P2MocapPawn(Instigator).ServerStayHere();

		bAltFiring=true;

		PlayAltFiring();
		GotoState('NormalFire');
	//}
}

simulated function Fire( float Value )
{
	if(P2MocapPawn(Instigator) != None
		&& Bot(Instigator.Controller) == None
		/*&& (Level.Game == None
			|| !Level.Game.bIsSinglePlayer)*/)
	{
		ServerFire();
		if ( Role < ROLE_Authority )
		{
			PlayFiring();
			GotoState('ClientFiring');
		}
	}
}

simulated function AltFire( float Value )
{
	if(P2MocapPawn(Instigator) != None
		&& Bot(Instigator.Controller) == None
		/*&& (Level.Game == None
			|| !Level.Game.bIsSinglePlayer)*/)
	{
		ServerAltFire();
		if ( Role < ROLE_Authority )
		{
			PlayAltFiring();
			GotoState('ClientFiring');
		}
	}
}

simulated function PlayFiring()
{
	//if(Level.Game == None
	//		|| !Level.Game.bIsSinglePlayer)
		PlayAnim('Point', WeaponSpeedShoot1 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

simulated function PlayAltFiring()
{
	//if(Level.Game == None
	//		|| !Level.Game.bIsSinglePlayer)
		PlayAnim('Stay', WeaponSpeedShoot2 + (WeaponSpeedShoot1Rand*FRand()), 0.05);
}

///steam 18/06/2016
simulated function float SwitchPriority()
{
	///steam 08/09/2018 - switch fix - allows to fool the ClientWeaponSet()
	if( Level.TimeSeconds < 10 )
		return 999999;
	return Super.SwitchPriority();
}

defaultproperties
{
}
