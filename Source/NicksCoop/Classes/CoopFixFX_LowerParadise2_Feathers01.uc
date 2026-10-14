//=============================================================================
// CoopFixFX_LowerParadise2_Feathers01.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFixFX_LowerParadise2_Feathers01 extends Emitter;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=CoopFixFX_LowPar2_Feat_FX01
        MaxParticles=70
        StartLocationRange=(X=(Min=-256.000000,Max=256.000000),Y=(Min=-256.000000,Max=256.000000))
        SpinParticles=True
        SpinsPerSecondRange=(X=(Min=0.300000,Max=0.200000),Y=(Min=0.300000,Max=0.200000),Z=(Min=0.300000,Max=0.200000))
        StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=5.000000,Max=10.000000),Z=(Min=5.000000,Max=10.000000))
        DrawStyle=PTDS_Brighten
        Texture=Texture'Zo_Town_Tex.Misc.zo_town_feathers'
        TextureUSubdivisions=2
        TextureVSubdivisions=2
        UseRandomSubdivision=True
        StartVelocityRange=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000),Z=(Min=-64.000000,Max=-96.000000))
        Name="CoopFixFX_LowPar2_Feat_FX01"
    End Object
    Emitters(0)=SpriteEmitter'CoopFixFX_LowPar2_Feat_FX01'
    Tag="Feathers"
    //Name="Emitter14"
}
