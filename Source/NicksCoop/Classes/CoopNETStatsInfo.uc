//=============================================================================
// CoopNETStatsInfo.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopNETStatsInfo extends Actor;

const	LEFT_START_X	=	0.20; 
const	RIGHT_START_X	=	0.7; 
const	START_Y			=	0.06; 
const	INC_Y			=	0.025;
const	REVEAL_TIME		=	0.1;
const   FINAL_WAIT_TIME	=	2.0;

var Texture BackgroundTex;

var bool bBlinkMsgTrig;

var float BlinkMsgTime;

var localized string AboutToCloseMsg;
var localized string ClientModeText;

///replication section

var int PeopleKilled;
var int CopsKilled;
var int PeopleRoasted;
var int ElephantsKilled;
var int DogsKilled;
var int CatsKilled;
var int PistolHeadShot;
var int ShotgunHeadShot;	
var int RifleHeadShot;
var int CatsUsed;
var int MoneySpent;
var float PeeTotal;
var int LimbsHacked;
var int HeadsLopped;
var int BaseballHeads;
var int ChainsawKills;
var int DoorsKicked;
var int TimesArrested;
var int DressedAsCop;
var int DogsTrained;
var int CopsLuredByDonuts;
var float TimeElapsed;
var string GameDifficulty;
var string PlayerRank;
var string GameMode;
var bool DidPlayerCheat;
var string GetPlayerRankingSpeedRun;
var string TimePlayed;
var string GetModList;
var string GetPlayerRanking;

var int ZombiesKilledOverall;
var int ZombiesResurrected;
var int LostSledgeInCow;
var int FanaticsKilled;
var int ArmyKilled;

replication
{
	unreliable if( Role == ROLE_Authority )
		PeopleKilled, CopsKilled, PeopleRoasted, ElephantsKilled, DogsKilled, 
		CatsKilled, PistolHeadShot, ShotgunHeadShot, RifleHeadShot, CatsUsed, 
		MoneySpent, PeeTotal, LimbsHacked, HeadsLopped, BaseballHeads, 
		ChainsawKills, DoorsKicked, TimesArrested, DressedAsCop, DogsTrained, 
		CopsLuredByDonuts, TimeElapsed, GameDifficulty, PlayerRank, GameMode, 
		DidPlayerCheat, GetPlayerRankingSpeedRun, TimePlayed, GetModList, 
		ZombiesKilledOverall, ZombiesResurrected, LostSledgeInCow, FanaticsKilled, 
		ArmyKilled;
}

simulated function PlayerController GetPlayer()
{
	if( Owner != None )
		return PlayerController(Owner);
	return None;
}

function P2GameInfoSingle GetGameSingle()
{
	if( Level.Game != None )
		return P2GameInfoSingle(Level.Game);
	return None;
}

function PostBeginPlay()
{
	local GameState gamest;

	Super.PostBeginPlay();

	gamest = GetGameSingle().TheGameState;
	if( gamest == None )
		return;

	PeopleKilled = gamest.PeopleKilled;
	CopsKilled = gamest.CopsKilled;
	PeopleRoasted = gamest.PeopleRoasted;
	ElephantsKilled = gamest.ElephantsKilled;
	DogsKilled = gamest.DogsKilled;///steam 21/10/2017
	CatsKilled = gamest.CatsKilled;
	PistolHeadShot = gamest.PistolHeadShot;
	ShotgunHeadShot = gamest.ShotgunHeadShot;
	RifleHeadShot = gamest.RifleHeadShot;
	CatsUsed = gamest.CatsUsed;
	MoneySpent = gamest.MoneySpent;
	PeeTotal = 0.1*float(gamest.PeeTotal);
	LimbsHacked = gamest.LimbsHacked;
	HeadsLopped = gamest.HeadsLopped;
	BaseballHeads = gamest.BaseballHeads;
	ChainsawKills = gamest.ChainsawKills;
	DoorsKicked = gamest.DoorsKicked;
	TimesArrested = gamest.TimesArrested;
	DressedAsCop = gamest.DressedAsCop;
	DogsTrained = gamest.DogsTrained;
	CopsLuredByDonuts = gamest.CopsLuredByDonuts;
	GameMode = GetGameSingle().GameName;
	GameDifficulty = GetGameSingle().GetDiffName(gamest.GameDifficulty);
	DidPlayerCheat = gamest.DidPlayerCheat();
	GetPlayerRankingSpeedRun = gamest.GetPlayerRankingSpeedRun();
	TimePlayed = gamest.HoursPlayed()$":"$gamest.MinutesPlayed()$":"$gamest.SecondsPlayed()@gamest.GetSingleSegmentString();
	GetModList = gamest.GetModList();
	PlayerRank = gamest.GetPlayerRanking();

	if( AWGameState(gamest) != None )
	{
		ZombiesKilledOverall = AWGameState(gamest).ZombiesKilledOverall;
		ZombiesResurrected = AWGameState(gamest).ZombiesResurrected;
		LostSledgeInCow = AWGameState(gamest).LostSledgeInCow;
		FanaticsKilled = AWGameState(gamest).FanaticsKilled;
		ArmyKilled = AWGameState(gamest).ArmyKilled;
	}
}

simulated function RenderStats(canvas Canvas, FontInfo MyFont)
{
	local int StatNum;
	local int i;
	local float sxl, sxr, sy,NearestFourByThree, OffsetX;
	local string ustr, Mods;

	StatNum = 100;

	if( BackgroundTex != None )
	{
		//ScaleX = Canvas.ClipX / BackgroundTex.USize;
		//ScaleY = Canvas.ClipY / BackgroundTex.VSize;

		Canvas.Style = 1; //ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255, 255, 255);
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(BackgroundTex, Canvas.SizeX, Canvas.SizeY, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);
	}

    NearestFourByThree = GetPlayer().GetFourByThreeResolution(canvas);
	OffsetX = (canvas.ClipX - NearestFourByThree) /2;

	// Show our stats
	sxl = LEFT_START_X;
	sxr = RIGHT_START_X;
	sy = START_Y;
	if(StatNum == 0) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.PeopleKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$PeopleKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 1) return;

	// Number of zombies killed
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'AWStatsScreen'.default.ZombiesKilledOverall, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$ZombiesKilledOverall, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 2) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'AWStatsScreen'.default.ZombiesResurrected, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$ZombiesResurrected, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 3) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.CopsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$CopsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 4) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.PeopleRoasted, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$PeopleRoasted, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 5) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.ElephantsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$ElephantsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 6) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.DogsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$DogsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 7) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.CatsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$CatsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 8) return;

	// Fanatics killed
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'AWStatsScreen'.default.FanaticsKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$FanaticsKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 9) return;

	// Army killed
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'AWStatsScreen'.default.ArmyKilled, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$ArmyKilled, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 10) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.ShotgunHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$ShotgunHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 11) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.RifleHeadShot, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$RifleHeadShot, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 12) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.CatsUsed, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$CatsUsed, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 13) return;

	// Sledges lost in cow
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'AWStatsScreen'.default.LostSledgeInCow, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$LostSledgeInCow, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 14) return;

	// Limbs hacked
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.LimbsHacked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$LimbsHacked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 15) return;

	// Heads lopped
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.HeadsLopped, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$HeadsLopped, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 16) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.HeadsBattedOff, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$BaseballHeads, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 17) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.ChainsawKills, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$ChainsawKills, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 18) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.MoneySpent, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$MoneySpent, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 19) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.PeeTotal, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$PeeTotal, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 20) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.DoorsKicked, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$DoorsKicked, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 21) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.TimesArrested, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$TimesArrested, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 22) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.DressedAsCop, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$DressedAsCop, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 23) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.DogsTrained, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$DogsTrained, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 24) return;

	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.CopsLuredByDonuts, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$CopsLuredByDonuts, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 25) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.GameMode@ClientModeText, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GameMode, 0, false, EJ_Left);
	sy += INC_Y;
	if(StatNum == 26) return;
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.Difficulty, 0, false, EJ_Left);
	MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$GameDifficulty, 0, false, EJ_Left);
	sy += INC_Y;

///	if (URL == "") return;

	// Hide this if they cheated
	if (!DidPlayerCheat)
	{
		if (GetPlayerRankingSpeedRun != "")
			MyFont.TextColor=class'StatsScreen'.default.YellowC;
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxl * NearestFourByThree), sy * Canvas.ClipY, class'StatsScreen'.default.TimeElapsed@GetPlayerRankingSpeedRun, 0, false, EJ_Left);
		MyFont.DrawTextEx(Canvas, NearestFourByThree, OffsetX + (sxr * NearestFourByThree), sy * Canvas.ClipY, ustr$TimePlayed, 0, false, EJ_Left);
		MyFont.TextColor=MyFont.default.TextColor;
		sy += INC_Y;
		if (StatNum == 27) return;
	}
	
	if (StatNum < 28) return;
	// Mods
	Mods = GetModList;
	if (Mods != "")
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, class'StatsScreen'.default.ModsUsed@Mods, 0, false, EJ_Center);
		
	sy += INC_Y;
	sy += INC_Y;
	
	// Final summary
	MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, class'StatsScreen'.default.Ranking, 2, false, EJ_Center);
	sy += INC_Y;
	MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, ustr$PlayerRank, 3, false, EJ_Center);
	sy += INC_Y;
	sy += INC_Y;
/**	if (UseInfo.FinallyOver())
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, CheatsNow, 1, false, EJ_Center);
	if(StatNum < 30) return;
	if(
		useinfo.VerifyGH()
		&& useinfo.SeqTimeVerified())
		{
		sy += INC_Y;
		MyFont.TextColor=YellowC;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, NewItemNow, 1, false, EJ_Center);
		MyFont.TextColor=MyFont.default.TextColor;
		}	
	}**/

	if( Level.TimeSecondsAlways > BlinkMsgTime )
	{
		bBlinkMsgTrig = !bBlinkMsgTrig;
		BlinkMsgTime = Level.TimeSecondsAlways + 0.5;
	}
	if( bBlinkMsgTrig )
	{
		MyFont.TextColor=class'StatsScreen'.default.YellowC;
		MyFont.DrawTextEx(Canvas, Canvas.ClipX, 0.5 * Canvas.ClipX, sy * Canvas.ClipY, AboutToCloseMsg, 1, false, EJ_Center);
		MyFont.TextColor=MyFont.default.TextColor;
	}
}

defaultproperties
{
	ClientModeText="(Client-Player)"
	AboutToCloseMsg="Server is about to close! Do not forget to make screenshot! (this window will disappear)"
	BackgroundTex=Texture'P2Misc_full.InkyBlackness'

	NetUpdateFrequency=10.0f
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysTick=true
	bHidden=true
	bAlwaysRelevant=true
	bGameRelevant=true
	bReplicateMovement=false
}
