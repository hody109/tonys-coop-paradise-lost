class PLCoopDiagnostic extends Actor;
function PostBeginPlay() { Super.PostBeginPlay(); SetTimer(5,true); }
function Timer() {
 local CoopPLPlayerClient P;
 P=CoopPLPlayerClient(Owner);
 if(P==None) { Destroy(); return; }
 Log("PLSTATUS|health=" $ P.Pawn.Health $ "|old=" $ P.MyOldState);
 P.PLCoopStatus();
}
defaultproperties { bHidden=True RemoteRole=ROLE_None }
