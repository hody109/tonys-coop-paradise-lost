//=============================================================================
// CoopPawnDeadController.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopPawnDeadController extends Actor
	notplaceable;

///steam 07/01/2016
var float TimerLockDead;
var int TimerFrameCounter;
var Texture TimerFrameTex[9];
var CoopPawnDeadControllerIcon TimerFrameIcon;

var bool bLockDead;
var CoopPostalDude myCoopPawn;
var CoopPlayerController myCoopPlayer;
var Emitter DeadFX;

///steam 11/04/2016
var bool bLockMatinee;
var bool bLockMatineeSwitch;
var float LockMatineeUpd;

///steam 08/10/2016
var CoopPawnDeadControllerIcon CoopTypingIcon;

///steam 20/11/2016
var float fUpdateTime;
var float fCheckHelpTime;

///steam 28/07/2017
var bool bCoopDedicatedHost;

///steam 19/12/2018 update
var vector LastAlivePos;
var float LastAliveTime;

replication
{
	unreliable if( Role == ROLE_Authority )
		myCoopPawn, myCoopPlayer;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TimerFrameIcon = spawn(class'CoopPawnDeadControllerIcon',self,,Location+vect(0,0,100));
	TimerFrameIcon.SetBase(self);

	CoopTypingIcon = spawn(class'CoopPawnDeadControllerIconType',self,,Location+vect(0,0,98));
	CoopTypingIcon.SetBase(self);
}

simulated function Destroyed()
{
	Super.Destroyed();
	if( TimerFrameIcon != None )
		TimerFrameIcon.Destroy();
	if( CoopTypingIcon != None )
		CoopTypingIcon.Destroy();
	if( DeadFX != None )
		DeadFX.Destroy();
}

simulated function SwitchTimerFrame()
{
	if( TimerFrameIcon == None )
		return;

	TimerFrameIcon.SetLocation(Location+vect(0,0,100));
	TimerFrameIcon.SetBase(self);
	if( TimerFrameCounter >= 8 )
		return;
	TimerFrameIcon.Texture = TimerFrameTex[TimerFrameCounter];
	TimerFrameCounter++;
	TimerFrameIcon.bHidden = false;
}

simulated function ResetTimerFrame()
{
	if( TimerFrameIcon == None )
		return;

	TimerFrameCounter = 0;
	TimerFrameIcon.Texture = TimerFrameTex[0];
	TimerFrameIcon.bHidden = true;
}

///steam 10/04/2016
simulated function SetLockMatinee()
{
	if( bLockMatineeSwitch )
		return;
	//myCoopPawn.bHidden = true;
	myCoopPawn.SetCollision(false,false,false);
	myCoopPawn.Acceleration = vect(0,0,0);
	myCoopPawn.Velocity = vect(0,0,0);
	bLockMatineeSwitch = true;
	//myCoopPawn.ClientMessage("SetLockMatinee"@bLockMatinee@bLockMatineeSwitch);
}

///steam 10/04/2016
simulated function SetUnLockMatinee()
{
	if( !bLockMatineeSwitch )
		return;
	bLockMatineeSwitch = false;
	//myCoopPawn.bHidden = false;
	myCoopPawn.SetCollision(myCoopPawn.default.bCollideActors,myCoopPawn.default.bBlockActors,myCoopPawn.default.bBlockPlayers);
	//myCoopPawn.ClientMessage("SetUnLockMatinee"@bLockMatinee@bLockMatineeSwitch);
}

simulated function xForceHealThePawn(float useHealth)
{
	ResetTimerFrame();
	myCoopPawn.xPostForceHealThePawn(useHealth);
	myCoopPawn.SetPhysics(PHYS_Falling);
	myCoopPawn.AddHealthPct(useHealth);
	if( myCoopPlayer != None )
		myCoopPlayer.CallForceReturnView();///steam 21/07/2016 hack to return view forced
		///myCoopPlayer.NETCoopSpectator(false);
	bLockDead = false;

	///steam 15/05/2016
	if( CoopGameInfo(Level.Game) != None )
		CoopGameInfo(Level.Game).CoopCheckLevelGameOver(true);
}

simulated function Tick(float DeltaTime)
{
	local CoopPostalDude OtherCoopPawn;
	local int nTimerFrame;
	local NavigationPoint aRespawnSpot;
	local vector DeadBodyLoc;

	if( Level.TimeSeconds < fUpdateTime )
		return;
	fUpdateTime = Level.TimeSeconds + 0.02;

	if( myCoopPawn != None && !myCoopPawn.bDeleteMe )///steam 31/07/2016
	{
		///steam 11/04/2016
		if( myCoopPlayer != None )
		{
			if( myCoopPlayer.Buoyancy != 75 || bCoopDedicatedHost )
			{
				if( Level.TimeSeconds > LockMatineeUpd )
				{
					bLockMatinee = myCoopPlayer.xGetMatineeCameraStatus();
					LockMatineeUpd = Level.TimeSeconds + 1.01;
				}
			}
			else bLockMatinee = false;

			///steam 08/10/2016
			if( CoopTypingIcon != None && !bLockMatinee 
				&& myCoopPlayer.PlayerReplicationInfo != None 
				&& !myCoopPlayer.PlayerReplicationInfo.bOnlySpectator )
			{
				if( myCoopPlayer.bCoopIsTyping 
					&& !myCoopPlayer.bInterpolating 
					&& !myCoopPawn.bHidden 
					&& ((TimerFrameIcon != None && TimerFrameIcon.bHidden) || TimerFrameIcon == None) )
				{
					if( CoopTypingIcon.bHidden )
						CoopTypingIcon.bHidden = false;
				}
				else
				{
					if( !CoopTypingIcon.bHidden )
						CoopTypingIcon.bHidden = true;
				}
			}
		}
		else
		{
			if( CoopTypingIcon != None && !CoopTypingIcon.bHidden )
				CoopTypingIcon.bHidden = true;
		}

		if( myCoopPawn.Health <= 0 || bLockDead )
		{
			bLockDead = true;

			///steam 07/01/2016
			if( TimerLockDead == 0 )
				TimerLockDead = Level.TimeSeconds;

			nTimerFrame = Level.TimeSeconds - TimerLockDead;

			if( nTimerFrame == TimerFrameCounter )
				SwitchTimerFrame();

			if( !bCollideActors )
			{
				SetCollision(true);
				ForcePlayerDied();
			}

			if( myCoopPlayer != None )
				myCoopPlayer.SetBlockPlayerInput(true, !bLockMatinee);

			if( myCoopPawn.Health != 0 )
				myCoopPawn.Health = 0;

			if( myCoopPawn.bCollideActors )
				myCoopPawn.SetCollision(false,false,false);

			if( !myCoopPawn.bCoopPlayerDied )
				myCoopPawn.bCoopPlayerDied = true;

			myCoopPawn.Acceleration = vect(0,0,0);
			myCoopPawn.Velocity = vect(0,0,0);
			myCoopPawn.SetLocation(Location);

			if( myCoopPawn.Physics != PHYS_None )
				myCoopPawn.SetPhysics(PHYS_None);

			if( DeadFX == None )
			{
				DeadFX = spawn(class'CoopPawnDeadControllerFX', self,, Location);
				DeadFX.SetBase(self);
			}
			else DeadFX.SetLocation(Location);

			///steam 07/01/2016
			if( Level.TimeSeconds > TimerLockDead + 8 )
			{
				ResetTimerFrame();
				if( Level.TimeSeconds > fCheckHelpTime )
				{
					foreach CollidingActors(class'CoopPostalDude', OtherCoopPawn, CollisionRadius)
					{
						if( OtherCoopPawn.bCoopPlayer && OtherCoopPawn != myCoopPawn )
						{
							xForceHealThePawn(30);
							myCoopPawn.ClientMessage(OtherCoopPawn.OwnerName$" is healing you.");
							OtherCoopPawn.ClientMessage("You are healing: "$myCoopPawn.OwnerName);
							///steam 20/11/2016 break added
							break;
						}
					}
					fCheckHelpTime = Level.TimeSeconds + 0.31;
				}
			}
		}
		else if( !bLockDead )
		{
			///steam 07/01/2016
			TimerLockDead = 0;

			///steam 10/04/2016
			if( bLockMatinee )
			{
				if( myCoopPlayer != None )
					myCoopPlayer.SetBlockPlayerInput(true, false);
				SetLockMatinee();
			}
			else
			{
				SetUnLockMatinee();
				if( myCoopPlayer != None )
					myCoopPlayer.SetBlockPlayerInput(false, false);
			}
			SetLocation(myCoopPawn.Location);

			///steam 19/12/2018 update
			if( myCoopPawn.Physics == PHYS_Walking )
			{
				if( Level.TimeSeconds > LastAliveTime )
					LastAlivePos = Location;
			}
			else LastAliveTime = Level.TimeSeconds + 1.0;

			if( bCollideActors )
			{
				SetCollision(false);
				ForcePlayerRevived();
			}

			if( DeadFX != None )
			{
				DeadFX.Destroy();
				DeadFX = None;
			}

			///steam 28/07/2017
			if( bCoopDedicatedHost )
			{
				if( bLockMatinee )
				{
					if( myCoopPawn.bHidden )
						myCoopPawn.bHidden = false;
				}
				else
				{
					if( !myCoopPawn.bHidden )
						myCoopPawn.bHidden = true;
					if( myCoopPawn.bCollideActors )
					{
						myCoopPawn.SetCollision(false,false,false);
						myCoopPawn.bProjTarget = false;
					}
				}
			}
		}
	}
	else
	{
		if( DeadFX != None )
		{
			DeadFX.Destroy();
			DeadFX = None;
		}
		myCoopPawn = None;
	}
}

///steam 02/08/2016
simulated event FellOutOfWorld()
{
	///STUBED
}

///steam 20/11/2016
simulated function ForcePlayerDied()
{
	myCoopPawn.Health = 0;
	myCoopPawn.SetLocation(Location);
	myCoopPawn.SetCollision(false,false,false);
	myCoopPawn.bCoopPlayerDied = true;
	myCoopPawn.Acceleration = vect(0,0,0);
	myCoopPawn.Velocity = vect(0,0,0);
	myCoopPawn.SetPhysics(PHYS_None);
	///steam 20/11/2016
	if( myCoopPlayer != None )
		myCoopPlayer.xCallCoopStopFiring();
	///steam 15/05/2016
	if( CoopGameInfo(Level.Game) != None )
		CoopGameInfo(Level.Game).CoopCheckLevelGameOver();
}

///steam 20/11/2016
simulated function ForcePlayerRevived()
{
	myCoopPawn.bCoopPlayerDied = false;
	myCoopPawn.SetCollision(myCoopPawn.default.bCollideActors,myCoopPawn.default.bBlockActors,myCoopPawn.default.bBlockPlayers);
}

///steam 19/12/2018 update
function NotifyCrushedDeath()
{
	if( LastAlivePos != vect(0,0,0) )
		SetLocation(LastAlivePos);
}

//steam UPD
defaultproperties
{
	TimerFrameTex(0)=Texture'NicksCoop.TimerHUD.coop_timer_frame00'
	TimerFrameTex(1)=Texture'NicksCoop.TimerHUD.coop_timer_frame01'
	TimerFrameTex(2)=Texture'NicksCoop.TimerHUD.coop_timer_frame02'
	TimerFrameTex(3)=Texture'NicksCoop.TimerHUD.coop_timer_frame03'
	TimerFrameTex(4)=Texture'NicksCoop.TimerHUD.coop_timer_frame04'
	TimerFrameTex(5)=Texture'NicksCoop.TimerHUD.coop_timer_frame05'
	TimerFrameTex(6)=Texture'NicksCoop.TimerHUD.coop_timer_frame06'
	TimerFrameTex(7)=Texture'NicksCoop.TimerHUD.coop_timer_frame07'
	TimerFrameTex(8)=Texture'NicksCoop.TimerHUD.coop_timer_frame08'

	bIgnoreOutOfWorld=true
	bSkipActorPropertyReplication=false
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'stuff.stuff1.Pistol'
	Skins(0)=Shader'Timb.Misc.invisible_mask'
	Physics=PHYS_Projectile
	bAlwaysRelevant=true
	bBlockActors=false
	bBlockNonZeroExtentTraces=false
	bBlockZeroExtentTraces=false
	bBlockPlayers=false
	bCollideActors=false//true
	bCollideWorld=false
	bReplicateMovement=true
	bAlwaysTick=true
	bReplicateInstigator=true
	bGameRelevant=true
	bMovable=true
	bStasis=false
	bWorldGeometry=false
	bNoDelete=false
	bHidden=false
	Mass=0.0
	CollisionRadius=100.0
	CollisionHeight=72.0
}