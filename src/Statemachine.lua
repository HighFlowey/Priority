--!nocheck
--[=[
	@class Priority

	Priority based state machine.
]=]
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

--[=[
	This method initializes the state machine,
	It get's called automatically if created with the [Constructor].
	
	@private
	@within Priority
	@return void
]=]
function class:__init__()
	--[=[
		@prop PropertyModifier {(n: string, p: number)->(number)}
		@within Priority

		A list of functions that take a name and a number and modify it,
		It's used on properties that use numbers as their value.
	]=]
	self.PropertyModifiers = {} -- functions that apply changes to a property

	--[=[
		@prop ActiveState StateInfo
		@within Priority
		
		Reference to the current active state.
	]=]
	self.ActiveState = nil -- active state

	--[=[
		@private
		@prop StatesMap {StateInfoMap}
		@within Priority

		A list of state infos that the module uses to figure out which one to activate.
	]=]
	self.StatesMap = {} -- table/list of states

	--[=[
		@prop States {StateInfo}
		@within Priority

		A list of states.
	]=]
	self.States = {} -- dictionary of states
end

--[=[
	This method can enable or disable a state.
	
	@param stateName string -- name of the state
	@param stateEnabled boolean -- true means enabled, false means disabled
	@within Priority
	@return void
]=]
function class:setEnabled(stateName: string, stateEnabled: boolean)
	self.States[stateName].Enabled = stateEnabled
	self:update()
end

--[=[
	This method applies properties from [Priority.ActiveState] to [Humanoid].
	
	@private
	@within Priority
	@return void
]=]
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

--[=[
	This method loops through the states that are enabled and will
	activate the one with the highest priority.
	
	@private
	@within Priority
	@return void
]=]
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

--[=[
	Use this method to add states to a statemachine/[Priority] class.
	
	@within Priority
	@param name string -- name of the state
	@param info StateInfo -- the state info
	@param dont_update boolean? -- if set to true, module won't use [Priority:update]
	@return void
]=]
function class:newState(name: string, info: StateInfo, dont_update: boolean?)
	local mapInfo: StateMapInfo = { name = name, info = info }
	table.insert(self.StatesMap, mapInfo)

	self.States[name] = info

	if not dont_update then
		self:update()
	end
end

--[=[
	Use this method to add multiple states to a statemachine/[Priority] class.
	
	@within Priority
	@param states {[string]: StateInfo}
	@return void
]=]
function class:batch_addState(states: { [string]: StateInfo })
	for name, info in states do
		self:newState(name, info, true)
	end

	self:update()
end

return {
	__index = class,
}
