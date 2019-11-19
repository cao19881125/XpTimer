XpTimer = LibStub("AceAddon-3.0"):NewAddon("XpTimer", "AceConsole-3.0","AceComm-3.0", "AceTimer-3.0")

local XpTimer = _G.XpTimer
local AceGUI = LibStub("AceGUI-3.0")

local CreateFrame = CreateFrame

XpTimer.events = CreateFrame("Frame")

XpTimer.events:SetScript("OnEvent", function(self, event, ...)
	if not XpTimer[event] then
		return
	end

	XpTimer[event](XpTimer, ...)
end)

function XpTimer:insert_space(frame)
    local target_label = AceGUI:Create("Label")
    target_label:SetText("   ")
    frame:AddChild(target_label)
end

function XpTimer:CreateMainWindow()

    local frame = AceGUI:Create("Frame")
    frame:SetTitle("经验统计")
    frame:SetStatusText("当前状态:停止")

    frame:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    frame:SetLayout("List")
    frame:SetWidth(400)
    frame:SetHeight(340)
    frame.frame:SetResizable(false)


    -- control group

    local ctl_btn_group = AceGUI:Create("SimpleGroup")
    ctl_btn_group:SetLayout("Flow")
    ctl_btn_group:SetWidth(380)
    frame:AddChild(ctl_btn_group)

    XpTimer.btn_start = AceGUI:Create("Button")
    XpTimer.btn_start:SetText("开始")
    XpTimer.btn_start:SetWidth(172)
    XpTimer.btn_start:SetCallback("OnClick", XpTimer.OnStartBtn)
    ctl_btn_group:AddChild(XpTimer.btn_start)

    --XpTimer.btn_pause = AceGUI:Create("Button")
    --XpTimer.btn_pause:SetText("暂停")
    --XpTimer.btn_pause:SetWidth(115)
    --XpTimer.btn_pause:SetCallback("OnClick", XpTimer.OnPauseBtn)
    --XpTimer.btn_pause:SetDisabled(true)
    --ctl_btn_group:AddChild(XpTimer.btn_pause)

    XpTimer.btn_stop = AceGUI:Create("Button")
    XpTimer.btn_stop:SetText("结束")
    XpTimer.btn_stop:SetWidth(172)
    XpTimer.btn_stop:SetCallback("OnClick", XpTimer.OnStopBtn)
    XpTimer.btn_stop:SetDisabled(true)
    ctl_btn_group:AddChild(XpTimer.btn_stop)


    XpTimer:insert_space(frame)

    -- target set group
    local target_set_group = AceGUI:Create("SimpleGroup")
    target_set_group:SetLayout("Flow")
    target_set_group:SetWidth(380)
    frame:AddChild(target_set_group)

    local tgt_set_label = AceGUI:Create("Label")
    tgt_set_label:SetText("目标经验设置(经验/小时)")
    tgt_set_label:SetWidth(200)
    target_set_group:AddChild(tgt_set_label)

    --local tgt_edt_group = AceGUI:Create("SimpleGroup")
    --tgt_edt_group:SetWidth(360)
    --tgt_edt_group:SetLayout("Flow")
    --target_set_group:AddChild(tgt_edt_group)

    XpTimer.tgt_set_editbox = AceGUI:Create("EditBox")
    XpTimer.tgt_set_editbox:SetWidth(160)
    XpTimer.tgt_set_editbox:SetCallback("OnEnterPressed", XpTimer.OnSetTargetBtn)
    target_set_group:AddChild(XpTimer.tgt_set_editbox)

    --local tgt_ensure_btn = AceGUI:Create("Button")
    --tgt_ensure_btn:SetText("确定")
    --tgt_ensure_btn:SetCallback("OnClick", XpTimer.OnSetTargetBtn)
    --tgt_ensure_btn:SetWidth(80)
    --tgt_edt_group:AddChild(tgt_ensure_btn)


    XpTimer:insert_space(frame)


    -- information label
    XpTimer.target_label = AceGUI:Create("Label")
    XpTimer.target_label:SetText("目标(经验/小时):0")
    XpTimer.target_label:SetWidth(360)
    frame:AddChild(XpTimer.target_label)

    XpTimer:insert_space(frame)

    XpTimer.accumulate_label = AceGUI:Create("Label")
    XpTimer.accumulate_label:SetText("累计时间:0分0秒   累计经验:0    累计数量:0")
    XpTimer.accumulate_label:SetWidth(360)
    frame:AddChild(XpTimer.accumulate_label)

    XpTimer:insert_space(frame)

    XpTimer.update_level_label = AceGUI:Create("Label")
    XpTimer.update_level_label:SetText("升级剩余时间:0分0秒   升级剩余经验:0")
    XpTimer.update_level_label:SetWidth(360)
    frame:AddChild(XpTimer.update_level_label)

    XpTimer:insert_space(frame)

    XpTimer.averge_label = AceGUI:Create("Label")
    XpTimer.averge_label:SetText("平均一只怪经验:0   剩余击杀数量:0")
    XpTimer.averge_label:SetWidth(360)
    frame:AddChild(XpTimer.averge_label)

    XpTimer:insert_space(frame)

    XpTimer.speed_icon = AceGUI:Create("Icon")
    XpTimer.speed_icon:SetImage("Interface\\AddOns\\XpTimer\\textures\\gray")
    XpTimer.speed_icon.image:SetPoint("BOTTOMLEFT", 0, 0)
    XpTimer.speed_icon:SetLabel("速度:0/小时(%0)")
    XpTimer.speed_icon:SetImageSize(360,30)
    XpTimer.speed_icon:SetWidth(360)
    XpTimer.speed_icon:SetHeight(30)
    frame:AddChild(XpTimer.speed_icon)

    --frame:Show()
    XpTimer.MainWindow = frame
end

function XpTimer:OnStartBtn()
    XpTimer.init_data()
    XpTimer.current_state = 2 -- 1:停止 2：运行中
    XpTimer.btn_start:SetDisabled(true)
    XpTimer.btn_stop:SetDisabled(false)
    XpTimer.MainWindow:SetStatusText("当前状态:运行中")
end

--function XpTimer:OnPauseBtn()
--    XpTimer.current_state = 2
--    XpTimer.btn_pause:SetText("继续")
--end

function XpTimer:OnStopBtn()
    XpTimer.current_state = 1
    XpTimer.btn_start:SetDisabled(false)
    XpTimer.btn_stop:SetDisabled(true)
    XpTimer.MainWindow:SetStatusText("当前状态:停止")
end

function XpTimer:OnSetTargetBtn()
    local target = XpTimer.tgt_set_editbox:GetText()
    XpTimer.target_exp = tonumber(target)
    XpTimer.target_label:SetText(string.format("目标(经验/小时):%d",XpTimer.target_exp))
end


function XpTimer:OnInitialize()
    XpTimer:CreateMainWindow()

    XpTimer.MainWindow:Show()
    XpTimer.current_state = 1
end

function XpTimer:OnEnable()

    XpTimer.events:RegisterEvent("PLAYER_ENTERING_WORLD")
    XpTimer.events:RegisterEvent("PLAYER_XP_UPDATE")
    XpTimer.events:RegisterEvent("PLAYER_LEVEL_UP")
    XpTimer.events:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")

end

function XpTimer:OnDisable()

end

function XpTimer:PLAYER_ENTERING_WORLD()
    --local current_xp = UnitXP("player")
    --message("hello "..current_xp)

    --XpTimer:init_data()
    --
    --message(XpTimer.start_time)
end

function XpTimer:init_data()
    XpTimer.start_time = GetTime()
    XpTimer.start_exp = UnitXP("player")
    XpTimer.max_exp = UnitXPMax("player")
    XpTimer.current_level = UnitLevel("player")
    XpTimer.all_exp = 0
    XpTimer.kill_num = 0

end

function XpTimer:Frame_update()



    local current_level = UnitLevel("player")

    -- time
    local current_time = GetTime()
    local seconds = current_time - XpTimer.start_time
    local ret_minutes = (floor(seconds / 60))
    local ret_seconds = (floor(seconds % 60))


    -- xp
    local current_exp = UnitXP("player")
    local exp_up = 0
    if(current_level == XpTimer.current_level) then
        exp_up = current_exp - XpTimer.start_exp
        XpTimer.start_exp = current_exp
    else
        exp_up = current_exp + ( XpTimer.max_exp -  XpTimer.start_exp)
        XpTimer.start_exp = current_exp
        XpTimer.current_level = current_level
        XpTimer.max_exp = UnitXPMax("player")
    end

    XpTimer.all_exp = XpTimer.all_exp + exp_up

    local speed_exp_second = (XpTimer.all_exp/seconds)
    speed_exp_second = speed_exp_second * 100
    speed_exp_second = floor(speed_exp_second + 0.5)
    speed_exp_second = speed_exp_second/100
    local speed_exp_hour = speed_exp_second*3600

    -- level up time
    local time_to_up_second = (XpTimer.max_exp - current_exp)/speed_exp_second
    local time_to_up_min = floor(time_to_up_second/60)

    -- kill_num
    --XpTimer.kill_num = XpTimer.kill_num + 1
    local averge_exp = floor(XpTimer.all_exp/XpTimer.kill_num)
    local require_num = (XpTimer.max_exp - current_exp)/averge_exp



    -- update frame
    XpTimer.accumulate_label:SetText(string.format("累计时间:%d分%d秒   累计经验:%d   累计数量:%d",ret_minutes,ret_seconds,XpTimer.all_exp,XpTimer.kill_num))
    XpTimer.update_level_label:SetText(string.format("升级剩余时间:%d分%d秒   升级剩余经验:%d",time_to_up_min,floor(time_to_up_second%60),(XpTimer.max_exp - current_exp)))
    XpTimer.averge_label:SetText(string.format("平均一只怪经验:%d   剩余击杀数量:%d",averge_exp,require_num))


    local icon_img = ""
    local per = floor(speed_exp_hour*100/XpTimer.target_exp)

    if(per <= 50) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\gray"
    elseif(per >50 and per <= 60) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\green"
    elseif(per >60 and per <= 75) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\yellow"
    elseif(per >75 and per <= 90) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\blue"
    elseif(per >90 and per <= 100) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\red"
    elseif(per >100) then
        icon_img = "Interface\\AddOns\\XpTimer\\textures\\purple"
    end

    XpTimer.speed_icon:SetImage(icon_img)
    local icon_len = 0
    if(per >= 100)then
        icon_len = 360
    else
        icon_len = floor(360*per/100)
    end
    XpTimer.speed_icon:SetLabel(string.format("速度:%d/小时(%%%d)",speed_exp_hour,per))
    XpTimer.speed_icon:SetImageSize(icon_len,30)
    XpTimer.speed_icon:SetWidth(360)
    XpTimer.speed_icon:SetHeight(30)

end

function XpTimer:PLAYER_XP_UPDATE()

    if (XpTimer.current_state ~= 2) then
        return
    end

    XpTimer:Frame_update()
end


function XpTimer:PLAYER_LEVEL_UP()
    if (XpTimer.current_state ~= 2) then
        return
    end

    XpTimer:Frame_update()
end

function XpTimer:CHAT_MSG_COMBAT_XP_GAIN()
    if (XpTimer.current_state ~= 2) then
        return
    end
    XpTimer.kill_num = XpTimer.kill_num + 1
    XpTimer:Frame_update()
end


--Sandbox = { }
--
--function Sandbox:HelloWorld()
--    message("Hello World!")
--end
--
--function Sandbox:HideGryphons()
--    MainMenuBarLeftEndCap:Hide()
--    MainMenuBarRightEndCap:Hide()
--end
--
--Sandbox:HelloWorld()