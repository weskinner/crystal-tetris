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
    property rotation
    property color

    def initialize(@rotation, @color)
    end
  end

  class TetrominoMovement
    property type
    property rotation
    property x
    property y

    def initialize(@type, @rotation, @x, @y)
    end
  end

  class Game
    def initialize(@graphics)
      @cb_timer = 0
      @playfield = Array(UInt32).new PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH, ColorBlock::EMPTY
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

    def update(action)
      tetro_s = [0x6C00_u16, 0x4620_u16, 0x06C0_u16, 0x8c40_u16]
      tetromino = Tetromino.new tetro_s, ColorBlock::GREEN
      request = TetrominoMovement.new tetromino, 0_u8, 4_u8, 3_u8
      coords = Array(UInt8).new(8, 0_u8)
      render_tetromino(request, coords)
    end

    def draw_playing_field
      @graphics.clear_background

      ((PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH)-1..0).each do |i|
        set_playfield(i % PLAYFIELD_WIDTH, i / PLAYFIELD_WIDTH, @playfield[i])
      end

      @graphics.set_render_changed
    end

    #  render tetromino movement request
    #  returns true if tetromino is rendered succesfully; false otherwise
    def render_tetromino(tetra_request, current_coords)

        #  simple 'queue' to store coords of blocks to render on playing field.
        #  Each tetromino has 4 blocks with total of 4 coordinates.
        # 
        #  To access a coord, if 0 <= i < 4, then
        #       x = i * 2, y = x + 1
        # 
        block_render_queue = Array(UInt8).new(8, 0_u8)

        return false unless can_render_tetromino(tetra_request, block_render_queue)

        #  clear old tetromino position
        (0..3).each do |i|
          x_coord = i * 2;
          y_coord = x_coord + 1;

          _x = current_coords[x_coord];
          _y = current_coords[y_coord];

          @graphics.draw_block(_x, _y, ColorBlock::EMPTY);
        end


        #  render new tetromino blocks
        (0..3).each do |i|
          x_coord = i * 2;
          y_coord = x_coord + 1;

          #  store and draw new tetromino position
          _x = block_render_queue[x_coord];
          _y = block_render_queue[y_coord];

          current_coords[x_coord] = _x;
          current_coords[y_coord] = _y;

          @graphics.draw_block(_x, _y, tetra_request.type.color);
        end

        return true;
    end

    private def get_playfield(x, y)
      return @playfield[(y * PLAYFIELD_WIDTH) + x]
    end

    private def set_playfield(x, y, color)
      @playfield[(y * PLAYFIELD_WIDTH) + x] = color
      @graphics.draw_block(x, y, color)
    end

    private def can_render_tetromino(tetra_request, block_render_queue)
      row = 0_u8
      col = 0_u8

      piece = tetra_request.type.rotation[tetra_request.rotation];
      x = tetra_request.x.to_u8
      y = tetra_request.y.to_u8;

      #  loop through tetramino data
      i = 0
      bit = 0x8000_u16
      while bit > 0 && i < 8
        # piece_string = ("%016s" % piece.to_s(2))
        # bit_string = ("%016s" % bit.to_s(2))
        # puts "piece: #{piece_string}"
        # puts "bit:   #{bit_string}"
        # puts row
        # puts col
        if (piece & bit) != 0
            _x = (x + col).to_u8
            _y = (y + row).to_u8

            #  bounds check
            if (_x < 0) || (_x >= PLAYFIELD_WIDTH) ||
              (_y < 0) || (_y >= PLAYFIELD_HEIGHT) ||
              get_playfield(_x, _y) != ColorBlock::EMPTY

              #  unable to render tetramino block
              return false
              break
            else
              # puts block_render_queue
              if block_render_queue != nil
                  block_render_queue[i * 2] = _x;
                  block_render_queue[i * 2 + 1] = _y;
              end

              i += 1
            end
        end

        #  cycle col between 0 to 3
        #  if col is 0 then increment row
        col = (col + 1) % 4
        row = row + 1 if col == 0

        bit = bit >> 1
      end

      return true
    end

    def spawn_tetromino
      #TODO
    end

    private def shuffle
      #TODO
    end
  end
end
