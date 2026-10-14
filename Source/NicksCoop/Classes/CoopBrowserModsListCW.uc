//=============================================================================
// CoopBrowserModsListCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserModsListCW extends ShellMapListCW
	config(NicksCoopCustomMods);

struct CoopModsStruct
{
	var array<string> InventoryClasses;
	var string ModName;
};
var globalconfig array<CoopModsStruct> CoopMods;

function LoadButtonClicked()
{
	local int i;

	if( MapListBox.SelectedItem != None )
	{
		i = int(ShellMapListItem(MapListBox.SelectedItem).MapName);
		if( GetPlayerOwner().Buoyancy == 75 )
			CoopGameInfo(Root.GetLevel().Game).CoopLoadCustomMod(CoopMods[i].ModName, CoopMods[i].InventoryClasses);
		else CoopPlayerController(GetPlayerOwner()).NETCoopLoadCustomMod(CoopMods[i].ModName, i);
	}
	ShellRootWindow(Root).HideMenu();
}

function LoadMapList()
{
	local int i;
	local ShellMapListItem sItem;

	for( i = 0 ; i < CoopMods.Length ; i++ )
	{
		sItem = ShellMapListItem(MapListBox.Items.Append(class'ShellMapListItem'));
		sItem.MapName = ""$i;
		sItem.DisplayName = CoopMods[i].ModName;
	}

	MapListBox.Sort();
}

defaultproperties
{
	CoopMods(0)=(ModName="ProjectMarica vehicles mod",InventoryClasses=("ProjectMarica.VehicleCreatorWeapon"))
	CoopMods(1)=(ModName="DarkFire weapons mod",InventoryClasses=("DarkFire.DarkFireCaseInv"))
}