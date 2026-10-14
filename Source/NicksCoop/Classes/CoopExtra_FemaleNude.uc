//=============================================================================
// CoopExtra_FemaleNude.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopExtra_FemaleNude extends Bystander
 	placeable;

defaultproperties
{
	bRandomizeHeadScale=false
	bIsFemale=true
	//HeadSkin=Texture'ChamelHeadSkins.Female.FWA__026__FemLH'
	HeadMesh=SkeletalMesh'heads.FemLH'
	Mesh=SkeletalMesh'Characters.Fem_LS_Skirt'
	Skins(0)=Texture'NicksCoop.Others.Fem_LS_Skirt_Nude_tex'
}
