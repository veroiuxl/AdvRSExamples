-- Register the behaviour
behaviour("MWE")

local ERandom = {
	RangeInt = function(min, max)
		return Mathf.FloorToInt(Random.Range(min, max))
	end
	
}
function MWE:Start()
	self.hitInstances = {}
	self.playerHitSoundInstances = {}
	self.script.StartCoroutine(self:GetDefaultSpeed())
	for i,y in ipairs(ActorManager.actors) do
		if(y.isBot) then
			y.onTakeDamage.AddListener(self,"onTakeDamage")		
		else
			y.onTakeDamage.AddListener(self,"onTakeDamagePlayer")		
		end
	end
	GameEvents.onActorDied.AddListener(self,"onActorDied")
	-- Field Of View
	self.fieldOfView = GameObject.Find("Field Of View").GetComponentInChildren(Slider).value
	-- self.playerCamera = GameObject.Find("FP Camera").GetComponent(Camera)
	self.playerCamera = PlayerCamera.fpCamera
	self.startFov = self.playerCamera.fieldOfView
	self.targetFov = self.startFov + 20 
	self.currentFov = self.startFov
	print(self.fieldOfView)

	

	self.hitSounds = {}
	self.hitSoundVolume = self.script.mutator.GetConfigurationRange("hitSoundVolume") / 100
	self.playerHitSoundVolume = self.script.mutator.GetConfigurationRange("playerHitSoundVolume") / 100
	table.insert(self.hitSounds, self.targets.hitIndicator)
	table.insert(self.hitSounds, self.targets.hitIndicator2)
	self.killSound = self.targets.killSound
	self.playerHitSounds = {}
	table.insert(self.playerHitSounds, self.targets.phs1)
	table.insert(self.playerHitSounds, self.targets.phs2)
	table.insert(self.playerHitSounds, self.targets.phs3)
	table.insert(self.playerHitSounds, self.targets.phs4)
	table.insert(self.playerHitSounds, self.targets.phs5)
	table.insert(self.playerHitSounds, self.targets.phs6)
	table.insert(self.playerHitSounds, self.targets.phs7)
	table.insert(self.playerHitSounds, self.targets.phs8)
	table.insert(self.playerHitSounds, self.targets.phs9)
	table.insert(self.playerHitSounds, self.targets.phs10)
	table.insert(self.playerHitSounds, self.targets.phs11)
	self.soundInstance = self.targets.soundInstance
	
	self.regenSpeedUp = self.script.mutator.GetConfigurationRange("regenSpeed") * 100
	self.lastShotTime = 0
	self.hasLowerHealth = false
	self.currentRegenTimer = 0
	self.maxRegenTimer = self.script.mutator.GetConfigurationRange("regenTimer")

	self.healthText = GameObject.Find("Health Text").GetComponent(Text)
end
function MWE:GetDefaultSpeed()
return function()
coroutine.yield(WaitForSeconds(0.3))
self.targetSpeed = Player.actor.speedMultiplier * 1.2
self.defaultSpeed = Player.actor.speedMultiplier
self.speedC = self.defaultSpeed
end
end
function MWE:tablefind(tab,el) 
	for index, value in pairs(tab) do
		if value == el then
			return index
		end
	end
end
function MWE:onActorDied(actor,source,isSilent)

if(not isSilent and source == Player.actor and actor ~= Player.actor) then
self:SpawnSoundAtPos(self.killSound,actor.position,1.3)
end
end
function MWE:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function MWE:onTakeDamagePlayer(actor,source,damageInfo)
if(not actor.isDead and not damageInfo.isScripted) then
	self:SpawnPlayerSoundAtPos(self:GetPlayerHitSound(),actor.position,0.4)
	self.currentRegenTimer = self.maxRegenTimer
	self.exp = 0
	self.lastShotTime = Time.time
end
end
function MWE:onTakeDamage(actor,source,damageInfo)
	if(source == Player.actor and not damageInfo.isScripted and not damageInfo.isSplashDamage and actor.isBot and not actor.isDead) then
		self:SpawnSoundAtPos(self:GetRandomHitSound(),damageInfo.point,0.6)
	end
end

function MWE:SpawnSoundAtPos(clip, point,destorydelay)
	local soundInstance = GameObject.Instantiate(self.soundInstance).GetComponent(AudioSource)
	table.insert(self.hitInstances, soundInstance)
	soundInstance.clip = clip
	soundInstance.volume = self.hitSoundVolume
	soundInstance.transform.position = point
	soundInstance.SetOutputAudioMixer(AudioMixer.FirstPerson)
	soundInstance.Play()
	self.script.StartCoroutine(self:DestroyWithDelayhitInstances(soundInstance,destorydelay))
end
function MWE:SpawnPlayerSoundAtPos(clip, point,destorydelay)
	local soundInstance = GameObject.Instantiate(self.soundInstance).GetComponent(AudioSource)
	table.insert(self.playerHitSoundInstances, soundInstance)
	soundInstance.clip = clip
	soundInstance.volume = self.playerHitSoundVolume
	soundInstance.transform.position = point
	soundInstance.SetOutputAudioMixer(AudioMixer.FirstPerson)
	soundInstance.Play()
	self.script.StartCoroutine(self:DestroyWithDelayplayerHitSoundInstances(soundInstance,destorydelay))
end
function MWE:GetPlayerHitSound()
	return self.playerHitSounds[ERandom.RangeInt(1,self:tablelength(self.playerHitSounds) + 1)]
end
function MWE:GetRandomHitSound()
	return self.hitSounds[ERandom.RangeInt(1,self:tablelength(self.hitSounds) + 1)] 
end
function MWE:DestroyWithDelayplayerHitSoundInstances(gameObject,delay)

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
		table.remove(self.playerHitSoundInstances, self:tablefind(self.playerHitSoundInstances,destroyGO))
	end

end
function MWE:DestroyWithDelayhitInstances(gameObject,delay)

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
		table.remove(self.hitInstances, self:tablefind(self.hitInstances,destroyGO))
	end

end
function MWE:EaseIn(n)
	return n * n
end
function MWE:SetHorizontalFOV(Fov,camera)
	local num = Screen.width / Screen.height;
	local b2 = Mathf.Tan(Fov / 2 * 0.0174532924) / num
	local a1 = 114.59156 * Mathf.Atan(b2)
	camera.fieldOfView = a1;
end
function MWE:HorizontalToVertical(horizontalFov,camera)
	return 2.0* Mathf.Atan(Mathf.Tan(horizontalFov*0.5)/camera.aspect)
end
function MWE:Update()
	if(Input.GetKeyDown(KeyCode.Escape)) then
		if(not GameManager.isPaused) then

			-- Won't check if player is using aimFov
			self.startFov = self.playerCamera.fieldOfView
			self.targetFov = self.startFov + 20
		end
	end
	if(Input.GetKeyDown(KeyCode.J)) then
		Player.actor.Damage(Player.actor, 10, 0, false,false)
		self.currentRegenTimer = self.maxRegenTimer
		self.exp = 1
		self.lastShotTime = Time.time
	end
	if(Player.actor.health <= Player.actor.maxHealth - 1) then
		self.hasLowerHealth = true
	else
		self.hasLowerHealth = false
	end
	
	-- if(Player.actor.isSprinting and not Player.actor.isAiming) then
	-- 	self.currentFov = self.targetFov
	-- else if(self.playerCamera.fieldOfView >= self.startFov and not Player.actor.isSprinting and not Player.actor.isAiming) then
	-- 	self.currentFov = self.startFov
	-- else if (self.playerCamera.fieldOfView < self.startFov and Player.actor.activeWeapon ~= nil) then
	-- 	self.currentFov = Mathf.RoundToInt(self.playerCamera.fieldOfView)
	-- end
	-- end
	-- end
	if(Input.GetKeyDown(KeyCode.LeftAlt)) then
		self.shouldZoom = not self.shouldZoom
	
	end
	if(self.shouldZoom) then
		self.playerCamera.fieldOfView = Mathf.Lerp(self.playerCamera.fieldOfView,40,Time.deltaTime * 12)
	end
	-- print(self.playerCamera.fieldOfView .. " moving to " .. tostring(self.currentFov))

	if(not Player.actor.isDead) then
			if(Player.actor.isSprinting) then
				self.speedC = self.targetSpeed
			else
				self.speedC = self.defaultSpeed
			end
			Player.actor.speedMultiplier = Mathf.Lerp(Player.actor.speedMultiplier,self.speedC,Time.deltaTime * 3) 
			if (self.currentRegenTimer > 0) then
				self.currentRegenTimer = self.currentRegenTimer - Time.deltaTime
				local secondsleft = Mathf.FloorToInt((self.currentRegenTimer + 1) % 60)
				print("Time left " .. tostring(secondsleft))
				
			else
				if(self.hasLowerHealth) then
				self.exp = self:EaseIn((Time.time - self.lastShotTime) / self.regenSpeedUp )
				Player.actor.health = Mathf.Lerp(Player.actor.health, Player.actor.maxHealth + Player.actor.maxHealth, self.exp);
				-- print("Start regen exp " .. tostring(self.exp) .. " player " .. tostring( Mathf.CeilToInt(Player.actor.health)))
				self.healthText.text = Mathf.CeilToInt(Player.actor.health)
				end
			end
	end
	for i,y in ipairs(self.playerHitSoundInstances) do
		if(y ~= nil and Player.actor ~= nil and not Player.actor.isDead) then
			y.transform.position = Player.actor.position
			y.pitch = Time.timeScale
		end
	end
	for i,y in ipairs(self.hitInstances) do
		if(y ~= nil) then
			y.pitch = Time.timeScale
		end
	end
end
