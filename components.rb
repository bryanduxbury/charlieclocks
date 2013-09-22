main_ring_leds = ((1..7).to_a.product((1..9).to_a) + [8].product((5..9).to_a)).reject{|pair| pair.first == pair.last}.map{|pair| "led_#{pair.first}_#{pair.last}"}

led_names = []
(1..9).each do |high|
  ((1..9).to_a - [high]).each do |low|
    led_names << "led_#{high}_#{low}"
  end
end

# (0..59).each do |idx|
#   angle = 90 + (idx+1) * -6
#   puts "move #{led_names[idx]} (P 32.5 #{angle});"
#   puts "rotate =R#{angle+90} #{led_names[idx]};"
# end

main_ring_leds.each_with_index do |led_name, idx|
  angle = 90 + (idx+1) * -6
  puts "move #{led_name} (P 32.5 #{angle});"
  puts "rotate =R#{angle+90} #{led_name};"
end

dy = 37.5
angle = 0.0
(led_names-main_ring_leds).each_with_index do |led_name, idx|
  angle = 90 + (idx - 60) * -30
  puts "move #{led_name} (P 37.5 #{angle});"
  puts "rotate =R#{angle+180} #{led_name};"
end

range = 360.0
(1..9).to_a.reverse.each_with_index do |rn, idx|
  angle = range / 9 * (idx) + 90
  puts "move RN#{rn} (P 12 #{angle});"
  if rn==9
    puts "rotate =R90 RN9;"
  else
    puts "rotate =R#{angle+90} RN#{rn};"
  end

end

names = %w(SCL MISO MOSI RESET VCC GND)

names.each_with_index do |name, idx|
  puts "move #{name} (P 8 #{-60*(idx+1) - 30});"
end