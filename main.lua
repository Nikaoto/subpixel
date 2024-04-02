lg = love.graphics
fmt = string.format
gw = 1280
gh = 720
base_scale = 10
vert_tile_margin = 260
horiz_tile_margin = 200
horiz_tile = 3
vert_tile = 3
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

scaling_methods = {
   ["vertex_shader"] = {},
   ["love.graphics.draw"] = {},
   ["love.graphics.scale"] = {},
}
scaling_methods["vertex_shader"].next = "love.graphics.draw"
scaling_methods["love.graphics.draw"].next = "love.graphics.scale"
scaling_methods["love.graphics.scale"].next = "vertex_shader"


animate_scaling = true
animate_movement = false
animate_rotation = false

left_side = {
   filter = "nearest",
   shader_name = "none",
   sprite = lg.newImage("gnippie.png"),
   padded_sprite = nil,
   current_texture = nil,
   hovered = false,
   offset = {0, 0},
   scale = base_scale,
   movement_method = "",
   scaling_method = "love.graphics.draw",
   rotation_method = "",
}
right_side = {
   filter = "linear",
   shader_name = "subpixel_d7samurai",
   sprite = lg.newImage("gnippie.png"),
   padded_sprite = nil,
   current_texture = nil,
   hovered = false,
   offset = {0, 0},
   scale = base_scale,
   movement_method = "",
   scaling_method = "love.graphics.scale",
   rotation_method = "",
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
   love.window.setMode(gw, gh, {resizable = true, vsync = 1})

   -- Make 1px padded versions of the sprites
   left_side.padded_sprite = pad_texture(left_side.sprite, 1)
   right_side.padded_sprite = pad_texture(right_side.sprite, 1)

   -- Set textures to use from the start
   left_side.current_texture = left_side.sprite
   right_side.current_texture = right_side.padded_sprite
end

function love.resize(w, h)
   gw = w
   gh = h
end

function love.update(dt)
   -- Determine which side is hovered by the mouse
   local mx, my = love.mouse.getPosition()
   if mx <= gw/2 and mx > 0 then
      left_side.hovered  = true
      right_side.hovered = false
   elseif mx < gw-1 and mx > gw/2 then
      left_side.hovered  = false
      right_side.hovered = true
   else
      left_side.hovered  = false
      right_side.hovered = false
   end
   if my >= gh - 1 or my <= 0 then
      left_side.hovered  = false
      right_side.hovered = false
   end

   -- Animate movement

   -- Animate scaling
   local time = love.timer.getTime()

   -- local scale = 1
   -- local x, y
   -- if move then
   --    x = gw/4 + math.sin(time) * 10
   --    y = math.sin(time*2 + 10) * 10
   --    scale = math.sin(time) + 14
   -- else
   --    x = gw/4
   --    y = gh/4
   --    scale = 1
   -- end

   
   -- Zoom screen
   -- lg.push()
   -- local s = math.sin(time * 0.3) + 1.1
   -- lg.scale(s)
   -- lg.translate(1/s * gw/2 - gw/2, 1/s * gh/2 - gh/2)

   -- Animate scaling
   if animate_scaling then
      for _, side in pairs({left_side, right_side}) do
         side.scale = base_scale + math.sin(time) * base_scale / 2
      end
   end
end

function draw_side_info(side, x, y)
   local mar = 5
   local pad = 5
   local w = mar*2 + 260
   local h = mar*2 + 130
   local r = 5

   -- Draw background
   if side.hovered then
      lg.setColor(235/255, 201/255, 63/255, 0.7)
   else
      lg.setColor(235/255, 201/255, 63/255, 0.3)
   end
   lg.rectangle("fill", x + mar, y + mar, w, h, r, r)

   -- Draw info text
   lg.setColor(63/255, 123/255, 235/255, 1)   
   lg.print(
      fmt("1) texture_filter: %s\n", side.current_texture:getFilter()) ..
      fmt("2) shader: %s\n", side.shader_name) ..
      fmt("3) padding: %s\n", side.current_texture == side.padded_sprite) ..
      fmt("4) scaling_method: %s\n", side.scaling_method) ..
      fmt("5) movement_method: %s\n", side.movement_method) ..
      fmt("6) rotation_method: %s\n", side.rotation_method) ..
      fmt("7) animate_scaling: %s\n", animate_scaling) ..
      fmt("8) animate_movement: %s\n", animate_movement) ..
      fmt("9) animate_rotation: %s\n", animate_rotation),
      x + pad + mar, y + pad + mar
   )
end

function draw_side(side, x, y)
   -- Clear the side
   lg.setColor(1, 1, 1, 1)
   lg.rectangle("fill", x, y, gw/2, gh)
   lg.setScissor(x, y, gw/2, gh)

   -- Set up scaling
   local vertex_shader_scale = {1, 1}
   local lg_draw_scale = {1, 1}
   local lg_scale_scale = {1, 1}
   if side.scaling_method == "vertex_shader" then
      vertex_shader_scale[1] = side.scale
      vertex_shader_scale[2] = side.scale
   elseif side.scaling_method == "love.graphics.draw" then
      lg_draw_scale[1] = side.scale
      lg_draw_scale[2] = side.scale
   elseif side.scaling_method == "love.graphics.scale" then
      lg_scale_scale[1] = side.scale
      lg_scale_scale[2] = side.scale
   end

   -- TODO: Set up movement
   local lg_draw_offset = {0, 0}
   local lg_translate_offset = {0, 0}

   -- TODO: Set up rotation

   -- Apply the transformations.
   -- This does nothing if the respective method is not selected.
   lg.push()
   lg.translate(
      (lg_scale_scale[1] - 1) * gw/2,
      (lg_scale_scale[2] - 1) * gh/2
   )
   lg.scale(lg_scale_scale[1], lg_scale_scale[2])

   -- Set up shaders
   local sh = shaders[side.shader_name].sh
   lg.setShader(sh)
   sh:send("texture_size", {
      side.current_texture:getWidth(),
      side.current_texture:getHeight()
   })
   sh:send("vertScale", vertex_shader_scale)
   
   -- Draw texture multiple times
   for j=1, vert_tile do
      local vert_idx = (j-1) - (vert_tile-1)/2
      for i=1, horiz_tile do
         local horiz_idx = (i-1) - (horiz_tile-1)/2
         lg.draw(
            side.current_texture,
            x + gw/4 + lg_draw_offset[1] + horiz_tile_margin * horiz_idx,
            y + gh/2 + lg_draw_offset[2] + vert_tile_margin * vert_idx,
            0, -- TODO: rotation
            lg_draw_scale[1], lg_draw_scale[2],
            side.current_texture:getWidth()/2, side.current_texture:getHeight()/2
         )
      end
   end

   lg.setShader()
   lg.pop()

   -- Draw info
   draw_side_info(side, x, y)

   lg.setScissor()
end

function love.keypressed(k)
   local side
   if left_side.hovered then
      side = left_side
   elseif right_side.hovered then
      side = right_side
   else
      return
   end

   -- Cycle love2d's filter (love2d only offers nearest/linear)
   if k == "1" then
      side.filter = (side.filter == "linear") and "nearest" or "linear"
      side.sprite:setFilter(side.filter, side.filter)
      side.padded_sprite:setFilter(side.filter, side.filter)
      return
   end

   -- Cycle shader
   if k == "2" then
      side.shader_name = shaders[side.shader_name].next
      return
   end

   -- Cycle padding
   if k == "3" then
      side.current_texture = side.current_texture == side.padded_sprite and
         side.sprite or side.padded_sprite
      return
   end

   -- Cycle scaling method
   if k == "4" then
      side.scaling_method = scaling_methods[side.scaling_method].next
      return
   end

   -- Cycle movement method
   if k == "5" then
      --side.movement_method = movement_methods[side.movement_method].next
      return
   end

   -- Cycle rotation method
   if k == "6" then
      --side.rotation_method = rotation_methods[side.rotation_method].next
      return
   end

   if k == "7" then
      animate_scaling = not animate_scaling
      return
   end

   if k == "8" then
      animate_movement = not animate_movement
      return
   end

   if k == "9" then
      animate_rotation = not animate_rotation
      return
   end
end

function love.draw()
   lg.clear(1, 1, 1, 1)

   -- Draw the sides
   draw_side(left_side, 0, 0)
   draw_side(right_side, gw/2, 0)

   -- Draw separating line
   local t = 1
   lg.setColor(0, 0, 0, 1)
   lg.rectangle("fill", gw/2 - t, 0, t*2, gh)

   draw_side_info(left_side, 0, 0)
   draw_side_info(right_side, gw/2, 0)
end
