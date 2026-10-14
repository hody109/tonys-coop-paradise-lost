//=============================================================================
// CoopBrowserServerSubsetFact.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopBrowserServerSubsetFact extends UBrowserSubsetFact;

function ConsiderItem(UBrowserServerList L)
{
	local UBrowserServerList NewItem;
	local int MinNetVer;
	local int GameVer;

	if(!L.bPinged)
		return;	

	if(bLocalServersOnly && !L.bLocalServer)
		return;

	MinNetVer = int(Owner.Owner.GetPlayerOwner().Level.MinNetVersion);
	GameVer = int(Owner.Owner.GetPlayerOwner().Level.EngineVersion);

	if(bCompatibleServersOnly && (L.MinNetVer > GameVer || MinNetVer > L.GameVer))
		return;

	if(GameMode != "" && GameMode != L.GameMode)
		return;

	///steam 10/05/2017
	if( GameType != "" && InStr(caps(L.GameType), caps(GameType)) == -1 )
		return;

	if(MinPlayers != 0 && L.NumPlayers < MinPlayers)
		return;

	if(MaxPing != 0 && L.Ping > MaxPing)
		return;

	if( PingedList.FindExistingServer( L.IP, L.QueryPort ) != None)
		return;

	NewItem = UBrowserServerList(Owner.CopyExistingListItem(L.Class, L));
	NewItem.Remove();
	PingedList.AppendItem(NewItem);
	Owner.bNeedUpdateCount = True;
}

defaultproperties
{
	SupersetTag="UBrowserAll"
	bLocalServersOnly=False
	GameMode=""
	GameType="NicksCoop"
	Ping=9999
	NotFoundError="Could not find the window: "
	NotReadyError="Window is not ready: "
}
