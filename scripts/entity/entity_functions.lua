-- OPENTOMB ENTITY FUNCTIONS SCRIPT
-- By TeslaRus, Lwmte, 2014-2015

--------------------------------------------------------------------------------
-- This script contains routines for all entity functions. Note that it is not
-- just entity functions, but "function creation" routines, which usually
-- includes some events executed on level start-up. Function itself is placed
-- inside entity function array (entity_funcs).
--------------------------------------------------------------------------------

entity_funcs = {};  -- Initialize entity function array.

-- Load up some extra entity scripts.

dofile("scripts/entity/script_switch.lua");     -- Additional switch scripts.

-- Erase single entity function.

function efuncs_EraseEntity(index)
    if(entity_funcs[index] ~= nil) then
        entity_funcs[index].onActivate      = nil;
        entity_funcs[index].onDeactivate    = nil;
        entity_funcs[index].onCollide       = nil;
        entity_funcs[index].onStand         = nil;
        entity_funcs[index].onHit           = nil;
        entity_funcs[index].onLoop          = nil;
        entity_funcs[index]                 = nil;
    end;
end;

-- Clear whole entity functions array. Must be called on each level loading.

function entfuncs_Clear()
    for k,v in pairs(entity_funcs) do
        efuncs_EraseEntity(k);
    end;
    print("Entity function table cleaned");
end;

--------------------------------------------------------------------------------
-- ENTITY FUNCTIONS IMPLEMENTATION
--------------------------------------------------------------------------------

function door_init(id)   -- NORMAL doors only!

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    setEntityActivity(object_id, 1);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(object_id == nil) then return end;
        swapEntityState(object_id, 0, 1);
    end;
    
    entity_funcs[id].onDeactivate = entity_funcs[id].onActivate;    -- Same function.
    
    entity_funcs[id].onLoop = function(object_id)
        if(tickEntity(object_id) == TICK_STOPPED) then
            swapEntityState(object_id, 0, 1);
            setEntityEvent(object_id, 0);
        end;
    end
    
    prepareEntity(id);
end

function keyhole_init(id)    -- Key and puzzle holes

    setEntityTypeFlag(id, ENTITY_TYPE_INTERACTIVE);
    setEntityActivity(id, 0);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(object_id == nil or getEntityActivity(object_id) >= 1 or canTriggerEntity(activator_id, object_id, 256.0, 0.0, 256.0, 0.0) ~= 1) then
            return;
        end
        
        if((getEntityActivity(object_id) == 0) and (switch_activate(object_id, activator_id) == 1)) then
            setEntityPos(activator_id, getEntityPos(object_id));
            moveEntityLocal(activator_id, 0.0, 360.0, 0.0);
        end
    end;
end

function switch_init(id)     -- Ordinary switches
    
    setEntityTypeFlag(id, ENTITY_TYPE_INTERACTIVE);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(object_id == nil or canTriggerEntity(activator_id, object_id, 256.0, 0.0, 256.0, 0.0) ~= 1) then
            return;
        end
        
        if(switch_activate(object_id, activator_id) == 1) then
            setEntityPos(activator_id, getEntityPos(object_id));    -- Move activator right next to object.
            moveEntityLocal(activator_id, 0.0, 360.0, 0.0);         -- Shift activator back to proper distance.
        end;
    end;
    
    entity_funcs[id].onLoop = function(object_id)
        if(tickEntity(object_id) == TICK_STOPPED) then
            setEntityState(object_id, 1);
            setEntitySectorStatus(object_id, 1);
        end;
    end;
end

function anim_init(id)      -- Ordinary animatings

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        setEntityActivity(object_id, 1);
        setEntityState(object_id, 1);
    end    
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        setEntityActivity(object_id, 0);
        setEntityState(object_id, 0);
    end
    
    entity_funcs[id].onLoop = function(object_id)
        if(tickEntity(object_id) == TICK_STOPPED) then setEntityState(object_id, 0) end;
    end
end

function venicebird_init(id)    -- Venice singing birds (TR2)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        setEntityActivity(object_id, 1);
    end
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        setEntityActivity(object_id, 0);
    end
    
    entity_funcs[id].onLoop = function(object_id)
        if(tickEntity(object_id) == TICK_STOPPED) then setEntityActivity(object_id, 0) end;
        if(getEntityDistance(player, object_id) < 8192.0) then
            if(math.random(100000) > 99500) then playSound(316, object_id) end;
        end;
    end
    
    prepareEntity(id);
end

function doorbell_init(id)    -- Lara's Home doorbell (TR2)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    setEntityActivity(id, 0);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        setEntityActivity(object_id, 1);
    end
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        setEntityActivity(object_id, 0);
    end
    
    entity_funcs[id].onLoop = function(object_id)
        if(getEntityDistance(player, object_id) < 4096.0) then
            playSound(334, object_id);
            setEntityActivity(object_id, 0);
        end;
    end
end

function alarm_TR2_init(id)    -- Offshore Rig alarm (TR2)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    setEntityActivity(id, 0);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(getEntityActivity(object_id) == 0) then setEntityActivity(object_id, 1) end;
    end
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        if(getEntityActivity(object_id) == 1) then
            setEntityActivity(object_id, 0);
            stopSound(332, object_id);
        end;
    end
    
    entity_funcs[id].onLoop = function(object_id)
        playSound(332, object_id);
        if(tickEntity(object_id) == TICK_STOPPED) then
            setEntityActivity(object_id, 0)
            stopSound(332, object_id);
        end;
    end
end

function alarmbell_init(id)    -- Home Sweet Home alarm (TR2)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    setEntityActivity(id, 0);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(getEntityActivity(object_id) == 0) then setEntityActivity(object_id, 1) end;
    end
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        if(getEntityActivity(object_id) == 1) then
            setEntityActivity(object_id, 0);
            stopSound(335, object_id);
        end;
    end
    
    entity_funcs[id].onLoop = function(object_id)
        playSound(335, object_id);
        if(tickEntity(object_id) == TICK_STOPPED) then
            setEntityActivity(object_id, 0)
            stopSound(335, object_id);
        end;
    end
end

function heli_TR2_init(id)    -- Helicopter (TR2)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    
    entity_funcs[id].distance_passed = 0;
    setEntityActivity(id, 0);
    setEntityVisibility(id, 0);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(getEntityActivity(object_id) == 0) then
            setEntityActivity(object_id, 1);
            setEntityVisibility(id, 1);
            playSound(297, object_id);
        end;
    end
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        setEntityActivity(object_id, 0);
    end
    
    entity_funcs[id].onLoop = function(object_id)
        entity_funcs[object_id].distance_passed = entity_funcs[object_id].distance_passed + 40.0;
        moveEntityLocal(object_id, 0.0, 40.0, 0.0);
        if(entity_funcs[object_id].distance_passed > 30720) then
            stopSound(297, object_id);
            disableEntity(object_id);
        end;
    end
    
    prepareEntity(id);
end

function swingblade_init(id)        -- Swinging blades (TR1)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    setEntityActivity(id, 1);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        setEntityState(object_id, 2);
    end    
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        setEntityState(object_id, 0);
    end
    
    entity_funcs[id].onLoop = function(object_id)
        if(tickEntity(object_id) == TICK_STOPPED) then setEntityState(object_id, 0) end;
    end
    
    prepareEntity(id);
end

function tallblock_init(id)    -- Tall moving block (TR1)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    
    entity_funcs[id].distance_passed = 0;
    setEntityActivity(id, 0);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(getEntityActivity(object_id) == 0) then
            setEntityActivity(object_id, 1);
            playSound(64, object_id);
        end;
    end
    
    entity_funcs[id].onDeactivate = entity_funcs[id].onActivate;
    
    entity_funcs[id].onLoop = function(object_id)
        local move_speed = 32.0;
        if(getEntityEvent(object_id) == 0) then move_speed = 0 - move_speed end;
        
        entity_funcs[object_id].distance_passed = entity_funcs[object_id].distance_passed + move_speed;
        moveEntityLocal(object_id, 0.0, move_speed, 0.0);
        if(math.abs(entity_funcs[object_id].distance_passed) >= 2048.0) then
            stopSound(64, object_id);
            setEntityActivity(object_id, 0);
            entity_funcs[object_id].distance_passed = 0;
        end;
    end
    
    prepareEntity(id);
end

function slamdoor_init(id)      -- Slamming doors (TR1-TR2)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    setEntityActivity(id, 1);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        setEntityState(object_id, 1);
    end    
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        setEntityState(object_id, 0);
    end
    
    entity_funcs[id].onLoop = function(object_id)
        if(tickEntity(object_id) == TICK_STOPPED) then setEntityState(object_id, 0) end;
    end
    
    prepareEntity(id);
end

function wallblade_init(id)     -- Wall blade (TR1-TR3)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        setEntityActivity(object_id, 1);
    end    
    
    entity_funcs[id].onDeactivate = function(object_id, activator_id)
        setEntityActivity(object_id, 0);
    end
    
    entity_funcs[id].onLoop = function(object_id)
        if(tickEntity(object_id) == TICK_STOPPED) then setEntityActivity(object_id, 0) end;
        local anim_number = getEntityAnim(object_id);
        if(anim_number == 2) then
            setEntityAnim(object_id, 3);
        elseif(anim_number == 1) then
            setEntityAnim(object_id, 0);
        end;
    end
    
    prepareEntity(id);
end

function pickup_init(id, item_id)    -- Pick-ups

    setEntityTypeFlag(id, ENTITY_TYPE_PICKABLE);
    setEntityActivationOffset(id, 0.0, 0.0, 0.0, 480.0);
    setEntityActivity(id, 0);

    entity_funcs[id].onActivate = function(object_id, activator_id)
        if((item_id == nil) or (object_id == nil)) then
            return;
        end
        
        local need_set_pos = true;
        local curr_anim = getEntityAnim(activator_id);

        if(curr_anim == 103) then                 -- Stay idle
            local dx, dy, dz = getEntityVector(object_id, activator_id);
            if(dz < -256.0) then
                need_set_pos = false;
                setEntityAnim(activator_id, 425); -- Standing pickup, test version
            else
                setEntityAnim(activator_id, 135); -- Stay pickup
            end;
        elseif(curr_anim == 222) then             -- Crouch idle
            setEntityAnim(activator_id, 291);     -- Crouch pickup
        elseif(curr_anim == 263) then             -- Crawl idle
            setEntityAnim(activator_id, 292);     -- Crawl pickup
        elseif(curr_anim == 108) then             -- Swim idle
            setEntityAnim(activator_id, 130);     -- Swim pickup
        else
            return;     -- Disable picking up, if Lara isn't idle.
        end;

        addTask(
        function()
        
            -- Position corrector
        
            if(getEntityMoveType(activator_id) == 6) then
                if(getEntityDistance(object_id, activator_id) > 128.0) then
                    moveEntityToEntity(activator_id, object_id, 25.0);
                end;
            else
                if(getEntityDistance(object_id, activator_id) > 32.0) then
                    moveEntityToEntity(activator_id, object_id, 50.0);
                end;
            end;
            
            local a, f, c = getEntityAnim(activator_id);
            
            -- Standing pickup anim makes action on frame 40 in TR1-3, in TR4-5
            -- it was generalized with all rest animations by frame 16.

            if((a == 135) and (getLevelVersion() < TR_IV)) then
                if(f < 40) then
                    return true;
                end;
            else
                if(f < 16) then
                    return true;
                end;
            end;

            addItem(activator_id, item_id);
            disableEntity(object_id);
            return false;   -- Item successfully picked up, kill the task.
        end);
    end;
end

function crystal_TR3_init(id)   -- "Savegame" crystal (TR3 version)

    setEntityTypeFlag(id, ENTITY_TYPE_GENERIC);
    setEntityActivity(id, 1);
    
    entity_funcs[id].onLoop = function(object_id)
        if(getEntityDistance(player, object_id) < 512.0) then
            playSound(SOUND_MEDIPACK);
            changeCharacterParam(player, PARAM_HEALTH, 200);
            disableEntity(object_id);
        end;
    end
end

function fallblock_init(id)  -- Falling block (TR1-3)

    local f1, f2, f3 = getEntityFlags(id);  -- f1 - state flags, f2 - type flags, f3 - callback flags
    setEntityFlags(id, nil, nil, bit32.bor(f3, ENTITY_CALLBACK_STAND));
    setEntitySpeed(id, 0.0, 0.0, 0.0);

    entity_funcs[id].onStand = function(object_id, activator_id)
        if((object_id == nil) or (activator_id == nil)) then
            return;
        end

        local anim = getEntityAnim(object_id);
        if(anim == 0) then
            setEntityAnim(object_id, 1);
            -- print("you trapped to id = "..object_id);
            local once = true;
            addTask(
            function()
                local anim = getEntityAnim(object_id);
                if(anim == 1) then
                    return true;
                end;
                if(once) then
                    setEntityCollision(object_id, 0);
                    once = false;
                end;
                if(dropEntity(object_id, frame_time)) then
                    setEntityAnim(object_id, 3);
                    return false;
                end;
                return true;
            end);
        end;
    end;
end

function fallceiling_init(id)  -- Falling ceiling (TR1-3)

    setEntitySpeed(id, 0.0, 0.0, 0.0);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if((object_id == nil) or (activator_id == nil)) then
            return;
        end

        local anim = getEntityAnim(object_id);
        if(anim == 0) then
            setEntityAnim(object_id, 1);
            addTask(
            function()
                if(dropEntity(object_id, frame_time)) then
                    setEntityAnim(object_id, 2);
                    setEntityCollision(object_id, 0);
                    return false;
                end;
                return true;
            end);
        end;
    end;
    
end

function pushdoor_init(id)   -- Pushdoors (TR4)

    setEntityTypeFlag(id, ENTITY_TYPE_INTERACTIVE);
    setEntityActivity(id, 0);

    entity_funcs[id].onActivate = function(object_id, activator_id)
        if((object_id == nil) or (activator_id == nil)) then
            return;
        end;

        if((getEntityActivity(object_id) == 0) and (getEntityDirDot(object_id, activator_id) < -0.9)) then
            setEntityActivity(object_id, 1);
            local x, y, z, az, ax, ay = getEntityPos(object_id);
            setEntityPos(activator_id, x, y, z, az + 180.0, ax, ay);
            moveEntityLocal(activator_id, 0.0, 256.0, 0.0);
            -- floor door 317 anim
            -- vertical door 412 anim
            setEntityAnim(activator_id, 412);
        end;
    end;
end

function midastouch_init(id)    -- Midas gold touch

end

function oldspike_init(id)  -- Teeth spikes (INVALID)

    setEntityActivity(id, 1);
    local f1, f2, f3 = getEntityFlags(id);
    setEntityFlags(id, nil, bit32.bor(f2, ENTITY_TYPE_GENERIC), bit32.bor(f3, ENTITY_CALLBACK_COLLISION));
    
    entity_funcs[id].onCollision = function(object_id, activator_id)
        if((object_id == nil) or (activator_id == nil)) then
            return;
        end;
        
        if(getModelID(activator_id) == 0) then  -- Lara
        
            local s1, s2, s3 = getEntitySpeed(activator_id);
            -- check if Lara and remove her HP!!!!
            print("speed: " .. s1 .. " " .. s2 .. " " .. s3);
        
        end;
    end;
end

function baddie_init(id)    -- INVALID!

    setEntityTypeFlag(id, ENTITY_TYPE_ACTOR);
    disableEntity(id);
    
    entity_funcs[id].onActivate = function(object_id, activator_id)
        if(getEntityActivity(object_id) == 0) then enableEntity(object_id) end;
    end;
    
end