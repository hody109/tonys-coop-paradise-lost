//=============================================================================
// CoopConFix_PoliceController.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopConFix_PoliceController extends PoliceController;

var bool bHateNonArrestable;

function bool xIsReadyForArrest(Pawn aPawn)
{
	local CoopPlayerController aPC;
	if( aPawn != None )
		aPC = CoopPlayerController(aPawn.Controller);
	if( aPC != None )
		return aPC.xIsReadyForArrestFinal();
	return false;
}

function CoopPlayerArrestAlert(MpPawn aSuspect)
{
	if( aSuspect != None 
		&& !aSuspect.bDeleteMe 
		&& aSuspect.Health > 0 
		&& aSuspect.IsHumanControlled() 
		&& CoopGameInfo(Level.Game) != None )
	{
		if( xIsReadyForArrest(aSuspect) )
			CoopGameInfo(Level.Game).CoopPlayerArrestAlert(aSuspect);
		else bHateNonArrestable = true;
	}
}

state GetOutCuffs
{
	function BeginState()
	{
		bHateNonArrestable = false;
		if( MpPawn(Attacker) != None )
			CoopPlayerArrestAlert(MpPawn(Attacker));
		else if( MpPawn(InterestPawn) != None )
			CoopPlayerArrestAlert(MpPawn(InterestPawn));
		Super.BeginState();
	}
}

state CuffHim
{
Begin:
	//CoopPlayerController(Attacker.Controller).ClientMessage("wait for coop...");
	if( Attacker != None && xIsReadyForArrest(Attacker) )
		Sleep(2.0);
	if( CheckForFinalCuff() )
	{
		if( Attacker != None 
			&& !xIsReadyForArrest(Attacker) )
		{
			GotoStateSave('TellHimToFreeze');
		}
		else
		{
		// Actual code that begins the sending.
		if(P2Player(Attacker.Controller) != None)
		{
			// Unhook from interestpawn
			P2Player(Attacker.Controller).InterestPawn = None;
			
			SendingPlayerToJail(P2Player(Attacker.Controller));
			Sleep(1.0);
		}
		GotoStateSave('LookAroundForTrouble');
		}
	}
	else	// can't cuff him, so attack him
	{
		GoKilling();
	}
}

state TellHimToFreeze
{
	function DecideNextStateBasedOnAttacker(optional bool bStart)
	{
		local byte StateChange;

		if( Attacker != None 
			&& !xIsReadyForArrest(Attacker) 
			&& bHateNonArrestable )
		{
			// Check to walk closer first
			NeedToWalkCloser(FREEZE_BASE_DIST, StateChange);
			if(StateChange == 1)
				return;
			SwitchToBestWeapon();
			GotoState('ShootAtAttacker', 'FireNowPrep');
			return;
		}
		Super.DecideNextStateBasedOnAttacker();
	}
}

// UPD 20/04/2018 - separate wanted
function AuthorityActOnPawnLooks(FPSPawn LookAtMe, optional out byte StateChange)
{
	local P2Weapon p2weap;
	local vector dir, pawndiff, rot, crosscheck;
	local float dist;
	local bool bcheck, bRunAway;
	local P2GameInfoSingle checkg;
	local bool bIsGimp, bIsCop;

	// If this guy doesn't care about things going on around him
	if(MyPawn.bIgnoresSenses)
		return;

	// Handle zombies
	if(LookAtMe.IsA('AWZombie'))
	{
		if(MyPawn.bHasViolentWeapon)
		{
			// Drop things if you had them in your hands
			MyPawn.DropBoltons(MyPawn.Velocity);
			SetAttacker(LookAtMe);
			MakeMoreAlert();
			SaveAttackerData(LookAtMe);
			PrintDialogue("Animals must die!");
			Say(MyPawn.myDialog.lStartAttackingAnimal);
			GotoStateSave('ShootAtAttacker', 'WaitTillFacing');
			StateChange=1;
		}
		else
		{
			GenSafeRangeMin();
			InterestPawn = LookAtMe;
			SetAttacker(InterestPawn);
			DangerPos = Attacker.Location;
			GotoStateSave('FleeFromAttacker');
			StateChange=1;
		}
	}

	// If he's on fire, just watch him, if we're not already fighting
	if(Attacker == None
		&& LookAtMe.MyBodyFire != None)
	{
		GenSafeRangeMin();
		DangerPos = LookAtMe.Location;
		MakeMoreAlert();
		InterestPawn = LookAtMe;
		GotoStateSave('WatchGuyOnFire');
		StateChange = 1;
		return;
	}

	// If it's a crazy animal, run or fight it
	// Animals very rarely send out look requests--usually only when they're deadly
	if(AnimalPawn(LookAtMe) != None)
	{
		if(AnimalPawn(LookAtMe).bDangerous)
		{
			if(MyPawn.bHasViolentWeapon)
			{
				// Drop things if you had them in your hands
				MyPawn.DropBoltons(MyPawn.Velocity);
				SetAttacker(LookAtMe);
				MakeMoreAlert();
				SaveAttackerData(LookAtMe);
				GotoStateSave('RecognizeAttacker');
			}
			else
			{
				GenSafeRangeMin();
				InterestPawn = LookAtMe;
				SetAttacker(InterestPawn);
				DangerPos = Attacker.Location;
				GotoStateSave('FleeFromAttacker');
			}
			StateChange=1;
		}
		return;
	}

	// We don't care about other cops
	if(FriendWithMe(LookAtMe))
		return;

	// Check first (before we see the weapon) if he is possibly in your house
	// and not supposed to be, and you care about it
	CheckForIntruder(LookAtMe, StateChange);
	if(StateChange == 1)
		return;

	// Handle the dude-cop seperately. We don't care what he's looking
	// like, except if he's got his pants down
	if(DudeDressedAsCop(LookAtMe))
	{
		return;
	}
	// If the dude
	if(LookAtMe.bPlayer)
	{
		// And you're friends with him, don't care what he looks like
		if(MyPawn.bPlayerIsFriend)
			return;

		// Otherwise, if we've spotted the dude, and he's still wanted, then
		// arrest him
		checkg = P2GameInfoSingle(Level.Game);
		if((MyPawn.bHasRadio 
			&& CopsWantThisPlayer(LookAtMe)) // UPD 20/04/2018 - separate wanted
			//&& checkg.TheGameState.CopsWantPlayer() > 0)
			|| checkg.TheGameState.bArrestPlayerInJail)
		{
			StartWithSuspect(LookAtMe);
			StateChange=1;
			return;
		}
	}

	// Check to see if we care what he's doing or what he looks like
	p2weap = P2Weapon(LookAtMe.Weapon);

	// Check to make sure the weapon is in our view (and he's
	// not walking backwards to us, with it or something)
	// Also, the weapon we see is anything we're interested in.
	if(p2weap != None
		&& WeaponTurnedToUs(LookAtMe, MyPawn))
	{
		dir = LookAtMe.Location - MyPawn.Location;
		dist = VSize(dir);

		// We're close enough to see what the weapon is, that he has
		if(dist < p2weap.RecognitionDist)
		{
			// If he's got a cowhead, stare at him
			if(P2Weapon(LookAtMe.Weapon) != None
						&& P2Weapon(LookAtMe.Weapon).bWeaponIsGross)
			{
				if(MyPawn.bHasViolentWeapon)
				{
					InterestPawn = LookAtMe;
					GotoStateSave('WatchGuyWithCowhead');
					StateChange=1;
					return;
				}
			}
			// If we even see a gas can, we're concerned
			else if(GasCanWeapon(LookAtMe.Weapon) != None)
			{
				if(MyPawn.bHasViolentWeapon)
				{
					InterestPawn = LookAtMe;
					GotoStateSave('WatchGuyWithGasCan');
					StateChange=1;
					return;
				}
			}
			// You're pants are down, so arrest you for it--unless you're doing this
			// in jail, in which case we don't care.
			else if(LookAtMe.HasPantsDown())
			{
				checkg = P2GameInfoSingle(Level.Game);
				if(MyPawn.bHasViolentWeapon
					&& (!checkg.TheGameState.bPlayerInCell
						|| checkg.TheGameState.bArrestPlayerInJail))
				{
					InterestPawn = LookAtMe;
					GotoStateSave('HandleGuyWithPantsDown');
					StateChange=1;
					return;
				}
			}
			else if(ConcernedAboutWeapon(p2weap))
			{
				if(p2weap.ViolenceRank >= p2weap.LEGAL_VIOLENCE_RANK
					&& !ZombiePerimeterCheck(LookAtMe.Location)) // He might be fighting a zombie/skeleton. If so don't arrest him, just watch, we can arrest him later if there are no zombies/skeletons
				// Handle pistol, shotgun, machinegun, rifle, grenade as soon
				// as you see them, with arrest mode/or attack him
				{
					if(!MyPawn.bHasViolentWeapon)
						bRunAway=true;
					else 						
					{
						SetAttacker(LookAtMe);
						InterestPawn = LookAtMe;
						GotoStateSave('HandleGuyWithBigGun');
						StateChange=1;
						return;
					}
				}
				else
				// Handle Shocker, scissors, cowhead, molotov, shovel, baton
				// by watching him carefully, as soon as you recognize these things
				// and either arrest him or attack him when he's too close.
				{
					InterestPawn = LookAtMe;
					GotoStateSave('HandleGuyWithSmallGun');
					StateChange=1;
					return;
				}
			}

			if(bRunAway)
			{
				// We're scared of cops shooting, but we won't really avoid them
				// like an attacker, we just run from where they shot
				// Run away like a little girl if you don't have a weapon
				// Check to see if we should flee or if we're an okay distance away
				// Find direction away from danger
				SetAttacker(LookAtMe);
				DangerPos = LookAtMe.Location;
				dir = (MyPawn.Location - DangerPos);
				dir.z=0;
				// Dist between attacker and me
				CurrentDist = VSize(dir);
				// Decide current safe min
				UseSafeRangeMin = MyPawn.SafeRangeMin + (MyPawn.Cowardice)*MyPawn.SafeRangeMin;
				//log("Check react to "$KnownDanger);

				GotoStateSave('FleeFromAttacker');
				StateChange=1;
				return;
			}
		}
		else if(dist < 2*p2weap.RecognitionDist
			&& ConcernedAboutWeapon(p2weap))
		// If he's got ANYTHING even vaguely dangerous, consider watching him for it if it's
		// close enough to see he has something, but not quite make out what it is
		{
			TryToSeeWeapon(LookAtMe);
			StateChange=1;
			return;
		}
	}

	bIsGimp = PersonDressedAsGimp(LookAtMe);

	if(MyPawn.Talkative > FRand()
		|| bIsGimp)
	// Consider talking to them
	{
		// If they don't have their pants down and have no weapon,
		// then check to talk to them
		if(p2weap == None
			|| (!ConcernedAboutWeapon(p2weap)
			&& !LookAtMe.HasPantsDown()))
		{
			TryToGreetPasserby(LookAtMe, bIsGimp, false, StateChange);
			if(StateChange == 1)
				return;
		}
	}

	// Since we're not doing anything else, if it's the player, then check to see what he's doing
	if(LookAtMe.bPlayer)
		HandlePlayerSightReaction(LookAtMe);

	return;
}

function DangerPawnBump( Actor Other, optional out byte StateChange )
{
	local P2Pawn ppawn;
	
	ppawn = P2Pawn(Other);

	// Only check players, unless he's dressed as a cop
	if(ppawn != None
		&& ppawn.bPlayer
		&& !DudeDressedAsCop(FPSPawn(Other)))
	{
		// Arrest him if wanted
		if(MyPawn.bHasRadio 
			&& CopsWantThisPlayer(FPSPawn(Other))) // UPD 20/04/2018 - separate wanted
			//&& P2GameInfoSingle(Level.Game).TheGameState.CopsWantPlayer() > 0
		{
			SetAttacker(ppawn);
			SaveAttackerData();
			DangerPos = Other.Location;
			if(IsInState('LegMotionToTarget'))
				bPreserveMotionValues=true;
			SetNextState('AssessAttacker');
			GotoStateSave('ConfusedByDanger');
			StateChange=1;
		}
		// Arrest him breaking out of jail
		else if(P2GameInfoSingle(Level.Game).TheGameState.bArrestPlayerInJail)
		{
			CheckDisturbanceInJail(Other);
			StateChange=1;
		}
	}

	if(StateChange != 1)
		Super(PersonController).DangerPawnBump(Other, StateChange);
}

function ReportAsWanted(FPSPawn Attacker, optional bool bForce)
{
	local P2GameInfoSingle checkg;

	if(Attacker != None
		&& Attacker.bPlayer
		&& MyPawn.bHasRadio)
	{
		if(!bReportedPlayer || bForce)
		{
			checkg = P2GameInfoSingle(Level.Game);
			checkg.TheGameState.IncreaseCopRadioTime();
			bReportedPlayer=true;

			// UPD 20/04/2018 - separate wanted
			if( CoopPostalDude(Attacker) != None )
				UpdateCoopSuspect(CoopPostalDude(Attacker));
		}
	}
}

function bool CopsWantThisPlayer(FPSPawn aPawn)
{
	local bool bCheckSuspect;
	if( P2GameInfoSingle(Level.Game) != None 
		&& P2GameInfoSingle(Level.Game).TheGameState.CopsWantPlayer() > 0 )
	{
		bCheckSuspect = CheckCoopSuspect(CoopPostalDude(aPawn));
		return bCheckSuspect;
	}
	return false;
}

function bool CheckCoopSuspect(CoopPostalDude aPawn)
{
	if( aPawn == None 
		|| aPawn.bDeleteMe 
		|| aPawn.Health <= 0 )
		return false;
	return aPawn.CoopWantedTimer_GetStatus();
}

function UpdateCoopSuspect(CoopPostalDude aPawn, optional bool bInit)
{
	if( aPawn == None 
		|| aPawn.bDeleteMe 
		|| aPawn.Health <= 0 )
		return;
	aPawn.CoopWantedTimer_Update(bInit);
}

function FindCoopSuspects()
{
	local Controller aCon;
	for( aCon = Level.ControllerList ; aCon != None ; aCon = aCon.nextController )
	{
		if( aCon.Pawn != None 
			&& !aCon.Pawn.bDeleteMe
			&& CoopPlayerController(aCon) != None 
			&& !CoopPlayerController(aCon).IsCoopDedicatedHost() 
			&& aCon.Pawn.Health > 0 )
		{
			UpdateCoopSuspect(CoopPostalDude(aCon.Pawn));
		}
	}
}

function SetToAttackPlayer(FPSPawn PlayerP)
{
	Super.SetToAttackPlayer(PlayerP);
	if( !MyPawn.bNoTriggerAttackPlayer )
		FindCoopSuspects();
}

function SetAttacker(Pawn NewA, optional bool bDontUpdateLocation)
{
	Super.SetAttacker(NewA, bDontUpdateLocation);
	// UPD 20/04/2018 - separate wanted
	if( CoopPostalDude(Attacker) != None )
		UpdateCoopSuspect(CoopPostalDude(Attacker), true);
}

defaultproperties
{
}
