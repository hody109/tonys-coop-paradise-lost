//=============================================================================
// CoopConFix_AWZombieController.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopConFix_AWZombieController extends AWZombieController;

///steam 20/11/2016
var float fForceAlertTime;
const FORCE_ALERT_DELAY = 0.1;

///steam 04/08/2016
function bool xPlayerIsRealEnemy(Pawn Other)
{
	return ( Pawn != None && !Pawn.bDeleteMe 
			&& Other != None && !Other.bDeleteMe && (Hero == None || (Hero != None && !Hero.bDeleteMe && Other != Hero) ) 
			/*&& (MyPawn.bPlayerIsEnemy || MyPawn.PawnInitialState == MyPawn.EPawnInitialState.EP_AttackPlayer)*/ );
}

///steam 04/08/2016
function bool xCanKillThisPlayer(Pawn Other)
{
	return ( Other != None && !Other.bDeleteMe && Other.Controller != None && Other.Controller.IsA('PlayerController') && Other.Health > 0 );
}

///steam 04/08/2016
function HearNoise(float Loudness, Actor NoiseMaker)
{
	if( NoiseMaker != None 
		&& !NoiseMaker.bDeleteMe 
		&& xPlayerIsRealEnemy(NoiseMaker.Instigator) 
		&& xCanKillThisPlayer(NoiseMaker.Instigator) )
		xForceAlertMe(NoiseMaker.Instigator);
}

///steam 04/08/2016
event SeePlayer(Pawn SeenPlayer)
{
	if( xPlayerIsRealEnemy(SeenPlayer) 
		&& xCanKillThisPlayer(SeenPlayer) )
		xForceAlertMe(SeenPlayer);
}

///steam 04/08/2016
event xForceAlertMe(Pawn AlertPawn)
{
	if( Attacker != None 
		&& ( Attacker == AlertPawn 
			|| VSize(AlertPawn.Location-Pawn.Location) > VSize(Attacker.Location-Pawn.Location)) )
		return;

	///steam 20/11/2016
	if( Level.TimeSeconds < fForceAlertTime )
		return;
	fForceAlertTime = Level.TimeSeconds + FORCE_ALERT_DELAY;

	///MpPawn(AlertPawn).ClientMessage(MyPawn@"Found in coop"@AlertPawn);

	//MakeMoreAlert();
	SetToAttackPlayer(FPSPawn(AlertPawn));
	AttackThisNow(FPSPawn(AlertPawn), true);
}

///steam 04/08/2016
function SetToAttackPlayer(FPSPawn PlayerP)
{
	/*if( MyPawn != None && !MyPawn.bDeleteMe )
		MyPawn.bPlayerIsEnemy = true;*/
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
