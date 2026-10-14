//=============================================================================
// CoopPLMenu.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLMenu extends CoopMenu;

defaultproperties
{
	DefWorkshopGameINIPath="..\\WorkshopContent\\962305875\\Postal2CRCoOp.ini"

	NicksCoopAddonBuildString=" - PL addon 0.0.1b"

	bUseStoryCombo=false
	bUseNoHolidaysCheckbox=false

	CoopMenuGameInfoClass="NicksCoopPL.CoopPLGameInfoMenu"
	ServerGameType=class'NicksCoopPL.CoopPLGameInfo'
	//ServerMap="DudeHouse.fuk"
}
