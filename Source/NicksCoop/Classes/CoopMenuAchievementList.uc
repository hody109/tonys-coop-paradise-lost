//=============================================================================
// CoopMenuAchievementList.uc
//
// Author: Nick Pilshikov "Evil"
// Email: nickp@gopostal.com
// Steam: www.steamcommunity.com/id/evilthedark
// For: Postal2 NicksCoop
// Do not use any resources without permission
//
// 2016.
//=============================================================================

class CoopMenuAchievementList extends MenuAchievementList;

function Notify(UWindowDialogControl C, byte E)
{
	Super(ShellMenuCW).Notify(C, E);
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					/*case NextChoice:
						if (AchIndex + ACH_Max < AchIndexMax)
						{
							AchIndex += ACH_MAX;
							SaveConfig();
						}
						GotoMenu(class'CoopMenuAchievementList');
						break;
					case PrevChoice:
						if (AchIndex <= 0)
							GoBack();
							//GotoMenu(class'CoopMenuAdmin');	// Can't use "GoBack" because it might just pull up the Achievement List again.
						else
						{
							AchIndex = AchIndex - ACH_MAX;
							if (AchIndex <= 0)
								AchIndex = 0;
							SaveConfig();
							GotoMenu(class'CoopMenuAchievementList');
						}
						break;*/
					case BackChoice:
						//GotoMenu(class'CoopMenuAdmin');
						GoBack();
						break;
					}
			break;
		}
}

///////////////////////////////////////////////////////////////////////////////
// Hit escape at any time to exit the achievement list entirely.
///////////////////////////////////////////////////////////////////////////////
function bool KeyEvent( out EInputKey Key, out EInputAction Action, FLOAT Delta )
{
	if (Action == IST_Release)
		{
		switch (Key)
			{
			case IK_ESCAPE:
				GoBack();
				//GotoMenu(class'CoopMenuAdmin');
				return true;
			//case IK_UP:
			case IK_MOUSEWHEELUP:
				ScrollBy(GRID_SCROLL_AMT);
				return true;
			//case IK_DOWN:
			case IK_MOUSEWHEELDOWN:
				ScrollBy(-GRID_SCROLL_AMT);
				return true;
			}
		}
	
	if (Action == IST_Press
		|| Action == IST_Hold)
		{
			switch (Key)
			{
			case IK_UP:
				ScrollBy(GRID_SCROLL_AMT);
				return true;
			case IK_DOWN:
				ScrollBy(-GRID_SCROLL_AMT);
				return true;
			}
		}
		
	// Scroll achievement list
	// FIXME IST_Hold does not work for joysticks
	if (Action == IST_Press || Action == IST_Hold)
	{
		if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_UP_BUTTON) == "1")
		{
			ScrollBy(4*GRID_SCROLL_AMT);
			return true;
		}
		if (Root.GetPlayerOwner().ConsoleCommand("ISKEYBIND"@Key@MENU_DOWN_BUTTON) == "1")
		{
			ScrollBy(-4*GRID_SCROLL_AMT);
			return true;
		}
	}
		
	Super(ShellMenuCW).KeyEvent(Key, Action, Delta);
	return false;
}

defaultproperties
{
}