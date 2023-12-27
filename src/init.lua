--!nocheck
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Starter = require(script.Starter)
local Statemachine = require(script.Statemachine)

--[=[
	@class currentVersion

	current version of the wally package
]=]
local CURRENT_VERSION = "0.5.3"

--[=[
	@function getAsyncRetry
	@private
	
	PCalls HttpService:GetAsync() and retries infinitly when it fails
]=]
local function getAsyncRetry(...)
	local success, value = pcall(HttpService.GetAsync, HttpService, ...)

	if success then
		return value
	elseif value:find("not enabled") then
		warn(
			"Priority module uses HttpService to check the version of the module and remind you when there are updates, you can ignore this warning as it doesn't break anything."
		)
		return nil
	else
		task.wait(3)
		return getAsyncRetry(...)
	end
end

--[=[
	@function readSourceFromGithub
	@private
	
	Returns the source of a file from a github repository
]=]
local function readSourceFromGithub(
	fileName: string,
	fileExtension: string,
	repoInfo: { username: string, repo: string, branch: string }
)
	local username = (repoInfo and repoInfo.username or "HighFlowey")
	local repoName = (repoInfo and repoInfo.repo or "Coach-CodingProblems")
	local branchName = (repoInfo and repoInfo.branch or "main")

	local source =
		getAsyncRetry(`https://github.com/{username}/{repoName}/blob/{branchName}/{fileName}.{fileExtension}`, true)

	if source then
		local info = HttpService:JSONDecode(source)
		local code = getAsyncRetry(info.payload.blob.rawBlobUrl, true)
		return code
	else
		return nil
	end
end

if RunService:IsServer() then
	task.spawn(function()
		local wally =
			readSourceFromGithub("wally", "toml", { username = "HighFlowey", repo = "Priority", branch = "master" })
		if wally == nil then
			return
		end

		local version = string.match(wally, 'version%s-=%s-"([%d%.]+)"')
		if CURRENT_VERSION ~= version then
			warn(
				`You are currently using an outdated version of the Priority module\ncurrent version: {CURRENT_VERSION} | latest version: {version}`
			)
		end
	end)
end

--[=[
	@class Constructor

	Returned by the main module.
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

	```lua
	-- Example
	local Priority = Priority5.new(humanoid)
	local disableWeight = Priority5.createWeight(Priority, {
		["WalkSpeed"] = 0.5, -- multiplies WalkSpeed by 0.5 (2x slower)
		["JumpPower"] = 2, -- doubles JumpPower
	})

	task.wait(2)

	disableWeight()
	```

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

	```lua
	-- Example
	local character = ...
	local humanoid = character:WaitForChild("Humanoid")
	local Priority = Priority5.new(humanoid)
	```

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
