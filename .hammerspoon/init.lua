local previousLayout = nil
local targetApps = { "iTerm2", "Remote Desktop Manager", "AnyDesk", "PyCharm", "WinBox", "KeePassXC", "Preview"}

local function isTargetApp(appName)
    for _, name in ipairs(targetApps) do
        if appName == name then
            return true
        end
    end
    return false
end

local function handleAppEvent(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        if isTargetApp(appName) then
            previousLayout = hs.keycodes.currentLayout()
            hs.keycodes.setLayout("U.S.")
        end
    elseif eventType == hs.application.watcher.deactivated then
        if isTargetApp(appName) and previousLayout ~= nil then
            hs.keycodes.setLayout(previousLayout)
        end
    end
end

appWatcher = hs.application.watcher.new(handleAppEvent)
appWatcher:start()
