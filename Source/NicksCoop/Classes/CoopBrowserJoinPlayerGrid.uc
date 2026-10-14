//=============================================================================
// CoopBrowserJoinPlayerGrid.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinPlayerGrid extends UBrowserPlayerGrid;

function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY) 
{
	local UBrowserServerList Server;
	local UBrowserPlayerList PlayerList, l;
	local int Visible;
	local int Count;
	local int Skipped;
	local int Y;
	local int TopMargin;
	local int BottomMargin;

	C.Font = Root.Fonts[F_Small];

	if(bShowHorizSB)
		BottomMargin = LookAndFeel.Size_ScrollbarWidth;
	else
		BottomMargin = 0;

	TopMargin = LookAndFeel.ColumnHeadingHeight;

	Server = UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server;
	if(Server == None)
		return;
	PlayerList = Server.PlayerList;

	if(PlayerList == None)
		return;
	Count = PlayerList.Count();
	if( ngSecretColumn.WinWidth <= 1 )
	{
		ngSecretColumn.ShowWindow();
		ngSecretColumn.WinWidth = ngSecretWidth;
	}
	Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);
	
	VertSB.SetRange(0, Count+1, Visible);
	TopRow = VertSB.Pos;

	Skipped = 0;

	Y = 1;
	l = UBrowserPlayerList(PlayerList.Next);
	while((Y < RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && (l != None))
	{
		if(Skipped >= VertSB.Pos)
		{
			C.SetDrawColor(0,0,0);
			switch(Column.ColumnNum)
			{
			case 0:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerName );
				break;
			case 1:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerFrags );
				break;
			case 2:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerPing);
				break;
			case 3:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerTeam );
				break;
			case 4:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerCharacter );
				break;
/*			case 4:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerMesh );
				break;
			case 5:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerSkin );
				break;
			case 6:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerFace );
				break;
			case 7:
				Column.ClipText( C, 2, Y + TopMargin, l.PlayerID );
				break;*/
			case 5:
				if( l.PlayerStats ~= "bot" )
					Column.ClipText( C, 2, Y + TopMargin, BotText );
				else if( l.PlayerStats ~= "true" )
					Column.ClipText( C, 2, Y + TopMargin, EnabledText );
				else
					Column.ClipText( C, 2, Y + TopMargin, DisabledText );
				break;
			}

			Y = Y + RowHeight;			
		} 
		Skipped ++;
		l = UBrowserPlayerList(l.Next);
	}
}

defaultproperties
{
}