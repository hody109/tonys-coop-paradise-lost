Tony's coop: Paradise Lost / LAUNCHER
Community test build for POSTAL 2 + Paradise Lost 5025

Open TonysCoopParadiseLost.exe (or Launch.cmd). No additional download is needed
for the launcher on this Windows installation. It uses .NET Framework 4.

PLAY
Enter your nickname. NEW CAMPAIGN starts a local server and connects your
game to it. Your previous co-op save is backed up under SaveBackups first.
New campaigns load the original PL intro. At Waiting for players, let your
friends connect. Only the host can press ENTER to begin.
The intro starts after an 8-second countdown. Continue does not replay it.
CONTINUE uses your last map-transition checkpoint. It is unavailable until
the save contains a destination map. Original single-player saves are separate.
Progress is saved at location transitions, not by arbitrary quicksaving.

JOIN
Enter your friend's IP address or hostname, optionally with :port, and choose
JOIN GAME. Both players need exactly the same compiled mod packages.
The default UDP port is 7777. Set the host's port in the HOST A CAMPAIGN area.
The players setting controls the host's maximum number of players (2–8).
Use INTERNET for the optional Playit.gg tunnel, or connect directly on your LAN.
This launcher does not implement Steam invitations or change firewall rules.

OPTIONS
Fullscreen changes how the game opens. Direct host (experimental) selects the
less-tested listen-server mode instead of the background dedicated server.
Preferences are stored locally in launcher-settings.xml.
The launcher stays responsive while the game runs. Closing it during a session
minimizes it; quit the game first. The local server then stops automatically.
In-game Quit Game now exits the game client and brings the launcher back,
instead of opening the inherited Nick's Coop main menu.
If another launcher already owns the runtime, launching a second session fails
without replacing the active save. Details appear in the status area.

FIRST SETUP ON ANOTHER COMPUTER
Own and install POSTAL 2 and Paradise Lost, and subscribe to Nick's Coop
(Workshop item 737631813). Extract the complete package to a writable folder.
Select the POSTAL2Complete installation directory and choose SET UP.
After setup, this button becomes VERIFY FILES and checks compatibility.
Setup creates an isolated Runtime folder without modifying the original game.
Keep Steam running when playing. The ZIP does not contain the full game or DLC.

DIAGNOSTICS
The activity area shows setup and startup errors. LOGS opens Runtime/System;
look for PLCoop-Server.log and PLCoop-Player.log. Do not upload personal saves
or launcher preferences as part of a public mod release.

BUILD
BuildLauncher.ps1 compiles the included C# source into the Windows executable.
Build.ps1 separately rebuilds the UnrealScript game packages.
The launcher is a local frontend to Setup.ps1 and Launch.ps1. Optional Playit hosting connects to Playit.gg. Account linking opens your browser.
The mod itself does not implement telemetry or an auto-updater.

CURRENT VALIDATION
The mod has passed local two-client networking, a shared location transition,
save-state reload, all seven day starts, and scripted transitions through all
seven campaign stages. Full mission/boss/cinematic completion and two-PC
internet play remain unverified. This launcher does not change those limits.

WORKSHOP
See WORKSHOP-PREPARATION.txt. This is a usable standalone launcher, not yet
an integrated POSTAL 2 in-game Workshop entry. Nothing has been published.

INTERNET / PLAYIT.GG
Open INTERNET, INSTALL, then START / LINK AGENT. Choose OPEN LINK to
approve the agent in your own Playit account. In DASHBOARD create a free
Custom UDP tunnel with one port, local IP 127.0.0.1 and local port matching
the launcher (7777 by default). Save its public hostname:port in the dialog.
Enable automatic startup if desired. Friends paste that address into JOIN GAME.
Only the host needs Playit; keep the host PC and launcher running. Confirm
that the dashboard reports Online. A running process alone does not prove
that the tunnel is reachable. Public two-PC play has not yet been tested.

The agent is pinned to supported version 0.17.1 and SHA-256 checked. Its
credentials stay in Private/Playit; never publish that folder, Runtime,
SaveBackups or launcher-settings.xml. Game logs may contain a temporary
host-session key; redact PLHostKey values before sharing diagnostics.
Free UDP availability: https://playit.gg/
Official agent: https://github.com/playit-cloud/playit-agent

CHARACTER SELECTION
Before hosting or joining, choose CHARACTER at the top of the launcher.
Each player saves their own selection. The options include the default
Paradise Lost Dude and all 15 original Nick's Coop character skins.
The selection applies to your next session and travels with your character.
These are the original Nick's Coop appearances, not arbitrary NPC models.

INTRO CONTROLS
Only the host can start the intro from the waiting screen. From the
waiting screen until the first map loads, game keyboard and mouse inputs are blocked, including Escape, console,
firing, inventory and camera controls. ENTER is the only exception: before
the intro only the host may start it; while it plays each connected player
may vote to skip it. All connected players must agree. One vote per player.
Controls return automatically in the first map. Operating-system shortcuts
such as switching windows or closing the game remain available.

CINEMATIC HOST VISIBILITY
On dedicated servers, the scripted Dude represents the host during cinematic
scenes. The host's duplicate gameplay body is hidden for the scene and
restored afterwards. Other connected players remain visible.

SECOND-PLAYER TEST THROUGH PLAYIT
Start NEW CAMPAIGN or CONTINUE. When your host game has opened, use Alt+Tab
back to this launcher and click TEST SECOND PLAYER. A second window joins
the public address saved in INTERNET as <nickname>_Test, wearing Blue Dude.
Use Alt+Tab to switch windows. Both players must press ENTER to skip the
intro; only the original host can start it. Quit the test window to disconnect.
The test player uses separate settings and a separate PLCoop-TestPlayer.log.
Playit must be linked and its tunnel must point to this server. No second Steam account is required.
The server must have a free player slot. This tests the Playit relay from your PC, not a friend's PC.

NARRATED MAP BRIEFING
Story-triggered new errands are revealed one by one with their original
Paradise Lost voice lines and fading map markers. Opening the map manually
still shows the normal co-op overview.

TEAM TRAVEL AND PICKUPS
Zone exits require every connected non-spectator player to gather at the
same exit. AFK players still count. Revive a downed player before leaving.
Disconnected players stop counting automatically; the server story bot
never counts. Scripted story transitions retain their existing behavior.
After everyone has gathered, the exit stays open while the team passes
through. The barrier resets only after everyone leaves the gathering area.
Its collision state is synchronized to each client.
Each standard weapon or ammo pickup can be collected once by each player
in that loaded zone. Taking it leaves it available for other players.
Full ammunition does not consume your pickup claim. Quest and inventory
transfer weapons retain their special story behavior.
LAUNCHER RADIO
Ah-Ah starts automatically at low volume when the launcher opens.
The vinyl record rotates while the track plays. PAUSE holds your position;
PLAY resumes; STOP rewinds. The track loops when it reaches the end.
Starting a game pauses the music. You can still control the player during a
session. Closing the launcher releases the audio player.
RAGDOLL PHYSICS
The launcher loads the original game's Karma skeleton assets for NPC bodies.
Existing Client/Server configurations are repaired automatically before launch.
Restart the game after updating; the physics assets load at process startup.


FASTER PLAYIT MAP CHANGES (2026-10-14)
Default hosting starts PLCoopRelay.exe automatically. It keeps the public UDP
port open while the dedicated game server changes maps. Leave your Playit
local target at 127.0.0.1:7777 (or the UDP port selected in the launcher).
The game server uses a separate internal port chosen automatically; do not
copy that internal port into Playit. Keep PLCoopRelay.exe beside the launcher.
The relay stops when hosting ends. Experimental listen hosting does not use it.
A measured public-tunnel map transition improved from 101-104 seconds to 7-8
seconds on the test PC; actual map and network loading times vary.

HOST DIFFICULTY
Choose DIFFICULTY (NEW GAME) before starting a new campaign. Default: Average.
Continue preserves the saved difficulty; joining follows the host.
Original 5025 presets: Liebermode, Too Easy, Very Easy, Easy, Remedial,
Average, Aggressive, Hard, Very Hard, Manic, Hestonworld, Insane-o,
They Hate Me, POSTAL, Impossible.

PROJECT NAME
Tony's coop: Paradise Lost is based on Nick's Coop. Original credits are preserved.
Internal game package and runtime executable names remain unchanged for
save and network compatibility.

CLEAN DISTRIBUTION
New installations have no linked Playit account, public tunnel address, saved
campaign or personal launcher preferences. Each host links their own account.
The release excludes local diagnostic logs and installed game data.
