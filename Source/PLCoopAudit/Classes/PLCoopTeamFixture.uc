// Server-only test actors; no second client or localhost network connection.
class PLCoopTeamFixture extends PLCoopTeamProbe;
var bool FixturesCreated;
function int FindTestPlayers()
{
    local int i;
    local string Error;
    local vector Pos;
    if(Level.TimeSeconds<35) return 0;
    if(!FixturesCreated)
    {
        FixturesCreated=true;
        StopSceneManagers();
        Pos=GetPlayer().Pawn.Location;
        for(i=0;i<3;i++)
        {
            TestPlayers[i]=CoopPLPlayerClient(Login("","?Name=Fixture" $ i,Error));
            RestartPlayer(TestPlayers[i]);
            TestPlayers[i].Tag='TeamFixture';
            TestPlayers[i].bGodMode=true;
            TestPlayers[i].Pawn.SetLocation(Pos+vect(0,80,0)*i);
        }
    }
    return 3;
}
defaultproperties
{
    TestSentinelClass=class'PLCoopFixtureSentinel'
}
