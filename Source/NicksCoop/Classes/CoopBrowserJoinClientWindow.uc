//=============================================================================
// CoopBrowserJoinClientWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinClientWindow extends UBrowserMainClientWindow;

var UWindowPageControlPage JoinDirectPage;

var globalconfig string	DefCoopALLTabName;
var localized string DefCoopALLName;
var localized string DefCoopALLDesc;

var globalconfig string	DefNicksCoopTabName;
var localized string DefNicksCoopName;
var localized string DefNicksCoopDesc;

var string JoinDirectClass;
var localized string JoinDirectName;

function Created() 
{
	local int i, j;
	local UWindowPageControlPage P;
	local UBrowserServerListWindow W;
	local class<UBrowserServerListWindow> C;
	local class<UBrowserFavoriteServers> FC;
	local class<UBrowserUpdateServerWindow> MC;
	local string NextWindowClass, NextWindowDesc;
	local class<CoopBrowserJoinDirectWindow> JoinDirectWindowClass;
	local string sTempCaption;

	Super(UWindowClientWindow).Created();

	InfoWindow = UBrowserInfoWindow(Root.CreateWindow(class'CoopBrowserJoinInfoWindow', 10, 40, 310, 170));
	InfoWindow.HideWindow();

	PageControl = UWindowPageControl(CreateWindow(class'UWindowPageControl', 0, 0, WinWidth, WinHeight));
	PageControl.SetMultiLine(True);

	// Add MOTD
	/// 02/05/21 - Removed due to developerfuntime down
//	MC = class<UBrowserUpdateServerWindow>(DynamicLoadObject(UpdateServerClass, class'Class'));
//	MOTD = PageControl.AddPage(MOTDName, MC);

//	IRC = PageControl.AddPage(IRCName, class'UBrowserIRCWindow');

	JoinDirectWindowClass = class<CoopBrowserJoinDirectWindow>(DynamicLoadObject(JoinDirectClass, class'Class'));
	JoinDirectPage = PageControl.AddPage(JoinDirectName, JoinDirectWindowClass);

	// Add favorites
	FC = class<UBrowserFavoriteServers>(DynamicLoadObject(FavoriteServersClass, class'Class'));
	Favorites = PageControl.AddPage(FavoritesName, FC);
	if( CoopBrowserFavoriteServers(Favorites.Page) != None )
		CoopBrowserFavoriteServers(Favorites.Page).UpdatePageHeaderText();

	C = class<UBrowserServerListWindow>(DynamicLoadObject(ServerListWindowClass, class'Class'));

	for(i=0; i<50; i++)
	{
		if(ServerListNames[i] == '')
			break;

		P = PageControl.AddPage("", C, ServerListNames[i]);
		if(string(ServerListNames[i]) ~= LANTabName)
			LANPage = P;

		W = UBrowserServerListWindow(P.Page);
		if(W.bHidden)
			PageControl.DeletePage(P);

		if(W.ServerListTitle != "")
			P.SetCaption(W.ServerListTitle);
		else
		{
			sTempCaption = Localize("ServerListTitles", string(ServerListNames[i]), "MultiplayerInfo");
			if( Left(sTempCaption,2) ~= "<?" )
			{
				sTempCaption = Localize("ServerListTitles", string(ServerListNames[i]), "NicksCoop");
				if( Left(sTempCaption,2) ~= "<?" )
				{
					// if( string(ServerListNames[i]) ~= DefCoopALLTabName )
					// {
						// sTempCaption = DefCoopALLName;
						// if( CoopBrowserJoinServerListWindow(W) != None )
							// CoopBrowserJoinServerListWindow(W).UpdatePageHeaderText(DefCoopALLDesc);
					// }
					if( string(ServerListNames[i]) ~= DefNicksCoopTabName )
					{
						sTempCaption = DefNicksCoopName;
						if( CoopBrowserJoinServerListWindow(W) != None )
							CoopBrowserJoinServerListWindow(W).UpdatePageHeaderText(DefNicksCoopDesc);
					}
					else sTempCaption = ""$ServerListNames[i];
				}
			}
			P.SetCaption(sTempCaption);
		}

		FactoryWindows[i] = W;
	}

	// Load custom UBrowser pages
	if(i < 50)
	{
		j = 0;
		GetPlayerOwner().GetNextIntDesc(ServerListWindowClass, j, NextWindowClass, NextWindowDesc); 
		while( NextWindowClass != "" && i < 50 )
		{
			C = class<UBrowserServerListWindow>(DynamicLoadObject(NextWindowClass, class'Class'));
			if( C != None )
			{
				ServerListNames[i] = '';
				P = PageControl.AddPage("", C);
				W = UBrowserServerListWindow(P.Page);
				if(W.bHidden)
					PageControl.DeletePage(P);
				if(W.ServerListTitle != "")
					P.SetCaption(W.ServerListTitle);
				else
					P.SetCaption(NextWindowDesc);
				FactoryWindows[i] = W;	
				i++;
			}
			j++;
			GetPlayerOwner().GetNextIntDesc(ServerListWindowClass, j, NextWindowClass, NextWindowDesc); 
		}
	}
}

defaultproperties
{
	JoinDirectName="Direct"
	JoinDirectClass="NicksCoop.CoopBrowserJoinDirectWindow"

	DefCoopALLTabName="UBrowserPostal2"
	DefCoopALLName="All"
	DefCoopALLDesc="Shows all the games you can join on the Internet"

	DefNicksCoopTabName="UBrowserNicksCoop"
	DefNicksCoopName="NicksCoop"
	DefNicksCoopDesc="Shows all NicksCoop servers"

	//ServerListWindowClass="UTBrowser.UTBrowserServerListWindow"
	ServerListWindowClass="NicksCoop.CoopBrowserJoinServerListWindow"
	//FavoriteServersClass="UTBrowser.UTBrowserFavoriteServers"
	FavoriteServersClass="NicksCoop.CoopBrowserFavoriteServers"
	//UpdateServerClass="UTBrowser.UTBrowserUpdateServerWindow"
	UpdateServerClass="NicksCoop.CoopBrowserUpdateServerWindow"
}
