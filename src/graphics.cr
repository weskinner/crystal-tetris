require "./lib_sdl2_gfx"

include SDL2

module Tetris
  WINDOW_TITLE = "tetris-sdl-c"

  # a block 'pixel' of a playing field is 15px by 15px in size
  BLOCK_SIZE = 20

  # standard size of a tetris playing field
  PLAYFIELD_HEIGHT = 22
  PLAYFIELD_WIDTH = 10

  WINDOW_HEIGHT = PLAYFIELD_HEIGHT * ( BLOCK_SIZE + 1) + 1
  WINDOW_WIDTH = PLAYFIELD_WIDTH * ( BLOCK_SIZE + 1) + 1

  class Graphics
    property font
    property render

    def initialize
      @render_changed = false

      @window = LibSDL2.create_window(WINDOW_TITLE, LibSDL2::WINDOWPOS_CENTERED, LibSDL2::WINDOWPOS_CENTERED,
          WINDOW_WIDTH, WINDOW_HEIGHT, Window::Flags::SHOWN)
      unless @window
        raise "SDL_CreateWindow Error:  #{SDL2.error}"
      end

      # Create a renderer that will draw to the window, -1 specifies that we want to load whichever
      # video driver supports the flags we're passing
      #
      # Flags:
      # SDL_RENDERER_ACCELERATED: We want to use hardware accelerated rendering
      # SDL_RENDERER_PRESENTVSYNC: We want the renderer's present function (update screen) to be
      # synchornized with the monitor's refresh rate
      @render = LibSDL2.create_renderer(@window, -1, Renderer::Flags::ACCELERATED | Renderer::Flags::PRESENTVSYNC | Renderer::Flags::TARGETTEXTURE)
      unless @render
        raise "SDL_CreateRenderer Error:  #{SDL2.error}"
      end

      LibSDL2.set_render_draw_blend_mode(@render, LibSDL2::BlendMode::BLEND)

      # texture for render context
      @display = LibSDL2.create_texture(@render, 0x16462004_u32, LibSDL2::TextureAccess::TARGET, WINDOW_WIDTH, WINDOW_HEIGHT)

      LibSDL2.set_render_target(@render, @display)

      # Load font
      raise "TTF_OpenFont Error:  #{SDL2.error}" unless @font = LibSDL2_TTF.open_font(File.join(File.dirname(__FILE__), "Ubuntu-M.ttf"), 20)
    end

    def update_render
      if @render_changed
        LibSDL2.set_render_target(@render, nil)
        LibSDL2.render_copy(@render, @display, nil, nil)

        LibSDL2.render_present(@render)
        @render_changed = false;
      end
    end

    def set_render_changed
      @render_changed = true
    end

    def clear_background
      LibSDL2.set_render_draw_color(@render, 0x4f_u8, 0x4c_u8, 0x42_u8, 255_u8)
      LibSDL2.render_clear(@render)
    end

    def draw_block(x, y, color)
      # raise if x >= 0 && x < PLAYFIELD_WIDTH
      # raise if y >= 0 && y < PLAYFIELD_HEIGHT

      # top-left coords of block
      x_tl = x.to_i16 * (BLOCK_SIZE + 1) + 1;
      y_tl = y.to_i16 * (BLOCK_SIZE + 1) + 1;

      # bottom-right coords of block
      x_br = x_tl + BLOCK_SIZE;
      y_br = y_tl + BLOCK_SIZE;

      LibSDL2_GFX.box_color(@render as Void*, x_tl, y_tl, x_br, y_br, color);

      set_render_changed 
    end

    def render_text(text)
      # Show tetris score after all tetris operations are finished
      text_color = LibSDL2::Color.new(r: 0x11_u8, g: 0x1F_u8, b: 0x3F_u8)
      text_surface = LibSDL2_TTF.render_text_blended(@font, text, text_color)
      raise "TTF_Render Error #{LibSDL2.get_error}" if text_surface == nil

      mtexture = LibSDL2.create_texture_from_surface(@render, text_surface)
      raise "SDL_CreateTextureFromSurface Error #{LibSDL2.get_error}" if mtexture == nil

      mWidth = text_surface.value.w;
      mHeight = text_surface.value.h;

      LibSDL2.free_surface(text_surface)

      # render text
      render_quad = LibSDL2::Rect.new(x: (WINDOW_WIDTH - mWidth - 10), y: 10, w: mWidth, h: mHeight)
      LibSDL2.render_copy_ex(@render, mtexture, nil, pointerof(render_quad), 0_f64, nil, RenderFlip::NONE);

      LibSDL2.destroy_texture(mtexture)
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
