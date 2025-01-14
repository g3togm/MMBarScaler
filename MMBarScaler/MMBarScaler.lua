-- MMBarScaler.lua

-- Define the slash commands for scaling and opening the GUI
SLASH_MMBARSCALE1 = "/mmbarscale"
SLASH_MMBARSCALE2 = "/scaleMMBar"

SLASH_MMBARSCALEGUI1 = "/mmbarscalergui"
SLASH_MMBARSCALEGUI2 = "/scaleMMBarGUI"

-- Function to scale the Main Menu Bar via slash command
local function ScaleMMBar(msg, editBox)
    -- Parse the scale value from the command, default to 1.2 if not provided
    local scale = tonumber(msg) or 1.2
    -- Clamp the scale between 0.5 and 2.0 for safety
    scale = math.max(0.5, math.min(scale, 2.0))
    -- Apply the scale if MainMenuBar exists
    if MainMenuBar then
        MainMenuBar:SetScale(scale)
        -- Save the scale value in SavedVariables
        MMBarScalerDB.scale = scale
        -- Uncomment the following line to enable chat messages
        -- print(string.format("Main Menu Bar scale set to %.1f", scale))
    else
        print("MMBarScaler: MainMenuBar not found.")
    end
end

-- Register the slash command with the function
SlashCmdList["MMBARSCALE"] = ScaleMMBar

-- Function to create the GUI Frame
local function CreateMMBarScalerFrame()
    -- If the frame already exists, just show it
    if MMBarScalerFrame then
        MMBarScalerFrame:Show()
        return
    end

    -- Create the main frame
    local frame = CreateFrame("Frame", "MMBarScalerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(300, 200) -- Increased height to accommodate new textbox
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Set frame title
    frame.title = frame:CreateFontString(nil, "OVERLAY")
    frame.title:SetFontObject("GameFontHighlight")
    frame.title:SetPoint("LEFT", frame.TitleBg, "LEFT", 5, 0)
    frame.title:SetText("MMBarScaler")

    -- Add a description
    local description = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -8)
    description:SetWidth(280)
    description:SetHeight(40) -- Increased height to prevent text overlap
    description:SetJustifyH("LEFT")
    description:SetText("Use the slider below to adjust the scale of the Main Menu Bar.")

    -- Create the slider
    local slider = CreateFrame("Slider", "MMBarScalerSlider", frame, "OptionsSliderTemplate")
    slider:SetPoint("TOP", description, "BOTTOM", 0, -20)
    slider:SetWidth(200)
    slider:SetMinMaxValues(0.5, 2.0)
    slider:SetValueStep(0.1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(MMBarScalerDB.scale or 1.2)

    -- Slider Labels
    slider.low = _G[slider:GetName() .. "Low"]
    slider.high = _G[slider:GetName() .. "High"]
    slider.text = _G[slider:GetName() .. "Text"]

    slider.low:SetText("0.5")
    slider.high:SetText("2.0")
    slider.text:SetText("Main Menu Bar Scale")

    -- Slider Value Display (placed below the slider to prevent overlap)
    slider.value = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    slider.value:SetPoint("TOP", slider, "BOTTOM", 0, -5) -- Adjusted position
    slider.value:SetText(string.format("%.1f", slider:GetValue()))

    -- Slider OnValueChanged Script
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 10 + 0.5) / 10 -- Round to 1 decimal
        if MainMenuBar then
            MainMenuBar:SetScale(value)
            -- Save the scale value in SavedVariables
            MMBarScalerDB.scale = value
            -- Update the displayed value
            self.value:SetText(string.format("%.1f", value))
            -- Uncomment the following line to enable chat messages
            -- print(string.format("Main Menu Bar scale set to %.1f", value))
        else
            print("MMBarScaler: MainMenuBar not found.")
        end
    end)

    -- Create a Close Button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeButton:SetSize(80, 22)
    closeButton:SetText("Close")
    closeButton:SetPoint("BOTTOM", 0, 10)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    -- Create a Reset Button
    local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    resetButton:SetSize(80, 22)
    resetButton:SetText("Reset")
    resetButton:SetPoint("BOTTOM", closeButton, "RIGHT", 50, 0)
    resetButton:SetScript("OnClick", function()
        local defaultScale = 1.0
        slider:SetValue(defaultScale)
        -- Uncomment the following line to enable chat messages
        -- print("Main Menu Bar scale reset to default (1.0)")
    end)

    -- **New Addition:** Instruction Textbox
    local instruction = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    instruction:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -60) -- Adjust position as needed
    instruction:SetWidth(280)
    instruction:SetHeight(20)
    instruction:SetJustifyH("LEFT")
    instruction:SetText("Type /mmbarscalergui to open the menu.")

    -- Assign the frame to a global variable for reuse
    MMBarScalerFrame = frame
end

-- Function to open the GUI via slash command
local function OpenMMBarScalerGUI()
    CreateMMBarScalerFrame()
end

-- Register the GUI slash commands
SlashCmdList["MMBARSCALEGUI"] = OpenMMBarScalerGUI

-- Initialize SavedVariables
local function InitializeSavedVariables()
    if not MMBarScalerDB then
        MMBarScalerDB = {}
    end
    -- Set default scale if not set
    if not MMBarScalerDB.scale then
        MMBarScalerDB.scale = 1.2
    end
end

-- Apply the saved scale on addon load
local function ApplySavedScale()
    local savedScale = MMBarScalerDB.scale or 1.2
    if MainMenuBar then
        MainMenuBar:SetScale(savedScale)
    else
        print("MMBarScaler: MainMenuBar not found.")
    end
    -- **New Addition:** Chat message on login
    print("MMBarScaler loaded. Type /mmbarscalergui to open the menu.")
end

-- Event Handling
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        InitializeSavedVariables()
        ApplySavedScale()
    end
end)
