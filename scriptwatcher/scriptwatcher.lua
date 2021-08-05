--[[
scriptwatcher.lua

Update scripts in mudlet when they change on disk

Scriptwatcher.infolevel
    0=errors only
    1=info
    2=debug

Scriptwatcher.addNewScripts
    Set to true to have the scriptwatcher create scripts from file if they do not exist yet.
    Can be useful when starting a new profile (or annoying if you make a typo in the scripts table)
]]

Scriptwatcher = Scriptwatcher or {}
Scriptwatcher.version = '0.3.1'
Scriptwatcher.infolevel = 1
Scriptwatcher.addNewScripts = false

-- Make sure to only set unique script names
-- we do not watch for instance if we have multiple script with same name
Scriptwatcher.scripts = Scriptwatcher.scripts or {
    Scriptwatcher = 'C:/repos/MudletScripts/scriptwatcher/scriptwatcher.lua',
}

Scriptwatcher.onchange = function()
    if Scriptwatcher.infolevel >= 2 then
        print("Scriptwatcher detected a file change")
    end
    for script, path in pairs(Scriptwatcher.scripts) do
        local code = getScript(script)
        if code == -1 and Scriptwatcher.addNewScripts ~= true then
            print(string.format('No script with name [%s] found', script))
        else
            if code == -1 and Scriptwatcher.addNewScripts == true then
                print(string.format('Adding new script with name [%s]', script))
                permScript(script, '', '-- script stub, added from Scriptwatcher')
                enableScript(script)
            end
            local filecontent = Scriptwatcher.read(path)
            if filecontent and filecontent ~= "" then
                if filecontent == code then
                    if Scriptwatcher.infolevel >= 2 then
                        print(string.format('Skipping unchanged script [%s]', script))
                    end
                else
                    if pcall(setScript, script, filecontent) then
                        if Scriptwatcher.infolevel >= 1 then
                            print(string.format('Updating script [%s]', script))
                        end
                    else
                        print(string.format('Failed updating script [%s]! '..
                        'Check code for errors and try again', script))
                    end
                end
            else
                print(string.format('Unexpected content in [%s], keeping current script [%s] as-is!', path, script))
            end
        end
    end
end

Scriptwatcher.read = function(path)
    local file = io.open(path, "r") -- r read mode
    if not file then
        print(string.format('Could not open file [%s]', path))
        return false
    end
    local filecontent = nil
    filecontent = file:read("*all")
    file:close()
    return filecontent
end

Scriptwatcher.scriptChangeHandler = function(_, path)
    -- Delay updates for 1 second to give time for mudliple updates
    if Scriptwatcher.timer then killTimer(Scriptwatcher.timer) end
    Scriptwatcher.timer = tempTimer(0.2, Scriptwatcher.onchange)
end

for _, value in pairs(Scriptwatcher.scripts) do
    removeFileWatch(value)
    addFileWatch(value)
end

Scriptwatcher.events = Scriptwatcher.events or {
    registerAnonymousEventHandler("sysPathChanged",
                                  "Scriptwatcher.scriptChangeHandler")
}
if Scriptwatcher.infolevel >= 2 then
    print(string.format('Loaded %s v%s', 'Scriptwatcher', Scriptwatcher.version))
end

if Scriptwatcher.addNewScripts then Scriptwatcher.scriptChangeHandler() end
