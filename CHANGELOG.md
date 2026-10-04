# Changelog

## 1.2.0 — Minimap Command Palette and WoW Forever
- Upgraded the movable minimap button: left-click opens Sound Studio, right-click opens a compact command palette (configuration, commands, audio preview/stop, alert toggle, help and Retail-only Mythic+).
- Added an interactive Commands page and `/tbs commands`, `/tbs help`, `/tbs settings`, `/tbs minimap show|hide|reset` with an easy way to restore the button.
- Added interface `16001` and explicit WoW Forever detection (modern project ID + version/interface).
- Completely disables bundled Keystone Sync on Forever before global registration, messages or events; removes the Mythic+ tab and commands from the interface/help/menu.
- Added indexed aura fallback and direct haste-buff checks for Forever, retaining Retail Sated/Exhaustion polling, login suppression and replay protection.
- Bundled library has only a two-line Forever guard ahead of its original unchanged implementation and MIT license.
- Original OGG files still require the included one-time sound installer.

# Changelog

## 1.1.0
- Bundled LibTomoKeystoneSync-1.0 unmodified, with its original MIT license.
- Added a Mythic+ tab for group and session keystones, party/guild requests, and chat output.
- Added `/tbs key`, `/tbs guild`, and `/tbs known`.
- Added English and French translations for keystone features.
- Preserved the sound studio, original audio presets, and duplicate-alert safeguards.

# 1.0.0 — First standalone release

- Extracted Bloodlust detection, sound presets, channel selection, preview controls, chat and debugging from TomoMod.
- Added a new purple/teal Sound Studio, a sound library, dashboard, minimap launcher, and French/English localization.
- Prevents duplicate audio with TomoMod by default and imports former Bloodlust preferences on first use.
- Retained loading-screen suppression, aura-flicker protection, and respect for WoW's global audio settings.
- Included one-time installers to recover the five unchanged original OGG files from TomoMod or GitHub.
