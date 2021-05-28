-- 胜利结算

local ui = {}

require "common.const"
require "common.func"
local view = require "common.view"
local img = require "res.img"
local lbl = require "res.lbl"
local json = require "res.json"
local i18n = require "res.i18n"
local audio = require "res.audio"
local herosdata = require "data.heros"

function ui.create(video)
    local layer = require("fight.base.win").create()

    --layer.addVsScores(video)

    layer.addOkButton(function()
        require("fight.pvpgmill.loading").backToUI(video)
    end)

    --if video.hurts and #video.hurts > 0 then
    --    layer.addHurtsButton(video.atk.camp, video.def.camp, video.hurts, video)
    --end

    if video.rewards and #video.rewards > 0 then
        layer.addRewardIcons(video.rewards[1])
    end

    return layer
end

return ui