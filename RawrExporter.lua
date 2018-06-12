local _G, _M = getfenv(0), {}
setfenv(1, setmetatable(_M, {__index=_G}))

local module = CreateFrame('Frame')
local Item

_G.rawr = module

do
	local id = 0
	module.unique_id = function()
		id = id + 1
		return 'RawrExporter'..id
	end
end

do
	module.elapsed = 0
	module:SetScript('OnUpdate', function(self, elapsed)
		this.elapsed = this.elapsed + elapsed
		if this.elapsed >= 1 then
			this.elapsed = 0
			
			if module.req then
				if GetItemInfo(module.req.id) then
					module.req.func()
					module.req = nil
				else
					module.req.try()
				end
			end
			
		end
	end)
end

do
	local main_frame = CreateFrame('Frame', nil, UIParent)
	module.main_frame = main_frame
	main_frame:Hide()

	main_frame:SetPoint('CENTER', 0, 0)
	main_frame:SetWidth(400)
	main_frame:SetHeight(200)
	main_frame:SetBackdrop({
		bgFile=[[Interface\DialogFrame\UI-DialogBox-Background]],
		edgeFile=[[Interface\DialogFrame\UI-DialogBox-Border]],
		tile = true,
		tileSize = 32,
		edgeSize = 32,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	main_frame:SetClampedToScreen(true)
	main_frame:EnableMouse(true)
	main_frame:SetMovable(true)
	main_frame:RegisterForDrag('LeftButton')
	main_frame:SetScript('OnDragStart', function(self)
		self:StartMoving()
	end)
	main_frame:SetScript('OnDragStop', function(self)
		self:StopMovingOrSizing()
	end)
	
	do
		local close = CreateFrame('Button', nil, module.main_frame, 'UIPanelCloseButton')
		module.main_frame.close = close
		
		close:SetPoint('TOPRIGHT', -6, -6)
	end
	
	do
		local header = module.main_frame:CreateTexture()
		module.main_frame.header = header
		header:SetPoint('TOP', module.main_frame, 'TOP', 0, 12)
		header:SetWidth(256)
		header:SetHeight(64)
		header:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
		
		local header_text = module.main_frame:CreateFontString()
		header_text:SetFontObject(GameFontNormal)
		header_text:SetPoint('TOP', module.main_frame.header, 'TOP', 0, -14)
		header_text:SetText('Rawr Exporter')
	end
	
	do
		local label_itemID = module.main_frame:CreateFontString()
		module.main_frame.label_itemID = label_itemID
		label_itemID:SetFontObject(GameFontNormal)
		label_itemID:SetPoint('TOPLEFT', module.main_frame, 'TOPLEFT', 14, -36)
		label_itemID:SetJustifyV('MIDDLE')
		label_itemID:SetJustifyH('LEFT')
		label_itemID:SetText('Item ID')
		
		local inputBox = CreateFrame('EditBox', module.unique_id(), module.main_frame, 'InputBoxTemplate')
		module.main_frame.inputBox = inputBox
		inputBox:SetPoint('LEFT', module.main_frame.label_itemID, 'RIGHT', 10, 0)
		inputBox:SetWidth(64)
		inputBox:SetHeight(24)
		inputBox:SetMaxLetters(64)
		inputBox:SetMultiLine(false)
		inputBox:EnableMouse(true)
		inputBox:SetAutoFocus(false)
		
		inputBox:SetScript('OnEscapePressed', function(self)
			this:ClearFocus()
		end)
		inputBox:SetScript('OnEnterPressed', function(self)
			this:ClearFocus()
		end)
		
		inputBox:SetScript('OnEnter', function(self)
			if not this:HasFocus() and not this.shown then
				this.shown = true
				GameTooltip:SetOwner(module.main_frame.inputBox, 'ANCHOR_BOTTOMRIGHT')
				GameTooltip:SetText('You can also drag & drop your item here.')
				GameTooltip:Show()
			end
		end)
		inputBox:SetScript('OnLeave', function(self)
			GameTooltip:Hide()
		end)
		
		inputBox:SetScript('OnMouseUp', function(self)
			local type, id, link = GetCursorInfo()
			if type and type == 'item' then
				this:SetText(id)
				this:ClearFocus()
				ClearCursor()
			end
		end)
		
		local button = CreateFrame('Button', nil, module.main_frame.inputBox, 'UIPanelButtonTemplate')
		module.main_frame.inputBox.button = button
		button:SetPoint('LEFT', module.main_frame.inputBox, 'RIGHT', 5, 0)
		button:SetWidth(50)
		button:SetHeight(24)
		button:SetText('Export')
		
		button:SetScript('OnClick', function(self)
			module.main_frame.inputBox:ClearFocus()
			--module.main_frame.inputBox:SetText(tonumber(module.main_frame.inputBox:GetText()))
			if not GetItemInfo(module.main_frame.inputBox:GetText()) then
				module.main_frame.Scroll.EditBox:SetText('Fetching item from server')
				module.req = {
					['id'] = module.main_frame.inputBox:GetText(),
					['func'] = function()
						Item.Scanner.Set(module.main_frame.inputBox:GetText())
						module.main_frame.Scroll.EditBox:SetText(Item.ToXML())
					end,
					['try'] = function() -- this can, and probably should be done with clousers but im lazy
						Item.Scanner.Tooltip:SetHyperlink('item:' .. module.main_frame.inputBox:GetText())
					end,
				}
			else
				Item.Scanner.Set(module.main_frame.inputBox:GetText())
				module.main_frame.Scroll.EditBox:SetText(Item.ToXML())
			end
		end)
	end
	
	do
		local panic = CreateFrame('CheckButton', module.unique_id(), module.main_frame, 'UICheckButtonTemplate')
		module.main_frame.panic = panic
		panic:SetPoint('TOPRIGHT', module.main_frame, 'TOPRIGHT', -50, -26)
		_G[panic:GetName()..'Text']:SetText('PANIC')
		_G.PANIC = panic
	end
	
	do
		local Scroll = CreateFrame('ScrollFrame', module.unique_id(), module.main_frame, 'UIPanelScrollFrameTemplate')
		module.main_frame.Scroll = Scroll
		Scroll:SetHitRectInsets(0, 0, 5, 5)
		Scroll:SetPoint('TOP', module.main_frame, 'TOP', 0, -60)
		Scroll:SetPoint('LEFT', 10, 0)
		Scroll:SetPoint('RIGHT', -40, 0)
		Scroll:SetPoint('BOTTOM', module.main_frame, 'BOTTOM', 0, 10)
		Scroll:SetBackdrop({
			bgFile=[[Interface\Tooltips\UI-Tooltip-Background]],
			edgeFile=[[Interface\Tooltips\UI-Tooltip-Border]],
			tile = true,
			tileSize = 16,
			edgeSize = 16,
			insets = { left = 5, right = 5, top = 5, bottom = 5 }
		})
		Scroll:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b, 0.5)
		Scroll:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
			
		do
			local EditBox = CreateFrame('EditBox', module.unique_id(), module.main_frame)
			module.main_frame.Scroll.EditBox = EditBox
			EditBox:SetPoint('TOP', 0, 0)
			EditBox:SetTextInsets(5, 5, 5, 5)
			EditBox:SetWidth(module.main_frame.Scroll:GetWidth())
			EditBox:SetMaxLetters(64000)
			EditBox:SetMultiLine(true)
			EditBox:EnableMouse(true)
			EditBox:SetAutoFocus(false)
			EditBox:SetScript('OnEscapePressed', function(self)
				this:ClearFocus()
			end)
			
			EditBox:SetFontObject(ChatFontNormal)
			
			Scroll:SetScrollChild(EditBox)
		end
	end
end

local ItemSlot = {
	['INVTYPE_HEAD'] = 'Head',
	['INVTYPE_NECK'] = 'Neck',
	['INVTYPE_SHOULDER'] = 'Shoulders',
	['INVTYPE_CLOAK'] = 'Back',
	['INVTYPE_CHEST'] = 'Chest',
	['INVTYPE_ROBE'] = 'Chest',
	['INVTYPE_BODY'] = 'Shirt',
	['INVTYPE_TABARD'] = 'Tabard',
	['INVTYPE_WRIST'] = 'Wrist',
	['INVTYPE_HAND'] = 'Hands',
	['INVTYPE_WAIST'] = 'Waist',
	['INVTYPE_LEGS'] = 'Legs',
	['INVTYPE_FEET'] = 'Feet',
	['INVTYPE_FINGER'] = 'Finger',
	['INVTYPE_TRINKET'] = 'Trinket',
	['INVTYPE_WEAPON'] = 'OneHand',
	['INVTYPE_2HWEAPON'] = 'TwoHand',
	['INVTYPE_WEAPONMAINHAND'] = 'MainHand',
	['INVTYPE_WEAPONOFFHAND'] = 'OffHand',
	['INVTYPE_SHIELD'] = 'OffHand',
	['INVTYPE_HOLDABLE'] = 'OffHand',
	['INVTYPE_THROWN'] = 'Ranged',
	['INVTYPE_RANGED'] = 'Ranged',
	['INVTYPE_RANGEDRIGHT'] = 'Ranged',
	['INVTYPE_RELIC'] = 'Ranged',
	['INVTYPE_AMMO'] = 'Projectile',
	['INVTYPE_QUIVER'] = 'ProjectileBag',
	['INVTYPE_BAG'] = 'ProjectileBag',
}

do
	function module:print(msg)
		DEFAULT_CHAT_FRAME:AddMessage(msg)
	end
end

do
	function module:parse_link(link)
		local _, _, item_id, enchant_id, suffix_id, unique_id, name = strfind(link, '|c%x%x%x%x%x%x%x%x|Hitem:(%d*):(%d*):%d*:%d*:%d*:%d*:(-?%d*):(-?%d*)[:0-9]*|h%[(.-)%]|h|r')
		return tonumber(item_id) or 0, tonumber(suffix_id) or 0, tonumber(unique_id) or 0, tonumber(enchant_id) or 0, name
	end
end

do
	CreateFrame('GameTooltip', 'RawrExporerItemTooltip', nil, 'GameTooltipTemplate')
	RawrExporerItemTooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')
	
	Item = {}
	module.Item = Item
	
	Item.Stats = {}
	Item.Stats.Size = function()
		local size = 0
		for key, value in pairs(Item.Stats.Values) do
			size = size + 1
		end
		return size
	end
	Item.Stats.Values = {}
	Item.Stats.ToValue = function(text)
		text = gsub(text, '%s+', '')
		
		if text == 'ResilienceRating' then
			text = 'Resilience'
		elseif text == 'CriticalStrikeRating' then
			text = 'CritRating'
		end
		
		return text
	end
	Item.Stats.Reset = function()
		Item.Stats.Values = {
			['Agility'] = nil,
			['Stamina'] = nil,
			['AttackPower'] = nil,
			['Strength'] = nil,
			['CritRating'] = nil,
			['HitRating'] = nil,
			['Armor'] = nil,
			['ArmorPenetration'] = nil,
			['ExpertiseRating'] = nil,
			['HasteRating'] = nil,
			['Resilience'] = nil,
		}
	end
	
	Item.Id = nil
	Item.Name = nil
	Item.Icon = nil
	Item.Slot = nil
	Item.Quality = nil
	Item.Type = nil
	Item.MinDamage = nil
	Item.MaxDamage = nil
	Item.SetName = nil
	Item.Speed = nil
	Item.Unique = nil
	
	Item.Reset = function()
		Item.Stats.Reset()
		Item.Sockets.Reset()
		
		Item.Id = nil
		Item.Name = nil
		Item.Icon = nil
		Item.Slot = nil
		Item.Quality = nil
		Item.Type = nil
		Item.MinDamage = nil
		Item.MaxDamage = nil
		Item.SetName = nil
		Item.Speed = nil
		Item.Unique = nil
	end
	
	Item.Sockets = {}
	Item.Sockets.Stats = {
		['Values'] = {},
		['Size'] = 0,
	}
	Item.Sockets.Slots = {}
	Item.Sockets.Reset = function()
		Item.Sockets.Stats = {['Values']={}, ['Size']=0}
		Item.Sockets.Slots = {}
	end
	Item.Sockets.Get = function()
		return Item.Sockets.Slots, Item.Sockets.Stats
	end
	Item.Sockets.GetColor = function(text)
		local _, _, value = strfind(text, '(.+) Socket')
		if value then
			Item.Sockets.Add(value)
		end
		return value
	end
	Item.Sockets.Add = function(color)
		tinsert(Item.Sockets.Slots, color)
	end
	Item.Sockets.GetBonus = function(text)
		local _, _, value, type = strfind(text, 'Socket Bonus: %+(%d+) (.+)')
		if type then
			type = Item.Stats.ToValue(type)
			Item.Sockets.Stats.Values[type] = value
			Item.Sockets.Stats.Size = Item.Sockets.Stats.Size + 1
		end
		return value, type
	end
	
	Item.ToXML = function()
		if not Item.Id then return '' end
		
		local data = ''
		
		data = data..'<Item>\n'
		data = data..' <Name>'..Item.Name..'</Name>\n'
		data = data..' <Id>'..Item.Id..'</Id>\n'
		data = data..' <IconPath>'..Item.Icon..'</IconPath>\n'
		data = data..' <Slot>'..Item.Slot..'</Slot>\n'
		
		if Item.Stats.Size() > 0 then
			data = data..' <Stats>\n'
			
			for key, value in pairs(Item.Stats.Values) do
				data = data..'  <'..key..'>'..value..'</'..key..'>\n'
			end
			
			data = data..' </Stats>\n'
		end
		
		local sockets, socketBonus = Item.Sockets.Get()
		data = data..' <Sockets>\n'
		
		for key, value in ipairs(sockets) do
			data = data..'  <Color'..key..'>'..value..'</Color'..key..'>\n'
		end
		
		if socketBonus and socketBonus.Size > 0 then
			data = data..'  <Stats>\n'
			
			for key, value in pairs(socketBonus.Values) do
				data = data..'   <'..key..'>'..value..'</'..key..'>\n'
			end
			
			data = data..'  </Stats>\n'
		else
			data = data..'  <Stats />\n'
		end
		
		data = data..' </Sockets>\n'
		
		data = data..' <Quality>'..Item.Quality..'</Quality>\n'
		
		if Item.SetName then
			data = data..' <SetName>'..Item.SetName..'</SetName>\n'
		end
		
		data = data..' <Type>'..Item.Type..'</Type>\n'
		
		if Item.MinDamage then
			data = data..' <MinDamage>'..Item.MinDamage..'</MinDamage>\n'
		end
		if Item.MaxDamage then
			data = data..' <MaxDamage>'..Item.MaxDamage..'</MaxDamage>\n'
		end
		if Item.Speed then
			data = data..' <Speed>'..Item.Speed..'</Speed>\n'
		end
		if Item.Unique then
			data = data..' <Unique>true</Unique>\n'
		end
		
		data = data..'</Item>\n'
		
		return data
	end
	
	Item.Scanner = {}
	Item.Scanner.Tooltip = RawrExporerItemTooltip
	Item.Scanner.Name = 'RawrExporerItemTooltip'
	Item.Scanner.Set = function(item_id)
		Item.Reset()
		
		Item.Scanner.Tooltip:ClearLines()
		Item.Scanner.Tooltip:SetHyperlink('item:' .. item_id)
		local name, link, rarity, level, minLevel, type, subType,
		stackCount, itemEquipLoc, itemTexture = GetItemInfo(item_id)
		
		if not name then
			if module.main_frame.panic:GetChecked() then
				module:print('emergecy abort')
			end
			return
		end
		
		Item.Id = item_id
		Item.Name = name
		Item.Slot = Item.GetSlot(itemEquipLoc)
		Item.Quality = Item.GetQuality(rarity)
		
		if type == 'Weapon' then
			Item.Type = Item.GetWeaponType(subType)
		elseif type == 'Back' then
			Item.Type = 'None'
		else
			if subType == 'Miscellaneous' then subType = 'None' end
			Item.Type = subType
		end
		
		Item.Icon = strlower(gsub(itemTexture, 'Interface\\Icons\\', ''))
		
		local Left, Right
		for i = 1, Item.Scanner.Tooltip:NumLines(), 1 do
			Left = _G[Item.Scanner.Name..'TextLeft'..i]:GetText()
			Right = _G[Item.Scanner.Name..'TextRight'..i]:GetText()
			
			if Left and Left ~= '' then
				if module.main_frame.panic:GetChecked() then
					module:print(Left)
				end
				
				Item.Stats.Values.Armor = Item.Stats.Values.Armor or Item.GetStat.Armor(Left)
				Item.Stats.Values.Stamina = Item.Stats.Values.Stamina or Item.GetStat.Stamina(Left)
				Item.Stats.Values.Agility = Item.Stats.Values.Agility or Item.GetStat.Agility(Left)
				Item.Stats.Values.Strength = Item.Stats.Values.Strength or Item.GetStat.Strength(Left)
				if Item.Stats.Values.AttackPower and Item.GetStat.AttackPower(Left) then
					Item.Stats.Values.AttackPower = Item.Stats.Values.AttackPower + Item.GetStat.AttackPower(Left)
				else
					Item.Stats.Values.AttackPower = Item.GetStat.AttackPower(Left) or Item.Stats.Values.AttackPower
				end
				Item.Stats.Values.CritRating = Item.Stats.Values.CritRating or Item.GetStat.CritRating(Left)
				Item.Stats.Values.HitRating = Item.Stats.Values.HitRating or Item.GetStat.HitRating(Left)
				Item.Stats.Values.Resilience = Item.Stats.Values.Resilience or Item.GetStat.Resilience(Left)
				Item.Stats.Values.ArmorPenetration = Item.Stats.Values.ArmorPenetration or Item.GetStat.ArmorPenetration(Left)
				Item.Stats.Values.ExpertiseRating = Item.Stats.Values.ExpertiseRating or Item.GetStat.ExpertiseRating(Left)
				Item.Stats.Values.HasteRating = Item.Stats.Values.HasteRating or Item.GetStat.HasteRating(Left)
				
				Item.Sockets.GetColor(Left)
				Item.Sockets.GetBonus(Left)
				
				local min,max = Item.GetDamage(Left)
				if min and max then
					Item.MinDamage, Item.MaxDamage = min, max
				end
				
				local _,_, value = strfind(Left, '(.+) %(%d/%d%)')
				if value then
					Item.SetName = value
				end
				
				if Left == 'Unique' then
					Item.Unique = true
				end
				
			end
			if Right and Right ~= '' then
				Item.Speed = Item.Speed or Item.GetSpeed(Right)
			end
		end
	end
	
	Item.GetSpeed = function(text)
		local _, _, value = strfind(text, 'Speed (%d+%.%d+)')
		return value
	end
	Item.GetDamage = function(text)
		local _, _, min, max = strfind(text, '(%d+) %- (%d+) Damage')
		return min, max
	end
	-- provided by GetItemInfo, #4
	Item.GetQuality = function(value)
		if value == 1 then
			return 'Common'
		elseif value == 2 then
			return 'Uncommon'
		elseif value == 3 then
			return 'Rare'
		elseif value == 4 then
			return 'Epic'
		elseif value == 5 then
			return 'Legendary'
		elseif value == 6 then
			return 'Artifact'
		end
		
		return 'Poor'
	end
	-- provided by GetItemInfo, #9
	Item.GetSlot = function(value)
		if ItemSlot[value] then
			return ItemSlot[value]
		end
		
		return 'None'
	end
	Item.GetWeaponType = function(text)
		if strsub(text, -1, -1) == 's' then
			text = strsub(text, 1, -2)
		end
		
		text = gsub(text, ' ', '')
		text = gsub(text, '-', '')
		text = gsub(text, 'Handed', 'Hand')
		
		if text == 'Stave' then
			text = 'Staff'
		end
		
		return text
	end
	
	Item.GetStat = {}
	
	Item.GetStat.Armor = function(text)
		local _, _, value = strfind(text, '^(%d+) Armor')
		return value
	end
	Item.GetStat.Stamina = function(text)
		local _, _, value = strfind(text, '^%+(%d+) Stamina')
		return value
	end
	Item.GetStat.Strength = function(text)
		local _, _, value = strfind(text, '^%+(%d+) Strength')
		return value
	end
	Item.GetStat.Agility = function(text)
		local _, _, value = strfind(text, '^%+(%d+) Agility')
		return value
	end
	Item.GetStat.AttackPower = function(text)
		local _, _, value = strfind(text, '^%+(%d+) Attack Power')
		if value then
			return value
		end
		local _, _, value = strfind(text, 'Equip: Increases attack power by (%d+)%.')
		if value then
			return value
		end
		local _, _, value, valueTime, minutes, seconds = strfind(text, 'Use: Increases attack power by (%d+) for (%d+) sec%. %((%d+) Min (%d+) Secs Cooldown%)')
		if seconds then
			local t = (minutes * 60) + seconds
			return value * valueTime / t
		end
		local _, _, value, valueTime, minutes = strfind(text, 'Use: Increases your melee and ranged attack power by (%d+)%.  Effect lasts for (%d+) sec%. %((%d+) Mins Cooldown%)')
		if minutes then
			local t = (minutes * 60)
			return value * valueTime / t
		end
	end
	Item.GetStat.CritRating = function(text)
		local _, _, value = strfind(text, 'Equip: Improves critical strike rating by (%d+)%.')
		return value
	end
	Item.GetStat.HitRating = function(text)
		local _, _, value = strfind(text, 'Equip: Improves hit rating by (%d+)%.')
		return value
	end
	Item.GetStat.Resilience = function(text)
		local _, _, value = strfind(text, 'Equip: Increases your resilience rating by (%d+)%.')
		if value then
			return value
		end
		local _, _, value = strfind(text, 'Equip: Improves your resilience rating by (%d+)%.')
		return value
	end
	Item.GetStat.ArmorPenetration = function(text)
		local _, _, value = strfind(text, 'Equip: Increases armor penetration rating by (%d+)%.')
		return value
	end
	Item.GetStat.ExpertiseRating = function(text)
		local _, _, value = strfind(text, 'Equip: Increases expertise rating by (%d+)%.')
		return value
	end
	Item.GetStat.HasteRating = function(text)
		local _, _, value = strfind(text, 'Equip: Increases your haste rating by (%d+)%.')
		return value
	end
	
	_G.ItemAPI = Item
end


_G.SLASH_RAWREXPORTER1 = '/export'
_G.SLASH_RAWREXPORTER2 = '/rawrexporter'
function SlashCmdList.RAWREXPORTER(command)
	local id = module:parse_link(command)
	if id == 0 then
		id = tonumber(command)
	end
	
	if id and id > 0 then
		module.main_frame.inputBox:SetText(id)
	end
	
	module.main_frame:Show()
end
