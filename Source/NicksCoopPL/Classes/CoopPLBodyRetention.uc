// Keep local ragdolls after dedicated-server tear-off, instead of the legacy
// twelve-second forced removal. A finite lifetime bounds long-session memory.
class CoopPLBodyRetention extends CoopMiscTimerMulticast_RemoveBody;

simulated function RemoveBody(float Delay)
{
    if(P2MoCapPawn(Owner)!=None && Pawn(Owner).Health<=0)
    {
        Owner.LifeSpan=FMax(1,180-Delay);
        Owner.SetTimer(Owner.LifeSpan,false);
    }
}

simulated function Timer()
{
    // Apply after the initial dying-state setup on clients as well as server.
    RemoveBody(0.5);
}
