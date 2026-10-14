//=============================================================================
// CoopPLInvFix_BucketAttachment.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLInvFix_BucketAttachment extends BucketAttachment;

defaultproperties
{
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'PLBucket.pl_bucket'
	Skins(0)=Shader'Timb.Misc.invisible_mask'
	Skins(1)=Texture'PL_BucketTex.bucket_unwrap'
	Skins(2)=Shader'Timb.Misc.invisible_mask'
	WeapClass=class'CoopPLInvFix_BucketWeapon'
}
