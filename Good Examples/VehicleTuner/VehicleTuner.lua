-- Register the behaviour
behaviour("VehicleTuner")

function VehicleTuner:Start()
	self.canvas = self.targets.canvas.GetComponent(Canvas)
	self.canvas.enabled = false
	self.keybinds = { "backspace","delete","tab","clear","return","pause","escape","space","up","down","right","left","insert","home","end","pageup","pagedown","f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","0","1","2","3","4","5","6","7","8","9","!","\"","#","$","&","'","(",")","*","+",",","-",".","/",":",";","<","=",">","?","@","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","numlock","capslock","scrolllock","rightshift","leftshift","rightctrl","leftctrl","rightalt","leftalt"}
	self.defaultKeybind = KeyCode.J
	self:GetCustomKeybind()
	self:InitVehicleTargets()
	self.currentVehicleText = self.targets.currentVehicleText.GetComponent(Text)
	self.currentVehicleTextShadow = self.targets.currentVehicleTextShadow.GetComponent(Text)
	self.maxSliderAmount = self.script.mutator.GetConfigurationInt("maxSliderAmount")
	self.pauseGameWhenTuning = self.script.mutator.GetConfigurationBool("pauseGameWhenEditing")
	self.carScroll = self.targets.carScroll
	self.helicopterScroll = self.targets.helicopterScroll
	self.airScroll = self.targets.airScroll
	self.boatScroll = self.targets.boatScroll
	self.lastVehicle = nil
	self.currentVeComp = nil
	self.timescaleBeforeFreeze = nil
	self.script.AddValueMonitor("MonitorActiveVehicle", "OnActiveVehicle");
end

function VehicleTuner:MonitorActiveVehicle()
    return Player.actor.activeVehicle
end

function VehicleTuner:OnActiveVehicle(newVehicle)
	if newVehicle ~= nil then
		if(self.lastVehicle ~= newVehicle) then
			self:ChangeScroll()
			print("New/Different Vehicle!")
		end
		self.lastVehicle = newVehicle
    else
		self.canvas.enabled = false
		Screen.LockCursor()
    end
end

function VehicleTuner:Update()
	if(Player.actor ~= nil) then
		if(Input.GetKeyDown(self.defaultKeybind)) then
			if(Player.actor.activeVehicle ~= nil) then
				self.canvas.enabled = not self.canvas.enabled
				if(self.canvas.enabled) then
					if(self:HasVehicleStats()) then
						print("Refreshing vehicle health")
						self:RefreshVehicleHealth()
					end
					if(self.pauseGameWhenTuning) then
						if(Time.timeScale ~= 0.002) then
							self.timescaleBeforeFreeze = Time.timeScale
							Time.timeScale = 0.002
						end
					end
					Screen.UnlockCursor()
				else
					if(self.pauseGameWhenTuning) then
						Time.timeScale = self.timescaleBeforeFreeze
					end
					
					Screen.LockCursor()
				end
			end
		end
	end
	if(self.pauseGameWhenTuning and self.canvas.enabled) then
		Time.timeScale = 0.002
	end
end


function VehicleTuner:RefreshVehicleHealth()
	if(Player.actor.activeVehicle ~= nil) then
		local activeVehicle = Player.actor.activeVehicle
		if(activeVehicle.isCar) then
			self:SetTextAndValueForVehicleVar(self.car.health,1000, activeVehicle.health)
			self:SetTextAndValueForVehicleVar(self.car.maxHealth,1000, activeVehicle.maxHealth)
		elseif(activeVehicle.isHelicopter) then
			self:SetTextAndValueForVehicleVar(self.heli.health,1000, activeVehicle.health)
			self:SetTextAndValueForVehicleVar(self.heli.maxHealth,1000, activeVehicle.maxHealth)
		elseif(activeVehicle.isAirplane) then
			self:SetTextAndValueForVehicleVar(self.airPlane.health,1000, activeVehicle.health)
			self:SetTextAndValueForVehicleVar(self.airPlane.maxHealth,1000, activeVehicle.maxHealth)
		elseif(activeVehicle.isBoat) then
			self:SetTextAndValueForVehicleVar(self.boat.health,1000, activeVehicle.health)
			self:SetTextAndValueForVehicleVar(self.boat.maxHealth,1000, activeVehicle.maxHealth)
		end
	end
end
function VehicleTuner:HasVehicleStats()
	if(Player.actor.activeVehicle ~= nil) then
		local activeVehicle = Player.actor.activeVehicle
		if(activeVehicle.isCar) then
			if(self.currentCarStats == nil) then
				return false
			end
		elseif(activeVehicle.isHelicopter) then
			if(self.currentHeliStats == nil) then
				return false
			end
		elseif(activeVehicle.isAirplane) then
			if(self.currentAirPlaneStats == nil) then
				return false
			end
		elseif(activeVehicle.isBoat) then
			if(self.currentBoatStats == nil) then
				return false
			end
		end
		return true
	end
end
function VehicleTuner:ChangeScroll()
	if(Player.actor.activeVehicle ~= nil) then
		local activeVehicle = Player.actor.activeVehicle
		if(activeVehicle.isCar) then
			local car = activeVehicle.gameObject.GetComponent(Car)
			self.currentVeComp = car
			self:SetArrayForCurrentCar(car)
			self.script.StartCoroutine(self:RefreshStats("Car"))
			self:SetCurrentVehicleText("Car/Tank",activeVehicle.name,"green")
			self.carScroll.gameObject.SetActive(true)
			self.helicopterScroll.gameObject.SetActive(false)
			self.airScroll.gameObject.SetActive(false)
			self.boatScroll.gameObject.SetActive(false)
			return
		elseif(activeVehicle.isHelicopter) then
			local heli = activeVehicle.gameObject.GetComponent(Helicopter)
			self.currentVeComp = heli
			self:SetArrayForCurrentHeli(heli)
			self.script.StartCoroutine(self:RefreshStats("Helicopter"))
			self:SetCurrentVehicleText("Helicopter",activeVehicle.name,"#3266a8")
			self.carScroll.gameObject.SetActive(false)
			self.helicopterScroll.gameObject.SetActive(true)
			self.airScroll.gameObject.SetActive(false)
			self.boatScroll.gameObject.SetActive(false)
		elseif(activeVehicle.isAirplane) then
			local airPlane = activeVehicle.gameObject.GetComponent(Airplane)
			self.currentVeComp = airPlane
			self:SetArrayForCurrentAirPlane(airPlane)
			self.script.StartCoroutine(self:RefreshStats("AirPlane"))
			self:SetCurrentVehicleText("Airplane",activeVehicle.name,"#fcc603")
			self.carScroll.gameObject.SetActive(false)
			self.helicopterScroll.gameObject.SetActive(false)
			self.airScroll.gameObject.SetActive(true)
			self.boatScroll.gameObject.SetActive(false)
		elseif(activeVehicle.isBoat) then
			local boat = activeVehicle.gameObject.GetComponent(Boat)
			self.currentVeComp = boat
			self:SetArrayForCurrentBoat(boat)
			self.script.StartCoroutine(self:RefreshStats("Boat"))
			self:SetCurrentVehicleText("Boat",activeVehicle.name,"#166efa")
			self.carScroll.gameObject.SetActive(false)
			self.helicopterScroll.gameObject.SetActive(false)
			self.airScroll.gameObject.SetActive(false)
			self.boatScroll.gameObject.SetActive(true)
		end 
	end
end
function VehicleTuner:split(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end
function VehicleTuner:round(exact)
		return tonumber(string.format("%.3f", exact)) -- Unprecise?
end
function VehicleTuner:AddSliderListener(slider,text,statIndex)
	slider.onValueChanged.AddListener(self,"SliderChangeListener",{text,statIndex})
end
function VehicleTuner:SliderChangeListener(newValue)
	local data = CurrentEvent.listenerData
	if(data == nil) then
		print("<color=yellow>SliderChangeListener data was nil?</color>")
		return
	end
	local textForValue = data[1]
	local stat = data[2]
	local split = self:split(textForValue.text,":")
	textForValue.text = split[1]..": "..tostring(self:round(newValue,3))
	
	-- print("Set " .. tostring(stat) .. " in Listener to " .. tostring(newValue))
	self.currentVeComp[stat] = newValue
end
function VehicleTuner:RefreshStats(string)
	return function()
		local vehicleStatsType
		local currentVehicleStats
		if(string == "Car") then
			vehicleStatsType = self.car
			currentVehicleStats = self.currentCarStats
		elseif(string == "Helicopter") then
			vehicleStatsType = self.heli
			currentVehicleStats = self.currentHeliStats
		elseif(string == "AirPlane") then
			vehicleStatsType = self.airPlane
			currentVehicleStats = self.currentAirPlaneStats
		elseif(string == "Boat") then
			vehicleStatsType = self.boat
			currentVehicleStats = self.currentBoatStats
		end	
		for i,y in pairs(vehicleStatsType) do
			local currentStat = currentVehicleStats[i]
			local slider,text = self:RetSetTextAndValueForVehicleVar(y,self.maxSliderAmount,currentStat)
			self:AddSliderListener(slider,text,i)
			coroutine.yield(WaitForSeconds(0.01))
		end
	end
end
function VehicleTuner:SetTextAndValueForVehicleVar(vehicleVar,maxValueAdd,value)

	local sliderForValue = self:GetSliderOfVehicleVar(vehicleVar)
	sliderForValue.maxValue = tonumber(value) + maxValueAdd
	sliderForValue.value = tonumber(value)
	sliderForValue.minValue = 0
	local textForValue = self:GetTextOfVehicleVar(vehicleVar)
	local split = self:split(textForValue.text,":") -- performance heavy
	textForValue.text = split[1]..": "..tostring(self:round(value,3))

end
function VehicleTuner:RetSetTextAndValueForVehicleVar(vehicleVar,maxValueAdd,value)

	local sliderForValue = self:GetSliderOfVehicleVar(vehicleVar)
	sliderForValue.maxValue = tonumber(value) + maxValueAdd
	sliderForValue.value = tonumber(value)
	sliderForValue.minValue = 0
	local textForValue = self:GetTextOfVehicleVar(vehicleVar)
	local split = self:split(textForValue.text,":") -- performance heavy
	textForValue.text = split[1]..": "..tostring(self:round(value,3))
	return sliderForValue,textForValue

end
function VehicleTuner:SetArrayForCurrentCar(vehicle)
	self.currentCarStats = {
		acceleration = vehicle.acceleration,
		accelerationTipAmount = vehicle.accelerationTipAmount,
		airAngularDrag = vehicle.airAngularDrag,
		airDrag = vehicle.airDrag,
		baseTurnTorque = vehicle.baseTurnTorque,
		brakeAccelerationTriggerSpeed = vehicle.brakeAccelerationTriggerSpeed,
		brakeDrag = vehicle.brakeDrag,
		brakeDriftMinSpeed = vehicle.brakeDriftMinSpeed,
		downforcePerSpeed = vehicle.downforcePerSpeed,
		driftDuration = vehicle.driftDuration,
		driftingSlip = vehicle.driftingSlip,
		extraStability = vehicle.extraStability,
		frictionTipAmount = vehicle.frictionTipAmount,
		groundAngularDrag = vehicle.groundAngularDrag,
		groundDrag = vehicle.groundDrag,
		groundSteeringDrag = vehicle.groundSteeringDrag,
		health = vehicle.health,
		maxHealth = vehicle.maxHealth,
		reverseAcceleration = vehicle.reverseAcceleration,
		slideDrag = vehicle.slideDrag,
		topSpeed = vehicle.topSpeed
	}
-- for i,y in pairs(self.currentCarStats) do
-- 	local sliderForValue = self:GetSliderOfVehicleVar(self.car[i])
-- 	print("Index " .. tostring(i) .. ": " .. y .. " -> Slider value " .. tostring(sliderForValue.value))
-- end
end
function VehicleTuner:SetArrayForCurrentHeli(vehicle)
	self.currentHeliStats = {
		health = vehicle.health,
		maxHealth = vehicle.maxHealth,
		manouverability = vehicle.manouverability,
		rotorForce = vehicle.rotorForce
}
end
function VehicleTuner:SetArrayForCurrentAirPlane(vehicle)
	self.currentAirPlaneStats = {
		health = vehicle.health,
		maxHealth = vehicle.maxHealth,
		acceleration = vehicle.acceleration,
		accelerationThrottleDown = vehicle.accelerationThrottleDown,
		accelerationThrottleUp = vehicle.accelerationThrottleUp,
		autoPitchTorqueGain = vehicle.autoPitchTorqueGain,
		baseLift = vehicle.baseLift,
		controlWhenBurning = vehicle.controlWhenBurning,
		liftGainTime = vehicle.liftGainTime,
		perpendicularDrag = vehicle.perpendicularDrag,
		pitchSensitivity = vehicle.pitchSensitivity,
		rollSensitivity = vehicle.rollSensitivity,
		yawSensitivity = vehicle.yawSensitivity
}
end
function VehicleTuner:SetArrayForCurrentBoat(vehicle)
	self.currentBoatStats = {
		health = vehicle.health,
		maxHealth = vehicle.maxHealth,
		speed = vehicle.speed,
		stability = vehicle.stability,
		turnSpeed = vehicle.turnSpeed,
		floatAcceleration = vehicle.floatAcceleration,
		floatDepth = vehicle.floatDepth,
		reverseMultiplier = vehicle.reverseMultiplier,
		sinkingFloatAcceleration = vehicle.sinkingFloatAcceleration,
		sinkingMaxTorque = vehicle.sinkingMaxTorque
}
end
function VehicleTuner:GetSliderOfVehicleVar(vehicleVar)
	return vehicleVar.gameObject.transform.GetChild(1).gameObject.GetComponent(Slider)
end
function VehicleTuner:GetTextOfVehicleVar(vehicleVar)
	return vehicleVar.gameObject.transform.GetChild(0).gameObject.GetComponent(Text)
end
function VehicleTuner:SetCurrentVehicleText(type,vehicleName,colorHex)
	self.currentVehicleTextShadow.text = type .. ": <i>" .. vehicleName.. "</i>" 
	self.currentVehicleText.text = string.format("<color=%s>%s:</color> <i>%s</i>",colorHex,type,vehicleName)
end
function VehicleTuner:GetCustomKeybind()
	local customKeybind = self:GetKeyCodeFromString(self.script.mutator.GetConfigurationString("customKeybind"):lower())
	print(customKeybind)
	if(customKeybind ~= self.defaultKeybind) then
		print("Using custom key " .. customKeybind)
		self.defaultKeybind = customKeybind
	end
end
function VehicleTuner:GetKeyCodeFromString(string)

	for i,y in ipairs(self.keybinds) do
		if(y == string) then
			return string
		end
	end
	return self.defaultKeybind
end

function VehicleTuner:InitVehicleTargets()
	self.car = {
		acceleration = self.targets.carAcceleration,
		accelerationTipAmount =  self.targets.caraccelerationTipAmount,
		airAngularDrag =  self.targets.carairAngularDrag,
		airDrag = self.targets.carairDrag,
		baseTurnTorque =  self.targets.carbaseTurnTorque,
		brakeAccelerationTriggerSpeed =  self.targets.carbrakeAccelerationTriggerSpeed,
		brakeDrag =  self.targets.carbrakeDrag,
		brakeDriftMinSpeed = self.targets.carbrakeDriftMinSpeed,
		downforcePerSpeed =  self.targets.cardownforcePerSpeed,
		driftDuration =  self.targets.cardriftDuration,
		driftingSlip =  self.targets.cardriftingSlip,
		extraStability =  self.targets.carextraStability,
		frictionTipAmount =  self.targets.carfrictionTipAmount,
		groundAngularDrag =  self.targets.cargroundAngularDrag,
		groundDrag =  self.targets.cargroundDrag,
		groundSteeringDrag =  self.targets.cargroundSteeringDrag,
		health =  self.targets.carHealth,
		maxHealth =  self.targets.carmaxHealth,
		reverseAcceleration =  self.targets.carreverseAcceleration,
		slideDrag =  self.targets.carslideDrag,
		topSpeed =  self.targets.carTopspeed
}
	self.heli = {
		health = self.targets.helihealth,
		maxHealth = self.targets.helimaxHealth,
		manouverability = self.targets.helimanouverability,
		rotorForce = self.targets.helirotorForce
}
	self.airPlane = {
		health = self.targets.airhealth,
		maxHealth = self.targets.airmaxHealth,
		acceleration = self.targets.airacceleration,
		accelerationThrottleDown = self.targets.airaccelerationThrottleDown,
		accelerationThrottleUp = self.targets.airaccelerationThrottleUp,
		autoPitchTorqueGain = self.targets.airautoPitchTorqueGain,
		baseLift = self.targets.airbaseLift,
		controlWhenBurning = self.targets.aircontrolWhenBurning,
		liftGainTime = self.targets.airliftGainTime,
		perpendicularDrag = self.targets.airperpendicularDrag,
		pitchSensitivity = self.targets.airpitchSensitivity,
		rollSensitivity = self.targets.airrollSensitivity,
		yawSensitivity = self.targets.airyawSensitivity
}	
	self.boat = {
		health = self.targets.boathealth,
		maxHealth = self.targets.boatmaxHealth,
		speed = self.targets.boatspeed,
		stability = self.targets.boatStability,
		turnSpeed = self.targets.boatturnSpeed,
		floatAcceleration = self.targets.boatfloatAcceleration,
		floatDepth = self.targets.boatfloatDepth,
		reverseMultiplier = self.targets.boatreverseMultiplier,
		sinkingFloatAcceleration = self.targets.boatsinkingFloatAcceleration,
		sinkingMaxTorque = self.targets.boatsinkingMaxTorque
}	

end
