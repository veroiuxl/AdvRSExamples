-- Register the behaviour
behaviour("LDS")
-- local self.rotateableTurretTreePath = "Anti Air Gun/Mount Parent/Mount Bearing"
-- local self.rotateableTurretGunTreePath = "Anti Air Gun/Mount Parent/Mount Bearing/Mount/Gun"
-- local self.GunMuzzleTreePath = "Anti Air Gun/Mount Parent/Mount Bearing/Mount/Gun/Muzzle"

function LDS:Start()
	self.rotateableTurretTreePath = "SEQ-4"
	self.rotateableTurretGunTreePath = "SEQ-4/Plane/Cylinder"
	self.GunMuzzleTreePath = "SEQ-4/Plane/Cylinder/Muzzle"
	self.targetRange = Mathf.Infinity
	self.WaitBetweenTargetAcquire = 1
	self.turretBaseRotationSpeed = 6
	self.turretGunRotationSpeed = 9
	self.timeToDestroy = 2
	self.currentTarget = nil
	self.currentTargetSafe = nil
	self.hasTarget = false 
	self.isShooting = false
	self.debugMode = true
	self.rotateableTurret = nil
	self.rotateableTurretGun = nil
	self.GunMuzzle = nil
	self.scriptVar = self.script
	self.activated = false
	self.lineRenderer = nil
	self.explosionPs = nil
	local projectileReceiverObj = GameObject.Find("ProjectileReceiver(Clone)")
	if(projectileReceiverObj == nil) then
		projectileReceiverObj = GameObject.Instantiate(self.targets.projectileReceiverScript)
		self.projectileReceiverScript = ScriptedBehaviour.GetScript(projectileReceiverObj)
		print("Created projectile receiver")
	else
		print("Receiver found")
		self.projectileReceiverScript = ScriptedBehaviour.GetScript(projectileReceiverObj)
	end
	self.searchingForTarget = false


	self.rotateableTurret = self.gameObject.transform.Find(self.rotateableTurretTreePath)
	self.rotateableTurretGun = self.gameObject.transform.Find(self.rotateableTurretGunTreePath)
	self.GunMuzzle = self.gameObject.transform.Find(self.GunMuzzleTreePath)
	self.lineRenderer = self.targets.lineRenderer.GetComponent(LineRenderer)
	self.lineRenderer.SetPosition(1, Vector3(0,0,0))
	self.explosionPs = self.targets.explosionPs
	self.isMutatorRunning = false
	self.mutator = GameObject.Find("ANSEQ-3 Laser Weapon SystemScript(Clone)")
	if self.mutator == nil then

		print("Mutator not found.")
		self.debugMode = false
		self.isMutatorRunning = false 
	else 

	
	self.behavLDS = ScriptedBehaviour.GetScript(self.mutator)
	local customMutatorV = self.behavLDS:GetCustomValues()
	self.isMutatorRunning = true
	if customMutatorV[1] == -1 then
		self.targetRange = Mathf.Infinity
	else
		self.targetRange = customMutatorV[1]
	end
	self.WaitBetweenTargetAcquire = customMutatorV[2]
	self.turretBaseRotationSpeed = customMutatorV[3]
	self.turretGunRotationSpeed = customMutatorV[4]
	self.timeToDestroy = customMutatorV[5]
	self.debugMode = customMutatorV[6]
	print("Set custom Mutator values (LDS SCRIPT)")
	self.behavLDS:UpdateUI("Set custom Mutator values",0)
	if self.debugMode == false then
		self.behavLDS:HideUI()
	end
	end
	
	
end
function LDS:UpdateUI(status,distance) -- Remove this in future versions
	if self.debugMode == true and self.isMutatorRunning then
	self.behavLDS:UpdateUI(status,distance)
	end
end
function LDS:UpdateClosestUI(text) -- Remove this in future versions
	if self.debugMode == true and self.isMutatorRunning  then
	self.behavLDS:UpdateClosestUI(text)
	end
end
function LDS:GetAllRockets()
-- local rockets = {}
-- for i,y in ipairs(GameObject.FindObjectsOfType(Projectile)) do -- Yikes
-- 	if y.gameObject.GetComponent(Light) ~= nil and y.gameObject.activeSelf == true then
-- 		table.insert(rockets, y)
-- 	end
-- end
-- return rockets
local allrockets = self.projectileReceiverScript:GetAllRockets()
print(tostring(#allrockets))
return allrockets
end
function LDS:ConfirmTarget(target)
return function()
		if target ~= nil then
		if string.sub(target.gameObject.name, -7) == "beingTr" then
			self:UpdateUI("<color=#21c904>Target is already being tracked</color>",-10)
			self.hasTarget = false
			self.currentTarget = nil
			return
		end
		self.hasTarget = true
		self.currentTarget = target
		-- local ray = Ray(self.GunMuzzle.transform.position * self.GunMuzzle.transform.position.forward + 1,self.GunMuzzle.transform.position.forward)
		--  -- self.targetRange - 10 because it would probably hit the rocket and return that as an obstacle
		-- local raycast = RaycastHit(ray,self.targetRange - 3,RaycastTarget.ProjectileHit)
		self:UpdateUI("<color=#21c904>Target acquired</color>",0)
		if self.debugMode == true then
		print("Target acquired")
		end
		self.currentTarget.gameObject.name = self.currentTarget.gameObject.name .. "beingTr" 
		self.script.StartCoroutine("Shoot")
		else
			if self.debugMode == true then
			print("Target is already been destroyed")
			end
			self.hasTarget = false
			self.currentTarget = nil
			self.searchingForTarget = false
			self:UpdateUI("<color=gray>Invalid Target</color>",0)
		end
	   
	end
end
function LDS:DestroyWithDelay(gameObject,delay)

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
function LDS:Shoot()
	if self.currentTarget ~= nil then
		self.currentTargetSafe = self.currentTarget.gameObject.transform
	end
	
	self.isShooting = true
	self.lineRenderer.SetPosition(0, Vector3(0,0,0))
	local tardir = self.currentTargetSafe.position - self.GunMuzzle.transform.position
	
	self:UpdateUI("<color=#b1eb34>Shoot() Waiting self.timeToDestroy</color>",-1)
	coroutine.yield(WaitForSeconds(self.timeToDestroy))
	if self.currentTarget ~= nil and self.currentTargetSafe ~= nil then
	-- for i,y in ipairs(self.currentTargetSafe.gameObject.GetComponentsInChildren(ParticleSystem)) do
	-- 	if y ~= nil then
	-- 	if string.find(y.gameObject.name,"Explosion") then
	-- 	y.Play()
	-- 	end
	-- 	end
	-- end
	
	local expl = GameObject.Instantiate(self.explosionPs)
	print(tostring(self.currentTargetSafe))
	expl.transform.position = self.currentTargetSafe.gameObject.GetComponent(Projectile).transform.position
	expl.GetComponentInChildren(ParticleSystem).Play()


	self.script.StartCoroutine(self:DestroyWithDelay(expl,4))
	self.lineRenderer.SetPosition(1, Vector3(0,0,0))
	if self.currentTarget ~= nil then
		GameObject.Destroy(self.currentTarget.gameObject)
		self:UpdateUI("<color=#eb3d34>Shoot() Destroyed Target</color>",-3)
	end
	self.currentTarget = nil
	self.currentTargetSafe = nil
	coroutine.yield(WaitForSeconds(self.WaitBetweenTargetAcquire))
	self.hasTarget = false
	self.searchingForTarget = true
	--	self.currentTargetSafe.GetComponent(Projectile).velocity = Vectro3(0,-99999,0)
	self.isShooting = false
	end
end
function LDS:AcquireTarget()
	if self.rotateableTurret == nil then
		print("self.rotateableTurret is nil")
		return
	end
	if self.rotateableTurretGun == nil then
		print("self.rotateableTurretGun is nil")
		return
	end
	local allProj = self:GetAllRockets()
	if(allProj == nil or allProj == 0) then
		self:UpdateUI("<color=#3abda7>No targets found</color>",0)
		return
	end
	local target = self:GetClosest(allProj)
	
	if target ~= nil  then
		self:UpdateUI("<color=#3b992b>Got target</color>",0)
		if self.debugMode == true then
		print("<color=#3b992b>Got target</color>")
		end
		self.scriptVar.StartCoroutine(self:ConfirmTarget(target))
	else
		self:UpdateUI("<color=#3abda7>No targets found</color>",0)
		self.searchingForTarget = true
	end
end
function LDS:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function LDS:GetClosest(proje) 
	local bestTarget = null;
	local closestDistanceSqr = self.targetRange
	local currentPosition = self.scriptVar.gameObject.transform.position

	for i,potentialTarget in ipairs(proje) do
		local directionToTarget = potentialTarget.transform.position - currentPosition
		local ray = Ray(self.GunMuzzle.transform.position, self.GunMuzzle.transform.forward)
		local raycast = Physics.RaycastAll(ray,directionToTarget.magnitude - (directionToTarget.magnitude / 2) - 2, RaycastTarget.Default)
		local dSqrToTarget = directionToTarget.sqrMagnitude
		local size = self:tablelength(raycast)
		
		if size == 0 then
			if dSqrToTarget < closestDistanceSqr then
				closestDistanceSqr = dSqrToTarget;
				bestTarget = potentialTarget;
			end
		else
		
			self:UpdateClosestUI(potentialTarget.transform.gameObject.name .. " is behind obj")
			-- for i,y in ipairs(raycast) do
			-- 	print("Hit object " .. y.transform.gameObject.name)
			-- end
		end
		
	end
	return bestTarget
end
--[[
https://github.com/warlockbrawl/warlock/blob/master/game/dota_addons/warlock/scripts/vscripts/warlock/projectiles/bouncerprojectile.lua#L82-L114
--]]
function LDS:Update()
	
    if self.hasTarget then
		local lookPos1 
		local lookPos2
		local tar
		local ray
		local raycast

		if self.currentTargetSafe ~= nil or self.currentTarget ~= nil then

			lookPos1 = self.currentTargetSafe.transform.position - self.rotateableTurret.transform.position 
			lookPos2 = self.currentTargetSafe.transform.position - self.rotateableTurretGun.transform.position
		    tar = self.currentTargetSafe.transform.position - self.GunMuzzle.transform.position 
			-- tar.magnitude - (tar.magnitude / 2)) 

			ray = Ray(self.GunMuzzle.transform.position, self.GunMuzzle.transform.forward)
			raycast = Physics.RaycastAll(ray,tar.magnitude - (tar.magnitude / 2) - 2, RaycastTarget.Default) -- Time.frameCount%5 == 0 addition for performance reason
			local size = self:tablelength(raycast)
			if size ~= 0 then
				self:UpdateUI("Lost target",tar.magnitude)
				if self.debugMode == true then
				for i=1,size,1 do
					local lineRenderer2 = GameObject.Instantiate(self.targets.lineRendererPrefab)
					lineRenderer2.GetComponent(LineRenderer).SetPosition(0, self.GunMuzzle.transform.position)
					lineRenderer2.GetComponent(LineRenderer).SetPosition(1, raycast[i].point)
					self.script.StartCoroutine(self:DestroyWithDelay(lineRenderer2,3))
					print("Lost target")
					self.searchingForTarget = false
				end
				end
				self.hasTarget = false
				self.searchingForTarget = false
				return
			end
			self.lineRenderer.SetPosition(1, Vector3(0,0,tar.magnitude - (tar.magnitude / 2)))

		local rotation1 = Quaternion.LookRotation(lookPos1)
		rotation1 = Quaternion.Euler(Vector3(0, rotation1.eulerAngles.y, 0))
		self.rotateableTurret.transform.rotation = Quaternion.Slerp(self.rotateableTurret.transform.rotation, rotation1, Time.deltaTime * self.turretBaseRotationSpeed)

		local rotation2 = Quaternion.LookRotation(lookPos2)
		rotation2 = Quaternion.Euler(Vector3(0, -90.00001,-rotation2.eulerAngles.x))  -- -90.00001 specific to current model aswell as -rotation2.eulerAngles.x because blender export
		self.rotateableTurretGun.transform.localRotation = Quaternion.Slerp(self.rotateableTurretGun.transform.localRotation, rotation2, Time.deltaTime * self.turretGunRotationSpeed)
		end
	else
		self:UpdateUI("<color=#e3b007>Acquiring Target...</color>",0)
		self.hasTarget = false
	if(not self.searchingForTarget) then
		print("Started Acquire Target coroutine")
		self.script.StartCoroutine("AcquireTarget")
		self.searchingForTarget = true
	end
    end
end
