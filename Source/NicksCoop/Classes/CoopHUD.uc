//=============================================================================
// CoopHUD.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

#EXEC OBJ LOAD FILE="ImportOBJs\NicksCoopTex.utx" Package=NicksCoop
#EXEC OBJ LOAD FILE="ImportOBJs\NicksCoopAnims.ukx" Package=NicksCoop

class CoopHUD extends AWWrapHUD;//MpHUD;

///steam 20/07/2016 debug
var bool xCoopDebugEnabled;
var vector xCoopDebugLocation;
var string xCoopDebugString;
///steam 20/07/2016 debug

var PlayerReplicationInfo		PawnOwnerPRI;
var float						IdentityFadeTime;
var float						IdentityFadeDuration;
var CoopPlayerReplicationInfo	IdentityTarget;
var float						IdentityInfoPY;
var float						IdentityHealthPW;
var float						IdentityHealthPH;
var float						IdentityBorderPS;
var float						LastTime;
var float						CurrentDeltaTime;
var localized string			ViewFrom;
var bool						bPlayersSorted;

var vector vTeleportPawn;

var Texture CoopPlayerIndicatorIcon;
var Texture WaitIcon;

var float CoopPlayerIndicatorScale;

///steam 15/05/2016
var int CoopLevelStatus;
var localized string CoopGameOverMessage1;
var localized string CoopGameOverMessage2;
var localized string CoopDeadMessage1;
var localized string CoopDeadMessage2;
var localized string CoopWaitPlayersMessage1;
var localized string CoopWaitPlayersMessage2;

///steam 29/05/2016
var float CoopBlinkTime;
var bool bCoopBlink;

///steam 01/08/2016
var bool bCoopForceHideHUD;

///steam 20/11/2016
var float fTrackingPawnsTime;
var array<Object> TrackingPawnsArr;
///steam 30/10/2017 - TrackingPawnsArr removed
///steam 05/11/2017 - TrackingPawnsArr returned

var Material CoopWantedIcon;
var Material CoopWantedBar;

///steam 15/05/2016 changed to GetStatus
simulated function int GetCoopLevelStatus()
{
	if( OurPlayer != None 
		&& OurPlayer.GameReplicationInfo != None 
		&& CoopGameReplicationInfo(OurPlayer.GameReplicationInfo) != None )
	{
		if( CoopGameReplicationInfo(OurPlayer.GameReplicationInfo).bCoopLevelLoading )
			return 1;
		else if( CoopGameReplicationInfo(OurPlayer.GameReplicationInfo).bCoopLevelGameOver )
			return 2;
		else if( CoopGameReplicationInfo(OurPlayer.GameReplicationInfo).bCoopWaitPlayers )
			return 3;
	}
	return 0;
}

///steam 01/08/2016
simulated function DrawLoadingIndicator(Canvas Canvas, bool bOnlyIndicator)
{
	local CoopShellRootWindow PlayerRootMenu;

	if( OurPlayer != None )
	{
		PlayerRootMenu = CoopShellRootWindow(OurPlayer.Player.InteractionMaster.BaseMenu);
		if( PlayerRootMenu != None )
			PlayerRootMenu.DrawMainStatusMessage(Canvas, bOnlyIndicator);
	}
}

simulated function DrawCanvasText(Canvas C, string str, float X, float Y, int Pos, float Size, int FontType, optional byte SetColor, optional color NewColor)
{
	local float XL, YL;
	local float lScale;

	lScale = FClamp(C.ClipY/1024,0.4,1);

	if( lScale <= 0.5 )
	{
		lScale = 1.0;
		FontType = 0;
	}

	if( FontType == 0 )
		C.Font = C.SmallFont;
	else C.Font = C.MedFont;

	C.FontScaleX  = C.default.FontScaleX*Size * lScale;
	C.FontScaleY  = C.default.FontScaleY*Size * lScale;

	if (Pos != -1)
	{
		if (Pos == 1)//right
		{
			C.StrLen(str, XL, YL);
			X -= XL;
		}
		else if (Pos == 2)//center
		{
			C.StrLen(str, XL, YL);
			X -= (XL / 2);
		}
	}

	C.Style = ERenderStyle.STY_Alpha;
	C.SetDrawColor(25,25,25,180);

	C.bCenter = false;
	C.SetPos(X+2.0, Y+2.0);
	C.DrawText(str, false);

	if( SetColor == 1 )
	{
		C.DrawColor.R = NewColor.R;
		C.DrawColor.G = NewColor.G;
		C.DrawColor.B = NewColor.B;
		C.DrawColor.A = 255;
	}
	else C.SetDrawColor(255,255,255,255);

	if( FontType == 0 )
		C.Font = C.SmallFont;
	else C.Font = C.MedFont;

	C.SetPos(X, Y);
	C.DrawText(str, false);
}

simulated function HUDSetup(canvas canvas)
{
	Super.HUDSetup(Canvas);
	
	if (OurPlayer == None)
		PawnOwnerPRI = None;
	else if ((PawnOwner != None) && (PawnOwner.Controller != None))
		PawnOwnerPRI = PawnOwner.PlayerReplicationInfo;
	else
		PawnOwnerPRI = OurPlayer.PlayerReplicationInfo;
	
	CurrentDeltaTime = Level.TimeSeconds - LastTime;
	LastTime = Level.TimeSeconds;
}

simulated function NETDrawPlayerWantedStatus(canvas Canvas, float Scale)
{
	local Texture usetex;
	local float radiopct;
	local float BarH, BarW;
    local float backgroundPosX,backgroundPosY;
	local bool bCoopWanted;

	if( CoopGameReplicationInfo(OurPlayer.GameReplicationInfo) != None )
	{
		// Get a number from 0 to 1.0 for how much the cops want the player
		radiopct = CoopGameReplicationInfo(OurPlayer.GameReplicationInfo).CopRadioTime / 200;

		if(radiopct > 0)
		{
			// Draw background wanted symbol
			Canvas.Style = ERenderStyle.STY_Masked;
			Canvas.DrawColor = DefaultIconColor;

			bCoopWanted = (CoopPostalDude(PawnOwner) != None && CoopPostalDude(PawnOwner).CoopWantedStatus > 0);
			if( bCoopWanted )
				usetex = Texture(WantedIcon);
			else usetex = Texture(CoopWantedIcon);

			///steam 01/09/2017 - 5022 build fix
			BackgroundPosX = (IconPos[WantedIndex].X*Canvas.ClipX) - (Scale*(usetex.USize / 2));
			BackgroundPosY = (IconPos[WantedIndex].Y*CanvasHeight) - (Scale*(usetex.VSize / 2));
			///backgroundPosX = UltraWideOffsetX + IconPos[WantedIndex].X*CanvasWidth - Scale*(usetex.USize/2);
            ///backgroundPosY = IconPos[WantedIndex].Y*CanvasHeight - Scale*(usetex.VSize/2);

			Canvas.SetPos(
				backgroundPosX,
				backgroundPosY);
			Canvas.DrawIcon(usetex, Scale);

			// Draw the bar showing how much he's still wanted
			Canvas.Style = ERenderStyle.STY_Masked;
			if( bCoopWanted )
			{
				radiopct = CoopPostalDude(PawnOwner).CoopWantedStatus / 200;
				usetex = Texture(WantedBar);
			}
			else usetex = Texture(CoopWantedBar);

			BarH = usetex.VSize;
			BarW = (radiopct*HUD_WANTED_BAR_SCALE_WIDTH*Texture(WantedIcon).USize);

			Canvas.SetPos(
                (backgroundPosX) + ((Texture(WantedIcon).USize*scale) * HUD_WANTED_BAR_OFF_X),
                (backgroundPosY) + ((Texture(WantedIcon).VSize*scale) * HUD_WANTED_BAR_OFF_Y));
			Canvas.DrawTile(usetex,
				Scale*BarW,
				Scale*BarH,
				0, 0, usetex.USize, usetex.VSize);
		}
	}
}

simulated function DrawPlayerWantedStatus(canvas Canvas, float Scale)
{
	local Texture usetex;
	local float radiopct;
	local float BarH, BarW;
    local float backgroundPosX,backgroundPosY;
	local bool bCoopWanted;

	if(P2GameInfoSingle(Level.Game).TheGameState != None)
	{
		// Get a number from 0 to 1.0 for how much the cops want the player
		radiopct = P2GameInfoSingle(Level.Game).TheGameState.CopsWantPlayer();

		if(radiopct > 0)
		{
			// Draw background wanted symbol
			Canvas.Style = ERenderStyle.STY_Masked;
			Canvas.DrawColor = DefaultIconColor;

			bCoopWanted = (CoopPostalDude(PawnOwner) != None && CoopPostalDude(PawnOwner).CoopWantedStatus > 0);
			if( bCoopWanted )
				usetex = Texture(WantedIcon);
			else usetex = Texture(CoopWantedIcon);

		//ErikFOV Change: Nick's HUD fix
			BackgroundPosX = (IconPos[WantedIndex].X*Canvas.ClipX) - (Scale*(usetex.USize / 2));
			BackgroundPosY = (IconPos[WantedIndex].Y*CanvasHeight) - (Scale*(usetex.VSize / 2));
			/*backgroundPosX = UltraWideOffsetX + IconPos[WantedIndex].X*CanvasWidth - Scale*(usetex.USize/2);
            backgroundPosY = IconPos[WantedIndex].Y*CanvasHeight - Scale*(usetex.VSize/2);*/
		//end
			Canvas.SetPos(
				backgroundPosX,
				backgroundPosY);
			Canvas.DrawIcon(usetex, Scale);

			// Draw the bar showing how much he's still wanted
			Canvas.Style = ERenderStyle.STY_Masked;
			if( bCoopWanted )
			{
				radiopct = CoopPostalDude(PawnOwner).CoopWantedStatus / 200;
				usetex = Texture(WantedBar);
			}
			else usetex = Texture(CoopWantedBar);

			BarH = usetex.VSize;
			BarW = (radiopct*HUD_WANTED_BAR_SCALE_WIDTH*Texture(WantedIcon).USize);

			Canvas.SetPos(
                (backgroundPosX) + ((Texture(WantedIcon).USize*scale) * HUD_WANTED_BAR_OFF_X),
                (backgroundPosY) + ((Texture(WantedIcon).VSize*scale) * HUD_WANTED_BAR_OFF_Y));
			Canvas.DrawTile(usetex,
				Scale*BarW,
				Scale*BarH,
				0, 0, usetex.USize, usetex.VSize);
		}
	}
}

simulated event PostRender( canvas Canvas )
{
	local HUD H;

	///steam 22/11/2016
	if( OurPlayer != None && CoopPlayerController(OurPlayer) != None )
	{
		if( CoopPlayerController(OurPlayer).RenderNETStatsInfo(Canvas, MyFont) )
			return;
	}
	///steam 01/08/2016
	if( bCoopForceHideHUD )
		return;
	CoopLevelStatus = GetCoopLevelStatus();
	if( AllowSuperPostRender(Canvas) )
	{
		///Super.PostRender(Canvas);

		///steam 25/07/2017 - fixed shit from update 5022
		// If there's an active screen, check to see if it wants the hud
		// If there's a root window running then never show the hud
		if ((OurPlayer.CurrentScreen == None || OurPlayer.CurrentScreen.ShouldDrawHUD()) && !AreAnyRootWindowsRunning())
			{
			if ( !PlayerOwner.bBehindView )
				{
				// Draw your foot in now
				if ( (PawnOwner != None) && (PawnOwner.MyFoot != None) )
					PawnOwner.MyFoot.RenderOverlays(Canvas);
				}

			// Do rest of weapons and hud
			Super(FPSHUD).PostRender(Canvas);

			// Give game info a chance to show debug stuff
			if (P2GameInfoSingle(Level.Game) != None)
				P2GameInfoSingle(Level.Game).RenderOverlays(Canvas);
			}

		// Display text saying who this version was issued to
		DrawIssuedToText(Canvas);

		//ErikFOV Change: Subtitle system
		if (OurPlayer.CurrentScreen == None && OurPlayer.bEnableSubtitles && SubBoxSize > 0 && (!bHideHUD || OurPlayer.ViewTarget != OurPlayer.Pawn))
		{
			DrawSubtitles(Canvas); //
		}
		//end
		
		// Global conditions for drawing any IGT.
		if( Level.Game != None && !P2GameInfoSingle(Level.Game).bNeverDrawTime )
		{	
			// Draw normal IGT only when the clock is running.
			if (!P2GameInfoSingle(Level.Game).bStrictTime
				&& (OurPlayer.CurrentScreen == None || OurPlayer.CurrentScreen.ShouldDrawHUD())
				&& !AreAnyRootWindowsRunning()
				&& PawnOwner != None
				&& PawnOwner.Health > 0
				&& Level.Pauser == None
				&& P2GameInfoSingle(Level.Game).TheGameState != None
				&& !PlayerOwner.IsInState('PlayerPrepSave')
				)
			{
				DrawTimeOnScreen(Canvas);
			}
			// Draw strict timer always
			else if (P2GameInfoSingle(Level.Game).bStrictTime
				&& P2GameInfoSingle(Level.Game).TheGameState != None
				&& !IsMainMenuRunning())
			{
				DrawTimeOnScreen(Canvas);
			}
			// If time is called, draw the timer regardless.
			else if (P2GameInfoSingle(Level.Game).TheGameState != None
				&& P2GameInfoSingle(Level.Game).TheGameState.TimeStop != vect(0,0,0))
			{
				DrawTimeOnScreen(Canvas);
			}
		}
		DrawAchievements(Canvas);
		///steam 25/07/2017 - fixed shit from update 5022

		//steam 06/08/2018 - fixed ability to watch score/messages while movies
		if( CoopLevelStatus == 3 
			|| IsMatineeActiveForViewport() )
		{
			if( TextureMovie != None 
				&& TextureMovie.Movie != None 
				&& TextureMovie.Movie.IsPlaying() )
				DisplayMessages(Canvas);
			if( bShowScores && bPlayersSorted && MpScoreboard(Scoreboard) != None )
				MpScoreboard(Scoreboard).DrawScoreboard(Canvas);
		}
	}
	///else Super(HUD).PostRender(Canvas);
	DrawCoopLevelStatus(Canvas);
}

function bool IsMatineeActiveForViewport()
{
	if( OurPlayer != None && OurPlayer.ViewTarget != None )
		return ( OurPlayer.ViewTarget.bInterpolating || OurPlayer.ViewTarget.IsA('CoopMatineeCamera') );
	return false;
}

///steam 07/09/2018 - rendering subs over the client map
function ClientForceDrawSubs(Canvas Canvas)
{
	if( OurPlayer.bEnableSubtitles && SubBoxSize > 0 && (!bHideHUD || OurPlayer.ViewTarget != OurPlayer.Pawn) )
	{
		DrawSubtitles(Canvas);
	}
}

simulated function bool DrawPlayerStatus(canvas Canvas, optional bool bCriticalInfoOnly)
{
	local bool bDisplayOtherStuff;
	local P2GameInfo p2g;
	local int viewstate;

	// If we're getting ready to commit suicide, display this helpful hint
	// and don't show any of the other hud stuff
	if(OurPlayer.IsReadyToCommitSuicide())
		DrawSuicideHints(canvas);
	else
		{
		// Make sure there's a pawn
		if(PawnOwner != None
			&& (OurPlayer.ViewTarget != OurPlayer.Pawn || !OurPlayer.bBehindView))
			{
			p2g = P2GameInfo(Level.Game);

			//if (p2g != None)
			DrawHurtBars(Canvas, Scale);
			DrawSniperBars(Canvas, Scale);

			// Handle drawing the various swirling hud effects
			// usually only from head injury situations.
			if(StartActive != 0)
				DrawSwirl(canvas, startinjuries);
			if(WalkActive != 0)// || CoopPlayerController(OurPlayer).bClientHeadInjury) this is actually not working on clients
				DrawSwirl(canvas, walkinjuries);
			if(StopActive != 0)
				DrawSwirl(canvas, stopinjuries);
			// Have the head injury effects override the gary effects
			if(StartActive == 0
				&& WalkActive == 0
				&& StopActive == 0
				&& GaryActive != 0)
				DrawSwirl(canvas, garyeffects);

			if (!bCriticalInfoOnly)
				{
				// If we're focussed on the player, provide his full hud
				if(OurPlayer.ViewTarget == OurPlayer.Pawn)
					{
					viewstate = OurPlayer.HudViewState;

					if( viewstate > 0 )
					{
						if( P2GameInfoSingle(Level.Game) != None )
							DrawPlayerWantedStatus(Canvas, Scale);
						else if( OurPlayer.Buoyancy != 75 )
							NETDrawPlayerWantedStatus(Canvas, Scale);
					}
					if( viewstate > 0 )
						DrawHealthAndArmor(Canvas, Scale);
					if( viewstate > 1 )
						DrawWeapon(Canvas, Scale);
					if( viewstate > 2 )
						DrawInventory(Canvas, Scale);
					//if (OurPlayer.KillJobs.Length > 0)
						DrawKillJobs(Canvas, Scale);
					/*
					if(KillIcon != None)
						DrawKillCount(Canvas, Scale);
					else if(BossIcon != None)
						DrawBossHealth(Canvas, Scale);
					*/
					if( CoopLevelStatus == 0 
						&& PawnOwner != None 
						&& CoopPostalDude(PawnOwner) != None 
						&& CoopPostalDude(PawnOwner).bCoopPlayerDied )
						DrawCoopDeadStatus(Canvas, CoopDeadMessage1, CoopDeadMessage2);
					}

				// Put up helpful hints about viewing a rocket as it travels
				// if we're watching the rocket
				if(OurPlayer.IsInState('PlayerWatchRocket'))
					{
					DrawRocketHints(canvas);
					}
				else// Give the radar chance only if we're not driving a rocket
					{
					// Give the radar a chance to draw, it will decide
					// whether or not to draw the full image
					if(OurPlayer.ShowRadarAny())
						DrawRadar(Canvas, Scale);
					}
				}

			// Indicate that other hud stuff should be displayed
			bDisplayOtherStuff = true;
			}
		}

	return bDisplayOtherStuff;
}

///steam 02/05/2016
function DrawKillJobs(Canvas Canvas, float Scale)
{
	local int UseMax, UseCount, idx;
    local float backgroundPosX, backgroundPosY, BarLength, BarHeight;
	local bool bPercentageDisplay;
	local float UseScale;

	local CoopGameReplicationInfo myReplicaInfo;
	local Texture UseTex;

	if( OurPlayer.Buoyancy == 75 )
	{
		if( OurPlayer.KillJobs.Length > 0 )
			Super.DrawKillJobs(Canvas, Scale);
		return;
	}

	myReplicaInfo = CoopGameReplicationInfo(OurPlayer.GameReplicationInfo);

	if( myReplicaInfo == None )
		return;

	// Loop through all kill jobs.
	for( idx = 0 ; idx < myReplicaInfo.KillJobsLength ; idx++ )
	{
		// Get values for this kill job from the player
		//OurPlayer.GetKillJobValues(idx, UseCount, UseMax, bPercentageDisplay);
		UseCount = myReplicaInfo.KillJobs[idx].UseCount;
		UseMax = myReplicaInfo.KillJobs[idx].UseMax;
		UseTex = myReplicaInfo.KillJobs[idx].HUDIcon;
		bPercentageDisplay = myReplicaInfo.KillJobs[idx].bPercentageDisplay;
		
		// Willow bar
		if (myReplicaInfo.KillJobs[idx].bWillow)
		{
			// Draw percentage bar
			backgroundPosX = CanvasWidth / 2;
			backgroundPosY = (KillPos.Y + HUD_BACKGROUND_Y_OFFSET + KillOffset.Y * idx)*CanvasHeight;			
			BarLength = CanvasWidth / 2.5;
			BarHeight = CanvasHeight / 70.0;
			DrawPercBarDebug(Canvas, backgroundPosX, backgroundPosY, BarLength, BarHeight, 1, RedColor, Float(UseCount)/Float(UseMax), true);
			MyFont.TextColor = WhiteColor;
			MyFont.DrawTextEx(Canvas, CanvasWidth, (backgroundPosX) + (CanvasWidth / 200) - (BarLength / 2), (backgroundPosY) + (BarHeight / 10), myReplicaInfo.KillJobs[idx].WillowText, 0);
			MyFont.TextColor = RedColor;
		}
		else
		{		
			// Offset icon based on index count
			backgroundPosX = UltraWideOffsetX + (KillPos.X + HudBackgroundXOffset + KillOffset.X * idx)*CanvasWidth;
			backgroundPosY = (KillPos.Y + HUD_BACKGROUND_Y_OFFSET + KillOffset.Y * idx)*CanvasHeight;

			// Draw background.
			Canvas.Style = ERenderStyle.STY_Masked;
			Canvas.DrawColor = DefaultIconColor;
			Canvas.SetPos(
				backgroundPosX,
				backgroundPosY);
			Canvas.DrawIcon(KillBkgd, Scale);
			
			UseScale = 64.0 / UseTex.VSize;

			// Draw icon of pawn/kill goal
			Canvas.SetPos(
				// If you should shake, add it here.
				(backgroundPosX) + ((KillBkgd.USize*scale) / 4) + (myReplicaInfo.KillJobs[idx].ShakeKillTime*(FRand() - 0.5)*SHAKE_MOD*CanvasWidth),
				(backgroundPosY) + ((KillBkgd.VSize*scale) / 8) + (myReplicaInfo.KillJobs[idx].ShakeKillTime*(FRand() - 0.5)*SHAKE_MOD*CanvasHeight));
			Canvas.DrawIcon(UseTex, UseScale*Scale);
			
			if (bPercentageDisplay)
			{
				// draw percentage display
				MyFont.DrawTextEx(Canvas, CanvasWidth,
					(backgroundPosX) + (KillBkgd.USize*scale /1.5) + HUD_NUMBERS_KILL_OFFSET_X,
					(backgroundPosY) + (KillBkgd.VSize*scale /1.5) + HUD_NUMBERS_OFFSET_Y,
					""$Int(100.0 * Float(UseCount) / Float(UseMax))$"%", 2);
			}
			else
			{
				// draw text showing number and max to reach
				MyFont.DrawTextEx(Canvas, CanvasWidth,
					(backgroundPosX) + (KillBkgd.USize*scale /1.5) + HUD_NUMBERS_KILL_OFFSET_X,
					(backgroundPosY) + (KillBkgd.VSize*scale /1.5) + HUD_NUMBERS_OFFSET_Y,
					""$UseCount$"/"$UseMax, 2);
			}
		}
	}
}

///steam 20/07/2016 debug
simulated function xCoopDebugHUD(Canvas Canvas)
{
	local vector DrawPos, CamPos;
	local rotator CamRot;
	local string str;
	local float XL, YL;

	if( OurPlayer == None )
		return;

	if( xCoopDebugEnabled )
	{
		Canvas.GetCameraLocation(CamPos, CamRot);
		if( CoopWorldToScreen(DrawPos, CamPos, CamRot, xCoopDebugLocation, Canvas) )
		{
			Canvas.Style = 	ERenderStyle.STY_Alpha;
			Canvas.bCenter = false;
			Canvas.Font = MyFont.GetFont(0, true, Canvas.ClipX);
			Canvas.SetDrawColor(255,255,255,255);
			str = "xCoopDebug:"@xCoopDebugString;
			Canvas.StrLen(str, XL, YL);
			Canvas.SetPos(DrawPos.X-(XL*0.5), DrawPos.Y);
			Canvas.DrawText(str);
		}
	}
}

simulated function DrawHUD( canvas Canvas )
{
	local bool bCoopSpectator;

	///steam 20/07/2016 debug
	xCoopDebugHUD(Canvas);

	// Draw special hud messages regardless of whether hud is hidden
	DrawHudMsgs(Canvas);

	// Setup hud (also allows super to set itself up)
	HUDSetup(Canvas);

	// Lots of things rely on the scoreboard updating the GRI so do this first
	bPlayersSorted = false;
	if (MpScoreboard(Scoreboard) != None)
		bPlayersSorted = MpScoreboard(Scoreboard).UpdateGRI();

	///steam 30/06/2017 - hack to fix DrawLocalMessages while client scene watching
	if( CoopPlayerController(OurPlayer) != None && CoopPlayerController(OurPlayer).bClientWatchScene )
	{
		if( bHideHUD )
			DrawLocalMessages(Canvas);
	}

		if (!bHideHUD && (PawnOwnerPRI != None))
		{
			// Display scoreboard when requested
			if (bShowScores && bPlayersSorted)
			{
				MpScoreboard(Scoreboard).DrawScoreboard(Canvas);

				// Only draw critical portions of normal hud
				if (!PawnOwnerPRI.bIsSpectator && (PawnOwner != None))
					DrawPlayerStatus(Canvas, true);
			}
			else
			{
				bCoopSpectator = false;
				// If we're viewing a pawn other than our own then say who it is
				if ( Pawn(PlayerOwner.ViewTarget) != None && Pawn(PlayerOwner.ViewTarget) != PlayerOwner.Pawn && Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo != None)
				{
					DrawViewFrom(Canvas, Pawn(PlayerOwner.ViewTarget).PlayerReplicationInfo, MpScoreboard(Scoreboard).MatchStatusPY * Canvas.ClipY);
					bCoopSpectator = true;
				}

				// Draw local messages
				DrawLocalMessages(Canvas);

				// Perform player tracking
				//DrawPawnTrackers(Canvas);
				
				// Specators don't get to see this stuff
				if (!PawnOwnerPRI.bIsSpectator)
				{
					if (PawnOwner != None)
					{
						// Draw player status (health/armor, weapons/ammo, inventory, suicide)
						DrawPlayerStatus(Canvas);
						///steam 15/05/2016 moved to DrawPlayerStatus
						///if( OurPlayer.Buoyancy != 75 )
						///	NETDrawPlayerWantedStatus(Canvas, Scale);
						if( CoopPlayerController(OurPlayer).bShowCoopPlayers && !bCoopSpectator )
							DrawCoopPlayers(Canvas);
					}

					// Draw match score
					//DrawMatchScore(Canvas, MatchScorePY * Canvas.ClipY);
				}

				if( !CoopPlayerController(OurPlayer).bShowCoopPlayers && !OurPlayer.bBehindView )
				{
					// If looking at a pawn, draw it's ID
					if ( (Canvas.ClipY > 320) && TraceIdentity(Canvas) )
						DrawIdentityInfo(Canvas, IdentityTarget);
				}

				// Notify player about remaining time
				//NotifyRemainingTime();

				// Have scoreboard draw critical status info
				if (MpScoreboard(Scoreboard) != None)
				{
					MpScoreboard(Scoreboard).DrawMatchStatus(Canvas, MpScoreboard(Scoreboard).MatchStatusPY * Canvas.ClipY, true);
					MpScoreboard(Scoreboard).DrawMatchHint(Canvas, MpScoreboard(Scoreboard).MatchHintPY * Canvas.ClipY, true);
				}
			}
		}
	///if( OurPlayer.bEnableSubtitles && SubBoxSize > 0 )
	///	DrawSubtitles(Canvas);
}

simulated function Tick(float DeltaTime)
{
	///local int i;

	Super.Tick(DeltaTime);

	if( Level.TimeSeconds > CoopBlinkTime )
	{
		bCoopBlink = !bCoopBlink;
		CoopBlinkTime = Level.TimeSeconds + 0.5;
	}

	IdentityFadeTime = FMax(0.0, IdentityFadeTime - DeltaTime);
}

///////////////////////////////////////////////////////////////////////////////
// Identify the pawn the player is looking at.
// Returns true if a pawn was found, false otherwise.
///////////////////////////////////////////////////////////////////////////////
simulated function bool TraceIdentity(canvas Canvas)
{
	local actor Other;
	local vector HitLocation, HitNormal, StartTrace, EndTrace;

	if ( (PawnOwner == None) || (PawnOwner != PlayerOwner.Pawn) )
		return false;

	StartTrace = PawnOwner.Location;
	StartTrace.Z += PawnOwner.BaseEyeHeight;
	EndTrace = StartTrace + vector(PlayerOwner.Rotation) * 2048.0;
	Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
	
	if ( IdentityFadeTime == 0.0 )
		IdentityTarget = None;

	if ( Pawn(Other) != None )
	{
		if ( (Pawn(Other).PlayerReplicationInfo != None) && !Other.bHidden )
		{
			if( CoopPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo) != None 
				&& !CoopPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).bCoopDedicatedHost )
			{
				IdentityTarget = CoopPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo);
				IdentityFadeTime = IdentityFadeDuration;
			}
		}
	}
	else if ( (Other != None) && SpecialIdentity(Canvas, Other) )
		return false;

	if ( (IdentityFadeTime == 0.0) || (IdentityTarget == None) || (IdentityTarget.PlayerName == "") )
		return false;

	return true;
}

///////////////////////////////////////////////////////////////////////////////
// Draw info for specified pawn
///////////////////////////////////////////////////////////////////////////////
/*simulated function DrawPawnInfo(Canvas canvas, float screenX, float screenY, pawn P)
{
	local vector DrawPos, CamPos;
	local rotator CamRot;
	local string str;

	if( P == None 
		|| OurPlayer == None )
		return;

	Canvas.GetCameraLocation(CamPos, CamRot);
	if( CoopWorldToScreen(DrawPos, CamPos, CamRot, P.Location, Canvas) )
	{
		Canvas.Style = 	ERenderStyle.STY_Alpha;
		Canvas.bCenter = false;
		Canvas.Font = MyFont.GetFont(0, true, Canvas.ClipX);

		str = MpPlayerReplicationInfo(P.PlayerReplicationInfo).PlayerName;
		//Canvas.StrLen(str, XL, YL);
		Canvas.SetPos(DrawPos.X, DrawPos.Y);
		Canvas.DrawText(str);
	}
}*/

///////////////////////////////////////////////////////////////////////////////
// Draw Identity info
///////////////////////////////////////////////////////////////////////////////
simulated function DrawIdentityInfo(canvas Canvas, MpPlayerReplicationInfo PRI)
{
	local float Y, XL, YL;
	local string str;
	local float Fade;
	local float Perc;

	str = PRI.PlayerName;

	Y = Canvas.ClipY * IdentityInfoPY;

	Canvas.DrawColor = MyFont.TextColor;

	Fade = IdentityFadeTime / IdentityFadeDuration;
	Canvas.DrawColor.A = FClamp(Fade * 128, 1, 255);
	if( Canvas.DrawColor.A > 1 )
	{
		Canvas.Style = 	ERenderStyle.STY_Alpha;
		Canvas.bCenter = false;
		Canvas.Font = MyFont.GetFont(0, true, Canvas.ClipX);

		Canvas.StrLen(str, XL, YL);
		Canvas.SetPos((Canvas.ClipX - XL)/2, Y);
		Canvas.DrawText(str);

		//if(Controller(PRI.Owner) != None && Controller(PRI.Owner).Pawn != None)
		if( CoopPlayerReplicationInfo(PRI) != None )
		{
			Perc = FClamp(CoopPlayerReplicationInfo(PRI).NETHealth / 100.0, 0.01, 1.0);
			//if (Perc > 1.0)
			//	Perc = 1.0;
			DrawPercBar(Canvas, Canvas.ClipX/2, Y + (YL * 1.25), Canvas.ClipX * IdentityHealthPW, Canvas.ClipY * IdentityHealthPH, Canvas.ClipX * IdentityBorderPS, Canvas.DrawColor, Perc);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// Check if it's a special identity
///////////////////////////////////////////////////////////////////////////////
simulated function bool SpecialIdentity(Canvas Canvas, Actor Other )
{
	return false;
}

///////////////////////////////////////////////////////////////////////////////
// Issue new orders to the currently identified bot
///////////////////////////////////////////////////////////////////////////////
exec function Order( name NewOrders )
{
	if ( (IdentityTarget == None) || (Bot(IdentityTarget.Owner) == None) )
		return;

	// FIXME - need to replicate orders to server
	Bot(IdentityTarget.Owner).SetOrders(NewOrders,PlayerOwner);
}

///////////////////////////////////////////////////////////////////////////////
// Draw percentage bar
///////////////////////////////////////////////////////////////////////////////
simulated function DrawPercBar(Canvas Canvas, float ScreenX, float ScreenY, float Width, float Height, float Border, Color Fore, float Perc)
{
	local float InnerWidth;
	local float InnerHeight;
	local color BarColor;

	Canvas.Style = ERenderStyle.STY_Alpha;

	/*Canvas.SetPos(ScreenX - (Width/2), ScreenY);
	Canvas.SetDrawColor(0,0,0,byte(float(Fore.A)*0.75));
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width, Height);

	InnerWidth = Width - 2 * Border;
	InnerHeight = Height - 2 * Border;

	Canvas.SetPos(ScreenX - (InnerWidth/2), ScreenY + Border);
	Canvas.DrawColor = Fore;
	if (Canvas.DrawColor.A > 0)
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', InnerWidth * Perc, InnerHeight);*/

	BarColor.A = Fore.A;
	Canvas.SetPos(ScreenX - (Width/2), ScreenY);
	Canvas.DrawColor = BarColor;
	if( Canvas.DrawColor.A > 1 )
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width, Height);

	InnerWidth = Width - 2 * Border;
	InnerHeight = Height - 2 * Border;

	BarColor.R = 255;
	BarColor.G = 255;

	Canvas.SetPos(ScreenX - (Width/2), ScreenY);
	Canvas.DrawColor = BarColor;
	if( Canvas.DrawColor.A > 1 )
		Canvas.DrawRect(Texture'engine.WhiteSquareTexture', Width * Perc, Height);
}

///steam 13/08/2017 - use native WorldToScreen() instead of slow uscript
simulated function bool CoopWorldToScreen(out vector Result, vector CamPos, rotator CamRot, vector WorldLoc, Canvas Canvas)
{
	local vector Dir, X, Y;
	GetAxes(CamRot, Dir, X, Y);
	Dir *= (WorldLoc-CamPos) dot Dir;
	Result = Canvas.WorldToScreen(WorldLoc, CamPos, CamRot);
	return ( Dir dot vector(CamRot) > 0 
		&& Result.X == FClamp(Result.X, Canvas.OrgX, Canvas.ClipX) 
		&& Result.Y == FClamp(Result.Y, Canvas.OrgY, Canvas.ClipY) );
}

simulated function DrawViewFrom(canvas Canvas, PlayerReplicationInfo FromPRI, float Y)
{
	local float XL, YL;
	local string str;
	local float Perc;

	Canvas.Font = MyFont.GetFont(2, false, Canvas.ClipX);
	Canvas.bCenter = true;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = MpScoreboard(Scoreboard).GeneralTextColor;
	str = ViewFrom$FromPRI.PlayerName;
	Canvas.StrLen(str, XL, YL);
	Canvas.SetPos(0, Y - YL);
	MyFont.DrawText(Canvas, str);

	if( CoopPlayerReplicationInfo(FromPRI) != None )
	{
		Perc = FClamp(CoopPlayerReplicationInfo(FromPRI).NETHealth / 100.0, 0.01, 1.0);
		DrawPercBar(Canvas, Canvas.ClipX/2, Y + (YL*0.5), Canvas.ClipX * IdentityHealthPW, Canvas.ClipY * IdentityHealthPH, Canvas.ClipX * IdentityBorderPS, Canvas.DrawColor, Perc);
	}
}

simulated function DrawCoopPlayers(canvas Canvas)
{
	local int i, j;
	local string str;
	local float lScale, Perc, SPerc, XL, YL;
	local CoopGameReplicationInfo ReplicaInfo;
	local CoopPlayerReplicationInfo PRI;
	local vector CamPos, DrawLoc, AimDrawPos;
	local rotator CamRot;
	local CoopPostalDude OtherPawn;//steam UPD 27/07/2016 OtherPawn must be CoopPostalDude
	local vector PRINetLoc;

	ReplicaInfo = CoopGameReplicationInfo(OurPlayer.GameReplicationInfo);

	if( ReplicaInfo != None )
	{
		///steam 21/11/2016
		if( Level.TimeSeconds > fTrackingPawnsTime )///steam 20/11/2016
		{
			if( TrackingPawnsArr.Length > 0 )
			{
				TrackingPawnsArr.Remove(0,TrackingPawnsArr.Length);
				TrackingPawnsArr.Length = 0;
			}
			//TrackingPawnsArr.Remove(0,TrackingPawnsArr.Length);
			//TrackingPawnsArr.Length = 0;
			foreach DynamicActors(class'CoopPostalDude', OtherPawn)//steam UPD
			{
				if( !OtherPawn.bDeleteMe ///steam 29/07/2016
					&& OtherPawn.bPlayer 
					&& (PawnOwner != None && OtherPawn != PawnOwner) 
					&& OtherPawn.PlayerReplicationInfo != None )
				{
					if( CoopPlayerReplicationInfo(OtherPawn.PlayerReplicationInfo) != None 
						&& !CoopPlayerReplicationInfo(OtherPawn.PlayerReplicationInfo).bCoopDedicatedHost )
					{
						j = TrackingPawnsArr.Length;
						TrackingPawnsArr.Insert(TrackingPawnsArr.Length, 1.0);
						TrackingPawnsArr[j] = OtherPawn;
					}
				}
				///steam 05/11/2017
				///i++;
				///if( i > 1024 )
				///	break;
			}
			fTrackingPawnsTime = Level.TimeSeconds + 0.21;
		}
		///steam 30/10/2017 - TrackingPawnsArr removed
		///steam 05/11/2017 - TrackingPawnsArr returned
		///OurPlayer.ClientMessage("post cycle 1"@TrackingPawnsArr.Length);

		for( i = 0 ; i < ReplicaInfo.PRIArray.Length ; i++ )
		{
			PRI = CoopPlayerReplicationInfo(ReplicaInfo.PRIArray[i]);
			if( PRI != None 
				&& !PRI.bDeleteMe
				&& !PRI.bCoopDedicatedHost 
				&& !PRI.bOnlySpectator ///steam 09/08/2017
				&& PRI != PawnOwnerPRI )
			{
				PRINetLoc = PRI.NETLocation;
				for( j = 0 ; j < TrackingPawnsArr.Length ; j++ )
				{
					if( TrackingPawnsArr[j] != None 
						&& CoopPostalDude(TrackingPawnsArr[j]) != None 
						&& !CoopPostalDude(TrackingPawnsArr[j]).bDeleteMe )
					{
						OtherPawn = CoopPostalDude(TrackingPawnsArr[j]);
						if( OtherPawn.PlayerReplicationInfo != None 
							&& CoopPlayerReplicationInfo(OtherPawn.PlayerReplicationInfo) != None 
							&& OtherPawn.PlayerReplicationInfo == PRI )
						{
							PRINetLoc = OtherPawn.Location;
							break;
						}
					}
					else
					{
						TrackingPawnsArr.Remove(j, 1);
						j--;
					}
				}
				///steam 30/10/2017 - TrackingPawnsArr removed
				///steam 05/11/2017 - TrackingPawnsArr returned

				/**foreach DynamicActors(class'CoopPostalDude', OtherPawn)//steam UPD
				{
					if( OtherPawn != None 
						&& !OtherPawn.bDeleteMe ///steam 29/07/2016
						&& OtherPawn.bPlayer 
						&& (PawnOwner != None && OtherPawn != PawnOwner) 
						&& OtherPawn.PlayerReplicationInfo != None )
					{
						if( CoopPlayerReplicationInfo(OtherPawn.PlayerReplicationInfo) != None 
							&& !CoopPlayerReplicationInfo(OtherPawn.PlayerReplicationInfo).bCoopDedicatedHost
							&& OtherPawn.PlayerReplicationInfo == PRI )
						{
							PRINetLoc = OtherPawn.Location;
							break;
						}
					}
					i++;
					if( i > 1024 )
						break;
				}**/

				///OurPlayer.ClientMessage("post cycle 2"@TrackingPawnsArr.Length);
				Canvas.GetCameraLocation(CamPos, CamRot);
				if( CoopWorldToScreen(DrawLoc, CamPos, CamRot, PRINetLoc, Canvas) )
				{
					AimDrawPos.X = Canvas.ClipX * 0.5;
					AimDrawPos.Y = Canvas.ClipY * 0.5;

					///OurPlayer.ClientMessage(VSize(AimDrawPos-DrawLoc)@VSize(AimDrawPos-vTeleportPawn)@vTeleportPawn);

					if( CoopPlayerController(OurPlayer).sTeleportPawn == PRI.PlayerName )///steam 21/07/2016
						vTeleportPawn = DrawLoc;
					if( CoopPlayerController(OurPlayer).sTeleportPawn != PRI.PlayerName 
						&& VSize(AimDrawPos-DrawLoc) < VSize(AimDrawPos-vTeleportPawn) )
					{
						vTeleportPawn = DrawLoc;
						CoopPlayerController(OurPlayer).sTeleportPawn = PRI.PlayerName;
					}

					Canvas.bCenter = false;
					Canvas.Style = ERenderStyle.STY_Alpha;
					Perc = PRI.NETHealth / 100.0;
					SPerc = FClamp(1-((Perc*0.48)+0.25),0,1);
					lScale = (CoopPlayerIndicatorScale * Canvas.ClipY) / CoopPlayerIndicatorIcon.USize;
					lScale *= FClamp(500/(VSize(PRINetLoc-CamPos)),0.4,1.5);

					if( PRI.NETHealth > 0 && SPerc <= 0 )
						SPerc = 0.7452;

					if( !PRI.bCoopPlayerAFK )
						Canvas.SetDrawColor(255,255,255,255);
					else Canvas.SetDrawColor(225,225,225,255);
					//Canvas.DrawColor.B = 255;
					//Canvas.DrawColor.G = 255;
					Canvas.SetPos(DrawLoc.X - lScale*CoopPlayerIndicatorIcon.USize/2, DrawLoc.Y - lScale*CoopPlayerIndicatorIcon.VSize/2);
					Canvas.DrawIcon(CoopPlayerIndicatorIcon, lScale);

					Canvas.SetDrawColor(255,255,255,255);
					Canvas.DrawColor.B = 0;
					Canvas.DrawColor.G = 0;
					Canvas.SetPos(DrawLoc.X - lScale*CoopPlayerIndicatorIcon.USize/2, DrawLoc.Y - lScale*CoopPlayerIndicatorIcon.VSize/2);
					Canvas.DrawTile(CoopPlayerIndicatorIcon, CoopPlayerIndicatorIcon.USize*lScale, CoopPlayerIndicatorIcon.VSize*lScale*SPerc, 
						0, 0, CoopPlayerIndicatorIcon.USize, CoopPlayerIndicatorIcon.VSize*SPerc);//hui

					if( PRI.NETHealth > 0 )
						Perc = 1.0;
					else Perc = 0.0;

					Canvas.Style = ERenderStyle.STY_Normal;
					/**Canvas.SetDrawColor(255,255,255,64);
					Canvas.DrawColor.B = (255*Perc);
					Canvas.DrawColor.G = (255*Perc);
					Canvas.Draw3DLine(PawnOwner.Location, PRINetLoc);**/ ///steam 22/01/2018

					str = PRI.PlayerName;
					if( str == CoopPlayerController(OurPlayer).sTeleportPawn )
						Canvas.SetDrawColor(200,200,0,255);
					else Canvas.SetDrawColor(200,200,200,255);
					if( PRI.NETHealth <= 0 )
						Canvas.SetDrawColor(220,0,0,255);
					Canvas.Font = MyFont.GetFont(0, true, Canvas.ClipX);
					Canvas.StrLen(str, XL, YL);
					Canvas.SetPos(DrawLoc.X - XL/2, (DrawLoc.Y - YL/2)-((CoopPlayerIndicatorIcon.USize*0.32)*lScale));
					Canvas.DrawText(str);
				}
			}
		}
	}
}

///steam 15/05/2016
simulated function DrawCoopDeadStatus(canvas C, string s1, string s2)
{
	if( !AreAnyRootWindowsRunning() )
	{
		///same as DrawDeadMessage in P2HUD
		MyFont.DrawTextEx(
			C,
			CanvasWidth,
			UltraWideOffsetX + HUD_SUICIDE_TEXT_X * CanvasWidth,
			HUD_SUICIDE_TEXT_Y1 * CanvasHeight,
			s1,
			2, false, EJ_Center);
		MyFont.DrawTextEx(
			C,
			CanvasWidth,
			UltraWideOffsetX + HUD_SUICIDE_TEXT_X * CanvasWidth,
			HUD_DEAD_TEXT_Y2 * CanvasHeight,
			s2,
			2, false, EJ_Center);
	}
}

///steam 06/02/2017
simulated function bool AllowSuperPostRender(canvas C)
{
	return (CoopLevelStatus != 1);
}
simulated function bool DrawCoopLevelStatus(canvas C)
{
	///coop loading
	if( CoopLevelStatus == 1 )
	{
		DrawLoadingIndicator(C, false);

		///steam 23/02/2016
		///MyFont.DrawTextEx(C, CanvasWidth, CanvasWidth/2, CanvasHeight * 0.7, LoadingMessage, 3, false, EJ_Center);
		return true;
	}
	///coop gameover
	else if( CoopLevelStatus == 2 )
	{
		DrawCoopDeadStatus(C, CoopGameOverMessage1, CoopGameOverMessage2);
	}
	///coop waiting other players
	else if( CoopLevelStatus == 3 )
	{
		if( !AreAnyRootWindowsRunning() )
		{
			DrawLoadingIndicator(C, true);
			///same as DrawDeadMessage in P2HUD
			MyFont.DrawTextEx(
				C,
				CanvasWidth,
				0.5 * C.ClipX,
				0.5 * C.ClipY,
				CoopWaitPlayersMessage1,
				2, false, EJ_Center);
			if( bCoopBlink && OurPlayer.GameReplicationInfo != None 
				&& CoopGameReplicationInfo(OurPlayer.GameReplicationInfo) != None 
				&& CoopGameReplicationInfo(OurPlayer.GameReplicationInfo).bCoopWaitContinue )
			{
				MyFont.DrawTextEx(
					C,
					CanvasWidth,
					0.5 * C.ClipX,
					0.55 * C.ClipY,
					CoopWaitPlayersMessage2,
					2, false, EJ_Center);
			}
		}
	}
	return false;
}

function bool DrawLevelAction( canvas C )
{
	local string BigMessage;
	local float y;

	y = 0.5;
	BigMessage = "";

	if (Level.LevelAction == LEVACT_None )
	{
		// Check if we're paused (note the use of another magical epic number here)
		if ((Level.Pauser != None) && (Level.TimeSeconds > Level.PauseDelay + 0.2))
		{
			// Make sure no screens or root windows are running (somewhat time-consuming
			// but it's okay because if we get here we know the game is already paused)
			if( (OurPlayer.CurrentScreen == None) && !AreAnyRootWindowsRunning() && CoopLevelStatus == 0 )
			{
				// Display paused message
				BigMessage = PausedMessage;
			}
		}
	}
	else if (Level.LevelAction == LEVACT_Loading)
	{
	}
	else if (Level.LevelAction == LEVACT_Saving)
		BigMessage = SavingMessage;
	else if (Level.LevelAction == LEVACT_EasySaving)
		BigMessage = EasySavingMessage;
	else if (Level.LevelAction == LEVACT_AutoSaving)
		BigMessage = AutoSavingMessage;
	else if (Level.LevelAction == LEVACT_ForcedSaving)
		BigMessage = ForcedSavingMessage;
	else if (Level.LevelAction == LEVACT_Precaching)
		BigMessage = PrecachingMessage;
	
	if (BigMessage != "")
	{
		MyFont.DrawTextEx(C, CanvasWidth, CanvasWidth/2, CanvasHeight * y, BigMessage, 3, false, EJ_Center);
		return true;
	}
	return false;
}

///steam 19/05/2016 movie
simulated function PlayMovieDirect(String MovieFilename, int XPos, int YPos, bool UseSound, bool LoopMovie)
{
	if( Level.NetMode == NM_DedicatedServer )
		return;
	Super.PlayMovieDirect(MovieFilename, XPos, YPos, UseSound, LoopMovie);
}
simulated function PlayMovieScaled(MovieTexture InMovie, string MovieFileName, float Left, float Top, 
	float Right, float Bottom, bool UseSound, bool LoopMovie, optional bool Translucent)
{
	if( Level.NetMode == NM_DedicatedServer )
		return;
	Super.PlayMovieScaled(InMovie, MovieFileName, Left, Top, Right, Bottom, UseSound, LoopMovie, Translucent);
}
simulated function bool IsMoviePlaying()
{
	if( Level.NetMode == NM_DedicatedServer )
		return false;
	return Super.IsMoviePlaying();
}
simulated function PauseMovie(bool Pause)
{
	if( Level.NetMode == NM_DedicatedServer )
		return;
	Super.PauseMovie(Pause);
}
simulated function bool IsMoviePaused()
{
	if( Level.NetMode == NM_DedicatedServer )
		return false;
	return Super.IsMoviePaused();
}
simulated function StopMovie()
{
	if( Level.NetMode == NM_DedicatedServer )
		return;
	Super.StopMovie();
}
///steam 19/05/2016 movie

/*
	CoopGameOverMessage1="All players are DEAD. Open Menu and"
	CoopGameOverMessage2="select Restart level, or Load Game."
*/

defaultproperties
{
	CoopWantedIcon=Texture'NicksCoop.MiscHUD.cop_badge_coop'
	CoopWantedBar=Texture'NicksCoop.MiscHUD.cop_badge_slider_coop'

	CoopWaitPlayersMessage1="Waiting for players"
	CoopWaitPlayersMessage2="If all players joined, press %KEY_WantsToSkip% to continue."
	CoopDeadMessage1="You are DEAD. Press %KEY_Fire% to spectate and %KEY_AltFire% to return view."
	CoopDeadMessage2="Please wait, until anybody will heal you."
	CoopGameOverMessage1="All players are DEAD. Open Menu and"
	CoopGameOverMessage2="select Restart level, if you are admin"
	WaitIcon=Texture'NicksCoop.WaitHUD.wait_icon_00'
	CoopPlayerIndicatorIcon=Texture'NicksCoop.MiscHUD.PlayerIndicatorTex'
	CoopPlayerIndicatorScale=0.14 //0.2

	IdentityFadeDuration=1.000000
	IdentityInfoPY=0.550000
	IdentityHealthPW=0.060000
	IdentityHealthPH=0.004000
	IdentityBorderPS=0.001000
	ViewFrom="Tracking "
	CategoryFormats(0)=(YP=0.940000,VAlign=TVA_Bottom,Stack=TS_Up)
	CategoryFormats(1)=(YP=0.500000)
	CategoryFormats(2)=(YP=0.970000,FontSize=1)
	CategoryFormats(3)=(YP=0.130000,HAlign=THA_Center,Stack=TS_Down,FontSize=2)
	CategoryFormats(4)=(YP=0.750000,HAlign=THA_Center,Stack=TS_Down,FontSize=2)
	MedFont=Font'P2Fonts.Plain24'
	BigFont=Font'P2Fonts.Plain30'
	LargeFont=Font'P2Fonts.Plain38'
	SmallFont=Font'Engine.SmallFont'
	//FontInfoClass="FPSGame.FontInfo"
}
