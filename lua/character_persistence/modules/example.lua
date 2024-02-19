if true then return end // Custom check. (We don't want to load the example module)

local ModuleName = "MyModule"

CHARACTER_PERSISTENCE.MsgC(Color( 207, 146, 33), "-> "..ModuleName.." Module Loading.")


CHARACTER_PERSISTENCE:RegisterModule( ModuleName, 50,
function( ply, DataToSave )
    // Save the player's Data
    // Make sure you return 'data' to save it.


    return DataToSave
end,
function( ply, DataToLoad, GlobalData )
    // Load the player's Data
    // The data is returned the same way it was saved.

end )