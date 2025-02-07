--!native
--!strict

local Utils = {}

--[[
	Utility function to await all coroutines to have the 'dead' status.
]]
function Utils.awaitAll(coros: { thread })
	while next(coros) do
		task.wait()
		for i, coro in coros do
			if coroutine.status(coro) ~= 'dead' then
				break
			else
				coros[i] = nil
			end
		end
	end
end

--[[
	Round to `ndigits` number of decimal places.
	If no `ndigits` is provided, round to the nearest integer.
]]
function Utils.round(num: number, ndigits: number?): number
	local mult = 10 ^ (ndigits or 0)
	return math.floor(num * mult + 0.5) / mult
end

return Utils
