--!strict
return {
	["Walk"] = {
		Enabled = true,
		Active = false,
		IgnoreWeight = false,
		Priority = 0,
		Properties = {
			["WalkSpeed"] = 16,
			["JumpPower"] = 50,
		},
	},
	["Run"] = {
		Enabled = false,
		Active = false,
		IgnoreWeight = false,
		Priority = 1,
		Properties = {
			["WalkSpeed"] = 24,
			["JumpPower"] = 50,
		},
	},
	["Stun"] = {
		Enabled = false,
		Active = false,
		IgnoreWeight = true,
		Priority = 12,
		Properties = {
			["WalkSpeed"] = 0,
			["JumpPower"] = 0,
		},
	},
}
