local ui = {}

require "common.func"
local view = require "common.view"
local i18n = require "res.i18n"
local lbl = require "res.lbl"
local img = require "res.img"
local audio = require "res.audio"
local json = require "res.json"
local player = require "data.player"
local activityData = require "data.activity"
local NetClient = require "net.netClient"
local netClient = NetClient:getInstance()
local tipsequip = require "ui.tips.equip"
local tipsitem = require "ui.tips.item"

function ui.create()
	local IDS = activityData.IDS
	local ItemType = {
		Item = 1,
		Equip = 2,
	}
	local st1 = activityData.getStatusById(IDS.SCORE_SPESUMMON.ID)
	local MaxPoints = st1.cfg.instruct

    local layer = CCLayer:create()

    local board = CCSprite:create()
    board:setContentSize(CCSizeMake(570, 438))
    board:setScale(view.minScale)
    board:setAnchorPoint(CCPoint(0, 0))
    board:setPosition(scalep(362, 60))
    layer:addChild(board)
    --drawBoundingbox(layer, board)
    local board_w = board:getContentSize().width
    local board_h = board:getContentSize().height

    img.unload(img.packedOthers.ui_activity_spesummon)
    img.unload(img.packedOthers.ui_activity_spesummon_cn)
    if i18n.getCurrentLanguage() == kLanguageChinese then
        img.load(img.packedOthers.ui_activity_spesummon_cn)
    else
        img.load(img.packedOthers.ui_activity_spesummon)
    end
    local banner
    if i18n.getCurrentLanguage() == kLanguageKorean then
        banner = img.createUISprite("activity_spesummon_board_kr.png")
    elseif i18n.getCurrentLanguage() == kLanguageChineseTW then
        banner = img.createUISprite("activity_spesummon_board_tw.png")
    elseif i18n.getCurrentLanguage() == kLanguageJapanese then
        banner = img.createUISprite("activity_spesummon_board_jp.png")
    elseif i18n.getCurrentLanguage() == kLanguageRussian then
        banner = img.createUISprite("activity_spesummon_board_ru.png")
    elseif i18n.getCurrentLanguage() == kLanguagePortuguese then
        banner = img.createUISprite("activity_spesummon_board_pt.png")
    elseif i18n.getCurrentLanguage() == kLanguageSpanish then
        banner = img.createUISprite("activity_spesummon_board_sp.png")
    else
        banner = img.createUISprite(img.ui.activity_spesummon_board)
    end
    banner:setAnchorPoint(CCPoint(0.5, 1))
    banner:setPosition(CCPoint(board_w/2-10, board_h-8))
    board:addChild(banner)

    local lbl_cd = lbl.createFont2(14, "", ccc3(0xa5, 0xfd, 0x47))
    lbl_cd:setAnchorPoint(CCPoint(0, 0.5))
    lbl_cd:setPosition(CCPoint(287, 23))
    banner:addChild(lbl_cd)
    local lbl_cd_des = lbl.createFont2(14, i18n.global.activity_to_end.string)
    lbl_cd_des:setAnchorPoint(CCPoint(0, 0.5))
    lbl_cd_des:setPosition(CCPoint(358, 23))
    banner:addChild(lbl_cd_des)

    local item_des = "GET %s POINTS"
    if i18n.getCurrentLanguage() == kLanguageChinese 
        or i18n.getCurrentLanguage() == kLanguageChineseTW then
        item_des = "?????? %s ??????"
    end
    item_des = i18n.global.spesummon_gain.string .. " %s " .. i18n.global.arena_main_score.string

    local function createItem(itemObj)
        local temp_item = img.createUI9Sprite(img.ui.bottom_border_2)
        temp_item:setPreferredSize(CCSizeMake(542, 84))
        local item_w = temp_item:getContentSize().width
        local item_h = temp_item:getContentSize().height
        -- des
        local lbl_des = lbl.createFont1(16, string.format(item_des, itemObj.instruct), ccc3(0x5d, 0x2d, 0x12))
        lbl_des:setAnchorPoint(CCPoint(0, 0.5))
        lbl_des:setPosition(CCPoint(18, 55))
        temp_item:addChild(lbl_des)
        -- pgb
        local pgb_bg = img.createUI9Sprite(img.ui.playerInfo_process_bar_bg)
        pgb_bg:setPreferredSize(CCSizeMake(203, 20))
        pgb_bg:setPosition(CCPoint(120, 26))
        temp_item:addChild(pgb_bg)
        local pgb_fg = img.createUISprite(img.ui.activity_pgb_casino)
        local pgb = createProgressBar(pgb_fg)
        pgb:setPosition(CCPoint(pgb_bg:getContentSize().width/2, pgb_bg:getContentSize().height/2))
        pgb_bg:addChild(pgb)
        local numerator = 0
        if st1.limits >= itemObj.instruct then
            numerator = itemObj.instruct
        else
            numerator = st1.limits
        end
        pgb:setPercentage(numerator*100/itemObj.instruct)
        local lbl_pgb = lbl.createFont2(14, numerator .. "/" .. itemObj.instruct)
        lbl_pgb:setAnchorPoint(CCPoint(0.5, 0))
        lbl_pgb:setPosition(CCPoint(pgb_bg:getContentSize().width/2, pgb_bg:getContentSize().height/2))
        pgb_bg:addChild(lbl_pgb)
        -- rewards
        local r_pos = { [1] = 292, [2] = 357, [3] = 422, [4] = 487}
        local masks = {}
        for ii=1,#itemObj.rewards do
            local _obj = itemObj.rewards[ii]
            if _obj.type == ItemType.Equip then  -- equip
                local _item0 = img.createEquip(_obj.id, _obj.num)
                local _item = CCMenuItemSprite:create(_item0, nil)
                _item:setScale(0.7)
                _item:setPosition(CCPoint(r_pos[ii], item_h/2))
                local _item_menu = CCMenu:createWithItem(_item)
                _item_menu:setPosition(CCPoint(0, 0))
                temp_item:addChild(_item_menu)
                _item:registerScriptTapHandler(function()
                    audio.play(audio.button)
                    layer:getParent():getParent():addChild(tipsequip.createById(_obj.id), 1000)
                end)
            elseif _obj.type == ItemType.Item then
                local _item0 = img.createItem(_obj.id, _obj.num)
                local _item = CCMenuItemSprite:create(_item0, nil)
                _item:setScale(0.7)
                _item:setPosition(CCPoint(r_pos[ii], item_h/2))
                local _item_menu = CCMenu:createWithItem(_item)
                _item_menu:setPosition(CCPoint(0, 0))
                temp_item:addChild(_item_menu)
                _item:registerScriptTapHandler(function()
                    audio.play(audio.button)
                    layer:getParent():getParent():addChild(tipsitem.createForShow({id=_obj.id}), 1000)
                end)
            end
            if st1.limits >= itemObj.instruct then
                local _mask = img.createUISprite(img.ui.hook_btn_mask)
                _mask:setScale(0.6)
                _mask:setPosition(CCPoint(r_pos[ii], item_h/2))
                temp_item:addChild(_mask)
                --local tickIcon = img.createUISprite(img.ui.login_month_finish)
                --tickIcon:setPosition(CCPoint(15, 15))
                local tickIcon = img.createUISprite(img.ui.hook_btn_sel)
                tickIcon:setPosition(CCPoint(_mask:getContentSize().width/2, _mask:getContentSize().height/2))
                _mask:addChild(tickIcon)
            end
        end
        -- received
        --if st1.limits >= itemObj.instruct then
        --    local icon_recv = img.createUISprite(img.ui.achieve_calim)
        --    icon_recv:setPosition(CCPoint(468, item_h/2))
        --    temp_item:addChild(icon_recv)
        --end

        temp_item.height = item_h
        return temp_item
    end

    local lineScroll = require "ui.lineScroll"
    local scroll_params = {
        width = 550,
        height = 241,
    }
    local scroll = lineScroll.create(scroll_params)
    scroll:setAnchorPoint(CCPoint(0, 0))
    scroll:setPosition(CCPoint(0, 3))
    board:addChild(scroll)
    layer.scroll = scroll

    local items = {}
    for ii=9,0,-1 do
		local sti = activityData.find(st1.id - ii)
        if sti then
            items[#items+1] = clone(sti.cfg)
        end
    end
    local function sortValue(_obj)
        if _obj.instruct <= st1.limits then
            return 10000 + _obj.instruct
        else
            return _obj.instruct
        end
    end
    table.sort(items, function(a, b)
        return sortValue(a) < sortValue(b)
        --if a.instruct >= st1.limits and b.instruct >= st1.limits then
        --    return a.instruct < b.instruct
        --elseif a.instruct >= st1.limits and b.instruct < st1.limits then
        --    return true
        --elseif a.instruct < st1.limits and b.instruct >= st1.limits then
        --    return false
        --elseif a.instruct < st1.limits and b.instruct < st1.limits then
        --    return a.instruct < b.instruct
        --end
    end)

    local function showList(listObjs)
        for ii=1,#listObjs do
            --if ii == 1 then
            --    scroll.addSpace(3)
            --end
            local tmp_item = createItem(listObjs[ii])
            tmp_item.obj = listObjs[ii]
            tmp_item.ax = 0.5
            tmp_item.px = scroll_params.width/2
            scroll.addItem(tmp_item)
            if ii ~= item_count then
                scroll.addSpace(3)
            end
        end
        scroll.setOffsetBegin()
    end
    showList(items)

    local last_update = os.time() - 1
    local function onUpdate(ticks)
        if os.time() - last_update < 1 then return end
        last_update = os.time()
        local remain_cd = st1.cd - (os.time() - activityData.pull_time)
        if remain_cd >= 0 then
            local time_str = time2string(remain_cd)
            lbl_cd:setString(time_str)
        else
        end
    end
    layer:scheduleUpdateWithPriorityLua(onUpdate, 0)

    --img.unload(img.packedOthers.ui_activity_summon_score)
    require("ui.activity.ban").addBan(layer, scroll)
    layer:setTouchSwallowEnabled(false)
    layer:setTouchEnabled(true)
    return layer
end

return ui
