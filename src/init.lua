--!nocheck
local HttpService = game:GetService("HttpService")
local Starter = require(script.Starter)
local Statemachine = require(script.Statemachine)

--[=[
	@class Constructor
]=]
local module = {}

--[=[
	@class Memory
	@private

	[Priority] classes get stored here so [Constructor.new] doesn't create multiple classes for one [Humanoid].
]=]
local memory = {}

export type Priority = typeof(setmetatable({}, Statemachine))

--[=[
	@function createWeight
	@within  Constructor
	@param priority Priority
	@param properties {[string]: any} -- properties of a [Humanoid], only properties that are numbers are acceptable, the property will get multiplied by the number you put as the value.
	@return ()->() -- a destructor function that disables the weight
	@return string -- id of the weight

	Creates a weight that can be applied to a [Priority] class
]=]
function module.createWeight(priority: Priority, properties: { [string]: number })
	local id = HttpService:GenerateGUID()

	priority.PropertyModifiers[id] = function(n: string, p: number)
		for i, v in properties do
			-- apply modifier
			if n ~= i then
				continue
			end

			p *= v
			break
		end

		-- return modified
		return p
	end

	priority:apply()

	local function destroy()
		priority.PropertyModifiers[id] = nil
		priority:apply()
	end

	return destroy, id
end

--[=[
	@function new
	@within  Constructor
	@param humanoid Instance|Humanoid -- preferably a [Humanoid]
	@return Priority

	Creates a [Priority] class
]=]
function module.new(humanoid: Instance | Humanoid): Priority
	if memory[humanoid] then
		return memory[humanoid]
	end

	local class = setmetatable({
		Humanoid = humanoid,
	}, Statemachine)

	class:__init__()
	class:batch_addState(Starter)

	memory[humanoid] = class
	return class
end

return module
