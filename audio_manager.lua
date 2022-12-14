--[[
    Class to manage ComputerCraft (CC) audio tracks on different disks

    Written by Andrew_7_1
]]

local audio_manager = {}
audio_manager.init = function (dirs_file)
    local self = {}

    -- Load audio directories from file where directories are seperated by newlines"
    local function load_audio_dirs(file_location)
        local audio_dirs = {}
        local file = io.open(file_location, 'r')
        if file then
            for line in file:lines() do
                table.insert(audio_dirs, line)
            end
            file:close()
        end
        return audio_dirs
    end
    local audio_dirs = load_audio_dirs(dirs_file or 'audio_dirs.txt')

    --[[
        Iterate over all audio directories and load all audio files into a catalogue.
        Audio files have extensions of .dfpwm and rarely .wav
        Save them to a table of tables like this:
        {
            ["filepath"] = absolute file path
            ["length"] = file size / 6000
            ["title"] = file name without extension and path, e.g. "title.dfpwm" -> "title"
            ["extension"] = file extension, e.g. "dfpwm"
        }
    ]]
    local function load_audio_catalogue()
        local audio_catalogue = {}
        for _, dir in pairs(audio_dirs) do
            for _, file in pairs(fs.list(dir)) do
                if file:find('.dfpwm') or file:find('.wav') then
                    local file_path = dir .. '/' .. file
                    local file_size = fs.getSize(file_path)
                    local file_title = file:sub(1, #file - #file:match('.*%.(.*)$'))
                    local file_extension = file:match('.*%.(.*)$')
                    table.insert(audio_catalogue, {
                        ["filepath"] = file_path,
                        ["length"] = file_size / 6000,
                        ["title"] = file_title,
                        ["extension"] = file_extension
                    })
                end
            end
        end
        return audio_catalogue
    end
    self.audio_catalogue = load_audio_catalogue()

    -- Update audio catalogue
    function self.update_catalogue()
        self.audio_catalogue = load_audio_catalogue()
    end

    function self.get_catalogue()
        return self.audio_catalogue
    end


    -- Get part of an audio file in the catalogue
    function self.get_track_chunk(index, starting_second, length)
        if index > #self.audio_catalogue then
            return false
        end
        local track = self.audio_catalogue[index]

        local file = io.open(track.filepath, 'rb')
        if not file then
            return false
        end

        file:seek('set', starting_second * 6000)
        local chunk = file:read(length * 6000)
        file:close()

        return chunk
    end

    -- More convenient way to get track info than using entire catalogue
    function self.get_track_details(index)
        if index > #self.audio_catalogue then
            return false
        end
        return self.audio_catalogue[index]
    end

    return self
end

return audio_manager