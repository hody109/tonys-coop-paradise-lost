//=============================================================================
// CoopTelepadBlocker.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopTelepadBlocker extends Actor;

var float LifeTime;
var float MsgTime;
var float FrameTime;

///steam 28/06/2016
var array<Texture> TimerFrameTex;
var int nFrame;

///steam 31/07/2017
var CoopTelepadBlockerSentinel Sentinel;
var Texture SentinelStatusTex;
var bool bSentinel;

var localized string TimeBlocked;
var localized string SentinelBlocked1;
var localized string SentinelBlocked2;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	FrameTime = FClamp(LifeTime/(TimerFrameTex.Length+1),0.1,5)+frand();
	SetTimer(FrameTime, false);
}

function Timer()
{
	local float fCollRadius;
	if( nFrame < TimerFrameTex.Length )
	{
		Texture = TimerFrameTex[nFrame];
		SetTimer(FrameTime, false);
		nFrame++;
	}
	else if( bSentinel )
	{
		Sentinel = spawn(class'CoopTelepadBlockerSentinel',self,,Location);
		if( Sentinel != None )
		{
			if( CollisionRadius >= 1800 )
				fCollRadius = CollisionRadius*1.1;
			else if( CollisionRadius >= 900 )
				fCollRadius = CollisionRadius*1.2;
			else if( CollisionRadius >= 400 )
				fCollRadius = CollisionRadius*1.3;
			else fCollRadius = CollisionRadius*1.6;

			Sentinel.SetCollisionSize(fCollRadius, CollisionHeight*1.1);
			Texture = SentinelStatusTex;
			bHidden = true;
		}
		else CallSafeDestroy();
	}
	else CallSafeDestroy();
}

function Bump(Actor Other)
{
	local int n;
	if( !bHidden && Other != None && MpPawn(Other) != None )
	{
		if( Level.TimeSeconds > MsgTime )
		{
			if( Sentinel != None )
			{
				n = Sentinel.GetAccessPlayersNum();
				if( n > 0 )
					MpPawn(Other).ClientMessage(SentinelBlocked1 @ n @ SentinelBlocked2);
			}
			else MpPawn(Other).ClientMessage(TimeBlocked);
			MsgTime = Level.TimeSeconds + 1.0;
		}
	}
}

///steam 31/07/2017
function CallSafeDestroy()
{
	ControlTelepadCollision(true);
	if( Sentinel != None )
	{
		Sentinel.Destroy();
		Sentinel = None;
	}
	bHidden = true;
	LifeSpan = 0.1;
}

function TravelAccessControl(bool bGrantAccess)
{
	if( bGrantAccess )
	{
		ControlTelepadCollision(true);
		SetCollision(false,false);
		bHidden = true;
	}
	else
	{
		ControlTelepadCollision(false);
		SetCollision(true,true);
		bHidden = false;
	}
}

function ControlTelepadCollision(bool bUseCollide)
{
	if( Owner == None )
		return;
	Owner.SetCollision(bUseCollide, Owner.bBlockActors, Owner.bBlockPlayers);
//	CoopGameInfo(Level.Game).xCoopServerEventMessage("ControlTelepadCollision");
}

defaultproperties
{
	TimeBlocked="Try again after a time"
	SentinelBlocked1="You need"
	SentinelBlocked2="more players to travel!"

	TimerFrameTex(0)=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame01'
	TimerFrameTex(1)=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame02'
	TimerFrameTex(2)=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame03'
	TimerFrameTex(3)=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame04'
	TimerFrameTex(4)=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame05'
	TimerFrameTex(5)=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame06'
	TimerFrameTex(6)=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame07'

	SentinelStatusTex=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame_un'

	bCollideWorld=false
	bCollideActors=true
	bBlockActors=true
	bBlockPlayers=true
	bBlockZeroExtentTraces=false
	bBlockNonZeroExtentTraces=true
	LifeTime=15.0
	CollisionRadius=1.0
	CollisionHeight=1.0
	bStatic=false
	Texture=Texture'NicksCoop.TravelTimerHUD.coop_travel_timer_frame00'
	//Texture=Texture'NicksCoop.MiscHUD.coop_travel_block_tex'
	bHidden=false
	DrawScale=0.38
}
