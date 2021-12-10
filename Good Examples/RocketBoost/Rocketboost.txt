-- Register the behaviour
behaviour("Rocketboost")

function Rocketboost:Start()
	GameEvents.onExplosion.AddListener(self,"onExplosion")
	Player.actor.onTakeDamage.AddListener(self,"onDamage")
	self.sphereCol = self.targets.sphereCollider
	self.lastExplosionInfo = nil
	self.sphereColliderInstances = {}
	self.impact = Vector3.zero
	self.preset = self.script.mutator.GetConfigurationDropdown("rocketboostpreset")
	self.infiniteRocketLauncherAmmo = self.script.mutator.GetConfigurationBool("infiniteRocketLauncherAmmo")
	self.manuelControl = self.script.mutator.GetConfigurationBool("manuelControl")
	self.airResistance = 1.5
	self.impactMultiplier = 10
	if(self.preset == 0) then
		-- self:SetPreset(1.0,10)
		self:SetPreset(0.9,13)
	elseif(self.preset == 1) then
		self:SetPreset(0.6,12)
	elseif(self.preset == 2) then
		self:SetPreset(0.7,18)
	end
	--
	if(self.manuelControl) then
		self.airResistance = self.script.mutator.GetConfigurationRange("manuelAirFriction")
		self.impactMultiplier = self.script.mutator.GetConfigurationRange("manuelImpactMultiplier")
	end
	self.lerpTime = 1
	self.targetLerpTime = 1
	self.velocityLimitSliderStop = 0.01
	self.inAirTimer = 0
	self.airTime = 0
	self.hitObstacle = false
	self.script.AddValueMonitor("MonitorGrounded","OnMonitorGrounded")
	self.script.AddDebugValueMonitor("MonitorLerpTime","Lerp time", Color.grey)
	self.script.AddDebugValueMonitor("MonitorVelocity","Velocity", Color.grey)
	self.script.AddDebugValueMonitor("MonitorAirTime","AirTime", Color.grey)
	self.script.AddDebugValueMonitor("MonitorHitObstacle","HitObstacle", Color.grey)
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
end
function Rocketboost:onDamage(actor,source,info)
	if(source == Player.actor and actor == Player.actor and info.isSplashDamage) then
		CurrentEvent.Consume()
		self.lastExplosionInfo = info
		if(self.infiniteRocketLauncherAmmo) then
			Player.actor.activeWeapon.ammo = 100
		end
	end
end
function Rocketboost:SetPreset(airResistance,impactMultiplier)
	self.airResistance = airResistance
	self.impactMultiplier = impactMultiplier
end
function Rocketboost:MonitorGrounded()
	return Player.actorIsGrounded
end
function Rocketboost:MonitorVelocity()
	return tostring(self.impact) .. "      | " .. tostring(self.impact.magnitude)
end
function Rocketboost:MonitorLerpTime()
	return self.lerpTime
end
function Rocketboost:MonitorAirTime()
	return tostring(self.airTime)
end
function Rocketboost:MonitorHitObstacle()
	return self.hitObstacle
end
function Rocketboost:DelayReset() -- Allows bounce
	coroutine.yield(WaitForSeconds(0.04))
	if(self.airTime > 3 and self.impact.magnitude > 5) then
		self.impact = Vector3.zero
	end
end
function Rocketboost:OnMonitorGrounded(value)
	if(value == true) then

		self.inAirTimer = 0
		self.airTime = 0
		self.lerpTime = 0
		self.velocityLimitSliderStop = 20
		if(self.hitObstacle) then
			self.impact = Vector3.zero
			self.hitObstacle = false
		end
		self.script.StartCoroutine("DelayReset")
	else
		self.hitObstacle = false
		self.velocityLimitSliderStop = 0.01
		self.inAirTimer = Time.time
		self.airTime = 0
	end
end
function Rocketboost:onExplosion(position,range,source)
	if(source == Player.actor) then
		self.script.StartCoroutine(self:SetVelocity(position,range))
		
	end
end
function Rocketboost:SetVelocity(position,range)
	return function()
		coroutine.yield(WaitForSeconds(0.0001))
		-- if(not self.hitHimself) then
		-- 	return
		-- end
		-- if(Player.actor.isFallenOver) then
		-- Player.actor.KnockOver(self.lastExplosionInfo.impactForce * self.lastExplosionInfo.direction)
		-- return
		-- end
			local aliveActorsInRange = ActorManager.AliveActorsInRange(position, range)
			for i,y in ipairs(aliveActorsInRange) do
				if(y == Player.actor) then
					
					-- print("Add Impact")
					local distance = Vector3.Distance(Player.actor.position,position)
					local clamped = Mathf.Clamp01(distance,0.1,range + 4)
					-- print("Clamped distance " .. tostring(clamped) .. " max range (1) = " .. range)
					local force = (self.lastExplosionInfo.impactForce.magnitude * self.impactMultiplier) / clamped
					-- print("Applying force: " .. tostring(force))
					self:AddImpact(self.lastExplosionInfo.direction,force)
			end
		end
	end
end
function Rocketboost:AddImpact(dir, force)
	dir.Normalize()
	if (dir.y < 0) then dir.y = -dir.y end
	self.impact = self.impact + dir.normalized * force / 200;
end
function Rocketboost:tablefind(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end
function Rocketboost:onActorSpawn(actor)
	if(actor == Player.actor) then
		self.impact = Vector3.zero
	end
end
function Rocketboost:Update()
	if(GameManager.isPaused or Player.actor == nil or Player.actor.isDead) then
		return
	end

	if (self.impact.magnitude > self.velocityLimitSliderStop) then 
		Player.MoveActor(self.impact * Time.deltaTime) 
		Player.actor.balance = 100
	end
	self.airTime = (Time.time - self.inAirTimer)
	if(Player.actorIsGrounded) then
		if(self.impact.magnitude < 10) then
			self.impact = Vector3.zero
			self.inAirTimer = 0
			self.airTime  = 0
			self.lerpTime = 0
		end
	elseif(not Player.actorIsGrounded and (self.airTime > 1)) then
		if(Player.actor.isAiming) then
			PlayerCamera.ResetRecoil()
		end
		local ray = Ray(Player.actor.centerPosition ,self.impact.normalized)
		local raycast = Physics.Raycast(ray,3,RaycastTarget.Opaque)
		Debug.DrawRay(Player.actor.centerPosition,self.impact.normalized,Color.green)
		if(raycast ~= nil) then
			if(raycast ~= Player.actor) then
				self.hitObstacle = true
			end
		end
	end
	
	if(self.airTime < 2 and not self.hitObstacle) then
		self.targetLerpTime = self.airResistance*Time.deltaTime
	elseif(self.airTime > 2 and not self.hitObstacle) then
		self.targetLerpTime = (self.airResistance*Time.deltaTime) * Mathf.Clamp01((self.airTime),1,25)
	end
	self.lerpTime = Mathf.Lerp(self.lerpTime,self.targetLerpTime,Time.deltaTime * 10)
	self.impact = Vector3.Lerp(self.impact, Vector3.zero, self.lerpTime );
	-- for i,y in ipairs(self.sphereColliderInstances) do
	-- 	if(y[1] ~= nil) then
	-- 		y[1].transform.localScale = Vector3.Lerp(y[1].transform.localScale,Vector3(y[2],y[2],y[2]),Time.deltaTime * 10)
	-- 	end
	-- end
end
