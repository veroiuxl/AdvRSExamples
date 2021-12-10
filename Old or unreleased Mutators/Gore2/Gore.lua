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
	self.leftlegPath = "Armature/Bone/Leg_L/Leg_L_001"
	self.rightlegPath = "Armature/Bone/Leg_R/Leg_R_001"
	self.leftarmPath = "Armature/Bone/Bone_001/Bone_002/Shoulder_L/Arm_L_001"
	self.rightarmPath = "Armature/Bone/Bone_001/Bone_002/Shoulder_R/Arm_R_001"
	self.headPath = "Armature/Bone/Bone_001/Bone_002/Bone_003/Bone_004" -- I sure hope steel won't update the bones
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
	if(boneName == "Leg_L_001") then
 	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.leftlegPath) 
	elseif boneName == "Leg_R_001" then
	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.rightlegPath) 
	elseif boneName == "Arm_L_001" then
	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.leftarmPath) 
	elseif boneName == "Arm_R_001" then
	boneTransform = actor.aiController.gameObject.transform.GetChild(0).Find(self.rightarmPath) 
	elseif boneName == "Bone_004" then
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
local lndawlDAKWFuckingWork = self:ContainsName(targetLimbs,bone)
if(lndawlDAKWFuckingWork) then
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
	if(bone.gameObject.name == "Bone_004") then
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
		self:SpawnLimb(hitBone,actor,{"Bone_003","Bone_004"},self.targets.headprefab,true,"Bone_004")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.RightLowerArm) 
		-- hitBone = self:FindBoneByName(actor,"Arm_R_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Arm_R_001","Arm_R_002","Arm_R_003"},self.targets.leftArmprefab,false,"Arm_R_001")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.LeftLowerArm)
		-- hitBone = self:FindBoneByName(actor,"Arm_L_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Arm_L_001","Arm_L_002","Arm_L_003"},self.targets.rightArmprefab,false,"Arm_L_001")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.LeftLowerLeg)
		-- hitBone = self:FindBoneByName(actor,"Leg_L_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Leg_L_001"},self.targets.leftLegprefab,false,"Leg_L_001")
		hitBone = self:GetHumanoidTransform(actor,HumanBodyBones.RightLowerLeg)
		-- hitBone = self:FindBoneByName(actor,"Leg_R_001")
		hitBone.transform.localScale = Vector3(0,0,0)
		self:SpawnLimb(hitBone,actor,{"Leg_R_001"},self.targets.rightLegprefab,false,"Leg_R_001")

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
		or hitBone.transform.gameObject.name == "Bone_001"
		or string.find(hitBone.transform.gameObject.name,"Terrain") -- lazy but it works
		) then
		print("Hit banned bone " .. tostring(hitBone.name))
		hitBannedBone = true
		end
	end
	if(info.healthDamage >= actor.health and not hitBannedBone and hitBone ~= nil) then
		-- print(hitBone.transform.gameObject.name)
		local actorHitCountInTable = self.actorGoreCount[self:tablefindInTable(self.actorGoreCount,actor)][2]
		if(actorHitCountInTable <= self.maxSeperatableLimbs) then -- cause spahghett 
		print("Actor had " .. tostring(actorHitCountInTable) .. " hits already")
		if(hitBone.transform.gameObject.name == "Bone_003" or hitBone.transform.gameObject.name == "Bone_004") then
			self:SpawnLimb(hitBone,actor,{"Bone_003","Bone_004"},self.targets.headprefab,true,"Bone_004")
		end
		if(hitBone.transform.gameObject.name == "Arm_R_001" or hitBone.transform.gameObject.name == "Arm_R_002" or hitBone.transform.gameObject.name == "Arm_R_003" ) then
			self:SpawnLimb(hitBone,actor,{"Arm_R_001","Arm_R_002","Arm_R_003"},self.targets.leftArmprefab,false,"Arm_R_001")
		end
		if(hitBone.transform.gameObject.name == "Arm_L_001" or hitBone.transform.gameObject.name == "Arm_L_002" or hitBone.transform.gameObject.name == "Arm_L_003" ) then
			self:SpawnLimb(hitBone,actor,{"Arm_L_001","Arm_L_002","Arm_L_003"},self.targets.rightArmprefab,false,"Arm_L_001")
		end
		if(hitBone.transform.gameObject.name == "Leg_L_001" or hitBone.transform.gameObject.name == "Leg_L" or hitBone.transform.gameObject.name == "Leg_L_002" ) then
			self:SpawnLimb(hitBone,actor,{"Leg_L_001","Leg_L_002"},self.targets.leftLegprefab,false,"Leg_L_001")
		end
		if(hitBone.transform.gameObject.name == "Leg_R_001" or hitBone.transform.gameObject.name == "Leg_R" or hitBone.transform.gameObject.name == "Leg_R_002") then
			self:SpawnLimb(hitBone,actor,{"Leg_R_001","Leg_R_002"},self.targets.rightLegprefab,false,"Leg_R_001")
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
