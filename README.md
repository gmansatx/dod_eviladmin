# DoD EvilAdmin

An admin plugin for **Day of Defeat** (AMX Mod X) that lets admins apply fun/punishing
effects to a target player - slay with an explosion, mute, bury, glow, pimp-slap,
restrict to melee weapons, and more.

- **Plugin file:** `dod_eviladmin2.sma`
- **Author:** g-man   (Had to decompile and rewrite as I did not original other)
- **Version:** 1.0

## Requirements

### Server

| Requirement | Notes |
|---|---|
| AMX Mod X | Base platform the plugin compiles/runs against |
| DoDX module | Provides the Day of Defeat natives (`dod_*`) this plugin calls |
| Day of Defeat server | Tested against DoD / DoD: Beta Legacy |
| HATS plugin *(optional)* | If loaded, a cosmetic hat is added/removed with the shield effect (`amx_evilshield` / `amx_evilunshield`). The plugin runs fine without it. |

### Includes used (for compiling from source)

```
amxmodx.inc
amxmisc.inc
dodfun.inc
dodx.inc
engine.inc
fun.inc
```

### Files to install

Copy these into your server's `addons/amxmodx` and `dod` directories:

| File | Destination |
|---|---|
| `dod_eviladmin2.sma` | `addons/amxmodx/scripting/` (source, optional on live servers) |
| `dod_eviladmin2.amxx` | `addons/amxmodx/plugins/` (compiled plugin - required) |
| `sound/smb_powerup.wav` | `dod/sound/` |
| `sound/misc/shut-up-for-a-sec.wav` | `dod/sound/misc/` |
| `sound/misc/rules.wav` | `dod/sound/misc/` |
| `sound/misc/choke.wav` | `dod/sound/misc/` |
| `sound/misc/nvg_on.wav` | `dod/sound/misc/` |
| `sound/ambience/thunder_clap.wav` | `dod/sound/ambience/` |
| `sound/mapsounds/cowbell.wav` | `dod/sound/mapsounds/` |

The plugin also precaches the stock DoD sprite `sprites/explode1.spr` (used for the
`amx_evilslay` explosion effect) - this ships with the base game, no extra file needed.

## Installation

1. Place `dod_eviladmin2.amxx` in `addons/amxmodx/plugins/`.
2. Add a line to `addons/amxmodx/configs/plugins.ini`:
   ```
   dod_eviladmin2.amxx
   ```
3. Copy the sound files listed above into their matching `dod/sound/...` folders.
4. Make sure the admins you want to use these commands have the **`l`** admin flag
   (`ADMIN_LEVEL_B`) in `addons/amxmodx/configs/users.ini` (or your admin backend).
5. Restart the server or `amx_reloadadmins` + `amxx reload`.

## Commands

All commands require the `l` (`ADMIN_LEVEL_B`) admin flag and take a `<player>`
target (name, partial name, or `#userid`); most accept `@all` / `@team` style targets
too depending on your AMX Mod X version.

| Command | Effect |
|---|---|
| `amx_evilslay <player>` | Slay target with an explosion |
| `amx_evilmelee <player>` / `amx_evilunmelee <player>` | Restrict target to melee weapons only / undo |
| `amx_evilslowdown <player>` / `amx_evilunslowdown <player>` | Deplete target's stamina / restore it |
| `amx_evilmirrordmg <player>` / `amx_evilunmirrordmg <player>` | Damage target deals is mirrored back onto them / disable |
| `amx_evillowhealth <player>` / `amx_evilunlowhealth <player>` | Target spawns with 1 HP / reset to normal |
| `amx_evilhealth90 <player>` / `amx_evilunhealth90 <player>` | Target spawns with 90 HP / reset to normal |
| `amx_evilglow <player>` / `amx_evilunglow <player>` | Target glows in their team color / remove glow |
| `amx_evilstfu <player>` / `amx_evilunstfu <player>` | Mute target's chat and voice comm / unmute |
| `amx_evilpimpslap <player>` | Repeatedly slap target until death |
| `amx_evilbury <player>` / `amx_evilunbury <player>` | Bury target into the ground / dig them out |
| `amx_evilkick <player>` | Kick target from the server |
| `amx_evilvision <player>` / `amx_evilunvision <player>` | Distort target's FOV / restore it |
| `amx_evilnoprone <player>` / `amx_evilunnoprone <player>` | Prevent target from going prone / allow again |
| `amx_evilcowbell <player>` / `amx_eviluncowbell <player>` | Play a cowbell sound whenever target moves / stop |
| `amx_evilshield <player>` / `amx_evilunshield <player>` | Give target 400 HP (+ cosmetic hat if HATS is loaded) / remove it |
| `amx_evilnoflag <player>` / `amx_evilunnoflag <player>` | Block target from capturing flags / allow again |
| `amx_rules <player>` | Play the "rules" sound to target |

## CVars

| CVar | Default | Description |
|---|---|---|
| `sv_evil_spshellthick` | `25` | Thickness of the glow shell effect used by `amx_evilglow` / `amx_evilshield` |

## Notes

- Most effects are automatically re-applied on respawn for as long as they're active
  (e.g. melee-only, glow, low health, mute, shield, cowbell).
- `amx_evilnoprone`, `amx_evilcowbell`, and `amx_evilnoflag` are implemented without
  relying on native DoD cvars - they poll player state each think/round and correct
  it, so they work across DoD mod versions.
