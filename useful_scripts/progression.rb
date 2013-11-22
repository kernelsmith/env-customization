# Time.local(2011,"may",21,18,0,0
# usage examples
# p = Progression.new(0, 5000);p.show {|curr| sleep 1;curr + 500}
# p = Progression.new(0, 5000);p.fill_upward = true;p.show {|curr| sleep 1;curr + 500}
# p = Progression.new(0, 60);p.show {|curr| sleep 2;curr + 2}
# p = Progression.new(Time.now, Time.now + 10);p.show
# p = Progression.new(Time.now, Time.now + 10);p.show {sleep 1; Time.now}
# p = Progression.new(Time.now, Time.now + 10);p.fill_upward = true;p.show
# above example is broken

class Progression
  attr_accessor :start_val, :stop_val, :title, :color, :end_val, :fill_upward
  attr_reader :progress, :last_length, :orig_delta, :remaining, :current_value

  # TODO:  no color opt, hide method, pause?, stop?
  #        use block to calculate remaining or when loop should stop
  MAX_BAR_LENGTH = 100

  def initialize(color = true, title = "Progress", start_val, end_val)
  	@start_val = start_val
    @current_value = @start_val
    @end_val = end_val
  	@title = title
    @color = color
    @orig_delta = end_val - start_val
    @fill_upward = false
    # negate remaining if
    #@remaining = @remaining < 0 ? @remaining * -1 : @remaining
    @last_length = 8
  end

  def show(&block)
    puts "DEBUG: start_val:#{start_val}, current_value:#{current_value}, " +
          "end_val:#{end_val}, orig_delta:#{orig_delta}, title:#{title}, " +
          "color:#{color}, fill_upward:#{fill_upward}"
    print(title + " ")
    block ||= Proc.new {sleep 1;Time.now}
    update(block) until remaining <= 0
    # render an empty an empty progress bar
    @current_value = end_val
    render_basics
    render_progress(0)
    puts
  end

  # def decrement(amount)
  #   increment(amount * -1)
  # end

  # def increment(amount)
  #   remaining = remaining + amount
  # end

  def update(block)
    render_basics
    render_progress(remaining_percentage)
    @current_value = block.call(current_value)
  end

  private

  def render_basics
    progressbar_length = 106 + last_length
    move_cursor = "\e[#{progressbar_length}D"
    print(move_cursor + (" " * progressbar_length) + move_cursor)
    STDOUT.flush
    print("\e[33m#{title} \e[0m")
  end

  def render_progress(percent)
    print("\e[33m[\e[0m") # yellow [
    fill_amount = percent.to_i
    space_amount = MAX_BAR_LENGTH - percent.to_i
    if fill_upward
      # then exchange the values
      fill_amount, space_amount = space_amount, fill_amount
    end
    
    print("\e[31m=\e[0m" * fill_amount) # red =
    if percent < 97
      print("|#{percent.to_s}%")
      space_amount -= 4
    end
    print(" " * space_amount) # spaces 
    print("\e[33m]\e[0m") # yellow ]
    #print(" cv:#{current_value}, rem:#{remaining}")
    # print("\e[31m=\e[0m" * [[percent.to_i, 46].min, 0].max )# red =
    # print(" " * [46 - [percent.to_i, 46].min, 46].min)
    # print("\e[33m#{remaining.to_s}\e[0m") # yellow
    # print("\e[31m=\e[0m" * [percent.to_i - 54, 0].max) # red =
    # print(" " * [46 - (percent.to_i - 54), 46].min)
    # print("\e[33m]\e[0m") # yellow ]
 
    # new_length = remaining.to_s.length
    # if last_length > new_length
    #   print " " * (last_length - new_length)
    #   print "\e[#{last_length - new_length}D"
    # end
    # @last_length = new_length
    STDOUT.flush
  end

  def remaining_percentage
    # since orig_delta is an int if start & end are ints, remaining truncates
    remaining * 100 / orig_delta
  end

  def remaining
    end_val - current_value
  end
end