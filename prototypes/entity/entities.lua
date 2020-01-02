data:extend({
  {
    type = "explosion",
    name = "flashlight-button-press",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__core__/graphics/empty.png",
        priority = "low",
        width = 1,
        height = 1,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1
      },
    },
    light = {intensity = 0, size = 0},
    sound =
    {
      {
        filename = "__Keyboard__/sounds/flashlight_button_press.ogg",
        volume = 1.0
      }
    }
  }
})
