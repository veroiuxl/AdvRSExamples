-- Register the behaviour
behaviour("HL2Crosshair")

function HL2Crosshair:Start()
	-- Find the crosshair transform
	self.crosshairTransform = self.targets.crosshairParent.GetComponent(RectTransform)
	self.isEnabled = true
end
function HL2Crosshair:OnDisable()
	self.isEnabled = false
end
function HL2Crosshair:OnEnable()
	self.isEnabled = true
end
function HL2Crosshair:Update()
	if(self.isEnabled) then
	local activeWeapon = Player.actor.activeWeapon;

	if activeWeapon == nil then
		-- Disable the crosshair if no weapon is equipped or the player is not in first person mode
		self.targets.crosshairParent.SetActive(false)
		return
	end

	-- Some weapons have sub weapons such as underslung grenade launchers. Get the active sub weapon.
	activeWeapon = activeWeapon.activeSubWeapon

	local muzzleTransform = activeWeapon.currentMuzzleTransform

	-- Only draw the crosshair when the weapon is ready to fire
	local enabled = muzzleTransform ~= nil and not activeWeapon.isReloading and activeWeapon.isUnholstered and not activeWeapon.isAiming and not Player.actor.isSprinting and not Player.actor.isFallenOver and not Player.actor.isOnLadder and not Player.actor.isInWater
	self.targets.crosshairParent.SetActive(enabled)

	if not enabled then
		return;
	end

	local ray = Ray(muzzleTransform.position, muzzleTransform.forward)
	local target = RaycastTarget.ProjectileHit
	local distance = 1000
	local hit = Physics.Raycast(ray, distance, target)

	if hit ~= nil then
		distance = hit.distance
	end

	-- Position the crosshair so it on the point 1000 meters ahead of the muzzle.
	local aimPoint = ray.origin + ray.direction * distance

	local screenPoint = PlayerCamera.activeCamera.WorldToScreenPoint(aimPoint)
	-- Set screen point depth to 0, if it is too high it will be culled.
	screenPoint.z = 0

	-- Calculate the crosshair size based on the current weapon spread angle and the player camera FOV.
	local fovRatio = (activeWeapon.currentSpreadMaxAngleRadians * Mathf.Rad2Deg) / PlayerCamera.activeCamera.fieldOfView
	local size = Mathf.Max(4, fovRatio * Screen.height)

	-- Assign the point and size to the transform.
	self.crosshairTransform.position = screenPoint
	self.crosshairTransform.sizeDelta = Vector2(size, size)
end
end