if true then return end // We don't want to load the example module. But otherwise, remove this line.
--[[
  ______                           _      
 |  ____|                         | |     
 | |__  __  ____ _ _ __ ___  _ __ | | ___ 
 |  __| \ \/ / _` | '_ ` _ \| '_ \| |/ _ \
 | |____ >  < (_| | | | | | | |_) | |  __/
 |______/_/\_\__,_|_| |_| |_| .__/|_|\___|
                            | |           
                            |_|           
]]
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

end,
function( ply, CharData )
    // New Character
    // This function is called when a new character is created.
    // This is useful for setting default values for a new character.

end
)