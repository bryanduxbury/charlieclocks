puts "mark (40 40);"

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

# these resistors need to be flipped to make the routing work right!
puts "rotate R180 'RN1';"
puts "rotate R180 'RN2';"
puts "rotate R180 'RN5';"
puts "rotate R180 'RN6';"

names = %w(SCL MISO MOSI RESET VCC GND)

names.each_with_index do |name, idx|
  puts "move #{name} (P 8 #{-60*(idx+1) - 30});"
end

puts "mark (40 40);"
puts "mark (P 13 90);"
puts "move 'rs1' (P 2 0);"
puts "rotate =MR90 'rs1';"
puts "move 'rr1' (P 2 180);"
puts "rotate =MR270 'rr1';"

puts "mark (40 40);"
puts "mark (P 13 210);"
puts "move 'rs2' (P 2 300);"
puts "rotate =MR330 'rs2';"
puts "move 'rr2' (P 2 120);"
puts "rotate =MR150 'rr2';"

puts "mark (40 40);"
puts "mark (P 13 330);"
puts "move 'rs3' (P 2 -300);"
puts "rotate =MR-150 'rs3';"
puts "move 'rr3' (P 2 -120);"
puts "rotate =MR-330 'rr3';"

puts "mark (40 40);"
puts "move 'upsw' (P 13 30);"
puts "rotate =MR240 'upsw';"

puts "mark (40 40);"
puts "move 'downsw' (P 13 150);"
puts "rotate =MR120 'downsw';"

puts "mark (40 40);"
puts "mark (P 13 270);"
puts "move 'v+' (P 3 180);"
puts "rotate =MR0 'v+';"
puts "move 'gnd2' (P 3 0);"
puts "rotate =MR0 'gnd2';"