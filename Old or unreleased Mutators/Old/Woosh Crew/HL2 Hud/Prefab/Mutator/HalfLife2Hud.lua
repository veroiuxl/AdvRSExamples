-- Register the behaviour
behaviour("HalfLife2Hud")

function HalfLife2Hud:Start()
	self.middleRight = self.targets.MiddleRight
	self.PrimaryIcon = self.targets.PrimaryIcon.transform.gameObject.GetComponent(Image)
	self.SecondaryIcon = self.targets.SecondaryIcon.transform.gameObject.GetComponent(Image)
	self.Gear1 = self.targets.Special1.transform.gameObject.GetComponent(Image)
	self.largeGear = self.targets.Special2.transform.gameObject.GetComponent(Image)
	self.Gear3 = self.targets.Special3.transform.gameObject.GetComponent(Image)
	self.Gear3GameObject = self.targets.Gear3GameObject
	self.middleRight.gameObject.SetActive(false)
	-- Weapon Text
	self.PrimaryText = self.PrimaryIcon.gameObject.transform.parent.parent.gameObject.GetComponentInChildren(Text)
	self.SecondaryText = self.SecondaryIcon.gameObject.transform.parent.parent.gameObject.GetComponentInChildren(Text)
	self.Gear1Text = self.Gear1.gameObject.transform.parent.parent.gameObject.GetComponentInChildren(Text)
	self.largeGearText = self.largeGear.gameObject.transform.parent.parent.gameObject.GetComponentInChildren(Text)
	self.Gear3Text = self.Gear3.gameObject.transform.parent.parent.gameObject.GetComponentInChildren(Text)



	self.weaponMaterial = GameObject.Find("Primary Button").gameObject.transform.Find("Image").gameObject.GetComponent(Image).material
	self.canvas = self.targets.canvas.GetComponent(Canvas)
	self.canvas.enabled = false
	self.hasLargeGear = true
	self.disabledHud = true
	-- Bottom Left
	self.healthText = self.targets.HealthText.GetComponent(Text)
	self.CurrentAmmoText = self.targets.CurrentAmmoText.GetComponent(Text)
	self.SpareAmmoText = self.targets.SpareAmmoText.GetComponent(Text)
	self.vehicleCanvasGroup = self.targets.VehicleHealthObj.GetComponent(CanvasGroup)
	self.vehicleHealthText = self.targets.VehicleHealthObj.gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
	self.vehicleCanvasGroup.alpha = 0
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	GameEvents.onActorDied.AddListener(self,"onActorDied")

	-- self.script.AddValueMonitor("MonitorCurrentAmmo", "OnAmmoChange")
	-- self.script.AddValueMonitor("MonitorSpareAmmo", "OnSpareAmmoChange")
	-- self.script.AddValueMonitor("MonitorHealth", "OnHealthChange")
	-- self.script.AddValueMonitor("MonitorActiveWeapon", "OnActiveWeaponChange")

	-- Variables
	self.currentWeapon = nil

	-- Setting the material for the Icons
	self.PrimaryIcon.material = self.weaponMaterial
	self.SecondaryIcon.material = self.weaponMaterial
	self.Gear1.material = self.weaponMaterial
	self.largeGear.material = self.weaponMaterial
	self.Gear3.material = self.weaponMaterial


	self.fadeInSpeed = 0.6
	self.fadeOutSpeed = 0.8
	self.gearFadeInAndOutSpeed = self.fadeInSpeed

	self.PrimaryImage = self.targets.PrimaryImage.GetComponent(Image)
	self.SecondaryImage = self.targets.SecondaryImage.GetComponent(Image)
	self.Special1Image = self.targets.Special1Image.GetComponent(Image)
	self.Special2Image = self.targets.Special2Image.GetComponent(Image)
	self.Special3Image = self.targets.Special3Image.GetComponent(Image)

	self:FadeOutAll()
	self.CrosshairGameObject = self.targets.CrosshairGameObject
	self.EmptyShotSoundGameObject = self.targets.EmptyShotSoundGameObject
	self.SpawnedForTheFirstTime = false
	self.playerIsUsingFramework = false
	self.playerEnabledHud = self.script.mutator.GetConfigurationBool("playerEnabledHud")
	self.playerEnabledCrosshair = self.script.mutator.GetConfigurationBool("playerEnabledHLCrosshair")
	self.playerEnabledEmptyShot = self.script.mutator.GetConfigurationBool("playerEnabledEmptyShot")
	print(string.format("Hud %s | Crosshair %s | EmptyShotSFX %s",tostring(self.playerEnabledHud),tostring(self.playerEnabledCrosshair),tostring(self.playerEnabledEmptyShot)))
	self:ToggleCrosshair()
	self:ToggleEmptyShotSounds()



end
function HalfLife2Hud:ToggleHealthAndAmmoUI(value)

end
function HalfLife2Hud:PhFramework()
	coroutine.yield(WaitForSeconds(0.3))
	self.ph = GameObject.Find("Attachment System")


	self.playerIsUsingFramework = false
	if(self.ph ~= nil) then
		self.ph = self.ph.gameObject.transform.GetChild(0)
		print("Found Ph!")
		self.playerIsUsingFramework = true
	end


end
function HalfLife2Hud:ToggleCrosshair()
	self.targets.CrosshairGameObject.gameObject.SetActive(self.playerEnabledCrosshair)
end
function HalfLife2Hud:ToggleEmptyShotSounds()
	self.targets.EmptyShotSoundGameObject.gameObject.SetActive(self.playerEnabledEmptyShot)
end
function HalfLife2Hud:FadeOutAll()
	self.PrimaryImage.CrossFadeAlpha(0, 0, true)
	self.SecondaryImage.CrossFadeAlpha(0, 0, true)
	self.Special1Image.CrossFadeAlpha(0, 0, true)
	self.Special2Image.CrossFadeAlpha(0, 0, true)
	self.Special3Image.CrossFadeAlpha(0, 0, true)

	self.PrimaryIcon.CrossFadeAlpha(0, 0, true)
	self.SecondaryIcon.CrossFadeAlpha(0, 0, true)
	self.Gear1.CrossFadeAlpha(0, 0, true)
	self.largeGear.CrossFadeAlpha(0, 0, true)
	self.Gear3.CrossFadeAlpha(0, 0, true)

	self.PrimaryText.CrossFadeAlpha(0, 0, true)
	self.SecondaryText.CrossFadeAlpha(0, 0, true)
	self.Gear1Text.CrossFadeAlpha(0, 0, true)
	self.largeGearText.CrossFadeAlpha(0, 0, true)
	self.Gear3Text.CrossFadeAlpha(0, 0, true)
end
function HalfLife2Hud:OnlyPrimary()
	self.PrimaryImage.CrossFadeAlpha(1, 0, true)
	self.SecondaryImage.CrossFadeAlpha(0, 0, true)
	self.Special1Image.CrossFadeAlpha(0, 0, true)
	self.Special2Image.CrossFadeAlpha(0, 0, true)
	self.Special3Image.CrossFadeAlpha(0, 0, true)

	self.PrimaryIcon.CrossFadeAlpha(1, 0, true)
	self.SecondaryIcon.CrossFadeAlpha(0, 0, true)
	self.Gear1.CrossFadeAlpha(0, 0, true)
	self.largeGear.CrossFadeAlpha(0, 0, true)
	self.Gear3.CrossFadeAlpha(0, 0, true)

	self.PrimaryText.CrossFadeAlpha(1, 0, true)
	self.SecondaryText.CrossFadeAlpha(0, 0, true)
	self.Gear1Text.CrossFadeAlpha(0, 0, true)
	self.largeGearText.CrossFadeAlpha(0, 0, true)
	self.Gear3Text.CrossFadeAlpha(0, 0, true)


end
function HalfLife2Hud:Update()
	if(self.playerEnabledHud == false) then
		self.canvas.enabled = false
		return
	end
	if(Input.GetKeyDown(KeyCode.Home)) then
		self.disabledHud = not self.disabledHud 
		if(self.disabledHud) then
			self:FadeOutAll()
		end
		self.canvas.enabled = self.disabledHud
	end

	GameManager.hudPlayerEnabled = false
	if(Player.actor ~= nil) then
		-- if(self.playerIsUsingFramework) then
		-- 	if(self.ph.gameObject.activeSelf) then
		-- 		self.canvas.enabled = true
		-- 		print("Disabling")
		-- 		self.disabledHud = true
		-- 	elseif(not self.ph.gameObject.activeSelf ) then
		-- 		self.canvas.enabled = false
		-- 		print("Enabled")
		-- 	end
		-- end
		if(Player.actor.activeWeapon ~= nil) then
			local currentWeapon = Player.actor.activeWeapon
			self.CurrentAmmoText.text = currentWeapon.ammo
			self.SpareAmmoText.text = currentWeapon.spareAmmo
			if (currentWeapon.spareAmmo == -1) then
				self.SpareAmmoText.text = ""
			elseif (currentWeapon.spareAmmo == -2) then
				self.SpareAmmoText.text = "/∞";
			end
			self.healthText.text = tostring(Mathf.RoundToInt(Player.actor.health))
			if(Player.actor.activeVehicle ~= nil) then
				self.vehicleHealthText.text = tostring(Mathf.RoundToInt(Player.actor.activeVehicle.health))	
				self.vehicleCanvasGroup.alpha = 1
			else
				self.vehicleCanvasGroup.alpha = 0
			end
		end
			if(self.currentWeapon ~= nil) then
				if(self.currentWeapon ~= Player.actor.activeWeapon) then
					self:PlayerSwitchedWeaponEvent(self.currentWeapon,Player.actor.activeWeapon)
				end
			end
			self.currentWeapon = Player.actor.activeWeapon
	else
		self.healthText.text = "0"
	end
	
end


function HalfLife2Hud:onActorDied(actor,source,silent)
	if(actor == Player.actor) then
	print("Hide MiddleRight")
	self.middleRight.gameObject.SetActive(false)
	self.canvas.enabled = false
end


end
function HalfLife2Hud:onActorSpawn(actor)
if(actor == Player.actor) then
	if(not self.SpawnedForTheFirstTime) then
		self.script.StartCoroutine("PhFramework")
		self.SpawnedForTheFirstTime = true
	end
	self.canvas.enabled = true
	self.script.StartCoroutine("ChangeWeaponIcons")
	self:OnlyPrimary()

end
end
function HalfLife2Hud:ExternalWeaponChange()
	self.script.StartCoroutine("ChangeWeaponIcons")
	self:OnlyPrimary()
end
function HalfLife2Hud:ChangeWeaponIcons()
	for i,y in ipairs(Player.actor.weaponSlots) do
		print(tostring(i) .. y.weaponEntry.name .. " | " .. tostring(y.weaponEntry.slot))
	end
	local primaryWeaponSlot =  Player.actor.weaponSlots[1]
	if(primaryWeaponSlot ~= nil) then
	self.PrimaryIcon.sprite = primaryWeaponSlot.uiSprite
	self.PrimaryText.text = primaryWeaponSlot.weaponEntry.name
	else

	end
	local secondaryWeaponSlot =  Player.actor.weaponSlots[2]
	if(secondaryWeaponSlot ~= nil) then
	self.SecondaryIcon.sprite = secondaryWeaponSlot.uiSprite
	self.SecondaryText.text = secondaryWeaponSlot.weaponEntry.name
	end
	local Gear1WeaponSlot =  Player.actor.weaponSlots[3]
	if(Gear1WeaponSlot ~= nil) then
	self.Gear1.sprite = Gear1WeaponSlot.uiSprite
	self.Gear1Text.text = Gear1WeaponSlot.weaponEntry.name
	end
	local gear5 = Player.actor.weaponSlots[5] 
	if(gear5 == nil) then
		self.hasLargeGear = true
		local largeGear = Player.actor.weaponSlots[4]
		self.largeGear.sprite = largeGear.uiSprite
		self.largeGearText.text = largeGear.weaponEntry.name
		self.Gear3GameObject.gameObject.SetActive(false)
		
	else
		self.hasLargeGear = false
		self.Gear3GameObject.gameObject.SetActive(true)
		local largeGear = Player.actor.weaponSlots[4]
		if(largeGear ~= nil) then
		self.largeGear.sprite = largeGear.uiSprite
		self.largeGearText.text = largeGear.weaponEntry.name
		end
		local lastGear = Player.actor.weaponSlots[5]
		if(lastGear ~= nil) then
			self.Gear3.sprite = lastGear.uiSprite
			self.Gear3Text.text = lastGear.weaponEntry.name
		end
	end
	print(print(tostring(self.hasLargeGear )))

	self.middleRight.gameObject.SetActive(true)
	
end

-- Events
function HalfLife2Hud:PlayerSwitchedWeaponEvent(previousWeapon,newWeapon)
	if(previousWeapon == nil or newWeapon == nil) then
		return
	end
	if(previousWeapon.slot == 0) then
		self:AnimateIconOut(self.PrimaryImage)
		self:AnimateIconOut(self.PrimaryIcon)
		self:AnimateIconOut(self.PrimaryText)
	elseif previousWeapon.slot == 1 then
		self:AnimateIconOut(self.SecondaryImage)
		self:AnimateIconOut(self.SecondaryIcon)
		self:AnimateIconOut(self.SecondaryText)
	elseif previousWeapon.slot == 2 then
		self:AnimateIconOut(self.Special1Image)
		self:AnimateIconOut(self.Gear1)
		self:AnimateIconOut(self.Gear1Text)
	elseif previousWeapon.slot == 3 and self.hasLargeGear then
		self:AnimateIconOut(self.Special2Image)
		self:AnimateIconOut(self.largeGear)
		self:AnimateIconOut(self.largeGearText)
	elseif previousWeapon.slot == 3 and not self.hasLargeGear then
		self:AnimateIconOut(self.Special2Image)
		self:AnimateIconOut(self.largeGear)
		self:AnimateIconOut(self.largeGearText)
	elseif previousWeapon.slot == 4 and not self.hasLargeGear then
		self:AnimateIconOut(self.Special3Image)
		self:AnimateIconOut(self.Gear3)
		self:AnimateIconOut(self.Gear3Text)
	end
	if(newWeapon.slot == 0) then
		self:AnimateIconIn(self.PrimaryImage)
		self:AnimateIconIn(self.PrimaryIcon)
		self:AnimateIconIn(self.PrimaryText)
	elseif newWeapon.slot == 1 then
		self:AnimateIconIn(self.SecondaryImage)
		self:AnimateIconIn(self.SecondaryIcon)
		self:AnimateIconIn(self.SecondaryText)
	elseif newWeapon.slot == 2 then
		self:AnimateIconIn(self.Special1Image)
		self:AnimateIconIn(self.Gear1)
		self:AnimateIconIn(self.Gear1Text)
	elseif newWeapon.slot == 3 and self.hasLargeGear then
		self:AnimateIconIn(self.Special2Image)
		self:AnimateIconIn(self.largeGear)
		self:AnimateIconIn(self.largeGearText)
	elseif newWeapon.slot == 3 and not self.hasLargeGear then
		self:AnimateIconIn(self.Special2Image)
		self:AnimateIconIn(self.largeGear)
		self:AnimateIconIn(self.largeGearText)
	elseif newWeapon.slot == 4 and not self.hasLargeGear then
		self:AnimateIconIn(self.Special3Image)
		self:AnimateIconIn(self.Gear3)
		self:AnimateIconIn(self.Gear3Text)
	end

end
function HalfLife2Hud:AnimateIconIn(icon)
	icon.CrossFadeAlpha(1, self.fadeInSpeed, true)
end
function HalfLife2Hud:AnimateIconOut(icon)
	icon.CrossFadeAlpha(0, self.fadeOutSpeed, true)

end
function HalfLife2Hud:AnimateGearIconIn(gearicon)
	gearicon.CrossFadeAlpha(1,self.gearFadeInAndOutSpeed,true)
end
function HalfLife2Hud:AnimateGearIconOut(gearicon)
	gearicon.CrossFadeAlpha(0,self.gearFadeInAndOutSpeed,true)
end
-- ValueMonitors
-- function HalfLife2Hud:MonitorSpareAmmo()
-- 	return Player.actor.activeWeapon.spareAmmo
-- end
-- function HalfLife2Hud:MonitorActiveWeapon()
-- 	return Player.actor.activeWeapon
-- end
-- function HalfLife2Hud:MonitorCurrentAmmo()
-- 	return Player.actor.activeWeapon.ammo
-- end
-- function HalfLife2Hud:MonitorHealth()
-- 	return Player.actor.health
-- end

-- OnValueChange Events

-- function HalfLife2Hud:OnActiveWeaponChange(newWeapon)
-- 	if newWeapon ~= nil then
-- 		print("Player equipped "..newWeapon.weaponEntry.name)
-- 	else
-- 		print("Player weapon was removed")
-- 	end
-- end
-- function HalfLife2Hud:OnAmmoChange(ammoCount)

-- end
-- function HalfLife2Hud:OnSpareAmmoChange(spareAmmo)

-- end
-- function HalfLife2Hud:OnHealthChange(newHealth)

-- end
