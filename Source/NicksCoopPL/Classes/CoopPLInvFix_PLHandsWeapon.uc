//=============================================================================
// CoopPLInvFix_PLHandsWeapon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLInvFix_PLHandsWeapon extends PLHandsWeapon;

simulated function CallPLGetDown()
{
	if( P2MocapPawn(Instigator) != None && P2Player(P2MocapPawn(Instigator).Controller) != None )
		P2Player(P2MocapPawn(Instigator).Controller).ServerGetDown();
}

/*simulated function PlayFiring()
{
	Super.PlayFiring();
	CallPLGetDown();
}

simulated function PlayAltFiring()
{
	Super.PlayAltFiring();
	CallPLGetDown();
}*/

function ServerFire()
{
	//if(!Level.Game.bIsSinglePlayer)
	//{
		///P2MocapPawn(Instigator).ServerFollowMe();
		CallPLGetDown();
		PlayFiring();
		GotoState('NormalFire');
	//}
}

function ServerAltFire()
{
	//if(!Level.Game.bIsSinglePlayer)
	//{
		///P2MocapPawn(Instigator).ServerStayHere();
		CallPLGetDown();
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

///steam 18/06/2016
simulated function float SwitchPriority() 
{
	return 999999;
}

defaultproperties
{
}
