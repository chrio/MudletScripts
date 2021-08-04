# Scriptwatcher
The `scriptwatcher.lua` script helps with copying Mudlet script content from files on disk to the corresponding scripts in Mudlet when it detects a file change.

I made it as a tool to avoid all the copy-paste from my editor to Mudlet, since I wanted to keep my scripts in a git repository to track changes.  The syncronization is one way only, from your files to Mudlet. 

To use it, simply copy the code to a new script in Mudlet (preferably calling it 'scriptwatcher').

In order to select which scripts it should keep track of, you can either:

* Modify the scriptwatcher.scripts table in scriptwatcher.
* Create a new script containing the table, and make sure it runs before the scriptwatcher script (by placing it higher up in the list).

The second option is more flexible, since it allows you to keep different files synced for different profiles. Here is a template for such a script:

```lua
Scriptwatcher = scriptwatcher or {}
Scriptwatcher.scripts = {
    scriptwatcher = 'C:/repos/MudletScripts/scriptwatcher.lua',
    ['ui-frames'] = 'C:/repos/MudletScripts/ui-frames.lua',
    ['ui-data'] =  'C:/repos/MudletScripts/ui-data.lua',
    ['a test script'] = 'C:/repos/MudletScripts/some_test.lua',
}
```

The script names in Mudlet are used as the table keys, and the values are the path to the files.

## Settings

### Scriptwatcher.infolevel

This variable can be set between 0-2 to select the amount of messages it should show. Errors are always shown.
* 0=errors only
* 1=info
* 2=debug

### Scriptwatcher.addNewScripts

When this variable is set to `true` the scripts will create the scripts if they do not exist yet. This could be useful when starting a new profile, but it's better to leave it at `false` unless it is needed.

## Important notices
The script will not care if you have made any changes to your script from within Mudlet. If it detects a file event for *any* of the files you listed in the `Scriptwatcher.scripts` table, it will check *all* the scripts one by one, and update any script where it detects a difference between the file and Mudlet.

In other words, this means that script A could be overwritten if you have changed it in Mudlet and the file from script B was updated.

The scripts will also run once they are updated, in the same way as when you save them from Mudlet.
