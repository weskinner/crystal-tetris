require "SDL2-Crystal/sdl2"
require "./graphics"

def get_input
    while LibSDL2.poll_event(out e) == 1
      case e.type
      when LibSDL2::QUIT
        return :quit
      end
    end
end

SDL2.run LibSDL2::INIT_EVERYTHING do
  raise "TTF_Init Error: " + String.new(LibSDL2.get_error) unless LibSDL2_TTF.init() != -1
  graphics = Tetris::Graphics.new

  quit = false
  until quit
    graphics.prerender

    action = get_input
    quit = true if action == :quit

    # update game

    # render

    # etc
  end


  LibSDL2_TTF.quit
end
