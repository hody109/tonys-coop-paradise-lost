// Test-only server game: load a campaign day's starting map and exit after startup.
// It deliberately seeds a day; this is NOT a playthrough or an errand-completion test.
class PLCoopCampaignProbe extends CoopPLGameInfo;

var int ProbeDay;

event InitGame(out string Options, out string Error)
{
    Super.InitGame(Options, Error);
    ProbeDay = int(ParseOption(Options, "PLTestDay"));
    bAutoSave_FirstRun = false;
}

function bool CoopLoadServerGameState()
{
    TheGameState.CurrentDay = 0;
    TheGameState.NextDay = ProbeDay;
    TheGameState.bChangeDayPostTravel = true;
    return true;
}

function CoopSaveServerGameState() {}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(10.0, false);
}

event Timer()
{
    if (TheGameState != None && TheGameState.CurrentDay == ProbeDay
        && GetPlayer() != None && PLGameState(TheGameState) != None)
        Log("PLPROBE|PASS|day=" $ ProbeDay $ "|map=" $ Level.GetLocalURL());
    else
        Log("PLPROBE|FAIL|day=" $ ProbeDay);
    ConsoleCommand("exit");
}
