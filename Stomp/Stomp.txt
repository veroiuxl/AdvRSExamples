-- Register the behaviour
behaviour("Stomp")
function Stomp:Start()
self.SmokeParticles = self.targets.SmokeParticles.GetComponent(ParticleSystem)
self.affectedBots = {}
self.smokeTransforms = {}
self.isStomping = false
self.wasPerformingStomp = false
self.smokesReady = false
self.savedHealth = nil
self.savedmaxHealth = nil
self.savedBalance = nil
self.savedMaxBalance = nil
self.tracking = false
self.healthUIText = GameObject.Find("Health Text").GetComponent(Text).text
self.smokeTrails = self.script.mutator.GetConfigurationBool("smokeTrails")
self.invincibilityWhenStomping = self.script.mutator.GetConfigurationBool("invincibilityWhenStomping")
self.targetRange = self.script.mutator.GetConfigurationRange("nearestBotRange")

self.stompRange = self.script.mutator.GetConfigurationRange("range")
self.stompKnockback = self.script.mutator.GetConfigurationRange("force")
if self.script.mutator.GetConfigurationBool("targetNearestActor") then
	self.tracking = true
end
if self.script.mutator.GetConfigurationBool("crazyMode") then
	self.stompKnockback = 90
	self.smokeTrails = false
	self.invincibilityWhenStomping = true
	self.stompRange = 50
	self.targetRange = 999
end
end
function Stomp:HandleParticles()

	self.smokesReady = false
	for k in pairs (self.smokeTransforms) do
		self.smokeTransforms[k] = nil
	end
	

end
-- Reset UI
-- This is not a good way
function Stomp:ResetHealth()
	coroutine.yield(WaitForSeconds(0.04))
	
	if Player.actor.maxHealth > 8000 then
		if self.savedHealth == nil then
			print("Saved maxHealth was nil")
			return
		end
		if self.savedmaxHealth < 8000 then 
			print("Set maxHealth to savedmaxHealth -> " .. tostring(self.savedmaxHealth))
			Player.actor.maxHealth  = self.savedmaxHealth
		else
			Player.actor.maxHealth = 100
		
			print("Reset maxHealth to 100")
		end
	end
	if Player.actor.health > 8000 then
		if self.savedHealth == nil then
			print("Saved health was nil")
			return
		end
		if self.savedHealth < 8000 then -- Other mutators also increase the health pool so fuck
			print("Set health to savedHealth -> " .. tostring(self.savedHealth))
			Player.actor.health = self.savedHealth
			self.healthUIText = tostring(Player.actor.health)
		else
			Player.actor.health = 100
			self.healthUIText = tostring(100)
			print("Reset health to 100")
		end
	else if Player.actor.health < 0 and Player.actor.isDead == false then
		print("<color=red>Player health is under 0</color>")
		self.healthUIText = tostring(0)
		Player.actor.Damage(Player.actor.maxHealth)
	end
	end


end
function Stomp:Grenade(raycast)
	return function()
		self.isStomping = true
		
		self.SmokeParticles.Stop()
		self.SmokeParticles.transform.position = Player.actor.position
		self.SmokeParticles.Play()
		
		for i,y in ipairs(ActorManager.AliveActorsInRange(raycast,self.stompRange)) do
			if (y.isBot) then
				table.insert(self.affectedBots, y)
				if self.smokeTrails then
				local singleSmoke = GameObject.Instantiate(self.targets.SingleActorSmoke)
				table.insert(self.smokeTransforms, {y,singleSmoke}) 
				singleSmoke.GetComponent(ParticleSystem).Play()
				end
			--	print("Added " .. y.name)
				--	y.KnockOver(Vector3(0,1000,0))
				
			end
		end
		
		for i,y in ipairs(self.affectedBots) do
			local vec = y.position - Player.actor.position
			--print(tostring(vec))
			y.KnockOver(Vector3.Scale((vec.normalized * (self.stompKnockback * 160)),Vector3(1,11,1)))
			-- Vector3 normalized takes out the scale/magnitude/direction
			PlayerCamera.ApplyRecoil(Vector3(0,0.7,0),false)
			PlayerCamera.ApplyScreenshake(2.5,1)
		end
		self.smokesReady = true
		for k,y in ipairs(self.affectedBots) do
			y.Damage(Player.actor, y.maxHealth, 100, false, false)
		end
		coroutine.yield(WaitForSeconds(3))
		for i,y in ipairs(self.affectedBots) do
			if (y.isBot) then
				--	print("Removed " .. y.name)
				
			end
		end
		for k in pairs (self.affectedBots) do
			self.affectedBots[k] = nil
		end
		self.wasPerformingStomp = false
		self.isStomping = false
	
		if self.smokeTrails then
		self.smokesReady = false
		for k in pairs (self.smokeTransforms) do
		self.smokeTransforms[k] = nil
		end
		end
		
		-- Player.actor.balance = self.savedBalance 
		-- Player.actor.maxBalance = self.savedMaxBalance 
		--print("Set health " .. Player.actor.health .. " maxhealth " .. Player.actor.maxHealth)
	end
	
	
end
function Stomp:getIndex(tab, val)
    local index = nil
    for i, v in ipairs (tab) do 
        if (v.id == val) then
          index = i 
        end
    end
    return index
end
function Stomp:GetClosestActor(ActorsInRange,currenPos) 
	local bestTarget = null;
	local closestDistanceSqr = Mathf.Infinity;
	
	for i,potentialTarget in ipairs(ActorsInRange) do
		local directionToTarget = potentialTarget.transform.position - currenPos
		local dSqrToTarget = directionToTarget.sqrMagnitude
		if dSqrToTarget < closestDistanceSqr then
			closestDistanceSqr = dSqrToTarget;
			bestTarget = potentialTarget;
		end
	end
	return bestTarget
end

function Stomp:Update()
	if self.smokeTrails then
	if self.smokesReady then
		if #self.smokeTransforms == 0 then
			self.smokesReady = false
		--	print("Stomp not used")
			return
		end
		for i,y in ipairs(self.smokeTransforms) do
			
			if y[2] ~= nil then
			if y[1].isDead then
			y[2].transform.position = y[1].GetHumanoidTransformRagdoll(HumanBodyBones.Chest).position
			end
			end
		end
	end
	end
	
	if self.isStomping and Player.actorIsGrounded then
		self.script.StartCoroutine("ResetHealth")
	end
	if Input.GetKeyBindButton(KeyBinds.Crouch) then
		if not Player.actorIsGrounded and not Player.actor.isParachuteDeployed and self.wasPerformingStomp == false then
				self.savedBalance = Player.actor.balance
				self.savedMaxBalance = Player.actor.maxBalance
				self.savedHealth = Player.actor.health
				self.savedmaxHealth = Player.actor.maxHealth

				print("Saved health " .. tostring(self.savedHealth))
			Player.actor.balance = 9999
			Player.actor.maxBalance = 9999
		end
	end
	if Input.GetKeyBindButton(KeyBinds.Crouch) then
		if not Player.actorIsGrounded and not Player.actor.isParachuteDeployed then
			-- Just for aesthetics, but actually allows the player to fly up 
			Player.MoveActor((Vector3.Scale(Player.actor.position,Vector3(0,5,0))).normalized * 4 * Time.deltaTime) 
			local ray = Ray(PlayerCamera.activeCamera.main.transform.position, Vector3.down)
			local raycast = Physics.Raycast(ray,1000,RaycastTarget.ProjectileHit)
			if raycast ~= nil and self.isStomping == false then
				
				-- Maybe implement max jump height check
				-- Implement stomp to nearest target
				local aliveActorInRange = ActorManager.AliveActorsInRange(Player.actor.position,self.targetRange)
				local removedPlayerWhyIsThatNotDefault = {}
				for i,y in ipairs(aliveActorInRange) do
					if y.isBot and y.team == Player.enemyTeam then
						if not y.isInWater then
							if ActorManager.ActorCanSeePlayer(y) then -- !!
						table.insert(removedPlayerWhyIsThatNotDefault, y)
							end
						end
					end
				end

				if self.tracking then
				Player.actor.health = 9999
				Player.actor.maxHealth = 9999
				Player.actor.balance = 9999
				local closestTarget = self:GetClosestActor(removedPlayerWhyIsThatNotDefault,Player.actor.position)
			
				if closestTarget ~= nil then
				--	local pos = (raycast.point - Player.actor.position).normalized
					Player.MoveActor((closestTarget.position - raycast.point).normalized * 13 * Time.deltaTime)
					--Player.MoveActor((pos - closestTarget.position.normalized) * Time.deltaTime)
				else
					Player.MoveActor((raycast.point - Player.actor.position).normalized * 11 * Time.deltaTime)
				end
			else
					Player.MoveActor((raycast.point - Player.actor.position).normalized * 11 * Time.deltaTime)
				end
				self.wasPerformingStomp = true
			end
		else if Player.actorIsGrounded and self.wasPerformingStomp then
			if self.isStomping == false then
			
			self.script.StartCoroutine(self:Grenade(Player.actor.position))
			end
		end
		end
	end	
	
end
