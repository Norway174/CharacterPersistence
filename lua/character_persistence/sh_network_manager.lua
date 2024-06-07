CHARACTER_PERSISTENCE.MsgC("Network Manager Loading.")

CHARACTER_PERSISTENCE = CHARACTER_PERSISTENCE or {}
CHARACTER_PERSISTENCE.Config = CHARACTER_PERSISTENCE.Config or {}


CHARACTER_PERSISTENCE.Config.Network = CHARACTER_PERSISTENCE.Config.Network or {}
CHARACTER_PERSISTENCE.Config.Network.NetName = "HALOARMORY_CHARPERSISTENCE"


local Actions = {
    ["GetCharacter"] = 1, // Unimplemented
    ["SetCharacter"] = 2, // Unimplemented
    ["DeleteCharacter"] = 3, // Unimplemented
    ["GetAllCharacters"] = 4,
    ["CreateCharacter"] = 5,
}

if SERVER then
    util.AddNetworkString(CHARACTER_PERSISTENCE.Config.Network.NetName)
end

//==========================================================
//======================== CLIENT ==========================
//==========================================================
if CLIENT then
    local ClientFunctionReturns = {}


    function CHARACTER_PERSISTENCE.SendRequest(Action, Data, ReturnFunction)

        // Check if the action is valid
        // Action could be a string or a number, convert it to a number
        // Then check if the action is valid
        if (type(Action) == "string") then
            Action = Actions[Action]
        end
        if (Action == nil) then
            ErrorNoHalt("CharacterPersistence: Invalid action")
            return
        end

        // Data is an optional table or string. If it's a table, convert it to a string
        if (type(Data) == "table") then
            Data = util.TableToJSON(Data)
        elseif (type(Data) != "string") then
            Data = tostring(Data) or ""
        end


        // ReturnFunction is an optional function object that will be called when the server returns a response
        // Generate a unique function name to pass to the server. Which will be used to call the function from ClientFunctionReturns when the server returns a response
        if (ReturnFunction != nil) then
            local FunctionName = "CH_PER_RETURN_" .. Action .. "_" .. tostring(os.time())
            // Check if the function already exists, if it does, append a random number to the end of the function name
            while (ClientFunctionReturns[FunctionName] != nil) do
                FunctionName = FunctionName .. tostring(math.random(1, 100))
            end
            ClientFunctionReturns[FunctionName] = ReturnFunction
            ReturnFunction = FunctionName
        end
        
        local DataString = util.Compress(Data)
        local DataBytes = #DataString

        net.Start(CHARACTER_PERSISTENCE.Config.Network.NetName)
        net.WriteUInt(Action, 8)
        net.WriteString(ReturnFunction)

        net.WriteUInt(DataBytes, 32)
        net.WriteData(DataString, DataBytes)

        net.SendToServer()


    end

    net.Receive(CHARACTER_PERSISTENCE.Config.Network.NetName, function(len, ply)
        --local Action = net.ReadUInt(8) // Action is not needed to be sent back from the server?
        --local DataString = net.ReadString()

        local ReturnFunction = net.ReadString() // We send the function first.


        local DataBytes = net.ReadUInt(32)
        local DataString = net.ReadData(DataBytes)

        local Data = util.Decompress(DataString)
        local DataTable = util.JSONToTable(Data)

        if (DataTable != nil) then
            Data = DataTable
        end

        // Check if the function exists
            if (ClientFunctionReturns[ReturnFunction] != nil) then

                // Wrap in a try catch to catch any errors that might occur
                local success, err_msg = pcall(function()
                    ClientFunctionReturns[ReturnFunction](Data)
                end)
                if (not success) then
                    if istable(Data) then
                        Data = table.ToString(Data, "Data", true)
                    end
                    if not isstring(Data) then
                        Data = tostring(Data)
                    end
                    ErrorNoHalt("CharacterPersistence: Error calling function " .. ReturnFunction .. " with data " .. Data .. " and error " .. err_msg)
                end

                // Remove the function from the list of functions to call
                ClientFunctionReturns[ReturnFunction] = nil
            end

    end)

end


//==========================================================
//======================== SERVER ==========================
//==========================================================
if SERVER then

    net.Receive(CHARACTER_PERSISTENCE.Config.Network.NetName, function(len, ply)
        local Action = net.ReadUInt(8)

        local ReturnFunction = net.ReadString()

        local DataBytes = net.ReadUInt(32)
        local DataString = net.ReadData(DataBytes)


        if (Action == Actions.GetAllCharacters) then
            local Characters = CHARACTER_PERSISTENCE.GetAllCharacters( ply )

            --PrintTable(Characters)


            DataString = util.TableToJSON(Characters)
            DataString = util.Compress(DataString)
            DataBytes = #DataString
            
            net.Start(CHARACTER_PERSISTENCE.Config.Network.NetName)
            net.WriteString(ReturnFunction)

            net.WriteUInt(DataBytes, 32)
            net.WriteData(DataString, DataBytes)

            net.Send(ply)

        elseif (Action == Actions.CreateCharacter) then
            
            // TODO: Save to selected Character slot, with the character data
            local CharData = util.Decompress(DataString)
            CharData = util.JSONToTable(CharData)

            local SlotName = CharData.SlotName
            local CharName = CharData.Name
            local CharJob = CharData.Job
            local CharModel = CharData.Model
            local CharSkin = CharData.Skin
            local CharBodygroups = CharData.Bodygroups

            // CHARACTER_PERSISTENCE.NewCharacter( ply, slotName, PlyName, PlyTeam, PlyModel, PlySkin, PlyBodygroups )
            local success, errorMsg = CHARACTER_PERSISTENCE.NewCharacter( ply, SlotName, CharName, CharJob, CharModel, CharSkin, CharBodygroups )


            // Send response back to server
            net.Start(CHARACTER_PERSISTENCE.Config.Network.NetName)
            net.WriteString(ReturnFunction)

            // TODO: Sand back the success or failure of the character creation
            local Data = {
                Success = success,
                ErrorMsg = errorMsg
            }

            DataString = util.TableToJSON(Data)
            DataString = util.Compress(DataString)
            DataBytes = #DataString

            net.WriteUInt(DataBytes, 32)
            net.WriteData(DataString, DataBytes)

            net.Send(ply)

        end


    end)

end