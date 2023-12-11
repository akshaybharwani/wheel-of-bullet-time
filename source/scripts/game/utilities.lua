UTILITIES = {}

function UTILITIES.secondsToMinutesAndSeconds(s)
    local m = math.floor(s / 60)
    s = s % 60
    return m, s
end