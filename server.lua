--[[
    Audio server for ComputerCraft (CC)

    Written by Andrew_7_1 with huge help from GitHub copilot, he's a really cool guy
]]

local audio_manager = require('audio_manager').init('audio_dirs.txt')  -- NIL CHECK!!!
local logger = require('logger').new()

local port = 7101 -- will be configurable later
local modem = peripheral.find('modem')
if not modem then error('No modem found') end
modem.open(port)
logger.info('Audio server started on port ' .. port)

-- Listen for incoming transmissions on port
--[[
    Messages are tables. All have an argument "type", which dictates what other arguments there are and what to return

    type query - return audio_catalogue
    type track_info - argument index, return info for atrack
    type track_chunk - argument index and "chunk_info": {"starting_second" and "length"}, return requested part of track
]]
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent('modem_message')
    logger.info("Recieved message from " .. channel .. ": " .. message.type)

    if message.type == 'query' then
        modem.transmit(replyChannel, port, {type = 'audio_catalogue', audio_catalogue = audio_manager.get_audio_catalogue()})
        logger.success('Query sent')
    elseif message.type == 'track_info' then
        local track_info = audio_manager.get_track_info(message.index)
        if track_info then
            modem.transmit(replyChannel, port, {type = 'track_info', track_info = track_info})
            logger.success('Track info sent')
        else
            modem.transmit(replyChannel, port, {type = 'track_info', track_info = {}})
            logger.warning('Track info request for invalid index: ' .. message.index)
        end

    elseif message.type == 'track_chunk' then
        local track_chunk = audio_manager.get_track_chunk(message.index, message.chunk_info)
        if track_chunk then
            modem.transmit(replyChannel, port, {type = 'track_chunk', track_chunk = track_chunk})
            logger.success('Track chunk sent (' .. message.chunk_info.starting_second .. '-' .. message.chunk_info.starting_second + message.chunk_info.length .. ')')
        else
            modem.transmit(replyChannel, port, {type = 'track_chunk', track_chunk = {}})
            logger.warning('Track chunk request for invalid index: ' .. message.index)
        end
    end
end
