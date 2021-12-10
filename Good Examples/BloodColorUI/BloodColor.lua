-- Register the behaviour
behaviour("BloodColor")
function BloodColor:Start()

self.blueSplat = GameObject.Find("Blue Splat Decal Drawer")
self.redSplat = GameObject.Find("Red Splat Decal Drawer")
self.already = false
if self.script.mutator.GetConfigurationBool("disableBlood") then
	GameEvents.onActorSelectedLoadout.AddListener(self,"onActorSelectedLoadout")
-- self:SetBlueColor(Color(0,0,0,0))
-- self:SetRedColor(Color(0,0,0,0))

print("Disabled blood")
return
end

if self.blueSplat == nil then
print("<color=red>Couldn't find Decal Drawer</color>")
Overlay.ShowMessage("<color=red>Couldn't find Decal Drawer</color>")
	return
end
if self.redSplat == nil then
print("<color=red>Couldn't find Decal Drawer</color>")
Overlay.ShowMessage("<color=red>Couldn't find Decal Drawer</color>")
	return
end
-- if self.script.mutator.GetConfigurationBool("useHexColor") then
-- local bluehex = self.script.mutator.GetConfigurationString("hexColorBlue")
-- local redhex = self.script.mutator.GetConfigurationString("hexColorRed")
-- if not self:stringstartswith(bluehex) then
-- print("<color=red>The hex color for Eagle didn't start with #!</color>")
-- Overlay.ShowMessage("<color=red>The hex color for Eagle didn't start with #!</color>")
-- return
-- end
-- if not self:stringstartswith(redhex) then
-- print("<color=red>The hex color for Eagle didn't start with #!</color>")
-- Overlay.ShowMessage("<color=red>The hex color for Eagle didn't start with #!</color>")
-- return
-- end
-- local values = self:hex2rgb("#ff008c")
-- print(tostring(values[1]))
-- local hexToRgbEagle = self:hex2rgb(tostring(bluehex))
-- local hexToRgbRaven = self:hex2rgb(tostring(redehex))

-- self:SetBlueColor(Color(hexToRgbEagle[1] / 255,hexToRgbEagle[2] / 255,hexToRgbEagle[3] / 255))
-- self:SetRedColor(Color(hexToRgbRaven[1] / 255,hexToRgbRaven[2] / 255,hexToRgbRaven[3] / 255))
-- print("Set color " .. tostring(Color(hexToRgbEagle[1] / 255,hexToRgbEagle[2] / 255,hexToRgbEagle[3] / 255).ToString()))
-- print("Set color" .. tostring(Color(hexToRgbRaven[1] / 255,hexToRgbRaven[2] / 255,hexToRgbRaven[3] / 255).ToString()))
-- else

self.colorBlue = Color(self.script.mutator.GetConfigurationRange("rSliderEagle") / 255,self.script.mutator.GetConfigurationRange("gSliderEagle") / 255,self.script.mutator.GetConfigurationRange("bSliderEagle") / 255,self.script.mutator.GetConfigurationRange("aSliderEagle") / 255)
self.colorRed = Color(self.script.mutator.GetConfigurationRange("rSliderRaven") / 255,self.script.mutator.GetConfigurationRange("gSliderRaven") / 255,self.script.mutator.GetConfigurationRange("bSliderRaven") / 255,self.script.mutator.GetConfigurationRange("aSliderRaven") / 255)
if(self.script.mutator.GetConfigurationBool("usePresets")) then
local preset = self.script.mutator.GetConfigurationDropdown("preset") 
if(preset == 0) then
	self.colorBlue = Color(65 / 255,13 / 255,9 / 255)
	self.colorRed = Color(65 / 255,13 / 255,9 / 255)
else if preset == 1 then
	self.colorBlue = Color(99 / 255,16 / 255,23 / 255)
	self.colorRed = Color(99 / 255,16 / 255,23 / 255)
end
end

end
if(self.script.mutator.GetConfigurationBool("hexColorEnabled")) then
	if(self:stringstartswith(self.script.mutator.GetConfigurationString("hexValueEagle"))) then
		local inputHex = self.script.mutator.GetConfigurationString("hexValueEagle")
		local hexRGBRed = self:hex2rgb(inputHex)
		print("Using Hex color for Eagle")
		self.colorBlue = Color(hexRGBRed[1] ,hexRGBRed[2],hexRGBRed[3],1)
	end
	if(self:stringstartswith(self.script.mutator.GetConfigurationString("hexValueRaven"))) then
		local inputHex = self.script.mutator.GetConfigurationString("hexValueRaven")
		local hexRGBBlue = self:hex2rgb(inputHex)
		print("Using Hex color for Raven")
		self.colorRed = Color(hexRGBBlue[1] ,hexRGBBlue[2],hexRGBBlue[3],1)
	end
end
self:SetBlueColor(self.colorBlue)
self:SetRedColor(self.colorRed)

-- end

end
function BloodColor:ClearDecals()
	
	coroutine.yield(WaitForSeconds(4))
	for i,y in ipairs(GameObject.FindObjectsOfType(Mesh)) do
		if string.find(y.name,"Blood") then
			print("Clearing " .. y.name)
			GameObject.Destroy(y)
		end
	end
	self.already = true


end
function BloodColor:hex2rgb(hex)
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
	print(string.format("R %s G %s B %s",r,g,b))
	return {r,g,b}
end
function BloodColor:onActorSelectedLoadout(actor,loadoutse,loadoutstrat)
if not actor.isBot then
if self.already == false then 
self.script.StartCoroutine("ClearDecals")
end
end
end
function BloodColor:stringstartswith(str)
	return str:sub(1, 1) == "#"
 end
 
function BloodColor:SetBlueColor(color)
	if self.blueSplat ~= nil then
		self.blueSplat.GetComponent(Renderer).material.SetColor("_Color", color)
	else
		print("<color=red>blueSplat not found!</color>")
	end

end

function BloodColor:SetRedColor(color)
	if self.redSplat ~= nil then
	   self.redSplat.GetComponent(Renderer).material.SetColor("_Color", color)
	else
		print("<color=red>redSplat not found!</color>")
	end
end
-- function BloodColor:hex2rgb(hex)
--     local hex2 = hex:gsub("#","")
-- 	local returnTa = {}
-- 	print(tostring(hex2))
-- 	print("R" .. tonumber(hex2:sub(1,2)))
-- 	print("G" .. tonumber(hex2:sub(3,4)))
-- 	print("B" .. tonumber(hex2:sub(5,6)))
--     table.insert(returnTa,tonumber("0x"..hex2:sub(1,2)))
--     table.insert(returnTa,tonumber("0x"..hex2:sub(3,4)))
--     table.insert(returnTa,tonumber("0x"..hex2:sub(5,6)))
--     return returnTa
-- end


function BloodColor:Update()

--	self.bloodDrop = GameObject.FindGameObjectsWithTag("No Destroy")
	-- self.bloodDrop = GameObject.FindObjectsOfType(GameObject)
	-- for i,y in ipairs(self.bloodDrop) do

	-- 	if y.name == "Blood Drop(Clone)" then
	-- 		print("Tag " .. y.tag)
	-- 	if y.gameObject.GetComponent(Renderer) ~= nil then
	-- 	if y.gameObject.GetComponent(Renderer).material.color == Color.blue then
	-- 	y.gameObject.GetComponent(Renderer).material.color = self.colorBlue
	-- 	else
	-- 	y.gameObject.GetComponent(Renderer).material.color = self.colorRed
	-- 	end
	-- end
	-- end
	-- end
end
