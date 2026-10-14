class PLCoopRagdollProbe extends CoopPLGameInfo;
var int Phase;
var float NextProbe;
var PersonPawn Victim;
var PLCoopRagdollClient A,B;
event Tick(float D)
{
 local PLCoopRagdollClient C;
 local PersonPawn P;
 local vector V;
 local rotator R;
 Super.Tick(D);
 if(Level.TimeSeconds<NextProbe || Phase>2)return;
 NextProbe=Level.TimeSeconds+4;
 A=None;B=None;
 foreach DynamicActors(class'PLCoopRagdollClient',C)
  if(C.Player!=None && C.Pawn!=None) {if(A==None)A=C;else B=C;}
 if(A==None || B==None || Level.TimeSeconds<35)return;
 if(Phase==0)
 {
  StopSceneManagers();
  foreach DynamicActors(class'PersonPawn',P)
   if(!P.bPlayer && P.Health>0 && !P.bForbidRagdoll && P.Controller!=None) {Victim=P;break;}
  if(Victim==None){Log("PLRAG|FAIL|no test NPC");Phase=3;return;}
  V=A.Pawn.Location+vector(A.Rotation)*220+vect(0,0,140);
  Victim.bCollideWorld=false;Victim.SetLocation(V);Victim.bCollideWorld=true;Victim.SetPhysics(PHYS_None);
  Victim.Controller.GotoState('');
  B.Pawn.SetLocation(A.Pawn.Location+vect(0,80,0));
  foreach DynamicActors(class'PLCoopRagdollClient',C)
   if(C.Player!=None && C.Pawn!=None) {R=rotator(Victim.Location-C.Pawn.Location);C.SetRotation(R);C.ClientSetRotation(R);}
  Log("PLRAG|NPC|"$Victim$"|pos="$Victim.Location);
 }
 else if(Phase==1) {A.ClientWatchBody(Victim);B.ClientWatchBody(Victim);}
 else
 {
  Log("PLRAG|KILL|"$Victim);
  Victim.TearOffMomentum=vect(1000,0,0);
  Victim.Died(A,class'BulletDamage',Victim.Location);
  Log("PLRAG|DEAD|health="$Victim.Health$"|tearoff="$Victim.bTearOff);
 }
 Phase++;
}
defaultproperties
{
 PlayerControllerClassName="PLCoopAudit.PLCoopRagdollClient"
}
