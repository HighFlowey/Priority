--!nocheck
local class = {}

export type StateInfo = {
	Enabled: boolean,
	Active: boolean,
	Priority: number,
	Properties: {
		[string]: any,
	},
}

export type StateMapInfo = {
	name: string,
	info: StateInfo,
}

function class:__init__()
	self.PropertyModifiers = {} -- functions that apply changes to a property
	self.ActiveState = nil -- active state
	self.StatesMap = {} -- table/list of states
	self.States = {} -- dictionary of states
end

function class:setEnabled(stateName: string, stateEnabled: boolean)
	self.States[stateName].Enabled = stateEnabled
	self:update()
end

function class:apply()
	local humanoid: Humanoid = self.Humanoid
	local state: StateInfo = self.ActiveState

	if state ~= nil then
		for i, v in state.Properties do
			if typeof(v) == "number" then
				-- Let property modifiers, modify the property value
				local mods = 0
				for _, mod: (n: string, p: number) -> number in self.PropertyModifiers do
					v = mod(i, v)
					mods += 1
				end
			end

			local success = pcall(function()
				humanoid[i] = v
			end)

			if not success then
				warn(`Humanoid doesn't have property called {i}`)
			end
		end
	end
end

function class:update()
	local enabledStatesMap = {} -- table/list of enabled states

	for _, infoMap: StateMapInfo in self.StatesMap do
		if infoMap.info.Enabled == true then
			table.insert(enabledStatesMap, infoMap)
		end
	end

	table.sort(enabledStatesMap, function(a: StateMapInfo, b: StateMapInfo)
		return a.info.Priority > b.info.Priority
	end)

	-- Activate state
	local highest: StateMapInfo = enabledStatesMap[1]
	highest.info.Active = true

	if self.ActiveState then
		-- Deactivate previously activated state
		self.ActiveState.Active = false
	end

	-- Set active state to new active state
	self.ActiveState = highest.info
	self:apply()
end

function class:newState(name: string, info: StateInfo, dont_update: boolean?)
	local mapInfo: StateMapInfo = { name = name, info = info }
	table.insert(self.StatesMap, mapInfo)

	self.States[name] = info

	if not dont_update then
		self:update()
	end
end

function class:batch_addState(states: { [string]: StateInfo })
	for name, info in states do
		self:newState(name, info, true)
	end

	self:update()
end

return {
	__index = class,
}
