// Consume input before console, menus, key bindings and gameplay receive it.
// The controller flag is replicated by the server, including for late joins.
class CoopPLConsole extends FPSConsoleExt;
var CoopPLPlayerClient PLInputPlayer;

function bool WaitingMenuAllowed()
{
    local CoopGameReplicationInfo G;
    if(!IntroLocked()) return false;
    G=CoopGameReplicationInfo(PLInputPlayer.GameReplicationInfo);
    return G!=None && G.bCoopWaitPlayers && G.bCoopWaitContinue;
}

function P2RootWindow IntroMenu()
{
    if(PLInputPlayer==None || PLInputPlayer.Player==None
        || PLInputPlayer.Player.InteractionMaster==None) return None;
    return P2RootWindow(PLInputPlayer.Player.InteractionMaster.BaseMenu);
}

function UpdateIntroMenu()
{
    local P2RootWindow M;
    if(!IntroLocked() || WaitingMenuAllowed()) return;
    M=IntroMenu();
    if(M!=None && M.IsMenuShowing()) M.HideMenu();
}

function bool IntroLocked()
{
    return PLInputPlayer != None && !PLInputPlayer.bDeleteMe
        && PLInputPlayer.PLIntroInputLocked();
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
    local CoopPLPlayerClient P;
    local CoopGameReplicationInfo G;
    local P2RootWindow M;
    if (IntroLocked())
    {
        UpdateIntroMenu();
        M=IntroMenu();
        if(WaitingMenuAllowed() && M!=None)
        {
            // Route menu input directly and consume it before gameplay bindings.
            if(M.IsMenuShowing())
            {
                M.KeyEvent(Key,Action,Delta);
                return true;
            }
            if(Key==IK_Escape)
            {
                if(Action==IST_Release) M.ShowMenu();
                return true;
            }
        }
        P=PLInputPlayer;
        G=CoopGameReplicationInfo(P.GameReplicationInfo);
        if (Key==IK_Enter && Action==IST_Press && G!=None
            && G.bCoopWaitPlayers && G.bCoopWaitContinue)
            P.NETCoopWaitContinue();
        else if(Key==IK_Enter && Action==IST_Press && G!=None && !G.bCoopWaitPlayers)
            P.ServerPLVoteSkip();
        return true;
    }
    return Super.KeyEvent(Key, Action, Delta);
}

function bool KeyType(EInputKey Key, optional string Unicode)
{
    local P2RootWindow M;
    if (IntroLocked())
    {
        UpdateIntroMenu();
        M=IntroMenu();
        if(WaitingMenuAllowed() && M!=None && M.IsMenuShowing()) M.KeyType(Key,Unicode);
        return true;
    }
    return Super.KeyType(Key, Unicode);
}

function PostRender(Canvas C)
{
    local CoopGameReplicationInfo G;
    Super.PostRender(C);
    if(!IntroLocked()) return;
    G=CoopGameReplicationInfo(PLInputPlayer.GameReplicationInfo);
    if(G==None || G.bCoopWaitPlayers) return;
    C.SetPos(C.ClipX*0.05,C.ClipY*0.93);
    C.SetDrawColor(255,255,255);
    C.DrawText("ENTER: vote to skip intro. All connected players must agree.",false);
}

state ConsoleVisible
{
    function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
    {
        if (IntroLocked()) return true;
        return Super.KeyEvent(Key, Action, Delta);
    }
    function bool KeyType(EInputKey Key, optional string Unicode)
    {
        if (IntroLocked()) return true;
        return Super.KeyType(Key, Unicode);
    }
}
