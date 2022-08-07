--[[
    Audio server for ComputerCraft (CC)

    Written by Andrew_7_1
]]

local server = {}
server.init = function (port, audio_dir)
    local self = {}

    local logger = require('logger').init()
    local audio_manager = require('audio_manager').init(audio_dir or 'audio_dirs.txt')

    local port = port or 7101
    local modem = peripheral.find('modem')
    if not modem then error('No modem found') end
    modem.open(port)
    logger.info('Audio server started on port ' .. port .. ' with audio directories from ' .. audio_dir)

    local message_types = {
        query = function (replyChannel, msg)
            modem.transmit(replyChannel, port, {code = 200, audio_catalogue = audio_manager.get_catalogue()})
            logger.success('Query sent')
        end,
        refresh = function (replyChannel, msg)
            audio_manager.update_catalogue()
            modem.transmit(replyChannel, port, {code = 200})
            logger.success('Catalogue updated')
        end,

        track_info = function (replyChannel, msg)
            local track = audio_manager.get_track_details(msg.index)
            if not track then
                modem.transmit(replyChannel, port, {code = 404})
                logger.error('Track not found (id: ' .. msg.index .. ')')
            else
                modem.transmit(replyChannel, port, {code = 200, track = track})
                logger.success('Track details sent (id: ' .. msg.index .. ')')
            end
        end,
        track_chunk = function (replyChannel, msg)
            local track = audio_manager.get_track_chunk(msg.index, msg.starting_second, msg.length)
            if not track then
                modem.transmit(replyChannel, port, {code = 404})
                logger.error('Track not found (id: ' .. msg.index .. ')')
            else
                modem.transmit(replyChannel, port, {code = 200, track = track})
                logger.success('Part of a track sent (id: ' .. msg.index .. ', part:' .. msg.starting_second .. '-' .. msg.starting_second + msg.length .. ')')
            end
        end
    }

    function self.process_transmission(event, side, channel, replyChannel, message, distance)
        message_types[message.type](replyChannel, message)
    end

    return self
end

return server