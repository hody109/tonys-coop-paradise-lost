//=============================================================================
// CoopPawnDeadControllerFX.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopPawnDeadControllerFX extends P2Emitter
	notplaceable;

defaultproperties
{
	bReplicateMovement=true
	AutoDestroy=true

    Begin Object Class=SpriteEmitter Name=CPDCFXEffect01
        Acceleration=(Z=-10.000000)
        ColorScale(0)=(Color=(G=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=255))
        FadeOut=True
        FadeInEndTime=1.000000
        FadeIn=True
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=-10.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=70.000000,Max=80.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'GenFX.LensFlar.lens'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        BlendBetweenSubdivisions=True
        SecondsBeforeInactive=0.000000
        LifetimeRange=(Min=3.000000,Max=3.000000)
        StartVelocityRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Max=100.000000))
        Name="CPDCFXEffect01"
    End Object
    Emitters(0)=SpriteEmitter'CPDCFXEffect01'
}
