//=============================================================================
// CoopPLMapInteraction.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLMapInteraction extends CoopMapInteraction;


var bool bBriefing;
var int BriefMask, BriefErrand, BriefStage, FadeSprite;
var float NextBriefTime, FadeStarted;
var DayBase BriefDay;

function float BriefSound(Sound S)
{
    if(S==None) return 0.5;
    ViewportOwner.Actor.ClientPlaySound(S);
    Log("PLBRIEF|sound=" $ S);
    return FMax(0.5,GetSoundDuration(S)+0.4);
}

function BeginBriefing(int Mask)
{
    local CoopGameReplicationInfo G;
    G=CoopGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo);
    if(G==None) return;
    BriefDay=GameClass.default.Days[G.CurrentDay];
    TryToEnableRenderBase();
    BriefMask=Mask; BriefErrand=-1; BriefStage=0; FadeSprite=-1;
    bBriefing=true;
    NextBriefTime=ViewportOwner.Actor.Level.TimeSecondsAlways+1.0;
    Log("PLBRIEF|started|mask=" $ Mask);
}

function SetupErrands(CoopGameReplicationInfo G)
{
    local int i;
    Super.SetupErrands(G);
    if(!bBriefing) return;
    for(i=0;i<SetupNumErrands;i++)
        if((BriefMask & (1<<i))!=0)
        {
            if(i>BriefErrand || (i==BriefErrand && BriefStage==0)) Sprites[ErrandNameBase+i].status=SS_Off;
            if(i>BriefErrand || (i==BriefErrand && BriefStage<3)) Sprites[ErrandLocBase+i].status=SS_Off;
        }
}

function AdvanceBriefing()
{
    local float Duration;
    if(BriefStage==0)
    {
        BriefErrand++;
        while(BriefErrand<SetupNumErrands && (BriefMask & (1<<BriefErrand))==0) BriefErrand++;
        if(BriefErrand>=SetupNumErrands)
        {
            bBriefing=false; FadeSprite=-1;
            Log("PLBRIEF|finished");
            return;
        }
        FadeSprite=ErrandNameBase+BriefErrand;
        Duration=BriefSound(BriefDay.GetErrandStartComment(BriefErrand));
    }
    else if(BriefStage==1)
    {
        FadeSprite=-1;
        if(BriefDay.IsLocationTexActive(BriefErrand)) Duration=BriefSound(BriefDay.GetErrandWhereComment(BriefErrand));
    }
    else if(BriefStage==2)
    {
        if(BriefDay.IsLocationTexActive(BriefErrand))
        {
            FadeSprite=ErrandLocBase+BriefErrand;
            Duration=BriefSound(BriefDay.GetErrandFoundComment(BriefErrand));
        }
    }
    else {FadeSprite=-1; Duration=0.7; BriefMask=BriefMask & ~(1<<BriefErrand);}
    BriefStage=(BriefStage+1)%4;
    FadeStarted=ViewportOwner.Actor.Level.TimeSecondsAlways;
    NextBriefTime=FadeStarted+FMax(0.6,Duration);
}

function PostRender(Canvas C)
{
    if(bBriefing && ViewportOwner.Actor!=None)
    {
        ViewportOwner.Actor.bWantsToSkip=0;
        bEnableShow=true;
        if(ViewportOwner.Actor.Level.TimeSecondsAlways>=NextBriefTime) AdvanceBriefing();
        SetupErrands(CoopGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo));
    }
    Super.PostRender(C);
}

function MapReset()
{
    bBriefing=false; BriefDay=None;
    Super.MapReset();
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
                if(bBriefing && s==FadeSprite) alpha=255*FClamp((ViewportOwner.Actor.Level.TimeSecondsAlways-FadeStarted)/0.7,0,1);
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

defaultproperties
{
    GameClass=class'PLGameInfo'
    FadeSprite=-1
}

