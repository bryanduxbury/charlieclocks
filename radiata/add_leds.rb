vert_spacing = 1.0
horz_spacing = 1.0

num_leds = 9


(1..num_leds).each do |high|
  (((1..num_leds).to_a) - [high]).each_with_index do |low, index|
    puts "add ledchipled_1206 led_#{high}_#{low} R0 (#{low * horz_spacing} #{high * vert_spacing});"
    puts "net n_#{high} (#{low * horz_spacing} #{high * vert_spacing + 0.1}) (#{low * horz_spacing} #{high * vert_spacing + 0.2});"
    puts "net n_#{low} (#{low * horz_spacing} #{high * vert_spacing - 0.2}) (#{low * horz_spacing} #{high * vert_spacing - 0.3});"
  end
end

# (1..num_leds).each do |high|
#   (((1...(num_leds-1)).to_a)).each_with_index do |low, index|
#     puts "net n_#{high} (#{low * horz_spacing} #{high * vert_spacing + 0.1}) (#{(low - 1) * horz_spacing} #{high * vert_spacing + 0.1})"
#     puts "net n_#{low} (#{low * horz_spacing} #{high * vert_spacing - 0.2}) (#{low * horz_spacing} #{high * vert_spacing - 0.3})"
#   end
#   
#   # (((1..num_leds).to_a) - [high]).each_with_index do |low, index|
#   #   puts "net n_#{low} (#{high * }) ()"
#   # end
# end