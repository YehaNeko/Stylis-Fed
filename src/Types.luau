--!strict

local Types = {}

export type FullBanConfig = {
	UserIds: { number },
	ApplyToUniverse: boolean?,
	Duration: number,
	DisplayReason: string, -- 400 char limit
	PrivateReason: string, -- 1000 char limit
	ExcludeAltAccounts: boolean?,
}

export type CustomBanConfig = number | {
	UserId: number,
	ApplyToUniverse: boolean?,
	Duration: number?,
	DisplayReason: string?, -- 400 char limit
	PrivateReason: string?, -- 1000 char limit
	ExcludeAltAccounts: boolean?,
}

export type AnyBanConfig = FullBanConfig | CustomBanConfig

export type StylisFedImpl = {
	ban: () -> (),
	_attemptBans: (configs: { AnyBanConfig }) -> { FullBanConfig },
	_ensureBanConfig: (config: AnyBanConfig) -> FullBanConfig?,
}

return Types
