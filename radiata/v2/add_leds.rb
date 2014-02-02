vert_spacing = 0.7
horz_spacing = 0.3

num_leds = 9

all_leds = (1..9).to_a.product((1..9).to_a).reject{|pair| pair.first == pair.last}
hour_leds = [8].product((1..4).to_a) + [9].product((1..8).to_a)

y = -2
(all_leds - hour_leds).each_with_index do |pair, index|
  high = pair.first
  low = pair.last
  basex = (index % 10) * horz_spacing
  basey = y + vert_spacing * -(index / 10).to_i

  puts "add led1206 led_#{high}_#{low} R0 (#{basex} #{basey});"
  puts "net n_#{high} (#{basex} #{basey + 0.1}) (#{basex} #{basey + 0.2});"
  puts "net n_#{low} (#{basex} #{basey - 0.2}) (#{basex} #{basey - 0.3});"
end    

vert_spacing = 0.9
hour_leds.each_with_index do |pair, index|
  high = pair.first
  low = pair.last
  basex = 5 + (index % 10) * horz_spacing
  basey = y + vert_spacing * -(index / 10).to_i

  puts "add led1206 led_#{high}_#{low}_1 R0 (#{basex} #{basey});"
  puts "net n_#{high} (#{basex} #{basey + 0.1}) (#{basex} #{basey + 0.2});"
  puts "add led1206 led_#{high}_#{low}_2 R0 (#{basex} #{basey-0.3});"
  puts "net n_#{low} (#{basex} #{basey - 0.5}) (#{basex} #{basey - 0.6});"
end