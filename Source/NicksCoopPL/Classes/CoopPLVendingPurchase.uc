// Server-only transaction. The client supplies an index, never a price or class.
class CoopPLVendingPurchase extends Object;
static function bool Buy(CoopPLPlayerClient Buyer,P2EVendingMachineTrigger Vendor,int Index)
{
 local MoneyInv Money;
 local Inventory Owned;
 local Weapon W;
 local Ammunition AmmoOwned;
 local class<Inventory> InventoryKind;
 local CoopGameInfo Game;
 local P2PowerupInv Power;
 local Pickup Pick;
 local class<Pickup> Kind;
 local P2EVendingMachineInteraction Rules;
 local int Price,Amount;
 if(Buyer==None || Buyer.Pawn==None || Buyer.Pawn.Health<=0 || Vendor==None || Index<0 || Index>=Vendor.ItemList.Length)return false;
 Vendor.UpdateItemQuantities();
 Money=MoneyInv(Buyer.Pawn.FindInventoryType(class'MoneyInv'));
 Price=Vendor.ItemList[Index].ItemBuyRate.ItemPrice;
 Amount=Vendor.ItemList[Index].ItemBuyRate.ItemAmount;
 Kind=Vendor.ItemList[Index].ItemPickup;
 if(Money==None || Price<0 || Money.Amount<Price || Vendor.ItemList[Index].QuantityAvailable==255 || Kind==None)return false;
 if(Amount<=0 && (!ClassIsChildOf(Kind,class'WeaponPickup') || Vendor.ItemList[Index].bWeaponIsAlsoAmmo))return false;
 Rules=new(None) class'P2EVendingMachineInteraction';
 Rules.MenuUser=Buyer.Pawn;Rules.VMT=Vendor;Rules.SelectedItemButton=Index;
 if(Rules.DisallowPurchase())return false;
 InventoryKind=Kind.default.InventoryType;
 Game=CoopGameInfo(Buyer.Level.Game);
 if(Game!=None && Game.CoopBaseMutator!=None)InventoryKind=Game.CoopBaseMutator.GetInventoryObjClass(InventoryKind);
 Owned=Buyer.Pawn.FindInventoryType(InventoryKind);
 AmmoOwned=Ammunition(Owned);
 if(AmmoOwned!=None && AmmoOwned.AmmoAmount>=AmmoOwned.MaxAmmo)return false;
 W=Weapon(Owned);Power=P2PowerupInv(Owned);
 if(W!=None && W.AmmoType!=None)
 {
  if(W.AmmoType.AmmoAmount>=W.AmmoType.MaxAmmo)return false;
  if(P2AmmoInv(W.AmmoType)!=None && P2AmmoInv(W.AmmoType).bInfinite)return false;
 }
 if(Power!=None && Power.MaxAmount!=0 && Power.Amount>=Power.MaxAmount)return false;
 // Tag is present before spawn callbacks, so bought weapons/ammo never enter
 // the shared world-pickup respawn path or become free loot for other players.
 Pick=Vendor.Spawn(Kind,Buyer,'PLVendorPurchase',Buyer.Pawn.Location);
 if(Pick==None)return false;
 Pick.SetCollision(false,false,false);
 Pick.bCollideWorld=false;Pick.SetLocation(Buyer.Pawn.Location);
 Pick.GotoState('Pickup');
 if(!ClassIsChildOf(Kind,class'WeaponPickup') || Vendor.ItemList[Index].bWeaponIsAlsoAmmo)
 {
  if(Ammo(Pick)!=None)Ammo(Pick).AmmoAmount=Amount;
  if(P2WeaponPickup(Pick)!=None)P2WeaponPickup(Pick).AmmoGiveCount=Amount;
  if(P2PowerupPickup(Pick)!=None)P2PowerupPickup(Pick).AmountToAdd=Amount;
 }
 if(P2PowerupPickup(Pick)!=None)
 {Pick.GotoState('Pickup');P2PowerupPickup(Pick).bOKToGrab=true;}
 Buyer.PLActiveVendorPickup=Pick;
 Pick.Touch(Buyer.Pawn);
 Buyer.PLActiveVendorPickup=None;
 // Successful pickup destroys the transaction actor (ShouldRespawn returns false).
 if(!Pick.bDeleteMe) {Pick.Destroy();return false;}
 Money.Amount-=Price;
 if(Vendor.ItemList[Index].QuantityAvailable!=0)
 {
  Vendor.ItemList[Index].QuantityAvailable--;
  if(Vendor.ItemList[Index].QuantityAvailable==0)Vendor.ItemList[Index].QuantityAvailable=255;
 }
 Vendor.RecordMoneySpent(Price);
 Log("PLVENDOR|purchased|item="$Kind$"|price="$Price);
 return true;
}
