local K, C = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local string_find = _G.string.find
local string_format = _G.string.format
local table_insert = _G.table.insert
local table_wipe = _G.table.wipe

local C_AzeriteEmpoweredItem = _G.C_AzeriteEmpoweredItem
local EmbeddedItemTooltip = _G.EmbeddedItemTooltip
local GameTooltip = _G.GameTooltip
local GetSpellInfo = _G.GetSpellInfo
local IsAddOnLoaded = _G.IsAddOnLoaded
local ItemRefTooltip = _G.ItemRefTooltip
local ShoppingTooltip1 = _G.ShoppingTooltip1

-- Credit: AzeriteTooltip, by jokair9
function Module:AzeriteArmor()
	local tipList = {}
	local function scanTooltip(tooltip)
		for i = 9, tooltip:NumLines() do
			local line = _G[tooltip:GetName().."TextLeft"..i]
			local text = line:GetText()
			if text and string_find(text, "%- ") then
				table_insert(tipList, i)
			end
		end
		return #tipList
	end

	local iconString = "|T%s:18:22:0:0:64:64:5:59:5:59"
	local function getIconString(icon, known)
		if known then
			return string_format(iconString..":255:255:255|t", icon)
		else
			return string_format(iconString..":120:120:120|t", icon)
		end
	end

	local powerData = {}
	local function convertPowerID(id)
		local spellID = powerData[id]
		if not spellID then
			local powerInfo = C_AzeriteEmpoweredItem.GetPowerInfo(id)
			if powerInfo and powerInfo.spellID then
				spellID = powerInfo.spellID
				powerData[id] = spellID
			end
		end
		return spellID
	end

	local function lookingForAzerite(tooltip, powerName)
		for i = 8, tooltip:NumLines() do
			local line = _G[tooltip:GetName().."TextLeft"..i]
			local text = line:GetText()
			if text and string_find(text, "%- "..powerName) then
				return true
			end
		end
	end

	local cache = {}
	local function updateAzeriteArmor(self)
		local link = select(2, self:GetItem())
		if not link then
			return
		end

		if not C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link) then
			return
		end

		local allTierInfo = cache[link]
		if not allTierInfo then
			allTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfoByItemID(link)
			cache[link] = allTierInfo
		end

		if not allTierInfo then
			return
		end

		local count = scanTooltip(self)
		local index = 1
		for i = 1, #allTierInfo do
			local powerIDs = allTierInfo[i].azeritePowerIDs
			if powerIDs[1] == 13 then
				break
			end

			local tooltipText = ""
			for _, id in ipairs(powerIDs) do
				local spellID = convertPowerID(id)
				if not spellID then
					break
				end
				local name, _, icon = GetSpellInfo(spellID)
				local found = lookingForAzerite(self, name)
				if found then
					tooltipText = tooltipText.." "..getIconString(icon, true)
				else
					tooltipText = tooltipText.." "..getIconString(icon)
				end
			end

			if tooltipText ~= "" and count > 0 then
				local line = _G[self:GetName().."TextLeft"..tipList[index]]
				line:SetText(line:GetText().."\n "..tooltipText)
				count = count - 1
				index = index + 1
			end
		end

		table_wipe(tipList)
	end

	GameTooltip:HookScript("OnTooltipSetItem", updateAzeriteArmor)
	ItemRefTooltip:HookScript("OnTooltipSetItem", updateAzeriteArmor)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", updateAzeriteArmor)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", updateAzeriteArmor)
end

function Module:CreateTooltipAzerite()
	if not C["Tooltip"].AzeriteArmor then
		return
	end

	if IsAddOnLoaded("AzeriteTooltip") then
		return
	end

	self:AzeriteArmor()
end