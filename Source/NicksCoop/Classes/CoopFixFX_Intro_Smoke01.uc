//=============================================================================
// CoopFixFX_Intro_Smoke01.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFixFX_Intro_Smoke01 extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=CoopFixFX_Intro_Smoke01FX01
        Acceleration=(Z=12.000000)
        FadeOut=True
        MaxParticles=9
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
        StartVelocityRange=(X=(Min=-50.000000,Max=-60.000000),Y=(Min=80.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000))
        Name="CoopFixFX_Intro_Smoke01FX01"
    End Object
    Emitters(0)=SpriteEmitter'CoopFixFX_Intro_Smoke01FX01'
    Tag="carsmoke2"
    //Name="P2Emitter2"
}
