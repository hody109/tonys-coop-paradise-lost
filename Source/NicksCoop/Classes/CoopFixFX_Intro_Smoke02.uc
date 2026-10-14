//=============================================================================
// CoopFixFX_Intro_Smoke02.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFixFX_Intro_Smoke02 extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=CoopFixFX_Intro_Smoke02FX01
        Acceleration=(X=3.000000,Y=-8.000000,Z=8.000000)
        FadeOut=True
        MaxParticles=38
        RespawnDeadParticles=False
        AutoDestroy=True
        Disabled=True
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.200000)
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=30.000000,Max=50.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=-20.000000),Y=(Min=30.000000,Max=40.000000))
        Name="CoopFixFX_Intro_Smoke02FX01"
    End Object
    Emitters(0)=SpriteEmitter'CoopFixFX_Intro_Smoke02FX01'
    Tag="carsmoke1"
    //Name="P2Emitter3"
}
