-- Register the behaviour
behaviour("EmptyShootSound")

function EmptyShootSound:Start()
	self.audioSrc = self.gameObject.GetComponent(AudioSource)
	self.audioSrc.SetOutputAudioMixer(AudioMixer.FirstPerson)
	self.isEnabled = true
end
function EmptyShootSound:OnEnable()
	print("OnEnable")
	self.isEnabled = true
end
function EmptyShootSound:OnDisable()
	print("OnDisable")
	self.isEnabled = false
end
function EmptyShootSound:Update()
	if(self.isEnabled) then
	if Input.GetKeyBindButtonDown(KeyBinds.Fire) and not Player.actor.isDead and Player.actor.activeWeapon.ammo == 0 then
		self.audioSrc.PlayOneShot(self.targets.emptyClip)
	end
	if Input.GetKeyBindButtonDown(KeyBinds.Sprint) and Player.actor.isSprinting then
		self.audioSrc.PlayOneShot(self.targets.sprintClip, 3)
	end
end
end
