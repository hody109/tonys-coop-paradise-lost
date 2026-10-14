//=============================================================================
// CoopBrowserJoinScreenshotCW.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinScreenshotCW extends UBrowserScreenshotCW;

var string MapGameType;

var localized string CoopMapNameText;
var localized string CoopAuthorByText;
var localized string CoopServerCompatibleText;

var Texture DefaultScreenshot;

function Paint(Canvas C, float MouseX, float MouseY)
{
	local float X, Y, W, H;
	local int i;
	local string M;
	local UBrowserServerList L;
	local Object LevSumObject;
	local LevelSummary LevSum;
	local bool bNicksCoop;

	L = UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server;

	bNicksCoop = false;

	if( L != None )
	{
		M = L.MapName;
		if( M != MapName )
		{
			MapName = M;
			if( MapName == "" )
			{
				ScreenShot = None;
				MapTitle = "";
				MapAuthor = "";

				MapGameType = "";
			}
			else
			{
				// RWS Change:  .UNR -> .FUK
				i = InStr(Caps(MapName), ".FUK");
				if(i != -1)
					MapName = Left(MapName, i);

				//Screenshot = Texture(DynamicLoadObject(MapName$".Screenshot", class'Texture'));
				LevSumObject = DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary', true);
				if(LevSumObject != None && LevelSummary(LevSumObject) != None)
				{
					LevSum = LevelSummary(LevSumObject);

					MapTitle = LevSum.Title;
					MapAuthor = CoopAuthorByText @ LevSum.Author;
					Screenshot = Texture(LevSum.Screenshot);

					if( (InStr(caps(L.GameType), "NICKSCOOP") != -1) )
					{
						bNicksCoop = true;

						if( MapAuthor != "" )
						{
							if( (InStr(caps(MapAuthor), "ANONYMOUS") != -1) )
								MapAuthor = "";
						}
						if( Screenshot == None )
							Screenshot = DefaultScreenshot;
						MapGameType = CoopServerCompatibleText;
					}

					if( MapTitle ~= "Untitled" )
						MapTitle = MapName;
					MapTitle = CoopMapNameText @ MapTitle;
				}
				else
				{
					ScreenShot = None;
					MapTitle = "";
					MapAuthor = "";

					MapGameType = "";
				}
			}
		}
	}
	else
	{
		ScreenShot = None;
		MapName = "";
		MapTitle = "";
		MapAuthor = "";

		MapGameType = "";
	}

	Super(UWindowClientWindow).Paint(C, X, Y);
	//DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');

	if(Screenshot != None)
	{
		DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');

		W = Min(WinWidth, Screenshot.USize);
		H = Min(WinHeight, Screenshot.VSize);
		
		if(W > H)
			W = H;
		if(H > W)
			H = W;

		X = (WinWidth - W) / 2;
		Y = (WinHeight - H) / 2;
			
		DrawStretchedTexture(C, X, Y, W, H, Screenshot);
		
		C.Font = Root.Fonts[F_Normal];

		if( MapAuthor != "")
		{
			TextSize(C, MapAuthor, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*2;
			C.SetDrawColor(0,0,0);
			ClipText(C, X+1.0, Y+1.0, MapAuthor);
			C.SetDrawColor(255,255,255);
			ClipText(C, X, Y, MapAuthor);
		}

		if(MapTitle != "")
		{
			TextSize(C, MapTitle, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*3;
			C.SetDrawColor(0,0,0);
			ClipText(C, X+1.0, Y+1.0, MapTitle);
			C.SetDrawColor(255,255,255);
			ClipText(C, X, Y, MapTitle);
		}

		if( MapGameType != "" )
		{
			TextSize(C, MapGameType, W, H);
			X = (WinWidth - W) / 2;
			Y = WinHeight - H*4;
			C.SetDrawColor(0,0,0);
			ClipText(C, X+1.0, Y+1.0, MapGameType);
			C.SetDrawColor(128,128,255);
			ClipText(C, X, Y, MapGameType);
		}
	}	
}

defaultproperties
{
	CoopMapNameText="Map name:"
	CoopAuthorByText="Map author:"
	CoopServerCompatibleText="-NicksCoop compatible game-"

	DefaultScreenshot=Texture'slaughterhouse-sw.Trans.greenbelt1-a-stv'
}