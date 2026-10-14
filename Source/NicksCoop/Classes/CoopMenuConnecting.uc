//=============================================================================
// CoopMenuConnecting.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMenuConnecting extends MenuConnecting;

function CreateMenuContents()
{
	Super(ShellMenuCW).CreateMenuContents();

	TitleAlign = TA_Center;
	ItemAlign = TA_Center;
	//AddTitle(ConnectingText, TitleFont, TitleAlign);
	Message1 = AddTextItem(Msg1, "", F_FancyM);
	Message1.bActive = false;
	Message1.Align = TA_Center;
	Message1.ValueAlign = TA_Center;
	Message2 = AddTextItem(Msg2, "", F_FancyM);
	Message2.bActive = false;
	Message2.Align = TA_Center;
	Message2.ValueAlign = TA_Center;
	CancelChoice = AddChoice(CancelText, "", ItemFont, ItemAlign, true);

	//BackChoice = AddChoice(BackText, "", ItemFont, ItemAlign, true);

	GetPlayerOwner().ClearProgressMessages();
	ShellRootWindow(Root).bLaunchedMultiplayer = true;

	InitialLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(InitialLevel, 4) ~= ".fuk")
		InitialLevel = Left(InitialLevel, Len(InitialLevel) - 4);
}

function SetStatus(string M1, string M2, bool bDownloading)
{
	local string Server, Map, MapFileName;
	local int i;

	if(bDownloading)
		bReceivingFile = true;

	if(!bReceivingFile || (bDownloading && bReceivingFile))
	{
		Msg1 = M1;
		Msg2 = M2;
		if(bDownloading)	// Receiving a file, keep messages the same
		{
			Message1.SetText(Msg1);
			Message2.SetText(Msg2);
		}
		else				// Connecting to server, separate out the address and map
		{
			Server = Msg2;
			if(InStr(Caps(Server), Caps("postal2://")) != -1)
				Server = Right(Server, Len(Server) - 10);
			Map = Right(Server, Len(Server) - InStr(Server, "/") - 1);
			MapFileName = Map;
			Map = class'MultiBase.MpGameInfo'.static.CleanMapName(Map);
			Server = Left(Server, InStr(Server, "/"));
			Message1.SetText(Server);

			if( CoopShellRootWindow(Root).CoopLoadMapName != "" )
				Map = CoopShellRootWindow(Root).CoopLoadMapName;
			else if( Map ~= "Index" || Map ~= "Entry" )
				Map = "";
			else Map = MapFileName;

			if( Map == "" )
				Map = "Undefined";

			Message2.SetText(Map);
		}
	}
}

///steam 25/11/2016
function GoBack()
{
	local string CurrentLevel, GamePath;

	CurrentLevel = ShellRootWindow(Root).ParseLevelName(Root.GetLevel().GetLocalURL());
	if(Right(CurrentLevel, 4) ~= ".fuk")
		CurrentLevel = Left(CurrentLevel, Len(CurrentLevel) - 4);

	if(GetGameSingle() != None && Caps(CurrentLevel) != Caps(ShellRootWindow(Root).GetStartupMap()))	// SINGLEPLAYER
		GetGameSingle().QuitGame();
	else																	// MULTIPLAYER
		{
		if(CurrentLevel ~= "Entry")
			{
			GetPlayerOwner().ConsoleCommand("disconnect");
			P2RootWindow(Root).HideMenu();
			// RWS FIXME: Read the game type value from ini
			//GamePath = "GameTypes.GameSinglePlayer";
			GamePath = CoopShellRootWindow(Root).xGetCoopGamePath();
			if( GamePath == "" )
				GamePath = "NicksCoop.CoopGameInfoMenu";
			GetPlayerOwner().ClientTravel(ShellRootWindow(Root).GetStartupMap()$".fuk?Mutator=?Workshop=0?Game=" $ GamePath, TRAVEL_Absolute, false);
			}
		}
	P2RootWindow(Root).EnableMenu();
	Super(ShellMenuCW).GoBack();
}

defaultproperties
{
	TitleHeight=200
}

