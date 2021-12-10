-- Register the behaviour
behaviour("AutoSquad1")
function AutoSquad1:Start()
	
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	self.squadUiText = GameObject.Find("Squad Text").GetComponent(Text)
	self.autoFill = false
	if self.script.mutator.GetConfigurationBool("autoFill") then
		self.autoFill = true
	end
	self.updateText = false
	print(tostring(self.script.mutator.GetConfigurationRange("botCount")))
	print("dropdownmenu " .. self.script.mutator.GetConfigurationDropdown("dropdownVersion"))
end
function AutoSquad1:InfoSquadUI()
self.updateText = true
self.squadUiText.color = Color(0.98,0.729,0.01)
coroutine.yield(WaitForSeconds(4))
self.updateText = false
self.squadUiText.color = Color.white
self.squadUiText.text = previousText
end
function AutoSquad1:contains(table, element)
	for _, value in pairs(table) do
	  if value == element then
		return true
	  end
	end
	return false
  end
  function AutoSquad1:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function AutoSquad1:onActorSpawn(actor)
if self.script.mutator.GetConfigurationDropdown("dropdownVersion") == 0 then
if not actor.isPlayer and actor.team == Player.actor.team and self:contains(Player.actor.squad.members,actor) == false then
		Player.actor.squad.AddMember(actor)
		else if actor.isPlayer then
		
			for i,y in ipairs(ActorManager.GetAliveActorsOnTeam(Player.team)) do
			
				Player.actor.squad.AddMember(y)
			end
		
		end
end
else
if actor.isPlayer then
	local squadMax = self.script.mutator.GetConfigurationRange("botCount")
	local actorsInRange = ActorManager.AliveActorsInRange(Player.actor.position,500)
	-- Could've use ActorDistanceToPlayer to check distance, but I'm blind
	table.sort(actorsInRange,function(a,b) return a.position.sqrMagnitude > b.position.sqrMagnitude end)
	for i,y in ipairs(actorsInRange) do
	if squadMax > self:tablelength(Player.actor.squad.members) and y.isBot and y.team == Player.actor.team then
	Player.actor.squad.AddMember(y)
	--print("Added Squad Member " .. y.name .. " with magnitude : " .. tostring(Player.actor.position - y.position))
	end
	-- if Player.actor.squad.members > squadMax then
	-- 	local removeC = Player.actor.squad.members
	-- end
	end
	if #Player.actor.squad.members == 0 then
		self.script.StartCoroutine("InfoSquadUI")
	end
end
end

end

-- Add Coroutine
function AutoSquad1:Update()
	if self.autoFill then
		 if self.script.mutator.GetConfigurationDropdown("dropdownVersion") == 1 then
			local squadMax = self.script.mutator.GetConfigurationRange("botCount")
			if Player.actor.squad ~= nil then
			if squadMax > (#Player.actor.squad.members - 1) then
			local actorsInRange = ActorManager.AliveActorsInRange(Player.actor.position,500)
			table.sort(actorsInRange,function(a,b) return a.position.sqrMagnitude > b.position.sqrMagnitude end)
			for i,y in ipairs(actorsInRange) do
				if squadMax > (#Player.actor.squad.members - 1) and y.isBot and y.team == Player.actor.team and self:contains(Player.actor.squad.members,y) == false then
				print("Added " .. y.name)
				Player.actor.squad.AddMember(y)
				--print("Added Squad Member " .. y.name .. " with magnitude : " .. tostring(Player.actor.position - y.position))
				end
			end
		end
		end
		end
	end
	--print(self.script.mutator.GetConfigurationDropdown("selectedVersions"))
	if self.updateText then
		local previousText = self.squadUiText.text
		self.squadUiText.text = "SQUAD ON NEXT RESPAWN"
	
	end

end
