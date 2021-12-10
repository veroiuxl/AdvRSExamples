-- Register the behaviour
behaviour("Tester")

function Tester:Start()
 self.lc = GameObject.Find("LoadoutChangeScript(Clone)")
 self.playingWithlc = false
 self.behaviourLc = nil
 if(self.lc) then
	print("Got LoadoutChangerScript")
	self.playingWithlc = true
	self.behaviourLc = ScriptedBehaviour.GetScript(self.lc)
 else
	print("Not running LoadoutChangerScript")
 end
	
end
function Tester:RemoveFromList(resupplyCr)
return function()
coroutine.yield(WaitForSeconds(4))
self.behaviourLc:RemoveResupplyCrate(resupplyCr)
print("Removed it")
end
end
function Tester:Update()
	if Input.GetKeyBindButtonDown(KeyBinds.Use) then
			local ray = Ray(PlayerCamera.activeCamera.main.transform.position + PlayerCamera.activeCamera.main.transform.forward * 1, PlayerCamera.activeCamera.main.transform.forward)
			local raycast = Physics.Raycast(ray,7, RaycastTarget.Default)
			if(raycast ~= nil ) then
				local objec = GameObject.Instantiate(self.targets.resupplyC)
				self.behaviourLc:AddResupplyCrate(objec)
				objec.transform.position = raycast.point
				self.script.StartCoroutine(self:RemoveFromList(objec))

			end


	end
	
end
