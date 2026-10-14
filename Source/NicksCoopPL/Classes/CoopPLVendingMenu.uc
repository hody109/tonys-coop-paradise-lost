class CoopPLVendingMenu extends P2EVendingMachineInteraction;
var CoopPLPlayerClient Buyer;
var int Session;
var bool Pending, Closed;
function InitializeMenu(Pawn User,P2EVendingMachineTrigger Vendor)
{
 Super.InitializeMenu(User,Vendor);
 // Original localized key icons do not resolve in network games.
 HintTextMouse[0]="Point to select. Left click to buy.";
 HintTextMouse[1]="Mouse wheel to scroll. Esc to exit.";
}
function PlaySong(string SongName,optional float FadeInTime,optional float Volume)
{
 if(SongName!="") SongHandle=ViewportOwner.Actor.PlayMusic(SongName,FadeInTime,,false);
}
function StopSong(optional float FadeOutTime)
{
 if(SongHandle!=0) ViewportOwner.Actor.StopMusic(SongHandle,FadeOutTime);
 SongHandle=0;
}
function AttemptPurchase()
{
 if(Closed || Pending || Buyer==None || VMT==None || SelectedItemButton<0 || SelectedItemButton>=VMT.ItemList.Length) return;
 Pending=true;
 Buyer.ServerPLBuyVendor(Session,SelectedItemButton);
}
function AttemptSell() {}
function Tick(float D)
{
 // Avoid indexing empty greeting arrays on a network snapshot.
 bPlayGreeting=false;
 Super.Tick(D);
 if(Buyer==None || Buyer.Pawn==None || Buyer.Pawn.Health<=0) CloseMenu();
}
function CloseMenu()
{
 if(Closed) return;
 Closed=true;
 if(Buyer!=None) {Buyer.ServerPLCloseVendor(Session);Buyer.PLVendingMenu=None;Buyer.PLVendorView=None;}
 ResumeGame();StopSong();
 UWindowRootWindow(Master.BaseMenu).bAllowJoyMouse=false;
 if(VMT!=None) VMT.Destroy();
 Master.RemoveInteraction(self);
}
defaultproperties
{
 HintTextMouse(0)="Point to select. Left click to buy."
 HintTextMouse(1)="Mouse wheel to scroll. Esc to exit."
 bAutoRemoveAfterLevelChange=True
}
