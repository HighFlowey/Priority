return function()
	local Priority5 = require(script.Parent)
	local Starter = require(script.Parent.Starter)

	local function getDefaultState()
		local defaultPriority: string?
		do
			for i, v in Starter do
				if v.Enabled then
					defaultPriority = i
					break
				end
			end
		end
		return defaultPriority
	end

	describe("Main module", function()
		it("Should have a new function", function()
			expect(Priority5.new).to.be.a("function")
		end)

		it("Should have a createWeight function", function()
			expect(Priority5.createWeight).to.be.a("function")
		end)
	end)

	describe("Starter module", function()
		it("Should have a default state", function()
			expect(getDefaultState()).to.be.ok()
		end)
	end)

	describe("new function", function()
		local humanoid = Instance.new("Humanoid")

		it("Should return a priority class", function()
			local class = Priority5.new(humanoid)
			expect(class).to.be.ok()
		end)
	end)

	describe("Weight", function()
		local humanoid = Instance.new("Humanoid")
		local class = Priority5.new(humanoid)
		local properties = {
			["WalkSpeed"] = 0.5,
		}

		local weight, weightId = Priority5.createWeight(class, properties)

		afterAll(function()
			weight()
		end)

		it("Should return a destroy function", function()
			expect(weight).to.be.a("function")
		end)

		it("Should return an id", function()
			expect(weightId).to.be.a("string")
		end)

		it("Should be added to priority class as a PropertyModifier", function()
			expect(class.PropertyModifiers[weightId]).to.be.a("function")
		end)

		it("Should change properties", function()
			for i, v in properties do
				local stateValue = class.ActiveState.Properties[i]
				if stateValue then
					local expectedValue = stateValue * v
					expect(humanoid[i]).to.be.equal(expectedValue)
				end
			end
		end)

		it("The property modifier function should change property", function()
			local modified = class.PropertyModifiers[weightId]("WalkSpeed", 5)
			expect(modified).to.be.equal(5 * properties["WalkSpeed"])
		end)
	end)

	describe("Weight (blending multiple weights)", function()
		local humanoid = Instance.new("Humanoid")
		local class = Priority5.new(humanoid)

		local properties = {
			["WalkSpeed"] = 0.5,
		}
		local properties2 = {
			["WalkSpeed"] = 0.25,
		}

		local weight, _weightId = Priority5.createWeight(class, properties)
		local weight2, _weightId2 = Priority5.createWeight(class, properties2)

		it("Should blend in multiple weights to apply properties", function()
			for i, v in properties do
				local stateValue = class.ActiveState.Properties[i]
				if stateValue then
					local expectedValue = (stateValue * v) * properties2[i]
					expect(humanoid[i]).to.be.equal(expectedValue)
				end
			end
		end)

		it("Should return properties back to normal after getting destroyed", function()
			weight2()
			weight()

			for i, _ in properties do
				local stateValue = class.ActiveState.Properties[i]
				if stateValue then
					expect(humanoid[i]).to.be.equal(stateValue)
				end
			end
		end)
	end)

	describe("Priority class", function()
		local humanoid = Instance.new("Humanoid")
		local class = Priority5.new(humanoid)

		it("Should have a table containing the default states", function()
			for i, _ in Starter do
				expect(class.States[i]).to.be.ok()
			end
		end)

		local defaultPriority = getDefaultState()

		it("Should have the default state set to active", function()
			expect(class.ActiveState).to.be.equal(Starter[defaultPriority])
		end)

		it("Should change properties based on the currently active state", function()
			for i, v in class.ActiveState.Properties do
				expect(humanoid[i]).to.be.equal(v)
			end
		end)

		it("Active state should be changed to new enabled state that has high priority", function()
			class:setEnabled("Run", true)
			expect(class.ActiveState).to.be.equal(Starter["Run"])
			class:setEnabled("Run", false)
			expect(class.ActiveState).to.never.equal(Starter["Run"])
		end)

		it("When active state changes, signal should be fired", function()
			local received = false
			local signal = class.ActiveStateChanged:Connect(function(name)
				if name == "Run" then
					received = true
				end
			end)

			class:setEnabled("Run", true)
			expect(received).to.be.equal(true)
			class:setEnabled("Run", false)

			signal:Disconnect()
		end)
	end)
end
