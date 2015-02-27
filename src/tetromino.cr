module Tetris
  module ColorBlock
    EMPTY = 0xFF4f4c42_u32
    TEAL = 0xFFFFDB7F_u32
    BLUE = 0xFFD97400_u32
    ORANGE = 0xFF1B85FF_u32
    YELLOW = 0xFF00DCFF_u32
    GREEN = 0xFF40CC2E_u32
    PURPLE = 0xFF4B1485_u32
    RED = 0xFF4B59F2_u32
  end

  module Piece
    TETRA_I = Tetromino.new [0x0F00, 0x2222, 0x00F0, 0x4444], ColorBlock::TEAL
    TETRA_J = Tetromino.new [0x8E00, 0x6440, 0x0E20, 0x44C0], ColorBlock::BLUE
    TETRA_L = Tetromino.new [0x2E00, 0x4460, 0x0E80, 0xC440], ColorBlock::ORANGE
    TETRA_O = Tetromino.new [0x6600, 0x6600, 0x6600, 0x6600], ColorBlock::YELLOW
    TETRA_S = Tetromino.new [0x6C00, 0x4620, 0x06C0, 0x8c40], ColorBlock::GREEN
    TETRA_T = Tetromino.new [0x4E00, 0x4640, 0x0E40, 0x4C40], ColorBlock::PURPLE
    TETRA_Z = Tetromino.new [0xC600, 0x2640, 0x0C60, 0x4C80], ColorBlock::RED
  end

  class Tetromino
    property rotation
    property color

    def initialize(@rotation, @color)
    end

    def initialize(other)
      @rotation = other.rotation
      @color = other.color
    end
  end

  class TetrominoRequest
    property x, y, rotation, color

    def initialize(@x = 0, @y = 0, @rotation = 0, @color = 0x00000000)
    end
  end

  # Interface
  # -set type
  # -get coords
  # -update location / rotation from request
  # -reset to top of screen
  class TetrominoMovement
    property type
    property rotation
    property x
    property y

    def initialize(@type, @rotation, @x, @y, @current_coords = Array(UInt8).new(8, 0_u8))
    end
    
    def initialize(other)
      @type = other.type
      @rotation = other.rotation
      @x = other.x
      @y = other.y
      @current_coords = Array(UInt8).new(8, 0_u8)
      (0..7).each {|i| @current_coords[i] = other.current_coords[i]}
    end

    protected def current_coords
      @current_coords
    end

    def coords
      (0..3).each do |i|
        x_coord = i * 2
        y_coord = x_coord + 1

        _x = @current_coords[x_coord]
        _y = @current_coords[y_coord]

        yield _x, _y
      end
    end

    def update(tetra_request)
      @rotation = (@rotation + tetra_request.rotation) % 4
      @x += tetra_request.x
      @y += tetra_request.y

      block_render_queue = Array(UInt8).new(8, 0_u8)

      row = 0_u8
      col = 0_u8

      piece = type.rotation[@rotation];
      x = @x
      y = @y

      #  loop through tetramino data
      i = 0
      bit = 0x8000_u16
      while bit > 0 && i < 8
        if (piece & bit) != 0
            _x = (x + col).to_u8
            _y = (y + row).to_u8

            # puts block_render_queue
            if block_render_queue != nil
                block_render_queue[i * 2] = _x;
                block_render_queue[i * 2 + 1] = _y;
            end

            i += 1
        end

        #  cycle col between 0 to 3
        #  if col is 0 then increment row
        col = (col + 1) % 4
        row = row + 1 if col == 0

        bit = bit >> 1
      end

      (0..3).each do |j|
        x_coord = j * 2
        y_coord = x_coord + 1

        #  store and draw new tetromino position
        _x = block_render_queue[x_coord]
        _y = block_render_queue[y_coord]

        @current_coords[x_coord] = _x
        @current_coords[y_coord] = _y
      end
    end

    def reset(type = Piece::TETRA_I)
      @type = type
      @x = 3
      @y = 0
      @rotation = 0
      @current_coords = Array(UInt8).new(8, 0_u8)
    end
  end
end
