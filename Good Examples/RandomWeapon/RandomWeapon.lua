-- Register the behaviour
behaviour("RandomWeapon")
local allWeapons
            local ERandom = {
                RangeInt = function(min, max)
                    return Mathf.RoundToInt(Random.Range(min, max))
                end
            }
function RandomWeapon:Start()
    if self.script.mutator.GetConfigurationDropdown("selectedVersion") == 0 then
        GameEvents.onActorSpawn.AddListener(self,"ActorSpawn")
    end
    if self.script.mutator.GetConfigurationDropdown("selectedVersion") == 1 then
        GameEvents.onActorSpawn.AddListener(self,"ActorSpawnAISelected")
    end
    if self.script.mutator.GetConfigurationDropdown("selectedVersion") == 2 then
        self.script.StartCoroutine("RandomizePerMinutes")
        print("Will wait " .. tostring(self.script.mutator.GetConfigurationFloat("waitMinutes") * 60) .. " seconds")
    end
    self.onlyPrimary = self.script.mutator.GetConfigurationBool("onlyPrimary")
    self.onlySecondary = self.script.mutator.GetConfigurationBool("onlySecondary")

   -- GameEvents.onActorSelectedLoadout.AddListener(self,"ActorSelectLoadout")
     allGear = {}
     allBigGear = {}
     allPrimary = {}
     allSecondary = {}
    self.allWeapons = WeaponManager.allWeapons
    for index,weaponentry in ipairs(self.allWeapons) do 
        if weaponentry.slot == WeaponSlot.Primary then
            table.insert(allPrimary, weaponentry)
        end
        if weaponentry.slot == WeaponSlot.LargeGear then
            table.insert(allBigGear, weaponentry)
        end
        if weaponentry.slot == WeaponSlot.Gear then
            table.insert(allGear, weaponentry)
        end
        if weaponentry.slot == WeaponSlot.Secondary then
            table.insert(allSecondary, weaponentry)
        end
    

    end
    self.isUsingModifiedHud = false
    self.script.StartCoroutine("GetHL2Hud")
end

function RandomWeapon:GetHL2Hud()
    local hl2hud = GameObject.Find("HL2 HUD Canvas").transform.parent.gameObject -- Get parent of that
    
    if(hl2hud ~= nil) then
        self.hl2Hud = ScriptedBehaviour.GetScript(hl2hud)
        self.isUsingModifiedHud = true    
    end
end
function RandomWeapon:RandomizePerMinutes()
    if not Player.actor.isDead then
    if(self.onlyPrimary) then
        Player.actor.RemoveWeapon(0)
        Player.actor.EquipNewWeaponEntry(allPrimary[ERandom.RangeInt(1,#allPrimary)], 0, false)
    elseif self.onlySecondary then
        Player.actor.RemoveWeapon(1)
        Player.actor.EquipNewWeaponEntry(allSecondary[ERandom.RangeInt(1,#allSecondary)], 1, false)
    elseif (self.onlyPrimary and self.onlySecondary) then
        Player.actor.RemoveWeapon(0)
        Player.actor.EquipNewWeaponEntry(allPrimary[ERandom.RangeInt(1,#allPrimary)], 0, false)
        Player.actor.RemoveWeapon(1)
        Player.actor.EquipNewWeaponEntry(allSecondary[ERandom.RangeInt(1,#allSecondary)], 1, false)
    elseif (not self.onlyPrimary and not self.onlySecondary) then
        Player.actor.RemoveWeapon(0)
        Player.actor.RemoveWeapon(1)
        Player.actor.RemoveWeapon(2)
        Player.actor.RemoveWeapon(3)
        Player.actor.RemoveWeapon(4)
        Player.actor.EquipNewWeaponEntry(allGear[ERandom.RangeInt(1,#allGear)], 2, false)
        Player.actor.EquipNewWeaponEntry(allBigGear[ERandom.RangeInt(1,#allBigGear)], 3, false)
        Player.actor.EquipNewWeaponEntry(allPrimary[ERandom.RangeInt(1,#allPrimary)], 0, false)
        Player.actor.EquipNewWeaponEntry(allSecondary[ERandom.RangeInt(1,#allSecondary)], 1, false)
    end
   
    print("\n")
    for i,y in ipairs(Player.actor.weaponSlots) do
        print("Selected Weapon: " .. y.weaponEntry.name .. " in " .. tostring(y.weaponEntry.slot) )
    end
    coroutine.yield(WaitForSeconds(self.script.mutator.GetConfigurationFloat("waitMinutes") * 60))
    self.script.StartCoroutine("RandomizePerMinutes")
    else
        coroutine.yield(WaitForSeconds(3))
        self.script.StartCoroutine("RandomizePerMinutes")
    end
    if(self.isUsingModifiedHud) then
        self.hl2Hud:ExternalWeaponChange()
    end

end
function RandomWeapon:Randomize(actor)

    return function()
        local aliveActors = ActorManager.GetAliveActorsOnTeam(Player.team)
        local randomActor = aliveActors[ERandom.RangeInt(0,#aliveActors)]
        if #aliveActors == 0 or randomActor == nil then
            coroutine.yield(WaitForSeconds(1))
            self.script.StartCoroutine(self:Randomize(actor))
            return
        end
        local WeaponsActor = randomActor
        while randomActor == Player.actor do
            coroutine.yield(WaitForSeconds(1))
            self.script.StartCoroutine(self:Randomize(actor))
            return
        end
        if WeaponsActor == nil then
            coroutine.yield(WaitForSeconds(1))
            self.script.StartCoroutine(self:Randomize(actor))
            return
        end
        local allWeapons = WeaponsActor.weaponSlots
        if(not self.onlyPrimary and not self.onlySecondary) then
        for i,y in ipairs(allWeapons) do
            local weapon = y.weaponEntry
            actor.RemoveWeapon(y.slot)
            actor.EquipNewWeaponEntry(weapon, y.slot, false)
        end 
        else if self.onlyPrimary then
            actor.RemoveWeapon(0)
            actor.EquipNewWeaponEntry(allWeapons[1].weaponEntry, 0, true)
        else if self.onlySecondary then
            actor.RemoveWeapon(1)
            actor.EquipNewWeaponEntry(allWeapons[2].weaponEntry, 1, true)
        else if self.onlyPrimary and self.onlySecondary then
            actor.RemoveWeapon(0)
            actor.EquipNewWeaponEntry(allWeapons[1].weaponEntry, 0, true)
            actor.RemoveWeapon(1)
            actor.EquipNewWeaponEntry(allWeapons[2].weaponEntry, 1, true)
        end
        end
        end
        
        end
        
        print("\n")
        for i,y in ipairs(actor.weaponSlots) do
            print("Selected AI Weapon: " .. y.weaponEntry.name.. " in "  .. tostring(y.weaponEntry.slot) )
        end
        if(self.isUsingModifiedHud) then
            self.hl2Hud:ExternalWeaponChange()
        end
    end
    end
function RandomWeapon:ActorSpawnAISelected(actor)
    if not actor.isBot then
        self.script.StartCoroutine(self:Randomize(actor))
    end
end
function RandomWeapon:ActorSpawn(actor)
    if not actor.isBot then
        if (not self.onlyPrimary and not self.onlySecondary) then
            Player.actor.RemoveWeapon(0)
            Player.actor.RemoveWeapon(1)
            Player.actor.RemoveWeapon(2)
            Player.actor.RemoveWeapon(3)
            Player.actor.RemoveWeapon(4)
            Player.actor.EquipNewWeaponEntry(allGear[ERandom.RangeInt(1,#allGear)], 2, false)
            Player.actor.EquipNewWeaponEntry(allBigGear[ERandom.RangeInt(1,#allBigGear)], 3, false)
            Player.actor.EquipNewWeaponEntry(allPrimary[ERandom.RangeInt(1,#allPrimary)], 0, false)
            Player.actor.EquipNewWeaponEntry(allSecondary[ERandom.RangeInt(1,#allSecondary)], 1, false)
        else if self.onlyPrimary then
            Player.actor.RemoveWeapon(0)
            Player.actor.EquipNewWeaponEntry(allPrimary[ERandom.RangeInt(1,#allPrimary)], 0, false)
        else if self.onlySecondary then
            Player.actor.RemoveWeapon(1)
            Player.actor.EquipNewWeaponEntry(allSecondary[ERandom.RangeInt(1,#allSecondary)], 1, false)
        else if (self.onlyPrimary and self.onlySecondary) then
            Player.actor.RemoveWeapon(0)
            Player.actor.EquipNewWeaponEntry(allPrimary[ERandom.RangeInt(1,#allPrimary)], 0, false)
            Player.actor.RemoveWeapon(1)
            Player.actor.EquipNewWeaponEntry(allSecondary[ERandom.RangeInt(1,#allSecondary)], 1, false)
            end
            end
            end
        end
       
        print("\n")
        for i,y in ipairs(actor.weaponSlots) do
        print("Selected Weapon: " .. y.weaponEntry.name.. " in "  .. tostring(y.weaponEntry.slot) )
        end
        if(self.isUsingModifiedHud) then
            self.hl2Hud:ExternalWeaponChange()
        end
    end
end
function RandomWeapon:ActorSelectLoadout(actor,loadout,strategy)
--     if not actor.isBot then

-- loadout.primary = allPrimary[ERandom.RangeInt(1,#allPrimary)]
-- loadout.secondary = allSecondary[ERandom.RangeInt(1,#allSecondary)]
-- loadout.gear3 = allGear[ERandom.RangeInt(1,#allGear)]
-- loadout.gear2 = allGear[ERandom.RangeInt(1,#allGear)]
-- loadout.gear1 =allGear[ERandom.RangeInt(1,#allGear)]
-- print("Set random loadout")
--     end
end


function RandomWeapon:Update()
		
end
