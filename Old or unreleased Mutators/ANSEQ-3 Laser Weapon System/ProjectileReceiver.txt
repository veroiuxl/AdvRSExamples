-- Register the behaviour
behaviour("ProjectileReceiver")

function ProjectileReceiver:Awake()
	print("<color=green>Receiver started</color>")
	GameEvents.onProjectileSpawned.AddListener(self,"onProjectileSpawned")
	self.allProjectiles = {}
end
function ProjectileReceiver:onProjectileSpawned(projectile)
	-- if(projectile.source ~= Player.actor) then
		print("Projectile created")
		if(projectile.gameObject.GetComponent(Light) ~= nil) then
			print("Added rocket from " .. tostring(projectile.source.name))
			table.insert(self.allProjectiles, projectile)
		end
	-- end

end
function ProjectileReceiver:GetAllRockets()
	print("Passing " .. #self.allProjectiles .. " rockets to LDS")
	return self.allProjectiles
end
function ProjectileReceiver:Update()
	for i,y in ipairs(self.allProjectiles) do
		if(y == nil) then
			print("Removed a projectile. Proj Left: " .. tostring(#self.allProjectiles) )
			table.remove(self.allProjectiles, i)
		end
	end
end
