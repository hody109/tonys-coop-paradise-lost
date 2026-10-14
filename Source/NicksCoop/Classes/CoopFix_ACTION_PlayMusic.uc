//=============================================================================
// CoopFix_ACTION_PlayMusic.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopFix_ACTION_PlayMusic extends ACTION_PlayMusic;

function bool InitActionFor(ScriptedController C)
{
	if( Song != "" )
		C.SongHandle = FPSGameInfo(C.Level.Game).PlayMusicExt(Song, FadeInSongTime);
	return false;	
}

defaultproperties
{
}