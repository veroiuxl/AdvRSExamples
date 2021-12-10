-- Register the behaviour
behaviour("YourScript")
--[[
If you have more questions ask me on Discord Chryses#6081 (Nickname is Chai)
--]]
function YourScript:Start()
	-- Run when behaviour is created
	print("Hello World")

	-- This is how you get a target
	self.yourTarget = self.targets.yourFirstTarget
	print("Your first Target name " .. tostring(self.yourTarget))
	print("The position is " .. tostring(self.yourTarget.transform.position))

	-- This is how you add a listener to an event
	GameEvents.onActorSpawn.AddListener(self,"onActorSpawn")
	GameEvents.onActorDied.AddListener(self,"onActorDied")

	-- There also events in a few other classes like:
	Player.actor.onTakeDamage.AddListener(self,"onTakeDamage")
	-- You can add a listener for the onTakeDamage event by looping trough every actor (Hint: ActorManager.actors)



	-- Player.actor.activeWeapon.onFire.AddListener(self,"onFire")

end
function YourScript:onTakeDamage(actor,source,info) -- info is the class DamageInfo
	-- DamageInfo has a lot of helpful information
	print("Actor " .. actor.name .. " was damage " .. info.healthDamage .. " from actor " .. source.name .. " from direction " .. tostring(info.direction)) 
end
function YourScript:onActorSpawn(actor)
	print(actor.name .. " spawned")

	-- Another way to format a string is
	print(string.format("%s spawned and he has %d health", actor.name,actor.health)) -- http://lua-users.org/wiki/StringLibraryTutorial
end
-- actor is the bot (or Player) that died, source is the actor that killed that bot (or Player) and isSilent returns if the actor died trough Actor.KillSilently()
function YourScript:onActorDied(actor,source,isSilent) 
	print(actor.name .. " died cause of " .. source.name)
end
function YourScript:Update()
	-- Run every frame
end
