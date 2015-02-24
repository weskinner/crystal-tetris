require "SDL2-Crystal/sdl2"
require "./graphics"
require "./game"

def get_input
    while LibSDL2.poll_event(out e) == 1
      case e.type
      when LibSDL2::QUIT
        return :quit
      when LibSDL2::KEYDOWN
        case e.key.key_sym.sym
        when LibSDL2::Key::ESCAPE; return :quit
        when LibSDL2::Key::DOWN; return :down
        when LibSDL2::Key::RIGHT; return :right
        when LibSDL2::Key::LEFT; return :left
        when LibSDL2::Key::UP; return :rotate
        when LibSDL2::Key::R; return :restart
        when LibSDL2::Key::SPACE; return :drop
        end
      end
    end
end

SDL2.run LibSDL2::INIT_EVERYTHING do
  raise "TTF_Init Error: " + String.new(LibSDL2.get_error) unless LibSDL2_TTF.init() != -1
  graphics = Tetris::Graphics.new
  tetris = Tetris::Game.new(graphics)
  tetris.setup

  quit = false
  until quit
    graphics.prerender

    action = get_input
    quit = true if action == :quit

    tetris.update action
    graphics.update_render

    # etc
    SDL2.delay 16_u32
  end


  LibSDL2_TTF.quit
end
