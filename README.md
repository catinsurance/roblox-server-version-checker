# roblox-server-version-checker
Checks to see if the current Roblox server is up to date with the newest update of your game.

## Installation

Download the file to your computer (or alternatively get it from the Roblox catalog [here]()) and import to Roblox. A link to get it from the Roblox catalog will be available soon.
After you have installed it and imported it to Roblox Studio, place it somewhere that a local script can access. For this example, I'll be using *ReplicatedStorage.*

```lua
local VersionChecker = require(game:GetService("ReplicatedStorage").path.to.module)

VersionChecker.Activate()
```

## Usage

Below is an example of using the module.

```lua
local m = require(path.to.module)

m:SetCheckFrequency(3)

m.PlaceUpdated:Connect(function(date)
  print("This place is now outdated!!!")
end)

m.Activate()
```

## Documentation

### Function VersionChecker.GameUpdated(DateTime Updated)

Returns an event that fires whenever the server detects that the game was updated after the server started. 
Example usage:

```lua
local m = require(path.to.module)

m.Activate()

m.GameUpdated:Connect(function(Updated)
  print("The game was last updated at: " .. Updated)
end)
```

### Function VersionChecker.PlaceUpdated(DateTime Updated)

Returns an event that fires whenever the server detects that the place was updated after the server started. 
Example usage:

```lua
local m = require(path.to.module)

m.Activate()

m.PlaceUpdated:Connect(function(Updated)
  print("The place was last updated at: " .. Updated)
end)
```

### Void VersionChecker.Activate()

Activates the module.

### Void VersionChecker.Deactive()

Deactives the module. This means functions like VersionChecker:GetPlaceLastUpdated() will return values from when the module was activated.

### Boolean VersionChecker:IsPlaceUpToDate()

Returns a boolean stating if the place was updated after the server was started.

### Boolean VersionChecker:IsGameUpToDate()

Returns a boolean stating if the game was updated after the server was started.

### DateTime VersionChecker:GetPlaceLastUpdated()

Returns a DateTime object stating when the current place was last updated.

### DateTime VersionChecker:GetGameLastUpdated()

Returns a DateTime object stating when the current game was last updated.

### Void VersionChecker:SetCheckFrequency(Number Frequency)

Sets how often in seconds the module will check to see when the current game and place was last updated.
Example usage:

```lua
local m = require(path.to.module)

m:SetCheckFrequency(1) -- That's one second.
m.Activate()
```
