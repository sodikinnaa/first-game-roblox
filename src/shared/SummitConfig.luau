-- Shared configuration is public. Personal text/audio/camera remain disabled.
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
        -- Original pastel palette; native emitter texture only (no external assets).
        Confetti = {
            Enabled = true,
            Type = "World3D",
            DurationSeconds = 4,
            MaxLiveParticles = 48,
            Colors = { {255, 185, 205}, {180, 225, 255}, {195, 245, 210}, {245, 220, 175} },
        },
        Fireworks = { Enabled = false, DurationSeconds = 5, AnchorId = "FireworksAnchor" },
        Audio = { Enabled = false, SoundId = "", Volume = 0.5 },
        Camera = { Enabled = false, DurationSeconds = 5, AllowSkip = true },
    },
    Accessibility = { RespectReducedMotion = true, RespectAudioMute = true },
    Replay = { Enabled = true, CooldownSeconds = 10, GrantRewards = false },
}

-- Unsupported schemas/presets and malformed fields always fall back to a static banner.
function SummitConfig.resolve(config)
    local title = "Puncak Tercapai!"
    local subtitle = "Selamat! Kamu telah menaklukkan seluruh pulau langit."
    local duration = 5
    local confetti = nil
    local replay = nil
    local respectReducedMotion = true

    local isValidPreset = type(config) == "table" and config.SchemaVersion == 1
        and (config.PresetId == "Neutral" or config.PresetId == "Festive")
    if isValidPreset and type(config.Core) == "table" then
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

        if type(config.Personalization) == "table" and type(config.Personalization.Confetti) == "table" then
            local cf = config.Personalization.Confetti
            if cf.Enabled == true and cf.Type == "World3D" then
                local cfDuration = (type(cf.DurationSeconds) == "number" and cf.DurationSeconds == cf.DurationSeconds)
                    and math.clamp(cf.DurationSeconds, 3, 5) or 4
                local cfMax = (type(cf.MaxLiveParticles) == "number" and cf.MaxLiveParticles == cf.MaxLiveParticles)
                    and math.clamp(math.floor(cf.MaxLiveParticles), 40, 60) or 48
                local colors = {}
                if type(cf.Colors) == "table" then
                    for _, c in ipairs(cf.Colors) do
                        if #colors >= 8 then break end
                        if type(c) == "table" and #c == 3
                            and type(c[1]) == "number" and c[1] == c[1]
                            and type(c[2]) == "number" and c[2] == c[2]
                            and type(c[3]) == "number" and c[3] == c[3] then
                            table.insert(colors, {
                                math.clamp(math.floor(c[1]), 150, 255),
                                math.clamp(math.floor(c[2]), 150, 255),
                                math.clamp(math.floor(c[3]), 150, 255),
                            })
                        end
                    end
                end
                if #colors == 0 then
                    colors = { {255, 185, 205}, {180, 225, 255}, {195, 245, 210}, {245, 220, 175} }
                end
                confetti = {
                    Enabled = true,
                    Type = "World3D",
                    DurationSeconds = cfDuration,
                    MaxLiveParticles = cfMax,
                    Colors = colors,
                }
            end
        end

        if type(config.Replay) == "table" and config.Replay.Enabled == true then
            local cd = (type(config.Replay.CooldownSeconds) == "number" and config.Replay.CooldownSeconds == config.Replay.CooldownSeconds)
                and math.clamp(config.Replay.CooldownSeconds, 3, 30) or 10
            replay = {
                Enabled = true,
                CooldownSeconds = cd,
            }
        end

        if type(config.Accessibility) == "table" and config.Accessibility.RespectReducedMotion == false then
            respectReducedMotion = false
        end
    end

    return {
        Title = title,
        Subtitle = subtitle,
        DurationSeconds = duration,
        Confetti = confetti,
        Replay = replay,
        RespectReducedMotion = respectReducedMotion,
    }
end

return SummitConfig
