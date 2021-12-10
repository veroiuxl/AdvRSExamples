-- Register the behaviour
behaviour("BasicUIExample")
--[[
If you have more questions ask me on Discord Chryses#6081 (Nickname is Chai)
--]]
function BasicUIExample:Start()
	self.currentAmountOfBotsText = self.targets.aliveBotamountText.GetComponent(Text)
	self.currentPlayerPositonAndVelocity = self.targets.currentPosAndVText.GetComponent(Text)
end
function BasicUIExample:round2(num, numDecimalPlaces) -- from http://lua-users.org/wiki/SimpleRound
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
  end
function BasicUIExample:Update()
	self.currentAmountOfBotsText.text = "Current amount of bots: " .. tostring((#ActorManager.GetAliveActorsOnTeam(Team.Blue) + #ActorManager.GetAliveActorsOnTeam(Team.Red)) )
	-- This is the lazy version (most of the time it's fine to do it like this)
	if(Player.actor ~= nil) then
		if(not Player.actor.isDead) then
			self.currentPlayerPositonAndVelocity.text = "Pos: " .. tostring(Player.actor.position) .. " V: " .. tostring(self:round2(Player.actor.velocity.sqrMagnitude,3))
		else
			self.currentPlayerPositonAndVelocity.text = "Pos: nil Velocity: 0"
		end
	end
	-- You don't have to do tostring() for every int that you want to concatenate, I just do it to make sure
	
end
