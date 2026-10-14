class CoopPLTravelSentinel extends CoopTelepadBlockerSentinel;

function bool IsParticipant(Controller C)
{
    return CoopPlayerController(C)!=None && PlayerController(C).Player!=None
        && !CoopPlayerController(C).IsCoopDedicatedHost()
        && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator;
}

function int GetLevelPlayersNum()
{
    local Controller C;
    local int Total;
    for(C=Level.ControllerList;C!=None;C=C.NextController)
        if(IsParticipant(C)) Total++;
    return Total;
}

function int GetAccessPlayersNum()
{
    local Controller C;
    local vector Offset;
    local int Missing;
    for(C=Level.ControllerList;C!=None;C=C.NextController)
        if(IsParticipant(C))
        {
            if(C.Pawn==None || C.Pawn.bDeleteMe || C.Pawn.Health<=0) {Missing++;continue;}
            Offset=C.Pawn.Location-Location;
            if(Abs(Offset.Z)>CollisionHeight+C.Pawn.CollisionHeight
                || Square(Offset.X)+Square(Offset.Y)>Square(CollisionRadius+C.Pawn.CollisionRadius)) Missing++;
        }
    return Missing;
}

function bool GetFinalAccess()
{
    return GetLevelPlayersNum()>0 && GetAccessPlayersNum()==0;
}

function TravelAccessControl(bool Granted)
{
    if(CoopGameReplicationInfo(Level.Game.GameReplicationInfo)!=None
        && CoopGameReplicationInfo(Level.Game.GameReplicationInfo).bCoopLevelLoading) return;
    // Once the whole team has arrived, keep the corridor open until everyone
    // leaves it. Closing on one UnTouch can trap the remaining players.
    if(!Granted && CoopPLTelepadBlocker(Owner)!=None
        && CoopPLTelepadBlocker(Owner).bPLOpen
        && GetAccessPlayersNum()<GetLevelPlayersNum()) return;
    if(CoopTelepadBlocker(Owner)!=None) CoopTelepadBlocker(Owner).TravelAccessControl(Granted);
    // Keep observing departures even while the exit is open.
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.25,true);
}

function RegisterRequest(PersonPawn P)
{
    Super.RegisterRequest(P);
    SetTimer(0.25,true);
}

function UnTouch(Actor Other)
{
    Super.UnTouch(Other);
    TravelAccessControl(GetFinalAccess());
}

function Timer()
{
    TravelAccessControl(GetFinalAccess());
}
