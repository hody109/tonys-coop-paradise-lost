//=============================================================================
// CoopTransferBackpack.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2018.
//=============================================================================

class CoopTransferBackpack extends Actor
	placeable;

var() Sound PickupSound;

function Touch(Actor Other)
{
	local CoopSaveSystem aCoopSaveSystem;
	Super.Touch(Other);

	if( CoopGameInfo(Level.Game) == None 
		|| MpPawn(Other) == None 
		|| !MpPawn(Other).IsHumanControlled() )
		return;

	aCoopSaveSystem = CoopGameInfo(Level.Game).CoopSaveSystem;
	if( aCoopSaveSystem != None )
	{
		if( aCoopSaveSystem.RecoverTransferItems(MpPawn(Other)) )
		{
			Other.PlaySound( PickupSound,,2.0 );

			MpPawn(Other).ClientMessage("You got your loot back!");
			if( aCoopSaveSystem.TransferItemsCache.Length == 0 )
			{
				bHidden = true;
				SetCollision(false);
				LifeSpan = 0.1;
			}
		}
	}
}

defaultproperties
{
	PickupSound=Sound'WeaponSounds.weapon_picked_up'

	Physics=PHYS_Rotating
	bFixedRotationDir=True
	RotationRate=(Pitch=0,Roll=0,Yaw=10000)
	DesiredRotation=(Pitch=0,Roll=0,Yaw=1)

	bCollideActors=true
	bBlockActors=false
	bBlockPlayers=false
	AmbientGlow=255
	DrawType=DT_StaticMesh
	//StaticMesh=StaticMesh'boltons.Military_Pack'
	//StaticMesh=StaticMesh'AW_Meshes.Misc.Smell_The_Pain'
	StaticMesh=StaticMesh'dj-protostuff.Chest_Storage'
	//RelativeRotation=(Pitch=16384,Roll=-16384,Yaw=0)
	DrawScale=1.0
	CollisionHeight=4.0
	CollisionRadius=24.0
}
