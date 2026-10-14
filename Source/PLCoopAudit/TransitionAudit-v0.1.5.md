# Transition crash audit - v0.1.5

Confirmed loading transitions: 20/115. Candidate links passed: 20/102. Maps reached by both clients: 11/38.

Status: stopped at the user's request. No further tests or game changes were made. The last attempted transition (step 20, PL-Greenbelt2 -> PL-Industry2#Pad3) did not receive both client confirmations: clients returned to Entry/menu and the server later timed out. The cause has not been diagnosed; this is not a confirmed native crash or a passed transition. Remaining rows are untested.

Day-chain check: all seven stages passed, including new-day title cards on both clients. Guest connection: public Playit. Both clients ran on one PC.

Loading checks call the production SendPlayerEx route after killing up to three available NPCs. A successful row requires source travel plus subsequent client-confirmed arrival in the same test session. This does not complete missions or validate all trigger/unlock conditions and all day-specific variants.

| Step | Source | Destination | Loading result | Runtime exit | Target tag |
|---:|---|---|---|---|---|
| 0 | PL-Highlands | PL-Greenbelt2#greenbelt2_highlands?peer | PASS | enabled | 1 match(es) |
| 1 | PL-Greenbelt2 | PL-Highlands#highlands_greenbelt2?peer | PASS | enabled | 1 match(es) |
| 2 | PL-Highlands | PL-Industry#Pad1?peer | PASS | enabled | 1 match(es) |
| 3 | PL-Industry | PL-Highlands#Pad3?peer | PASS | enabled | 1 match(es) |
| 4 | PL-Highlands | PL-rwsblock#pod5?peer | PASS | enabled | 1 match(es) |
| 5 | PL-rwsblock | PL-Highlands#Pad5?peer | PASS | enabled | 1 match(es) |
| 6 | PL-Highlands | PL-Church#Pad11?peer | PASS | enabled | 1 match(es) |
| 7 | PL-Church | PL-Highlands#Pad11?peer | PASS | enabled | 1 match(es) |
| 8 | PL-Highlands | PL-Church#Pad7?peer | PASS | enabled | 1 match(es) |
| 9 | PL-Church | PL-Highlands#Pad7?peer | PASS | enabled | 1 match(es) |
| 10 | PL-Highlands | PL-EastMall#Pad2?peer | PASS | enabled | 1 match(es) |
| 11 | PL-EastMall | PL-Highlands#Pad9?peer | PASS | enabled | 1 match(es) |
| 12 | PL-Highlands | PL-WestMall#Pad1?peer | PASS | enabled | 1 match(es) |
| 13 | PL-WestMall | PL-Highlands#Pad10?peer | PASS | enabled | 1 match(es) |
| 14 | PL-Highlands | PL-Church#Pad8?peer | PASS | enabled | 1 match(es) |
| 15 | PL-Church | PL-underhub#pod2?peer | PASS | enabled | 1 match(es) |
| 16 | PL-underhub | PL-suburbs-3#podhole?peer | PASS | enabled | 1 match(es) |
| 17 | PL-suburbs-3 | PL-suburbs-1#sub1_sub3a?peer | PASS | enabled | 1 match(es) |
| 18 | PL-suburbs-1 | PL-industry2#Industry2_sub1?peer | PASS | enabled | 1 match(es) |
| 19 | PL-Industry2 | PL-Greenbelt2#Pad5?peer | PASS | enabled | 1 match(es) |
| 20 | PL-Greenbelt2 | PL-Industry2#Pad3?peer | INCOMPLETE | enabled | 1 match(es) |
| 21 | PL-Industry2 | PL-Greenbelt2#Pad6?peer | NOT TESTED | enabled |  |
| 22 | PL-Greenbelt2 | PL-Greenbelt1#Pad3?peer | NOT TESTED | enabled |  |
| 23 | PL-Greenbelt1 | PL-suburbs-1#Sub1_greenbelt1?peer | NOT TESTED | not confirmed as telepad |  |
| 24 | PL-suburbs-1 | PL-suburbs-2#pod2?peer | NOT TESTED | enabled |  |
| 25 | PL-suburbs-2 | PL-suburbs-1#pod4?peer | NOT TESTED | not confirmed as telepad |  |
| 26 | PL-suburbs-1 | PL-suburbs-2#pod9?peer | NOT TESTED | enabled |  |
| 27 | PL-suburbs-2 | PL-suburbs-1#pod5?peer | NOT TESTED | not confirmed as telepad |  |
| 28 | PL-suburbs-1 | PL-rwsblock#rwsblock_sub1?peer | NOT TESTED | enabled |  |
| 29 | PL-rwsblock | PL-Estates#estates_rwsblock_alley?peer | NOT TESTED | enabled |  |
| 30 | PL-Estates | PL-Suburbs-3#sub3_estates?peer | NOT TESTED | not confirmed as telepad |  |
| 31 | PL-suburbs-3 | PL-suburbs-4#pod1?peer | NOT TESTED | enabled |  |
| 32 | PL-suburbs-4 | PL-suburbs-2#GhettoEntranceTele?peer | NOT TESTED | not confirmed as telepad |  |
| 33 | PL-suburbs-2 | PL-Greenbelt1#greenbelt1_sub2?peer | NOT TESTED | not confirmed as telepad |  |
| 34 | PL-Greenbelt1 | PL-Greenbelt2#Pad1?peer | NOT TESTED | not confirmed as telepad |  |
| 35 | PL-Greenbelt2 | PL-Industry#industry_greenbelt2?peer | NOT TESTED | enabled |  |
| 36 | PL-Industry | PL-Greenbelt2#greenbelt2_industry?peer | NOT TESTED | enabled |  |
| 37 | PL-Greenbelt2 | PL-Industry2#Pad4?peer | NOT TESTED | enabled |  |
| 38 | PL-Industry2 | PL-Industry#industry1_industry2?peer | NOT TESTED | enabled |  |
| 39 | PL-Industry | PL-Industry2#industry2_industry1?peer | NOT TESTED | enabled |  |
| 40 | PL-Industry2 | PL-Suburbs-1#sub1_industry2?peer | NOT TESTED | enabled |  |
| 41 | PL-suburbs-1 | PL-suburbs-3#sub3_sub1?peer | NOT TESTED | enabled |  |
| 42 | PL-suburbs-3 | PL-estates#estates_sub3?peer | NOT TESTED | enabled |  |
| 43 | PL-Estates | PL-rwsblock#rwsblock_estates_alley?peer | NOT TESTED | not confirmed as telepad |  |
| 44 | PL-rwsblock | PL-EastMall#Pad1?Peer | NOT TESTED | enabled |  |
| 45 | PL-EastMall | PL-WestMall#Pad4?peer | NOT TESTED | enabled |  |
| 46 | PL-WestMall | PL-Highlands#Pad2?Peer | NOT TESTED | enabled |  |
| 47 | PL-Highlands | PL-Compound#Pad1?peer | NOT TESTED | enabled |  |
| 48 | PL-Compound | PL-Highlands#Pad1?peer | NOT TESTED | not confirmed as telepad |  |
| 49 | PL-Highlands | PL-Outro | NOT TESTED | not confirmed as telepad |  |
| 50 | PL-Outro | PL-Credits#CreditsStart?peer | NOT TESTED | not confirmed as telepad |  |
| 51 | PL-Credits | PL-BanditHideout | NOT TESTED | setup |  |
| 52 | PL-BanditHideout | PL-suburbs-4#pod9?peer | NOT TESTED | not confirmed as telepad |  |
| 53 | PL-suburbs-4 | PL-forest#ForestEntranceTele?peer | NOT TESTED | not confirmed as telepad |  |
| 54 | PL-forest | PL-Suburbs-2#pod5?peer | NOT TESTED | not confirmed as telepad |  |
| 55 | PL-suburbs-2 | PL-forest#ForestEntranceTele?peer | NOT TESTED | not confirmed as telepad |  |
| 56 | PL-forest | PL-underhub#pod2forest?peer | NOT TESTED | not confirmed as telepad |  |
| 57 | PL-underhub | PL-Church#pad9?peer | NOT TESTED | enabled |  |
| 58 | PL-Church | PL-Highlands#Pad8?peer | NOT TESTED | enabled |  |
| 59 | PL-Highlands | PL-WestMall#Pad2?Peer | NOT TESTED | enabled |  |
| 60 | PL-WestMall | PL-EastMall#Pad3?peer | NOT TESTED | enabled |  |
| 61 | PL-EastMall | PL-rwsblock#Pad6?Peer | NOT TESTED | enabled |  |
| 62 | PL-rwsblock | PL-Estates#estates_rwsblock_bridge?peer | NOT TESTED | enabled |  |
| 63 | PL-Estates | PL-Meadow#PlayerStart?peer | NOT TESTED | not confirmed as telepad |  |
| 64 | PL-Meadow | PL-Estates#oldmanreturn?peer | NOT TESTED | not confirmed as telepad |  |
| 65 | PL-Estates | PL-rwsblock#rwsblock_estates_bridge?peer | NOT TESTED | not confirmed as telepad |  |
| 66 | PL-rwsblock | PL-suburbs-1#sub1_rwsblock?peer | NOT TESTED | enabled |  |
| 67 | PL-suburbs-1 | PL-Greenbelt1#Greenbelt1_sub1?peer | NOT TESTED | enabled |  |
| 68 | PL-Greenbelt1 | PL-Industry2#Pad2?peer | NOT TESTED | not confirmed as telepad |  |
| 69 | PL-Industry2 | PL-ColemanCave#Pad1?peer | NOT TESTED | enabled |  |
| 70 | PL-ColemanCave | PL-Industry2#ColeMinePad?peer | NOT TESTED | not confirmed as telepad |  |
| 71 | PL-Industry2 | PL-Greenbelt1#Pad4?peer | NOT TESTED | enabled |  |
| 72 | PL-Greenbelt1 | PL-suburbs-2#sub2_greenbelt1?peer | NOT TESTED | not confirmed as telepad |  |
| 73 | PL-suburbs-2 | PL-suburbs-4#HideoutEntranceTele?peer | NOT TESTED | not confirmed as telepad |  |
| 74 | PL-suburbs-4 | PL-Suburbs-3#pod6?peer | NOT TESTED | not confirmed as telepad |  |
| 75 | PL-suburbs-3 | PL-underhub#pod777?peer | NOT TESTED | enabled |  |
| 76 | PL-underhub | PL-ToraBora#pad1?peer | NOT TESTED | enabled |  |
| 77 | PL-ToraBora | PL-underhub#pod3?peer | NOT TESTED | not confirmed as telepad |  |
| 78 | PL-underhub | PL-forest#podholio?peer | NOT TESTED | enabled |  |
| 79 | PL-forest | PL-suburbs-4#pod3?peer | NOT TESTED | not confirmed as telepad |  |
| 80 | PL-suburbs-4 | PL-BanditHideout#pod1?peer | NOT TESTED | not confirmed as telepad |  |
| 81 | PL-BanditHideout | PL-Brewery | NOT TESTED | setup |  |
| 82 | PL-Brewery | PL-Industry#BrewPad?peer | NOT TESTED | not confirmed as telepad |  |
| 83 | PL-Industry | PL-Saloon#Jail?peer | NOT TESTED | enabled |  |
| 84 | PL-Saloon | PL-Industry#TheHole?peer | NOT TESTED | not confirmed as telepad |  |
| 85 | PL-Industry | PL-Brewery#IndyPad?peer | NOT TESTED | enabled |  |
| 86 | PL-Brewery | PL-ColemanCave | NOT TESTED | setup |  |
| 87 | PL-ColemanCave | PL-EndOfThursday?peer | NOT TESTED | not confirmed as telepad |  |
| 88 | PL-EndOfThursday | PL-Greenbelt2 | NOT TESTED | setup |  |
| 89 | PL-Greenbelt2 | PL-RoboFact#Pad1?peer | NOT TESTED | enabled |  |
| 90 | PL-RoboFact | PL-Greenbelt2#Pad11?peer | NOT TESTED | not confirmed as telepad |  |
| 91 | PL-Greenbelt2 | PL-Junkyard#Pad7?peer | NOT TESTED | enabled |  |
| 92 | PL-Junkyard | PL-Greenbelt2#Pad7?peer | NOT TESTED | not confirmed as telepad |  |
| 93 | PL-Greenbelt2 | PL-JunkyardArena-Apoc#ApocalypsePad?peer | NOT TESTED | enabled |  |
| 94 | PL-JunkyardArena-Apoc | PL-Greenbelt2#Pad7?peer | NOT TESTED | not confirmed as telepad |  |
| 95 | PL-Greenbelt2 | PL-Hell_ent | NOT TESTED | setup |  |
| 96 | PL-Hell_ent | PL-Hell_Part1 | NOT TESTED | not confirmed as telepad |  |
| 97 | PL-Hell_Part1 | PL-Hell_Part2#HellPart2_HellPart1?peer | NOT TESTED | not confirmed as telepad |  |
| 98 | PL-Hell_Part2 | PL-FinalBoss?peer | NOT TESTED | not confirmed as telepad |  |
| 99 | PL-FinalBoss | PL-Hell_Part2 | NOT TESTED | setup |  |
| 100 | PL-Hell_Part2 | PL-Hell_Part1#HellPart1_HellPart2?peer | NOT TESTED | not confirmed as telepad |  |
| 101 | PL-Hell_Part1 | PL-Intro | NOT TESTED | setup |  |
| 102 | PL-Intro | PL-Highlands#PlayerStart?peer | NOT TESTED | not confirmed as telepad |  |
| 103 | PL-Highlands | PL-Outro-AC | NOT TESTED | setup |  |
| 104 | PL-Outro-AC | PL-Credits#CreditsStart?peer | NOT TESTED | not confirmed as telepad |  |
| 105 | PL-Credits | PL-RoboFact | NOT TESTED | setup |  |
| 106 | PL-RoboFact | PL-Greenbelt2#Pad2?peer | NOT TESTED | not confirmed as telepad |  |
| 107 | PL-Greenbelt2 | PL-suburbs-1 | NOT TESTED | setup |  |
| 108 | PL-suburbs-1 | PL-suburbs-3#sub3_sub1b | NOT TESTED | enabled |  |
| 109 | PL-suburbs-3 | PL-suburbs-1#sub1_sub3b?peer | NOT TESTED | enabled |  |
| 110 | PL-suburbs-1 | PL-suburbs-2 | NOT TESTED | setup |  |
| 111 | PL-suburbs-2 | PL-WinterWonderLand#WonderLandEntrance?peer | NOT TESTED | not confirmed as telepad |  |
| 112 | PL-WinterWonderLand | PL-suburbs-2#pod69?peer | NOT TESTED | not confirmed as telepad |  |
| 113 | PL-suburbs-2 | PL-EndOfMonday | NOT TESTED | setup |  |
| 114 | PL-EndOfMonday | PL-JunkyardArena | NOT TESTED | setup |  |
