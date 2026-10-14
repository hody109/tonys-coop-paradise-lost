class PLCoopTeamProbe extends CoopPLGameInfo;
var CoopPLPlayerClient TestPlayers[3];
var P2WeaponPickup TestWeapon;
var P2AmmoPickup TestAmmo;
var CoopPLTravelSentinel TestExit;
var class<CoopPLTravelSentinel> TestSentinelClass;
var int Phase;
var float NextProbe;

function Check(bool OK,string Message)
{
    if(OK) Log("PLTEAM|PASS|" $ Message);
    else Log("PLTEAM|FAIL|" $ Message);
}

function int ClaimCount(Pickup Item)
{
    local int i,N;
    for(i=0;i<PLPickupClaims.Length;i++) if(PLPickupClaims[i].Item==Item) N++;
    return N;
}

event Tick(float D)
{
    local CoopPLPlayerClient P;
    local int N,OldAmmo;
    local Weapon W;
    local vector Center,OldThird;
    Super.Tick(D);
    if(Level.TimeSeconds<NextProbe || Phase>5) return;
    NextProbe=Level.TimeSeconds+2;
    N=FindTestPlayers();
    if(N!=3 || Level.TimeSeconds<35) return;
    if(Phase==0)
    {
        StopSceneManagers();
        TestExit=Spawn(TestSentinelClass,,,TestPlayers[0].Pawn.Location);
        TestExit.SetCollision(false,false,false);
        TestExit.SetCollisionSize(1,1);
        Check(TestExit.GetLevelPlayersNum()==3,"three humans; story bot excluded");
        Check(!TestExit.GetFinalAccess(),"one of three cannot travel");
        Center=(TestPlayers[0].Pawn.Location+TestPlayers[1].Pawn.Location+TestPlayers[2].Pawn.Location)/3;
        TestExit.SetLocation(Center);
        TestExit.SetCollisionSize(2000,2000);
        Check(TestExit.GetFinalAccess(),"three of three can travel");
        OldThird=TestPlayers[2].Pawn.Location;
        TestPlayers[2].Pawn.bCollideWorld=false;
        Check(TestPlayers[2].Pawn.SetLocation(OldThird+vect(0,0,10000)),"place third player outside exit");
        Check(TestExit.GetAccessPlayersNum()==1 && !TestExit.GetFinalAccess(),"two of three cannot travel");
        TestPlayers[2].Pawn.SetLocation(OldThird);
        TestPlayers[2].Pawn.bCollideWorld=true;
        TestPlayers[2].Pawn.Health=0;
        Check(!TestExit.GetFinalAccess(),"downed participant is not silently omitted");
        TestPlayers[2].Pawn.Health=100;
        TestWeapon=Spawn(class'Inventory.ShotgunPickup',,,Center+vect(0,0,80));
        TestWeapon.GotoState('Pickup');TestWeapon.SetCollision(false,false,false);
        TestWeapon.Touch(TestPlayers[0].Pawn);
        Check(ClaimCount(TestWeapon)==1,"weapon first claim");
    }
    else if(Phase==1)
    {
        Check(!TestWeapon.bDeleteMe,"weapon survives first pickup");
        W=Weapon(TestPlayers[0].Pawn.FindInventoryType(TestWeapon.InventoryType));
        OldAmmo=W.AmmoType.AmmoAmount;
        TestWeapon.Touch(TestPlayers[0].Pawn);
        Check(W.AmmoType.AmmoAmount==OldAmmo && ClaimCount(TestWeapon)==1,"same player cannot farm weapon");
        TestWeapon.Touch(TestPlayers[1].Pawn);
        Check(ClaimCount(TestWeapon)==2,"weapon second claim");
    }
    else if(Phase==2)
    {
        TestWeapon.Touch(TestPlayers[2].Pawn);
        Check(ClaimCount(TestWeapon)==3,"weapon third claim");
        TestAmmo=Spawn(class'Inventory.ShotgunAmmoPickup',,,TestWeapon.Location+vect(0,0,10));
        TestAmmo.SetCollision(false,false,false);
        W=Weapon(TestPlayers[0].Pawn.FindInventoryType(TestWeapon.InventoryType));
        W.AmmoType.AmmoAmount=W.AmmoType.MaxAmmo;
        TestAmmo.Touch(TestPlayers[0].Pawn);
        Check(ClaimCount(TestAmmo)==0,"full ammo does not consume claim");
        W.AmmoType.AmmoAmount=0;
        TestAmmo.Touch(TestPlayers[0].Pawn);
        Check(ClaimCount(TestAmmo)==1 && W.AmmoType.AmmoAmount>0,"ammo first claim");
    }
    else if(Phase==3)
    {
        W=Weapon(TestPlayers[0].Pawn.FindInventoryType(TestWeapon.InventoryType));
        OldAmmo=W.AmmoType.AmmoAmount;
        TestAmmo.Touch(TestPlayers[0].Pawn);
        Check(W.AmmoType.AmmoAmount==OldAmmo,"same player cannot farm ammo");
        TestAmmo.Touch(TestPlayers[1].Pawn);
        Check(ClaimCount(TestAmmo)==2,"ammo second claim");
    }
    else if(Phase==4)
    {
        TestAmmo.Touch(TestPlayers[2].Pawn);
        Check(ClaimCount(TestAmmo)==3,"ammo third claim");
    }
    else
    {
        Check(!TestWeapon.bDeleteMe && !TestAmmo.bDeleteMe,"both pickups remain available");
        Log("PLTEAM|DONE");
        ConsoleCommand("exit");
    }
    Phase++;
}

function int FindTestPlayers()
{
 local CoopPLPlayerClient P;
 local int N;
 foreach DynamicActors(class'CoopPLPlayerClient',P)
  if(P.Player!=None && P.Pawn!=None && N<3) {TestPlayers[N]=P;N++;}
 return N;
}
defaultproperties
{
 TestSentinelClass=class'CoopPLTravelSentinel'
}


