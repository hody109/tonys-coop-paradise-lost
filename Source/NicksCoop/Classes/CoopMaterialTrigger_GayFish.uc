//=============================================================================
// CoopMaterialTrigger_GayFish.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMaterialTrigger_GayFish extends CoopMaterialTrigger;

defaultproperties
{
    MaterialsToTrigger(0)=MaterialSwitch'PB_MaterialSW.All.wall1'
    MaterialsToTrigger(1)=MaterialSwitch'PB_MaterialSW.All.floor1'
    MaterialsToTrigger(2)=MaterialSwitch'PB_MaterialSW.All.ceilingfloorcombo'
    MaterialsToTrigger(3)=MaterialSwitch'PB_MaterialSW.ceiling2'
    MaterialsToTrigger(4)=MaterialSwitch'PB_MaterialSW.floortile'
    MaterialsToTrigger(5)=MaterialSwitch'PB_MaterialSW.wall2'

	Tag="HeadTexTrig"
	//Name="MaterialTrigger7"
}
