//=============================================================================
// CoopReportFileLog.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopReportFileLog extends FileLog;

event Destroyed()
{
	if( CoopGameInfo(Owner) != None )
		CoopGameInfo(Owner).ReportLogFileInfo = None;
	Super.Destroyed();
}

defaultproperties
{
}