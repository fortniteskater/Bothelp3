-- learning_bot.lua (Updated for Lua 5.3+)

local database_file = "bot.json"
local knowledge = {}

-- Function to load knowledge from a JSON file
local function load_knowledge()
    local file = io.open(database_file, "r")
    if file then
        local content = file:read("*all")
        file:close()
        -- Use 'load' instead of 'loadstring' for compatibility
        if content and content ~= "" then
            -- Wrap content in parentheses to make it a return statement
            local success, data = pcall(load("return " .. content))
            if success then
                knowledge = data
                print("Knowledge loaded from " .. database_file)
            else
                print("Error loading knowledge data: " .. data)
            end
        end
    end
end

-- Function to save knowledge to a JSON file
local function save_knowledge()
    local file = io.open(database_file, "w")
    if file then
        -- Simple JSON encode for demonstration
        local content = "{\n"
        for input_pattern, outputs in pairs(knowledge) do
            content = content .. '  ["' .. input_pattern .. '"] = { "' .. table.concat(outputs, '", "') .. '" },\n'
        end
        -- Remove trailing comma and add closing brace if there are entries
        if #knowledge > 0 then
           content = content:gsub(",\n}$", "\n}")
        else
           content = content .. "}"
        end
        
        file:write(content)
        file:close()
        print("Knowledge saved to " .. database_file)
    end
end

-- Function to get a response
local function get_response(user_input)
    -- Normalize input to lowercase for easier matching
    local normalized_input = string.lower(user_input)
    
    -- Check if we have a match in our knowledge base
    if knowledge[normalized_input] then
        local responses = knowledge[normalized_input]
        -- Return a random response from the list of known answers
        return responses[math.random(1, #responses)]
    end
    
    -- If no match is found, prompt the user to teach the bot
    return "I'm still learning. How should I respond to that? Type 'teach [your input] [bot response]' to help me."
end

-- Function to teach the bot a new response
local function teach_bot(input_pattern, response)
    local normalized_input = string.lower(input_pattern)
    if not knowledge[normalized_input] then
        knowledge[normalized_input] = {}
    end
    table.insert(knowledge[normalized_input], response)
    print("Learned: '" .. input_pattern .. "' -> '" .. response .. "'")
    save_knowledge()
end

-- Main chat loop
load_knowledge()

print("Chatbot started. Type 'teach [input] [response]' to teach me.")
print("Type 'quit' to exit.")

while true do
    io.write("You: ")
    local user_input = io.read()
    
    if string.lower(user_input) == "quit" then
        break
    elseif string.match(string.lower(user_input), "^teach ") then
        -- Handle teaching command
        local _, _, input_part, response_part = string.find(user_input, "^teach%s+(.-)%s+(.+)$")
        if input_part and response_part then
            teach_bot(input_part, response_part)
        else
            print("Bot: Invalid teach command format.")
        end
    else
        -- Get and print bot response
        local bot_response = get_response(user_input)
        print("Bot: " .. bot_response)
    end
end
