-- Register the behaviour
behaviour("Sliding")

function Sliding:Start()
	self.impact = Vector3.zero
	self.airResistance = 1.5
	self.impactMultiplier = 10
	
	self.lerpTime = 1
	self.targetLerpTime = 1
	self.slidingSpeedMultiplier = 1.6
	self.hitObstacle = false
	-- self.script.AddDebugValueMonitor("MonitorLerpTime","Lerp time", Color.grey)
	self.script.AddDebugValueMonitor("MonitorAllowedSoSlide","AllowedToSlide")
	self.script.AddValueMonitor("MonitorIsPlayerCrouching","OnPlayerCrouch")
	self.script.AddDebugValueMonitor("MonitorVelocity","Velocity", Color.grey)
	self.script.AddDebugValueMonitor("MonitorHitObstacle","HitObstacle", Color.grey)
	self.script.AddDebugValueMonitor("MonitorOnGround","OnGround")
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")

	self.isSliding = false
	self.allowedToSlide = false
	self.isGrounded = false
end

function Sliding:SetPreset(airResistance,impactMultiplier)
	self.airResistance = airResistance
	self.impactMultiplier = impactMultiplier
end
function Sliding:MonitorOnGround()
	return self.isGrounded 
end
function Sliding:MonitorGrounded()
	return Player.actorIsGrounded
end
function Sliding:MonitorAllowedSoSlide()
	return self.allowedToSlide
end
function Sliding:MonitorVelocity()
	return tostring(self.impact) .. "      | " .. tostring(self.impact.magnitude)
end
function Sliding:MonitorLerpTime()
	return self.lerpTime
end
function Sliding:MonitorIsPlayerCrouching()
	if(Player.actor == nil) then
		return false
	end
	return Player.actor.isCrouching
end
function Sliding:MonitorHitObstacle()
	return self.hitObstacle
end
function Sliding:OnPlayerCrouch(value)
if(value) then
	if(self.allowedToSlide) then
		self.targetLerpTime = 0.6
		self:CopyPlayerVelocity()
	end
else
	self.targetLerpTime = 8
end
end
function Sliding:CopyPlayerVelocity()
	self.impact = Vector3.Scale(Player.actor.velocity,Vector3(self.slidingSpeedMultiplier,1,self.slidingSpeedMultiplier))
end
function Sliding:tablefind(tab,el)
    for index, value in pairs(tab) do
        if value == el then
            return index
        end
    end
end
function Sliding:onActorSpawn(actor)
	if(actor == Player.actor) then
		self.impact = Vector3.zero
	end
end
function Sliding:IsGrounded()
	if(Player.actorIsGrounded) then
		return true
	end
	local ray = Ray(Player.actor.position,-Vector3.up) 
	local raycast = Physics.Raycast(ray,2,RaycastTarget.ProjectileHit)
	if(raycast ~= nil) then
		return true
	else
		return false
	end
end
function Sliding:Update()
	if(GameManager.isPaused or Player.actor == nil or Player.actor.isDead) then
		return
	end

	if (self.impact.magnitude > 0.9) then 
		Player.MoveActor(self.impact * Time.deltaTime * 1.2) 
		Player.actor.balance = 100
	end
	self.isGrounded = self:IsGrounded()
	if(Player.actor.isSprinting and self.isGrounded and not Player.actor.isSwimming and not Player.actor.isFallenOver) then
		self.allowedToSlide = true
	else
		self.allowedToSlide = false
	end
	-- if(Player.actorIsGrounded) then
	-- 	if(self.impact.magnitude < 10) then
	-- 		self.impact = Vector3.zero
	-- 		self.inAirTimer = 0
	-- 		self.airTime  = 0
	-- 		self.lerpTime = 0
	-- 	end
	-- elseif(not Player.actorIsGrounded and (self.airTime > 1)) then
	-- 	if(Player.actor.isAiming) then
	-- 		PlayerCamera.ResetRecoil()
	-- 	end
	-- 	local ray = Ray(Player.actor.centerPosition ,self.impact.normalized)
	-- 	local raycast = Physics.Raycast(ray,3,RaycastTarget.Opaque)
	-- 	Debug.DrawRay(Player.actor.centerPosition,self.impact.normalized,Color.green)
	-- 	if(raycast ~= nil) then
	-- 		if(raycast ~= Player.actor) then
	-- 			self.hitObstacle = true
	-- 		end
	-- 	end
	-- end
	self.lerpTime = Mathf.Lerp(self.lerpTime,self.targetLerpTime,Time.deltaTime * 2 )
	self.impact = Vector3.Lerp(self.impact, Vector3.zero, Time.deltaTime * self.lerpTime );
end
