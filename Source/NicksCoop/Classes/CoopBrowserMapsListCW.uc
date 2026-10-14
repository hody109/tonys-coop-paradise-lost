//=============================================================================
// CoopBrowserMapsListCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserMapsListCW extends ShellMapListCW;

const CUSTOM_MAP_PREFACE_COOP	=	"coop";
const CUSTOM_MAP_PREFACE_WS		=	"ws";

function LoadButtonClicked()
{
	local string MapName, URL;

	if (MapListBox.SelectedItem != None)
	{
		URL = ""$ShellMapListItem(MapListBox.SelectedItem).MapName;
		if( GetPlayerOwner().Buoyancy == 75 )
			P2GameInfoSingle(Root.GetLevel().Game).LoadCustomMap(URL);
		else CoopPlayerController(GetPlayerOwner()).NETCoopLoadCustomMap(URL);
	}
}

function LoadMapList()
{
	local string FirstMap, NextMap, TestMap, MapName;
	local int i, IncludeCount;
	local ShellMapListItem Item;
	
	FirstMap = GetPlayerOwner().GetMapName("", "", 0);
	NextMap = FirstMap;
	while (!(FirstMap ~= TestMap))
		{
		//log(self$" next map "$nextmap);
		if( Left(nextmap, 3) ~= CUSTOM_MAP_PREFACE 
			|| Left(nextmap, 4) ~= CUSTOM_MAP_PREFACE_COOP 
			|| Left(nextmap, 2) ~= CUSTOM_MAP_PREFACE_WS )
			{
			Item = ShellMapListItem(MapListBox.Items.Append(class'ShellMapListItem'));
			Item.MapName = NextMap;
			if(Right(NextMap, 4) ~= ".fuk")
				Item.DisplayName = Left(NextMap, Len(NextMap) - 4);
			else
				Item.DisplayName = NextMap;
			}
		NextMap = GetPlayerOwner().GetMapName("", NextMap, 1);
		TestMap = NextMap;
		}
	
	MapListBox.Sort();
}

defaultproperties
{
}