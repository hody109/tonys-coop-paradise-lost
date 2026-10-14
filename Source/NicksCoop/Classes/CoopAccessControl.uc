//=============================================================================
// CoopAccessControl.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopAccessControl extends AccessControl;

var globalconfig array<string> IPPoliciesExtend;
var array<string> TCC_IP_Cache;

function bool CheckTCC_Cache(string S)
{
	local string IP;
	local int j;
	IP = Left(S, InStr(S, ":"));
	for( j = 0; j < TCC_IP_Cache.Length; j++ )
	{
		if( TCC_IP_Cache[j] == IP )
			return true;
	}
	return false;
}

/*
function AddIPPoliciesExtend(string sIP)
{
	local int j;
	local bool bEmptySlot;

	bEmptySlot = false;

	for( j = 0 ; j < IPPoliciesExtend.Length ; j++ )
	{
		if( IPPoliciesExtend[j] == "" )
		{
			bEmptySlot = true;
			break;
		}
	}
	if( !bEmptySlot )
	{
		j = IPPoliciesExtend.Length;
		IPPoliciesExtend.Insert(j, 1.0);
		IPPoliciesExtend[j] = "DENY,"$sIP;
	}
	else
	{
		if( j < IPPoliciesExtend.Length )
			IPPoliciesExtend[j] = "DENY,"$sIP;
	}
}
*/

function AddIPPoliciesExtend(string sIP)
{
	local int j;
	j = IPPoliciesExtend.Length;
	IPPoliciesExtend.Insert(j, 1.0);
	IPPoliciesExtend[j] = "DENY,"$sIP;
}

function CoopAddToBanList(string S, optional bool bTCC)
{
	local string IP;
	local int j;
	local bool bFound;

	if( bTCC )
	{
		if( CheckTCC_Cache(S) )
			return;

		//bChecked = CheckIPPolicy(S);

		IP = Left(S, InStr(S, ":"));
		j = TCC_IP_Cache.Length;
		TCC_IP_Cache.Insert(j, 1.0);
		TCC_IP_Cache[j] = IP;

		Log("Adding IP Ban for TCC: "$IP);
		AddIPPoliciesExtend(IP);
		SaveConfig();

		return;
	}

	if( CheckIPPolicy(S) )
	{
		IP = Left(S, InStr(S, ":"));
		Log("Adding IP Ban for: "$IP);
		for(j=0;j<50;j++)
		{
			if( IPPolicies[j] == "" )
			{
				bFound = true;
				break;
			}
		}
		if( bFound )
			IPPolicies[j] = "DENY,"$IP;
		else AddIPPoliciesExtend(IP);

		SaveConfig();
	}
}

function KickBan( string S ) 
{
	local PlayerController P;
	local string IP;
	local int j;
	local bool bFound;

	ForEach DynamicActors(class'PlayerController', P)
		if ( P.PlayerReplicationInfo.PlayerName~=S 
			&&	(NetConnection(P.Player)!=None) )
		{
			IP = P.GetPlayerNetworkAddress();
			if( CheckIPPolicy(IP) && !IsAdmin(P))
			{
				IP = Left(IP, InStr(IP, ":"));
				Log("Adding IP Ban for: "$IP);
				for(j=0;j<50;j++)
				{
					if( IPPolicies[j] == "" )
					{
						bFound = true;
						break;
					}
				}
				if( bFound )
					IPPolicies[j] = "DENY,"$IP;
				else AddIPPoliciesExtend(IP);

				SaveConfig();
			}
			if(!IsAdmin(P))
				Kick(P.PlayerReplicationInfo.PlayerName);
			return;
		}
}

function bool CheckIPPolicy(string Address)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;
	local bool bFound;
	local string sLogDeniedIP;

	if( CheckTCC_Cache(Address) )
		return false;
	
	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = True;
	for(i=0; i<50 && IPPolicies[i] != ""; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);
		if(Policy ~= "ACCEPT") 
			bAcceptPolicy = True;
		else if(Policy ~= "DENY") 
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
				bFound = true;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
				bFound = true;
			}
		}
	}

	if(!bAcceptAddress)
		sLogDeniedIP = IPPolicies[LastMatchingPolicy];

	if( bAcceptAddress || !bFound )
	{
	for(i=0; i<IPPoliciesExtend.Length /*&& IPPoliciesExtend[i] != ""*/; i++)
	{
		j = InStr(IPPoliciesExtend[i], ",");
		if(j==-1)
			continue;
		Policy = Left(IPPoliciesExtend[i], j);
		Mask = Mid(IPPoliciesExtend[i], j+1);
		if(Policy ~= "ACCEPT") 
			bAcceptPolicy = True;
		else if(Policy ~= "DENY") 
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}
	if(!bAcceptAddress)
		sLogDeniedIP = IPPoliciesExtend[LastMatchingPolicy];
	}

	if(!bAcceptAddress)
		Log("Denied connection for "$Address$" with IP policy "$sLogDeniedIP);
		
	return bAcceptAddress;
}

function AdminEntered( PlayerController P )
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged in as Administrator.");
	CoopGameInfo(Level.Game).xCoopReportLogF(P.GetPlayerNetworkAddress()@P.PlayerReplicationInfo.PlayerName@"logged in as Administrator.");
	///Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"logged in as a server administrator." );
}

function AdminExited( PlayerController P )
{
	Log(P.PlayerReplicationInfo.PlayerName@"logged out from Administrator.");
	CoopGameInfo(Level.Game).xCoopReportLogF(P.PlayerReplicationInfo.PlayerName@"logged out from Administrator.");
	///Level.Game.Broadcast( P, P.PlayerReplicationInfo.PlayerName@"gave up administrator abilities.");
}

defaultproperties
{
	AdminClass=class'CoopAdmin'
}
