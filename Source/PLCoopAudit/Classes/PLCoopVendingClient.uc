class PLCoopVendingClient extends CoopPLPlayerClient;
var int BuyIndex;
var float BuyAt;
var bool ReportedMenu;
var class<Inventory> ExpectedKind;
var bool ExpectHealing;
var float VerifyAt,ReopenAt;
replication
{
 reliable if(Role==ROLE_Authority) StartVendorTest,FinishVendorTest;
 reliable if(Role<ROLE_Authority) ReportVendorTest;
}
simulated function StartVendorTest(int Index,class<Inventory> Expected,bool Healing)
{
 ExpectedKind=Expected;ExpectHealing=Healing;VerifyAt=Level.TimeSeconds+25;
 BuyIndex=Index;BuyAt=Level.TimeSeconds+12;
 ActivateItem();
}
simulated function FinishVendorTest() {ConsoleCommand("quit");}
function ReportVendorTest(string S) {Log("PLVENDTEST|CLIENT|"$PlayerReplicationInfo.PlayerName$"|"$S);}
simulated function PlayerTick(float D)
{
 Super.PlayerTick(D);
 if(Role!=ROLE_AutonomousProxy)return;
 if(VerifyAt>0 && Level.TimeSeconds>=VerifyAt)
 {
  VerifyAt=0;
  if(Pawn!=None && ((ExpectHealing && Pawn.Health>25) || Pawn.FindInventoryType(ExpectedKind)!=None))ReportVendorTest("replicated-purchase|PASS");
  else ReportVendorTest("replicated-purchase|FAIL");
  if(PLVendingMenu!=None)PLVendingMenu.CloseMenu();
  ReportedMenu=false;ReopenAt=Level.TimeSeconds+2;
 }
 if(ReopenAt>0 && Level.TimeSeconds>=ReopenAt){ReopenAt=0;ActivateItem();ReportVendorTest("reopen");}
 if(PLVendingMenu!=None && !ReportedMenu)
 {ReportedMenu=true;ReportVendorTest("menu|items="$PLVendorView.ItemList.Length);}
 if(BuyAt>0 && Level.TimeSeconds>=BuyAt && PLVendingMenu!=None)
 {
  BuyAt=0;PLVendingMenu.SelectedItemButton=BuyIndex;PLVendingMenu.AttemptPurchase();
  ReportVendorTest("purchase-request|index="$BuyIndex);
 }
}
