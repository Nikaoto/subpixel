lg = love.graphics
fmt = string.format
gw = 1024
gh = 768
shader = nil
move = true

shaders = {
   subpixel = { sh = lg.newShader("subpixel.frag", "scale.vert") },
   subpixel_d7samurai = { sh = lg.newShader("subpixel_d7samurai.frag", "scale.vert") },
   none = { sh = lg.newShader("default.frag", "scale.vert") },
   bilinear = { sh = lg.newShader("bilinear.frag", "scale.vert") },
}
shaders.subpixel.next = "subpixel_d7samurai"
shaders.subpixel_d7samurai.next = "none"
shaders.none.next = "bilinear"
shaders.bilinear.next = "subpixel"

shader_name = "subpixel"
filter = "nearest"

function love.load()
   lg.setDefaultFilter("nearest", "nearest")
   sprite = lg.newImage("gnippie.png")
   sprite:setFilter("nearest", "nearest")
   love.window.setMode(gw, gh)

   -- Draw sprite onto texture (this pads the sprite)
   canvas = lg.newCanvas(gw, gh)
   canvas:setFilter(filter, filter)
   canvas:renderTo(function()
      local m, am = lg.getBlendMode()
      lg.setBlendMode("replace")
      lg.clear(0, 0, 0, 0)
      lg.setBlendMode(m, am)
      lg.setColor(1, 1, 1, 1)
      lg.draw(sprite, 0, 0)
   end)

   -- Draw sprite onto texture (this pads the sprite)
   canvas_right = lg.newCanvas(gw, gh)
   local filter_right = filter == "nearest" and "linear" or "nearest"
   canvas_right:setFilter(filter_right, filter_right)
   canvas_right:renderTo(function()
      local m, am = lg.getBlendMode()
      lg.setBlendMode("replace")
      lg.clear(0, 0, 0, 0)
      lg.setBlendMode(m, am)
      lg.setColor(1, 1, 1, 1)
      lg.draw(sprite, 0, 0)
   end)
end

function love.resize(w, h)
   gw = w
   gh = h
end

function love.update(dt)
end

function love.keypressed(k)
   if k == "1" then
      canvas_right:setFilter(filter, filter)
      filter = filter == "linear" and "nearest" or "linear"
      canvas:setFilter(filter, filter)
      return
   end

   if k == "2" then
      shader_name = shaders[shader_name].next
      return
   end

   if k == "3" then
      move = not move
      return
   end
end

function love.draw()
   lg.clear(1, 1, 1, 1)
   local time = love.timer.getTime()

   local scale = 1
   local x, y
   if move then
      x = gw/4 + math.sin(time) * 10
      y = math.sin(time*2 + 10) * 10
      scale = math.sin(time) + 14
   else
      x = gw/4
      y = gh/4
      scale = 1
   end

   local sh = shaders[shader_name].sh
   lg.setShader(sh)
   sh:send("texture_size", {canvas:getWidth(), canvas:getHeight()})
   sh:send("scale", 10)
   sh:send("vertScale", {1, 1})

   -- Zoom screen
   lg.push()
   local s = math.sin(time * 0.3) + 1.1
   lg.scale(s)
   lg.translate(1/s * gw/2 - gw/2, 1/s * gh/2 - gh/2)

   -- Draw left side
   lg.setColor(1, 1, 1, 1)
   lg.draw(
      canvas,
      0, 0, --x,y
      0,--math.sin(time/10) * math.pi*2,
      1, 1,
      0, 0 --canvas:getWidth()/2, canvas:getHeight()/2
   )

   -- Draw right side
   lg.setColor(1, 1, 1, 1)
   lg.draw(
      canvas_right,
      gw/2, 0,
      0,--math.sin(time/10) * math.pi*2,
      -1, 1,
      canvas:getWidth()/2, 0 --/2, canvas:getHeight()/2
   )
   lg.pop()


   lg.setShader()

   -- Draw separating line
   local t = 1
   lg.setColor(0, 0, 0, 1)
   lg.rectangle("fill", gw/2 - t, 0, t*2, gh)

   -- Print info
   lg.setColor(66/255, 135/255, 245/255, 1)   
   lg.print(
      fmt("1) texture_filter: %s\n", canvas:getFilter()) ..
      fmt("2) shader: %s\n", shader_name) ..
      fmt("3) move: %s\n", move),
      5, 5
   )
end
