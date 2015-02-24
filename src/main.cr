require "SDL2-Crystal/sdl2"
require "./*"

raise "Unable to init SDL " + String.new(LibSDL2.get_error) unless LibSDL2.init(LibSDL2::INIT_EVERYTHING)
raise "TTF_Init Error: " + String.new(LibSDL2.get_error) unless LibSDL2_TTF.init() != -1
Tetris::Graphics.new

LibSDL2.delay 2000_u32

LibSDL2_TTF.quit
LibSDL2.quit
