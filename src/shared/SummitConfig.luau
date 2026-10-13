-- Shared configuration is public. Optional personalization is reserved, not implemented.
local SummitConfig = {
    SchemaVersion = 1,
    PresetId = "Neutral",
    Core = {
        Enabled = true,
        BannerTitle = "Puncak Tercapai!",
        BannerSubtitle = "Selamat! Kamu telah menaklukkan seluruh pulau langit.",
        BannerDurationSeconds = 5,
        FinishZoneName = "SummitFinishZone",
    },
    Personalization = {
        DisplayName = "",
        CustomMessage = "",
        Cake = { Enabled = false, AnchorId = "CakeAnchor" },
        Decorations = { Enabled = false, AnchorId = "DecorationAnchor" },
        Confetti = { Enabled = false, DurationSeconds = 4, MaxLiveParticles = 80 },
        Fireworks = { Enabled = false, DurationSeconds = 5, AnchorId = "FireworksAnchor" },
        Audio = { Enabled = false, SoundId = "", Volume = 0.5 },
        Camera = { Enabled = false, DurationSeconds = 5, AllowSkip = true },
    },
    Accessibility = { RespectReducedMotion = true, RespectAudioMute = true },
    Replay = { Enabled = false, CooldownSeconds = 10, GrantRewards = false },
}

-- Unsupported schemas/presets and malformed fields always fall back to a static banner.
function SummitConfig.resolve(config)
    local title = "Puncak Tercapai!"
    local subtitle = "Selamat! Kamu telah menaklukkan seluruh pulau langit."
    local duration = 5
    if type(config) == "table" and config.SchemaVersion == 1 and config.PresetId == "Neutral"
        and type(config.Core) == "table" then
        local core = config.Core
        if type(core.BannerTitle) == "string" and #core.BannerTitle > 0 and #core.BannerTitle <= 120 then
            title = core.BannerTitle
        end
        if type(core.BannerSubtitle) == "string" and #core.BannerSubtitle <= 300 then
            subtitle = core.BannerSubtitle
        end
        if type(core.BannerDurationSeconds) == "number" and core.BannerDurationSeconds == core.BannerDurationSeconds then
            duration = math.clamp(core.BannerDurationSeconds, 1, 10)
        end
    end
    return { Title = title, Subtitle = subtitle, DurationSeconds = duration }
end

return SummitConfig
