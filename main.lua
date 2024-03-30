lg = love.graphics
fmt = string.format
gw = 800
gh = 600
shader = nil
subpixel_shader = lg.newShader("subpixel.frag")

function love.load()
   sprite = lg.newImage("gnippie.png")
   love.window.setMode(gw, gh)
end

function love.resize(w, h)
   gw = w
   gh = h
end

function love.update(dt)
end

function love.keypressed(k)
   if k == "1" then
      local min, mag = sprite:getFilter()
      sprite:setFilter(
         min == "linear" and "nearest" or "linear",
         mag == "linear" and "nearest" or "linear"
      )
      return
   end

   if k == "2" then
      shader = shader == nil and subpixel_shader or nil
   end
end

function love.draw()
   lg.clear(1, 1, 1, 1)
   local time = love.timer.getTime()

   if shader then
      lg.setShader(shader)
      shader:send("textureSize", {sprite:getWidth(), sprite:getHeight()})
   end

   -- Draw sprite
   lg.setColor(1, 1, 1, 1)
   local x = gw/4 + math.sin(time) * 10
   local y = math.sin(time*2 + 10) * 10
   local scale = math.sin(time) + 10
   lg.draw(
      sprite,
      x,
      y,
      0,    -- rotation
      scale, scale, -- sx, sy
      0, 0, -- ox, oy
      0, 0  -- kx, ky
   )

   if shader then
      lg.setShader()
   end

   -- Print info
   lg.setColor(66/255, 135/255, 245/255, 1)   
   lg.print(
      fmt("1) texture_filter: %s\n", sprite:getFilter()) ..
      fmt("2) shader: %s\n",
         shader == subpixel_shader and "subpixel" or "default"),
      5, 5
   )
end
