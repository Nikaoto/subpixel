lg = love.graphics
fmt = string.format
gw = 1280
gh = 720
base_scale = 10
vert_tile_margin = 280
horiz_tile_margin = 220
horiz_tile = 3
vert_tile = 3
move = true
font = lg.newFont(14, "light")

text_color = {0/255, 82/255, 229/255, 1}
text_box_color_hovered = {1, 0.85, 0.7, 0.9}
text_box_color_unhovered = {1, 0.85, 0.7, 0.5}

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
   ["none"] = {},
}
scaling_methods["vertex_shader"].next = "love.graphics.draw"
scaling_methods["love.graphics.draw"].next = "love.graphics.scale"
scaling_methods["love.graphics.scale"].next = "none"
scaling_methods["none"].next = "vertex_shader"

movement_methods = {
   ["vertex_shader"] = {},
   ["love.graphics.draw"] = {},
   ["love.graphics.translate"] = {},
   ["none"] = {},
}
movement_methods["vertex_shader"].next = "love.graphics.draw"
movement_methods["love.graphics.draw"].next = "love.graphics.translate"
movement_methods["love.graphics.translate"].next = "none"
movement_methods["none"].next = "vertex_shader"


-- Configuration of the sides
both_sides = {
   scaling_method = "love.graphics.draw",
   movement_method = "none",
   rotation_method = "none",
}
left_side = {
   filter = "nearest",
   shader_name = "none",
   sprite = lg.newImage("gnippie.png"),
   padded_sprite = nil,
   current_texture = nil,
   hovered = false,
   offset = {0, 0},
   scale = base_scale,
   scaling_method = both_sides.scaling_method,
   movement_method = both_sides.movement_method,
   rotation_method = both_sides.rotation_method,
}
right_side = {
   filter = "linear",
   shader_name = "subpixel",
   sprite = lg.newImage("gnippie.png"),
   padded_sprite = nil,
   current_texture = nil,
   hovered = false,
   offset = {0, 0},
   scale = base_scale,
   scaling_method = both_sides.scaling_method,
   movement_method = both_sides.movement_method,
   rotation_method = both_sides.rotation_method,
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

  -- Set appropriate filters
  left_side.sprite:setFilter(left_side.filter, left_side.filter)
  left_side.padded_sprite:setFilter(left_side.filter, left_side.filter)
  right_side.sprite:setFilter(right_side.filter, right_side.filter)
  right_side.padded_sprite:setFilter(right_side.filter, right_side.filter)
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

   local time = love.timer.getTime()
   for _, side in pairs({left_side, right_side}) do
      -- Animate scaling   
      if side.scaling_method ~= "none" then
         side.scale = base_scale + math.sin(time) * base_scale / 2
      end

      -- Animate movement
      if side.scaling_method ~= "none" then
         side.offset[1] = math.sin(time) * gw/2
      end
   end
end

function draw_side_info(side, x, y)
   local mar = 5
   local pad = 5
   local w = mar*2 + 340
   local h = mar*2 + 50
   local r = 5

   -- Draw background
   if side.hovered then
      lg.setColor(text_box_color_hovered)
   else
      lg.setColor(text_box_color_unhovered)
   end
   lg.rectangle("fill", x + mar, y + mar, w, h, r, r)

   -- Draw info text
   lg.setColor(text_color)
   lg.print(
      fmt("1) texture_filter: %s\n", side.current_texture:getFilter()) ..
      fmt("2) shader: %s\n", side.shader_name) ..
      fmt("3) padding: %s\n", side.current_texture == side.padded_sprite),
      x + pad + mar, y + pad + mar
   )
end

function draw_side(side, x, y)
   -- Clear the side
   lg.setColor(1, 1, 1, 1)
   lg.rectangle("fill", x, y, gw/2, gh)
   lg.setScissor(x, y, gw/2, gh)

   lg.push()
   lg.translate(x, y)

   -- Set up scaling
   local vertex_shader_scale = {1, 1}
   local lg_draw_scale = {1, 1}
   local lg_scale_scale = {1, 1}
   if side.scaling_method == "vertex_shader" then
      vertex_shader_scale[1] = side.scale
      vertex_shader_scale[2] = side.scale
      lg.translate(
         (-1/vertex_shader_scale[1]) * gw,
         (-1/vertex_shader_scale[2]) * gh
      )
   elseif side.scaling_method == "love.graphics.draw" then
      lg_draw_scale[1] = side.scale
      lg_draw_scale[2] = side.scale
   elseif side.scaling_method == "love.graphics.scale" then
      lg_scale_scale[1] = side.scale
      lg_scale_scale[2] = side.scale
      lg.translate(
         (lg_scale_scale[1] - 1) * (-gw/4),
         (lg_scale_scale[2] - 1) * (-gh/2)
      )
   end

   -- Set up movement TODO:
   local vertex_shader_offset = {0, 0}
   local lg_draw_offset = {0, 0}
   local lg_translate_offset = {0, 0}

   -- TODO: Set up rotation

   -- Scale the camera (zoom in/out)
   lg.scale(lg_scale_scale[1], lg_scale_scale[2])


   -- Set up shaders
   local sh = shaders[side.shader_name].sh
   lg.setShader(sh)
   sh:send("texture_size", {
      side.current_texture:getWidth(),
      side.current_texture:getHeight()
   })
   sh:send("scale", vertex_shader_scale)
   
   -- Draw texture multiple times
   local hm = horiz_tile_margin
   local vm = vert_tile_margin
   if lg_scale_scale[1] ~= 1 or vertex_shader_scale[1] ~= 1 then hm = hm / 6 end
   if lg_scale_scale[2] ~= 1 or vertex_shader_scale[2] ~= 1 then vm = vm / 6 end

   for j=1, vert_tile do
      local vert_idx = (j-1) - (vert_tile-1)/2
      for i=1, horiz_tile do
         local horiz_idx = (i-1) - (horiz_tile-1)/2
         lg.draw(
            side.current_texture,
            gw/4 + lg_draw_offset[1] + hm * horiz_idx,
            gh/2 + lg_draw_offset[2] + vm * vert_idx,
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
   -- Settings for both sides
   -- Cycle scaling method
   if k == "4" then
      both_sides.scaling_method = scaling_methods[both_sides.scaling_method].next
      left_side.scaling_method = both_sides.scaling_method
      right_side.scaling_method = both_sides.scaling_method
      return
   end

   -- Cycle movement method
   if k == "5" then
      both_sides.movement_method = movement_methods[both_sides.movement_method].next
      left_side.movement_method = both_sides.movement_method
      right_side.movement_method = both_sides.movement_method
      return
   end

   -- Cycle rotation method
   if k == "6" then
      both_sides.rotation_method = rotation_methods[both_sides.rotation_method].next
      left_side.rotation_method = both_sides.rotation_method
      right_side.rotation_method = both_sides.rotation_method
      return
   end

   -- Settings for a single side (currently hovered)
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
end

function love.draw()
   lg.clear(1, 1, 1, 1)
   lg.setFont(font)

   -- Draw the sides
   draw_side(left_side, 0, 0)
   draw_side(right_side, gw/2, 0)

   -- Draw both_sides info in the bottom center
   local mar = 5
   local pad = 5
   local w = mar*2 + 340
   local h = mar*2 + 48
   local br = 5
   local x = gw/2 - w/2 - pad
   local y = gh - h

   -- Draw background
   lg.setColor(text_box_color_hovered)
   lg.rectangle("fill", x, y, w, h, br, br)

   -- Draw info text
   lg.setColor(text_color)
   lg.print(
      fmt("4) scaling_method: %s\n", both_sides.scaling_method) ..
      fmt("5) movement_method: %s\n", both_sides.movement_method) ..
      fmt("6) rotation_method: %s\n", both_sides.rotation_method),
      x + pad, y + pad
   )

   -- Draw separating line
   local t = 1
   lg.setColor(0, 0, 0, 1)
   lg.rectangle("fill", gw/2 - t, 0, t*2, gh - h)
end
