lg = love.graphics
fmt = string.format
gw = 1024
gh = 768
shader = nil
move = true

shaders = {
   subpixel = { sh = lg.newShader("subpixel.frag") },
   none = { sh = lg.newShader("default.frag") },
   bilinear = { sh = lg.newShader("bilinear.frag") },
}
shaders.subpixel.next = "none"
shaders.none.next = "bilinear"
shaders.bilinear.next = "subpixel"

shader_name = "subpixel"
filter = "linear"

function love.load()
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
end

function love.resize(w, h)
   gw = w
   gh = h
end

function love.update(dt)
end

function love.keypressed(k)
   if k == "1" then
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

   local x, y, scale
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
   if sh then
      lg.setShader(sh)
      sh:send("textureSize", {canvas:getWidth(), canvas:getHeight()})
      sh:send("scale", scale)
   end

   -- Draw sprite
   lg.setColor(1, 1, 1, 1)
   lg.draw(canvas, 0, 80)

   if sh then
      lg.setShader()
   end

   -- Print info
   lg.setColor(66/255, 135/255, 245/255, 1)   
   lg.print(
      fmt("1) texture_filter: %s\n", canvas:getFilter()) ..
      fmt("2) shader: %s\n", shader_name) ..
      fmt("3) move: %s\n", move),
      5, 5
   )
end
