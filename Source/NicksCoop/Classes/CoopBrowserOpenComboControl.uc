//=============================================================================
// CoopBrowserOpenComboControl.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserOpenComboControl extends UWindowComboControl;

function Created()
{
	Super.Created();

	if( EditBox != None )
		EditBox.NotifyOwner = None;
}

function BeforePaint(Canvas C, float X, float Y)
{
	Super.BeforePaint(C, X, Y);

	/*if( EditBox != None )
		EditBox.NotifyOwner = None; crash???*/
}

defaultproperties
{
}
