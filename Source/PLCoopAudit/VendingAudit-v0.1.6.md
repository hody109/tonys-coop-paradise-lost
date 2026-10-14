# Vending regression checks — v0.1.6

Environment: POSTAL 2 / Paradise Lost 5025, native dedicated server, production UDP relay, two real clients on one Windows PC. The second client connected through a public Playit UDP tunnel; it did not connect directly to localhost.

## Implemented behavior

The original vending interaction assumes a local single-player controller. Coop now opens a local menu using a server-provided snapshot. Prices, item classes, daily availability, money and stock are authoritative on the server. Requests validate the live buyer, interaction range, session, item index and capacity. Purchased pickups can only be claimed by the buyer during the transaction and are excluded from shared world-pickup respawning. The original vendor game-state stock tracking is retained.

## Verified cases

- Monday weapon menu: seven entries; health menu: four entries.
- Pistol and stun gun purchases for both players, correct individual payment, inventory replication.
- Medkit purchases heal both wounded players, charge $30 each and replicate health to both clients.
- Pistol ammunition purchases for both players; 20 rounds for $10, visible in the original menu.
- Tuesday health menu: seven entries. Both players buy one Health Pipe for $75; the original two-piece stock becomes sold out.
- Menu close and reopen on both clients.
- Rejection with no money, sold-out stock, full ammunition, invalid item index, stale menu session and out-of-range buyer.
- No purchased pickup remains as free world loot.
- Compilation: zero errors and zero warnings. No vending-specific runtime warnings in the final archived checks.

The test fixture clears the selected starting item before purchase. In particular, test characters can already carry a stun gun with 30/30 ammunition; attempting to buy another correctly fails. Medkits are tested on wounded characters because the original game rejects them at full health.

## Limits

Tests use the actual vendors in PL-Industry. They do not constitute visits to every vending machine, every daily product or a complete campaign run. Both clients ran on one PC; separate-PC network reliability is not established. Previous transition-audit limitations remain unchanged.

## Reproduction fixtures

`Classes/PLCoopVendingProbe.uc` and `Classes/PLCoopVendingClient.uc` are development-only fixtures, compiled in PLCoopAudit, not production game classes. Launch PL-Industry with the probe game type, two clients and a configured public tunnel for the second client. Set SeedDay (0 or 1), TestHealth and RequestedItem in the probe's configuration section. The probe checks server payment/stock and reports client inventory replication. Do not use these fixtures with personal saves. Raw logs and tunnel settings are intentionally excluded from the repository.

## Gameplay package SHA-256

- `NicksCoop.u`: `3a8e6dd518143aab87c65e096a7ec91ff757c1e88a90a7d7341e257f032b557b`
- `NicksCoopPL.u`: `4eaef41c2d7ad5e1bc8ba0bd9cec869ed08c087ad91c9324571fceca0745e05e`
- `PLBase.u`: `389f2f7f4147a96c6c21898fa147a31a46a770817511944894f8604516441d66`
- `PLGame.u`: `e0549b73deb7ac9f29fbff056377e52c5c21b54c998bb8dacd594e02940e4c9e`
