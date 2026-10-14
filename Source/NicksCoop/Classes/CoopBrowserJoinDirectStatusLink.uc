//=============================================================================
// CoopBrowserJoinDirectStatusLink.uc
// -based on UBrowserServerPing.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopBrowserJoinDirectStatusLink extends UdpLink;

var IpAddr				ServerIPAddr;
var float				RequestSentTime;
var float				LastDelta;
var name				QueryState;
var bool				bInitial;
var bool				bJustThisServer;
var bool				bNoSort;
var int					PingAttempts;
var int					AttemptNumber;
var int					BindAttempts;

var localized string	AdminEmailText;
var localized string	AdminNameText;
var localized string	ChangeLevelsText;
var localized string	MultiplayerBotsText;
var localized string	FragLimitText;
var localized string	TimeLimitText;
var localized string	GameModeText;
var localized string	GameTypeText;
var localized string	GameVersionText;
var localized string	WorldLogText;
var localized string	MutatorsText;
var localized string	TrueString;
var localized string	FalseString;
var localized string	ServerAddressText;
var localized string	MinPlayersText;
var localized string	PlayersText;
var localized string	MaxTeamsText;
var localized string	BalanceTeamsText;
var localized string	PlayersBalanceTeamsText;
var localized string	FriendlyFireText;
var localized string	MinNetVersionText;
var localized string	BotSkillText;
var localized string	TournamentText;
var localized string	ServerModeText;
var localized string	DedicatedText;
var localized string	NonDedicatedText;
var localized string	WorldLogWorkingText;
var localized string	WorldLogWorkingTrue;
var localized string	WorldLogWorkingFalse;
var localized string	PasswordText;

// config
var int			MaxBindAttempts;
var int			BindRetryTime;
var int			PingTimeout;
var bool			bUseMapName;

var CoopBrowserJoinDirectWindow DirectWindowOwner;

var bool bQueryRecievedData;

///steam 14/01/2017
function PrintStatusLine(string sLine)
{
	DirectWindowOwner.PrintStatusLine(sLine);
}

///steam 14/01/2017
function PlayerListAddInfo(int nID, string sInfo)
{
	DirectWindowOwner.PlayerListAddInfo(nID, sInfo);
}

function ValidateServer()
{
	///STUB
}

///steam 14/01/2017
function CallDetermineDefaults()
{
	MaxBindAttempts = class'UBrowserServerPing'.default.MaxBindAttempts;
	BindRetryTime = class'UBrowserServerPing'.default.BindRetryTime;
	PingTimeout = class'UBrowserServerPing'.default.PingTimeout;
	bUseMapName = class'UBrowserServerPing'.default.bUseMapName;
}

function StartQuery(name S, int InPingAttempts)
{
	CallDetermineDefaults();

	QueryState = S;
	ValidateServer();
	///ServerIPAddr.Port = Server.QueryPort;
	///steam 14/01/2017
	ServerIPAddr.Port = DirectWindowOwner.GetQueryPort();
	GotoState('Resolving');
	PingAttempts=InPingAttempts;
	AttemptNumber=1;
}

function Resolved( IpAddr Addr )
{
	ServerIPAddr.Addr = Addr.Addr;

	GotoState('Binding');
}

function bool GetNextValue(string In, out string Out, out string Result)
{
	local int i;
	local bool bFoundStart;

	Result = "";
	bFoundStart = False;

	for(i=0;i<Len(In);i++) 
	{
		if(bFoundStart)
		{
			if(Mid(In, i, 1) == "\\")
			{
				Out = Right(In, Len(In) - i);
				return True;
			}
			else
			{
				Result = Result $ Mid(In, i, 1);
			}
		}
		else
		{
			if(Mid(In, i, 1) == "\\")
			{
				bFoundStart = True;
			}
		}
	}

	return False;
}

function string LocalizeBoolValue(string Value)
{
	if(Value ~= "True" || Value ~= "1")
		return TrueString;
	
	if(Value ~= "False" || Value ~= "0")
		return FalseString;

	return Value;
}

function string LocalizeSkin(string SkinName)
{
	local string MeshName, Junk, SkinDesc;

	MeshName = Left(SkinName, InStr(SkinName, "."));

	GetNextSkin(MeshName, SkinName$"1", 0, Junk, SkinDesc);
	if(Junk == "")
		GetNextSkin(MeshName, SkinName, 0, Junk, SkinDesc);
	if(Junk == "")
		return GetItemName(SkinName);
	
	return SkinDesc;
}

function string LocalizeTeam(string TeamNum)
{
	if(TeamNum == "255")
		return "";

	return TeamNum;
}

function AddRule(string Rule, string Value)
{
	///steam 14/01/2017
	PrintStatusLine(Rule$":"@Value);

	/*local UBrowserRulesList  RulesList;

	ValidateServer();

	for(RulesList = UBrowserRulesList(Server.RulesList.Next); RulesList != None; RulesList = UBrowserRulesList(RulesList.Next))
		if(RulesList.Rule == Rule)
			return; // Rule already exists

	// Add the rule
	RulesList = UBrowserRulesList(Server.RulesList.Append(class'UBrowserRulesList'));
	RulesList.Rule = Rule;
	RulesList.Value = Value;*/
}

state Binding
{
Begin:
	if( BindPort(2000, true) == 0 )
	{
		Log("UBrowserServerPing: Port failed to bind.  Attempt "$BindAttempts);
		BindAttempts++;

		ValidateServer();
		if(BindAttempts == MaxBindAttempts)
		{
			//Server.PingDone(bInitial, bJustThisServer, False, bNoSort);
			///steam 14/01/2017
			DirectWindowOwner.PingDone(bInitial, bJustThisServer, False, bNoSort);
		}
		else
			GotoState('BindFailed');
	}
	else
	{
		GotoState(QueryState);
	}
}

state BindFailed
{
	event Timer()
	{
		GotoState('Binding');
	}

Begin:
	SetTimer(BindRetryTime, False);
}

state GetStatus 
{
	event ReceivedText( IpAddr Addr, string Text )
	{
		local string Value;
		local string In;
		local string Out;
		local byte ID;
		local bool bOK;
		local UBrowserPlayerList PlayerEntry;

		ValidateServer();

		//PrintStatusLine("success!");

		In = Text;
		do 
		{
			bOK = GetNextValue(In, Out, Value);
			In = Out;
			if(Left(Value, 7) == "player_")
			{
				ID = Int(Right(Value, Len(Value) - 7));

				bOK = GetNextValue(In, Out, Value);
				In = Out;

				///steam 14/01/2017
				PlayerListAddInfo(ID,"Player:"@Value);
				//PrintStatusLine(ID@Value);
			} 
			else if(Left(Value, 6) == "frags_") 
			{
				ID = Int(Right(Value, Len(Value) - 6));

				bOK = GetNextValue(In, Out, Value);
				In = Out;

				///steam 14/01/2017
				PlayerListAddInfo(ID,"Frags:"@Value);
				//PrintStatusLine(ID@Value);
			}
			else if(Left(Value, 5) == "ping_")
			{
				ID = Int(Right(Value, Len(Value) - 5));

				bOK = GetNextValue(In, Out, Value);
				In = Out;

				///steam 14/01/2017
				PlayerListAddInfo(ID,"Ping:"@Int(Right(Value, len(Value) - 1)));
				//PrintStatusLine(ID@Int(Right(Value, len(Value) - 1)));// leading space
			}
			else if(Left(Value, 5) == "team_")
			{
				ID = Int(Right(Value, Len(Value) - 5));

				bOK = GetNextValue(In, Out, Value);
				In = Out;

				///steam 14/01/2017
				PlayerListAddInfo(ID,"Team:"@LocalizeTeam(Value));
				//PrintStatusLine(ID@LocalizeTeam(Value));
			}
			else if(Left(Value, 10) == "character_")
			{
				ID = Int(Right(Value, Len(Value) - 10));

				bOK = GetNextValue(In, Out, Value);
				In = Out;

				///steam 14/01/2017
				///PlayerListAddInfo(ID,"Character:"@Value);
				//PrintStatusLine(ID@Value);
			}
			else if(Left(Value, 9) == "ngsecret_")
			{
				ID = Int(Right(Value, Len(Value) - 9));

				bOK = GetNextValue(In, Out, Value);
				In = Out;

				///steam 14/01/2017
				PlayerListAddInfo(ID,"Stats:"@Value);
				//PrintStatusLine(ID@Value);
			}
			else if(Value == "final")
			{
				///Server.StatusDone(True);

				///steam 15/01/2017
				//DirectWindowOwner.PrintPlayerListInfo();

				///steam 14/01/2017
				//DirectWindowOwner.StatusDone(True);

				GetStatusFinished();

				return;
			}
			/*else if(Value ~= "gamever")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(GameVersionText, Value);
			}
			else if(Value ~= "minnetver")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(MinNetVersionText, Value);
			}
			else if(Value ~= "gametype")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(GameTypeText, Value);
			}*/
			else if(Value ~= "timelimit") 
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(TimeLimitText, Value);
			}
			// RWS CHANGE: changed fraglimit to goalscore
			else if(Value ~= "goalscore") 
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(FragLimitText, Value);
			}
			else if(Value ~= "MultiplayerBots") 
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(MultiplayerBotsText, LocalizeBoolValue(Value));
			}
			else if(Value ~= "AdminName") 
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(AdminNameText, Value);
			}
			else if(Value ~= "AdminEMail")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(AdminEmailText, Value);
			}
			else if(Value ~= "WantWorldLog")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(WorldLogText, LocalizeBoolValue(Value));
			}
			else if(Value ~= "WorldLog")
			{
				bOK = GetNextValue(In, Out, Value);
				if( Value ~= "True" )
					AddRule(WorldLogWorkingText, WorldLogWorkingTrue);
				else
					AddRule(WorldLogWorkingText, WorldLogWorkingFalse);
			}
			else if(Value ~= "mutators")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(MutatorsText, Value);
			}
			else if(Value ~= "minplayers")
			{
				bOK = GetNextValue(In, Out, Value);
				if(Value == "0")
					AddRule(MultiplayerBotsText, FalseString);
				else
					AddRule(MinPlayersText, Value@PlayersText);		
			}
			else if(Value ~= "changelevels")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(ChangeLevelsText, LocalizeBoolValue(Value));		
			}
			else if(Value ~= "botskill")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(BotSkillText, Value);		
			}
			else if(Value ~= "maxteams")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(MaxTeamsText, Value);
			}
			else if(Value ~= "balanceteams")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(BalanceTeamsText, LocalizeBoolValue(Value));
			}
			else if(Value ~= "playersbalanceteams")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(PlayersBalanceTeamsText, LocalizeBoolValue(Value));
			}
			else if(Value ~= "friendlyfire")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(FriendlyFireText, Value);
			}
			/*else if(Value ~= "gamestyle")
			{
				bOK = GetNextValue(In, Out, Value);
				AddRule(GameModeText, Value);
			}*/
			else if(Value ~= "tournament")
			{
				bOK = GetNextValue(In, Out, Value);
				// RWS CHANGE: no tournament mode
				//AddRule(TournamentText, LocalizeBoolValue(Value));
			}
			else if(Value ~= "listenserver")
			{
				bOK = GetNextValue(In, Out, Value);
				if(bool(Value))
					AddRule(ServerModeText, NonDedicatedText);
				else
					AddRule(ServerModeText, DedicatedText);
			}
			else if(Value ~= "password")
			{
				bOK = GetNextValue(In, Out, Value);
				// RWS CHANGE: Show "Requires Password" rule only if it's enabled
				if(bool(Value))
					AddRule(PasswordText, LocalizeBoolValue(Value));
			}
		} until(!bOK);

		///steam 15/01/2017
		//DirectWindowOwner.PrintPlayerListInfo();
	}

	function GetStatusFinished()
	{
		DirectWindowOwner.PrintPlayerListInfo();
		DirectWindowOwner.StatusDone(True);
	}

	event Timer()
	{
		if(AttemptNumber < PingAttempts)
		{
			Log("Timed out getting player replies.  Attempt "$AttemptNumber);
			AttemptNumber++;
			GotoState(QueryState);
		}
		else
		{
			///Server.StatusDone(False);

			///steam 14/01/2017
			DirectWindowOwner.StatusDone(False);

			Log("Timed out getting player replies.  Giving Up");
		}
	}
Begin:
	// Player info

	ValidateServer();
	/**if(Server.PlayerList != None)
	{
		Server.PlayerList.DestroyList();
	}
	Server.PlayerList = New(None) class'UBrowserPlayerList';
	Server.PlayerList.SetupSentinel();	

	if(Server.RulesList != None)
	{
		Server.RulesList.DestroyList();
	}
	Server.RulesList = New(None) class'UBrowserRulesList';
	Server.RulesList.SetupSentinel();**/
// RWS Change, changed from unreal to postal2 - now removed completely
	///AddRule(ServerAddressText, Server.IP$":"$string(Server.GamePort));

	///steam 15/01/2017
	DirectWindowOwner.PlayerListRemoveAllInfo();

	///steam 14/01/2017
	//AddRule(ServerAddressText, DirectWindowOwner.GetServerIP()$":"$string(DirectWindowOwner.GetGamePort()));

	SendText( ServerIPAddr, "\\status\\" );
	SetTimer(PingTimeout + FRand(), False);
}

function string ParseReply(string Text, string Key)
{
	local int i;
	local string Temp;

	i=InStr(Text, "\\"$Key$"\\");
	Temp = Mid(Text, i + Len(Key) + 2);
	return Left(Temp, InStr(Temp, "\\"));
}

state GetInfo
{
	event ReceivedText(IpAddr Addr, string Text)
	{
		local string Temp;
		local float ElapsedTime;

		// Make sure this packet really is for us.
		Temp = IpAddrToString(Addr);
		///if(Server.IP != Left(Temp, InStr(Temp, ":")))
		///steam 14/01/2017
		if( DirectWindowOwner.GetServerIP() != Left(Temp, InStr(Temp, ":")))
			return;

		//PrintStatusLine("success!");

		ValidateServer();
		ElapsedTime = (Level.TimeSeconds - RequestSentTime) * Level.TimeDilation;
		DirectWindowOwner.Ping = Max(1000*ElapsedTime - (0.5*LastDelta) - 10, 4); // subtract avg client and server frametime from ping.
		DirectWindowOwner.HostName = DirectWindowOwner.GetServerIP();
		DirectWindowOwner.GamePort = 0;
		DirectWindowOwner.MapName = "";
		DirectWindowOwner.MapTitle = "";
		DirectWindowOwner.MapDisplayName = "";
		DirectWindowOwner.GameType = "";
		DirectWindowOwner.GameMode = "";
		DirectWindowOwner.NumPlayers = 0;
		DirectWindowOwner.MaxPlayers = 0;
		DirectWindowOwner.GameVer = 0;
		DirectWindowOwner.MinNetVer = 0;

		Temp = ParseReply(Text, "hostname");
		if(Temp != "")
			DirectWindowOwner.HostName = Temp;

		Temp = ParseReply(Text, "hostport");
		if(Temp != "")
			DirectWindowOwner.GamePort = Int(Temp);

		Temp = ParseReply(Text, "mapname");
		if(Temp != "")
			DirectWindowOwner.MapName = Temp;

		Temp = ParseReply(Text, "maptitle");
		if(Temp != "")
		{
			DirectWindowOwner.MapTitle = Temp;
			DirectWindowOwner.MapDisplayName = DirectWindowOwner.MapTitle;
			if(DirectWindowOwner.MapTitle == "" || DirectWindowOwner.MapTitle ~= "Untitled" || bUseMapName)
				DirectWindowOwner.MapDisplayName = DirectWindowOwner.MapName;
		}
		
		Temp = ParseReply(Text, "gametype");
		if(Temp != "")
			DirectWindowOwner.GameType = Temp;
	
		Temp = ParseReply(Text, "numplayers");
		if(Temp != "")
			DirectWindowOwner.NumPlayers = Int(Temp);

		Temp = ParseReply(Text, "maxplayers");
		if(Temp != "")
			DirectWindowOwner.MaxPlayers = Int(Temp);
	
		Temp = ParseReply(Text, "gamemode");
		if(Temp != "")
			DirectWindowOwner.GameMode = Temp;

		Temp = ParseReply(Text, "gamever");
		if(Temp != "")
			DirectWindowOwner.GameVer = Int(Temp);

		Temp = ParseReply(Text, "minnetver");
		if(Temp != "")
			DirectWindowOwner.MinNetVer = Int(Temp);

		///if( Server.DecodeServerProperties(Text) )
		///{
			///Server.PingDone(bInitial, bJustThisServer, True, bNoSort);

			///steam 14/01/2017
			//DirectWindowOwner.PrintStatusInfo();
			//DirectWindowOwner.PingDone(bInitial, bJustThisServer, True, bNoSort);
			GetInfoFinished();

			Disable('Tick');
		///}
	}

	function GetInfoFinished()
	{
		DirectWindowOwner.PrintStatusInfo();
		DirectWindowOwner.PingDone(bInitial, bJustThisServer, True, bNoSort);
	}

	event Tick(Float DeltaTime)
	{
		LastDelta = DeltaTime;
	}

	event Timer()
	{
		ValidateServer();
		if(AttemptNumber < PingAttempts)
		{
			Log("Ping Timeout from "$DirectWindowOwner.GetServerIP()$".  Attempt "$AttemptNumber);
			AttemptNumber++;
			GotoState(QueryState);
		}
		else
		{
			Log("Ping Timeout from "$DirectWindowOwner.GetServerIP()$" Giving Up");

			DirectWindowOwner.Ping = 9999;
			DirectWindowOwner.GamePort = 0;
			DirectWindowOwner.MapName = "";
			DirectWindowOwner.MapDisplayName = "";
			DirectWindowOwner.MapTitle = "";
			DirectWindowOwner.GameType = "";
			DirectWindowOwner.GameMode = "";
			DirectWindowOwner.NumPlayers = 0;
			DirectWindowOwner.MaxPlayers = 0;

			Disable('Tick');

			DirectWindowOwner.PingDone(bInitial, bJustThisServer, False, bNoSort);
		}
	}

Begin:
	Enable('Tick');
	SendText( ServerIPAddr, "\\info\\" );
	RequestSentTime = Level.TimeSeconds;
	SetTimer(PingTimeout + FRand(), False);
}

state Resolving
{
Begin:
	Resolve( DirectWindowOwner.GetServerIP() );
}

///steam 02/03/2017
state CollectServerInfoStepI extends GetInfo
{
	function GetInfoFinished()
	{
		DirectWindowOwner.PrintStatusInfo();
		GotoState('CollectServerInfoStepII');
	}
}
state CollectServerInfoStepII extends GetStatus
{
	function GetStatusFinished()
	{
		DirectWindowOwner.PrintPlayerListInfo();
		DirectWindowOwner.StatusDone(True);
	}
}

defaultproperties
{
	AdminEmailText="Admin Email"
	AdminNameText="Admin Name"
	MultiplayerBotsText="Bots in Multiplayer"
	FragLimitText="Score Limit"
	TimeLimitText="Time Limit"
	GameModeText="Game Mode"
	GameTypeText="Game Type"
	GameVersionText="Game Version"
	MinNetVersionText="Min. Compatible Version"
	MutatorsText="Mutators"
	MinPlayersText="Bots Enter Game for Min. of"
	PlayersText="Players"
	ChangeLevelsText="Change Levels"
	MaxTeamsText="Max Teams"
	BalanceTeamsText="Bots Balance Teams"
	PlayersBalanceTeamsText="Force Team Balance"
	FriendlyFireText="Friendly Fire Damage"
	BotSkillText="Bot Skill"
	TournamentText="Tournament Mode"
	TrueString="Enabled"
	FalseString="Disabled"
	MaxBindAttempts=5
	BindRetryTime=10
	PingTimeout=1
	ServerAddressText="Server Address"
	ServerModeText="Server Mode"
	DedicatedText="Dedicated"
	NonDedicatedText="Non-Dedicated"
	WorldLogText="Game Stats Enabled"
	WorldLogWorkingText="Game Stats Status"
	WorldLogWorkingTrue="Processing Stats Correctly"
	WorldLogWorkingFalse="Not Processing Stats Correctly"
	PasswordText="Requires Password"
}
