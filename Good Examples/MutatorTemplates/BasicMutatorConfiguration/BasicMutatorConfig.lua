-- Register the behaviour
behaviour("BasicMutatorConfig")
--[[
If you have more questions ask me on Discord Chryses#6081 (Nickname is Chai)
--]]
function BasicMutatorConfig:Start()
	self.inputInt = self.script.mutator.GetConfigurationInt("inputInt")
	print("inputInt is " .. tostring(self.inputInt))

	self.inputFloat = self.script.mutator.GetConfigurationFloat("inputFloat")
	print("inputFloat is " .. tostring(self.inputFloat))

	self.inputrange = self.script.mutator.GetConfigurationRange("inputrange")
	print("inputrange is " .. tostring(self.inputrange))

	self.inputString = self.script.mutator.GetConfigurationString("inputString")
	print("inputString is " .. tostring(self.inputString))

	self.checkbox = self.script.mutator.GetConfigurationBool("checkbox")
	print("checkbox bool is " .. tostring(self.checkbox)) -- If you don't put tostring() here it will give you an error

	self.pickedTeam = self.script.mutator.GetConfigurationDropdown("dropdown")
	print("Picked index " .. tostring(self.pickedTeam))
	if(self.pickedTeam == 0) then -- Eagle
		print("Picked Eagle")
	elseif (self.pickedTeam == 1) then
		print("Picked Raven")
	elseif (self.pickedTeam == 2) then
		print("Picked Nothing")
	end 
	-- Sadly there are no switch statements in this version of lua
end

function BasicMutatorConfig:Update()
	-- Run every frame
	
end
