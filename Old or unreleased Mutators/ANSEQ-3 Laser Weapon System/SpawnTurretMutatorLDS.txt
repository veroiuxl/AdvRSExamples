-- Register the behaviour
behaviour("SpawnTurretMutatorLDS")
local spawned = false
local instan
local inputFE = false
function SpawnTurretMutatorLDS:Start()
	spawned = false
	print(self.gameObject.name)
	-- self.targets.inputFieldCopy.gameObject.SetActive(false)
	self.targetRangeI = self.script.mutator.GetConfigurationInt("targetRange")
	self.WaitBetweenTargetAcquireI = self.script.mutator.GetConfigurationInt("WaitBetweenTargetAcquire")
	self.turretBaseRotationSpeedI = self.script.mutator.GetConfigurationInt("turretBaseRotationSpeed")
	self.turretGunRotationSpeedI = self.script.mutator.GetConfigurationInt("turretGunRotationSpeed")
	self.timeToDestroyI = self.script.mutator.GetConfigurationInt("timeToDestroy")
	self.debugModeI = self.script.mutator.GetConfigurationBool("debugMode")
	self.isSpectator = false
	if Player.actor.team == Team.Neutral then
	self.isSpectator = true
	self.specCam = GameObject.Find("Spectator Camera(Clone)").GetComponent(Camera)
	end
end
function SpawnTurretMutatorLDS:UpdateUI(status,distance)
	self.targets.text.GetComponent(Text).text = "Status: " .. status 
	.. "\nDistance:" .. tostring(distance) 
end
function SpawnTurretMutatorLDS:UpdateClosestUI(text)
	self.targets.textcl.GetComponent(Text).text = "GetClosest(): " .. tostring(text)

end
function SpawnTurretMutatorLDS:HideUI()

	self.targets.text.GetComponent(Text).gameObject.SetActive(false)
	self.targets.textcl.GetComponent(Text).gameObject.SetActive(false)
end
function SpawnTurretMutatorLDS:GetCustomValues()

return {self.targetRangeI,self.WaitBetweenTargetAcquireI,self.turretBaseRotationSpeedI,self.turretGunRotationSpeedI,self.timeToDestroyI,self.debugModeI}
	--			1						2								3								4						5				6			
end
function SpawnTurretMutatorLDS:Update()
	-- if Input.GetKeyDown(KeyCode.B) then
	-- 	inputFE = not inputFE
	-- 	if inputFE then
		
	-- 		Screen.UnlockCursor()
	-- 		self.targets.inputFieldCopy.gameObject.setActive(true)
	-- 		self.targets.textC.GetComponent(Text).text = "targetRange = " .. tostring(self.targetRangeI) 
	-- 		.. "\nWaitBetweenTargetAcquire = " .. tostring(self.WaitBetweenTargetAcquireI)
	-- 		.. "\nturretBaseRotationSpeed = " .. tostring(self.turretBaseRotationSpeedI)
	-- 		.. "\nturretGunRotationSpeed = " .. tostring(self.turretGunRotationSpeedI)
	-- 		.. "\ntimeToDestroy = " .. tostring(self.timeToDestroyI)
	-- 		.. "\ndebugMode = " .. tostring(self.debugModeI)
	-- 	else
	-- 		Screen.LockCursor()
	-- 		self.targets.inputFieldCopy.gameObject.setActive(false)
	-- 	end
	-- end
	if Input.GetKeyDown(KeyCode.T) and not Player.actor.isDead and Player.actor.activeWeapon ~= nil then
		local rocket = GameObject.Instantiate(self.targets.rocket)
		if self.isSpectator then
			rocket.transform.position = self.specCam.transform.position
			rocket.transform.rotation = self.specCam.transform.rotation
		else
		rocket.transform.position = Player.actor.activeWeapon.currentMuzzleTransform.position
		rocket.transform.rotation = Player.actor.activeWeapon.currentMuzzleTransform.rotation
		end
		print("Spawned " .. rocket.gameObject.name .. " with tag " .. rocket.gameObject.tag )
		local allProj = GameObject.FindObjectsOfType(Projectile)
		
	end
	-- if not Player.actor.isDead then
	-- 	local tempArray = {}
	-- 	local allProj = GameObject.FindObjectsOfType(Projectile)
	-- for i,y in ipairs(allProj) do
	-- 	if y.gameObject.GetComponent(Projectile) ~= nil then
	-- 	if string.find(y.gameObject.GetComponent(Projectile).gameObject.name,"rocket") then
	-- 	print(y.gameObject.name .. " with projcomp: " .. tostring(y.gameObject.GetComponent(Projectile).sourceWeapon) .. " source " .. tostring(y.gameObject.GetComponent(Projectile).source))
	-- 	end
	-- 	end
	-- end
	-- end
	
	if Input.GetKeyDown(KeyCode.X) then
		local ray
		local raycast
		if self.isSpectator then
			ray = Ray(self.specCam.transform.position + self.specCam.transform.forward, self.specCam.transform.forward)
			raycast = Physics.Raycast(ray,50, RaycastTarget.ProjectileHit)
		else
			ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward, PlayerCamera.activeCamera.main.transform.forward)
			raycast = Physics.Raycast(ray,50, RaycastTarget.ProjectileHit)
		end
		if raycast ~= nil then
			local pos = raycast.point
			local direction
			if not self.isSpectator then
				direction = pos - Player.actor.position
			else
				direction = pos - self.specCam.transform.position
			end
			direction = Vector3(direction.x,0,direction.z) 
			-- if spawned then
			-- 	instan.transform.rotation = Quaternion.LookRotation(direction)
			-- 	instan.transform.position = pos
			-- 	return
			-- end
			instan = GameObject.Instantiate(self.targets.turret)
			instan.transform.rotation = Quaternion.LookRotation(direction)
			instan.transform.position = pos
			-- spawned = true
		end

	end
	
end
