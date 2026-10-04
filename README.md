# TomoBloodlustSound 1.2.0

Standalone Bloodlust / Heroism sound alerts, extracted from TomoMod by **TomoAniki**.
Modern purple-and-teal Sound Studio, French/English UI, and five original sound presets.

## One-time sound installation

The code ZIP cannot include the five OGG binaries in this environment. Choose **one** method to
place the *unaltered* originals inside `TomoBloodlustSound/Assets/Sounds/`:

- **Windows (easy):** double-click `Tools/Installer-les-sons.bat` with an Internet connection. It calls the PowerShell installer; it first copies the sounds from a neighboring TomoMod folder when possible, then downloads anything missing from the author's GitHub repository.
- **macOS / Linux / Steam Deck:** run `python3 Tools/install_sounds.py` from anywhere.
- **Manual:** copy `Assets/Sounds/*.ogg` from your TomoMod installation into the standalone's `Assets/Sounds/` directory. Preserve the filenames.

The original audio source and license are:
https://github.com/tomoaniki93/TomoMod/tree/main/Assets/Sounds

The scripts verify each file's original Git blob SHA-1 (including its `blob <length>\0`
header), so partial or incorrect downloads are not silently installed. The sound files
are copied unchanged and never transcoded.

## Installation

1. Extract the release ZIP into `World of Warcraft/_retail_/Interface/AddOns/` or Forever's `_classic_beta_/Interface/AddOns/`.
2. Run the sound installer once (unless you copied the five OGG files manually).
3. In WoW, enable **TomoBloodlustSound** and use `/tbs` to open Sound Studio.
4. If TomoMod is also installed, disable TomoMod's own Bloodlust Sound feature
   to avoid duplicate alerts. By default this addon silences itself while that
   feature is enabled.

## Commands

- `/tbs key`: request party keys and print them after a short delay.
- `/tbs guild`: request guild keys.
- `/tbs known`: print known keys from this session.

- `/tbs` or `/tbls`: toggle Sound Studio.
- `/tbs preview`: play the selected sound.
- `/tbs stop`: stop the preview and current alert.
- `/tbs on` or `/tbs off`: enable / disable the alert.
- `/tbs status`: show detection state.

## Behavior and compatibility

- Retail Interface 120105 / 120100 and WoW Forever 16001 (in-game validation required on your current build).
- On Forever, the bundled Keystone Sync library returns before initialization: no Mythic+ UI, no keystone requests, no addon-message events or callbacks. The sound studio and minimap command menu still load.
- On Forever, the aura detector falls back to indexed modern `C_UnitAuras` when needed and also recognizes available direct haste buffs.
- Detects Bloodlust, Heroism, Time Warp, Primal Rage, Fury of the Aspects and
  related effects by the player's Sated/Exhaustion debuffs.
- Suppresses replay after a login or zone change, and tolerates brief aura flickers.
- Plays through the selected WoW audio channel; does not force muted channels or
  change audio CVars during playback.
- The optional volume slider explicitly changes the selected channel's **global**
  volume in WoW, exactly as the original TomoMod Sound panel did.
- On first run, imports the former TomoMod Bloodlust options if present; it
  does not modify TomoMod's database.

**Author:** TomoAniki. The original audio remains governed by the license in
`Assets/Sounds/LICENSE`, included with the sound installer or copied from TomoMod.

Original sources inspected from `tomoaniki93/TomoMod` main at
`1242249226a59df127abca945afd5468942e0432`.


## Mythic+ keystone synchronization (v1.2.0)

The bundled `LibTomoKeystoneSync-1.0` answers and receives compatible Mythic+
keystone requests (`TOMOKEYS` protocol), including when TomoMod is absent.
The **Mythic+** tab shows group members and keys known in the current session,
and lets you request updates from the party or guild. Guild requests populate
the **Known this session** view; those records are not a live guild roster.

Commands: `/tbs key` requests the party then reports its keys in chat;
`/tbs guild` requests guild keys; `/tbs known` prints the current session cache.
The shared library avoids duplicate outgoing messages when TomoMod already
handles the transport. The library source and its MIT license are preserved
under `Libs/LibTomoKeystoneSync-1.0/`.

## Minimap button (v1.2.0)

- Left-click: open or close Sound Studio.
- Right-click: a quick menu for Settings, Commands, preview, stop, enable/disable, help, and Mythic+ (Retail only).
- Left-drag: move the button around the minimap; the position is saved.
- `/tbs minimap show` restores the button if hidden in Settings; `/tbs minimap hide` hides it; `/tbs minimap reset` also restores its default position.
- `/tbs commands` opens an interactive command list; `/tbs help` prints the available commands.

**Note:** The original vendored Keystone Sync code is preserved after a two-line client guard at the beginning, preventing any initialization on Forever. Original library license is unchanged.
