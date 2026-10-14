//=============================================================================
// CoopPawnDeadControllerIcon.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopPawnDeadControllerIcon extends Actor
	notplaceable;

defaultproperties
{
	Texture=Texture'NicksCoop.TimerHUD.coop_timer_frame00'
	bReplicateMovement=true
	bCollideActors=false
	DrawType=DT_Sprite
	bHidden=true
	bAlwaysRelevant=true
	DrawScale=0.3
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=false
	bIgnoreOutOfWorld=true
}
