local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

-- Auto opening of items in bag (kAutoOpen by Kellett)

local _G = _G

local C_Container_GetContainerNumSlots = _G.C_Container.GetContainerNumSlots
local C_Container_GetContainerItemInfo = _G.C_Container.GetContainerItemInfo
local OPENING = _G.OPENING
local C_Container_GetContainerItemLink = _G.C_Container.GetContainerItemLink

local atBank
local atMail
local atMerchant

local function BankOpened()
	atBank = true
end

local function BankClosed()
	atBank = false
end

local function GuildBankOpened()
	atBank = true
end

local function GuildBankClosed()
	atBank = false
end

local function MailOpened()
	atMail = true
end

local function MailClosed()
	atMail = false
end

local function MerchantOpened()
	atMerchant = true
end

local function MerchantClosed()
	atMerchant = false
end

local function BagDelayedUpdate(event)
	if atBank or atMail or atMerchant then
		return
	end

	if InCombatLockdown() then
		return K:RegisterEvent("PLAYER_REGEN_ENABLED", BagDelayedUpdate)
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", BagDelayedUpdate)
	end

	for bag = 0, 4 do
		for slot = 0, C_Container_GetContainerNumSlots(bag) do
			local cInfo = C_Container_GetContainerItemInfo(bag, slot)
			if cInfo then
				if cInfo.hasLoot and not cInfo.isLocked and cInfo.itemID and C.AutoOpenItems[cInfo.itemID] then
					K.Print(K.SystemColor .. OPENING .. ":|r " .. C_Container_GetContainerItemLink(bag, slot))
					C_Container.UseContainerItem(bag, slot)
					return
				end
			end
		end
	end
end

function Module:CreateAutoOpenItems()
	if C["Automation"].AutoOpenItems then
		K:RegisterEvent("BANKFRAME_OPENED", BankOpened)
		K:RegisterEvent("BANKFRAME_CLOSED", BankClosed)
		K:RegisterEvent("GUILDBANKFRAME_OPENED", GuildBankOpened)
		K:RegisterEvent("GUILDBANKFRAME_CLOSED", GuildBankClosed)
		K:RegisterEvent("MAIL_SHOW", MailOpened)
		K:RegisterEvent("MAIL_CLOSED", MailClosed)
		K:RegisterEvent("MERCHANT_SHOW", MerchantOpened)
		K:RegisterEvent("MERCHANT_CLOSED", MerchantClosed)
		K:RegisterEvent("BAG_UPDATE_DELAYED", BagDelayedUpdate)
	else
		K:UnregisterEvent("BANKFRAME_OPENED", BankOpened)
		K:UnregisterEvent("BANKFRAME_CLOSED", BankClosed)
		K:UnregisterEvent("GUILDBANKFRAME_OPENED", GuildBankOpened)
		K:UnregisterEvent("GUILDBANKFRAME_CLOSED", GuildBankClosed)
		K:UnregisterEvent("MAIL_SHOW", MailOpened)
		K:UnregisterEvent("MAIL_CLOSED", MailClosed)
		K:UnregisterEvent("MERCHANT_SHOW", MerchantOpened)
		K:UnregisterEvent("MERCHANT_CLOSED", MerchantClosed)
		K:UnregisterEvent("BAG_UPDATE_DELAYED", BagDelayedUpdate)
	end
end
