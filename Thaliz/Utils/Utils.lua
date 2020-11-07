-- Checks if a value (v) is in a numeric table (t)
function InNumericTable(v, t)
	local tLength = table.getn(t)

	if (tLength == 0) then
		return false
	end

	local i = 1
	local isInTable = false
	while i <= tLength and not isInTable do
		if (t[i] == v) then
			isInTable = true
		end

		i = i + 1
	end

	return isInTable
end

function RenumberTable(sourcetable)
	local index = 1
	local temptable = { }

	for key, value in next, sourcetable do
		temptable[index] = value
		index = index + 1
    end

    return temptable
end

-- Convert a msg so first letter is uppercase, and rest as lower case.
function UCFirst(playername)
	if not playername then
		return ""
	end

	-- Handles utf8 characters in beginning.. Ugly, but works:
	local offset = 2
	local firstletter = string.sub(playername, 1, 1)
	if (not string.find(firstletter, '[a-zA-Z]')) then
		firstletter = string.sub(playername, 1, 2)
		offset = 3
	end

	return string.upper(firstletter) .. string.lower(string.sub(playername, offset))
end


function BeginsWith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
 end
