//=============================================================================
// CoopPLFixFX_WestMall_NellyShit.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLFixFX_WestMall_NellyShit extends P2Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=CPLFFX_WestMall_NellyShitFX01
        Acceleration=(Z=-950.000000)
        UseColorScale=True
        ColorScale(0)=(Color=(G=46,R=91))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=32,R=64))
        FadeOutStartTime=0.500000
        MaxParticles=80
        Disabled=True
        DisableFogging=True
        UseRotationFrom=PTRS_Offset
        RotationOffset=(Yaw=16384)
        UseSizeScale=True
        UseRegularSizeScale=False
        SizeScale(0)=(RelativeSize=0.100000)
        SizeScale(1)=(RelativeTime=0.800000,RelativeSize=0.900000)
        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
        DrawStyle=PTDS_AlphaModulate_MightNotFogCorrectly
        Texture=Texture'PL-EmitterTex.Particles.Poop'
        TextureUSubdivisions=1
        TextureVSubdivisions=1
        LifetimeRange=(Min=0.750000,Max=1.000000)
        StartVelocityRange=(X=(Min=-300.000000,Max=-500.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=200.000000))
        Name="CPLFFX_WestMall_NellyShitFX01"
    End Object
    Emitters(0)=SpriteEmitter'CPLFFX_WestMall_NellyShitFX01'
    Begin Object Class=MeshEmitter Name=CPLFFX_WestMall_NellyShitFX02
        StaticMesh=StaticMesh'Timb_mesh.Champ.poo_turd'
        UseParticleColor=True
        Acceleration=(Z=-950.000000)
        UseCollision=True
        DampingFactorRange=(Z=(Min=0.250000,Max=0.330000))
        UseColorScale=True
        ColorScale(0)=(Color=(G=64,R=128))
        ColorScale(1)=(RelativeTime=1.000000,Color=(G=64,R=128))
        FadeOutStartTime=1.000000
        FadeOut=True
        MaxParticles=30
        Disabled=True
        UseRotationFrom=PTRS_Offset
        SpinParticles=True
        RotationOffset=(Yaw=16384)
        SpinsPerSecondRange=(Z=(Min=1.000000,Max=1.000000))
        StartSizeRange=(X=(Max=3.000000),Y=(Max=3.000000),Z=(Max=3.000000))
        DrawStyle=PTDS_Modulated
        LifetimeRange=(Min=2.000000,Max=2.000000)
        StartVelocityRange=(X=(Min=-200.000000,Max=-600.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Min=-200.000000,Max=300.000000))
        Name="CPLFFX_WestMall_NellyShitFX02"
    End Object
    Emitters(1)=MeshEmitter'CPLFFX_WestMall_NellyShitFX02'

    Tag="NellyShitEmitter"
}
