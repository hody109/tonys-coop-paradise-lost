//=============================================================================
// CoopFixFX_Library2_Fire02.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFixFX_Library2_Fire02 extends FireSizeableEmitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=CoopFXFix_Lib_Fire02FX01
        MaxParticles=30
        Disabled=True
        StartLocationRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Max=70.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.500000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.300000)
        SizeScale(1)=(RelativeTime=0.200000,RelativeSize=1.000000)
        SizeScale(2)=(RelativeTime=1.000000)
        StartSizeRange=(X=(Min=60.000000,Max=90.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'nathans.Skins.firegroup3'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=0.500000,Max=0.600000)
        StartVelocityRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=270.000000,Max=380.000000))
        Name="CoopFXFix_Lib_Fire02FX01"
    End Object
    Emitters(0)=SpriteEmitter'CoopFXFix_Lib_Fire02FX01'
    Begin Object Class=SuperSpriteEmitter Name=CoopFXFix_Lib_Fire02FX02
        Disabled=True
        StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-20.000000,Max=150.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Max=0.300000))
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(1)=(RelativeTime=0.300000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=50.000000))
        DrawStyle=PTDS_AlphaBlend
        Texture=Texture'nathans.Skins.smoke5'
        TextureUSubdivisions=1
        TextureVSubdivisions=4
        BlendBetweenSubdivisions=True
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000),Z=(Min=70.000000,Max=120.000000))
        Name="CoopFXFix_Lib_Fire02FX02"
    End Object
    Emitters(1)=SuperSpriteEmitter'CoopFXFix_Lib_Fire02FX02'
    Tag="Fire"
    LifeSpan=6000.000000
    Group="None,fires"
    //Name="FireSizeableEmitter54"
}
