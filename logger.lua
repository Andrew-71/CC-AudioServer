local logger = {}
logger.new = function(monitor_wrap)
    local self = {}

    local monitor = monitor_wrap
    local log_colours = {
        ['log'] = colours.white,
        ['info'] = colours.lightBlue,
        ['warn'] = colours.yellow,
        ['err'] = colours.red,
        ['success'] = colours.lime
    }

    local function move_line()
        monitor.setCursorPos(1, select(2, monitor.getCursorPos()) + 1)
        if select(2, monitor.getCursorPos()) >= select(2, monitor.getSize()) then
            monitor.scroll(1)
            monitor.setCursorPos(1, select(2, monitor.getCursorPos()) - 1)
        end
    end

    local function write_msg(message, msg_colour)
        local time_str = os.date('%Y-%b-%d %H:%M:%S')
        local msg_formatted = "[" .. time_str .. "] " .. message

        monitor.setTextColour(msg_colour)
        monitor.write(msg_formatted)
        move_line()
    end

    function self.log(msg)
        write_msg(msg, log_colours['log'])
    end

    function self.info(msg)
        write_msg('INFO: ' .. msg, log_colours['info'])
    end

    function self.warning(msg)
        write_msg('WARNING: ' .. msg, log_colours['warn'])
    end

    function self.error(msg)
        write_msg('ERROR: ' .. msg, log_colours['err'])
    end

    function self.success(msg)
        write_msg('SUCCESS: ' .. msg, log_colours['success'])
    end

    return self
end

return logger