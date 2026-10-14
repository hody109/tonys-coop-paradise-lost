// Test-only: exercise the real day-transition method, not the errands that unlock it.
class PLCoopProgressionProbe extends CoopPLGameInfo config(PLProgressionTest);
var config int ExpectedDay;
function PostBeginPlay() { Super.PostBeginPlay(); SetTimer(12,false); }
event Timer() {
 if(TheGameState==None || GetPlayer()==None || TheGameState.CurrentDay!=ExpectedDay) {
  Log("PLDAYS|FAIL|expected=" $ ExpectedDay $ "|actual=" $ TheGameState.CurrentDay);
  ConsoleCommand("exit");return;
 }
 Log("PLDAYS|PASS|day=" $ ExpectedDay $ "|map=" $ Level.GetLocalURL());
 if(ExpectedDay==6) { ConsoleCommand("exit");return; }
 ExpectedDay++;
 class'PLCoopProgressionProbe'.default.ExpectedDay=ExpectedDay;
 SaveConfig();
 SendPlayerToNextDay(GetPlayer());
}
