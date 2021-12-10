-- Register the behaviour
behaviour("MoreWeatherEffects")
-- TODO: Disable clouds at night cause they emit light
function MoreWeatherEffects:Start()
	-- Run when behaviour is created
	self.weatherSelected = self.script.mutator.GetConfigurationDropdown("weatherEffect")
	print("Dropdown selected: " .. tostring(self.script.mutator.GetConfigurationDropdown("weatherEffect")))
	self.levelOfQuality = self.script.mutator.GetConfigurationRange("qualityLevel")
	self.enableClouds = self.script.mutator.GetConfigurationBool("enableClouds")
	self.enableFog = self.script.mutator.GetConfigurationBool("realisticSandstorm")
	self.enableRealisticClouds = self.script.mutator.GetConfigurationBool("realisticClouds")
	self.cloudHeightMethod = self.script.mutator.GetConfigurationDropdown("cloudHeightMethod")
	self.cloudsPrefab = self.targets.clouds
	-- GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	self.audioPlayer = self.targets.audioPlayer
	self.instanceAudioPlayer = GameObject.Instantiate(self.audioPlayer)
	self.audioPlayerAll = self.instanceAudioPlayer.gameObject.GetComponentsInChildren(AudioSource)
	self.windHowl = self.audioPlayerAll[1]
	self.windAmbience = self.audioPlayerAll[2]
	self.rainDrops = self.audioPlayerAll[3]
	self.gentlerain = self.audioPlayerAll[4]
	if(self.cloudHeightMethod == 0) then
		local capturePoints = {}
		local heightAverage = 0
		for i,y in ipairs(ActorManager.capturePoints) do
			heightAverage = heightAverage + y.transform.position.y
		end
		heightAverage = heightAverage / self:tablelength(ActorManager.capturePoints)
		self.cloudHeight = heightAverage + 233
		print("Cloud Height (avg): " .. tostring(self.cloudHeight))
	elseif(self.cloudHeightMethod == 1) then
		local highestCapturePoint = {}
		for i,y in ipairs(ActorManager.capturePoints) do
			table.insert(highestCapturePoint, y.transform.position.y)
		end
		table.sort(highestCapturePoint, function(a, b) return a > b end)
		print("Cloud Height (highest Point): " .. tostring(highestCapturePoint[1] + 233) )
		self.cloudHeight = highestCapturePoint[1] + 233
	end
	self.disableBecauseSeated = false
	self.startedWithOnlyClouds = false
	if(self.levelOfQuality == 1) then
		self.psFog = self.targets.FogPs1
	elseif self.levelOfQuality == 2 then
		self.psFog = self.targets.FogPs2
	elseif self.levelOfQuality == 3 then
		self.psFog = self.targets.FogPs3
	elseif self.levelOfQuality == 4 then
		self.psFog = self.targets.FogPs4
	end
	if(self.levelOfQuality == 1) then
		self.psSnow = self.targets.SnowPs1
	elseif self.levelOfQuality == 2 then
		self.psSnow = self.targets.SnowPs2
	elseif self.levelOfQuality == 3 then
		self.psSnow = self.targets.SnowPs3
	elseif self.levelOfQuality == 4 then
		self.psSnow = self.targets.SnowPs4
	end
	
	if(self.levelOfQuality == 1) then
		self.psSandstorm = self.targets.sandstormPs1
	elseif self.levelOfQuality == 2 then
		self.psSandstorm = self.targets.sandstormPs2
	elseif self.levelOfQuality == 3 then
		self.psSandstorm = self.targets.sandstormPs3
	elseif self.levelOfQuality == 4 then
		self.psSandstorm = self.targets.sandstormPs4
	end
	if(self.levelOfQuality == 1) then
		self.psRain = self.targets.rainPs1
	elseif self.levelOfQuality == 2 then
		self.psRain = self.targets.rainPs2
	elseif self.levelOfQuality == 3 then
		self.psRain = self.targets.rainPs3
	elseif self.levelOfQuality == 4 then
		self.psRain = self.targets.rainPs4
	end
	self.headingPos = Vector3.zero
	self.lead = true
	self.onlyClouds = false
	-- self.psRain = self.targets.RainPs
	-- self.psHRain = self.targets.HRainPs
	self.speed = 1
	self.speedV = 1
	self.leadAhead = 1
	self.playerPressedF8 = false
	-- self.psExp = self.targets.Exp
	self.currentOffset = Vector3(0,0,0)
	self.currentVehicleOffset = Vector3(0,0,0)
	if(self.weatherSelected == 0) then -- Snow
		self.lead = true
		self.currentPs = GameObject.Instantiate(self.psSnow)	
		-- self.currentOffset = Vector3(0,4.5,0) Old
		
		self.currentOffset = Vector3(0,12,0)
		self.speed = 0.89
		self.speedV = 1.29
		self.leadAhead = 1
		self.currentVehicleOffset = Vector3(0,-4,0)
	elseif self.weatherSelected == 1 then -- Sandstorm
		self.currentPs = GameObject.Instantiate(self.psSandstorm)
		self.currentOffset = Vector3(0,0.05,0)
		self.speed = 1
		self.speedV = 1.3
		self.leadAhead = 1.4
		self.lead = true	
		if(self.enableFog == true) then
		self.script.StartCoroutine(self:ApplyRenderSettings(0.01,30.02,297.5,Color(238/255,232/255,205/255,0.2)))
		end
		self.windAmbience.Play()
		self.windHowl.Play()
		self.currentVehicleOffset = Vector3(0,2.5,0)
	elseif self.weatherSelected == 2 then -- Rain
		self.currentPs = GameObject.Instantiate(self.psRain)
		self.lead = true
		self.currentOffset = Vector3(0,-1,0)
		self.speed = 1
		self.speedV = 1.9
		self.leadAhead = 1.6
		self.windAmbience.Play()
		self.windHowl.Play()
		self.currentVehicleOffset = Vector3(0,25,0)
	elseif self.weatherSelected == 3 then -- Fog
		self.currentPs = GameObject.Instantiate(self.psFog)	
		self.currentOffset = Vector3(0,0.05,0)
		self.speed = 1.4
		self.speedV = 19
		self.leadAhead = 5.5
		self.lead = true
		self.currentVehicleOffset = Vector3(0,0,0) 
		if(self.enableFog == true) then
		-- self.script.StartCoroutine(self:ApplyRenderSettings(0.002,30,400,Color(0.79,0.79,0.79,0.2)))
		self.script.StartCoroutine(self:ApplyRenderSettings(0.007,30.02,297.5,Color(232/255,232/255,232/255,0.2)))
		end
	elseif self.weatherSelected == 4 then
		self.enableClouds = true
		self.onlyClouds = true
		self.startedWithOnlyClouds = true
	end
if(self.enableClouds) then
if(self.weatherSelected ~= 2) then
	if(self.enableRealisticClouds) then
		self.cloudsPs = GameObject.Instantiate(self.targets.cloudRealistic)
	else
		self.cloudsPs = GameObject.Instantiate(self.cloudsPrefab)
	end
elseif self.weatherSelected == 2 then
	if(self.enableRealisticClouds) then
		self.cloudsPs = GameObject.Instantiate(self.targets.cloudRainRealistic)
	else
		self.cloudsPs = GameObject.Instantiate(self.targets.cloudsRain)
	end
end
end
if(self.currentPs ~= nil) then
	print(tostring(self.currentPs.gameObject.name))
	self.currentPSComponent = self.currentPs.gameObject.GetComponent(ParticleSystem) 
end
self.windAmbience.SetOutputAudioMixer(AudioMixer.World)
self.windHowl.SetOutputAudioMixer(AudioMixer.World)
self.rainDrops.SetOutputAudioMixer(AudioMixer.World)
self.gentlerain.SetOutputAudioMixer(AudioMixer.World)

self.overWriteDefaultSkybox = self.script.mutator.GetConfigurationBool("overwriteDefaultSkybox")
self.script.StartCoroutine("ApplySkybox")
end
function MoreWeatherEffects:onActorSpawn(actor)
if(not actor.isBot) then
self.script.StartCoroutine("ActorSpawn")
end


end
function MoreWeatherEffects:contains(table, element)
	for _, value in pairs(table) do
	  if value == element then
		return true
	  end
	end
	return false
end
function MoreWeatherEffects:ApplySkybox()
coroutine.yield(WaitForSeconds(1))
if(self.overWriteDefaultSkybox and self:isUsingProceduralSkybox()) then
	RenderSettings.skybox = self.targets.customSkybox
end

end
function MoreWeatherEffects:isUsingProceduralSkybox()
	if(self:GetSkyboxName() == "Default-Skybox") then
		return true
	end
	
	local skybox = RenderSettings.skybox
	if(self:contains(skybox.shaderKeywords,"_EMISSION") and self:contains(skybox.shaderKeywords,"_SUNDISK_HIGH_QUALITY") or self:contains(skybox.shaderKeywords,"_SUNDISK_SIMPLE")) then
		return true
	end
	return false

end
function MoreWeatherEffects:GetSkyboxName()
	return RenderSettings.skybox.name
end
function MoreWeatherEffects:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function MoreWeatherEffects:ActorSpawn()

coroutine.yield(WaitForSeconds(0.1))
if(not self.onlyClouds or not self.startedWithOnlyClouds) then
self.currentPs.transform.position = Player.actor.position
end
end

function MoreWeatherEffects:ApplyRenderSettings(fogDensitiy,startDis,endDis,color)
	return function()
	coroutine.yield(WaitForSeconds(1))
	RenderSettings.fog = true
	RenderSettings.fogColor = color
	RenderSettings.fogDensity = fogDensitiy
	RenderSettings.fogStartDistance = startDis 
	RenderSettings.fogEndDistance = endDis
	end
end

function MoreWeatherEffects:SetAudioSourceVolume(index,volume)
	self.audioPlayerAll[index].volume = volume
end
function MoreWeatherEffects:PlayAll()
for i,y in ipairs(self.audioPlayerAll) do
	if(not y.isPlaying) then
	y.Play()
	end
end
end
function MoreWeatherEffects:StopAll()
	for i,y in ipairs(self.audioPlayerAll) do
		if(y.isPlaying) then
		y.Stop()
		end
	end
end
function MoreWeatherEffects:Update()
	if(GameManager.isPaused) then
		self.windHowl.Stop()
		self.windAmbience.Stop()
		self.rainDrops.Stop()
		self.gentlerain.Stop()
	else
		if(not self.rainDrops.isPlaying and self.weatherSelected == 2) then
			self.rainDrops.Play()
			self.gentlerain.Play()
			self.windAmbience.Play()
		end
		if(not self.windAmbience.isPlaying and self.weatherSelected == 1) then
			self.windHowl.Play()
			self.windAmbience.Play()
		end
	end

	if PlayerCamera.activeCamera.main ~= nil or PlayerCamera.activeCamera ~= nil and self.currentPs ~= nil and Player.actor ~= nil then
	
		self.instanceAudioPlayer.transform.position = PlayerCamera.activeCamera.transform.position
		if(not self.startedWithOnlyClouds) then
			if(Player.actor.isSeated and self.weatherSelected == 1) then
				if(Player.actor.activeVehicle.isAirplane or Player.actor.activeVehicle.isHelicopter) then
				if(self.currentPSComponent.isPlaying) then
					self.currentPSComponent.Stop(true)
					self.onlyClouds = true
					self.disableBecauseSeated = true
				
				end
			else
					self.disableBecauseSeated = false
					self.onlyClouds = false
				end
			end
		if(self.cloudHeight < (Player.actor.position.y - 2)) then
			if(self.currentPSComponent.isPlaying) then
				self.currentPSComponent.Stop(true)
				self.onlyClouds = true
				
			end
		elseif not self.disableBecauseSeated and self.cloudHeight > (Player.actor.position.y - 2) then
			self.onlyClouds = false
		end
		end
		if(not self.onlyClouds or not self.startedWithOnlyClouds) then -- start onlyClouds

		local ray = Ray(PlayerCamera.activeCamera.transform.position + PlayerCamera.activeCamera.transform.forward, PlayerCamera.activeCamera.transform.up)
		local raycast = Physics.Raycast(ray,9, RaycastTarget.Default)
		if raycast ~= nil then -- start raycast ~= nil 
			if(raycast.transform.gameObject.GetComponent(Vehicle) == nil) then
				self.headingPos = Vector3.Lerp(self.headingPos,Player.actor.velocity,Time.deltaTime * 1.2)
				if(not GameManager.isPaused and self.weatherSelected == 1 or self.weatherSelected == 2) then
					self.windAmbience.volume = Mathf.Lerp(self.windAmbience.volume,0.1,Time.deltaTime * 0.7)
					self.windHowl.volume = Mathf.Lerp(self.windHowl.volume,0.2,Time.deltaTime * 0.7)
					self.rainDrops.volume = Mathf.Lerp(self.rainDrops.volume,0.2,Time.deltaTime * 0.7)
				end
				-- if(self.currentPs.GetComponent(ParticleSystem).isPlaying) then // Cause I the rain has collision now
				-- 	self.currentPs.GetComponent(ParticleSystem).Stop(true)
				-- end
				end
		else -- else raycast ~= nil 
			if(not self.currentPSComponent.isPlaying and self.onlyClouds ~= true) then
				self.currentPSComponent.Play(true)
			end
			if(not GameManager.isPaused and self.weatherSelected == 1 or self.weatherSelected == 2 and not Player.actor.isSeated) then
			self.windAmbience.volume = Mathf.Lerp(self.windAmbience.volume,0.6,Time.deltaTime * 0.7)
			self.windHowl.volume = Mathf.Lerp(self.windHowl.volume,0.7,Time.deltaTime * 0.7)
			self.rainDrops.volume  = Mathf.Lerp(self.rainDrops.volume,0.8,Time.deltaTime * 1.5)
			self.gentlerain.volume  = Mathf.Lerp(self.gentlerain.volume,0.7,Time.deltaTime * 1)
			elseif not GameManager.isPaused and self.weatherSelected == 1 or self.weatherSelected == 2 and Player.actor.isSeated then
			self.windAmbience.volume = Mathf.Lerp(self.windAmbience.volume,0.36,Time.deltaTime * 0.7)
			self.windHowl.volume = Mathf.Lerp(self.windHowl.volume,0.3,Time.deltaTime * 0.7)
			self.rainDrops.volume = Mathf.Lerp(self.rainDrops.volume,0.3,Time.deltaTime * 1)
			self.gentlerain.volume = Mathf.Lerp(self.gentlerain.volume,0.2,Time.deltaTime * 1)	
			end
			self.headingPos =  Player.actor.velocity
		end  -- end raycast ~= nil 
		end-- end onlyClouds
		if(not Player.actor.isSeated) then
			-- Start Cloud
				if(self.enableClouds) then
					self.cloudsPs.transform.position = Vector3.Lerp(self.cloudsPs.transform.position,Vector3(Player.actor.velocity.x,0,Player.actor.velocity.z) + Vector3(Player.actor.position.x,self.cloudHeight,Player.actor.position.z) ,Time.fixedDeltaTime * 1.4) 
				end
			-- End Cloud
				if(not self.onlyClouds and not self.startedWithOnlyClouds) then
					if(self.lead) then
					self.currentPs.transform.position = Vector3.Lerp(self.currentPs.transform.position,(self.headingPos * self.leadAhead) + Player.actor.position + self.currentOffset,Time.fixedDeltaTime * self.speed) 
				else
					self.currentPs.transform.position = Player.actor.position
			end
			end
			else
			-- Start Cloud
				if(self.enableClouds) then
					self.cloudsPs.transform.position = Vector3.Lerp(self.cloudsPs.transform.position,Vector3(Player.actor.velocity.x,0,Player.actor.velocity.z) + Vector3(Player.actor.position.x,self.cloudHeight,Player.actor.position.z) ,Time.fixedDeltaTime * 1.4) 
				end
			-- End Cloud
				if(not self.onlyClouds and not self.startedWithOnlyClouds) then
					if(self.lead) then
						self.currentPs.transform.position = Vector3.Lerp(self.currentPs.transform.position,(self.headingPos * 1) + Player.actor.position - self.currentVehicleOffset,Time.fixedDeltaTime * self.speedV) 
					else
						self.currentPs.transform.position = Player.actor.position
					end 
				end
		end
end
	
end
