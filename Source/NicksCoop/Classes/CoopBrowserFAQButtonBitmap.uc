//=============================================================================
// CoopBrowserFAQButtonBitmap.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopBrowserFAQButtonBitmap extends UWindowBitmap
	config;

var Texture ButtonIconTexture;
var Texture ButtonIconTextureActive;
var Texture ButtonIconTextureNotify;

///steam 29/07/2016
var globalconfig bool bFirstStartNotify;
var float fNotifyTime;
var bool bNotifyActive;
var bool bNotifyOn;

const NicksCoop_SetGamesURL = "http://www.set-games.ru/index/nickscoop/0-30";

function Created() 
{
	bNotifyOn = bNotifyOn || bFirstStartNotify;
	Super.Created();
}

function RMouseDown(float X, float Y)
{
	super.RMouseDown(X, Y);

	// STUBED
	//GetPlayerOwner().ConsoleCommand("start "$NicksCoop_SetGamesURL);
}

function LMouseDown(float X, float Y)
{
	super.LMouseDown(X, Y);

	CoopShellRootWindow(Root).FAQButtonPressed();
	if( bFirstStartNotify )
	{
		bFirstStartNotify = false;
		SaveConfig();
		bNotifyOn = false;
	}
}

function MouseEnter()
{
	Super.MouseEnter();
	T = ButtonIconTextureActive;//Texture(class'Actor'.default.Texture);
}

function MouseLeave()
{
	Super.MouseLeave();
	T = ButtonIconTexture;
}

function CalledByOwnerMenu()
{
	T = ButtonIconTexture;
}

///steam 29/07/2016
function CallSetNotifyBitmap(bool bState)
{
	if( T == None )
		return;
	if( T != ButtonIconTextureActive )
	{
		if( bState )
		{
			if( T != ButtonIconTextureNotify )
				T = ButtonIconTextureNotify;
		}
		else
		{
			if( T != ButtonIconTexture )
				T = ButtonIconTexture;
		}
	}
	///Root.ViewportOwner.Actor.ClientMessage(bState);
}

function Paint(Canvas C, float X, float Y)
{
	Super.Paint(C, X, Y);

	if( bNotifyOn )
	{
		if( Root != None && Root.ViewportOwner.Actor != None && !Root.ViewportOwner.Actor.bDeleteMe )///steam 29/07/2016
		{
			if( Root.ViewportOwner.Actor.Level.TimeSecondsAlways > fNotifyTime )
			{
				bNotifyActive = !bNotifyActive;
				fNotifyTime = Root.ViewportOwner.Actor.Level.TimeSecondsAlways + 0.5;
			}
		}
	}
	CallSetNotifyBitmap(bNotifyActive && bNotifyOn);

	/*C.SetDrawColor(0, 255, 0, 255);
	C.SetPos(0, 0);
	C.DrawBox(C, WinWidth, WinHeight);
	C.DrawVertical(WinWidth / 2, WinHeight);	// RWS CHANGE: 02/16/03 JMI Added center line for testing centering.
	C.SetDrawColor(255, 255, 255, 255);*/
}

function BeforePaint(Canvas C, float X, float Y)
{
	WinLeft = C.SizeX/2-ParentWindow.WinLeft-WinWidth/2 + C.SizeX*0.4;
	WinTop = C.SizeY/2-ParentWindow.WinTop-WinHeight/2 + C.SizeY*0.4;

	Super.BeforePaint(C, X, Y);
}

defaultproperties
{
	bFirstStartNotify=true
	//bAlwaysBehind=true
	//bAlwaysOnTop=true
	ButtonIconTexture=Texture'NicksCoop.GUI.FAQ_button'
	ButtonIconTextureActive=Texture'NicksCoop.GUI.FAQ_button_active'
	ButtonIconTextureNotify=Texture'NicksCoop.GUI.FAQ_button_notify'
}