## Fixes

- Release the outgoing client's Karma physics before network map travel. This addresses the reproduced `KInitActorCollision` crash on a boulder when entering PL-rwsblock from Highlands.
- Keep dedicated-server NPC ragdolls for up to three minutes instead of forcing removal after twelve seconds.
- Keep the West Mall quest monkeys replicated to all players and make them follow a connected player instead of the hidden story pawn. Original quest exit behavior remains intact.
- Raise the default population target from 12 to 30 and the body setting from 8 to 25; remove the inherited ten-body clamp. The launcher migrates only the old default values and preserves other custom values.

## Updating

All players must use the same version. Extract the release over your existing mod folder while the game and launcher are closed, then run **SET UP** to refresh the runtime. Keep your existing Private folder, launcher preferences and saves; none are included in this archive.

## Validation and limits

Built with zero compiler errors or warnings. Two clients (guest through public Playit) completed West Mall -> Highlands -> PL-rwsblock with the combined fixes. Both clients reported six living quest monkeys in West Mall and retained physical ragdolls beyond thirty seconds. The server used population target 30 and body setting 25. Legacy/default configuration migration passed in Windows PowerShell.

These are targeted regression checks on one PC, not a full campaign or a separate-PC reliability test. Higher NPC and corpse counts can increase resource usage. The original game assets and personal test credentials/settings are excluded.
