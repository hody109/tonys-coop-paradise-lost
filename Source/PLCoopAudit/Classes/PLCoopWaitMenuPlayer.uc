class PLCoopWaitMenuPlayer extends CoopPLPlayerClient;
var float JoinedAt;
var int Phase;
var bool Requested;
var float MenuOpenedAt;

simulated function Check(bool OK,string Message)
{
    if(OK) Log("PLWAITMENU|PASS|"$Message);
    else Log("PLWAITMENU|FAIL|"$Message);
}

simulated function PlayerTick(float D)
{
    local CoopPLConsole C;
    local P2RootWindow M;
    local CoopGameReplicationInfo G;
    local int i;
    Super.PlayerTick(D);
    if(Role!=ROLE_AutonomousProxy || Player==None || PlayerReplicationInfo==None || Player.InteractionMaster==None) return;
    if(JoinedAt==0) JoinedAt=Level.TimeSeconds;
    for(i=0;i<Player.InteractionMaster.GlobalInteractions.Length;i++)
        if(CoopPLConsole(Player.InteractionMaster.GlobalInteractions[i])!=None)
            C=CoopPLConsole(Player.InteractionMaster.GlobalInteractions[i]);
    if(C==None) return;
    M=C.IntroMenu();
    G=CoopGameReplicationInfo(GameReplicationInfo);
    if(M==None || G==None) return;
    if(Phase==0 && C.WaitingMenuAllowed() && Level.TimeSeconds-JoinedAt>5)
    {
        Check(C.KeyEvent(IK_W,IST_Press,0),"waiting gameplay input blocked");
        C.KeyEvent(IK_Escape,IST_Press,0);
        C.KeyEvent(IK_Escape,IST_Release,0);
        Check(M.IsMenuShowing(),"Escape opens waiting menu");
        Check(C.KeyEvent(IK_Down,IST_Press,0),"menu navigation consumed");
        if(PlayerReplicationInfo.PlayerName=="WaitDisconnect")
        {
            Log("PLWAITMENU|QUIT|using normal menu exit");
            CoopPLShellRootWindow(M).CoopQuitCurrentGame();
        }
        MenuOpenedAt=Level.TimeSeconds;
        Phase=1;
    }
    if(PlayerReplicationInfo.PlayerName=="WaitHost" && !Requested && Phase==1 && Level.TimeSeconds-MenuOpenedAt>35)
    {
        Requested=true;
        NETCoopWaitContinue();
    }
    if(Phase==1 && !G.bCoopWaitContinue)
    {
        Check(!M.IsMenuShowing(),"open menu closes at countdown");
        C.KeyEvent(IK_Escape,IST_Press,0);
        C.KeyEvent(IK_Escape,IST_Release,0);
        Check(!M.IsMenuShowing(),"Escape blocked during countdown");
        Phase=2;
    }
    if(Phase==2 && !G.bCoopWaitPlayers)
    {
        C.KeyEvent(IK_Escape,IST_Press,0);
        C.KeyEvent(IK_Escape,IST_Release,0);
        Check(!M.IsMenuShowing(),"Escape blocked during cinematic");
        Check(C.KeyEvent(IK_LeftMouse,IST_Press,0),"cinematic mouse blocked");
        Log("PLWAITMENU|DONE");
        Phase=3;
        ConsoleCommand("quit");
    }
}
