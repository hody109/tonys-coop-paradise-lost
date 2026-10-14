//=============================================================================
// CoopShellMenuChoice.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopShellMenuChoice extends ShellMenuChoice;

function RClick(float X, float Y)
{
	if( bActive )
	{
		LookAndFeel.Control_Click(self);
		Notify(DE_RClick);
	}
	Super.RClick(X,Y);
}

defaultproperties
{
}