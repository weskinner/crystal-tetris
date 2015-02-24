module Tetris
  module ColorBlock
    EMPTY = 0xFFB3C0CC_u32
    TEAL = 0xFFFFDB7F_u32
    BLUE = 0xFFD97400_u32
    ORANGE = 0xFF1B85FF_u32
    YELLOW = 0xFF00DCFF_u32
    GREEN = 0xFF40CC2E_u32
    PURPLE = 0xFF4B1485_u32
    RED = 0xFF4B59F2_u32
  end

  class Tetromino
  end

  class Game
    def initialize(@graphics)
      @cb_timer = 0
      @playfield = Array(UInt32).new PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH, 0_u32
      @tetromino_queue_size = 7
      @tetromino_queue = [] of Tetromino
      @tetromino_action = :none
    end

    def setup
      # set up SDL timer
      LibSDL2.remove_timer(@cb_timer) unless @cb_timer == 0
      @cb_timer = 0

      @tetromino_action = :none;

      # Empty the playfield
      ((PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH)-1..0).each do |i|
        @playfield[i] = ColorBlock::EMPTY
      end

      # build tetromino queue

      # apply shuffle algorithm

      draw_playing_field

      spawn_tetromino
    end

    def draw_playing_field
      @graphics.clear_background

      ((PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH)-1..0).each do |i|
        set_playfield(i % PLAYFIELD_WIDTH, i / PLAYFIELD_WIDTH, @playfield[i])
      end

      @graphics.set_render_changed
    end

    private def set_playfield(x, y, color)
      @playfield[(y * PLAYFIELD_WIDTH) + x] = color
      @graphics.draw_block(x, y, color)
    end

    def spawn_tetromino
      #TODO
    end

    private def shuffle
      #TODO
    end
  end
end
