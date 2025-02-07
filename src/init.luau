--!strict

--[[
    Stylis-Fed ban module by LeahNeko, GNX and ThingCorp.
    Bans every known Stylis fed using the Roblox Ban API.

    Usage: ```luau
        require(path.to.StylisFed).ban()
	```

	Preferred way to run this is to use the server console in a production server.
]]

-- Modules
local BAN_CONFIGS = require(script.BanConfigs)
local Utils = require(script.Utils)
local Types = require(script.Types)

-- Services
local Players = game:GetService('Players')

-- Constants
local MAX_BAN_ATTEMPTS = 3
local DEFAULT_BAN_CONFIG: Types.FullBanConfig = {
	UserIds = {},
	ApplyToUniverse = true,
	Duration = -1, -- Permanent
	DisplayReason = 'Particularly Bioluminescent Individual',
	PrivateReason = 'Stylis Fed',
	ExcludeAltAccounts = false,
}

-- Class
local StylisFed = {} :: Types.StylisFedImpl

--[[
    Ban every Stylis fed.
]]
function StylisFed.ban()
	local startTime = os.clock()
	local banConfigs: { Types.AnyBanConfig } = BAN_CONFIGS

	local total = #banConfigs
	local banAttempts = 0

	print(`Banning {total} users...`)

	-- Retry loop
	while true do
		banConfigs = StylisFed._attemptBans(banConfigs)
		banAttempts += 1

		-- Exit if all users have been banned
		if #banConfigs == 0 then
			break
		end

		-- Exit if max ban attempts have been reached
		if banAttempts >= MAX_BAN_ATTEMPTS then
			warn(`Exhausted max ban attempts. ({banAttempts}/{banAttempts})`)
			break
		end

		print(`Failed to ban {#banConfigs} users. Retrying... ({banAttempts}/{MAX_BAN_ATTEMPTS})`)
		task.wait(0.5)
	end

	print(`Done. Banned {total - #banConfigs}/{total} users in {Utils.round(os.clock() - startTime, 2)}s.`)
end

--[[
	Attempt to ban a list of ban configs.
	Returns a list of BanConfigs that failed to ban.
]]
function StylisFed._attemptBans(configs: { Types.AnyBanConfig }): { Types.FullBanConfig }
	local taskCollection: { thread } = table.create(#configs)
	local failedConfigs: { Types.FullBanConfig } = {}

	-- We could use batch banning here but roblox makes you regex a string
	-- to get the UserIds that failed to ban and I don't wanna deal with that lol
	for i, idOrConfig in configs do
		-- Handle custom ban config
		local banConfig = StylisFed._ensureBanConfig(idOrConfig)

		if not banConfig then
			warn(`Ignoring bad BanConfig at index {i}.`)
			continue
		end

		-- Try to ban player
		local coro = task.defer(function()
			local success, err = pcall(function()
				Players:BanAsync(banConfig)
			end)

			-- Handle error
			if not success then
				warn(banConfig.UserIds[1], 'failed with error:\n', err)
				table.insert(failedConfigs, banConfig)
			end
		end)

		table.insert(taskCollection, coro)
	end

	-- Wait for all tasks to finish
	Utils.awaitAll(taskCollection)

	return failedConfigs
end

function StylisFed._ensureBanConfig(idOrConfig: Types.AnyBanConfig): Types.FullBanConfig?
	if type(idOrConfig) == 'table' then
		if idOrConfig['UserIds'] and idOrConfig['UserIds'][1] then
			return idOrConfig :: Types.FullBanConfig
		elseif not idOrConfig['UserId'] then
			return nil
		end

		local banConfig = table.clone(DEFAULT_BAN_CONFIG)
		banConfig.UserIds = { idOrConfig['UserId'] }
		banConfig.ApplyToUniverse = idOrConfig.ApplyToUniverse or banConfig.ApplyToUniverse
		banConfig.Duration = idOrConfig.Duration or banConfig.Duration
		banConfig.DisplayReason = idOrConfig.DisplayReason or banConfig.DisplayReason
		banConfig.PrivateReason = idOrConfig.PrivateReason or banConfig.PrivateReason
		banConfig.ExcludeAltAccounts = idOrConfig.ExcludeAltAccounts or banConfig.ExcludeAltAccounts
		return banConfig
	end

	-- idOrConfig is a number
	local banConfig = table.clone(DEFAULT_BAN_CONFIG)
	banConfig.UserIds = { idOrConfig }
	return banConfig
end

return StylisFed
