//=============================================================================
// CoopFixFX_Intro_Fire01.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFixFX_Intro_Fire01 extends FireSizeableEmitter;

defaultproperties
{
    Begin Object Class=SuperSpriteEmitter Name=CoopFixFX_Intro_Fire01FX01
        MaxParticles=20
        Disabled=True
        StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-20.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1.000000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=180.000000,Max=200.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=3.000000)
        InitialDelayRange=(Min=1.000000,Max=1.000000)
        StartVelocityRange=(X=(Max=80.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=80.000000,Max=150.000000))
        Name="CoopFixFX_Intro_Fire01FX01"
    End Object
    Emitters(0)=SuperSpriteEmitter'CoopFixFX_Intro_Fire01FX01'
    Begin Object Class=SpriteEmitter Name=CoopFixFX_Intro_Fire01FX02
        UseDirectionAs=PTDU_Up
        Acceleration=(Z=-900.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=255,R=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
        FadeOut=True
        MaxParticles=8
        Disabled=True
        StartLocationRange=(Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
        StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=8.000000,Max=10.000000))
        InitialParticlesPerSecond=10.000000
        AutomaticInitialSpawning=False
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.softwhitedot'
        LifetimeRange=(Min=500.000000,Max=500.000000)
        StartVelocityRange=(X=(Min=20.000000,Max=30.000000),Y=(Min=-80.000000,Max=80.000000),Z=(Min=-10.000000))
        Name="CoopFixFX_Intro_Fire01FX02"
    End Object
    Emitters(1)=SpriteEmitter'CoopFixFX_Intro_Fire01FX02'
    Tag="ShootAC"
    LifeSpan=60.000000
    //Name="FireSizeableEmitter5"
}
