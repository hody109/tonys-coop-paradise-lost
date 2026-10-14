//=============================================================================
// CoopBrowserJoinRulesGrid.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016-2017.
//=============================================================================

class CoopBrowserJoinRulesGrid extends UBrowserRulesGrid;

function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY) 
{
	local UBrowserServerList Server;
	local UBrowserRulesList RulesList, l;
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
	RulesList = Server.RulesList;
	if(RulesList == None)
		return;
	Count = RulesList.Count();

	Visible = int((WinHeight - (TopMargin + BottomMargin))/RowHeight);
	
	VertSB.SetRange(0, Count+1, Visible);
	TopRow = VertSB.Pos;

	Skipped = 0;

	Y = 1;
	l = UBrowserRulesList(RulesList.Next);
	while((Y < RowHeight + WinHeight - RowHeight - (TopMargin + BottomMargin)) && (l != None)) 
	{
		if(Skipped >= VertSB.Pos)
		{
			C.SetDrawColor(0,0,0);
			switch(Column.ColumnNum)
			{
			case 0:
				Column.ClipText( C, 2, Y + TopMargin, l.Rule );
				break;
			case 1:
				Column.ClipText( C, 2, Y + TopMargin, l.Value );
				break;
			}

			Y = Y + RowHeight;			
		} 
		Skipped ++;
		l = UBrowserRulesList(l.Next);
	}
}

defaultproperties
{
}