local DynamicValue = require('nibui.DynamicValue')

local Widget = {}

function Widget:new(config, document, parent)
    local defaults = {
        -- Colors
        shadow_color = 0, border_color = 0, background = 0, color = 15,
        -- Position and size
        x = 0, y = 0, z = 0, w = 0, h = 0, radius = 0,
        -- Content
        content = '', text_align = 'center', vertical_align = 'middle',
        text_palette = 0,
        -- Padding
        padding_top = 0, padding_left = 0, padding_bottom = 0, padding_right = 0,
    }

    local instance = {
        props = {},
        -- Mouse
        mouse = { inside = false },
        -- Tree
        children = {}, parent = nil, document = document, parent = parent,
        -- Methods
        onclick = function() end,
        onenter = function() end,
        onleave = function() end,
        onmove = function() end,
    }

    for k, _ in zip(config, defaults) do
        if config[k] then
            if type(config[k]) == 'number' then
                instance.props[k] = DynamicValue:new('interpolated', config[k], instance)
            elseif type(config[k]) == 'function' then
                instance[k] = config[k]
            elseif type(config[k]) == 'table' and config[k].isdynamicvalue then
                instance.props[k] = DynamicValue:new('interpolated', config[k], instance)
            else
                instance.props[k] = DynamicValue:new('static', config[k])
            end
        else
            if type(defaults[k]) == 'number' then
                instance.props[k] = DynamicValue:new('interpolated', defaults[k], instance)
            else
                instance.props[k] = DynamicValue:new('static', defaults[k])
            end
        end
    end

    setmetatable(instance, Widget)

    return instance
end

-- Acesso

function Widget:__index(k)
    if self.props[k] then
        return self.props[k]:get(self)
    else
        local raw = rawget(self, k)

        if raw then
            return raw
        else
            return Widget[k]
        end
    end
end

function Widget:__newindex(k, v)
    if self.props[k] then
        self.props[k]:set(v, self)
    else
        if type(v) == 'number' then
            self.props[k] = DynamicValue:new('interpolated', v, self)
        elseif type(v) == 'function' then
            rawset(self, k, v)
        elseif type(v) == 'table' and v.isdynamicvalue then
            self.props[k] = v
        else
            self.props[k] = DynamicValue:new('static', v)
        end
    end
end

function Widget:update(dt)
    -- Atualiza interpolated values
    for name, prop in pairs(self.props) do
        if prop.kind == 'interpolated' then
            prop:update(dt, self)
        end
    end

    -- Atualiza filhos
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

-- Loop

function Widget:draw()
    local x, y = self.x, self.y
    local w, h = self.w, self.h
    local r = math.floor(self.radius)
    local content = self.content
    local background = math.floor(self.background)
    local shadow_color = math.floor(self.shadow_color)
    local border_color = math.floor(self.border_color)
    local z = math.floor(self.z)

    if z ~= 0 then
      rectf(x+r, y+z, w-r*2, h, shadow_color)
      rectf(x, y+r+z, w, h-r*2, shadow_color)

      if r ~= 0 then
        circf(x+r, y+r+z, r, shadow_color)
        circf(x+w-r-1, y+r+z, r, shadow_color)
        circf(x+r, y+h-r+z-1, r, shadow_color)
        circf(x+w-r-1, y+h-r+z-1, r, shadow_color)
      end
    end

    rect(x+r-1, y-1, w-r*2+2, h+2, border_color)
    rect(x-1, y+r-1, w+2, h-r*2+2, border_color)

    if r ~= 0 then
        circf(x+r, y+r, r+1, border_color)
        circf(x+w-r-1, y+r, r+1, border_color)
        circf(x+r, y+h-r-1, r+1, border_color)
        circf(x+w-r-1, y+h-r-1, r+1, border_color)
    end

    rectf(x+r, y, w-r*2, h, background)
    rectf(x, y+r, w, h-r*2, background)

    if r ~= 0 then
        circf(x+r, y+r, r, background)
        circf(x+w-r-1, y+r, r, background)
        circf(x+r, y+h-r-1, r, background)
        circf(x+w-r-1, y+h-r-1, r, background)
    end

    -- TODO: use decorated text
    col(15, math.floor(self.color))

    local tx, ty = 0, 0

    if self.text_align == 'left' then
        tx = self.padding_left
    elseif self.text_align == 'center' then
        tx = x+w/2-#content/2*8
    elseif self.text_align == 'right' then
        tx = w-#content*8-self.padding_right
    end

    if self.vertical_align == 'top' then
        ty = self.padding_top
    elseif self.vertical_align == 'middle' then
        ty = y+h/2-4
    elseif self.vertical_align == 'bottom' then
        ty = h-8-self.padding_bottom
    end
    
    print(content, tx, ty, self.text_palette)

    col(15, 15)

    for _, child in ipairs(self.children) do
        child:draw()
    end
end

-- Eventos

function Widget:click(event)
    if self:in_bounds(event) then
        for _, child in ipairs(self.children) do
            if child:click(event) then
                return true
            end
        end

        if self.onclick then
            if self:onclick(event) then
                return true
            end
        end

        return true
    end
end

function Widget:move(event)
    if self:in_bounds(event) then
        if not self.mouse.inside then
            self.mouse.inside = true

            if self.onenter then
                if self:onenter(event) then
                    return
                end
            end
        end

        if self.onmove then
            if self:onmove(event) then
                return
            end
        end

        for _, child in ipairs(self.children) do
            child:move(event)
        end
    else
        self:leave(event)
    end
end

function Widget:leave(event)
    if self.mouse.inside then
        self.mouse.inside = false

        if self.onleave then
            self:onleave(event)
        end

        for _, child in ipairs(self.children) do
            child:leave(event)
        end
    end
end

function Widget:in_bounds(e)
    return e.x >= self.x and e.y >= self.y and
           e.x < self.x+self.w and
           e.y < self.y+self.h
end

return Widget
