class TestMP_MenuMain extends MenuMain;

function CreateMenuContents()
	{
	Super(BaseMenuBig).CreateMenuContents();
	AddTitleBitmap(TitleTexture);
	NewChoice     = AddChoice(NewGameText,		NewGameHelp,									ItemFont, ItemAlign);

	if(GetGameSingle() != None && GetGameSingle().VerifySeqTime(true))
		ShellRootWindow(Root).bVerified = true;
	// Only add this option in after you've beaten the game
	// 8/15 - Kamek - moved this to MenuStart
	//if(ShellRootWindow(Root).bVerified)
	//	EnhancedChoice= AddChoice(EnhancedText,		"",									ItemFont, ItemAlign);
	LoadChoice    = AddChoice(LoadGameText,		LoadGameHelp,	ItemFont, ItemAlign);
	
	if (FPSPlayer(GetPlayerOwner()).bEnableDebugMenu)
		DebugChoice = AddChoice(DebugText, DebugHelp, ItemFont, ItemAlign);
		
	//!! FIXME - launching DLC doesn't seem to work properly in Linux.
	if (PlatformIsWindows())
		MultiChoice   = AddChoice(MultiText,		MultiHelp,									ItemFont, ItemAlign);

	if (!GetLevel().SteamOwnsDLC(PL_DLC_APPID) && GetLevel().IsSteamBuild())
		ActualDLCChoice = AddChoice(ActualDLCText, ActualDLCHelp, ItemFont, ItemAlign);
	else if (PlatformIsWindows())
		LaunchPLChoice = AddChoice(LaunchPLText, LaunchPLHelp, ItemFont, ItemAlign);
		
	if (GetLevel().SteamOwnsDLC(ED_DLC_APPID) && PlatformIsWindows())
		LaunchEDChoice = AddChoice(LaunchEDText, LaunchEDHelp, ItemFont, ItemAlign);
	
	if (GetGameSingle().IsHoliday(DLC_Holiday))
	{
		DLCChoice	= AddChoice(DLCText,		"",									ItemFont, ItemAlign);
		DLCChoice.SetTextColor(DLCTextColor);
	}
	
	OptionsChoice = AddChoice(OptionsText,		"",									ItemFont, ItemAlign);
	ExitChoice    = AddChoice(ExitGameText,		"",									ItemFont, ItemAlign);

	// 01/23/03 JMI Don't allow access to load or save in demos.
	//				NOTE: This only works for ShellMenuChoices--not actual controls.
	LoadChoice.bActive = !GetLevel().IsDemoBuild();

	// Reset this value. When MenuDifficultyPatch starts up, it's the only one that needs it
	// and it will set it when necessary.
	ShellRootWindow(Root).bFixSave=false;
	
	AddSocialIcons();
	}

function Notify(UWindowDialogControl C, byte E)
	{
	local String NewGameURL;
	local bool bShowEnhanced;
	local class<UMenuStartGameWindow> StartGameClass;

	Super.Notify(C, E);
	switch(E)
		{
		case DE_Click:
			if (C != None)
				switch (C)
					{
					case NewChoice:
						// Start new game
						SetSingleplayer();
						ShellRootWindow(Root).bVerifiedPicked=false;
						bShowEnhanced = bool(GetPlayerOwner().ConsoleCommand("get"@EnhancedPath));
						if (!bShowEnhanced
							&& GetGameSingle().SeqTimeVerified())
							GotoMenu(class'MenuEnhanced');
						else if(!GetLevel().IsDemoBuild())
							// If not in the demo--allow them to pick the difficulty
							GotoMenu(class'MenuStart');
						else
							// The difficulty is set to default for the demo.
							// Go to the explaination instead.
							GotoMenu(class'MenuImageDemoExplain');
						break;

					case EnhancedChoice:
						SetSingleplayer();
						ShellRootWindow(Root).bVerifiedPicked=true;
						GotoMenu(class'MenuEnhanced');
						break;

					case LoadChoice:
						SetSingleplayer();
						GotoMenu(class'MenuLoad');
						break;

					case MultiChoice:
						GotoMenu(class'MenuMulti');
						//GotoMenu(class'MenuDLCLaunchMulti'); // not technically DLC, but is launched in the same manner.
						break;

					case OptionsChoice:
						GoToMenu(class'MenuOptions');
						break;

					case DebugChoice:
						GoToMenu(class'P2DebugMenu_Main');
						break;
						
					// Fake April Fools "DLC" (maybe get rid of this now that we have actual DLC?)
					case DLCChoice:
						// Launch specialized workshop menu
						StartGameClass = class<UMenuStartGameWindow>(DynamicLoadObject("Shell.DLCMainWindow", class'Class'));
						GotoWindow(Root.CreateWindow(StartGameClass, 100, 100, 200, 200, Self, True));
						break;
						
					// Actual DLC choice, displayed if the user does not have Paradise Lost installed.
					// Launches Steam store page.
					case ActualDLCChoice:
						GetLevel().SteamViewStorePage(PL_DLC_APPID);						
						break;
						
					// Actual DLC choice, displayed if the user owns PL.
					case LaunchPLChoice:
						GotoMenu(class'MenuDLCLaunchPL');
						break;
						
					// Actual DLC choice, displayed if the user owns ED.
					case LaunchEDChoice:
						GotoMenu(class'MenuDLCLaunchED');
						break;

					case ExitChoice:
						GoToMenu(class'MenuQuitExitConfirmation');	// 01/21/03 JMI Now looks for confirmation.
						break;
					}
				break;
		}
	}

defaultproperties
	{
	}
