local config = {
    port = 7101,
    audio_dir = 'audio_dirs.txt'
}

local server = require("server").init(config.port, config.audio_dir)
local modem = peripheral.find("modem")
if not modem then error("No modem found") end
modem.open(config.port)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    server.process_transmission(event, side, channel, replyChannel, message, distance)
end