//=============================================================================
// CoopPLAdmin.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLAdmin extends CoopAdmin;

var array<int> PL_VisibleErrands;

function PL_SortVisibleErrands(CoopGameInfo myGameInfo)
{
	local int i, j, nDay;
	PL_VisibleErrands.Length=0;
	if(myGameInfo==None || myGameInfo.TheGameState==None) return;
	nDay = myGameInfo.GetCurrentDay();
	if(nDay<0 || nDay>=myGameInfo.Days.Length) return;
	for (i = 0; i < myGameInfo.Days[nDay].Errands.Length; i++)
	{
		if( myGameInfo.Days[nDay].IsErrandActive(i) 
			&& !myGameInfo.Days[nDay].IsErrandComplete(i) 
			&& myGameInfo.Days[nDay].GetErrandName(i) != None )
		{
			j = PL_VisibleErrands.Length;
			PL_VisibleErrands.Insert(j, 1.0);
			PL_VisibleErrands[j] = i;
		}
	}
}

function PL_SetThisErrandComplete(CoopGameInfo myGameInfo, String UniqueName)
{
	local int DayI, ErrandI;
	myGameInfo.FindErrand(UniqueName, DayI, ErrandI);
	if(DayI >= 0 && ErrandI >= 0)
	{
		if( !myGameInfo.Days[DayI].IsErrandComplete(ErrandI) && myGameInfo.Days[DayI].IsErrandActive(ErrandI) )
		{
			myGameInfo.Days[DayI].Errands[ErrandI].ForceCompletion(myGameInfo.TheGameState, myGameInfo.GetPlayer());
			myGameInfo.SaveCompletedErrand(DayI, ErrandI);
			if( DayI == myGameInfo.TheGameState.CurrentDay )
				myGameInfo.TheGameState.ErrandsCompletedToday++;
		}
	}
}

exec function FinishErrand(int Idx)
{
	local int i, j;
	local CoopGameInfo myGameInfo;
	myGameInfo = CoopGameInfo(Level.Game);
	if( myGameInfo == None || myGameInfo.TheGameState==None )
		return;
	PL_SortVisibleErrands(myGameInfo);
	Idx = FMax(Idx-1,0);
	if( Idx >= PL_VisibleErrands.Length )
		return;
	i = PL_VisibleErrands[Idx];
	PL_SetThisErrandComplete(myGameInfo, myGameInfo.Days[myGameInfo.GetCurrentDay()].Errands[i].UniqueName);
}

defaultproperties
{
}
