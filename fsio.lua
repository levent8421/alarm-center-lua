module(..., package.seeall)

require 'io'

function ReadFile(filename, openFlag)
    local file = io.open(filename, openFlag)
    local content = file:read('*a')
    file:close()
    return content
end

function ReadBinaryFile(filePath, filename)
    local fullFileName = filePath .. filename
    return ReadFile(fullFileName, 'rb')
end

function ReadTextFile(filePath, filename)
    local fullFileName = filePath .. filename
    return ReadFile(fullFileName, 'r')
end
