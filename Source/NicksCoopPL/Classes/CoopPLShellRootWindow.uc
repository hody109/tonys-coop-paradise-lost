//=============================================================================
// CoopPLShellRootWindow.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2017.
//=============================================================================

class CoopPLShellRootWindow extends CoopShellRootWindow;

var Texture PLDayTexture;
var string PLDayFromLevel;
var string PLDayName;
var bool bPLDayRendered;

function ShowPLDayLoad(string TextureName,string DayName)
{
    PLDayTexture=Texture(DynamicLoadObject(TextureName,class'Texture'));
    PLDayFromLevel=ParseLevelName(Root.GetLevel().GetLocalURL());
    PLDayName=DayName;
    bPLDayRendered=false;
    Log("PLDAYCARD|received|" $ DayName $ "|" $ TextureName);
}

function PostRender(Canvas C)
{
    local string Current;
    local bool bEntry;
    local float W,X;
    Super.PostRender(C);
    if(PLDayTexture==None) return;
    Current=ParseLevelName(Root.GetLevel().GetLocalURL());
    bEntry=(Current ~= "Entry" || Current ~= "Index");
    if(MenuError(MyMenu)!=None || (!bEntry && !(Current ~= PLDayFromLevel)))
    {
        PLDayTexture=None;
        Log("PLDAYCARD|finished|" $ PLDayName);
        return;
    }
    C.Style=1;
    C.SetDrawColor(0,0,0,255);
    C.SetPos(0,0);
    C.DrawTile(CoopLoadingBlackTex,C.ClipX,C.ClipY,0,0,1,1);
    W=FMin(C.ClipX,C.ClipY*float(PLDayTexture.USize)/PLDayTexture.VSize);
    X=(C.ClipX-W)*0.5;
    C.SetDrawColor(255,255,255,255);
    C.SetPos(X,0);
    C.DrawTile(PLDayTexture,W,C.ClipY,0,0,PLDayTexture.USize,PLDayTexture.VSize);
    if(!bPLDayRendered)
    {
        bPLDayRendered=true;
        Log("PLDAYCARD|rendered|" $ PLDayName $ "|" $ PLDayTexture);
    }
}

// A deliberate Quit Game returns to the external launcher.
// Keep forced end-of-campaign/menu travel separate from user-requested exit.
function CoopQuitCurrentGame()
{
    if (IsGameMenu())
        GetPlayerOwner().ConsoleCommand("quit");
}

defaultproperties
{
	CoopMenuClass=class'CoopPLMenu'
	//xMainMenuClass=class'CoopPLMenuMain'
	//xGameMenuClass=class'CoopTubeMenuGame'
	//xMultiMenuClass=class'CoopTubeMenuGameMulti'
}
