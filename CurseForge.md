# TomoBloodlustSound

**Your Bloodlust. Your soundtrack.**

TomoBloodlustSound is a standalone **World of Warcraft Retail** addon by **TomoAniki**, based on TomoMod's Bloodlust Sound feature. It plays your chosen audio alert when Bloodlust, Heroism or an equivalent haste effect reaches your character, and gives you a dedicated Sound Studio to customize the experience.

## Features

- **Smart Bloodlust detection:** recognizes the player's Sated, Exhaustion and related effects from Bloodlust, Heroism, Time Warp, Primal Rage, Fury of the Aspects and other equivalent abilities. Login and zone-transition protection prevents outdated alerts, while a short grace period handles aura flicker.
- **Five original sound presets:** Taluani BL, Golden Kpop, Spinning Cat, Chipi Chapa and BLWOW Danger.
- **Sound Studio:** a modern purple-and-teal interface with one-click previews, sound selection, a stop button and live detection status.
- **Audio settings:** select the Master, SFX, Music, Ambience or Dialog channel. The volume control adjusts the selected **global WoW channel volume**, not an independent addon volume. Normal playback respects your game audio settings.
- **Personal preferences:** chat notifications, optional debug messages, a movable minimap button and French/English localization.
- **TomoMod coexistence:** imports your previous Bloodlust settings on first launch when available. By default, the standalone stays silent if TomoMod's own Bloodlust alert is already enabled, preventing duplicate playback.

## New in v1.2.0: Mythic+ Keystone Sync

**LibTomoKeystoneSync-1.0 is bundled**, so TomoBloodlustSound can exchange Mythic+ keystone information with other compatible addons without requiring TomoMod. The dedicated **Mythic+** tab lets you:

- View your group members' known keystones.
- Request fresh data from your party or guild.
- Review the keys received during the current session.
- Print group or known keys in chat.

The shared library uses the `TOMOKEYS` protocol and avoids duplicate outgoing synchronization when TomoMod's native KeySync is already active. Other players need a compatible addon to reply.

## Installation and sound files

1. Extract **TomoBloodlustSound** into your Retail `Interface/AddOns` directory.
2. **Install the five original OGG files once.** They are not embedded in this release ZIP: run `Tools/Installer-les-sons.bat` on Windows, run `python3 Tools/install_sounds.py` on macOS/Linux, or copy the five unmodified files from `TomoMod/Assets/Sounds` into `TomoBloodlustSound/Assets/Sounds`. The installers verify the original Git file checksums.
3. Enable the addon and type `/tbs` to open Sound Studio.

You do **not** need TomoMod installed. The bundled Mythic+ library is subject to its included MIT license; the original audio keeps its own license.

## Chat commands

- `/tbs` or `/tbls` — Open or close Sound Studio.
- `/tbs preview` — Preview your selected sound.
- `/tbs stop` — Stop the preview or active alert.
- `/tbs on` / `/tbs off` — Enable or disable Bloodlust detection.
- `/tbs status` — Show the detection state.
- `/tbs key` — Request your party's keystones and print the responses after a short wait.
- `/tbs guild` — Request your guild's keystones.
- `/tbs known` — Print the keystones currently known to the library.

**Author:** TomoAniki  
**Original project:** [TomoMod](https://github.com/tomoaniki93/TomoMod)  
**Platform:** World of Warcraft Retail

## Minimap command palette and Forever support (v1.2.0)

Left-click the draggable minimap icon to open the Sound Studio. Right-click for configuration, interactive commands, preview/stop, and alert controls. Open the new Commands page with `/tbs commands`, or restore a hidden minimap icon with `/tbs minimap show`.

Retail and WoW Forever share the same standalone package. On Forever (interface 16001), the Sound Studio, audio alerts, minimap button and normal sound commands are available; Mythic+ and Keystone Sync are strictly disabled.
