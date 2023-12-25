--!strict

--[=[
	@interface StateInfo
	@within Constructor
	.Enabled boolean
	.Active boolean
	.Priority number
	.Properties {[string]: any} -- properties of a [Humanoid]
]=]

--[=[
	@private
	@interface StateInfoMap
	@within Constructor
	.name string
	.info StateInfo
]=]

return {
	["Walk"] = {
		Enabled = true,
		Active = false,
		Priority = 0,
		Properties = {
			["WalkSpeed"] = 16,
			["JumpPower"] = 50,
		},
	},
	["Run"] = {
		Enabled = false,
		Active = false,
		Priority = 1,
		Properties = {
			["WalkSpeed"] = 24,
			["JumpPower"] = 50,
		},
	},
	["Stun"] = {
		Enabled = false,
		Active = false,
		Priority = 12,
		Properties = {
			["WalkSpeed"] = 0,
			["JumpPower"] = 0,
		},
	},
}
