//=============================================================================
// CoopAdmin.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopAdmin extends Admin;

static final operator(24) bool isin(string a, string b)
{
	return (InStr(caps(b), caps(a)) != -1);
}

function Pawn FindSpecifiedPawnByName(string S)
{
	local Pawn P;
	local Pawn aFoundPawn;

	foreach DynamicActors(class'Pawn', P)
	{
		if( S ~= P.PlayerReplicationInfo.PlayerName )
		{
			aFoundPawn = P;
			break;
		}
		else if( aFoundPawn == None && S isin P.PlayerReplicationInfo.PlayerName )
		{
			aFoundPawn = P;
		}
	}

	if( aFoundPawn == None )
		Outer.ClientMessage(S @ "is not valid player name or this player is not currently alive.");

	return aFoundPawn;
}

function Controller FindSpecifiedControllerByName(string S)
{
	local Controller P;
	local Controller aFoundCon;

	for ( P = Level.ControllerList; P!=None; P=P.nextController )
	{
		if( P.bIsPlayer )
		{
			if( S ~= P.PlayerReplicationInfo.PlayerName )
			{
				aFoundCon = P;
				break;
			}
			else if( aFoundCon == None && S isin P.PlayerReplicationInfo.PlayerName )
			{
				aFoundCon = P;
			}
		}
	}

	if( aFoundCon == None )
		Outer.ClientMessage(S @ "is not valid player name.");

	return aFoundCon;
}

function string GetExtraOption(out string UseString)
{
	local int i;
	local string sTemp;

	sTemp = UseString;
	i = InStr(sTemp, "_+_");
	if( i != -1 )
	{
		UseString = Mid(sTemp, i+3, Len(UseString));
		sTemp = Left(sTemp, i);
	}
	else UseString = "";

	return sTemp;
}

function xSendServerGlobalMessage(string sMessage)
{
	CoopGameInfo(Level.Game).xCoopServerEventMessage("CoopGame:"@sMessage);
}

/*exec function ReName(string S)
{
	local Controller P;
	local string NewName;

	NewName = S;
	S = GetExtraOption(NewName);

	if( NewName == "" )
		Outer.ClientMessage("You can set new name, EXAMPLE: ReName Player_+_Jack");

	P = FindSpecifiedControllerByName(S);
	if( P != None )
	{
		if( NewName == "" )
		{
			NewName = RenameRandomNames[Rand(RenameRandomNames.Length-1)];
			if( NewName == "" )
				NewName = "BULKA";
		}

		Outer.ClientMessage(P.PlayerReplicationInfo.PlayerName$"'s name was changed to"@NewName);
		Level.Game.ChangeName(P, NewName, false);
		if( PlayerController(P) != None )
			PlayerController(P).ClientMessage("Your name has been changed to"@NewName);
	}
}*/

exec function MuteForever(string S)
{
	local Pawn P;

	P = FindSpecifiedPawnByName(S);
	if( P != None )
	{
		if( CoopPlayerController(P.Controller) != None )
		{
			CoopPlayerController(P.Controller).ClientMessage("You've been muted by the administrator!");
			CoopPlayerController(P.Controller).bMuteSayMessages = true;
			xSendServerGlobalMessage(P.PlayerReplicationInfo.PlayerName @ "was muted by the administrator!");
		}
	}
}

exec function MuteFor(string S)
{
	local Pawn P;
	local string sForTime;

	sForTime = S;
	S = GetExtraOption(sForTime);

	if( sForTime == "" )
	{
		Outer.ClientMessage("Enter time in seconds, EXAMPLE: MuteFor Player_+_60");
		return;
	}

	P = FindSpecifiedPawnByName(S);
	if( P != None )
	{
		if( CoopPlayerController(P.Controller) != None )
		{
			CoopPlayerController(P.Controller).ClientMessage("You've been muted by the administrator!");
			CoopPlayerController(P.Controller).MuteSayMessagesTime = Level.TimeSeconds + int(sForTime);
			xSendServerGlobalMessage(P.PlayerReplicationInfo.PlayerName @ "was muted by the administrator!");
		}
	}
}

exec function MuteMin(string S)
{
	local Pawn P;

	P = FindSpecifiedPawnByName(S);
	if( P != None )
	{
		if( CoopPlayerController(P.Controller) != None )
		{
			CoopPlayerController(P.Controller).ClientMessage("You've been muted by the administrator!");
			CoopPlayerController(P.Controller).MuteSayMessagesTime = Level.TimeSeconds + 60;
			xSendServerGlobalMessage(P.PlayerReplicationInfo.PlayerName @ "was muted by the administrator!");
		}
	}
}

exec function Zero(string S)
{
	local Pawn P;

	P = FindSpecifiedPawnByName(S);
	if( P != None )
	{
		if( PlayerController(P.Controller) != None )
			PlayerController(P.Controller).ClientMessage("Your score was reseted by the administrator.");
		P.PlayerReplicationInfo.Score = 0;
		xSendServerGlobalMessage(P.PlayerReplicationInfo.PlayerName $ "'s score was reseted by the administrator!");
	}
}

exec function ConCom(string S)
{
	Outer.ClientMessage(Outer.ConsoleCommand(S));
}

exec function MarkAsBot(string S)
{
	local Controller P;
	local string sOption;

	sOption = S;
	S = GetExtraOption(sOption);

	if( sOption == "" )
	{
		Outer.ClientMessage("Enter option, EXAMPLE: MarkAsBot Player_+_TRUE");
		return;
	}

	P = FindSpecifiedControllerByName(S);
	if( P != None )
	{
		P.PlayerReplicationInfo.bBot = bool(sOption);
		Outer.ClientMessage(P.PlayerReplicationInfo.PlayerName @ "marked as bot:"@sOption);
	}
}

exec function Ban2( string S )
{
	local Controller P;

	P = FindSpecifiedControllerByName(S);

	if( P != None )
		Level.Game.KickBan(P.PlayerReplicationInfo.PlayerName);
}

exec function Kick2( string S )
{
	local Controller P;

	P = FindSpecifiedControllerByName(S);

	if( P != None )
		Level.Game.Kick(P.PlayerReplicationInfo.PlayerName);
}

exec function Kill(string S)
{
	local Pawn P;

	P = FindSpecifiedPawnByName(S);
	if( P != None )
	{
		P.TakeDamage(P.Health*2, None, P.Location, vect(0,0,0), class'Crushed');
		if( CoopPlayerController(P.Controller) != None )
		{
			CoopPlayerController(P.Controller).ClientMessage("You've been killed by the administrator!");
			xSendServerGlobalMessage(P.PlayerReplicationInfo.PlayerName @ "was killed by the administrator!");
		}
	}
}

exec function comGoto(String LevelName)
{
	CoopGameInfo(Level.Game).comGoto(LevelName);
}

///CHEATS

function CallCheat()
{
	CoopGameInfo(Level.Game).TheGameState.PlayerCheated("Using cheats");
}

exec function comEnhanced(bool bState)
{
	CoopGameInfo(Level.Game).TheGameState.bEGameStart = bState;
	if( bState )
		Outer.ClientMessage("Enhanced mode turned on");
	else Outer.ClientMessage("Enhanced mode turned off");
	Outer.ClientMessage("Effect will appear after level switch");
	CallCheat();
}

function PackNHeatFor(Pawn aPawn)
{
	local Inventory thisinv;
	if( aPawn != None 
		&& CoopPlayerController(aPawn.Controller) != None 
		&& !CoopPlayerController(aPawn.Controller).IsCoopDedicatedHost() )
	{
		P2Pawn(aPawn).CreateInventory("AWInventory.MacheteWeapon");
		P2Pawn(aPawn).CreateInventory("AWInventory.SledgeWeapon");
		P2Pawn(aPawn).CreateInventory("AWInventory.ScytheWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.BatonWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.ShovelWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.ShockerWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.PistolWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.ShotgunWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.MachinegunWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.GasCanWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.CowHeadWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.GrenadeWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.ScissorsWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.MolotovWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.RifleWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.LauncherWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.NapalmWeapon");
		P2Pawn(aPawn).CreateInventory("AWPStuff.BaseballBatWeapon");
		P2Pawn(aPawn).CreateInventory("AWPStuff.ChainSawWeapon");
		P2Pawn(aPawn).CreateInventory("AWPStuff.DustersWeapon");
		P2Pawn(aPawn).CreateInventory("AWPStuff.FlameWeapon");
		P2Pawn(aPawn).CreateInventory("AWPStuff.SawnOffWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.ShearsWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.AxeWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.BaliWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.DynamiteWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.GSelectWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.GrenadeLauncherWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.MP5Weapon");

		P2Pawn(aPawn).CreateInventory("Inventory.PlagueWeapon");
		//P2Pawn(aPawn).CreateInventory("Inventory.BoxLauncherWeapon");
		P2Pawn(aPawn).CreateInventory("EDStuff.BetaShotgunWeapon");
		P2Pawn(aPawn).CreateInventory("Inventory.MrDKNadeWeapon");
		P2Pawn(aPawn).CreateInventory("P2R.ProtestSignWeapon");
//		P2Pawn(aPawn).CreateInventory("AWPStuff.NukeWeapon");

		thisinv = P2Pawn(aPawn).Inventory;
		while(thisinv != None)
		{
			if(P2Weapon(thisinv) != None)
			{
				P2Weapon(thisinv).bJustMade=false;
			}
			thisinv = thisinv.inventory;
		}
	}
}

exec function PackNHeat(string S)
{
	local CoopPostalDude aPawn;
	local Pawn P;

	if( S == "" )
	{
		foreach DynamicActors(class'CoopPostalDude', aPawn)
		{
			PackNHeatFor(aPawn);
			aPawn.ClientMessage("Admin: PackNHeat");
		}
		Outer.ClientMessage("All players got weapons");
	}
	else
	{
		P = FindSpecifiedPawnByName(S);
		PackNHeatFor(P);
		Outer.ClientMessage(P.GetHumanReadableName() @ "got weapons");
		MpPawn(P).ClientMessage("Admin: PackNHeat");
	}
	CallCheat();
}

function PayLoadFor(Pawn aPawn)
{
	local Inventory Inv;

	if( aPawn != None 
		&& CoopPlayerController(aPawn.Controller) != None 
		&& !CoopPlayerController(aPawn.Controller).IsCoopDedicatedHost() )
	{
		for( Inv=aPawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
			if (Ammunition(Inv)!=None
				&& ClipboardAmmoInv(Inv) == None)	// Don't load up the clipboard this way
			{
				Ammunition(Inv).AmmoAmount  = 999;
				Ammunition(Inv).MaxAmmo  = 999;
			}
	}
}

exec function PayLoad(string S)
{
	local CoopPostalDude aPawn;
	local Pawn P;

	if( S == "" )
	{
		foreach DynamicActors(class'CoopPostalDude', aPawn)
		{
			PayLoadFor(aPawn);
			aPawn.ClientMessage("Admin: PayLoad");
		}
		Outer.ClientMessage("All players got ammo");
	}
	else
	{
		P = FindSpecifiedPawnByName(S);
		PayLoadFor(P);
		Outer.ClientMessage(P.GetHumanReadableName() @ "got ammo");
		MpPawn(P).ClientMessage("Admin: PayLoad");
	}
	CallCheat();
}

exec function Osama()
{
	Outer.ClientMessage("Fanaticizing your bystanders--please wait.");
	DudePlayer(Outer).ConvertNonImportants(class'Fanatics',,,true,,true);
	DudePlayer(Outer).ConvertNonImportants(class'Kumquat',,,true,true);
	DudePlayer(Outer).MyPawn.PlaySound(class'P2CheatManager'.default.FanaticsTalking);
	CallCheat();
}

exec function Nudes()
{
	Outer.ClientMessage("Adding nude girls.");
	DudePlayer(Outer).ConvertNonImportants(class'CoopExtra_FemaleNude',,,true,true);
	CallCheat();
}

exec function KrotchatizeMe()
{
	Outer.ClientMessage("Krotchatizing your bystanders--please wait.");
	DudePlayer(Outer).ConvertNonImportants(class'Krotchy');
	DudePlayer(Outer).MyPawn.PlaySound(class'P2CheatManager'.default.KrotchyTalking);
	CallCheat();
}

exec function JewTown()
{
	Outer.ClientMessage("Entering Jewtown--please wait.");
	DudePlayer(Outer).JewTown();
	DudePlayer(Outer).MyPawn.PlaySound(class'P2CheatManager'.default.MikeJTalking);
	CallCheat();
}

exec function Zombification()
{
	local class<P2Pawn> PawnClass;
	Outer.ClientMessage("Zombifying your bystanders--please wait.");
	PawnClass = class<P2Pawn>(DynamicLoadObject("AWPawns.AWZombieTom", class'Class'));
	DudePlayer(Outer).ConvertNonImportants(PawnClass);
	DudePlayer(Outer).MyPawn.PlaySound(class'P2CheatManager'.default.ZombieTalking);
	CallCheat();
}

exec function SkeletonWar()
{
	local class<P2Pawn> PawnClass1, PawnClass2;
	Outer.ClientMessage("Skeletonizing your bystanders--please wait.");
	PawnClass1 = class<P2Pawn>(DynamicLoadObject("Postal2Holidays.SkeletonSword", class'Class'));
	PawnClass2 = class<P2Pawn>(DynamicLoadObject("Postal2Holidays.SkeletonMace", class'Class'));
	DudePlayer(Outer).ConvertNonImportants(PawnClass1,, true, true, true, false);
	DudePlayer(Outer).ConvertNonImportants(PawnClass2,, true, true, false, true);
	DudePlayer(Outer).MyPawn.PlaySound(class'P2CheatManager'.default.ZombieTalking);
	CallCheat();
}

exec function SkeletonJihad()
{
	local class<P2Pawn> PawnClass1, PawnClass2;
	Outer.ClientMessage("Skeletonizing your bystanders--please wait.");
	PawnClass1 = class<P2Pawn>(DynamicLoadObject("Postal2Holidays.SkeletonKamikaze", class'Class'));
	PawnClass2 = class<P2Pawn>(DynamicLoadObject("Postal2Holidays.SkeletonSwordShield", class'Class'));
	DudePlayer(Outer).ConvertNonImportants(PawnClass1,, true, true, true, false);
	DudePlayer(Outer).ConvertNonImportants(PawnClass2,, true, true, false, true);
	DudePlayer(Outer).MyPawn.PlaySound(class'P2CheatManager'.default.ZombieTalking);
	CallCheat();
}

exec function RiotMode()
{
	local FPSPawn checkpawn;

	if( CoopGameInfo(Level.Game) == None )
		return;

	Outer.ClientMessage("Converting bystanders into riot mode.");
	CallCheat();
	foreach DynamicActors(class'FPSPawn', checkpawn)
	{
		if(!checkpawn.bPlayer
			&& !checkpawn.bSliderStasis
			&& BystanderController(checkpawn.Controller) != None
			&& CashierController(checkpawn.Controller) == None
			&& RWSController(checkpawn.Controller) == None)
			CoopGameInfo(Level.Game).ConvertToRiotModeFor(PersonController(checkpawn.Controller));
	}
}

exec function RocketGuys()
{
	local FPSPawn checkpawn;

	if( CoopGameInfo(Level.Game) == None )
		return;

	Outer.ClientMessage("Giving bystanders rocket launchers.");
	CallCheat();
	foreach DynamicActors(class'FPSPawn', checkpawn)
	{
		if(!checkpawn.bPlayer
			&& !checkpawn.bSliderStasis
			&& BystanderController(checkpawn.Controller) != None
			&& CashierController(checkpawn.Controller) == None
			&& RWSController(checkpawn.Controller) == None)
			CoopGameInfo(Level.Game).ConvertToRiotModeFor(PersonController(checkpawn.Controller), "Inventory.LauncherWeapon");
	}
}

exec function GimmeGuysGuns(string GunClass)
{
	local FPSPawn checkpawn;

	if( CoopGameInfo(Level.Game) == None )
		return;

	if( DynamicLoadObject(GunClass, class'class') == None )
	{
		Outer.ClientMessage("Incorrect gun class, EXAMPLE: GimmeGuysGuns Inventory.PistolWeapon");
		return;
	}

	Outer.ClientMessage("Giving bystanders" @ GunClass);
	CallCheat();
	foreach DynamicActors(class'FPSPawn', checkpawn)
	{
		if(!checkpawn.bPlayer
			&& !checkpawn.bSliderStasis
			&& BystanderController(checkpawn.Controller) != None
			&& CashierController(checkpawn.Controller) == None
			&& RWSController(checkpawn.Controller) == None)
			CoopGameInfo(Level.Game).ConvertToRiotModeFor(PersonController(checkpawn.Controller), GunClass);
	}
}

exec function IWant(string S)
{
	local CoopPostalDude aPawn;
	local Pawn P;
	local string ItemClass;
	local Inventory aInv;

	ItemClass = S;
	S = GetExtraOption(ItemClass);

	if( DynamicLoadObject(ItemClass, class'class') == None )
	{
		Outer.ClientMessage("Incorrect item class, EXAMPLE: IWant Player_+_Inventory.PistolWeapon");
		return;
	}

	if( S == "" )
	{
		foreach DynamicActors(class'CoopPostalDude', aPawn)
		{
			aInv = aPawn.CreateInventory(ItemClass);
			if( aInv != None )
			{
				if( P2PowerUpInv(aInv) != None )
					P2PowerUpInv(aInv).Amount += 1;
				else if( P2Weapon(aInv) != None && P2Weapon(aInv).AmmoType != None )
					P2Weapon(aInv).AmmoType.AmmoAmount += P2Weapon(aInv).AmmoType.MaxAmmo;
			}
			aPawn.ClientMessage("Admin: IWant" @ ItemClass);
		}
		Outer.ClientMessage("All players got" @ ItemClass);
	}
	else
	{
		P = FindSpecifiedPawnByName(S);
		P2Pawn(P).CreateInventory(ItemClass);
		Outer.ClientMessage(P.GetHumanReadableName() @ "got" @ ItemClass);
		MpPawn(P).ClientMessage("Admin: IWant" @ ItemClass);
	}
	CallCheat();
}
exec function GrantItem(string S)
{
	IWant(S);
}
exec function Gimme(string S)
{
	IWant(S);
}

exec function GimmeNuke(string S)
{
	IWant(S $ "_+_AWPStuff.NukeWeapon");
}
exec function GimmeBroom(string S)
{
	IWant(S $ "_+_NicksCoop.CoopExtra_WitchBroomWeapon");
}
exec function GimmeCrack(string S)
{
	IWant(S $ "_+_Inventory.CrackInv");
}

function AddControllerForNewPawn(FPSPawn NewPawn)
{
	if( !NewPawn.bDeleteMe 
		&& NewPawn.Controller == None 
		&& NewPawn.Health > 0 )
	{
		if( NewPawn.ControllerClass != None )
			NewPawn.Controller = spawn(NewPawn.ControllerClass);
		if( NewPawn.Controller != None )
			NewPawn.Controller.Possess(NewPawn);
		NewPawn.CheckForAIScript();
	}
}
exec function Summon(string ClassName)
{
	local class<actor> NewClass;
	local vector SpawnLoc;
	local Actor SpawnedActor;
	local vector OuterLoc;
	local rotator OuterRot;

	if( Outer.Pawn != None )
		OuterLoc = Outer.Pawn.Location;
	else OuterLoc = Outer.Location;
	OuterRot = Outer.Rotation;

	NewClass = class<actor>(DynamicLoadObject(ClassName, class'Class'));
	if( NewClass != None )
	{
		SpawnLoc = OuterLoc;
		SpawnedActor = Spawn(NewClass,,,SpawnLoc + 72 * Vector(OuterRot) + vect(0,0,1) * 15);
		if( SpawnedActor != None
			&& FPSPawn(SpawnedActor) != None )
			AddControllerForNewPawn(FPSPawn(SpawnedActor));
		Outer.ClientMessage("Admin: Summon" @ SpawnedActor);
	}
	else Outer.ClientMessage("Wrong class, EXAMPLE: Summon Postal2Holidays.GaryGhost");
	CallCheat();
}

exec function SummonBystanders()
{
	Summon("BasePeople.Bystanders");
}

exec function SummonGaryGhost()
{
	Summon("Postal2Holidays.GaryGhost");
}

exec function SummonGaryCowheadRun()
{
	Summon("AWPawns.AWCowheadGaryRunPawn");
}

exec function CustomBystanders(string ClassName)
{
	local class<P2Pawn> PawnClass;
	PawnClass = class<P2Pawn>(DynamicLoadObject(ClassName, class'Class'));
	if( PawnClass == None )
	{
		Outer.ClientMessage("Wrong class, EXAMPLE: CustomBystanders Postal2Holidays.GaryGhost");
		return;
	}
	Outer.ClientMessage("Turning bystanders into" @ PawnClass);
	DudePlayer(Outer).ConvertNonImportants(PawnClass,, true, true, true, false);
	DudePlayer(Outer).ConvertNonImportants(PawnClass,, true, true, false, true);
	CallCheat();
}

exec function GaryGhostTown()
{
	CustomBystanders("Postal2Holidays.GaryGhost");
}

exec function GaryCowheadRunTown()
{
	CustomBystanders("AWPawns.AWCowheadGaryRunPawn");
}

exec function comEndGame()
{
	if( CoopGameInfo(Level.Game) == None 
		|| CoopGameInfo(Level.Game).NETPlayerHost == None 
		|| CoopGameInfo(Level.Game).IsCinematic() )
		return;
	CoopGameInfo(Level.Game).EndOfGame(P2Player(CoopGameInfo(Level.Game).NETPlayerHost));
}

exec function comNextDay()
{
	local int DaysLength;

	if( CoopGameInfo(Level.Game) == None 
		|| CoopGameInfo(Level.Game).NETPlayerHost == None 
		|| CoopGameInfo(Level.Game).IsCinematic() )
		return;

	if( CoopGameInfo(Level.Game).CoopStoryModeType == 0 )
		DaysLength = CoopGameInfo(Level.Game).Days.Length-2;
	else DaysLength = CoopGameInfo(Level.Game).Days.Length;

	if( CoopGameInfo(Level.Game).TheGameState.CurrentDay + 1 < DaysLength )
		CoopGameInfo(Level.Game).SendPlayerToNextDay(P2Player(CoopGameInfo(Level.Game).NETPlayerHost));
	else Outer.ClientMessage("No available days anymore, to finish game use comEndGame");
}

exec function Revive(string S)
{
	local CoopPlayerController P;

	P = CoopPlayerController(FindSpecifiedControllerByName(S));
	if( P != None && P.Pawn != None && P.Pawn.Health <= 0 )
	{
		P.xForceHealThePawn(1);
		P.ClientMessage("You've been revived by the administrator!");
		xSendServerGlobalMessage(P.PlayerReplicationInfo.PlayerName @ "was revived by the administrator!");
	}
}

defaultproperties
{
}
