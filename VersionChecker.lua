-- Quenty Signal Class	
local Signal do
	Signal = {}
	Signal.__index = Signal
	Signal.ClassName = "Signal"

	--- Constructs a new signal.
	-- @constructor Signal.new()
	-- @treturn Signal
	function Signal.new()
		local self = setmetatable({}, Signal)

		self._bindableEvent = Instance.new("BindableEvent")
		self._argData = nil
		self._argCount = nil -- Prevent edge case of :Fire("A", nil) --> "A" instead of "A", nil

		return self
	end

	--- Fire the event with the given arguments. All handlers will be invoked. Handlers follow
	-- Roblox signal conventions.
	-- @param ... Variable arguments to pass to handler
	-- @treturn nil
	function Signal:Fire(...)
		self._argData = {...}
		self._argCount = select("#", ...)
		self._bindableEvent:Fire()
		self._argData = nil
		self._argCount = nil
	end

	--- Connect a new handler to the event. Returns a connection object that can be disconnected.
	-- @tparam function handler Function handler called with arguments passed when `:Fire(...)` is called
	-- @treturn Connection Connection object that can be disconnected
	function Signal:Connect(handler)
		if not (type(handler) == "function") then
			error(("connect(%s)"):format(typeof(handler)), 2)
		end

		return self._bindableEvent.Event:Connect(function()
			handler(unpack(self._argData, 1, self._argCount))
		end)
	end

	--- Wait for fire to be called, and return the arguments it was given.
	-- @treturn ... Variable arguments from connection
	function Signal:Wait()
		self._bindableEvent.Event:Wait()
		assert(self._argData, "Missing arg data, likely due to :TweenSize/Position corrupting threadrefs.")
		return unpack(self._argData, 1, self._argCount)
	end
end

--- Disconnects all connected events to the signal. Voids the signal as unusable.
-- @treturn nil
function Signal:Destroy()
	if self._bindableEvent then
		self._bindableEvent:Destroy()
		self._bindableEvent = nil
	end

	self._argData = nil
	self._argCount = nil
end

-- Real code starts below
local v = {}

local rs = game:GetService("RunService")
local mps = game:GetService("MarketplaceService")

local Activated = false

local Place = game.PlaceId
local Universe = game.GameId

local PlaceLastUpdated, GameLastUpdated

local UpToDatePlace = true
local UpToDateGame = true

local CheckFrequency = 5

v.GameUpdated = Signal.new()
v.PlaceUpdated = Signal.new()

function GetGameProductInfo()
	local success, info = pcall(function()
		return mps:GetProductInfo(Universe)
	end)

	if success then
		return info
	else
		wait(2)
		return GetGameProductInfo()
	end
end

function GetPlaceProductInfo()
	local success, info = pcall(function()
		return mps:GetProductInfo(Place)
	end)

	if success then
		return info
	else
		wait(2)
		return GetPlaceProductInfo()
	end
end

-- Boolean
-- Check if current place is up-to-date. 
function v:IsPlaceUpToDate()
	assert(PlaceLastUpdated, "You have not activated the module yet.")
	assert(GameLastUpdated, "You have not activated the module yet.")
	return UpToDatePlace
end

-- Boolean
-- Check if current game is up-to-date. 
function v:IsGameUpToDate()
	assert(PlaceLastUpdated, "You have not activated the module yet.")
	assert(GameLastUpdated, "You have not activated the module yet.")
	return UpToDateGame
end

-- DateTime 
-- Get the last time the place was updated.
function v:GetPlaceLastUpdated()
	assert(PlaceLastUpdated, "You have not activated the module yet.")
	assert(GameLastUpdated, "You have not activated the module yet.")
	return DateTime.fromIsoDate(PlaceLastUpdated)
end

-- DateTime
-- Get the last time the game was updated. 
function v:GetGameLastUpdated()
	assert(PlaceLastUpdated, "You have not activated the module yet.")
	assert(GameLastUpdated, "You have not activated the module yet.")
	return DateTime.fromIsoDate(GameLastUpdated)
end

-- Void
-- Sets the frequency in which the game will be checked for obsolescence.
function v:SetCheckFrequency(frequency)
	assert(type(frequency) == "number", "Argument 1 (frequency) must be a positive number!")
	assert(frequency >= 0, "Argument 1 (frequency) must be a positive number!")
	CheckFrequency = frequency
end

-- Void
-- Activate the module.
function v.Activate()
	Activated = true
	GameLastUpdated = GetGameProductInfo().Updated
	PlaceLastUpdated = GetPlaceProductInfo().Updated
	
	coroutine.wrap(function()
		while wait(CheckFrequency) do
			if not Activated then
				return
			end
			local Updated = GetGameProductInfo().Updated
			if GameLastUpdated ~= Updated then
				UpToDateGame = false
				v.GameUpdated:Fire(DateTime.fromIsoDate(Updated))
				GameLastUpdated = GetGameProductInfo().Updated
			end
			Updated = GetPlaceProductInfo().Updated
			if PlaceLastUpdated ~= Updated then
				UpToDatePlace = false
				v.PlaceUpdated:Fire(DateTime.fromIsoDate(Updated))
				PlaceLastUpdated = GetPlaceProductInfo().Updated
			end
		end
	end)()
end

-- Void
-- Deactive the module.
function v.Deactive()
	Activated = false
end

return v
