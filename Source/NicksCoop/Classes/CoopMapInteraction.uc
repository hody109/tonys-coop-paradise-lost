//=============================================================================
// CoopMapInteraction.uc
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

class CoopMapInteraction extends P2Screen;//Interaction;

const DEGREES_TO_RADIANS			=  0.01745;
const RADIANS_TO_DEGREES			= 57.29577;

var Texture BackgroundTex;
var RawActor HeadMarker, CoopHeadMarker;

var class<P2GameInfoSingle> GameClass;
var StaticMesh HeadMesh, CoopHeadMesh;

var bool bSorted;
var bool bEnableShow;
var bool MarkerScaleSwitch;
var bool bForceReseted;

var float ScaleX, ScaleY;
var float HeadMarkerScale;

var float SetupErrandsTime;
var float fKeySetupTime;
var float fResetTime;
var int SetupNumErrands;

struct MapPointInfo
{
	var MapPoint MapPoint;
	var vector Pos;
	var float Distance;
};
enum ESpriteStatus
{
	SS_Off,
	SS_Fading,
	SS_On
};
struct Sprite								// Simple sprite
{
	var Texture			tex;				// texture
	var float			x;					// x coord
	var float			y;					// y coord
	var ESpriteStatus	status;				// status
};
var array<Sprite>		Sprites;			// Array of sprites
var int					SpritesNextUnused;	// Used for allocating sprites
var() array<vector>		ErrandPositions;	// Where errand names and crossouts are drawn
var int					ErrandNameBase;		// index of first errand name sprite
var int					ErrandLocBase;		// index of first errand location sprite
var int					ErrandLocCrossBase;	// index of first errand location crossout sprite
var() array<Texture>	CrossoutTex;		// Crossout textures
var int					CrossoutBase;		// index of first crossout sprite

var() localized String	Message;	// message
var() float		MsgX;				// message x position (% of screen width)
var() float		MsgY;				// message y position (% of screen height)
var() float		MsgFlashRate;		// message flag rate
var float		MsgFlashTime;		// message flag time
var float		MarkerFlashTime;
var bool		bMsgFlashOn;		// used to flash message on/off
var string		FontInfoClass;		// which FontInfo class to use
var FontInfo	MyFont;				// current FontInfo (various sizes, etc)

struct SMapPos
	{
	var() name			UniqueTag;			// The unique tag of the MapPoint this position is associated with
	var() vector		Pos;				// Position on map corresponding to MapPoint's world position
	};
var() array<SMapPos>	MapPositions;		// Used to associate MapPoint's with their map positions

///steam 16/08/2017 - widescreen fix
var bool bEnableWidescreenStretch;
const FOUR_BY_THREE_ASPECT_RATIO = 1.33333333333;

///steam 18/08/2017
var Texture TextureOverride;

event Initialized()
{
//	ViewportOwner.Actor.ClientMessage("Map Initialized()");
	//MapInitialized();
}

function MapInitialized()
{
	if( MyFont == None || MyFont.Owner == None )
		MyFont = FontInfo(ViewportOwner.Actor.spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class')), ViewportOwner.Actor));
	SetupActors();
}

function MapReset()
{
	///steam 24/08/2017 - reset all object references
	P2P = None;
	MyFont = None;
	HeadMarker = None;
	CoopHeadMarker = None;

	MsgFlashTime = 0;
	MarkerFlashTime = 0;
	SetupErrandsTime = 0;
	fResetTime = 0;
	fKeySetupTime = 0;
	bEnableShow = false;

//	log("PreTravel MapReset");
}

function PreTravel()
{
	Super.PreTravel();
	MapReset();
}

function SetupActors()
{
	if( HeadMarker == None || HeadMarker.bDeleteMe )
		HeadMarker = ViewportOwner.Actor.Spawn(class'RawActor', ViewportOwner.Actor);
	if( HeadMarker != None && !HeadMarker.bDeleteMe )
	{
		HeadMarker.SetStaticMesh(HeadMesh);
		HeadMarker.SetDrawType(DT_StaticMesh);
		HeadMarker.bUnlit = true;
	}

	if( CoopHeadMarker == None || CoopHeadMarker.bDeleteMe )
		CoopHeadMarker = ViewportOwner.Actor.Spawn(class'RawActor', ViewportOwner.Actor);
	if( CoopHeadMarker != None && !CoopHeadMarker.bDeleteMe )
	{
		CoopHeadMarker.SetStaticMesh(CoopHeadMesh);
		CoopHeadMarker.SetDrawType(DT_StaticMesh);
		CoopHeadMarker.bUnlit = true;
	}
}

function RenderMsgBody(Canvas canvas)
{
	local CoopGameReplicationInfo myGameReplicaInfo;
	if( ViewportOwner.Actor != None && !ViewportOwner.Actor.bDeleteMe )///steam 29/07/2016
	{
		myGameReplicaInfo = CoopGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		if( myGameReplicaInfo != None && myGameReplicaInfo.bCoopLevelLoading )
			return;

		if( ViewportOwner.Actor.Level.TimeSecondsAlways > MsgFlashTime )
		{
			bMsgFlashOn = !bMsgFlashOn;
			MsgFlashTime = ViewportOwner.Actor.Level.TimeSecondsAlways + MsgFlashRate;
		}
		if( bMsgFlashOn && MyFont != None )
			MyFont.DrawTextEx(Canvas, Canvas.ClipX, MsgX * Canvas.ClipX, MsgY * Canvas.ClipY, Message, 0, false, EJ_Center);
	}
}

function int AllocateSprites(int Num)
{
	local int Base;
	local int ReqLen;
	local int i;

	// When allocating new sprites, only increase the array size if necessary.
	// The array never shrinks.  Each time the map is called, we start the
	// SpritesNextUnused at 0, thereby re-using previously-allocated sprites.
	Base = SpritesNextUnused;
	ReqLen = SpritesNextUnused + Num;
	if (ReqLen > Sprites.length)
		Sprites.insert(Sprites.length, ReqLen - Sprites.length);
	SpritesNextUnused += Num;

	// Clear newly allocated sprites to avoid any nasty surprises
	for (i = Base; i < SpritesNextUnused; i++)
	{
		Sprites[i].tex = None;
		Sprites[i].x = 0;
		Sprites[i].y = 0;
		Sprites[i].status = SS_Off;
	}

	return Base;
}

function Texture GetErrandName(int ErrandIndex, CoopGameReplicationInfo myGameReplicaInfo)
{
	return Texture(DynamicLoadObject(String(GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].NameTex), class'Texture'));
}

function Texture GetErrandLocation(int ErrandIndex, out float x, out float y, CoopGameReplicationInfo myGameReplicaInfo)
{
	x = GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationX;
	y = GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationY;
	if (GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationTex != '')
		return Texture(DynamicLoadObject(String(GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationTex), class'Texture'));
	return None;
}

function Texture GetErrandLocationCrossout(int ErrandIndex, out float x, out float y, CoopGameReplicationInfo myGameReplicaInfo)
{
	x = GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationCrossX;
	y = GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationCrossY;
	if (GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationCrossTex != '')
		return Texture(DynamicLoadObject(String(GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands[ErrandIndex].LocationCrossTex), class'Texture'));
	return None;
}

function bool IsErrandComplete(int ErrandIndex, CoopGameReplicationInfo myGameReplicaInfo)
{
	local int i;

	for( i = 0 ; i < ArrayCount(myGameReplicaInfo.TodayCompletedErrands) ; i++ )
	{
		if( myGameReplicaInfo.TodayCompletedErrands[i] == ErrandIndex )
			return true;
	}
	return false;
}

function bool IsErrandActive(int ErrandIndex, CoopGameReplicationInfo myGameReplicaInfo)
{
	local int i;

	for( i = 0 ; i < ArrayCount(myGameReplicaInfo.TodayActivatedErrands) ; i++ )
	{
		if( myGameReplicaInfo.TodayActivatedErrands[i] == ErrandIndex )
			return true;
	}
	return false;
}

///steam 04/06/2017
function Texture GetMapTexture(CoopGameReplicationInfo myGameReplicaInfo)
{
	return Texture(DynamicLoadObject(String(GameClass.default.Days[myGameReplicaInfo.CurrentDay].MapTex), class'Texture'));
}

function SetupSprites()
{
	local int i, j;
	local float x, y;
	local int RevealedHaters;
	local CoopGameReplicationInfo myGameReplicaInfo;
	local int NumErrands;

	if( ViewportOwner.Actor == None || ViewportOwner.Actor.bDeleteMe )
		return;

	myGameReplicaInfo = CoopGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
	if( myGameReplicaInfo == None || myGameReplicaInfo.bDeleteMe )
		return;

	NumErrands = GameClass.default.Days[myGameReplicaInfo.CurrentDay].Errands.Length;
	SetupNumErrands = NumErrands;

	///BackgroundTex = Texture(DynamicLoadObject(String(GameClass.default.Days[myGameReplicaInfo.CurrentDay].MapTex), class'Texture'));
	BackgroundTex = GetMapTexture(myGameReplicaInfo);

	SpritesNextUnused = 0;

	// Setup all errand names and locations
	ErrandNameBase = AllocateSprites(NumErrands);
	ErrandLocBase = AllocateSprites(NumErrands);
	ErrandLocCrossBase = AllocateSprites(NumErrands);
	CrossoutBase = AllocateSprites(NumErrands);
	for (i = 0; i < NumErrands; i++)
		{
		Sprites[ErrandNameBase+i].tex = GetErrandName(i, myGameReplicaInfo);
		Sprites[ErrandNameBase+i].x = ErrandPositions[i].X;
		Sprites[ErrandNameBase+i].y = ErrandPositions[i].Y;
		Sprites[ErrandNameBase+i].status = SS_Off;

		Sprites[ErrandLocBase+i].tex = GetErrandLocation(i, x, y, myGameReplicaInfo);
		Sprites[ErrandLocBase+i].x = x;
		Sprites[ErrandLocBase+i].y = y;
		Sprites[ErrandLocBase+i].status = SS_Off;

		Sprites[ErrandLocCrossBase+i].tex = GetErrandLocationCrossout(i, x, y, myGameReplicaInfo);
		Sprites[ErrandLocCrossBase+i].x = x;
		Sprites[ErrandLocCrossBase+i].y = y;
		Sprites[ErrandLocCrossBase+i].status = SS_Off;

		Sprites[CrossoutBase+i].tex = CrossoutTex[i];
		Sprites[CrossoutBase+i].x = ErrandPositions[i].X;
		Sprites[CrossoutBase+i].y = ErrandPositions[i].Y;
		Sprites[CrossoutBase+i].status = SS_Off;

		// Crossout completed errands and locations, unless it's the errand that's about to be crossed off
		if( /*IsErrandActive(i, myGameReplicaInfo) &&*/ IsErrandComplete(i, myGameReplicaInfo) )
			{
			Sprites[CrossoutBase+i].status = SS_On;
			if (Sprites[ErrandLocCrossBase+i].tex != None)
				Sprites[ErrandLocCrossBase+i].status = SS_On;
			}
		}

	// Turn on the name and location for each errand that has been revealed.
	for (i = 0; i < NumErrands; i++)
	{
		if( IsErrandActive(i, myGameReplicaInfo) )
		{
			Sprites[ErrandNameBase+i].status = SS_On;
			if (Sprites[ErrandLocBase+i].tex != None)
				Sprites[ErrandLocBase+i].status = SS_On;
		}
	}
}

function SetupErrands(CoopGameReplicationInfo myGameReplicaInfo)
{
	local int i;

	for (i = 0; i < SetupNumErrands; i++)
	{
		if( IsErrandActive(i, myGameReplicaInfo) )
		{
			Sprites[ErrandNameBase+i].status = SS_On;
			if (Sprites[ErrandLocBase+i].tex != None)
				Sprites[ErrandLocBase+i].status = SS_On;
		}
		if( IsErrandComplete(i, myGameReplicaInfo) )
		{
			Sprites[CrossoutBase+i].status = SS_On;
			if (Sprites[ErrandLocCrossBase+i].tex != None)
				Sprites[ErrandLocCrossBase+i].status = SS_On;
		}
	}
	///steam 22/02/2016
	/*if( MyFont == None 
		|| HeadMarker == None )
		//|| CoopHeadMarker == None )
		MapInitialized();*/
}

function bool CanTryToEnableRender(CoopPlayerController newCoopPC)
{
	if( newCoopPC == None 
		|| newCoopPC.bDeleteMe 
		|| CoopGameReplicationInfo(newCoopPC.GameReplicationInfo) == None 
		|| CoopGameReplicationInfo(newCoopPC.GameReplicationInfo).bCoopLevelTraveling )
		return false;
	return true;
}

function TryToEnableRenderBase()
{
	MapInitialized();
	SetupSprites();
	bEnableShow = true;
	fResetTime = ViewportOwner.Actor.Level.TimeSecondsAlways + 0.1;
	fKeySetupTime = ViewportOwner.Actor.Level.TimeSecondsAlways;
	bForceReseted = false;
}

///steam 25/07/2016
function TryToEnableRenderForced(CoopPlayerController newCoopPC)
{
	if( !CanTryToEnableRender(newCoopPC) )
		return;

	if( bEnableShow )
		return;

	TryToEnableRenderBase();
}

function TryToEnableRender(CoopPlayerController newCoopPC)
{
	if( !CanTryToEnableRender(newCoopPC) )
		return;

	///steam 22/02/2016
	//if( abs(ViewportOwner.Actor.Level.TimeSecondsAlways-fResetTime) > 0.6 )
	//	fResetTime = 0;

	if( ViewportOwner.Actor.Level.TimeSecondsAlways < fResetTime )
		return;

	if( bEnableShow )
	{
		bEnableShow = false;
		return;
	}

	TryToEnableRenderBase();
}

function PostRender(Canvas Canvas)
{
	local CoopGameReplicationInfo myGameReplicaInfo;

	if( ViewportOwner.Actor != None && !ViewportOwner.Actor.bDeleteMe )///steam 29/07/2016
	{
		if( ViewportOwner.Actor.Level.LevelAction == LEVACT_Loading )
		{
			if( !bForceReseted )
			{
				MapReset();
				bForceReseted = true;
			}
			return;
		}
		myGameReplicaInfo = CoopGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		if( myGameReplicaInfo != None && !myGameReplicaInfo.bDeleteMe )
		{
			if( myGameReplicaInfo.bCoopLevelTraveling )
			{
				/*if( !bForceReseted )
				{
					MapReset();
					bForceReseted = true;
				}*/
				return;
			}
		}
		else return;

		if( ViewportOwner.Actor.bWantsToSkip > 0 && ViewportOwner.Actor.Level.TimeSecondsAlways > fKeySetupTime + 0.2 )
		{
			ViewportOwner.Actor.bWantsToSkip = 0;
			if( bEnableShow )
			{
				fResetTime = ViewportOwner.Actor.Level.TimeSecondsAlways + 0.4;
				bEnableShow = false;
			}
		}

		if( bEnableShow )
		{
			if( ViewportOwner.Actor.Level.TimeSecondsAlways > SetupErrandsTime )//1.2 and 0.6 too slow
			{
				SetupErrands(myGameReplicaInfo);
				SetupErrandsTime = ViewportOwner.Actor.Level.TimeSecondsAlways + 0.37;
			}
			RenderScreen(Canvas);
		}
	}

	/*if( !bSorted )
	{
		SortInteractions();
		bSorted = true;
	}*/

	Super.PostRender(Canvas);
}

function RenderScreen(canvas Canvas)
{
	local Texture tex;
	local float alpha;
	local int s;
	local float MapScale, MapX, MapY;
	local float NearestFourByThree, OffsetX;
	local CoopGameReplicationInfo myGameReplicaInfo;

	if( bEnableShow )
	{
		myGameReplicaInfo = CoopGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
		if( myGameReplicaInfo == None || myGameReplicaInfo.bDeleteMe )
			return;

		// Calculate overall scaling (background stretched out to full canvas)
		ScaleX = Canvas.ClipX / BackgroundTex.USize;
		ScaleY = Canvas.ClipY / BackgroundTex.VSize;

		// NOTE: If map is drawn using STY_Normal then trail doesn't show up.  Using
		// STY_Alpha fixes this problem.  My guess is it has something to do with alpha'd
		// items being sorted separately during rendering.
		// In any case, we now have other reasonss why we want the map to be alpha'd.
		Canvas.Style = 5; //ERenderStyle.STY_Alpha;
		Canvas.SetDrawColor(255, 255, 255, 255);
		MapScale = 1.0;
		MapX = 0;
		MapY = 0;

		///steam 16/08/2017 - widescreen fix
		bEnableWidescreenStretch = (class'P2GameInfo'.default.bWidescreenStretch || (Canvas.ClipX/Canvas.ClipY) == 1.25);
		if( !bEnableWidescreenStretch )
		{
			NearestFourByThree = FOUR_BY_THREE_ASPECT_RATIO *(Canvas.SizeY * MapScale);
			OffsetX = FMax((Canvas.ClipX - NearestFourByThree)/2,0);
			Canvas.SetPos(OffsetX, MapY);
			if( TextureOverride != None )
				Canvas.DrawTile(TextureOverride, NearestFourByThree, Canvas.SizeY * MapScale, 0, 0, TextureOverride.USize, TextureOverride.VSize);
			else Canvas.DrawTile(BackgroundTex, NearestFourByThree, Canvas.SizeY * MapScale, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);
		}
		else
		{
			Canvas.SetPos(MapX, MapY);
			if( TextureOverride != None )
				Canvas.DrawTile(TextureOverride, Canvas.SizeX * MapScale, Canvas.SizeY * MapScale, 0, 0, TextureOverride.USize, TextureOverride.VSize);
			else Canvas.DrawTile(BackgroundTex, Canvas.SizeX * MapScale, Canvas.SizeY * MapScale, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);
		}
		///steam 16/08/2017 - widescreen fix

		///Canvas.SetPos(MapX, MapY);
		///Canvas.DrawTile(BackgroundTex, Canvas.SizeX * MapScale, Canvas.SizeY * MapScale, 0, 0, BackgroundTex.USize, BackgroundTex.VSize);

		if( TextureOverride == None )
		{
		// Display all sprites according to their current settings
		for (s = 0; s < SpritesNextUnused; s++)
		{
			tex = Sprites[s].tex;
			if (tex != None && Sprites[s].status != SS_Off)
			{
				if (Sprites[s].status == SS_On/* || bFadeScreen || bGoFast*/)
					alpha = 255;
				//else
				//	alpha = FadeAlpha;

				Canvas.SetDrawColor(255, 255, 255, alpha);

				///steam 16/08/2017 - widescreen fix
				if( !bEnableWidescreenStretch )
				{
					Canvas.SetPos(FOUR_BY_THREE_ASPECT_RATIO * (Sprites[s].x * ScaleY * MapScale) + OffsetX, (Sprites[s].y * ScaleY * MapScale) + MapY);
					Canvas.DrawTile(tex, FOUR_BY_THREE_ASPECT_RATIO * (tex.USize * ScaleY) * MapScale, (tex.VSize * ScaleY) * MapScale, 0, 0, tex.USize, tex.VSize);
				}
				else
				{
					Canvas.SetPos((Sprites[s].x * ScaleX * MapScale) + MapX, (Sprites[s].y * ScaleY * MapScale) + MapY);
					Canvas.DrawTile(tex, (tex.USize * ScaleX) * MapScale, (tex.VSize * ScaleY) * MapScale, 0, 0, tex.USize, tex.VSize);
				}
				///steam 16/08/2017 - widescreen fix

				///Canvas.SetPos((Sprites[s].x * ScaleX * MapScale) + MapX, (Sprites[s].y * ScaleY * MapScale) + MapY);
				///Canvas.DrawTile(tex, (tex.USize * ScaleX) * MapScale, (tex.VSize * ScaleY) * MapScale, 0, 0, tex.USize, tex.VSize);
			}
		}
		DrawTrail(canvas, myGameReplicaInfo);
		}
		RenderMsgBody(Canvas);

		///steam 07/09/2018 - rendering subs over the client map
		if( CoopPlayerController(ViewportOwner.Actor) != None )
			CoopPlayerController(ViewportOwner.Actor).ClientForceDrawSubs(Canvas);
	}
}

function vector FindMapPointPos(MapPoint mp)
{
	local int i;
	local vector bad;

	for (i = 0; i < MapPositions.length; i++)
	{
		if (MapPositions[i].UniqueTag == mp.Tag)
			return MapPositions[i].Pos;
	}

	///steam 01/07/2017
	///Warn("MapScreen.FindMapPointPos(): Can't find position for MapPoint with tag "$mp.Tag);

	return bad;
}

function CalcLineInfo(float x1, float y1, float x2, float y2, out float length, out float angle)
{
	local float dx, dy;

	dx = x2 - x1;
	dy = y2 - y1;
	length = Sqrt((dx * dx) + (dy * dy));
	angle = ACos(dx / length) * RADIANS_TO_DEGREES;
	if (dy < 0)
		angle = 360 - angle;
}

function DrawTrail(Canvas canvas, CoopGameReplicationInfo myGameReplicaInfo)
{
	local int i;
	local float MarkerScale;
	local CoopPlayerReplicationInfo PRI;
	local Pawn myPawn;

	myPawn = ViewportOwner.Actor.Pawn;

	if( ViewportOwner.Actor.Level.TimeSecondsAlways > MarkerFlashTime )
	{
		if( !MarkerScaleSwitch )
		{
			HeadMarkerScale = FClamp(HeadMarkerScale+0.03,0,1);
			if( HeadMarkerScale >= 1.0 )
				MarkerScaleSwitch = true;
		}
		else
		{
			HeadMarkerScale = FClamp(HeadMarkerScale-0.03,0,1);
			if( HeadMarkerScale <= 0 )
				MarkerScaleSwitch = false;
		}
		MarkerFlashTime = ViewportOwner.Actor.Level.TimeSecondsAlways + 0.01;
	}

	MarkerScale = 0.013 + (HeadMarkerScale * 0.003);

	if( myPawn != None && !myPawn.bDeleteMe )///steam 29/07/2016
	{
		//DrawTrailMarker(canvas, myPawn.Location, myPawn.Rotation.Yaw, HeadMarker, MarkerScale);
		if( myGameReplicaInfo != None )
		{
			for( i = 0 ; i < myGameReplicaInfo.PRIArray.Length ; i++ )
			{
				PRI = CoopPlayerReplicationInfo(myGameReplicaInfo.PRIArray[i]);
				if( PRI != None && !PRI.bDeleteMe )
				{
					if( PRI == ViewportOwner.Actor.PlayerReplicationInfo )
					{
						if( HeadMarker != None && !HeadMarker.bDeleteMe )///steam 29/07/2016
							DrawTrailMarker(canvas, myPawn.Location, myPawn.Rotation.Yaw, HeadMarker, MarkerScale);
					}
					else if( !PRI.bCoopDedicatedHost )
					{
						if( CoopHeadMarker != None && !CoopHeadMarker.bDeleteMe )///steam 29/07/2016
							DrawTrailMarker(canvas, PRI.NETLocation, 0, CoopHeadMarker, MarkerScale*0.4);
					}
				}
			}
		}
	}
}

function DrawMarkerOnMap(Canvas canvas, float MapX, float MapY, int PlayerYaw, float DiffDeg, Actor Marker, float MarkerScale)
{
	local vector screen;
	local vector world;
	local vector CameraLocation;
	local rotator CameraRotation;
	local Actor viewtarget;
	local float NearestFourByThree, OffsetX;

	if( Marker != None )
	{
		// Set draw style
		Canvas.Style = 1; //ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255, 255, 255);

		///steam 16/08/2017 - widescreen fix
		NearestFourByThree = FOUR_BY_THREE_ASPECT_RATIO *(Canvas.SizeY);
		OffsetX = FMax((Canvas.ClipX - NearestFourByThree)/2,0);
		if( !bEnableWidescreenStretch )
			screen.X = OffsetX + (FOUR_BY_THREE_ASPECT_RATIO) * (MapX * ScaleY);
		else screen.X = MapX * ScaleX;
		///steam 16/08/2017 - widescreen fix

		// Convert from map to screen coords (map is stretched to full screen)
		///screen.X = MapX * ScaleX;
		screen.Y = MapY * ScaleY;
		screen.Z = 0;

		// Convert from 2D to 3D world vector.  Vector comes back extremely close to
		// the near clipping plane, so we push it back to avoid actor clipping problems.
		world = ScreenToWorld(screen); 
		world *= 2.0;

		// Scale
		Marker.SetDrawScale(MarkerScale);

		// Get player's camera's location and rotation.  Marker needs to be positioned
		// relative to the camera and be rotated just like the camera so we'll always
		// see the same side of it even as the camera rotates.  We add an additional
		// rotation to the marker so it faces the direction the player is facing in
		// the map (if he's facing "north" in the game we want the marker to face
		// "north" too).
		ViewportOwner.Actor.PlayerCalcView(ViewTarget, CameraLocation, CameraRotation);
		Marker.SetLocation(CameraLocation + world);
		CameraRotation.Roll = PlayerYaw + ((DiffDeg/360) * 65535) + 16384;
		Marker.SetRotation(CameraRotation);

		Canvas.DrawActor(Marker, false);
	}
}

function DrawTrailMarker(Canvas canvas, Vector PlayerLoc, int PlayerYaw, Actor Marker, float MarkerScale)
{
	local int i, j;
	local MapPoint mp;
	local MapPointInfo points[2];
	local float WorldLen;
	local float WorldDeg;
	local float MapLen;
	local float MapDeg;
	local float DiffDeg;
	local float PlayerLen;
	local float PlayerDeg;
	local float PlayerMapX;
	local float PlayerMapY;
	local float AverageX;
	local float AverageY;
	local int MapPointCount;
	local vector pos;
	local float mpDistance;

	if( ViewportOwner != None && ViewportOwner.Actor != None )
	{
		// Go through all the map points and pick out the ones closest to the player
		ForEach ViewportOwner.Actor.AllActors(class'MapPoint', mp)
		{
			// Calculate distance to current map point
			//mp.Distance
			mpDistance = Sqrt(((PlayerLoc.X - mp.Location.X) * (PlayerLoc.X - mp.Location.X)) +
							   ((PlayerLoc.Y - mp.Location.Y) * (PlayerLoc.Y - mp.Location.Y)));
			// Compare distance to all map points that were already added to list
			for (i = 0; i < ArrayCount(points); i++)
				{
				if (points[i].MapPoint == None || (points[i].MapPoint != None && mpDistance < points[i].Distance))
					{
					// Insert new point into the array (may drop an existing map point off the end)
					for (j = ArrayCount(points)-1; j > i; j--)
					{
						points[j] = points[j-1];
					}
					points[i].MapPoint = mp;
					// Lookup the map point's position on the 2D map
					points[i].Pos = FindMapPointPos(mp);
					MapPointCount++;
					break;
					}
				}
		}

		// Make sure we found at least as many points as we wanted
		if (MapPointCount >= ArrayCount(points))
		{
			// Calculate the players position using several different pairs of
			// points, then we'll average the results together.
			for (i = 0; i < ArrayCount(points); i++)
			{
				j = i + 1;
				if (j == ArrayCount(points))
					j = 0;

				// Get length and angle of line from point1 to point2 in world
				CalcLineInfo(
					points[i].MapPoint.Location.X, points[i].MapPoint.Location.Y,
					points[j].MapPoint.Location.X, points[j].MapPoint.Location.Y,
					WorldLen, WorldDeg);

				// Get length and angle of line from point1 to point2 on map
				CalcLineInfo(
					points[i].Pos.X, points[i].Pos.Y,
					points[j].Pos.X, points[j].Pos.Y,
					MapLen, MapDeg);

				// Get length and angle of line from point1 to player in world
				CalcLineInfo(
					points[i].MapPoint.Location.X, points[i].MapPoint.Location.Y,
					PlayerLoc.X, PlayerLoc.Y,
					PlayerLen, PlayerDeg);

				// Adjust player angle by difference between map and world angles
				DiffDeg = MapDeg - WorldDeg;
				if (DiffDeg > 135)
					DiffDeg = DiffDeg - 360;
				else if (DiffDeg < -135)
					DiffDeg = DiffDeg + 360;

				PlayerDeg = PlayerDeg + DiffDeg;
				if (PlayerDeg < 0)
					PlayerDeg = 360 + PlayerDeg;
				else if (PlayerDeg >= 360)
					PlayerDeg = PlayerDeg - 360;

				// Adjust player length by the ratio between map and world lengths
				PlayerLen = PlayerLen * (MapLen / WorldLen);

				// Use adjusted player length and angle to calculate position of player
				// relative to point1's map coordinates.
				PlayerMapX = points[i].Pos.X + cos(PlayerDeg * DEGREES_TO_RADIANS) * PlayerLen;
				PlayerMapY = points[i].Pos.Y + sin(PlayerDeg * DEGREES_TO_RADIANS) * PlayerLen;

				// Average all the results together
				///steam 16/08/2017 - widescreen fix
				AverageX += (4/3)*PlayerMapX;
				///steam 16/08/2017 - widescreen fix
				///AverageX += PlayerMapX;
				AverageY += PlayerMapY;
			}

			// Draw marker at average location
			AverageX /= ArrayCount(points);
			AverageY /= ArrayCount(points);
			DrawMarkerOnMap(canvas, AverageX, AverageY, PlayerYaw, DiffDeg, Marker, MarkerScale);
		}
	}
}

function SortInteractions()
{
	local int i, j;
	local Interaction Tmp;

	for(i = 0; i < ViewportOwner.LocalInteractions.Length; i++)
	{
		for(j = i; j < ViewportOwner.LocalInteractions.Length; j++)
		{
			Tmp = ViewportOwner.LocalInteractions[i];
			ViewportOwner.LocalInteractions[i] = ViewportOwner.LocalInteractions[j];
			ViewportOwner.LocalInteractions[j] = Tmp;
		}
	}
}

defaultproperties
{
	 HeadMesh=StaticMesh'stuff.stuff1.ArrowBox'
	 CoopHeadMesh=StaticMesh'stuff.stuff1.DashBox'

     MapPositions(0)=(UniqueTag="suburbs-1-ne",pos=(X=722.000000,Y=475.000000))
     MapPositions(1)=(UniqueTag="suburbs-1-sw",pos=(X=655.000000,Y=559.000000))
     MapPositions(2)=(UniqueTag="suburbs-2-n",pos=(X=681.000000,Y=619.000000))
     MapPositions(3)=(UniqueTag="suburbs-2-se",pos=(X=725.000000,Y=703.000000))
     MapPositions(4)=(UniqueTag="suburbs-3-ne",pos=(X=789.000000,Y=469.000000))
     MapPositions(5)=(UniqueTag="suburbs-3-sw",pos=(X=748.000000,Y=512.000000))
     MapPositions(6)=(UniqueTag="suburbs-4-nw",pos=(X=767.000000,Y=703.000000))
     MapPositions(7)=(UniqueTag="suburbs-4-c",pos=(X=815.000000,Y=754.000000))
     MapPositions(8)=(UniqueTag="forest-e",pos=(X=814.000000,Y=830.000000))
     MapPositions(9)=(UniqueTag="forest-w",pos=(X=772.000000,Y=824.000000))
     MapPositions(10)=(UniqueTag="parade-c",pos=(X=715.000000,Y=812.000000))
     MapPositions(11)=(UniqueTag="parade-e",pos=(X=739.000000,Y=813.000000))
     MapPositions(12)=(UniqueTag="rwsblock-n",pos=(X=642.000000,Y=263.000000))
     MapPositions(13)=(UniqueTag="rwsblock-s",pos=(X=730.000000,Y=394.000000))
     MapPositions(14)=(UniqueTag="westmall-nw",pos=(X=569.000000,Y=318.000000))
     MapPositions(15)=(UniqueTag="westmall-mid",pos=(X=568.000000,Y=354.000000))
     MapPositions(16)=(UniqueTag="eastmall-mid",pos=(X=577.000000,Y=379.000000))
     MapPositions(17)=(UniqueTag="eastmall-se",pos=(X=642.000000,Y=380.000000))
     MapPositions(18)=(UniqueTag="highlands-w",pos=(X=435.000000,Y=300.000000))
     MapPositions(19)=(UniqueTag="highlands-e",pos=(X=533.000000,Y=330.000000))
     MapPositions(20)=(UniqueTag="industry-n",pos=(X=529.000000,Y=395.000000))
     MapPositions(21)=(UniqueTag="industry-s",pos=(X=504.000000,Y=456.000000))
     MapPositions(22)=(UniqueTag="industry2-s",pos=(X=511.000000,Y=488.000000))
     MapPositions(23)=(UniqueTag="industry2-n",pos=(X=573.000000,Y=446.000000))
     MapPositions(24)=(UniqueTag="greenbelt1-n",pos=(X=465.000000,Y=574.000000))
     MapPositions(25)=(UniqueTag="greenbelt1-s",pos=(X=593.000000,Y=664.000000))
     MapPositions(26)=(UniqueTag="greenbelt2-n",pos=(X=468.000000,Y=420.000000))
     MapPositions(27)=(UniqueTag="greenbelt2-c",pos=(X=436.000000,Y=515.000000))
     MapPositions(28)=(UniqueTag="napalm-nw",pos=(X=392.000000,Y=459.000000))
     MapPositions(29)=(UniqueTag="napalm-se",pos=(X=426.000000,Y=505.000000))
     MapPositions(30)=(UniqueTag="compound-sw",pos=(X=558.000000,Y=254.000000))
     MapPositions(31)=(UniqueTag="compound-c",pos=(X=596.000000,Y=163.000000))
     MapPositions(32)=(UniqueTag="lib1",pos=(X=681.000000,Y=540.000000))
     MapPositions(33)=(UniqueTag="lib2",pos=(X=655.000000,Y=501.000000))
     MapPositions(34)=(UniqueTag="post1",pos=(X=831.000000,Y=766.000000))
     MapPositions(35)=(UniqueTag="post2",pos=(X=891.000000,Y=729.000000))
     MapPositions(36)=(UniqueTag="pol1",pos=(X=699.000000,Y=671.000000))
     MapPositions(37)=(UniqueTag="pol2",pos=(X=730.000000,Y=629.000000))
     MapPositions(38)=(UniqueTag="slaughter1",pos=(X=786.000000,Y=785.000000))
     MapPositions(39)=(UniqueTag="slaughter2",pos=(X=768.000000,Y=764.000000))
     MapPositions(40)=(UniqueTag="church-se",pos=(X=473.000000,Y=330.000000))
     MapPositions(41)=(UniqueTag="church-nw",pos=(X=402.000000,Y=226.000000))
     MapPositions(42)=(UniqueTag="brewery-se",pos=(X=533.000000,Y=366.000000))
     MapPositions(43)=(UniqueTag="brewery-nw",pos=(X=571.000000,Y=398.000000))
     MapPositions(44)=(UniqueTag="estates-n",pos=(X=788.000000,Y=318.000000))
     MapPositions(45)=(UniqueTag="estates-s",pos=(X=736.000000,Y=317.000000))
     MapPositions(46)=(UniqueTag="junkyard-nw",pos=(X=387.000000,Y=560.000000))
     MapPositions(47)=(UniqueTag="junkyard-se",pos=(X=431.000000,Y=634.000000))

     Message="Press %KEY_WantsToSkip% to continue."
     MsgX=0.500000
     MsgY=0.950000
     MsgFlashRate=0.500000
     FontInfoClass="FPSGame.FontInfo"

     ErrandPositions(0)=(X=83.000000,Y=616.000000)
     ErrandPositions(1)=(X=101.000000,Y=691.000000)
     ErrandPositions(2)=(X=119.000000,Y=775.000000)
     ErrandPositions(3)=(X=131.000000,Y=832.000000)
	 ErrandPositions(6)=(X=121.000000,Y=691.000000)	// Hack for PL

     CrossoutTex(0)=Texture'P2Misc.Map.crossout_1'
     CrossoutTex(1)=Texture'P2Misc.Map.crossout_2'
     CrossoutTex(2)=Texture'P2Misc.Map.crossout_3'
     CrossoutTex(3)=Texture'P2Misc.Map.crossout_4'

	 GameClass=class'GameSinglePlayer'
	 BackgroundTex=Texture'p2misc_full.map_day5'
	 bVisible=true
}
