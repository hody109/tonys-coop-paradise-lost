//=============================================================================
// CoopShellRootWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2015.
//=============================================================================

class CoopShellRootWindow extends ShellRootWindow
	config;

///steam 01/08/2016
var Texture WaitIcon;

///steam 11/05/2016
var class<CoopMenu> CoopMenuClass;

///steam 18/03/2016
///added support of Unreal windows
var array<UWindowWindow> UnrealWindowsStack;

var CoopBrowserFAQButtonBitmap FAQButton;
var CoopBrowserFAQWindow FAQBrowserWindow;

var class<BaseMenuBig> xMainMenuClass, xGameMenuClass, xMultiMenuClass;
var bool bAllowMouse;
var bool bDisableMainStatusMsg;

var string CoopLoadMapName;
var string CoopLookAndFeelClass;
var localized string CoopConnectingMessage;
var localized string CoopLoadingMessage;
var string CoopErrorMessage;

var string stestmsg;

var Texture CoopLoadingLayerTex; // Additional layer texture over loading screen, might be None
var Texture CoopLoadingBlackTex; // Do not modify the value, should be shown all the time

function class<BaseMenuBig> GetMainMenuClass()
{
	return xMainMenuClass;
}

state GameMenuShowing
{
	function BeginState()
	{
		local String CurRes;

		bGameMenu = true;

		//Super.BeginState();

		if(P2GameInfoSingle(Root.GetLevel().Game) != None)
			CreateMenu(xGameMenuClass);
		else CreateMenu(xMultiMenuClass);

		bAllowConsole = false;

		// If current res is less than minimum res then switch to the min res
		// here and restore original resolution when state ends.
		CurRes = ViewportOwner.Actor.ConsoleCommand("GetCurrentRes");
		if (IsBelowMinRes(CurRes))
		{
			SetLowGameRes(CurRes);
			ViewportOwner.Actor.ConsoleCommand("SetRes "$MinRes);
		}

		if (!bAllowConsole && (MyMenu != None))
			MyMenu.ShowWindow();

		// Add code to initialize the uwindows system
	
		bVisible 		= true;
		bRequiresTick 	= true;
		
		bWindowVisible = True;
		bUWindowActive = true;

		ViewportOwner.bShowWindowsMouse = True;
		ViewportOwner.bSuspendPrecaching = True;

		// RWS CHANGE: Added flag to allow extended classes to block pausing
		if (ViewportOwner.Actor.Level.NetMode == NM_Standalone && !bDontPauseOrUnPause)
			ViewportOwner.Actor.SetPause( True );

		if (bAllowConsole && ConsoleWindow != None)
			ConsoleWindow.ShowWindow();
	}
}

function SetLoadingTexture(string MapName)
{
	local Object LevSumObject;
	local LevelSummary LevSum;
	local int i;

	MapName = ParseLevelName(MapName);
	i = InStr(Caps(MapName), ".FUK");
	if(i != -1)
		MapName = Left(MapName, i);

	LevSumObject = DynamicLoadObject(MapName$".LevelSummary", class'LevelSummary', true);
	if(LevSumObject != None && LevelSummary(LevSumObject) != None && Caps(MapName) != Caps(GetStartupMap()) && Caps(MapName) != Caps("entry") && Caps(MapName) != Caps("index"))
	{
		LevSum = LevelSummary(LevSumObject);
		if(Texture(LevSum.Screenshot) != None)
			LoadingTexture = Texture(LevSum.Screenshot);
		else
			LoadingTexture = Default.LoadingTexture;
		if( LevSum.Title != "" && LevSum.Title != "None" && LevSum.Title != "Index" && LevSum.Title != "Entry" )
			CoopLoadMapName = LevSum.Title;
	}
	else if( (LevSumObject == None || LevelSummary(LevSumObject) == None)  && Caps(MapName) != Caps(GetStartupMap()) && Caps(MapName) != Caps("entry") && Caps(MapName) != Caps("index"))
		LoadingTexture = Default.LoadingTexture;
}

///steam 01/08/2016
singular function DrawMainStatusMessage(canvas Canvas, bool bOnlyIndicator)
{
	local string sMessage;

	if( bDisableMainStatusMsg )
		return;

	///steam 01/08/2016
	xDrawLoadingIndicator(Canvas);

	///steam 01/08/2016
	if( bOnlyIndicator )
		return;

	if( !IsInState('MenuShowing') )
	{
		if( Root.GetLevel().LevelAction == LEVACT_Connecting )
			sMessage = CoopConnectingMessage;
		else sMessage = CoopLoadingMessage;
	}
	else sMessage = CoopConnectingMessage;

	if( MenuError(MyMenu) != None && CoopErrorMessage != "" )
		sMessage = CoopErrorMessage;

	if( sMessage != "" )
		DrawStatusMessage(Canvas, sMessage);
}

///steam 01/08/2016 draw it here, instead of CoopHUD.uc
simulated function xDrawLoadingIndicator(Canvas Canvas)
{
	local float X, Y, W;
	local float lScale;
	local Texture useWaitIcon;

	useWaitIcon = WaitIcon;

	if( useWaitIcon == None )
		return;

	W = 0.1 * Canvas.ClipY;
	lScale = W / useWaitIcon.USize;

	X = (Canvas.ClipX * 0.5);
	Y = (Canvas.ClipY * 0.3);

	Canvas.bNoSmooth = true;
	Canvas.Style = 5;///ERenderStyle.STY_Alpha;
	Canvas.SetDrawColor(255,255,255,150);
	Canvas.SetPos(X-(lScale*useWaitIcon.USize/2),Y-(lScale*useWaitIcon.VSize/2));
	Canvas.DrawIcon(useWaitIcon, lScale);
}

///steam 23/02/2016
function PostRender(canvas Canvas)
{
	local int i;
	local float XL, YL, XPos;
	local string CurrentLevel;
	local LevelInfo LI;

	bAllowMouse = true;

	// If we're in entry, hide the level with a background for multiplayer only
	LI = Root.GetLevel();
	CurrentLevel = ParseLevelName(LI.GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);
	if((CurrentLevel ~= "Entry" || CurrentLevel ~= "Index") /*&& bLaunchedMultiplayer*/)
	{
		///steam 23/02/2016
		/*if(LoadingTexture.USize == 0 || LoadingTexture.VSize == 0)
		{
			i = InStr(LoadingTexture, ".");
			SetLoadingTexture(Left(LoadingTexture, i));
		}
		Canvas.Style = 1; //ERenderStyle.STY_Normal;
		Canvas.SetDrawColor(255, 255, 255, 255);
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(LoadingTexture, Canvas.ClipX, Canvas.ClipY, 0, 0, LoadingTexture.USize, LoadingTexture.VSize);*/

		// 10/10/22 - In some cases we still getting this flickering image when loading, so try to hide it
		if (CoopLoadingBlackTex != None)
		{
			Canvas.Style = 1; //ERenderStyle.STY_Normal;
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.SetPos(0, 0);
			Canvas.DrawTile(CoopLoadingBlackTex, Canvas.ClipX, Canvas.ClipY, 0, 0, CoopLoadingBlackTex.USize, CoopLoadingBlackTex.VSize);
		}

		// 10/10/22 - Additional layer to show some extra image when loading
		if (CoopLoadingLayerTex != None)
		{
			XL = Canvas.ClipY * 1.3;
			YL = Canvas.ClipY;
			XPos = (Canvas.ClipX - XL) * 0.5;
			Canvas.Style = 1; //ERenderStyle.STY_Normal;
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.SetPos(XPos, 0);
			Canvas.DrawTile(CoopLoadingLayerTex, XL, YL, 0, 0, CoopLoadingLayerTex.USize, CoopLoadingLayerTex.VSize);
		}

		///steam 04/04/2016
		if( MenuError(MyMenu) != None )
		{
			if (CoopLoadingBlackTex != None)
			{
				Canvas.Style = 1; //ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255, 255, 255, 255);
				Canvas.SetPos(0, 0);
				Canvas.DrawTile(CoopLoadingBlackTex, Canvas.ClipX, Canvas.ClipY, 0, 0, CoopLoadingBlackTex.USize, CoopLoadingBlackTex.VSize);
			}
			else if (LoadingTexture != None)
			{
				Canvas.Style = 1; //ERenderStyle.STY_Normal;
				Canvas.SetDrawColor(255, 255, 255, 255);
				Canvas.SetPos(0, 0);
				Canvas.DrawTile(LoadingTexture, Canvas.ClipX, Canvas.ClipY, 0, 0, LoadingTexture.USize, LoadingTexture.VSize);
			}
		}
		else bAllowMouse = false;

		if(MenuConnecting(MyMenu) != None && Root.GetLevel().LevelAction == LEVACT_Connecting)
		{
			MyMenu.Close();
			MyMenu = None;
			HideMenu();
		}

		// Check if we're connecting and show connecting or loading text
		//DrawMainStatusMessage(Canvas); ///steam 18/03/2016 moved below...
		if(!IsInState('MenuShowing'))
		{
			if( !(Root.GetLevel().LevelAction == LEVACT_Connecting) )
			{
				if(!bDisabled)
					DisableMenu();
			}
		}

		bShowedLoadTexture = true;
	}
	else if(bShowedLoadTexture && CAPS(CurrentLevel) != CAPS(GetStartupMap()))
	{
		LoadingTexture = Default.LoadingTexture;
		bShowedLoadTexture = false;
	}

	///steam 18/03/2016 moved from ^...
	if( CurrentLevel ~= "Entry" || CurrentLevel ~= "Index" || MenuConnecting(MyMenu) != None )
		DrawMainStatusMessage(Canvas, false);
	
	// Draw Workshop status updates always, no matter what's happening
	DrawWorkshopStatus(Canvas);

	if(IsInState('MenuShowing'))
	{
		Super(P2RootWindow).PostRender(Canvas);

		if (MyFont == None)
			MyFont = FontInfo(ViewportOwner.Actor.spawn(Class<Actor>(DynamicLoadObject(FontInfoClass, class'Class')),ViewportOwner.Actor));

		// Display info about installed game
		if (MyMenu.class == GetMainMenuClass() || MyMenu.class == class'MenuGame')
			{
			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				VERSION_TEXT_X * Canvas.ClipX,
				VERSION_TEXT_Y * Canvas.ClipY,
				InstalledDescription$"-"$EngineVersion$HotfixText,
				0, true, EJ_Left);

			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				COPYRIGHT_TEXT_X * Canvas.ClipX,
				COPYRIGHT_TEXT_Y * Canvas.ClipY,
				"Copyright 2003-2015 RWS  All Rights Reserved",
				0, true, EJ_Right);
			}
		
		if (HelpText != "")
			{
			MyFont.DrawTextEx(
				Canvas,
				Canvas.ClipX,
				COPYRIGHT_TEXT_X * Canvas.ClipX,
				COPYRIGHT_TEXT_Y * Canvas.ClipY,
				HelpText,
				0, true, EJ_Right);
			}

		if (bPrecache)
			{
			// Hide precache by covering the screen with a black box
			Canvas.Style = 1; //ERenderStyle.STY_Normal;
			Canvas.SetDrawColor(255, 255, 255, 255);
			Canvas.SetPos(0, 0);
			Canvas.DrawTile(BlackBox, Canvas.SizeX, Canvas.SizeY, 0, 0, BlackBox.USize, BlackBox.VSize);

			bDidPrecache = true;
			}
	}

	if( stestmsg != "" )
	{
		MyFont.DrawTextEx(
					Canvas,
					Canvas.ClipX,
					Canvas.ClipX,
					0.5 * Canvas.ClipY,
					stestmsg,
					0, true, EJ_Right);
	}
}

function DrawMouse(Canvas C) 
{
	local float X, Y;

	if(ViewportOwner.bWindowsMouseAvailable)
	{
		// Set the windows cursor...
		ViewportOwner.SelectedCursor = MouseWindow.Cursor.WindowsCursor;
	}
	else if( bAllowMouse && !bUsingJoystick ) // Don't draw mouse if using D-pad to navigate.
	{
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		C.DrawColor.A = 255;	// RWS CHANGE: Must be 255 or cursor won't show up in full screen mode
		C.bNoSmooth = True;
		C.Style=2;
		C.SetPos(MouseX * GUIScale - MouseWindow.Cursor.HotX, MouseY * GUIScale - MouseWindow.Cursor.HotY);
		C.DrawIcon(MouseWindow.Cursor.tex, 1.0);
		C.Style=1;
	}
}

function GoToConnectingWindow(string Msg1, string Msg2, bool bDownloading)
{
	if(MenuError(MyMenu) != None || MenuUpgrade(MyMenu) != None || MenuPassword(MyMenu) != None)
		return;

	if(MenuConnecting(MyMenu) != None)
	{
		if(InStr(Caps(Msg2), Caps("Index")) == -1)
			MenuConnecting(MyMenu).SetStatus(Msg1, Msg2, bDownloading);
		return;
	}

	FreshJumpToMenu(class'CoopMenuConnecting');

	SetLoadingTexture(Msg2);
	MenuConnecting(MyMenu).SetStatus(Msg1, Msg2, bDownloading);
}

function Created()
{
	local class<P2GameInfoSingle> myGameType;
	local Texture myTitleTexture;

	LookAndFeelClass = CoopLookAndFeelClass;

	///steam 04/01/2017
	myGameType = class<P2GameInfoSingle>(CoopMenuClass.default.ServerGameType);
	if( myGameType != None )
		myTitleTexture = Texture(DynamicLoadObject(String(myGameType.default.MenuTitleTex), class'Texture'));
	if( myTitleTexture != None )
	{
		xMainMenuClass.default.TitleTexture = myTitleTexture;
		xGameMenuClass.default.TitleTexture = myTitleTexture;
		xMultiMenuClass.default.TitleTexture = myTitleTexture;
	}

	Super.Created();
}

///steam 17/03/2016
function xRegisterUnrealWindow(UWindowWindow newWindow)
{
	local int i;

	if( newWindow != None )
	{
		i = UnrealWindowsStack.Length;
		UnrealWindowsStack.Insert(i, 1.0);
		UnrealWindowsStack[i] = newWindow;
	}
	log("xRegisterUnrealWindow"@newWindow);
}
function xRemoveUnrealWindow(UWindowWindow myWindow)
{
	/*local int i;

	log("xRemoveUnrealWindow called"@myWindow);

	if( myWindow == None )
		return;

	//for( i = 0 ; i < UnrealWindowsStack.Length ; i++ )
	//	log("xRemoveUnrealWindow preload"@UnrealWindowsStack[i]);

	for( i = 0 ; i < UnrealWindowsStack.Length ; i++ )
	{
		if( UnrealWindowsStack[i] != None && UnrealWindowsStack[i] == myWindow )
		{
			UnrealWindowsStack.Remove(i, 1.0);
			break;
		}
	}

	//for( i = 0 ; i < UnrealWindowsStack.Length ; i++ )
	//	log("xRemoveUnrealWindow postload"@UnrealWindowsStack[i]);*/
}
function xRemoveAllUnrealWindows()
{
	local int i;

	if( FAQButton != None )
	{
		FAQButton.Close();
		FAQButton = None;
	}

	log("xRemoveAllUnrealWindows search"@UnrealWindowsStack.Length);

	//for( i = 0 ; i < UnrealWindowsStack.Length ; i++ )
	//	log("xRemoveAllUnrealWindows preload"@UnrealWindowsStack[i]);

	if( UnrealWindowsStack.Length > 0 )
	{
		for( i = 0 ; i < UnrealWindowsStack.Length ; i++ )
		{
			if( UnrealWindowsStack[i] != None )
			{
				UnrealWindowsStack[i].Close();
				UnrealWindowsStack[i] = None;
			}
		}
		///UnrealWindowsStack.Length = 0;
		///steam 15/01/2017 arrays usage fixed
		if( UnrealWindowsStack.Length > 0 )
		{
			UnrealWindowsStack.Remove(0,UnrealWindowsStack.Length);
			UnrealWindowsStack.Length = 0;
		}
	}

	//for( i = 0 ; i < UnrealWindowsStack.Length ; i++ )
	//	log("xRemoveAllUnrealWindows postload"@UnrealWindowsStack[i]);

	log("xRemoveAllUnrealWindows search"@UnrealWindowsStack.Length);
}
///steam 17/03/2016
function GoToWindow(UWindowWindow newWindow)
{
	local bool bSameWindow;
	///if (MyMenu != None)
	///	MyMenu.HideWindow();
	///openWindow = newWindow;
	if( !newWindow.IsA('CoopBrowserFAQWindow') )
	{
		bSameWindow = (newWindow.class == openWindow.class);
		if( openWindow != None )
		{
			if( !bClosing )
			{
				bClosing = true;
				openWindow.Close();
				openWindow = None;
				bClosing = false;
			}
		}
		if( !bSameWindow )
			openWindow = newWindow;
	}
	else xRegisterUnrealWindow(newWindow);
}
function GoToWindowClosed(UWindowWindow myWindow)
{
	xRemoveUnrealWindow(myWindow);
}
///steam 18/03/2016
function FreshJumpToMenu(class<ShellMenuCW> MenuClass)
{
	xRemoveAllUnrealWindows();
	Super.FreshJumpToMenu(MenuClass);
}
///steam 18/03/2016
function HideMenu()
{
	xRemoveAllUnrealWindows();
	Super.HideMenu();
}

///steam 23/03/2016
function CreateMenu(class<ShellMenuCW> clsMenu)
{
	Super.CreateMenu(clsMenu);
	if( !ClassIsChildOf(clsMenu, class'MenuConnecting') && !ClassIsChildOf(clsMenu, class'MenuError') )
	{
		if( FAQButton == None )
			AddFAQButton();
	}
	else if( FAQButton != None )
	{
		FAQButton.Close();
		FAQButton = None;
	}
}

function AddFAQButton()
{
	local CoopBrowserFAQButtonBitmap ctl;

	ctl = CoopBrowserFAQButtonBitmap(CreateWindow(class'CoopBrowserFAQButtonBitmap', 0, 0, 64, 64));
	if( ctl != None )
	{
		ctl.bFit = true;
		ctl.bAlpha = true;
		ctl.CalledByOwnerMenu();
		ctl.R.X = 0;
		ctl.R.Y = 0;
		ctl.R.W = ctl.T.USize;
		ctl.R.H = ctl.T.VSize;
		FAQButton = ctl;
	}
}

function FAQButtonPressed()
{
	FAQBrowserWindow = CoopBrowserFAQWindow(CreateWindow(class'CoopBrowserFAQWindow', 50, 30, 500, 300));
	FAQBrowserWindow.SelectFAQPage();
	GotoWindow(FAQBrowserWindow);
}

///steam 29/03/2016
function GoToErrorWindow(string Msg1, string Msg2, optional bool bLock)
{
	// 5024 change 2020: we don't use CoopMenuError anymore
	CoopErrorMessage = Msg1;

	Super.GoToErrorWindow(Msg1, Msg2, bLock);
}

///steam
function GoToPasswordWindow(string URL)
{
	if(MenuError(MyMenu) != None)
		MyMenu.Close();

	// If the user cancels, let them go back to the multiplayer menu
	if(IsGameMenu())
		FreshJumpToMenu(xMultiMenuClass);//class'MenuGameMulti');
	else
		FreshJumpToMenu(xMainMenuClass);//class'MenuMulti');

	GoToMenu(MyMenu.class, class'MenuPassword');

	MenuPassword(MyMenu).URL = URL;
}

///steam 02/08/2016 wtf restarts game, stubbed
function execConfirmButton()
{
	//ViewportOwner.Actor.ClientMessage("execConfirmButton");
}

///steam 19/11/2016
function CoopQuitCurrentGame()
{
	if( IsGameMenu() )
		CoopForceQuitCurrentGame();
}

///steam 25/11/2016
function string xGetCoopGamePath()
{
	local string GamePath;
	GamePath = CoopMenuClass.default.CoopMenuGameInfoClass;
	if( GamePath == "" )
		return "NicksCoop.CoopGameInfoMenu";
	return GamePath;
}

///steam 19/11/2016 this function is the same as QuitCurrentGame() in ShellRootWindow.uc
function CoopForceQuitCurrentGame()
{
	local string GamePath;

	ViewportOwner.Actor.ConsoleCommand("CINEMATICS 0");
	GetPlayerOwner().ConsoleCommand("disconnect");
	EndingGame();
	GamePath = xGetCoopGamePath();
	GetPlayerOwner().ClientTravel(GetStartupMap()$".fuk?Mutator=?Workshop=0?Game=" $ GamePath, TRAVEL_Absolute, false);
}

///steam 25/11/2016
function string GetStartupMap()
{
	local class<P2GameInfoSingle> GameType;
	if( GetGameSingle() != None )
		return GetGameSingle().MainMenuURL;
	GameType = class<P2GameInfoSingle>(CoopMenuClass.default.ServerGameType);
	if( GameType != None )
		return GameType.default.MainMenuURL;
	return "startup";
}

///steam 06/02/2017
function string GetNicksCoopBuild()
{
	local string sAddonBuild;
	if( CoopMenuClass.default.NicksCoopAddonBuildString != "" )
		sAddonBuild = CoopMenuClass.default.NicksCoopAddonBuildString;
	return CoopMenuClass.default.NicksCoopBuildString$sAddonBuild;
}

defaultproperties
{
	CoopLoadingLayerTex=None
	CoopLoadingBlackTex=Texture'nathans.Inventory.blackbox64'
	WaitIcon=Texture'NicksCoop.WaitHUD.wait_icon_00'

	CoopMenuClass=class'CoopMenu'
	CoopLookAndFeelClass="NicksCoop.CoopShellLookAndFeel"
	CoopConnectingMessage="Connecting"
	CoopLoadingMessage="Loading"
	LoadingTexture=Texture'P2Misc.Background.flames'
	xMainMenuClass=class'NicksCoop.CoopMenuMain'
	xGameMenuClass=class'NicksCoop.CoopMenuGame'
	xMultiMenuClass=class'NicksCoop.CoopMenuGameMulti'
}
