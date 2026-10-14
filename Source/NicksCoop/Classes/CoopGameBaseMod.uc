//=============================================================================
// CoopGameBaseMod.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopGameBaseMod extends P2GameMod
	config(NicksCoopInvReplace);

struct xInvReplaceStruct
{
	var string OldClass;
	var string NewClass;
};
var array<xInvReplaceStruct> CoopInvReplace;

var globalconfig bool bCustomCoopInvReplace;
var globalconfig array<xInvReplaceStruct> CustomCoopInvReplace;

///steam 12/10/2016
var array<xInvReplaceStruct> AddonCoopInvReplace;

///steam 30/10/2017
var globalconfig array<string> CustomCoopInvStarting;

///steam 26/07/2016 used in CoopPostalDude.uc CreateInventoryByClass() and CoopGameInfo.uc PickupQuery()
function class<Inventory> GetInventoryObjClass(class<Inventory> MakeMe)
{
	local int i;
	local bool bReplaced;
	local class<Inventory> OldInvClass;
	local class<Inventory> NewInvClass;

	bReplaced = false;

	///steam 03/08/2016
	if( bCustomCoopInvReplace )
	{
		for( i = 0 ; i < CustomCoopInvReplace.Length ; i++ )
		{
			OldInvClass = class<Inventory>(DynamicLoadObject(CustomCoopInvReplace[i].OldClass,class'Class'));
			NewInvClass = class<Inventory>(DynamicLoadObject(CustomCoopInvReplace[i].NewClass,class'Class'));
			if( OldInvClass != None 
				&& NewInvClass != None 
				&& MakeMe == OldInvClass )
			{
				MakeMe = NewInvClass;
				bReplaced = true;
				break;
			}
		}
	}

	///steam 12/10/2016
	if( !bReplaced && AddonCoopInvReplace.Length > 0 )
	{
		///steam 30/04/2016
		for( i = 0 ; i < AddonCoopInvReplace.Length ; i++ )
		{
			OldInvClass = class<Inventory>(DynamicLoadObject(AddonCoopInvReplace[i].OldClass,class'Class'));
			NewInvClass = class<Inventory>(DynamicLoadObject(AddonCoopInvReplace[i].NewClass,class'Class'));
			if( OldInvClass != None 
				&& NewInvClass != None 
				&& MakeMe == OldInvClass )
			{
				MakeMe = NewInvClass;
				bReplaced = true;
				break;
			}
		}
	}

	///steam 03/08/2016
	if( !bReplaced )
	{
		///steam 30/04/2016
		for( i = 0 ; i < CoopInvReplace.Length ; i++ )
		{
			OldInvClass = class<Inventory>(DynamicLoadObject(CoopInvReplace[i].OldClass,class'Class'));
			NewInvClass = class<Inventory>(DynamicLoadObject(CoopInvReplace[i].NewClass,class'Class'));
			if( OldInvClass != None 
				&& NewInvClass != None 
				&& MakeMe == OldInvClass )
			{
				MakeMe = NewInvClass;
				break;
			}
		}
	}
	return MakeMe;
}

///steam 26/07/2016 used in P2Pawn.uc CreateInventory()
function string GetInventoryClassOverride(string InventoryClassName)
{
	local int i;
	local bool bReplaced;

	bReplaced = false;

	///steam 03/08/2016
	if( bCustomCoopInvReplace )
	{
		for( i = 0 ; i < CustomCoopInvReplace.Length ; i++ )
		{
			if( CustomCoopInvReplace[i].OldClass != "" 
				&& CustomCoopInvReplace[i].NewClass != "" 
				&& InventoryClassName ~= CustomCoopInvReplace[i].OldClass )
			{
				InventoryClassName = CustomCoopInvReplace[i].NewClass;
				bReplaced = true;
				break;
			}
		}
	}

	///steam 12/10/2016
	if( !bReplaced && AddonCoopInvReplace.Length > 0 )
	{
		///steam 30/04/2016
		for( i = 0 ; i < AddonCoopInvReplace.Length ; i++ )
		{
			if( AddonCoopInvReplace[i].OldClass != "" 
				&& AddonCoopInvReplace[i].NewClass != "" 
				&& InventoryClassName ~= AddonCoopInvReplace[i].OldClass )
			{
				InventoryClassName = AddonCoopInvReplace[i].NewClass;
				bReplaced = true;
				break;
			}
		}
	}

	///steam 03/08/2016
	if( !bReplaced )
	{
		///steam 30/04/2016
		for( i = 0 ; i < CoopInvReplace.Length ; i++ )
		{
			if( CoopInvReplace[i].OldClass != "" 
				&& CoopInvReplace[i].NewClass != "" 
				&& InventoryClassName ~= CoopInvReplace[i].OldClass )
			{
				InventoryClassName = CoopInvReplace[i].NewClass;
				break;
			}
		}
	}
	return Super.GetInventoryClassOverride(InventoryClassName);
}

function ReplaceBaseEquipment(P2MoCapPawn Other)
{
	local int i;
	if( Other != None && PersonPawn(Other) != None && !PersonPawn(Other).bGotDefaultInventory )
	{
		for( i = 0 ; i < Other.BaseEquipment.Length ; i++ )
		{
			if( Other.BaseEquipment[i].WeaponClass != None )
				Other.BaseEquipment[i].WeaponClass = GetInventoryObjClass(Other.BaseEquipment[i].WeaponClass);
				//Other.BaseEquipment[i].WeaponClass = class<P2Weapon>(GetInventoryObjClass(Other.BaseEquipment[i].WeaponClass));
		}
	}
}

function ModifyNPC(Pawn Other)
{
	local int i;
	local P2MoCapPawn aPawn;

	if (P2MoCapPawn(Other) != None)
	{
		aPawn = P2MoCapPawn(Other);

		for( i = 0 ; i < aPawn.MAX_BOLTONS ; i++ )
		{
			if( aPawn.boltons[i].part != None && !aPawn.boltons[i].part.bDeleteMe )
			{
				if( aPawn.boltons[i].bAttachToHead
					|| aPawn.boltons[i].bone == 'NODE_Parent' )
					aPawn.boltons[i].part.SetOwner(aPawn.MyHead);
				else aPawn.boltons[i].part.SetOwner(aPawn);
			}
		}

		if (BystanderController(Other.Controller) != None)
			BystanderController(Other.Controller).bCoopAlertMode = true;
	}

	Super.ModifyNPC(Other);
}

///steam 30/10/2017
function AddCustomCoopInvStarting(P2MoCapPawn Other)
{
	local int i;
	if( Other == None 
		|| Other.bDeleteMe 
		|| CustomCoopInvStarting.Length == 0 )
		return;
	for( i = 0 ; i < CustomCoopInvStarting.Length ; i++ )
	{
		if( CustomCoopInvStarting[i] != "" )
			Other.CreateInventory(CustomCoopInvStarting[i]);
	}
}

/*function ModifyAppearance(Pawn Other)
{
	Super.ModifyAppearance(Other);
}*/

/*function Mutate(string Params, PlayerController Sender)
{
	Sender.ClientMessage(Level.Game.BaseMutator@Level.Game.BaseMutator.NextMutator@Level.Game.BaseMutator.NextMutator.NextMutator);
	if (NextMutator != None)
		NextMutator.Mutate(Params, Sender);
}*/

defaultproperties
{
	FriendlyName="NicksCoop"

	CoopInvReplace(0)=(OldClass="Inventory.HandsWeapon",NewClass="NicksCoop.CoopInvFix_HandsWeapon")
	CoopInvReplace(1)=(OldClass="Inventory.MachineGunWeapon",NewClass="NicksCoop.CoopInvFix_MachineGunWeapon")
	CoopInvReplace(2)=(OldClass="Inventory.ShotGunWeapon",NewClass="NicksCoop.CoopInvFix_ShotGunWeapon")
	CoopInvReplace(3)=(OldClass="Inventory.PistolWeapon",NewClass="NicksCoop.CoopInvFix_PistolWeapon")
	CoopInvReplace(4)=(OldClass="Inventory.CatnipInv",NewClass="NicksCoop.CoopInvFix_CatnipInv")
	CoopInvReplace(5)=(OldClass="Inventory.RocketCamInv",NewClass="NicksCoop.CoopInvFix_RocketCamInv")
	CoopInvReplace(6)=(OldClass="Inventory.RadarTargetInv",NewClass="NicksCoop.CoopInvFix_RadarTargetInv")
	CoopInvReplace(7)=(OldClass="Inventory.NewspaperInv",NewClass="NicksCoop.CoopInvFix_NewspaperInv")
	CoopInvReplace(8)=(OldClass="Inventory.ClipboardWeapon",NewClass="NicksCoop.CoopInvFix_ClipboardWeapon")
	CoopInvReplace(9)=(OldClass="Inventory.StatInv",NewClass="NicksCoop.CoopInvFix_StatInv")
	CoopInvReplace(10)=(OldClass="EDStuff.GrenadeLauncherWeapon",NewClass="NicksCoop.CoopInvFix_GrenadeLauncherWeapon")
}