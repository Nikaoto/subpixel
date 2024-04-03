# Subpixel sampling
Test texture sampling for smooth pixel art in love2d. When doing
nearest-neighbor sampling on pixel art (which is the default for most pixel-art
games unfortunately), the sprites will experience jitter and artefacting during
scaling/rotation/movement. This repo aims to demonstrate the solution in simple
terms.

**Scaling:**

Left - default, right - subpixel sampling.

![](scaling.gif)

**Rotation:**

Left - default, right - subpixel sampling.

![](rotation.gif)

Clone the repo and run `love .` from inside. You can try out multiple different
shaders and movement types and compare them side-by-side with each other.

![](./screenshot.png)

- Use keypad numbers 4/5/6 to cycle between movement/rotation/scaling methods.
- Hover over your desired side with your mouse and use the keypad numbers 1/2/3
  to cycle between the filter/shader/padding.

**Left** - nearest neighbor sampling. **Right** - subpixel sampling.

 ![](rotation.gif)
