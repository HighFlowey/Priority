--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Priority5 = require(ReplicatedStorage.Priority5)

local character: Model = script.Parent.Parent
local humanoid: Instance | Humanoid = character:WaitForChild("Humanoid")
local priority = Priority5.new(humanoid)
