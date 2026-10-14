class PLCoopIntroInspect extends CoopPLGameInfo;
function PostBeginPlay() {
 local MaterialTrigger T; local int i;
 Super.PostBeginPlay();
 foreach AllActors(class'MaterialTrigger',T) {
  Log("PLMAT|" $ T $ "|tag=" $ T.Tag);
  for(i=0;i<T.MaterialsToTrigger.Length;i++) Log("PLMAT|surface=" $ T.MaterialsToTrigger[i] $ "|class=" $ T.MaterialsToTrigger[i].Class);
 }
 SetTimer(3,false);
}
function Timer(){ConsoleCommand("exit");}
