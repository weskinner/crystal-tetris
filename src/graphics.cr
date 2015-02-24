module Tetris
  WINDOW_TITLE = "tetris-sdl-c"

  # a block 'pixel' of a playing field is 15px by 15px in size
  BLOCK_SIZE = 20

  # standard size of a tetris playing field
  PLAYFIELD_HEIGHT = 22
  PLAYFIELD_WIDTH = 10

  WINDOW_HEIGHT = 22 * ( 20 + 1) + 1
  WINDOW_WIDTH = 22 * ( 20 + 1) + 1

  class Graphics
    def initialize
      @render_changed = false

      @window = LibSDL2.create_window(WINDOW_TITLE, LibSDL2::WINDOWPOS_CENTERED, LibSDL2::WINDOWPOS_CENTERED,
          WINDOW_WIDTH, WINDOW_HEIGHT, LibSDL2::WINDOW_SHOWN)

      if @window == nil
        raise "\nSDL_CreateWindow Error:  %s\n" + String.new(LibSDL2.get_error)
      end

      # Create a renderer that will draw to the window, -1 specifies that we want to load whichever
      # video driver supports the flags we're passing
      #
      # Flags:
      # SDL_RENDERER_ACCELERATED: We want to use hardware accelerated rendering
      # SDL_RENDERER_PRESENTVSYNC: We want the renderer's present function (update screen) to be
      # synchornized with the monitor's refresh rate
      @render = LibSDL2.create_renderer(@window, -1, LibSDL2::RENDERER_ACCELERATED | LibSDL2::RENDERER_PRESENTVSYNC | LibSDL2::RENDERER_TARGETTEXTURE)

      if @render == nil
        raise "\nSDL_CreateRenderer Error:  %s\n" + String.new(LibSDL2.get_error)
      end

      LibSDL2.renderer_set_blend_mode(@render, LibSDL2::BlendMode::BLEND)

      # texture for render context
      @display = LibSDL2.create_texture(@render, 0x16462004_u32, LibSDL2::TextureAccess::TARGET, WINDOW_WIDTH, WINDOW_HEIGHT)

      LibSDL2.set_render_target(@render, @display)

      # Load font
      @font = LibSDL2_TTF.open_font("Ubuntu-M.ttf", 20)

      if @font == nil
        raise "\nTTF_OpenFont Error:  %s\n" + String.new(LibSDL2.get_error)
      end
    end

    def prerender
      LibSDL2.set_render_target(@render, @display)
    end

    def finalize
      LibSDL2.destroy_renderer(@render)
      LibSDL2.destroy_window(@window)
    end
  end
end
