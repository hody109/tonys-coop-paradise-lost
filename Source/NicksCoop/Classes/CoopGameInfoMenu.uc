//=============================================================================
// CoopGameInfoMenu.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopGameInfoMenu extends GameSinglePlayer;

function LoadCustomMap(string URL)
{
	local P2Player p2p;

	p2p = GetPlayer();

	if( p2p != None )
	{
		p2p.ClientMessage("At first host a game.");
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetFluidSurfaceInfoDefaults();
}

function SetFluidSurfaceInfoDefaults()
{
	// 14/10/22 - must be called both server and client game in order to make sure net code won't fail
	// called from CoopGameInfo and CoopGameInfoMenu
	ConsoleCommand("set FluidSurfaceInfo bNoDelete true");
}

defaultproperties
{
	 MainMenuName="NicksCoop.CoopMenuMain"
	 StartMenuName="NicksCoop.CoopMenuMain"
	 GameMenuName="NicksCoop.CoopMenuGame"

	 PlayerControllerClassName="NicksCoop.CoopPlayerControllerHostMenu"
	 DefaultPlayerName="TheDude"
	 GameName="Postal2 Single Player"
}
