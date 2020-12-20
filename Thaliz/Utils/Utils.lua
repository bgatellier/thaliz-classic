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


-- Get the list (numeric indexed) of table keys in the same order as the alphabetically sorted values.
-- @param t Table where keys are non-numeric. Example: { "p" = "Priest", "m" = "Mage", "h" = "Hunter" }
-- @return Example: { "h", "m", "p" }
function KeysSortedByAlphabeticallySortedValues(t)
	local swapT = {}
	local tSorted = {}
	local values = {}

	-- 1. Create a swapped table: keys become values and values become keys
	-- 2. Create a table that holds only the values
	for k, v in pairs(t) do
		swapT[v] = k
		table.insert(values, v)
	end

	-- Sort the values
	table.sort(values)

	-- Create the sorted table from the sorted value and the matching keys from the swapped table
	for _, v in ipairs(values) do
		table.insert(tSorted, swapT[v])
	end

	return tSorted
end
