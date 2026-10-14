# Tony's coop: Paradise Lost

An experimental cooperative campaign mod for **POSTAL 2: Paradise Lost, build 5025**, based on Nick's Coop and its unfinished Paradise Lost port.

Play the Paradise Lost campaign with friends using an English Windows launcher, shared progression, character selection and optional Playit.gg hosting.

## Status

The project includes all seven campaign stages. Networking, scripted day transitions, save restoration and selected gameplay features have been tested. **A complete playthrough of every mission, boss and ending has not been verified.** Public-tunnel tests used two clients on one PC; they do not establish reliability between two separate PCs.

This is a community project, not an official release by Running With Scissors or the original Nick's Coop author. Steam Workshop publishing and Steam invitations are not implemented.

## Requirements

- Windows with .NET Framework 4 and Windows PowerShell.
- Your own installed copies of POSTAL 2 (5025) and Paradise Lost, using the supported **5025** version.
- [Nick's Coop](https://steamcommunity.com/sharedfiles/filedetails/?id=737631813), installed through Steam Workshop.
- The same mod packages on every player's computer. Keep Steam running.

## Getting started

1. Download the latest [Release](https://github.com/hody109/tonys-coop-paradise-lost/releases). Extract a complete playable package into a writable folder. A source checkout needs the launcher build step below first.
2. Run `TonysCoopParadiseLost.exe` or `Launch.cmd`.
3. Select your `POSTAL2Complete` installation and click **SET UP**. Setup checks supported file hashes and creates an isolated `Runtime` folder.
4. Enter your nickname and select a character.
5. Choose **NEW CAMPAIGN**, **CONTINUE**, or **JOIN GAME**.

Setup uses files from your own game installation. The original installation and its single-player saves remain separate.

## Hosting and joining

The default mode starts a dedicated server on the host's PC. Select the player limit and difficulty before starting a new campaign. Keep the launcher open while playing.

For internet play, open **INTERNET**, install Playit, and use **START / LINK AGENT** to link it to your own account. Create a Custom UDP tunnel pointing to `127.0.0.1:7777`, or the public UDP port selected in the launcher. Save the tunnel's public `hostname:port`. Friends enter that address and choose **JOIN GAME**. Only the host needs the Playit agent. The host PC must stay on.

The launcher starts a UDP relay automatically for dedicated hosting. Leave Playit's target on the selected public port; the game's internal port is managed automatically. Direct host (experimental) does not use this relay.

For LAN play, connect to the host's local IPv4 address and selected port. The launcher does not configure your firewall or router.

## Gameplay

- Only the host can press **Enter** to start the intro. Other gameplay controls remain locked during the waiting period and intro.
- During the intro, each connected player can press **Enter** to vote to skip. Everyone must agree.
- Select the Paradise Lost Dude or an original Nick's Coop character in the launcher.
- All connected non-spectator players must gather at a zone exit. Revive downed teammates before leaving; AFK players still count.
- Standard weapon and ammunition pickups remain available for other players after you collect them. Quest items retain their special behavior.
- Progress is checkpointed at map transitions. **CONTINUE** uses the saved destination; arbitrary single-player quicksaving is not supported.
- Starting a new campaign backs up the previous co-op save under `SaveBackups`.
- **TEST SECOND PLAYER** launches another client through your saved public Playit address for testing on the same PC.

### Difficulty

The host's **DIFFICULTY (NEW GAME)** setting offers the original 5025 presets:

Liebermode, Too Easy, Very Easy, Easy, Remedial, Average, Aggressive, Hard, Very Hard, Manic, Hestonworld, Insane-o, They Hate Me, POSTAL and Impossible.

The default is **Average**. Continue preserves the saved difficulty; joining uses the host's campaign setting.

## Building

Run from the project folder in Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BuildLauncher.ps1
```

This builds the launcher and UDP relay with the installed .NET Framework compiler. To rebuild the UnrealScript packages, first complete setup, then run `Build.ps1`. Output goes into a timestamped `Builds` directory. Inspect the compiler log and deploy the matching four packages to every player's installation together. Rebuilding changes package identity; do not mix builds.

`Source/PLCoopAudit` contains developer checks. Some historical test scripts require the original development workspace and are not a portable test suite.

## Troubleshooting and reporting issues

Include the game build, mod revision, day, map, task, last action, and whether the problem affects the host or joining player. Say whether you used LAN, Playit, or experimental direct hosting.

Use **LOGS** to locate `PLCoop-Server.log` and `PLCoop-Player.log`. Review logs before sharing: remove `PLHostKey` values and personal addresses. Never upload `Private`, `Runtime`, `SaveBackups` or launcher preferences to GitHub.

See [the launcher guide](README-LAUNCHER.txt) for more details and [GitHub setup](GITHUB-SETUP.md) for repository instructions.

## Credits and redistribution

Based on **Nick's Coop by Nick Pilshikov / Evil** and the author's [unfinished Paradise Lost port](https://www.moddb.com/mods/nickscoop-postal-2-coop/downloads/nickscoop-paradiselost-unfinished-files). Original source headers and the [original author's notes](Source/Original-author-readme.txt) are retained. POSTAL 2 and Paradise Lost belong to their respective owners.

Inherited source headers require permission to use their resources. This repository does not establish permission to redistribute them, and no blanket open-source license is granted. Before public distribution, resolve permissions for inherited code/assets and bundled artwork/music. See [release preparation](WORKSHOP-PREPARATION.txt).
