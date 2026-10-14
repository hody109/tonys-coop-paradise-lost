//=============================================================================
// CoopCheapBloodPuddle.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopCheapBloodPuddle extends P2Emitter;

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=xPMPCBPFX01
		SecondsBeforeInactive=0.0
		UseDirectionAs=PTDU_Normal
		FadeOutStartTime=0.5
		FadeOut=True
		FadeInEndTime=0.2
		FadeIn=True
		MaxParticles=3
		DrawStyle=PTDS_AlphaBlend
		StartSizeRange=(X=(Min=20.0,Max=20.0),Y=(Min=20.0,Max=20.0))
		Texture=Texture'nathans.Skins.Bloodpuddle1'
		//Texture=Texture'nathans.Skins.pukesplat'
		LifetimeRange=(Min=1.0,Max=1.0)
		Name="xPMPCBPFX01"
	End Object
	Emitters(0)=SpriteEmitter'xPMPCBPFX01'
	Lifespan=5
	AutoDestroy=true
	RemoteRole=ROLE_None
}