-- Register the behaviour
--behaviour("DamageNumbers")
behaviour("DamageNumbers")

function DamageNumbers:Start()

	self.damageIndList = {}
	self.lastUsedIndex = 1
	self.fontsV = self.script.mutator.GetConfigurationDropdown("fonts")
	self.preset = self.script.mutator.GetConfigurationDropdown("preset")
	self.fontToSpawn = self.targets.damageIndicatorPrefabRoboto
	if(self.fontsV == 0) then
		self.fontToSpawn = self.targets.damageIndicatorPrefabBebasNeue
	elseif(self.fontsV == 1) then
		self.fontToSpawn = self.targets.damageIndicatorPrefabLato
	elseif(self.fontsV == 2) then
		self.fontToSpawn = self.targets.damageIndicatorPrefabRoboto
	end
	if(self.preset == 2 or self.preset == 3) then
		self.fontToSpawn = self.targets.damageIndicatorPrefabBebasNeue
	end 
	for i = 1,17,1 do
		if(self.fontsV == 0) then
			self.DamageNumbersText = GameObject.Instantiate(self.fontToSpawn).GetComponent(Text)
		elseif(self.fontsV == 1) then
			self.DamageNumbersText = GameObject.Instantiate(self.fontToSpawn).GetComponent(Text)
		elseif(self.fontsV == 2) then
			self.DamageNumbersText = GameObject.Instantiate(self.fontToSpawn).GetComponent(Text)
		end
		local rectTransfrom = self.DamageNumbersText.gameObject.GetComponent(RectTransform)
		rectTransfrom.position = Vector3(-5000,-5000,0)
		table.insert(self.damageIndList,{self.DamageNumbersText,rectTransfrom,Vector3(0,0,0),0,0,Vector3(0,0,0),0})
		rectTransfrom.parent = self.targets.canvas.transform
	end

	for i,actor in ipairs(ActorManager.actors) do
		actor.onTakeDamage.AddListener(self,"onTakeDamage")
	end
	self.lastZ = 0
	local floatUpSpeedD = self.script.mutator.GetConfigurationFloat("floatUpSpeed")
	if(floatUpSpeedD == 0) then
		self.floatUpSpeed = 8 / 100
	else
		self.floatUpSpeed = floatUpSpeedD 
	end
	local floatHeightD = self.script.mutator.GetConfigurationFloat("floatHeight")
	if(floatHeightD == 0) then
		self.floatHeight = 0.18 / 100
	else
		self.floatHeight = floatHeightD / 100
	end
	-- Implement Crit 
	-- Implement Sounds
	
	self.duration = self.script.mutator.GetConfigurationRange("textDuration")
	self.minSize = self.script.mutator.GetConfigurationRange("textSizemin") -- * 4
	self.maxSize = self.script.mutator.GetConfigurationRange("textSizemax")
	self.deathCheck = self.script.mutator.GetConfigurationBool("deathCheck")
	self.randomHeightmin = self.floatHeight * 0.4
	self.randomHeightmax = self.floatHeight
	self.wobble = self.script.mutator.GetConfigurationRange("wobble")
	self.debugCounter = 0
	self.debugEnabled = false
	self.healthColoredText = self.script.mutator.GetConfigurationBool("healthColoredTextEnabled")
	self.indicatorVersion = self.script.mutator.GetConfigurationDropdown("damageIndicatorsVersion")
	self.teamColoredText = self.script.mutator.GetConfigurationBool("teamColoredTextEnabled")
	self.randomizedDirection = self.script.mutator.GetConfigurationBool("randomizedDirection")
	self.headShotCrit = self.script.mutator.GetConfigurationBool("headShotCrit")
	self.lastHitActor = nil
	self.script.AddDebugValueMonitor("MonitorLastZ","Z")
	self.randomStrings = {
			"Why did you do that?",
			"There was no reason for that.",
			"<color=red>Stop</color>",
			">:(",
			"Ouch",
			"That hurt",
			"Not again",
			"Aight, that was unnecessary",
			"One too much"
		}
	if(self.preset == 1) then
		self.floatHeight = 0.18 / 100
		self.floatUpSpeed = 8 / 100
		self.wobble = 0.2
		self.minSize = 80 
		self.maxSize = 110
		self.duration = 1.1
		self.randomHeightmin = self.floatHeight * 0.4
		self.randomHeightmax = self.floatHeight
		self.randomizedDirection = true
		self.indicatorVersion = 0
	elseif(self.preset == 2) then
		self.floatHeight = 100 / 100
		self.floatUpSpeed = 120 / 100
		self.wobble = 0.07
		self.minSize = 50
		self.maxSize = 60
		self.duration = 3.91
		self.teamColoredText = true
		self.randomHeightmin = self.floatHeight * 0.4
		self.randomHeightmax = self.floatHeight
		self.randomizedDirection = true
		self.indicatorVersion = 0
	elseif(self.preset == 3) then
		self.floatHeight = 70 / 100
		self.floatUpSpeed = 50 / 100
		self.wobble = 0.03
		self.minSize = 50
		self.maxSize = 60
		self.duration = 2.01
		self.teamColoredText = true
		self.randomHeightmin = self.floatHeight * 0.6
		self.randomHeightmax = self.floatHeight * 1.34
		self.randomizedDirection = true
		self.indicatorVersion = 0
	end
	self.enableCustomColor = self.script.mutator.GetConfigurationBool("enableCustomColor")
	self.customColor = Color.white
	if(self.enableCustomColor) then
		if(self:stringstartswith(self.script.mutator.GetConfigurationString("customNumberColor"))) then
			local inputHex = self.script.mutator.GetConfigurationString("customNumberColor")
			local hexRGBRed = self:hex2rgb(inputHex)
			self.customColor = Color(hexRGBRed[1] ,hexRGBRed[2],hexRGBRed[3],1)
		end
	end
	
end
function DamageNumbers:MonitorLastZ()
	return self.lastZ
end
function DamageNumbers:tablelength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end
function DamageNumbers:ScrollTroughTable(objectss) 
	local maxSize = self:tablelength(objectss)

	self.lastUsedIndex = self.lastUsedIndex + 1
	if(self.lastUsedIndex < maxSize + 1) then
		return objectss[self.lastUsedIndex][1],objectss[self.lastUsedIndex][2]
	else
		self.lastUsedIndex = 1
		return objectss[1][1],objectss[1][2]
	end

end
function DamageNumbers:hex2rgb(hex)
	hex = hex:gsub("#","")
	local r = tonumber("0x"..hex:sub(1,2),16)
	local g = tonumber("0x"..hex:sub(3,4),16)
	local b = tonumber("0x"..hex:sub(5,6),16)
	if(r ~= 0) then
		r = r / 255
	end
	if(g ~= 0) then
		g = g / 255
	end
	if(b ~= 0) then
		b = b / 255
	end
	-- print(string.format("R %s G %s B %s",r,g,b))
	return {r,g,b}
end
function DamageNumbers:stringstartswith(str)
	return str:sub(1, 1) == "#"
end
function DamageNumbers:round2(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end
-- If balance 0 then crack sound 
function DamageNumbers:PlaceTextAtPos(worldPosition,healthDamageText,color) 
	local canvasPos = PlayerCamera.activeCamera.WorldToScreenPoint(worldPosition)
	local damageText,rectTransform = self:ScrollTroughTable(self.damageIndList)
	damageText.CrossFadeAlpha(1,0,false)
	damageText.color = color
	damageText.text = healthDamageText
	self.damageIndList[self.lastUsedIndex][3] = worldPosition
	self.damageIndList[self.lastUsedIndex][4] = Time.time -- elapsed time
	self.damageIndList[self.lastUsedIndex][5] = Random.Range(self.randomHeightmin,self.randomHeightmax) -- elapsed time
	if(self.randomizedDirection) then
		self.damageIndList[self.lastUsedIndex][6] = Vector3(Random.Range(-self.floatHeight,self.floatHeight),Random.Range(-self.floatHeight,self.floatHeight),0)
	end
	self.damageIndList[self.lastUsedIndex][7] = 0
	rectTransform.position = canvasPos
	damageText.CrossFadeAlpha(0,self.duration,false)
end
function DamageNumbers:onTakeDamage(actor,source,info)
	if(source ~= Player.actor or PlayerCamera.activeCamera == nil or info.healthDamage == 0) then return end
	local indText = (self.indicatorVersion == 1) and tostring(self:round2(actor.health)) or tostring(self:round2(info.healthDamage))
	if(self.deathCheck and self.lastHitActor ~= actor and actor.isFallenOver and actor.isDead) then
		self.lastHitActor = actor
		local randomInt = Mathf.FloorToInt(Random.Range(1, self:tablelength(self.randomStrings) + 1))
		self:PlaceTextAtPos(info.point,self.randomStrings[randomInt],Color(Random.Range(0,255) / 255,Random.Range(0,255) / 255,Random.Range(0,255) / 255))
		return
	end
	if(actor.isDead) then return end
	if(self.enableCustomColor) then
		if(actor.isFallenOver) then
			self:PlaceTextAtPos(info.point,indText,self.customColor )
		else
			self:PlaceTextAtPos(info.point,indText,self.customColor )
		end
		return
	end
	if(self.healthColoredText and self.teamColoredText) then
		local color = Color.Lerp(Color.red, ColorScheme.GetTeamColor(actor.team), (actor.health / actor.maxHealth));
		if(actor.isFallenOver) then
			self:PlaceTextAtPos(info.point,indText,color * Color(0.8,0.8,0.8))
		else
			self:PlaceTextAtPos(info.point,indText,color)
		end
		return
	end
	if(self.healthColoredText) then
		local color = Color.Lerp(Color.red, Color.green, (actor.health / actor.maxHealth));
		self:PlaceTextAtPos(info.point,indText,color)
		
	else
		if(self.teamColoredText) then
			if(actor.isFallenOver) then
				self:PlaceTextAtPos(info.point,indText,ColorScheme.GetTeamColor(actor.team) * Color(0.8,0.8,0.8))
			else
				self:PlaceTextAtPos(info.point,indText,ColorScheme.GetTeamColor(actor.team))
			end
		else
			if(actor.isFallenOver) then
				self:PlaceTextAtPos(info.point,indText,Color(1,0.5,0.5))
			else
				self:PlaceTextAtPos(info.point,indText,Color.red)
			end
		end
		
	end
	
		
end
function DamageNumbers:Flip(x)
    return 1 - x;
end
function DamageNumbers:EaseIn(n)
	return n * n
end
function DamageNumbers:PowOf3(n)
	return n * n * n
end
-- https://www.febucci.com/2018/08/easing-functions/
function DamageNumbers:EaseOut(t)
    return self:Flip(self:PowOf3(t));
end
function DamageNumbers:Spike(t)
	if(t <= 0.1) then
		return self:PowOf3(t / 0.1)
	end
    return self:Flip(self:PowOf3(t/0.9));
end
function DamageNumbers:Update()
	if(Debug.isTestMode) then
		if(self.debugEnabled) then
			self.debugCounter = self.debugCounter + 2
			if(self.debugCounter >= 100) then
				self:PlaceTextAtPos(PlayerCamera.activeCamera.transform.position + PlayerCamera.activeCamera.transform.forward * 4,tostring(50),Color(Random.Range(0,255) / 255,Random.Range(0,255) / 255,Random.Range(0,255) / 255))
				self.debugCounter = 0
			end
		end
		if(Input.GetKeyDown(KeyCode.T)) then
			self.debugEnabled = not self.debugEnabled
		end
	end
	if(self.randomizedDirection) then -- Had to do it this way because it is a bit more performent
		for i,y in ipairs(self.damageIndList) do
			local elapsedTime = Time.time - y[4]
			if(elapsedTime < self.duration) then
				y[3] = Vector3.Lerp(y[3],y[3] + y[6] + Vector3(Mathf.Sin(Time.time * 3) * self.wobble,0,0) ,self:EaseOut(elapsedTime/self.duration) * Time.deltaTime * self.floatUpSpeed) -- ease in 
				local canvasPos = PlayerCamera.activeCamera.WorldToScreenPoint(y[3])
				y[2].position = canvasPos
				local distance = canvasPos.z
				-- local clampedDistance = Mathf.Clamp((distance * 0.4),self.minSize,self.maxSize)
				-- clampedDistance = Mathf.Lerp(clampedDistance * 0.2,clampedDistance ,(elapsedTime / self.duration) * Time.deltaTime * 12)
				local clampedDistance = Mathf.Clamp((distance * 0.4),self.minSize,self.maxSize)
				-- clampedDistance = Mathf.Lerp(clampedDistance * 0.2,clampedDistance ,(elapsedTime / self.duration) * Time.deltaTime * 12)
				y[1].fontSize = clampedDistance * 0.8
			end
		end
	else
		for i,y in ipairs(self.damageIndList) do
			local elapsedTime = Time.time - y[4]
			if(elapsedTime < self.duration) then
				y[3] = Vector3.Lerp(y[3],y[3] + Vector3(Mathf.Sin(Time.time * 5) * self.wobble  + y[5] - self.floatHeight,self.floatHeight + y[5] * self.floatHeight,0),self:EaseOut(elapsedTime/self.duration) * Time.deltaTime * self.floatUpSpeed) -- ease in 
				local canvasPos = PlayerCamera.activeCamera.WorldToScreenPoint(y[3])
				y[2].position = canvasPos
				local distance = canvasPos.z
				local clampedDistance = Mathf.Clamp((distance * 0.4),self.minSize,self.maxSize)
				-- clampedDistance = Mathf.Lerp(clampedDistance * 0.2,clampedDistance ,(elapsedTime / self.duration) * Time.deltaTime * 12)
				y[1].fontSize = clampedDistance * 0.8
			end
		end
	end

end


-- self.floatUpSpeed = 0.08 * 100
	-- self.floatHeight = 0.18
	-- self.duration = 0.94
