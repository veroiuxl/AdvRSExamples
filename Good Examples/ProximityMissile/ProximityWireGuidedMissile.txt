-- Register the behaviour
behaviour("ProximityWireGuidedMissile")
function ProximityWireGuidedMissile:Start()
	self.dataContainer = self.targets.dataContainer
	self.proximityRange = self.dataContainer.GetInt("proximityRange")
	self.proximityRangeDetection = self.proximityRange + 20
	self.projectile = self.gameObject.GetComponent(Projectile)
	self.currentUser = self.projectile.source
	self.rocketObstacle = self.targets.rocketObstacle
	self.hasTarget = false
	print("Launched rocket")
	if(self.currentUser.isBot) then
		self.hasTarget = true
	end
end
function ProximityWireGuidedMissile:GetClosestVehicle(vehiclesArray) 
	local bestTarget = null;
	local closestDistanceSqr = Mathf.Infinity;
	local currentPosition =self.gameObject.transform.position
	for i,potentialTarget in ipairs(ActorsInRange) do
		local directionToTarget = potentialTarget.transform.position - currentPosition
		local dSqrToTarget = directionToTarget.sqrMagnitude
			if dSqrToTarget < closestDistanceSqr then
				closestDistanceSqr = dSqrToTarget;
				bestTarget = potentialTarget;
			end
	end
	return bestTarget
end
function ProximityWireGuidedMissile:Update()
	if(self.hasTarget or Player.actor.activeVehicle == nil) then
		return
	end

		
	for i,y in ipairs(ActorManager.vehicles) do
	if(Player.actor.activeVehicle ~= y) then
		local directionToTarget = y.transform.position - self.gameObject.transform.position
		if(directionToTarget.magnitude < self.proximityRangeDetection) then
			local lineCast = Physics.Linecast(self.gameObject.transform.position, y.transform.position, RaycastTarget.ProjectileHit)
			if(lineCast ~= nil) then
				local directionToTarget2 = lineCast.transform.position - self.gameObject.transform.position
				if(directionToTarget2.magnitude < self.proximityRange) then
					self.script.StartCoroutine("DestoryItself")
				end
			end
		end
	end
	end
end
function ProximityWireGuidedMissile:DestoryItself()
	self.rocketObstacle.gameObject.SetActive(true)
	self.hasTarget = true
end
