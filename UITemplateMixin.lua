local addonName, _ = ...

local db_default = {
    { text = "First" },
    { text = "Second" },
    { text = "Third" },
    { text = "Fourth" },
    { text = "Fifth" },
    { text = "Sixth" },
    { text = "Seventh" },
    { text = "Eighth" },
}
local AutoHideTimes = 5

do
    SendMessageDB = SendMessageDB or CopyTable(db_default)
    SendMessageUIDB = SendMessageUIDB or {}
    SendMessageUIDB.SendMessageMainButton = SendMessageUIDB.SendMessageMainButton or {
        point = "CENTER",
        relativePoint = "CENTER",
        x = 0,
        y = 0,
        scale = 1
    }
    SendMessageUIDB.SendMessageConfigFrame = SendMessageUIDB.SendMessageConfigFrame or {
        scale = 1
    }
end


local function substrChars(str, maxChars)
    maxChars = maxChars or 4
    local count = 0
    local i = 1
    local len = #str

    while i <= len and count < maxChars do
        local byte = string.byte(str, i)
        local charLen = 1
        local isChinese = false

        if byte >= 0xC0 and byte <= 0xDF then
            charLen = 2
        elseif byte >= 0xE0 and byte <= 0xEF then
            charLen = 3
            isChinese = true
        elseif byte >= 0xF0 and byte <= 0xF7 then
            charLen = 4
        end

        if i + charLen - 1 > len then
            break
        end

        if isChinese then
            count = count + 1
        else
            count = count + 0.5
        end

        i = i + charLen
    end

    return string.sub(str, 1, i - 1)
end


SendMessageTooltipMixin = {}

function SendMessageTooltipMixin:SetTooltipText(tooltipText)
    if type(tooltipText) == "string" and tooltipText ~= "" then
        self.tooltipText = tooltipText;
    else
        self.tooltipText = nil;
    end
end

function SendMessageTooltipMixin:OnLeave()
    if GameTooltip then
        GameTooltip:Hide();
    end
end

function SendMessageTooltipMixin:OnEnter()
    if not (self and self:IsVisible() and GameTooltip and self.tooltipText) then
        return;
    end
    GameTooltip:ClearLines();
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT", 20, 5);
    GameTooltip:AddLine(self.tooltipText);
    GameTooltip:Show();
end

function SendMessageOnMouseWheel(self, delta)
    local currentScale = self:GetScale()
    local newScale = currentScale + (delta * 0.1)
    newScale = math.max(0.5, math.min(1.5, newScale))
    self:SetScale(newScale)

    local widgetName = self:GetName()
    if widgetName and SendMessageUIDB[widgetName] then
        SendMessageUIDB[widgetName].scale = newScale
    end
end

SendMessageMainButtonMixin = {}
SendMessageMainButtonMixin.lastClickTime = 0


function SendMessageMainButtonMixin:OnLoad()
    self:SetText(SEND_MESSAGE)
    self:RegisterEvent("ADDON_LOADED")
    self.SendMessageMainFrame = CreateFrame("Frame", "SendMessageMainFrame", self, "SendMessageMainFrameTempalte")
    SendMessageConfigFrame = _G["SendMessageConfigFrame"]
end

function SendMessageMainButtonMixin:OnEnter()
    if not self.SendMessageMainFrame then return end
    self.SendMessageMainFrame:Show()
end

function SendMessageMainButtonMixin:OnLeave()
    if not self.SendMessageMainFrame then return end
    local function Hide()
        self.SendMessageMainFrame:Hide()
    end
    C_Timer.After(AutoHideTimes, Hide)
end

function SendMessageMainButtonMixin:OnClick()
    local currentTime = GetTime()
    if currentTime - (self.lastClickTime or 0) < 0.5 then
        return
    end

    self.lastClickTime = currentTime

    if not SendMessageConfigFrame then return end
    SendMessageConfigFrame:SetShown(not SendMessageConfigFrame:IsShown())

    for i = 1, #db_default do
        local editBox = SendMessageConfigFrame["EditBox" .. i]
        if editBox then
            local text = SendMessageDB[i] and SendMessageDB[i].text or db_default[i].text
            editBox:SetText(text)
        end
    end
end

function SendMessageMainButtonMixin:OnDragStop()
    self:StopMovingOrSizing()
    local widgetName = self:GetName()
    local widgetData = widgetName and SendMessageUIDB[widgetName]
    if widgetData then
        local point, _, relativePoint, x, y = self:GetPoint()
        widgetData.point = point
        widgetData.relativePoint = relativePoint
        widgetData.x = x
        widgetData.y = y
    end
end

function SendMessageMainButtonMixin:OnEvent(event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        local widgetName = self:GetName()
        if widgetName and SendMessageUIDB[widgetName] then
            local widgetData = SendMessageUIDB[widgetName]
            self:ClearAllPoints()
            self:SetPoint(
                widgetData.point,
                UIParent,
                widgetData.relativePoint,
                widgetData.x,
                widgetData.y
            )
            self:SetScale(widgetData.scale or 1.0)
        end
        if self.SendMessageMainFrame then
            for i = 1, #db_default do
                local button = self.SendMessageMainFrame["TextButton" .. i]
                if button then
                    local text = SendMessageDB[i] and SendMessageDB[i].text or db_default[i].text
                    button:SetText(substrChars(text))
                    button:SetTooltipText(text)
                end
            end
        end
        if SendMessageConfigFrame then
            SendMessageConfigFrame:SetScale(SendMessageUIDB.SendMessageConfigFrame.scale or 1)
        end
        self:UnregisterEvent("ADDON_LOADED")
    end
end

SendMessageTextButtonMixin = CreateFromMixins(SendMessageTooltipMixin)

function SendMessageTextButtonMixin:GetButtonInfo()
    local parent = self:GetParent()
    if not parent then return nil, nil end

    for key, value in pairs(parent) do
        if type(key) == "string" and value == self then
            local buttonNum = key:match("TextButton(%d+)")
            return key, buttonNum and tonumber(buttonNum) or nil
        end
    end

    return nil, nil
end

-- Now can send messages in LFG Group
function SendMessageTextButtonMixin:OnClick(button)
    local buttonKey, buttonNum = self:GetButtonInfo()
    if not buttonKey then return end
    local isGroupLeader = UnitIsGroupLeader("player")
    if buttonNum then
        local text = SendMessageDB[buttonNum] and SendMessageDB[buttonNum].text or db_default[buttonNum].text

        local inLFGDungeon = IsInLFGDungeon()
        local inInstance, instanceType = IsInInstance()
        local channel

        local numGroupMembers = GetNumGroupMembers()
        if button == "LeftButton" then
            channel = (inLFGDungeon or (inInstance and (instanceType == "pvp" or instanceType == "arena" or instanceType == "scenario"))) and
                "INSTANCE_CHAT" or
                (numGroupMembers > 0 and (numGroupMembers > 5 and "RAID" or "PARTY") or "SAY")
        elseif button == "RightButton" then
            channel = (inLFGDungeon or (inInstance and (instanceType == "pvp" or instanceType == "arena" or instanceType == "scenario"))) and
                "INSTANCE_CHAT" or
                (numGroupMembers > 0 and (numGroupMembers > 5 and (isGroupLeader and "RAID_WARNING" or "RAID") or "PARTY") or "SAY")
        end


        
        if channel then
            C_ChatInfo.SendChatMessage(text, channel)
        end
    elseif buttonKey == "ResetButton" then
        if isGroupLeader then
            ResetInstances()
        end
    elseif buttonKey == "LeveGroupButton" then
        C_PartyInfo.LeaveParty()
    end
end

function SendMessageTextButtonMixin:SetText(text)
    if not text then return end
    self.text:SetText(text)
end

function SendMessageTextButtonMixin:OnLoad()
    local buttonKey = self:GetButtonInfo()
    if not buttonKey then return end

    local buttonNum = buttonKey:match("TextButton(%d+)")
    if buttonNum then
        return
    elseif buttonKey == "ResetButton" then
        local resetText = RESET .. INSTANCE
        self:SetText(resetText)
        self:SetTooltipText(resetText)
        self.text:SetVertexColor(1, 1, 0)
    elseif buttonKey == "LeveGroupButton" then
        local LeveGroupButtonText = LEAVE .. STATUS_TEXT_PARTY
        self:SetText(LeveGroupButtonText)
        self.text:SetVertexColor(1, 0, 0)
        self:SetTooltipText(LeveGroupButtonText)
    end
end

ConfigEditBoxMixin = {}

function ConfigEditBoxMixin:GetEditBoxKey()
    local parent = self:GetParent()
    if not parent then return nil end

    for key, value in pairs(parent) do
        if type(key) == "string" and value == self then
            return key
        end
    end

    return nil
end

function ConfigEditBoxMixin:GetEditBoxIndex()
    local editBoxKey = self:GetEditBoxKey()
    if not editBoxKey then return nil end

    local editBoxNum = editBoxKey:match("EditBox(%d+)")
    return editBoxNum and tonumber(editBoxNum) or nil
end

function ConfigEditBoxMixin:SaveText()
    local index = self:GetEditBoxIndex()
    if not index or not db_default[index] then return end

    local text = self:GetText()
    if text and text ~= "" then
        SendMessageDB[index].text = text

        local mainFrame = _G["SendMessageMainFrame"]
        if mainFrame then
            local button = mainFrame["TextButton" .. index]
            if button then
                button:SetText(substrChars(text))
                button:SetTooltipText(text)
            end
        end
    end
end

function ConfigEditBoxMixin:ResetText()
    local index = self:GetEditBoxIndex()
    if not index or not db_default[index] then return end

    local textData = SendMessageDB[index] or db_default[index]
    if textData and textData.text then
        self:SetText(textData.text)
    end
end

function ConfigEditBoxMixin:OnLoad()
    if not db_default then return end

    local index = self:GetEditBoxIndex()
    if not index then return end

    if index <= #db_default then
        local textData = SendMessageDB[index]
        if textData and textData.text then
            self:SetText(textData.text)
        end
    end
end

function ConfigEditBoxMixin:OnEditFocusLost()
    self:ResetText()
end

function ConfigEditBoxMixin:OnEnterPressed()
    self:SaveText()
    self:ClearFocus()
end
