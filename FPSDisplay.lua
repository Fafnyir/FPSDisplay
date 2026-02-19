------------------------------------------------------------
-- FPS Display  •  Fafnyir
-- Shows current FPS and lets the user move, hide, or
-- change the font.  Starts hidden by default.
------------------------------------------------------------

-- ❶‑‑‑ Default constants
local DEFAULT_FONT      = "Interface\\AddOns\\FPSDisplay\\Fonts\\Font.ttf"
local DEFAULT_FONT_SIZE = 18

-- ❷‑‑‑ Saved‑variables table (declared in TOC as `FPSDisplaySettings`)
FPSDisplaySettings = FPSDisplaySettings or {}

-- Initialise defaults only once
if FPSDisplaySettings.shown == nil       then FPSDisplaySettings.shown = false  end -- start hidden
if FPSDisplaySettings.font  == nil       then FPSDisplaySettings.font  = DEFAULT_FONT end
if FPSDisplaySettings.fontSize == nil    then FPSDisplaySettings.fontSize = DEFAULT_FONT_SIZE end

------------------------------------------------------------
-- ❸‑‑‑ Frame + FontString
local fpsFrame = CreateFrame("Frame", "FPSDisplayFrame", UIParent, "BackdropTemplate")
fpsFrame:SetSize(100, 30)
fpsFrame:SetMovable(true)
fpsFrame:EnableMouse(true)
fpsFrame:RegisterForDrag("LeftButton")

local fpsText = fpsFrame:CreateFontString(nil, "OVERLAY")
fpsText:SetPoint("CENTER")
fpsText:SetFont(FPSDisplaySettings.font, FPSDisplaySettings.fontSize, "OUTLINE")

-- Apply saved position (if any)
if FPSDisplaySettings.position then
    fpsFrame:SetPoint(
        FPSDisplaySettings.position.point,
        UIParent,
        FPSDisplaySettings.position.relativePoint,
        FPSDisplaySettings.position.xOfs,
        FPSDisplaySettings.position.yOfs
    )
else
    fpsFrame:SetPoint("CENTER")
end

-- Apply saved visibility
if FPSDisplaySettings.shown then
    fpsFrame:Show()
else
    fpsFrame:Hide()
end

------------------------------------------------------------
-- ❹‑‑‑ Helpers
local fontTest = CreateFont("FPSDisplayFontTest")
local function IsFontFileValid(path)
    return pcall(fontTest.SetFont, fontTest, path, 12)
end

local function SavePosition()
    local point, _, relativePoint, xOfs, yOfs = fpsFrame:GetPoint()
    FPSDisplaySettings.position = {
        point = point, relativePoint = relativePoint,
        xOfs  = xOfs,  yOfs = yOfs,
    }
end

local function ToggleFPSDisplay()
    local show = not fpsFrame:IsShown()
    FPSDisplaySettings.shown = show
    if show then
        fpsFrame:Show()
        print("FPS Display: Shown")
    else
        fpsFrame:Hide()
        print("FPS Display: Hidden")
    end
end

------------------------------------------------------------
-- ❺‑‑‑ Movement handlers
fpsFrame:SetScript("OnDragStart", fpsFrame.StartMoving)
fpsFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

------------------------------------------------------------
-- ❻‑‑‑ Update ticker (4× sec)
C_Timer.NewTicker(0.25, function()
    if fpsFrame:IsShown() then
        fpsText:SetFormattedText("FPS: %.1f", GetFramerate())
    end
end)

------------------------------------------------------------
-- ❼‑‑‑ Slash commands
SLASH_FPSDISPLAY1 = "/fpsdisplay"
SlashCmdList.FPSDISPLAY = function(msg)
    local cmd, rest = msg:match("^(%S*)%s*(.*)$")
    cmd = cmd:lower()

    -- /fpsdisplay font <path> <size>
    if cmd == "font" then
        local path, size = rest:match("^\"([^\"]+)\"%s+(%d+)$")     -- quoted
                       or rest:match("^(%S+)%s+(%d+)$")             -- unquoted
        size = tonumber(size)
        if not path or not size or size <= 0 then
            print("Usage: /fpsdisplay font <path> <size>")
            return
        end

        if IsFontFileValid(path) then
            fpsText:SetFont(path, size, "OUTLINE")
            FPSDisplaySettings.font     = path
            FPSDisplaySettings.fontSize = size
            print(("FPS Display: Font set to %s (%d)"):format(path, size))
        else
            print("FPS Display: Invalid font path.")
        end

    -- /fpsdisplay reset
    elseif cmd == "reset" then
        fpsFrame:ClearAllPoints()
        fpsFrame:SetPoint("CENTER")
        SavePosition()
        print("FPS Display: Position reset to center.")

    -- /fpsdisplay toggle
    elseif cmd == "toggle" or cmd == "" then
        ToggleFPSDisplay()

    -- /fpsdisplay help
    else
        print("FPS Display commands:")
        print("  /fpsdisplay toggle      Show/Hide the FPS display")
        print("  /fpsdisplay reset       Reset position to center")
        print("  /fpsdisplay font <path> <size>")
        print("                           Change font (e.g., Interface\\AddOns\\YourMedia\\fonts\\MyFont.ttf 18)")
    end
end
