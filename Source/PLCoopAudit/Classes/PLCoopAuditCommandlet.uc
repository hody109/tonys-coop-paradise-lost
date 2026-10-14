// Read-only audit of the campaign defaults actually loaded by the engine.
class PLCoopAuditCommandlet extends Commandlet;

event int Main(string Params)
{
    local class<P2GameInfoSingle> G;
    local DayBase D;
    local ErrandBase E;
    local int i, j, k, Count;

    if (InStr(Params, " ") >= 0)
        Params = Left(Params, InStr(Params, " "));
    if (Params == "")
        Params = "PLGame.PLGameInfo";
    G = class<P2GameInfoSingle>(DynamicLoadObject(Params, class'Class'));
    if (G == None)
        return 1;
    Log("PLAUDIT|GAME|" $ G $ "|" $ G.default.Days.Length);
    for (i=0; i<G.default.Days.Length; i++)
    {
        D = G.default.Days[i];
        if (D == None)
            return 2;
        Log("PLAUDIT|DAY|" $ i $ "|" $ D.UniqueName $ "|" $ D.StartDayURL $ "|" $ D.FinishedDayURL);
        for (j=0; j<D.Errands.Length; j++)
        {
            E = D.Errands[j];
            if (E == None || E.Goals.Length == 0)
                return 3;
            Log("PLAUDIT|ERRAND|" $ i $ "|" $ j $ "|" $ E.UniqueName $ "|" $ E.bInitiallyActive $ "|" $ E.SendPlayerURL);
            for (k=0; k<E.Goals.Length; k++)
            {
                if (E.Goals[k] == None)
                    return 4;
                Log("PLAUDIT|GOAL|" $ i $ "|" $ j $ "|" $ k $ "|" $ E.Goals[k]);
                Count++;
            }
        }
    }
    Log("PLAUDIT|PASS|days=" $ G.default.Days.Length $ "|goals=" $ Count);
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
