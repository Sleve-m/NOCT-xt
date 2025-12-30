local ScriptViewer = {}

local TextService = game:GetService("TextService")

local ui = {}

local textContentScroller, foundLinesScroller, 
scriptViewerSearchInputTextBox, foundLineExampleButton,
lineNumTemplate, scriptTextTemplate

local currentScriptInViewerInstance = nil
local currentViewerOriginalSearchTerms = {}

local MAX_TEXTLABEL_CHAR_LIMIT = 16000

local function getLineCountForText(text)
	if text == "" then return 1 end 
	local count = 1
	for _ in string.gmatch(text, "\n") do
		count = count + 1
	end
	return count
end

local function escapePattern(text)
	if not text then return "" end
	return text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
end

local decompile_available, decompile = pcall(function() return decompile end)
if not (decompile_available and type(decompile) == "function") then
	decompile = function(scriptInstance)
		if scriptInstance and scriptInstance:IsA("LuaSourceContainer") then
			return "Mock Decompilation for: " .. scriptInstance:GetFullName() .. "\n" .. scriptInstance.Source
		end
		return "Could not decompile (mock) " .. (scriptInstance and scriptInstance.Name or "nil")
	end
end

local function getHighlightRanges(scriptContent, termsToHighlight, wholeWordSearchActiveFlag)
	local ranges = {}
	if not scriptContent or #scriptContent == 0 or not termsToHighlight or #termsToHighlight == 0 then
		return ranges
	end
	local lowerContent = scriptContent:lower()
	local sortedTerms = {}
	for _, t in ipairs(termsToHighlight) do table.insert(sortedTerms, t) end
	table.sort(sortedTerms, function(a, b) return #a > #b end) 
	local coveredChars = {} 
	for _, term in ipairs(sortedTerms) do
		local lowerTerm = term:lower()
		if #lowerTerm > 0 then
			local currentIndex = 1
			while currentIndex <= #lowerContent do
				local s, e 
				if wholeWordSearchActiveFlag then
					local pattern = "(%A|^)(" .. escapePattern(lowerTerm) .. ")(%A|$)"
					local s_match, e_match, boundary_start, captured_term_lower = string.match(lowerContent, pattern, currentIndex)
					if s_match then
						s = s_match + #(boundary_start or "") 
						e = s + #captured_term_lower - 1
					end
				else
					s, e = string.find(lowerContent, lowerTerm, currentIndex, true)
				end
				if s then 
					local isOverlapped = false
					for i = s, e do
						if coveredChars[i] then isOverlapped = true; break end
					end
					if not isOverlapped then
						table.insert(ranges, { start = s, finish = e })
						for i = s, e do coveredChars[i] = true end
					end
					currentIndex = s + 1 
				else
					break 
				end
			end
		end
	end
	return ranges
end

local function escapeRichTextSpecialChars(text)
	if not text then return "" end
	text = text:gsub("&", "&amp;")
	text = text:gsub("<", "&lt;")
	text = text:gsub(">", "&gt;")
	return text
end

local function buildRichTextFromRanges(scriptContent, ranges)
	if not scriptContent then return "" end
	if not ranges or #ranges == 0 then
		return escapeRichTextSpecialChars(scriptContent) 
	end
	table.sort(ranges, function(a, b) return a.start < b.start end) 
	local resultParts = {}
	local currentIndex = 1
	for _, range in ipairs(ranges) do
		if range.start > currentIndex then
			table.insert(resultParts, escapeRichTextSpecialChars(scriptContent:sub(currentIndex, range.start - 1)))
		end
		local word = escapeRichTextSpecialChars(scriptContent:sub(range.start, range.finish))
		local coloredWord = word

		if word == "local" or word == "function" or word == "end" then
			coloredWord = '<font color="#FF0000">' .. word .. '</font>'
		elseif word:sub(1,1) == '"' then
			coloredWord = '<font color="#00FF00">' .. word .. '</font>'
		end

		table.insert(resultParts, "<u>" .. coloredWord .. "</u>")
		currentIndex = range.finish + 1
	end
	if currentIndex <= #scriptContent then
		table.insert(resultParts, escapeRichTextSpecialChars(scriptContent:sub(currentIndex)))
	end
	return table.concat(resultParts)
end

local highlighter = {}
local keywords = {
	lua = {
		"and", "break", "or", "else", "elseif", "if", "then", "until", "repeat", "while", "do", "for", "in", "end",
		"local", "return", "function", "export"
	},
	rbx = {
		"game", "workspace", "script", "math", "string", "table", "task", "wait", "select", "next", "Enum",
		"error", "warn", "tick", "assert", "shared", "loadstring", "tonumber", "tostring", "type",
		"typeof", "unpack", "print", "Instance", "CFrame", "Vector3", "Vector2", "Color3", "UDim", "UDim2", "Ray", "BrickColor",
		"OverlapParams", "RaycastParams", "Axes", "Random", "Region3", "Rect", "TweenInfo",
		"collectgarbage", "not", "utf8", "pcall", "xpcall", "_G", "setmetatable", "getmetatable", "os", "pairs", "ipairs"
	},
	operators = {
		"#", "+", "-", "*", "%", "/", "^", "=", "~", "=", "<", ">", ",", ".", "(", ")", "{", "}", "[", "]", ";", ":"
	}
}

local colors = {
	numbers = Color3.fromRGB(255, 198, 0),
	boolean = Color3.fromRGB(214, 128, 23),
	operator = Color3.fromRGB(232, 210, 40),
	lua = Color3.fromRGB(160, 87, 248),
	rbx = Color3.fromRGB(146, 180, 253),
	str = Color3.fromRGB(56, 241, 87),
	comment = Color3.fromRGB(103, 110, 149),
	null = Color3.fromRGB(79, 79, 79),
	call = Color3.fromRGB(130, 170, 255),
	self_call = Color3.fromRGB(227, 201, 141),
	local_color = Color3.fromRGB(199, 146, 234),
	function_color = Color3.fromRGB(241, 122, 124),
	self_color = Color3.fromRGB(146, 134, 234),
	local_property = Color3.fromRGB(129, 222, 255),
}

local function createKeywordSet(kws)
	local keywordSet = {}
	for _, keyword in ipairs(kws) do keywordSet[keyword] = true end
	return keywordSet
end

local luaSet = createKeywordSet(keywords.lua)
local rbxSet = createKeywordSet(keywords.rbx)
local operatorsSet = createKeywordSet(keywords.operators)

local function getHighlight(tokens, index)
	local token = tokens[index]
	if colors[token .. "_color"] then return colors[token .. "_color"] end
	if tonumber(token) then return colors.numbers
	elseif token == "nil" then return colors.null
	elseif token:sub(1, 2) == "--" then return colors.comment
	elseif operatorsSet[token] then return colors.operator
	elseif luaSet[token] then return colors.rbx
	elseif rbxSet[token] then return colors.lua
	elseif token:sub(1, 1) == "\"" or token:sub(1, 1) == "\'" then return colors.str
	elseif token == "true" or token == "false" then return colors.boolean end
	if tokens[index + 1] == "(" then
		if tokens[index - 1] == ":" then return colors.self_call end
		return colors.call
	end
	if tokens[index - 1] == "." then
		if tokens[index - 2] == "Enum" then return colors.rbx end
		return colors.local_property
	end
end

function highlighter.run(source)
	local tokens = {}
	local currentToken = ""
	local inString = false
	local inComment = false
	local commentPersist = false

	for i = 1, #source do
		local character = source:sub(i, i)
		if inComment then
			if character == "\n" and not commentPersist then
				table.insert(tokens, currentToken); table.insert(tokens, character)
				currentToken = ""; inComment = false
			elseif source:sub(i - 1, i) == "]]" and commentPersist then
				currentToken ..= "]"; table.insert(tokens, currentToken)
				currentToken = ""; inComment = false; commentPersist = false
			else currentToken = currentToken .. character end
		elseif inString then
			if character == inString and source:sub(i-1, i-1) ~= "\\" or character == "\n" then
				currentToken = currentToken .. character; inString = false
			else currentToken = currentToken .. character end
		else
			if source:sub(i, i + 1) == "--" then
				table.insert(tokens, currentToken); currentToken = "-"
				inComment = true; commentPersist = source:sub(i + 2, i + 3) == "[["
			elseif character == "\"" or character == "\'" then
				table.insert(tokens, currentToken); currentToken = character; inString = character
			elseif operatorsSet[character] then
				table.insert(tokens, currentToken); table.insert(tokens, character); currentToken = ""
			elseif character:match("[%w_]") then currentToken = currentToken .. character
			else
				table.insert(tokens, currentToken); table.insert(tokens, character); currentToken = ""
			end
		end
	end
	table.insert(tokens, currentToken)

	local highlighted = {}
	for i, token in ipairs(tokens) do
		local highlight = getHighlight(tokens, i)
		if highlight then
			local syntax = string.format("<font color = \"#%s\">%s</font>", highlight:ToHex(), (token:gsub("<", "&lt;"):gsub(">", "&gt;")))
			table.insert(highlighted, syntax)
		else
			table.insert(highlighted, (token:gsub("<", "&lt;"):gsub(">", "&gt;")))
		end
	end
	return table.concat(highlighted)
end

local function createScriptSegment(chunkNumber, scriptChunk, startLineNumber, termsToHighlight, wholeWordSearchActiveFlag, lineNumTemplate, scriptTextTemplate)
	if not lineNumTemplate or not scriptTextTemplate or not TextService then
		return nil, 0
	end

	local segmentFrame = Instance.new("Frame")
	segmentFrame.Name = "ScriptSegment_" .. chunkNumber
	segmentFrame.BackgroundTransparency = 1
	segmentFrame.Size = UDim2.new(1, 0, 0, 0)
	segmentFrame.LayoutOrder = chunkNumber

	local segmentLineNumbers = lineNumTemplate:Clone()
	segmentLineNumbers.Name = "SegmentLines"
	segmentLineNumbers.Visible = true
	segmentLineNumbers.Parent = segmentFrame
	local lineNumWidth = (lineNumTemplate.AbsoluteSize.X > 0 and lineNumTemplate.AbsoluteSize.X) or 30
	segmentLineNumbers.Size = UDim2.new(0, lineNumWidth, 1, 0)
	segmentLineNumbers.TextYAlignment = Enum.TextYAlignment.Top
	segmentLineNumbers.TextXAlignment = Enum.TextXAlignment.Right

	local segmentScriptText = scriptTextTemplate:Clone()
	segmentScriptText.Name = "SegmentScript"
	segmentScriptText.Visible = true
	segmentScriptText.Parent = segmentFrame
	segmentScriptText.Position = UDim2.new(0, segmentLineNumbers.Size.X.Offset, 0, 0)
	segmentScriptText.AutomaticSize = Enum.AutomaticSize.X
	segmentScriptText.Size = UDim2.new(1, -segmentLineNumbers.Size.X.Offset, 1, 0)
	segmentScriptText.TextWrapped = false
	segmentScriptText.RichText = true
	segmentScriptText.TextYAlignment = Enum.TextYAlignment.Top
	segmentScriptText.TextXAlignment = Enum.TextXAlignment.Left

	local linesForChunkTable = {}
	local lineCountInThisChunk = getLineCountForText(scriptChunk)
	if #scriptChunk == 0 and chunkNumber == 1 then
		lineCountInThisChunk = 1
		table.insert(linesForChunkTable, "1")
	elseif #scriptChunk > 0 then
		for i = 0, lineCountInThisChunk - 1 do
			table.insert(linesForChunkTable, tostring(startLineNumber + i))
		end
	else
		lineCountInThisChunk = 0
	end
	segmentLineNumbers.Text = table.concat(linesForChunkTable, "\n")
	segmentFrame:SetAttribute("LineCount", lineCountInThisChunk)

	local highlightedChunk = highlighter.run(scriptChunk)
	segmentScriptText.Text = highlightedChunk

	local function updateSegmentFrameHeight()
		if segmentScriptText and segmentScriptText.Parent and segmentFrame and segmentFrame.Parent then
			game:GetService("RunService").Stepped:Wait()

			local calculatedTextHeight = 0
			local textContent = segmentScriptText.Text

			if #textContent > 0 then
				local plainText = textContent:gsub("<[^<>]->", "")
				local textSizeResult = TextService:GetTextSize(
					plainText,
					segmentScriptText.TextSize,
					segmentScriptText.Font,
					Vector2.new(math.huge, math.huge)
				)
				calculatedTextHeight = textSizeResult.Y
			else
				calculatedTextHeight = 0
			end

			local finalHeightToSet = math.max(0, calculatedTextHeight)
			segmentFrame.Size = UDim2.new(segmentFrame.Size.X.Scale, segmentFrame.Size.X.Offset, 0, finalHeightToSet)
		end
	end

	task.defer(updateSegmentFrameHeight)

	local propChangedConn
	if segmentScriptText then
		propChangedConn = segmentScriptText:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSegmentFrameHeight)
	end
	segmentFrame.Destroying:Connect(function()
		if propChangedConn then propChangedConn:Disconnect() end
	end)

	return segmentFrame, lineCountInThisChunk
end

local function clearScriptSegments(scroller)
	if not scroller then
		return
	end
	local segmentsToDestroy = {}
	local initialChildren = #scroller:GetChildren()

	for _, child in ipairs(scroller:GetChildren()) do
		if child.Name and child.Name:match("^ScriptSegment_") then
			table.insert(segmentsToDestroy, child)
		end
	end

	for _, seg in ipairs(segmentsToDestroy) do
		seg:Destroy()
	end
	local finalChildren = #scroller:GetChildren()
end

local function getLinesFromText(textBlock)
	local lines = {}
	if not textBlock or #textBlock == 0 then
		return lines
	end

	local currentPos = 1
	while currentPos <= #textBlock do
		local s, e = string.find(textBlock, "\n", currentPos, true)
		if s then
			table.insert(lines, textBlock:sub(currentPos, s - 1))
			currentPos = e + 1
		else
			table.insert(lines, textBlock:sub(currentPos))
			break
		end
	end
	if #lines > 0 and lines[#lines] == "" and textBlock:sub(#textBlock, #textBlock) == "\n" then
	elseif #textBlock > 0 and #lines == 0 then 
		table.insert(lines, textBlock)
	end
	return lines
end

local function getMatchLocations(scriptContent, termsToHighlight)
	local locations = {}; if not scriptContent or #scriptContent == 0 or not termsToHighlight or #termsToHighlight == 0 then return locations end
	local lines = string.split(scriptContent, "\n"); local uniqueTermsFoundOnLine = {} 
	for lineNum, lineText in ipairs(lines) do
		table.clear(uniqueTermsFoundOnLine); local lowerLine = lineText:lower(); local lineHasAnyMatch = false
		for _, term in ipairs(termsToHighlight) do if string.find(lowerLine, term:lower(), 1, true) then uniqueTermsFoundOnLine[term] = true; lineHasAnyMatch = true end end
		if lineHasAnyMatch then local actualMatchedTerms = {}; for term, _ in pairs(uniqueTermsFoundOnLine) do table.insert(actualMatchedTerms, term) end; if #actualMatchedTerms > 0 then table.insert(locations, { line = lineNum, matchedTerms = actualMatchedTerms }) end end
	end; return locations
end

local function updateScriptViewCanvasSize()
	if not textContentScroller then return end
	task.wait()

	local maxWidth = 0
	for _, segmentFrame in ipairs(textContentScroller:GetChildren()) do
		if segmentFrame.Name:match("^ScriptSegment_") then
			local scriptText = segmentFrame:FindFirstChild("SegmentScript")
			local linesText = segmentFrame:FindFirstChild("SegmentLines")
			if scriptText and linesText then
				local plainTextForWidthCalc = scriptText.Text:gsub("<[^<>]->", "")
				local contentTextBounds = TextService:GetTextSize(
					plainTextForWidthCalc,
					scriptText.TextSize,
					scriptText.Font,
					Vector2.new(100000, scriptText.AbsoluteSize.Y)
				)
				local segmentWidth = contentTextBounds.X + linesText.AbsoluteSize.X + 20
				if segmentWidth > maxWidth then
					maxWidth = segmentWidth
				end
			end
		end
	end

	local currentCanvasHeight = 0
	for i, v in pairs(textContentScroller:GetChildren()) do
		currentCanvasHeight += v.AbsoluteSize.Y
	end
	textContentScroller.CanvasSize = UDim2.new(0, math.max(maxWidth, textContentScroller.AbsoluteSize.X), 0, currentCanvasHeight)
end

local function populateMatchesScrollingFrame(matchLocations)
	if not foundLinesScroller or not foundLineExampleButton or not textContentScroller then
		if foundLinesScroller then foundLinesScroller.CanvasSize = UDim2.new(0,0,0,0) end
		return
	end

	for _, child in ipairs(foundLinesScroller:GetChildren()) do
		if child ~= foundLineExampleButton then child:Destroy() end
	end
	foundLineExampleButton.Visible = false

	if not matchLocations or #matchLocations == 0 then
		foundLinesScroller.CanvasSize = UDim2.new(0,0,0,0); return
	end

	local listLayout = foundLinesScroller:FindFirstChildOfClass("UIListLayout")
	if not listLayout then
		listLayout = Instance.new("UIListLayout", foundLinesScroller)
		listLayout.Padding = UDim.new(0, 2)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	end
	foundLinesScroller.AutomaticCanvasSize = Enum.AutomaticSize.Y

	for i, locationData in ipairs(matchLocations) do
		local item = foundLineExampleButton:Clone()
		item.Name = "Match_" .. i
		local termsString = locationData.matchedTerms and table.concat(locationData.matchedTerms, ", ") or ""
		item.Text = locationData.line .. ": " .. termsString
		item.Parent = foundLinesScroller
		item.LayoutOrder = i
		item.Visible = true

		item.MouseButton1Click:Connect(function()
			if not textContentScroller or not TextService then return end

			task.wait() 

			local targetAbsoluteLine = locationData.line
			local accumulatedOffsetY = 0
			local currentSegmentStartAbsoluteLine = 1 

			local segments = {}
			for _, child in ipairs(textContentScroller:GetChildren()) do
				if child.Name and child.Name:match("^ScriptSegment_") and child:IsA("Frame") then
					table.insert(segments, child)
				end
			end
			table.sort(segments, function(a,b) return a.LayoutOrder < b.LayoutOrder end)

			local uiListLayoutPaddingY = 0
			local listLayoutInScroller = textContentScroller:FindFirstChildOfClass("UIListLayout")
			if listLayoutInScroller then uiListLayoutPaddingY = listLayoutInScroller.Padding.Offset end

			local targetSegmentFrame = nil
			local lineWithinTargetSegment = 0

			for segIdx, segmentFrame in ipairs(segments) do
				local segmentScriptTextLabel = segmentFrame:FindFirstChild("SegmentScript")
				if not segmentScriptTextLabel then continue end

				local linesInThisSegment = segmentFrame:GetAttribute("LineCount") or 0
				if linesInThisSegment == 0 then 
					local plainTextForLineCounting = segmentScriptTextLabel.Text:gsub("<[^<>]->", "") 
					if #plainTextForLineCounting > 0 then linesInThisSegment = getLineCountForText(plainTextForLineCounting) end
				end
				if linesInThisSegment == 0 and #segmentScriptTextLabel.Text > 0 then linesInThisSegment = 1 end

				local segmentEndAbsoluteLine = currentSegmentStartAbsoluteLine + linesInThisSegment - 1
				local segmentActualHeight = segmentFrame.AbsoluteSize.Y 

				if targetAbsoluteLine >= currentSegmentStartAbsoluteLine and targetAbsoluteLine <= segmentEndAbsoluteLine then
					targetSegmentFrame = segmentFrame
					lineWithinTargetSegment = targetAbsoluteLine - currentSegmentStartAbsoluteLine + 1
					break 
				else
					accumulatedOffsetY = accumulatedOffsetY + segmentActualHeight + uiListLayoutPaddingY
					currentSegmentStartAbsoluteLine = currentSegmentStartAbsoluteLine + linesInThisSegment
				end
			end

			if targetSegmentFrame and lineWithinTargetSegment > 0 then
				local intraSegmentOffsetY = 0
				local targetSegmentScriptLabel = targetSegmentFrame:FindFirstChild("SegmentScript")

				if targetSegmentScriptLabel and lineWithinTargetSegment > 1 then
					local segmentFullRichText = targetSegmentScriptLabel.Text 


					local plainTextForLineSplitting = segmentFullRichText:gsub("<[^<>]->", "")
					local segmentLines = getLinesFromText(plainTextForLineSplitting) 

					if #segmentLines > 0 and lineWithinTargetSegment -1 <= #segmentLines then
						local textToMeasureForOffset = ""
						for lineIdx = 1, lineWithinTargetSegment - 1 do
							if segmentLines[lineIdx] then 
								textToMeasureForOffset = textToMeasureForOffset .. segmentLines[lineIdx] .. (lineIdx < lineWithinTargetSegment - 1 and "\n" or "")
							end
						end

						if #textToMeasureForOffset > 0 then
							local textSizeParams = Vector2.new(targetSegmentScriptLabel.AbsoluteSize.X, math.huge) 
							if textSizeParams.X <= 0 then textSizeParams.X = textContentScroller.AbsoluteSize.X - (targetSegmentFrame:FindFirstChild("SegmentLines") and targetSegmentFrame.FindFirstChild("SegmentLines").AbsoluteSize.X or 30) - 10 end
							if textSizeParams.X <= 0 then textSizeParams.X = 300 end 

							local requiredSize = TextService:GetTextSize(
								textToMeasureForOffset, 
								targetSegmentScriptLabel.TextSize, 
								targetSegmentScriptLabel.Font, 
								textSizeParams
							)
							intraSegmentOffsetY = requiredSize.Y
						end
					end
				end

				local targetScrollY = accumulatedOffsetY + intraSegmentOffsetY

				local scrollerViewportHeight = textContentScroller.AbsoluteSize.Y
				local canvasTotalHeight = 0
				if listLayoutInScroller and listLayoutInScroller.AbsoluteContentSize.Y > 0 then
					canvasTotalHeight = listLayoutInScroller.AbsoluteContentSize.Y
				else 
					for _, segFrame in ipairs(segments) do canvasTotalHeight = canvasTotalHeight + segFrame.AbsoluteSize.Y end
					canvasTotalHeight = canvasTotalHeight + math.max(0, #segments - 1) * uiListLayoutPaddingY
				end

				local maxScrollY = math.max(0, canvasTotalHeight - scrollerViewportHeight)
				targetScrollY = math.clamp(targetScrollY, 0, maxScrollY)

				textContentScroller.CanvasPosition = Vector2.new(textContentScroller.CanvasPosition.X, targetScrollY)
			else
				if targetSegmentFrame then
					textContentScroller.CanvasPosition = Vector2.new(textContentScroller.CanvasPosition.X, math.clamp(accumulatedOffsetY, 0, math.max(0, (listLayoutInScroller and listLayoutInScroller.AbsoluteContentSize.Y or 0) - scrollerViewportHeight)))
				end
			end
		end)
	end
end

function ScriptViewer.viewScript(scriptInstance, searchTerms)
	currentScriptInViewerInstance = nil
	currentViewerOriginalSearchTerms = searchTerms or {}
	if scriptViewerSearchInputTextBox then scriptViewerSearchInputTextBox.Text = "" end

	if not subframes["Script Viewer"] or not scriptInstance then return end

	if not (foundLinesScroller and textContentScroller and lineNumTemplate and scriptTextTemplate) then
		subframes["Script Viewer"].Visible = false; return
	end

	clearScriptSegments(textContentScroller)
	lineNumTemplate.Visible = false
	scriptTextTemplate.Visible = false

	local success, rawScriptContent = pcall(decompile, scriptInstance)

	if not success or not rawScriptContent then
		local errorSegment, _ = createScriptSegment(1, "Error decompiling script: " .. (scriptInstance and scriptInstance.Name or "nil") .. "\n" .. tostring(rawScriptContent), 1, {}, false, lineNumTemplate, scriptTextTemplate)
		if errorSegment then errorSegment.Parent = textContentScroller; local tl = errorSegment:FindFirstChild("SegmentScript"); if tl then tl.RichText = false end end
		populateMatchesScrollingFrame({})
		subframes["Script Viewer"].Visible = true; return
	end

	local currentCharacterIndex = 1
	local currentAbsoluteLineNumber = 1
	local segmentNumber = 1

	while currentCharacterIndex <= #rawScriptContent do
		local potentialEndIndexByLimit = math.min(currentCharacterIndex + MAX_TEXTLABEL_CHAR_LIMIT - 1, #rawScriptContent)
		local actualEndIndex = potentialEndIndexByLimit
		if potentialEndIndexByLimit < #rawScriptContent then
			for i = potentialEndIndexByLimit, currentCharacterIndex, -1 do
				if rawScriptContent:sub(i, i) == "\n" then actualEndIndex = i; break end
			end
		end
		local chunk = string.sub(rawScriptContent, currentCharacterIndex, actualEndIndex)
		if #chunk == 0 and currentCharacterIndex > #rawScriptContent then break end

		local newSegment, linesInThisChunk = createScriptSegment(segmentNumber, chunk, currentAbsoluteLineNumber, currentViewerOriginalSearchTerms, wholeWordSearchActive, lineNumTemplate, scriptTextTemplate)
		if newSegment then newSegment.Parent = textContentScroller end

		if linesInThisChunk > 0 then currentAbsoluteLineNumber = currentAbsoluteLineNumber + linesInThisChunk
		elseif #chunk > 0 and linesInThisChunk == 0 then currentAbsoluteLineNumber = currentAbsoluteLineNumber + 1 end

		currentCharacterIndex = actualEndIndex + 1; segmentNumber = segmentNumber + 1
		if currentCharacterIndex > #rawScriptContent and #chunk == 0 then break end
	end
	if #rawScriptContent == 0 and segmentNumber == 1 then
		local emptySegment, _ = createScriptSegment(1, "", 1, {}, false, lineNumTemplate, scriptTextTemplate)
		if emptySegment then emptySegment.Parent = textContentScroller end
	end

	task.defer(updateScriptViewCanvasSize) 
	local matchLocations = getMatchLocations(rawScriptContent, currentViewerOriginalSearchTerms)
	populateMatchesScrollingFrame(matchLocations)
	currentScriptInViewerInstance = scriptInstance
	subframes["Script Viewer"].Visible = true
	if textContentScroller then textContentScroller.CanvasPosition = Vector2.new(0,0) end
end

local isSearchingInScript = false
local lastSearchTriggerTime = 0
local searchDebounceTime = 0.2

performInScriptSearch = function()
	local currentTime = tick()
	if isSearchingInScript and (currentTime - lastSearchTriggerTime < 0.1) then
		return
	end
	if currentTime - lastSearchTriggerTime < searchDebounceTime then
		return
	end

	isSearchingInScript = true
	lastSearchTriggerTime = currentTime

	local inScriptQuery = scriptViewerSearchInputTextBox.Text
	local termsToActuallyUse = {}
	local newTermsToActuallyUse = {}
	if inScriptQuery and not inScriptQuery:match("^%s*$") then
		for term in string.gmatch(inScriptQuery, "[^%s]+") do table.insert(newTermsToActuallyUse, term) end
		if #newTermsToActuallyUse == 0 and #inScriptQuery > 0 then 
			table.insert(newTermsToActuallyUse, inScriptQuery)
		end
	else
		newTermsToActuallyUse = currentViewerOriginalSearchTerms or {}
	end
	termsToActuallyUse = newTermsToActuallyUse

	clearScriptSegments(textContentScroller) 

	game:GetService("RunService").Stepped:Wait() 
	if not currentScriptInViewerInstance then
		populateMatchesScrollingFrame({}) 
		return
	end

	local suc, rawScriptContent = pcall(decompile, currentScriptInViewerInstance)
	if not suc or not rawScriptContent then
		clearScriptSegments(textContentScroller)
		local errorSegment, _ = createScriptSegment(1, "Error re-decompiling script for search.", 1, {}, false, lineNumTemplate, scriptTextTemplate)
		if errorSegment then errorSegment.Parent = textContentScroller; local tl = errorSegment:FindFirstChild("SegmentScript"); if tl then tl.RichText = false end end
		populateMatchesScrollingFrame({})
		return
	end

	local currentCharacterIndex = 1
	local currentAbsoluteLineNumber = 1
	local segmentNumber = 1

	while currentCharacterIndex <= #rawScriptContent do
		local potentialEndIndexByLimit = math.min(currentCharacterIndex + MAX_TEXTLABEL_CHAR_LIMIT - 1, #rawScriptContent)
		local actualEndIndex = potentialEndIndexByLimit
		if potentialEndIndexByLimit < #rawScriptContent then
			for i = potentialEndIndexByLimit, currentCharacterIndex, -1 do
				if rawScriptContent:sub(i, i) == "\n" then actualEndIndex = i; break end
			end
		end
		local chunk = string.sub(rawScriptContent, currentCharacterIndex, actualEndIndex)
		if #chunk == 0 and currentCharacterIndex > #rawScriptContent then break end

		local newSegment, linesInThisChunk = createScriptSegment(segmentNumber, chunk, currentAbsoluteLineNumber, termsToActuallyUse, wholeWordSearchActive, lineNumTemplate, scriptTextTemplate)
		if newSegment then newSegment.Parent = textContentScroller end

		if linesInThisChunk > 0 then currentAbsoluteLineNumber = currentAbsoluteLineNumber + linesInThisChunk
		elseif #chunk > 0 and linesInThisChunk == 0 then currentAbsoluteLineNumber = currentAbsoluteLineNumber + 1 end

		currentCharacterIndex = actualEndIndex + 1; segmentNumber = segmentNumber + 1
		if currentCharacterIndex > #rawScriptContent and #chunk == 0 then break end
	end
	if #rawScriptContent == 0 and segmentNumber == 1 then
		local emptySegment, _ = createScriptSegment(1, "", 1, {}, false, lineNumTemplate, scriptTextTemplate)
		if emptySegment then emptySegment.Parent = textContentScroller end
	end

	task.defer(updateScriptViewCanvasSize)
	local matchLocations = getMatchLocations(rawScriptContent, termsToActuallyUse) 
	populateMatchesScrollingFrame(matchLocations)
end

function ScriptViewer.setup()
	ui = uis.SVUI
	textContentScroller = ui.textContentScroller
	foundLinesScroller = ui.foundLinesScroller
	scriptViewerSearchInputTextBox = ui.scriptViewerSearchInputTextBox
	foundLineExampleButton = ui.foundLineExampleButton
	lineNumTemplate = ui.lineNumTemplate
	scriptTextTemplate = ui.scriptTextTemplate

	scriptViewerSearchInputTextBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			if performInScriptSearch then 
				performInScriptSearch() 
			end
		end
	end)
end

return ScriptViewer