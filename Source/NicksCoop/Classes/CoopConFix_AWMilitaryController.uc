//=============================================================================
// CoopConFix_AWMilitaryController.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopConFix_AWMilitaryController extends AWMilitaryController;

///steam 20/11/2016
var float fForceAlertTime;
const FORCE_ALERT_DELAY = 0.1;

///steam 04/08/2016
function bool xPlayerIsRealEnemy()
{
	return ( MyPawn != None && !MyPawn.bDeleteMe 
			&& (MyPawn.bPlayerIsEnemy || MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_AttackPlayer) );
}

///steam 04/08/2016
function bool xCanKillThisPlayer(Pawn Other)
{
	return ( Other != None && !Other.bDeleteMe && Other.Controller != None && Other.Controller.IsA('PlayerController') && Other.Health > 0 );
}

///steam 04/08/2016
function HearNoise(float Loudness, Actor NoiseMaker)
{
	if( xPlayerIsRealEnemy() 
		&& NoiseMaker != None 
		&& !NoiseMaker.bDeleteMe 
		&& xCanKillThisPlayer(NoiseMaker.Instigator) )
		xForceAlertMe(NoiseMaker.Instigator);
}

///steam 04/08/2016
event SeePlayer(Pawn SeenPlayer)
{
	if( xPlayerIsRealEnemy() 
		&& xCanKillThisPlayer(SeenPlayer) )
		xForceAlertMe(SeenPlayer);
}

///steam 04/08/2016
event xForceAlertMe(Pawn AlertPawn)
{
	if( Attacker != None 
		&& ( Attacker == AlertPawn 
			|| VSize(AlertPawn.Location-MyPawn.Location) > VSize(Attacker.Location-MyPawn.Location)) )
		return;

	///steam 20/11/2016
	if( Level.TimeSeconds < fForceAlertTime )
		return;
	fForceAlertTime = Level.TimeSeconds + FORCE_ALERT_DELAY;

	///MpPawn(AlertPawn).ClientMessage(MyPawn@"Found in coop"@AlertPawn);

	///log(self@"xForceAlertMe called"@Level.TimeSeconds);

	MakeMoreAlert();
	SetToAttackPlayer(FPSPawn(AlertPawn));
}

///steam 04/08/2016
function SetToAttackPlayer(FPSPawn PlayerP)
{
	if( MyPawn != None && !MyPawn.bDeleteMe )
		MyPawn.bPlayerIsEnemy = true;
	Super.SetToAttackPlayer(PlayerP);
}

///steam 04/08/2016
/*function P2Player GetRandomPlayer()
{
	local P2Player ThisPlayer;

	if( Level.Game != None && CoopGameInfo(Level.Game) != None )
		ThisPlayer = CoopGameInfo(Level.Game).xGetValidPlayerFor(self);

	if( ThisPlayer != None )
		return ThisPlayer;

	return Super.GetRandomPlayer();
}*/

defaultproperties
{
}
