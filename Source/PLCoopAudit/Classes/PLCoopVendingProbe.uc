class PLCoopVendingProbe extends PLCoopPresentationProbe;
var P2EVendingMachineTrigger TestVendor;
var int Phase,ItemIndex,Price,InitialQuantity;
var float NextAt;
var config bool TestHealth;
var config int RequestedItem;
function Tick(float D)
{
 local PLCoopVendingClient C;
 local P2EVendingMachineTrigger V;
 local MoneyInv Money;
 local Inventory Owned;
 local Ammunition AmmoOwned;
 local Weapon OwnedWeapon;
 local int OldQuantity;
 local Pickup P;
 local int N,I;
 local vector Spot;
 if(Sent || GetPlayer()==None || Level.TimeSeconds<NextAt)return;
 foreach DynamicActors(class'PLCoopVendingClient',C)if(C.Player!=None && C.Pawn!=None)N++;
 if(N<2)return;
 if(Phase==0)
 {
  StopSceneManagers();
  foreach AllActors(class'P2EVendingMachineTrigger',V)
  {
   V.InitializeDayItemList();V.UpdateItemQuantities();
   Log("PLVENDTEST|vendor|"$V$"|items="$V.ItemList.Length);
   if(TestVendor==None && ((TestHealth && V.IsA('HealthVendingMachine')) || (!TestHealth && V.IsA('WeaponsVendingMachine'))))TestVendor=V;
  }
  if(TestVendor==None){Log("PLVENDTEST|FAIL|no weapon vendor");Sent=true;return;}
  ItemIndex=-1;
  for(I=0;I<TestVendor.ItemList.Length;I++)
  {
   if(TestVendor.ItemList[I].ItemPickup==None)TestVendor.ItemList[I].ItemPickup=class<Pickup>(DynamicLoadObject(TestVendor.ItemList[I].ItemPickupName,class'Class'));
   Log("PLVENDTEST|item|"$I$"|"$TestVendor.ItemList[I].ItemPickup$"|price="$TestVendor.ItemList[I].ItemBuyRate.ItemPrice$"|quantity="$TestVendor.ItemList[I].QuantityAvailable);
   if(ItemIndex<0 && TestVendor.ItemList[I].ItemBuyRate.ItemPrice>0 && (TestVendor.ItemList[I].QuantityAvailable==0 || (TestVendor.ItemList[I].QuantityAvailable>=2 && TestVendor.ItemList[I].QuantityAvailable<255)))ItemIndex=I;
  }
  if(RequestedItem>=0 && RequestedItem<TestVendor.ItemList.Length)ItemIndex=RequestedItem;
  if(ItemIndex<0){Log("PLVENDTEST|FAIL|no test item");Sent=true;return;}
  Price=TestVendor.ItemList[ItemIndex].ItemBuyRate.ItemPrice;
  InitialQuantity=TestVendor.ItemList[ItemIndex].QuantityAvailable;
  foreach DynamicActors(class'PLCoopVendingClient',C)
  {
   C.bGodMode=true;
   Money=MoneyInv(C.Pawn.FindInventoryType(class'MoneyInv'));
   if(Money==None)Money=MoneyInv(P2Pawn(C.Pawn).CreateInventoryByClass(class'MoneyInv'));
   Money.Amount=5000;
   Spot=TestVendor.Location;Spot.X+=40;
   C.Pawn.SetCollision(false,false,false);C.Pawn.bCollideWorld=false;C.Pawn.SetLocation(Spot);
   C.Pawn.bCollideWorld=true;C.Pawn.SetPhysics(PHYS_Falling);
   C.ClientSetLocation(Spot,C.Rotation);
  }
  Phase=1;NextAt=Level.TimeSeconds+5;return;
 }
 if(Phase==1)
 {
  foreach DynamicActors(class'PLCoopVendingClient',C)
  {
  Owned=C.Pawn.FindInventoryType(CoopBaseMutator.GetInventoryObjClass(TestVendor.ItemList[ItemIndex].ItemPickup.default.InventoryType));
  Log("PLVENDTEST|initial-inventory|"$Owned);
  if(Weapon(Owned)!=None && Weapon(Owned).AmmoType!=None)Log("PLVENDTEST|initial-ammo|"$Weapon(Owned).AmmoType.AmmoAmount$"/"$Weapon(Owned).AmmoType.MaxAmmo);
  if(Owned!=None)Owned.Destroy();
  Money=MoneyInv(C.Pawn.FindInventoryType(class'MoneyInv'));Money.Amount=5000;if(TestHealth)C.Pawn.Health=25;C.StartVendorTest(ItemIndex,CoopBaseMutator.GetInventoryObjClass(TestVendor.ItemList[ItemIndex].ItemPickup.default.InventoryType),TestHealth && ItemIndex==0);}
  Phase=2;NextAt=Level.TimeSeconds+45;return;
 }
 foreach DynamicActors(class'PLCoopVendingClient',C)
 {
  Money=MoneyInv(C.Pawn.FindInventoryType(class'MoneyInv'));
  Owned=C.Pawn.FindInventoryType(CoopBaseMutator.GetInventoryObjClass(TestVendor.ItemList[ItemIndex].ItemPickup.default.InventoryType));
  if(Money!=None && Money.Amount==5000-Price && (Owned!=None || (TestHealth && C.Pawn.Health>25)))
   Log("PLVENDTEST|PASS|buyer|"$C.PlayerReplicationInfo.PlayerName);
  else Log("PLVENDTEST|FAIL|buyer|"$C.PlayerReplicationInfo.PlayerName$"|money="$Money.Amount$"|item="$Owned);
 }
 foreach DynamicActors(class'PLCoopVendingClient',C)
 {
  Money=MoneyInv(C.Pawn.FindInventoryType(class'MoneyInv'));
  OldQuantity=TestVendor.ItemList[ItemIndex].QuantityAvailable;
  TestVendor.ItemList[ItemIndex].QuantityAvailable=255;
  TestVendor.RecordMoneySpent(0);Money.Amount=5000;C.PLNextVendorRequest=0;
  C.ServerPLBuyVendor(C.PLVendorSession,ItemIndex);
  if(Money.Amount==5000)Log("PLVENDTEST|PASS|sold-out");else Log("PLVENDTEST|FAIL|sold-out");
  TestVendor.ItemList[ItemIndex].QuantityAvailable=OldQuantity;TestVendor.RecordMoneySpent(0);
  Owned=C.Pawn.FindInventoryType(CoopBaseMutator.GetInventoryObjClass(TestVendor.ItemList[ItemIndex].ItemPickup.default.InventoryType));
  AmmoOwned=Ammunition(Owned);OwnedWeapon=Weapon(Owned);
  if(OwnedWeapon!=None)AmmoOwned=OwnedWeapon.AmmoType;
  if(AmmoOwned!=None)
  {
   AmmoOwned.AmmoAmount=AmmoOwned.MaxAmmo;C.PLNextVendorRequest=0;
   C.ServerPLBuyVendor(C.PLVendorSession,ItemIndex);
   if(Money.Amount==5000)Log("PLVENDTEST|PASS|full-ammo");else Log("PLVENDTEST|FAIL|full-ammo");
  }
  Money.Amount=0;C.PLNextVendorRequest=0;
  C.ServerPLBuyVendor(C.PLVendorSession,ItemIndex);
  if(Money.Amount==0)Log("PLVENDTEST|PASS|no-funds");else Log("PLVENDTEST|FAIL|no-funds");
  Money.Amount=5000;C.PLNextVendorRequest=0;
  C.ServerPLBuyVendor(C.PLVendorSession,-1);
  if(Money.Amount==5000)Log("PLVENDTEST|PASS|invalid-index");else Log("PLVENDTEST|FAIL|invalid-index");
  C.PLNextVendorRequest=0;C.ServerPLBuyVendor(C.PLVendorSession-1,ItemIndex);
  if(Money.Amount==5000)Log("PLVENDTEST|PASS|stale-session");else Log("PLVENDTEST|FAIL|stale-session");
  Spot=C.Pawn.Location;C.Pawn.bCollideWorld=false;C.Pawn.SetLocation(Spot+vect(0,0,1000));
  C.PLNextVendorRequest=0;C.ServerPLBuyVendor(C.PLVendorSession,ItemIndex);
  if(Money.Amount==5000)Log("PLVENDTEST|PASS|out-of-range");else Log("PLVENDTEST|FAIL|out-of-range");
  C.Pawn.SetLocation(Spot);C.Pawn.bCollideWorld=true;
 }
 if(InitialQuantity>0)
 {
  if((InitialQuantity==2 && TestVendor.ItemList[ItemIndex].QuantityAvailable==255) || TestVendor.ItemList[ItemIndex].QuantityAvailable==InitialQuantity-2)Log("PLVENDTEST|PASS|limited-stock");
  else Log("PLVENDTEST|FAIL|limited-stock");
 }
 foreach DynamicActors(class'Pickup',P)if(P.Tag=='PLVendorPurchase')Log("PLVENDTEST|FAIL|leftover purchased pickup");
 Sent=true;Log("PLVENDTEST|DONE");
 foreach DynamicActors(class'PLCoopVendingClient',C)C.FinishVendorTest();
 for(I=0;I<160;I++)Log("PLVENDTEST|flush-completed-results--------------------------------------");
}
defaultproperties
{
 RequestedItem=-1
 SeedDay=0
 PlayerControllerClassName="PLCoopAudit.PLCoopVendingClient"
}
