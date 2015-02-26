require "./tetromino.cr"

module Tetris
  class Game
    def initialize(@graphics)
      @cb_timer = 0
      @playfield = Array(UInt32).new PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH, ColorBlock::EMPTY
      @tetromino_action = :none
      @ghost_tetromino_coords = Array(UInt8).new(8, 0_u8)
      @current_tetromino = TetrominoMovement.new Piece::TETRA_O, 0, 3, 0
      @ghost_movement = TetrominoMovement.new @current_tetromino
      @lock_delay_count = 0
      @lock_delay_threshold = 2
      @score = 0
    end

    def setup
      @score = 0

      # set up SDL timer
      LibSDL2.remove_timer(@cb_timer) unless @cb_timer == 0
      @cb_timer = 0

      @tetromino_action = :none;

      empty_playfield
      draw_playing_field
      spawn_tetromino
    end

    def spawn_tetromino
      type = Piece::TETRA_O
      case (1..7).to_a.sample
      when 1
        type = Piece::TETRA_I
      when 2
        type = Piece::TETRA_J
      when 3
        type = Piece::TETRA_L
      when 4
        type = Piece::TETRA_O
      when 5
        type = Piece::TETRA_S
      when 6
        type = Piece::TETRA_T
      when 7
        type = Piece::TETRA_Z
      end

      @current_tetromino.reset(type)
      setup unless render_current_tetromino
    end

    def update(@tetromino_action)
      if @cb_timer == 0
        @cb_timer = LibSDL2.add_timer(1000_u32, ->(interval, param) { return (param as Game).auto_drop_timer(interval) }, self as Void*)
      end

      if on_score_area
        redraw_playfield_score_area
        draw_playing_field
        render_current_tetromino
        render_score
      end

      handle_input
    end

    def handle_input
      request = TetrominoRequest.new

      # action from keyboard
      case @tetromino_action
      when :none
      when :rotate
        request.rotation = (request.rotation + 1) % 4
        render_current_tetromino(request)
      when :left
        request.x -= 1
        render_current_tetromino(request)
      when :right
        request.x += 1
        render_current_tetromino(request)
      when :drop
        request.y += 1
        while render_current_tetromino(request)
        end
        lock_tetromino
      when :down
        request.y += 1
        unless render_current_tetromino(request)
          @lock_delay_count += 1
        else
          @lock_delay_count = 0
        end
      when :restart
        setup
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

    def on_score_area
      on_score_area = false
      @current_tetromino.coords do |x,y|
        if y <= 2
          on_score_area = true
          break
        end
      end

      return on_score_area
    end

    def lock_tetromino
      @lock_delay_count = 0

      @current_tetromino.coords do |x,y|
        set_playfield(x, y, @current_tetromino.type.color)
      end
      @current_tetromino.reset
      @ghost_tetromino_coords = Array(UInt8).new(8, 0_u8)

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

        # clear line
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

      # update score
      if completed_lines > 0
        # tetris
        @score += completed_lines/4 * 800;
        completed_lines = completed_lines % 4;

        # triple
        @score += completed_lines/3 * 500;
        completed_lines = completed_lines % 3;

        # double
        @score += completed_lines/2 * 300;
        completed_lines = completed_lines % 2;

        # single
        @score += completed_lines * 100;
      end


      spawn_tetromino
    end

    def render_score
      @graphics.render_text @score.to_s
    end

    def render_current_tetromino(tetra_request = TetrominoRequest.new)
      #clear old ghost
      @ghost_movement.coords do |x,y|
        @graphics.draw_block(x, y, ColorBlock::EMPTY)
      end

      ghost = Tetromino.new @current_tetromino.type

      # change alpha to ~50%
      ghost.color = ghost.color & 0x00FFFFFF;
      ghost.color = ghost.color | 0x66000000;

      @ghost_movement = TetrominoMovement.new @current_tetromino
      @ghost_movement.type = ghost
      @ghost_movement.update tetra_request

      ghost_request = TetrominoRequest.new 0, 1, 0

      # render ghost tetromino
      while render_tetromino(@ghost_movement, ghost_request)
        @ghost_movement.update ghost_request
      end

      # change alpha to 90%
      tetra_request.color = @current_tetromino.type.color & 0x00FFFFFF;
      tetra_request.color = tetra_request.color | 0xE5000000;

      if render_tetromino(@current_tetromino, tetra_request)
        @current_tetromino.update tetra_request
        return true
      end

      return false
    end

    #  render tetromino movement request
    #  returns true if tetromino is rendered succesfully; false otherwise
    def render_tetromino(tetromino, request)
      (future = TetrominoMovement.new(tetromino)).update(request)
      return false unless can_render_tetromino(future)

      #  clear old tetromino position
      tetromino.coords do |x,y|
        @graphics.draw_block(x, y, ColorBlock::EMPTY)
      end

      #  render new tetromino blocks
      future.coords do |x,y|
        @graphics.draw_block(x, y, tetromino.type.color)
      end

      return true
    end

    private def can_render_tetromino(tetromino)
      tetromino.coords do |_x,_y|
        if (_x < 0) || (_x >= PLAYFIELD_WIDTH) ||
          (_y < 0) || (_y >= PLAYFIELD_HEIGHT) ||
          get_playfield(_x, _y) != ColorBlock::EMPTY

          #  unable to render tetramino block
          return false
        end
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

    def draw_playing_field
      @graphics.clear_background

      ((PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH)-1).downto(0) do |i|
        set_playfield(i % PLAYFIELD_WIDTH, i / PLAYFIELD_WIDTH, @playfield[i])
      end

      @graphics.set_render_changed
    end

    def empty_playfield
      ((PLAYFIELD_HEIGHT * PLAYFIELD_WIDTH)-1).downto(0) do |i|
        @playfield[i] = ColorBlock::EMPTY
      end
    end

    def redraw_playfield_score_area
      (0..PLAYFIELD_WIDTH * 2 - 1).each do |n|
        x = n % PLAYFIELD_WIDTH;
        y = n / PLAYFIELD_WIDTH;

        set_playfield(x, y, get_playfield(x, y));
      end
    end

    def auto_drop_timer(interval)
      event = LibSDL2::Event.new
      userevent = LibSDL2::UserEvent.new

      userevent.type = EventType::USEREVENT;
      userevent.code = 0;
      userevent.data1 = Pointer(Void).null;
      userevent.data2 = Pointer(Void).null;

      event.type = EventType::USEREVENT;
      event.user = userevent;

      LibSDL2.push_event(pointerof(event))
      interval
    end
  end
end
