local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSetRole = UnitSetRole

local lastRoleChangeTime = 0
local currentRole = nil

-- Changes the player's role if it has not been changed in the last 2 seconds and the player is not in combat
local function changePlayerRole(role)
	local currentTime = GetTime()
	if not InCombatLockdown() and currentTime - lastRoleChangeTime > 2 and UnitGroupRolesAssigned("player") ~= role then
		if UnitSetRole("player", role) then
			lastRoleChangeTime = currentTime
			currentRole = role
			print("Changed role to " .. role)
		end
	end
end

function Module:SetupAutoRole()
	-- Check if the player is eligible to change roles
	if K.Level < 10 or InCombatLockdown() or not IsInGroup() or IsPartyLFG() then
		return
	end

	-- Get the player's specialization and role
	local spec = GetSpecialization()
	if spec then
		local role = GetSpecializationRole(spec)

		-- Change the player's role if it has changed
		if role ~= currentRole then
			changePlayerRole(role)
		end
	else
		changePlayerRole("No Role")
	end
end

function Module:CreateAutoSetRole()
	-- Check if the AutoSetRole option is enabled
	if not C["Automation"].AutoSetRole then
		return
	end

	-- Register events for updating the player's role
	K:RegisterEvent("PLAYER_TALENT_UPDATE", self.SetupAutoRole)
	K:RegisterEvent("GROUP_ROSTER_UPDATE", self.SetupAutoRole)

	-- Unregister the role poll popup event to prevent it from resetting the player's role
	RolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")
end
