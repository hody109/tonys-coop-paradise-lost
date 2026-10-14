// Consume input before console, menus, key bindings and gameplay receive it.
// The controller flag is replicated by the server, including for late joins.
class CoopPLConsole extends FPSConsoleExt;
var CoopPLPlayerClient PLInputPlayer;

function bool IntroLocked()
{
    return PLInputPlayer != None && !PLInputPlayer.bDeleteMe
        && PLInputPlayer.PLIntroInputLocked();
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
    local CoopPLPlayerClient P;
    local CoopGameReplicationInfo G;
    if (IntroLocked())
    {
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
    if (IntroLocked()) return true;
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
