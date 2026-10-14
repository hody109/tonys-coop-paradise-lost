//=============================================================================
// CoopBrowserPlayerMenuSetupDummy.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserPlayerMenuSetupDummy extends Actor;

var float FrameSize;
var float OldFrameSize;
var float ScreenWidth;
var float fUpdateTime;
var bool bReachFrameSize;

function SetupDummySkin(string NewSkin)
{
	local Material NewSkinMaterial;

	NewSkinMaterial = Material(DynamicLoadObject(NewSkin, class'Material'));

	if( NewSkinMaterial != None )
		Skins[0] = NewSkinMaterial;
}

function Tick(float DeltaTime)
{
	local float fTempSize;
	if( bReachFrameSize && Mesh != None )
	{
		if( Level.TimeSeconds > fUpdateTime )
		{
			fTempSize = VSize(GetBoneCoords('MALE01 head').Origin-Location);
			if( FrameSize > OldFrameSize && fTempSize < FrameSize && DrawScale < 2 )
				SetDrawScale(DrawScale+0.001);
			else if( FrameSize < OldFrameSize && fTempSize > FrameSize && DrawScale > 0.001 )
				SetDrawScale(DrawScale-0.001);
			else
			{
				bReachFrameSize = false;
				OldFrameSize = FrameSize;
			}
			fUpdateTime = Level.TimeSeconds + 0.01;
		}
	}
	Super.Tick(DeltaTime);
}

defaultproperties
{
	FrameSize=-1
	//DrawScale=0.018
	DrawScale=0.001
	Mesh=Mesh'Characters.Avg_Dude'
	//Skins(0)=Texture'ChameleonSkins.Special.Dude'

	bUnlit=true
	DrawType=DT_Mesh
	bHidden=true
}
