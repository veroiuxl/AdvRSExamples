-- Register the behaviour
behaviour("BombCarrier")

function BombCarrier:Start()
self.bomb = self.targets.bomb
self.currentBombers = {}
self.telephoneSound = self.targets.bigRocketExplosion
self.telephone005 = self.targets.telephone005
self.startFrequency = self.script.mutator.GetConfigurationRange("frequency")
self.currentFrequency = self.startFrequency
self.activateRadius = 12
self.jumpMultiplier = 1
self.speedMultiplierSet = false
self.defaultSpeedMultiplier = 1
GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
GameEvents.onActorDied.AddListener(self,"onActorDied")
self.audioPlayer = self.targets.audioPrefab
self.difficutly = self.script.mutator.GetConfigurationDropdown("difficulty")
if(self.difficutly == 0) then
	self.jumpMultiplier = 1
	self.activateRadius = 17
	self.reactionTimeAdd = 0.7
else if self.difficutly == 1 then
	self.activateRadius = 13
	self.jumpMultiplier = 2
	self.reactionTimeAdd = 0.3
else if self.difficutly == 2 then
	self.activateRadius = 11
	self.jumpMultiplier = 3
	self.reactionTimeAdd = 0.1
else if self.difficutly == 3 then
	self.activateRadius = 15
	self.jumpMultiplier = 4
	self.reactionTimeAdd = -0.6
end
	
end
end
end
self.hasStarted = false
end
function BombCarrier:onActorSpawn(actor)
	if(not actor.isBot and not self.hasStarted) then
	self.hasStarted = true
	self.script.StartCoroutine(self:GetRandomBombCarrier(5)) -- Change this
	end
end
function BombCarrier:GetHumanoidTransform(actor,humanBodyBone)
	local retV
	if(actor.isFallenOver) then
		retV = actor.GetHumanoidTransformRagdoll(humanBodyBone)
		else
		retV = actor.GetHumanoidTransformAnimated(humanBodyBone)
	end
	return retV
	end
function BombCarrier:onActorDied(actor,killer,isSilent)
if(Player.actor ~= nil) then
	if(killer == Player.actor and actor.isBot and actor.team == Player.enemyTeam) then
		self.currentFrequency = self.currentFrequency - 0.15
		print("Frequency was decreased to " .. tostring(self.currentFrequency))
	end
	if(actor == Player.actor) then
		if(self.startFrequency > self.currentFrequency) then
		self.currentFrequency = self.currentFrequency + 0.3
		print("Frequency was increased to " .. tostring(self.currentFrequency))
		end
	end
	
end
if(self:contains1(self.currentBombers,actor)) then
	table.remove(self.currentBombers,self:tablefind1(self.currentBombers,actor))
	print("Removed " .. tostring(actor.name))
end


end

function BombCarrier:contains1(table, element)
	for _, value in pairs(table) do
	  if value[1] == element then
		return true
	  end
	end
	return false
end

local ERandom = {
	RangeInt = function(min, max)
		return Mathf.RoundToInt(Random.Range(min, max))
	end
}
function BombCarrier:GetRandomBombCarrier(frequency)
return function()
	coroutine.yield(WaitForSeconds(frequency))
	print("Selecting bot")
	local randomBot = ActorManager.AliveActorsInRange(Player.actor.position,70)
	local allowedActors = {}
	for i,y in ipairs(randomBot) do
		if(y.isBot and y.team == Player.enemyTeam and not self:contains1(self.currentBombers,y)) then
		table.insert(allowedActors, y)
		end
	end
	if(self:tablelength(allowedActors) == 0) then
		coroutine.yield(WaitForSeconds(1))
		self.script.StartCoroutine(self:GetRandomBombCarrier(self.currentFrequency))
		return
	end
	local randomActor = allowedActors[ERandom.RangeInt(1,self:tablelength(allowedActors) + 1)] 
	if(not self.speedMultiplierSet) then
		self.defaultSpeedMultiplier = randomActor.speedMultiplier
		self.speedMultiplierSet = true
	end
	print("Added " ..  tostring(randomActor.name) .. " as a bomber")
	table.insert(self.currentBombers, {randomActor,false})
	print("Current frequency " .. tostring(self.currentFrequency))
	randomActor.maxHealth = 130
	randomActor.health = 130
	for z,a in ipairs(randomActor.weaponSlots) do
		a.LockWeapon()
		print("Removed weapon " .. tostring(a.weaponEntry.name))
	end

	randomActor.aiController.ignoreFovCheck = true
	randomActor.aiController.canSprint = true

	randomActor.aiController.OverrideDefaultMovement()
	self.script.StartCoroutine(self:GetRandomBombCarrier(self.currentFrequency))
end
end
function BombCarrier:tablefind1(tab,el) -- Because Lua sucks
    for index, value in pairs(tab) do
        if value[1] == el then
            return index
        end
    end
end
function BombCarrier:CalculateTrajectory( TargetDistance, velocity)
	local n = (-Physics.gravity.y * TargetDistance)
	local b = velocity * velocity
    local CalculatedAngle = 0.5 * ((Mathf.Asin (n / b)) * Mathf.Rad2Deg);
        if(CalculatedAngle ~= CalculatedAngle) then
            return 0
		end
        return CalculatedAngle
end

function BombCarrier:GetKnockOverForceOfActorTrajectory(dir)
	local force = Vector3.Scale((dir.normalized * dir.magnitude * 20 * self.jumpMultiplier),Vector3(1,1.2,1))
	local calcTraj = self:CalculateTrajectory(dir.magnitude,force.magnitude)
	local newF
	if calcTraj ~= 0 then
		local trajectoryHeight = Mathf.Tan(calcTraj * Mathf.Deg2Rad) * dir.magnitude
		print(trajectoryHeight)
		newF = Vector3(force.x,force.y + trajectoryHeight,force.z)
	end
	-- if(self.currentActor.isSeated) then
	-- 	self.currentActor.ExitVehicle()
	-- end
	return newF
end
function BombCarrier:Explode(randomActor)
	return function()
		local audioPlayer = GameObject.Instantiate(self.audioPlayer)
		audioPlayer.GetComponent(AudioSource).clip = self.telephone005
		audioPlayer.GetComponent(AudioSource).Play()
		self.script.StartCoroutine(self:DestroyWithDelayBasic(audioPlayer,6))
		print("Waiting " .. tostring(self.telephone005.length + self.reactionTimeAdd - 0.2))
		coroutine.yield(WaitForSeconds(self.telephone005.length + (self.reactionTimeAdd - 0.2)))
		if(not self:contains1(self.currentBombers,randomActor)) then
			print("Player killed bomber before explosion")
			return
		end
		local dir =  self:GetHumanoidTransform(Player.actor,HumanBodyBones.Chest).position - randomActor.position
		randomActor.KnockOver(self:GetKnockOverForceOfActorTrajectory(dir))
		-- randomActor.KnockOver(Vector3.Scale(dir.normalized * self.jumpMultiplier * Vector3.Distance(Player.actor.position,randomActor.position),Vector3(1,7,1)))
		coroutine.yield(WaitForSeconds(0.2))
		if(not self:contains1(self.currentBombers,randomActor)) then
			print("Player killed bomber before explosion")
			return
		end
		randomActor.speedMultiplier = self.defaultSpeedMultiplier
		randomActor.aiController.alwaysChargeTarget = false
		randomActor.aiController.ReleaseDefaultMovementOverride()
		local bomb = GameObject.Instantiate(self.bomb)
		bomb.GetComponent(Projectile).source = randomActor
		bomb.transform.gameObject.transform.position = randomActor.position
		table.remove(self.currentBombers,self:tablefind1(self.currentBombers,randomActor))
		print("Removed actor from currentBombers list : " .. tostring(randomActor.name))
	end
end
function BombCarrier:DestroyWithDelayBasic(gameObject,delay)

	return function()
		coroutine.yield(WaitForSeconds(delay))
		if gameObject == nil then
			return
		end
		local destroyGO = gameObject.gameObject
		if destroyGO == nil then
			return
		end
		GameObject.Destroy(destroyGO)
	end

end
function BombCarrier:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function BombCarrier:SpawnVehicle(position)
	return function()
	local bot = ActorManager.CreateAIActor(Team.Red)
	bot.SpawnAt(position,Quaternion.identity)
	-- local plane = GameObject.Instantiate(VehicleSpawner.GetPrefab(Team.Red,VehicleSpawnType.AttackPlane))
	-- plane.transform.position = position + Vector3(0,2.5,0)
	-- print("Enter vehicle")
	-- bot.EnterSeat(plane.GetComponent(Vehicle).GetEmptySeat(true))
	end
end

function BombCarrier:Update()
Player.actor.health = 999
Player.actor.maxHealth = 999
Player.actor.balance = 9999
Player.actor.maxBalance = 9999


--if(Input.GetKeyDown(KeyCode.K)) then
--	local ray = Ray(PlayerCamera.activeCamera.main.transform.position,PlayerCamera.activeCamera.main.transform.forward)
--	local raycast = Physics.Raycast(ray,400,RaycastTarget.ProjectileHit)
--	if(raycast ~= nil) then
--		self.script.StartCoroutine(self:SpawnVehicle(raycast.point))
--	end
--end
for i,y in ipairs(self.currentBombers) do
	local bot = y[1]
	local isExploding = y[2]
	if(bot ~= nil and not Player.actor.isDead) then
		if(not bot.isDead) then
			bot.balance = 400
			bot.maxBalance = 400
			bot.aiController.canSprint = true
			bot.aiController.alwaysChargeTarget = true
			if(Vector3.Distance(Player.actor.position,bot.position) < self.activateRadius and not isExploding) then
				y[2] = true
				self.script.StartCoroutine(self:Explode(bot))
			else if(Vector3.Distance(Player.actor.position,bot.position) > self.activateRadius) and not isExploding  then
				bot.aiController.GotoDirect(Player.actor.position)
				local normalizedSpeed = (Vector3.Distance(Player.actor.position,bot.position) - 10) / (80 - 10)
				-- print("normS " .. tostring(normalizedSpeed))
				bot.speedMultiplier = Mathf.Clamp((1 + normalizedSpeed) * self.defaultSpeedMultiplier + 2,1,8)
				-- print("Speed multiplier for " .. bot.name .. " is " .. tostring(bot.speedMultiplier))
				-- print("normalizedSpeed = " .. tostring(normalizedSpeed) .. " speed would be " .. tostring(normalizedSpeed * bot.speedMultiplier * 2))

			end
			end
		end
	end
end
end
