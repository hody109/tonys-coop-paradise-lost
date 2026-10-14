//=============================================================================
// CoopFix_ACTION_P2Screen.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFix_ACTION_P2Screen extends ACTION_P2Screen;

function bool InitActionFor(ScriptedController C)
{
	local P2Player p2p;

	///p2p = GetPlayer(C);
	p2p = CoopGameInfo(C.Level.Game).GetPlayer();
	if (p2p != None)
		{
		switch (Screen)
			{
			case EMapScreen:
				if (bMapRevealErrands)
				{
					p2p.DisplayMapErrands();
					//CoopPlayerController(p2p).CoopCallMapForClients();///steam 21/07/2016 replaced to p2p.DisplayMapErrands()
				}
				else if (bMapRevealHaters)
					p2p.DisplayMapHaters();
				else
				{
					p2p.DisplayMap();
					CoopPlayerController(p2p).CoopCallMapForClients();
				}
				break;

			case EVoteScreen:
				///steam 14/06/2016
				if( !CoopPlayerController(p2p).DecideToDelayScreenRequest("DisplayVote") )
					p2p.DisplayVote();
				break;

			case ENewsScreen:
				///steam 14/06/2016
				if( !CoopPlayerController(p2p).DecideToDelayScreenRequest("DisplayNews") )
					p2p.DisplayNews();
				break;

			case EPickScreen:
				///steam 14/06/2016
				if( !CoopPlayerController(p2p).DecideToDelayScreenRequest("DisplayPick") )
					p2p.DisplayPick();
				break;

			case EStatsScreen:
				///steam 14/06/2016
				if( !CoopPlayerController(p2p).DecideToDelayScreenRequest("DisplayStats") )
					p2p.DisplayStats();
				break;

			default:
				break;
			}
		}
	return false;
}

defaultproperties
{
}