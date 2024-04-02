lg = love.graphics
fmt = string.format
gw = 1280
gh = 720

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

left_side = {
   filter = "nearest",
   shader_name = "none",
   sprite = lg.newImage("gnippie.png"),
   padded_sprite = nil,
}

right_side = {
   filter = "linear",
   shader_name = "subpixel-d7samurai",
   sprite = lg.newImage("gnippie.png"),
   padded_sprite = nil,
}

function pad_texture(tex, pad)
   pad = math.floor(pad) -- padding amount

   -- Make new texture
   local canvas = lg.newCanvas(
      tex:getWidth() + pad * 2,
      tex:getHeight() + pad * 2
   )

   -- Draw onto new texture
   canvas:renderTo(function()
      local mode, alpha_mode = lg.getBlendMode()
      lg.setBlendMode("replace")
      lg.clear(0, 0, 0, 0)
      lg.setBlendMode(mode, alpha_mode)
      lg.setColor(1, 1, 1, 1)
      lg.draw(tex, pad, pad)
   end)

   return canvas
end

function love.load()
   love.window.setMode(gw, gh)

   -- Make 1px padded versions of the sprites
   left_side.padded_sprite = pad_texture(left_side.sprite, 1)
   right_side.padded_sprite = pad_texture(right_side.sprite, 1)
end

function love.resize(w, h)
   gw = w
   gh = h
end

function love.update(dt)
end

function love.draw_info()
   lg.setColor(66/255, 135/255, 245/255, 1)   
   lg.print(
      fmt("1) texture_filter: %s\n", canvas:getFilter()) ..
      fmt("2) shader: %s\n", shader_name) ..
      fmt("3) move: %s\n", move),
      5, 5
   )
end

function love.keypressed(k)
   local mx, my = love.mouse.getPosition()

   local side = (mx <= gw/2) and left_side or right_side

   -- Cycle love2d's filter (love2d only offers nearest/linear)
   if k == "1" then
      side.filter = (sidel.filter == "linear") and "nearest" or "linear"
      side.sprite:setFilter(side.filter, side.filter)
      side.padded_sprite:setFilter(side.filter, side.filter)
      return
   end

   -- Cycle shader
   if k == "2" then
      side.shader_name = shaders[shader_name].next
      return
   end

   -- Change animation/demo
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

   draw_info()
end
