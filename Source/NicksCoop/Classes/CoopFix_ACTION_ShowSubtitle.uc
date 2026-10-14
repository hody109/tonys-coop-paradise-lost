//=============================================================================
// CoopFix_ACTION_ShowSubtitle.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopFix_ACTION_ShowSubtitle extends ACTION_ShowSubtitle;

function bool InitActionFor(ScriptedController C)
{
	local Controller aCon;

	for( aCon = C.Level.ControllerList ; aCon != None ; aCon = aCon.NextController )
	{
		if( CoopPlayerController(aCon) != None && !CoopPlayerController(aCon).IsCoopDedicatedHost() )
			CoopPlayerController(aCon).xCoopShowSubtitleByTag(SubtitleTag);
	}

	return false;
}

defaultproperties
{
}