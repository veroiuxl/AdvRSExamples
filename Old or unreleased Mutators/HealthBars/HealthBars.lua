-- Register the behaviour
behaviour("HealthBars")
local orgColor
local orgBackgroundColor
local isPlayingWithNameTagMutator
local defaultScale

-- TODO Blue instead of green
function HealthBars:Start()
	-- Run when behaviour is created
	self.tags = {}
	self.colorBlue = Color(self.script.mutator.GetConfigurationRange("rSliderEagle") / 255,self.script.mutator.GetConfigurationRange("gSliderEagle") / 255,self.script.mutator.GetConfigurationRange("bSliderEagle") / 255,self.script.mutator.GetConfigurationRange("aSliderEagle") / 255)
	self.colorRed = Color(self.script.mutator.GetConfigurationRange("rSliderRaven") / 255,self.script.mutator.GetConfigurationRange("gSliderRaven") / 255,self.script.mutator.GetConfigurationRange("bSliderRaven") / 255,self.script.mutator.GetConfigurationRange("aSliderRaven") / 255)
	self.onlyOwnTeam = self.script.mutator.GetConfigurationBool("onlyOwnTeam")
	self.colorBlueLight = Color.Lerp(self.colorBlue, Color.white, 0.5)
	self.colorRedLight = Color.Lerp(self.colorRed, Color.white, 0.5)
	self.colorBlueLight.a = 0.7
	self.colorRedLight.a = 0.7
	if GameObject.Find("Name Tags Mutator(Clone)") ~= nil then
		isPlayingWithNameTagMutator = true
		print("Name Tag Mutator !")
	else
		isPlayingWithNameTagMutator = false
	end
	self.onlyTeammates = false 

	for k,actor in pairs(ActorManager.actors) do
		if actor.isBot then
			local tag = GameObject.Instantiate(self.targets.slider).GetComponent(Slider)
			local rectTf = tag.gameObject.GetComponent(RectTransform)
			rectTf.parent = self.targets.canvas.transform
			rectTf.position = Vector3(100, 100, 0)
			defaultScale = rectTf.localScale
			tag.maxValue = actor.maxHealth
			tagData = {}
			tagData.backgroundColor = tag.transform.Find("Background").gameObject.GetComponent(Image)
			tagData.baseColor = tag.transform.Find("Fill Area/Fill").gameObject.GetComponent(Image)
			tagData.backgroundColor.CrossFadeAlpha(0, 0, true)
			tagData.baseColor.CrossFadeAlpha(0, 0, true)
			tagData.healthText = tag.transform.gameObject.GetComponentInChildren(Text)
			tagData.healthText.CrossFadeAlpha(0, 0, true)
			tagData.rectTransform = rectTf
			tagData.tag = tag;
			tagData.isDrawing = false
			tagData.usingDriverTag = false
			self.tags[actor] = tagData
			
		end
	end
end

function HealthBars:Update()
	-- Run every frame
	if self.tags ~= nil then

		local camera = PlayerCamera.activeCamera
		for actor,tagData in pairs(self.tags) do
			
			local tag = tagData.tag
			local anchorWorldPos = actor.centerPosition
			if tagData.usingDriverTag and actor.activeVehicle ~= nil then
			
			 anchorWorldPos = actor.activeVehicle.transform.position
			
			end
			if isPlayingWithNameTagMutator then
			anchorWorldPos.y = anchorWorldPos.y + 0.91
			else
			anchorWorldPos.y = anchorWorldPos.y + 1
			end
			if tagData.usingDriverTag then 
				anchorWorldPos.y = anchorWorldPos.y + 1.7
			end
			local anchorScreenPos = camera.WorldToScreenPoint(anchorWorldPos)
		
			
		

			local isTeammate = actor.team == Player.team
			local focusSize = Screen.height/10
			local isInFocus = math.abs(anchorScreenPos.x - Screen.width/2) < focusSize and math.abs(anchorScreenPos.y - Screen.height/2) < focusSize
			local isInView = anchorScreenPos.z > 0
	--		local canActorSee = ActorManager.ActorCanSeePlayer(actor)
	local canSee = ActorManager.ActorsCanSeeEachOther(Player.actor,actor)
	local shouldDraw = isInView and not actor.isDead and not actor.isPassenger and (isInFocus or (isTeammate and anchorScreenPos.z < 15)) and canSee -- and canActorSee
	if not tagData.isDrawing and shouldDraw then

		tagData.isDrawing = true
		tagData.backgroundColor.CrossFadeAlpha(1, 0.1, true)
		tagData.baseColor.CrossFadeAlpha(1, 0.1, true)
		tagData.healthText.CrossFadeAlpha(1, 0.1, true)
	elseif tagData.isDrawing and not shouldDraw then
		tagData.isDrawing = false
		tagData.healthText.CrossFadeAlpha(0, 0.1, true)
		tagData.backgroundColor.CrossFadeAlpha(0, 0.1, true)
		tagData.baseColor.CrossFadeAlpha(0, 0.1, true)
	end
	if shouldDraw then
		if actor.isDriver then
			
			tagData.usingDriverTag = true
			tagData.rectTransform.localScale = Vector3(0.9,0.9,1)
		elseif not actor.isDriver and tagData.usingDriverTag then
			tagData.rectTransform.localScale = defaultScale
			tagData.usingDriverTag = false
		end
	end
	
	if actor.health > 0 then
		if tagData.usingDriverTag and actor.activeVehicle ~= nil then
			tag.value = actor.activeVehicle.health -- Replace with Vehicle health
			tag.maxValue = actor.activeVehicle.maxHealth
		
			tagData.healthText.text = tostring(Mathf.RoundToInt(actor.activeVehicle.health))
		else
			tag.value = actor.health 
			tag.maxValue = actor.maxHealth -- Because some mutators will increase it in the future!
			tagData.healthText.text = tostring(Mathf.RoundToInt(actor.health))
		end
	end
	tagData.rectTransform.position = anchorScreenPos
	

	if (isInView and anchorScreenPos.z < 290)  then
		if not isTeammate and not tagData.usingDriverTag and not self.onlyOwnTeam  then
			if anchorScreenPos.z < 160 then
			tagData.baseColor.color = self.colorRedLight
			tagData.healthText.color = Color(1,1,1,0.9)
			end
		elseif isTeammate and not tagData.usingDriverTag then
			if anchorScreenPos.z < 160 then
			tagData.baseColor.color = self.colorBlueLight
			tagData.healthText.color = Color(1,1,1,0.9)
			end
		elseif isTeammate and tagData.usingDriverTag then
			tagData.baseColor.color = self.colorBlue
			tagData.healthText.color = Color(1,1,1,1)
		elseif not isTeammate and tagData.usingDriverTag and not self.onlyOwnTeam  then
		
			tagData.baseColor.color = self.colorRed
			tagData.healthText.color = Color(1,1,1,1)
	else
		tagData.healthText.color = Color.clear
		tagData.baseColor.color = Color.clear
		tagData.backgroundColor.color = Color.clear
	end
end
end
end
end
