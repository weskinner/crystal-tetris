class Fps
  def initialize
    @last_ticks = @now_ticks = SDL2.ticks
    @frames_ticks = @last_ticks
    @frames = @fps_sum = @fps_samples = 0
  end

  def start
    @now_ticks = SDL2.ticks
    @dt = @now_ticks - @last_ticks
  end

  def stop
    @last_ticks = @now_ticks
    @frames += 1

    if @now_ticks - @frames_ticks > 1000
      fps = @frames.to_f / (@now_ticks - @frames_ticks) * 1000
      @fps_sum += fps
      @fps_samples += 1
      puts "FPS: #{fps}"
      puts "AVERAGE: #{@fps_sum / @fps_samples}"
      @frames_ticks = @now_ticks
      @frames = 0
    end
  end
end

