--!nocheck
local HttpService = game:GetService("HttpService")
local Starter = require(script.Starter)
local Statemachine = require(script.Statemachine)

local module = {}
local memory = {}

export type Priority = typeof(setmetatable({}, Statemachine))

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

	return function()
		-- destroy function
		priority.PropertyModifiers[id] = nil
		priority:apply()
	end, id
end

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
