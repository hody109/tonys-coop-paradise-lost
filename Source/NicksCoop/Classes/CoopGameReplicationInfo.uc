//=============================================================================
// CoopGameReplicationInfo.uc
// - 20-06-2015 change - activated errands added to replication
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopGameReplicationInfo extends MPGameReplicationInfo;

const ERRANDS_MAX = 10;

var CoopMatineeCamera NETSceneCamera;

var bool bCoopLevelLoading;
var bool bCoopLevelGameOver;
var bool bCoopWaitPlayers;
var bool bCoopWaitContinue;
var bool bCoopLevelTraveling;
var bool bCoopDedicated;

var float CopRadioTime;

var int CurrentDay;

var int TodayCompletedErrands[ERRANDS_MAX];
var int TodayActivatedErrands[ERRANDS_MAX];

struct KillJob
{
	var Texture HUDIcon;		// Icon to display in the HUD
	var float ShakeKillTime;	// Amount of time to shake kill icon for
	var bool bPercentageDisplay;	// True if we want a percentage output instead of the actual numbers.
	var bool bWillow;			// True if this kill job is a health bar
	var string WillowText;		// Text to overlay over Willow style health bar
	var int UseCount;
	var int UseMax;
};

var KillJob KillJobs[6];
var int KillJobsLength;

replication
{
	unreliable if( Role == ROLE_Authority )
		CopRadioTime, TodayCompletedErrands, TodayActivatedErrands, CurrentDay, bCoopLevelLoading, 
		KillJobs, KillJobsLength, bCoopLevelGameOver, bCoopWaitPlayers, bCoopWaitContinue, 
		bCoopLevelTraveling, bCoopDedicated;

	reliable if( Role == ROLE_Authority )
		NETSceneCamera;
}

defaultproperties
{
	KillJobs(0)=(HUDIcon=None,ShakeKillTime=0,bPercentageDisplay=false,bWillow=false,WillowText="Jack",UseCount=0,UseMax=0)
	KillJobs(1)=(HUDIcon=None,ShakeKillTime=0,bPercentageDisplay=false,bWillow=false,WillowText="Jack",UseCount=0,UseMax=0)
	KillJobs(2)=(HUDIcon=None,ShakeKillTime=0,bPercentageDisplay=false,bWillow=false,WillowText="Jack",UseCount=0,UseMax=0)
	KillJobs(3)=(HUDIcon=None,ShakeKillTime=0,bPercentageDisplay=false,bWillow=false,WillowText="Jack",UseCount=0,UseMax=0)
	KillJobs(4)=(HUDIcon=None,ShakeKillTime=0,bPercentageDisplay=false,bWillow=false,WillowText="Jack",UseCount=0,UseMax=0)
	KillJobs(5)=(HUDIcon=None,ShakeKillTime=0,bPercentageDisplay=false,bWillow=false,WillowText="Jack",UseCount=0,UseMax=0)

	TodayCompletedErrands(0)=-1
	TodayCompletedErrands(1)=-1
	TodayCompletedErrands(2)=-1
	TodayCompletedErrands(3)=-1
	TodayCompletedErrands(4)=-1
	TodayCompletedErrands(5)=-1
	TodayCompletedErrands(6)=-1
	TodayCompletedErrands(7)=-1
	TodayCompletedErrands(8)=-1
	TodayCompletedErrands(9)=-1

	TodayActivatedErrands(0)=-1
	TodayActivatedErrands(1)=-1
	TodayActivatedErrands(2)=-1
	TodayActivatedErrands(3)=-1
	TodayActivatedErrands(4)=-1
	TodayActivatedErrands(5)=-1
	TodayActivatedErrands(6)=-1
	TodayActivatedErrands(7)=-1
	TodayActivatedErrands(8)=-1
	TodayActivatedErrands(9)=-1
}
