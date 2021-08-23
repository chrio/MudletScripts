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

Keep a separate script containing your table with the info regarding what scripts to keep updated.
The table is named 'Scriptwatcher.scripts'

Example script:
    Scriptwatcher = Scriptwatcher or {}
    Scriptwatcher.scripts = {
        Scriptwatcher = 'C:/repos/MudletScripts/scriptwatcher/scriptwatcher.lua',
        ['ui-helpers'] = 'C:/repos/MudletScripts/ui-helpers/ui-helpers.lua',
    }
]]

Scriptwatcher = Scriptwatcher or {}
Scriptwatcher.version = '0.3.5'
Scriptwatcher.infolevel = 1
Scriptwatcher.addNewScripts = false

-- Make sure to only set unique script names
-- we do not watch for instance if we have multiple script with same name
Scriptwatcher.onchange = function()
    if not Scriptwatcher.scripts then return end -- wait until we have scripts
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
                    local ran, errorMsg = pcall(setScript, script, filecontent)
                    if ran then
                        if Scriptwatcher.infolevel >= 1 then
                            print(string.format('Updating script [%s]', script))
                        end
                    else
                        local err = errorMsg:gsub('^.*invalid Lua code:','<orange>'):gsub('^.*:(%d+):(.*)[)]','line %1: %2')
                        cecho(string.format('<red>Error when updating script <red>[<white>%s<red>] from <reset>%s\n   %s\n', script, path, err))
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
    -- Delay updates before reloading, to give time for multiple updates
    if Scriptwatcher.timer then killTimer(Scriptwatcher.timer) end
    Scriptwatcher.timer = tempTimer(0.2, Scriptwatcher.onchange)
end

Scriptwatcher.events = Scriptwatcher.events or {
    registerAnonymousEventHandler("sysPathChanged",
                                  "Scriptwatcher.scriptChangeHandler")
}
if Scriptwatcher.infolevel >= 2 then
    print(string.format('Loaded %s v%s', 'Scriptwatcher', Scriptwatcher.version))
end

Scriptwatcher.updateFileWatchers = function()
    if not Scriptwatcher.scripts then
        tempTimer(10, Scriptwatcher.updateFileWatchers)
        if not Scriptwatcher.helpshown then
            Scriptwatcher.help()
            Scriptwatcher.helpshown = true
        end
        return
    end
    for script, path in pairs(Scriptwatcher.scripts) do
        removeFileWatch(path)
        addFileWatch(path)
        if Scriptwatcher.infolevel >= 2 then
            print(string.format('Watching script [%s] for changes in file %s', script, path))
        end
    end
end

Scriptwatcher.help = function()
    if not Scriptwatcher.scripts then
        cecho("<yellow>Scriptwatcher is missing table <white>Scriptwatcher.scripts</reset>\n")
        cecho("The table should contains the necessary information regarding what scripts to update ")
        cecho("and what file is containing the script.\n\necessary")
        cecho("<cyan>Example script for Scriptwatcher path table:<reset>\n\n")
        cecho("   <white>Scriptwatcher = Scriptwatcher or {}\n")
        cecho("   <white>Scriptwatcher.scripts = {\n")
        cecho("   <white>    Scriptwatcher = 'C:/repos/MudletScripts/scriptwatcher/scriptwatcher.lua',\n")
        cecho("   <white>    ['my-other-script'] = 'C:/repos/MyScripts/my-other-script.lua',\n")
        cecho("   <white>}<reset>\n")
    else
        cecho('<cyan>Scripts watched:\n')
        for script, path in pairs(Scriptwatcher.scripts) do
            print(string.format('  [%s] in file %s', script, path))
        end
    end
end

Scriptwatcher.updateFileWatchers()
if Scriptwatcher.addNewScripts then Scriptwatcher.scriptChangeHandler() end
