# LibTomoKeystoneSync-1.0

A small embeddable World of Warcraft library for exchanging Mythic+ keystone
information between addons.

## Goals

- No LibOpenRaid dependency.
- One tiny wire protocol shared by TomoMod and third-party addons.
- Safe to embed in several addons at the same time.
- Does not send duplicate packets when TomoMod's native KeySync is present.
- Gracefully does nothing on clients without Mythic+.
- Can both answer key requests and consume keys from other compatible addons.

## Protocol

Addon-message prefix:

`TOMOKEYS`

Version 1 request:

`1:?`

Version 1 key payload:

`1:K:<challengeMapID>:<level>:<classID>:<specID>:<rating>`

Unknown protocol versions must be ignored.

## Embedding

Copy:

`Libs/LibTomoKeystoneSync-1.0/LibTomoKeystoneSync-1.0.lua`

into your addon and load it before the code that uses it.

TOC example:

`Libs\LibTomoKeystoneSync-1.0\LibTomoKeystoneSync-1.0.lua`

Access the library with:

```lua
local KeySync = _G["LibTomoKeystoneSync-1.0"]
```

The convenience alias below is also available:

```lua
local KeySync = LibTomoKeystoneSync
```

## Public API

### Read the local player's key

```lua
local key = KeySync.ReadOwnKeystone()
```

Returned fields:

- `challengeMapID`
- `mythicPlusMapID`
- `level`
- `classID`
- `specID`
- `rating`

### Ask the current party/raid for keys

```lua
KeySync.RequestKeystoneDataFromParty()
```

### Ask the guild for keys

```lua
KeySync.RequestKeystoneDataFromGuild()
```

### Read known keys

```lua
local all = KeySync.GetAllKeystonesInfo()
local playerKey = KeySync.GetKeystoneInfo("player")
local party1Key = KeySync.GetKeystoneInfo("party1")
```

### Receive updates

```lua
KeySync.RegisterCallback("MyAddon", "KeystoneUpdate", function(fullName, entry, allKeys)
    print(fullName, entry.level, entry.challengeMapID)
end)
```

Remove the callback:

```lua
KeySync.UnregisterCallback("MyAddon", "KeystoneUpdate")
```

### Publish the local key

Normally the library publishes automatically on relevant events.

```lua
KeySync.Broadcast(true)
```

`true` bypasses the normal voluntary broadcast throttle.

## Coexistence

Multiple addons may embed the library. The global major/minor guard makes all
copies share one runtime instance.

When TomoMod is installed, its native `TomoMod_KeySync` remains authoritative
for outgoing packets. The library continues listening and exposing its API,
but does not produce a second local response.

## Compatibility

The library deliberately uses `pcall` when registering Mythic+ events. This
allows addons that also support clients without Mythic+ to embed the same file.

## License

MIT. See `LICENSE`.
