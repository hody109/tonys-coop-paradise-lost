class PLCoopDifficultyCommandlet extends Commandlet;
event int Main(string Params)
{
    local class<CoopPLGameInfo> G;
    local int N;
    N=int(Params);
    G=class'CoopPLGameInfo';
    Log("PLDIFFICULTY|READ|number="$G.default.GameDifficultyNumber$"|AI="$G.default.GameDifficulty$"|Lieber="$G.default.bLieberMode$"|Heston="$G.default.bHestonMode$"|Insaneo="$G.default.bInsaneoMode$"|Hate="$G.default.bTheyHateMeMode$"|Expert="$G.default.bExpertMode);
    if(G.default.GameDifficultyNumber!=N || G.default.GameDifficulty!=Min(N,10)) return 1;
    if(G.default.bLieberMode!=(N==0)) return 2;
    if(G.default.bHestonMode!=(N==10 || N==13)) return 3;
    if(G.default.bInsaneoMode!=(N==11 || N==14)) return 4;
    if(G.default.bTheyHateMeMode!=(N>=12)) return 5;
    if(G.default.bExpertMode!=(N>=13)) return 6;
    if(G.default.bCustomMode || G.default.bLudicrousMode) return 7;
    Log("PLDIFFICULTY|PASS|"$N$"|"$G.default.DifficultyNames[N]$"|AI="$G.default.GameDifficulty);
    return 0;
}
defaultproperties
{
    IsClient=False
    IsServer=False
    IsEditor=True
    LogToStdout=True
    ShowErrorCount=True
}
