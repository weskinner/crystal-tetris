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

  class TetrominoMovement
    property type
    property rotation
    property x
    property y

    def initialize(@type, @rotation, @x, @y)
    end
    
    def initialize(other)
      @type = other.type
      @rotation = other.rotation
      @x = other.x
      @y = other.y
    end
  end
end
