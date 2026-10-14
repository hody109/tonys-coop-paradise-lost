//=============================================================================
// CoopBrowserJoinServerGrid.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinServerGrid extends UTBrowserServerGrid;

function DrawCell(Canvas C, float X, float Y, UWindowGridColumn Column, UBrowserServerList List)
{
	local Color SavedColor;
	SavedColor = C.DrawColor;
	if( SelectedServer == None || List != SelectedServer )
		C.SetDrawColor(0,0,0);
	/*switch(Column)
	{
	case Server:
		Column.ClipText( C, X, Y, List.HostName );
		break;
	case GameType:
		if(bShowGameTypes)
			Column.ClipText( C, X, Y, List.GameType );
		break;
	case Ping:
		Column.ClipText( C, X, Y, Int(List.Ping) );
		break;
	case MapName:
		Column.ClipText( C, X, Y, List.MapDisplayName );
		break;
	case Players:
		Column.ClipText( C, X, Y, List.NumPlayers$"/"$List.MaxPlayers );
		break;
	}*/
	Super.DrawCell(C, X, Y, Column, List);
	C.DrawColor = SavedColor;
}

defaultproperties
{
}