# Subpixel sampling
Testing texture sampling and filtering in love2d.

The original aim was to find out how to adjust the rendering pipeline of love2d
to draw pixel art sprites without jitter.

- 3 demos: scale, move, rotate, none
- camera movement with mouse
- toggle 1px border
- toggle between love2d filters(nearest, linear)
- toggle between shaders (subpixel-niko, subpixel-lod, subpixel-grad, subpixel-precond-d7samurai, billinear, none)
- toggle movevment type (vertex shader, love.graphics.draw, love.graphics.translate)
- toggle scaling type (vertex shader, love.graphics.draw, love.graphics.scale)
- toggle rotation type (vertex shader, love.graphics.draw, love.graphics.rotate)


# Notable discoveries
- Using `sx` and `sy` when doing `love.graphics.draw` does not work with the
  shader, but doing `love.graphics.scale` instead for scaling works.
