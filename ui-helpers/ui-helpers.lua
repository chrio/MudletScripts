Chrio = Chrio or {}
Chrio.uiHelper = Chrio.uiHelper or {}
local uih = Chrio.uiHelper
uih.version = '0.1.3'

-- Table for the different gauge gradients
uih.gradients = uih.gradients or {}
uih.gradients['flat'] = {pct = {[1] = 0, [2] = 1}, col = {[1] = 128, [2] = 128}}
uih.gradients['simple'] = {
    pct = {[1] = 0, [2] = 1},
    col = {[1] = 125, [2] = 14}
}
uih.gradients['hollow'] = {
    pct = {[1] = 0, [2] = 0.1, [3] = 0.15, [4] = 0.85, [5] = 0.9, [6] = 1},
    col = {[1] = 214, [2] = 129, [3] = 56, [4] = 193, [5] = 129, [6] = 66}
}
uih.gradients['round'] = {
    pct = { [1] = 0, [2] = 0.46, [3] = 0.50, [4] = 0.53, [5] = 0.76, [6] = 87, [7] = 1 },
    col = { [1] = 155, [2] = 28, [3] = 16, [4] = 25, [5] = 89, [6] = 68, [7] = 41 }
}
uih.gradients['glass'] = {
    pct = {[1] = 0, [2] = 0.1, [3] = 0.49, [4] = 0.5, [5] = 1},
    col = {[1] = 153, [2] = 140, [3] = 102, [4] = 82, [5] = 102}
}

uih.setGaugeStyle = function(gauge, red, green, blue, colorfactor, type, fontsize, textcss)
    local colorfactor = colorfactor or 3.5 -- used for the background. Higher value = darker background
    local cssfront, cssback, color, pct = '', '', {}, {}
    type = type or 'simple'
    local style = uih.gradients[string.lower(type)] or {pct = {[1] = 0, [2] = 1}, col = {[1] = 125, [2] = 14}}
    pct = style.pct
    color = style.col

    local h_grad =
        'background-color: QLinearGradient( x1: 0, y1: 0, x2: 0, y2: 1, '
    cssfront = h_grad;
    cssback = h_grad;
    for i, _ in ipairs(color) do
        local r, g, b = (color[i] + red) / 2, (color[i] + green) / 2, (color[i] + blue) / 2;
        cssfront = cssfront .. string.format('stop: %.2f rgb(%d,%d,%d)', pct[i], r, g, b) r, g, b = r / colorfactor, g / colorfactor, b / colorfactor;
        cssback = cssback .. string.format('stop: %.2f rgb(%d,%d,%d)', pct[i], r, g, b)
        if i < #color then
            cssfront = cssfront .. ','
            cssback = cssback .. ','
        end
    end
    cssfront = cssfront .. ');'
    cssback = cssback .. ');'

    local csstext = textcss or f [[padding-left: 0.2em; font: "Helvetica";]]
    if fontsize then gauge:setFontSize(fontsize) end
    gauge:setStyleSheet(cssfront, cssback, csstext)
end

--[[
  Test function, will draw gauges with random r,g,b color for each style in the uih.gradients table
]]
function uih:demo()
    local gauges = self.gauges or {}
    local dy = 0;
    local groupsize = 5
    local colorfactor = 3.5
    local gradients = self.gradients
    for stylename, _ in pairs(gradients) do
        for i = 1, groupsize do
            local name = stylename .. '#' .. i
            local y = '5%+' .. dy
            dy = dy + 25
            if not gauges[name] then
                gauges[name] = Geyser.Gauge:new({
                    name = name, x = "40%", y = y, width = "20%", height = "20px"
                })
            end
            local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
            self.setGaugeStyle(gauges[name], r, g, b, colorfactor, stylename)
            local text = string.format('%s rgb=%d,%d,%d', string.upper(name), r, g, b)
            gauges[name]:setValue(math.random(1, 100), 100, text)
            gauges[name]:show();
        end
        dy = dy + 20
    end
end

function uih:hideDemo()
    local g = self.gauges or {}
    for k,v in pairs(g) do
        if v.type and v.type == 'gauge' then
            v:hide()
            v = nil;
        end
    end
end
