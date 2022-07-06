-- states: start -> menu -> ingame
local state = "start"

while true do
  frame = emu.framecount()

  -- wait 10 frames before trying to activate menu
  if state == "start" and frame > 10 then
    local menu_flag = mainmemory.read_u16_be(0xFFAA)
    console.log("start: 0xFFAA = " .. menu_flag .. " (" .. frame .. ")")

    -- pulse A + B + C
    if emu.framecount() % 2 == 0 then
      joypad.set({A=true, B=true, C=true}, 1)
    else
      joypad.set({A=false, B=false, C=false}, 1)
    end

    if menu_flag ~= 0 then
      joypad.set({A=false, B=false, C=false}, 1)
      state = "menu"
    end

  -- MENU
  elseif state == "menu" then
    -- hit start to load level one
    -- it's okay to hold the start button
    joypad.set({Start=true}, 1)

    -- 0xE430 changes to 1 when we can control our character
    local started = memory.read_u16_be(0xE430)
    if started ~= 0 then
      state = "ingame"
    end

    console.log("menu: 0xE430 = " .. started .. " (" .. frame .. ")")

  -- INGAME
  elseif state == "ingame" then
    -- game map is at 0xFFF100
    -- 0xC cols, 0xC rows (0x90 length)
    local map = memory.read_bytes_as_array(0xFFF100, (0x90))
    console.log("playing!")
  else
    console.log("undefined state")
  end

  emu.frameadvance()
end
