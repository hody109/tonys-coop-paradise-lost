//=============================================================================
// CoopChameleonPlus.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015-2016.
//=============================================================================

class CoopChameleonPlus extends ChameleonPlus;

struct CoopReplaceConStruct
{
	var() class<AIController> OldClass;
	var() class<AIController> NewClass;
};
var array<CoopReplaceConStruct> CoopReplaceControllers;

///steam 14/03/2017
struct CoopReplaceHeadsStruct
{
	var() class<BodyPart> OldClass;
	var() class<BodyPart> NewClass;
};
var array<CoopReplaceHeadsStruct> CoopReplaceHeads;

///steam 04/08/2016
function class<AIController> ReplaceCoopBotController(class<AIController> useControllerClass)
{
	local int i;
	if( useControllerClass != None )
	{
		for( i = 0 ; i < CoopReplaceControllers.Length ; i++ )
		{
			if( CoopReplaceControllers[i].OldClass != None 
				&& CoopReplaceControllers[i].NewClass != None 
				&& useControllerClass == CoopReplaceControllers[i].OldClass )
			{
				useControllerClass = CoopReplaceControllers[i].NewClass;
				break;
			}
		}
	}
	return useControllerClass;
}

///steam 14/03/2017
function class<BodyPart> ReplaceCoopHeads(class<BodyPart> useHeadClass)
{
	local int i;
	if( useHeadClass != None )
	{
		for( i = 0 ; i < CoopReplaceHeads.Length ; i++ )
		{
			if( CoopReplaceHeads[i].OldClass != None 
				&& CoopReplaceHeads[i].NewClass != None 
				&& useHeadClass == CoopReplaceHeads[i].OldClass )
			{
				useHeadClass = CoopReplaceHeads[i].NewClass;
				break;
			}
		}
	}
	return useHeadClass;
}

///steam 14/03/2017
function CoopSetupBoltonsFor(P2MocapPawn P)
{
	/*local int i;
	if( !P.IsA('BandMembers') 
		&& !P.IsA('Military') 
		&& !P.IsA('AWMilitary') )
	{
		///steam 18/07/2016 to prevent spawning boltons
		for( i = 0 ; i < ArrayCount(P.boltons) ; i++ )
		{
			P.boltons[i].bInActive = true;
		}
	}*/

	///steam 10/04/2017 - to remove annoying laggy emitter
	P.HoldingCigarette = -1;
}

///steam 14/03/2017 - replaced from ExtraSetup() to this function
simulated function CoopExtraSetup(P2MocapPawn P)
{
	///P.bNoChamelBoltons = true;

	///steam 14/03/2017
	P.HeadClass = ReplaceCoopHeads(P.HeadClass);

	P.ControllerClass = ReplaceCoopBotController(P.ControllerClass);

	///steam 04/08/2016 try force it here too, host cycle have it
	P.bAllowStasis = false;

	if( CoopGameInfo(Level.Game) != None && CoopGameInfo(Level.Game).CoopBaseMutator != None )
		CoopGameInfo(Level.Game).CoopBaseMutator.ReplaceBaseEquipment(P);
}

simulated function ExtraSetup(P2MocapPawn P)
{
	CoopExtraSetup(P);
	Super.ExtraSetup(P);
	CoopSetupBoltonsFor(P);
}

///steam 24/08/2017
function bool TryPick(P2MocapPawn P, ChamelHead heads, FPSPawn.EGender ReqGender, FPSPawn.ERace ReqRace, FPSPawn.EBody ReqBody, bool bDoValidation)
{
	///steam 24/08/2017 - LowerParadise3 1000000 iterations crash fix
	if( P.IsA('AWZombie') )
	{
		P.ChameleonSkins[32] = 'End';
		P.ChamelHeadSkins[32] = 'End';
	}
	return Super.TryPick(P, heads, ReqGender, ReqRace, ReqBody, bDoValidation);
}

defaultproperties
{
	CoopReplaceHeads(0)=(OldClass=class'AWHead',NewClass=class'CoopPawnHead')
	CoopReplaceHeads(1)=(OldClass=class'AWDudeHead',NewClass=class'CoopPawnHeadDude')

	CoopReplaceControllers(0)=(OldClass=class'AWMilitaryController',NewClass=class'CoopConFix_AWMilitaryController')
	CoopReplaceControllers(1)=(OldClass=class'MilitaryController',NewClass=class'CoopConFix_MilitaryController')
	CoopReplaceControllers(2)=(OldClass=class'AWZombieController',NewClass=class'CoopConFix_AWZombieController')
	CoopReplaceControllers(3)=(OldClass=class'PoliceController',NewClass=class'CoopConFix_PoliceController')
}