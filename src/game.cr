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

  class Game
    def initialize(@graphics)
      @cb_timer = 0
      @playfield = Array(UInt32).new PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH, ColorBlock::EMPTY
      @tetromino_queue_size = 7
      @tetromino_queue = [] of Tetromino
      @tetromino_action = :none
      @current_tetromino_coords = Array(UInt8).new(8, 0_u8)
      @ghost_tetromino_coords = Array(UInt8).new(8, 0_u8)
      @current_tetromino = TetrominoMovement.new Piece::TETRA_O, 0, 3, 0
      @lock_delay_count = 0
      @lock_delay_threshold = 2
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

    def auto_drop_timer(interval)
      # SDL_Event event;
      event = LibSDL2::Event.new
      # SDL_UserEvent userevent;
      userevent = LibSDL2::UserEvent.new

      userevent.type = LibSDL2::USEREVENT;
      userevent.code = 0;
      userevent.data1 = Pointer(Void).null;
      userevent.data2 = Pointer(Void).null;

      event.type = LibSDL2::USEREVENT;
      event.user = userevent;

      # SDL_PushEvent(&event);
      LibSDL2.push_event(pointerof(event))
      interval
    end

    def update(@tetromino_action)
      if @cb_timer == 0
        @cb_timer = LibSDL2.add_timer(100_u32, ->(interval, param) { return (param as Game).auto_drop_timer(interval) }, self as Void*)
      end

      # // draw the scoreboard as needed
      # int i = 4;
      # bool on_score_area = false;
      # while(i --> 0) {
      #     uint8_t x_coord = i * 2;
      #     uint8_t y_coord = x_coord + 1;

      #     // uint8_t _x = CURRENT_TETROMINO_COORDS[x_coord];
      #     uint8_t _y = CURRENT_TETROMINO_COORDS[y_coord];

      #     // if a tetromino is within the top 3 rows of the playing field, redraw
      #     // that area of the playing field.
      #     // the third row is considered when the tetromino leaves the score area,
      #     // it will clear the previous position.
      #     if(_y <= 2) {
      #         on_score_area = true;
      #         break;
      #     }
      # }

      # if(on_score_area) {

      #     // re-draw playfield area where score is located in
      #     int n = PLAYFIELD_WIDTH * 2 - 1;
      #     while(n --> 0) {
      #         int x = n % PLAYFIELD_WIDTH;
      #         int y = n / PLAYFIELD_WIDTH;

      #         set_playfield(x, y, get_playfield(x, y));
      #     }

      #     draw_playing_field();

      #     // re-draw tetromino
      #     render_current_tetromino(CURRENT_TETROMINO);

      #     render_score();
      # }



      # Tetromino_Movement request = CURRENT_TETROMINO;
      request = TetrominoMovement.new @current_tetromino

      # // action from keyboard
      # switch(TETROMINO_ACTION) {
      case @tetromino_action
      #     case NONE:
      #         // do nothing - don't bother redrawing
      #     break;
      when :none

      #     case ROTATE:
      #         request.rotation = (request.rotation + 1) % 4;
      #         render_current_tetromino(request);
      #     break;
      when :rotate
        request.rotation = (request.rotation + 1) % 4
        render_current_tetromino(request)

      #     case LEFT:
      #         request.x -= 1;
      #         render_current_tetromino(request);
      #     break;
      when :left
        request.x -= 1
        render_current_tetromino(request)

      #     case RIGHT:
      #         request.x += 1;
      #         render_current_tetromino(request);

      #     break;
      when :right
        request.x += 1
        render_current_tetromino(request)

      #     case DROP:

      #         request.y += 1;
      #         while(render_current_tetromino(request))
      #             request.y += 1;

      #         lockTetromino();

      #     break;
      when :drop
        request.y += 1
        (request.y += 1) while render_current_tetromino(request)
        lock_tetromino

      #     case DOWN:
      #         request.y += 1;
      #         if(!render_current_tetromino(request)) {
      #             lock_delay_count++;
      #         } else {
      #             lock_delay_count = 0;
      #         }
      #     break;
      when :down
        request.y += 1
        unless render_current_tetromino(request)
          @lock_delay_count += 1
        else
          @lock_delay_count = 0
        end

      #     case RESTART:
      #         initTetris();
      #     break;
      when :restart
        setup

      #     case AUTO_DROP:

      #         request.y += 1;
      #         if (!render_current_tetromino(request)) {
      #             lock_delay_count++;
      #         } else {
      #             lock_delay_count = 0;
      #         }

      #         if (lock_delay_count >= lock_delay_threshold) {
      #             lockTetromino();
      #         }

      #     break;
      when :auto_drop
        request.y += 1
        unless render_current_tetromino(request)
          @lock_delay_count += 1
        else
          @lock_delay_count = 0
        end

        lock_tetromino if @lock_delay_count >= @lock_delay_threshold
      end

      @tetromino_action = :none
    end

    def lock_tetromino
      @lock_delay_count = 0

      (0..3).each do |i|
        x_coord = i * 2
        y_coord = x_coord + 1

        _x = @current_tetromino_coords[x_coord]
        _y = @current_tetromino_coords[y_coord]

        @current_tetromino_coords[x_coord] = 0_u8
        @current_tetromino_coords[y_coord] = 0_u8
        @ghost_tetromino_coords[x_coord] = 0_u8
        @ghost_tetromino_coords[y_coord] = 0_u8
 
        set_playfield(_x, _y, @current_tetromino.type.color)
      end

      row_to_copy_to = -1;
      completed_lines = 0;
      (PLAYFIELD_HEIGHT-1).downto(0) do |row|
        complete_line = true;
        # check if line is complete
        (0...PLAYFIELD_WIDTH).each do |col|
          if get_playfield(col, row) == ColorBlock::EMPTY
            complete_line = false
            break
          end
        end

        #// clear line
        #if(complete_line) {

        #    completed_lines++;

        #    if(row_to_copy_to < row) {
        #        row_to_copy_to = row;
        #    }

        #    for(col = 0; col < PLAYFIELD_WIDTH; col++) {
        #        set_playfield(col, row, EMPTY);
        #    }
        #} else if(row_to_copy_to > row) {

        #    for(col = 0; col < PLAYFIELD_WIDTH; col++) {
        #        set_playfield(col, row_to_copy_to, get_playfield(col, row));
        #    }

        #    row_to_copy_to--;
        #}
        if complete_line
          completed_lines += 1
          row_to_copy_to = row if row_to_copy_to < row
          (0...PLAYFIELD_WIDTH).each do |col|
            set_playfield(col, row, ColorBlock::EMPTY)
          end
        elsif row_to_copy_to > row
          (0...PLAYFIELD_WIDTH).each do |col|
            set_playfield(col, row_to_copy_to, get_playfield(col, row))
          end
          row_to_copy_to -= 1
        end

      end

      # // update score

      # if(completed_lines > 0) {
      #     // tetris
      #     score += completed_lines/4 * 800;
      #     completed_lines = completed_lines % 4;

      #     // triple
      #     score += completed_lines/3 * 500;
      #     completed_lines = completed_lines % 3;

      #     // double
      #     score += completed_lines/2 * 300;
      #     completed_lines = completed_lines % 2;

      #     // single
      #     score += completed_lines * 100;
      # }


      spawn_tetromino
    end

    def draw_playing_field
      @graphics.clear_background

      ((PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH)-1..0).each do |i|
        set_playfield(i % PLAYFIELD_WIDTH, i / PLAYFIELD_WIDTH, @playfield[i])
      end

      @graphics.set_render_changed
    end

    def render_current_tetromino(tetra_request)
      ghost = Tetromino.new tetra_request.type

      #   change alpha to ~50%
      ghost.color = ghost.color & 0x00FFFFFF;
      ghost.color = ghost.color | 0x66000000;

      ghost_request = TetrominoMovement.new tetra_request
      ghost_request.type = ghost

      #   render ghost tetromino
      # while(render_tetromino(ghost_request, GHOST_TETROMINO_COORDS))
      #     ghost_request.y += 1;
      while render_tetromino(ghost_request, @ghost_tetromino_coords)
        ghost_request.y += 1
      end

      #   change alpha to 90%
      tetra_request.type.color = tetra_request.type.color & 0x00FFFFFF;
      tetra_request.type.color = tetra_request.type.color | 0xE5000000;

      # if(render_tetromino(tetra_request, CURRENT_TETROMINO_COORDS)) {
      #     CURRENT_TETROMINO = tetra_request;

      #     return true;
      # }
      if render_tetromino(tetra_request, @current_tetromino_coords)
        @current_tetromino = tetra_request
        return true
      end

      return false
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
        x_coord = i * 2
        y_coord = x_coord + 1

        _x = current_coords[x_coord]
        _y = current_coords[y_coord]

        @graphics.draw_block(_x, _y, ColorBlock::EMPTY)
      end


      #  render new tetromino blocks
      (0..3).each do |i|
        x_coord = i * 2
        y_coord = x_coord + 1

        #  store and draw new tetromino position
        _x = block_render_queue[x_coord]
        _y = block_render_queue[y_coord]

        current_coords[x_coord] = _x
        current_coords[y_coord] = _y

        @graphics.draw_block(_x, _y, tetra_request.type.color)
      end

      return true
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
      # current_queue_index++;
      # if(current_queue_index >= tetromino_queue_size) {
      #     current_queue_index = 0;

      #       apply shuffle algorithm
      #     shuffle(tetromino_queue, tetromino_queue_size, sizeof(uint8_t));
      # }

      # Tetromino type;

      # switch(tetromino_queue[current_queue_index]) {
      #     case 1:
      #         type = TETRA_I;
      #     break;
      #     case 2:
      #         type = TETRA_J;
      #     break;
      #     case 3:
      #         type = TETRA_L;
      #     break;
      #     case 4:
      #         type = TETRA_O;
      #     break;
      #     case 5:
      #         type = TETRA_S;
      #     break;
      #     case 6:
      #         type = TETRA_T;
      #     break;
      #     case 7:
      #         type = TETRA_Z;
      #     break;
      # }

      # Tetromino_Movement tetra_request = {
      #     type,
      #     0,
      #     3, 0
      # };
      tetra_request = TetrominoMovement.new Piece::TETRA_O, 0, 3, 0

      # if(!render_current_tetromino(tetra_request)) {

      #       Reset the game
      #     initTetris();
      # }
      setup unless render_current_tetromino(tetra_request)
    end

    private def shuffle
      #TODO
    end
  end
end
