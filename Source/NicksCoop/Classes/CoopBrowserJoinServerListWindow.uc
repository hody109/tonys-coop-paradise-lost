//=============================================================================
// CoopBrowserJoinServerListWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinServerListWindow extends UBrowserServerListWindow;

function UpdatePageHeaderText(optional string usePageHeaderText)
{
	local string sTempCaption;
	local string MyName;

	// Ugly hack.  The favorites stuff gets created a different way, so there end up being
	// multiple copies created, each with a different number at the end of its name.  This
	// basically strips out the number.  Yes, very ugly.
	MyName = GetItemName(string(self));
	if( InStr(MyName, "UTBrowserFavoriteServers") != -1 
		|| InStr(MyName, "CoopBrowserFavoriteServers") != -1 )
		MyName = "UTBrowserFavoriteServers";

	sTempCaption = Localize("ServerListPageHeaders", MyName, "MultiplayerInfo");
	if( Left(sTempCaption,2) ~= "<?" )
	{
		sTempCaption = Localize("ServerListPageHeaders", MyName, "NicksCoop");
		if( Left(sTempCaption,2) ~= "<?" )
		{
			if( usePageHeaderText != "" )
				sTempCaption = usePageHeaderText;
			else sTempCaption = ""$MyName;
		}
	}
	PageHeaderText = sTempCaption;
	if( PageHeader != None )
		PageHeader.SetText(PageHeaderText);
}

function Created()
{
	Super.Created();
	UpdatePageHeaderText();
}

defaultproperties
{
	ButtonTextPadding=20

	//GridClass="UTBrowser.UTBrowserServerGrid"
	GridClass="NicksCoop.CoopBrowserJoinServerGrid"
	ServerListClassName="UTBrowser.UTBrowserServerList"
}
