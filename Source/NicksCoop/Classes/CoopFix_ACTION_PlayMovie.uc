//=============================================================================
// CoopFix_ACTION_PlayMovie.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopFix_ACTION_PlayMovie extends ACTION_PlayMovie;

function bool InitActionFor(ScriptedController C)
{
	local CoopPlayerController P;
	local float duration;
	local bool bWait;

	if (MovieFileName != "" && Sound != None)
	{
		foreach C.AllActors(class'CoopPlayerController', P)
		{
			P.xClientPlayMovieScaled(MovieTexture(DynamicLoadObject("MovieTextures.Generic", class'MovieTexture')), MovieFileName, 0, 0, 1, 1, false, false);

			C.GetSoundSource().PlaySound(Sound, SLOT_Interact, 1.0, , , , );

			if (bWaitUntilFinished)
			{
				C.CurrentAction = self;
				bWait = true;
			}
		}
	}
	if( bWait )
		C.SetTimer(C.GetSoundSource().GetSoundDuration(Sound), false);

	return bWait;
}

defaultproperties
{
}