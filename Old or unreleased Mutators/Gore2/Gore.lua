-- Register the behaviour
behaviour("Gore")
-- TODO: Blood Particles
function Gore:Start()
	self.actorGoreCount = {}
	for i,y in ipairs(ActorManager.actors) do
		table.insert(self.actorGoreCount, {y,0})
		y.onTakeDamage.AddListener(self,"onTakeDamage")
	end
	self.keepList = {}
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	self.despawnDelay = self.script.mutator.GetConfigurationRange("despawnTime")
	self.maxSeperatableLimbs = self.script.mutator.GetConfigurationRange("maxSeperatableLimbs") - 1
	self.leftlegPath = "Armature/Bone/Leg.L/Leg.L_001"
	self.rightlegPath = "Armature/Bone/Leg.R/Leg.R_001"
	self.leftarmPath = "Armature/Bone/Bone.001/Bone.002/Shoulder.L/Arm.L.001"
	self.rightarmPath = "Armature/Bone/Bone.001/Bone.002/Shoulder.R/Arm.R.001"
	-- self.headPath = "Armature/Bone/Bone_001/Bone_002/Bone_003/Bone_004" -- I sure hope steel won't update the bones (he did)
	self.headPath = "Armature/Bone/Bone.001/Bone.002/Bone.003/Bone.004" -- For Unity 2020
end
function Gore:onActorSpawn(actor)

if(actor.isBot ) then
	if(self.actorGoreCount[self:tablefindInTable(self.actorGoreCount,actor)][2] > 0) then
	local revertBone
	self.actorGoreCount[self:tablefindInTable(self.actorGoreCount,actor)][2] = 0
	-- print(actor.aiController.gameObject.transform.GetChild(0).Find(self.leftlegPath).gameObject.name)
	revertBone = actor.aiController.gameObject.transform.GetChild(0).Find(self.leftlegPath) 
	revertBone.transform.localScale = Vector3(1,1,1)
	revertBone = actor.aiController.gameObject.transform.GetChild(0).Find(self.rightlegPath) 
	revertBone.transform.localScale = Vector3(1,1,1)
	revertBone = actor.aiController.gameObject.transform.GetChild(0).Find(self.headPath) 
	revertBone.transform.localScale = Vector3(1,1,1)
	revertBone = actor.aiController.gameObject.transform.GetChild(0).Find(self.leftarmPath) 
	revertBone.transform.localScale = Vector3(1,1,1)
	revertBone = actor.aiController.gameObject.transform.GetChild(0).Find(self.rightarmPath) 
	revertBone.transform.localScale = Vector3(1,1,1)
	-- actor.SetRagdollJointDrive(0, 10)
	end
end
end
function Gore:tablefindInTable(tab,el)
    for index, value in pairs(tab) do
        if value[1] == el then
            return index
        end
    end
end
function Gore:DestroyWithDelaySimple(gameObject,delay)
	return function()
		coroutine.yield(WaitForSeconds(delay))
		if gameObject == nil then
			return
		end
		GameObject.Destroy(gameObject)
	end
end
function Gore:ContainsName(tab,object)
	local returnV = false
	for i,v in pairs(tab) do
		if(v == object.gameObject.name) then
			returnV = true
		end
	end
	return returnV
end
function Gore:FindBoneByName(actor,boneName)
local boneTransform

if(actor.isBot) then
	-- This is probably faster than .find
	if(boneName == "Leg.L.001") then
 	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.leftlegPath) 
	elseif boneName == "Leg.R.001" then
	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.rightlegPath) 
	elseif boneName == "Arm.L.001" then
	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.leftarmPath) 
	elseif boneName == "Arm.R.001" then
	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.rightarmPath) 
	elseif boneName == "Bone.004" then
	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.headPath)
	end
end
if(boneTransform == nil) then
	print("<color=red>FineBoneByName returned nil with boneName " .. tostring(boneName) .. "</color>!")
end
return boneTransform
end
function Gore:Contains(tab,object)
local returnV = false
for i,v in pairs(tab) do
	if(v == object) then
		returnV = true
	end
end
return returnV
end
function Gore:SpawnLimb(bone,actor,targetLimbs,targetInstanceObject,head,resizeBone) 
local targetLimb = self:ContainsName(targetLimbs,bone)
if(targetLimb) then
	local actualBoneTransform = self:FindBoneByName(actor,resizeBone)
	if(actualBoneTransform ~= nil) then
		print("Used actualboneTransform " .. tostring(actualBoneTransform.gameObject.name))
		if(head) then
			actualBoneTransform.transform.localScale = Vector3(0,0,-0.2)
		else
			actualBoneTransform.transform.localScale = Vector3(0,0,0)
		end
	else
	print("Used bone because actualBoneTransform was nil")
	if(head) then
		bone.transform.localScale = Vector3(0,0,-0.2)
	else
		bone.transform.localScale = Vector3(0,0,0)
	end
end
local spawnedLimb = GameObject.Instantiate(targetInstanceObject)
if(head) then
	spawnedLimb.transform.position = bone.transform.position
	spawnedLimb.transform.rotation = actor.transform.rotation
else
	spawnedLimb.transform.position = bone.transform.position
	spawnedLimb.transform.rotation = bone.transform.rotation
end
spawnedLimb.GetComponent(Rigidbody).velocity = actor.velocity

print("Spawned on " .. tostring(bone))
self:SetSkinOfInstanceObject(actor,spawnedLimb,head)
self.script.StartCoroutine(self:ApplyChanges(actor,actualBoneTransform))
self.script.StartCoroutine(self:DestroyWithDelaySimple(spawnedLimb,self.despawnDelay))
-- self.script.StartCoroutine(self:StayLikeThat(actor,bone))
end
end
function Gore:SetSkinOfInstanceObject(actor,object,head)
	local skins = actor.aiController.gameObject.transform.Find("Soldier/Soldier").gameObject.GetComponent(SkinnedMeshRenderer).materials
	local mesh = actor.aiController.gameObject.transform.Find("Soldier/Soldier").gameObject.GetComponent(SkinnedMeshRenderer).sharedMesh;
	if(head) then
		object.gameObject.GetComponentInChildren(SkinnedMeshRenderer).sharedMaterials[1] = skins[1]
		-- object.gameObject.GetComponentInChildren(SkinnedMeshRenderer).sharedMesh = mesh
	else
		object.gameObject.GetComponentInChildren(SkinnedMeshRenderer).materials = skins
		-- object.gameObject.GetComponentInChildren(SkinnedMeshRenderer).sharedMesh = mesh
	end
end
function Gore:ApplyChanges(actor,bone)
return function()
	local isHead = false
	if(bone.gameObject.name == "Bone.004") then
		isHead = true
	end
	if(isHead) then
		bone.transform.localScale = Vector3(0,0,-0.2)
	else
		bone.transform.localScale = Vector3(0,0,0)
	end
	-- table.insert(self.keepList, {actor,bone})
	for i=1,7,1 do
		if(isHead) then
			bone.transform.localScale = Vector3(0,0,-0.2)
		else
			bone.transform.localScale = Vector3(0,0,0)
		end
		coroutine.yield(WaitForSeconds(0.5))
	end
	
	-- table.remove(self.keepList, self:tablefindInTable(self.keepList,actor))
end
end
function Gore:SetDespawnDelay(delay) -- External
	self.despawnDelay = delay
end
function Gore:GetHumanoidTransform(actor,humanBodyBone)
local retV
if(actor.isFallenOver) then
	retV = actor.GetHumanoidTransformRagdoll(humanBodyBone)
	else
	retV = actor.GetHumanoidTransformAnimated(humanBodyBone)
end
return retV
end
function Gore:onTakeDamage(actor,source,info)
if(source == Player.actor and not info.isScripted and actor ~= Player.actor and not CurrentEvent.isConsumed) then
	local chest = self:GetHumanoidTransform(actor,HumanBodyBones.Chest)
	local shoulderRight = self:GetHumanoidTransform(actor,HumanBodyBones.RightShoulder)
	local shoulderLeft = self:GetHumanoidTransform(actor,HumanBodyBones.LeftShoulder)
	local legLeft = self:GetHumanoidTransform(actor,HumanBodyBones.LeftUpperLeg)
	local legRight = self:GetHumanoidTransform(actor,HumanBodyBones.RightUpperLeg)
	local hips = self:GetHumanoidTransform(actor,HumanBodyBones.Hips)

	local hitBannedBone = false
	local ray = Ray(info.point,info.direction)
	local raycast = Physics.Raycast(ray,2,RaycastTarget.ProjectileHit)
	local hitBone 
	if(info.isSplashDamage and info.healthDamage > actor.health) then
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.Head)
		hitBone.transform.localScale = Vector3(0,0,-0.2)
		self:SpawnLimb(hitBone,actor,{"Bone.003","Bone.004"},self.targets.headprefab,true,"Bone.004")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.RightLowerArm) 
		-- hitBone = self:FindBoneByName(actor,"Arm_R_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Arm.R.001","Arm.R.002","Arm.R.003"},self.targets.leftArmprefab,false,"Arm.R.001")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.LeftLowerArm)
		-- hitBone = self:FindBoneByName(actor,"Arm_L_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Arm.L.001","Arm.L.002","Arm.L.003"},self.targets.rightArmprefab,false,"Arm.L.001")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.LeftLowerLeg)
		-- hitBone = self:FindBoneByName(actor,"Leg_L_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Leg.L.001"},self.targets.leftLegprefab,false,"Leg.L.001")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.RightLowerLeg)
		-- hitBone = self:FindBoneByName(actor,"Leg_R_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Leg.R.001"},self.targets.rightLegprefab,false,"Leg.R.001")

	end
	if(raycast ~= nil and raycast.transform.gameObject ~= nil) then
	   hitBone = raycast.transform.gameObject
		if(hitBone.transform == chest 
		-- or hitBone.transform == shoulderLeft
		-- or hitBone.transform == shoulderRight
		-- or hitBone.transform == legLeft
		-- or hitBone.transform == legRight
		or hitBone.transform == hips
		or hitBone.transform.gameObject.name == "Bone"
		or hitBone.transform.gameObject.name == "Bone.001"
		or string.find(hitBone.transform.gameObject.name,"Terrain") -- lazy but it works
		) then
		print("Hit banned bone " .. tostring(hitBone.name))
		hitBannedBone = true
		end
	end
	if(info.healthDamage >= actor.health and not hitBannedBone and hitBone ~= nil) then
		-- print(hitBone.transform.gameObject.name)
		local actorHitCountInTable = self.actorGoreCount[self:tablefindInTable(self.actorGoreCount,actor)][2]
		if(actorHitCountInTable <= self.maxSeperatableLimbs) then
		print("Actor had " .. tostring(actorHitCountInTable) .. " hits already")
		if(hitBone.transform.gameObject.name == "Bone.003" or hitBone.transform.gameObject.name == "Bone.004") then
			self:SpawnLimb(hitBone,actor,{"Bone.003","Bone.004"},self.targets.headprefab,true,"Bone.004")
		end
		if(hitBone.transform.gameObject.name == "Arm.R.001" or hitBone.transform.gameObject.name == "Arm.R.002" or hitBone.transform.gameObject.name == "Arm.R.003" ) then
			self:SpawnLimb(hitBone,actor,{"Arm.R.001","Arm_R_002","Arm.R.003"},self.targets.leftArmprefab,false,"Arm.R.001")
		end
		if(hitBone.transform.gameObject.name == "Arm_L_001" or hitBone.transform.gameObject.name == "Arm.L.002" or hitBone.transform.gameObject.name == "Arm.L.003" ) then
			self:SpawnLimb(hitBone,actor,{"Arm.L.001","Arm.L.002","Arm.L.003"},self.targets.rightArmprefab,false,"Arm.L.001")
		end
		if(hitBone.transform.gameObject.name == "Leg_L_001" or hitBone.transform.gameObject.name == "Leg.L" or hitBone.transform.gameObject.name == "Leg.L.002" ) then
			self:SpawnLimb(hitBone,actor,{"Leg.L.001","Leg.L.002"},self.targets.leftLegprefab,false,"Leg.L.001")
		end
		if(hitBone.transform.gameObject.name == "Leg_R_001" or hitBone.transform.gameObject.name == "Leg.R" or hitBone.transform.gameObject.name == "Leg.R.002") then
			self:SpawnLimb(hitBone,actor,{"Leg.R.001","Leg.R.002"},self.targets.rightLegprefab,false,"Leg.R.001")
		end
		self.actorGoreCount[self:tablefindInTable(self.actorGoreCount,actor)][2] = actorHitCountInTable + 1
		else
		print("No scaling because of " .. tostring(actorHitCountInTable) .. " hits already")
		end
	end
end

end
function Gore:Update()
	-- for i,y in ipairs(self.keepList) do
		-- local bodyBone = self:GetHumanoidTransform(y[1],y[2])
		-- bodyBone.transform.localScale = Vector3(0,0,0)
	-- end
end
