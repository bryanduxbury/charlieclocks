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
  puts "move RN#{rn} (P 14.5 #{angle});"
  puts "move CN#{rn} (P 9 #{angle});"
  if rn==9
    puts "rotate =R90 RN9;"
  else
    puts "rotate =R#{angle} RN#{rn};"
  end
  puts "rotate =R#{angle} CN#{rn};"
end

# these resistors need to be flipped to make the routing work right!
# puts "rotate R180 'RN1';"
# puts "rotate R180 'RN2';"
# puts "rotate R180 'RN5';"
# puts "rotate R180 'RN6';"

(1..9).to_a.reverse.each_with_index do |rn, idx|
  angle = range / 9 * (idx) + 90

  # puts "mark (40 40); mark (P 14 #{angle});"
  puts "move NPN#{rn} (P 14.75 #{angle-12});"
  puts "rotate =R#{angle-90+180 - 12} NPN#{rn};"
  puts "move PNP#{rn} (P 14.75 #{angle + 12});"
  puts "rotate =R#{angle-90+180 + 12} PNP#{rn};"


  # puts "mark (40 40); mark (P 14 #{angle});"
  # puts "move NPN#{rn} (P 3.25 #{angle-120});"
  # puts "rotate =R#{angle-90+180} NPN#{rn};"
  # puts "move PNP#{rn} (P 3.25 #{angle + 120});"
  # puts "rotate =R#{angle-90+180} PNP#{rn};"
end

puts "mark (40 40);"

names = %w(RESET GND VCC MOSI MISO SCK)

names.each_with_index do |name, idx|
  puts "move #{name} (P 8 #{90 + (idx * 60)});"
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

# crystal loading caps and vcc decoupling cap
puts "mark (40 40);"
puts "move 'c3' (P 4 90);"
puts "move 'c1' (P 4 210);"
puts "rotate =MR60 'c1';"
puts "move 'c2' (P 4 330);"
puts "rotate =MR300 'c2';"

# signature!
puts "change layer bottom;"
puts "change ratio 20;"

def text_arc(str, rad, start_angle, step)
  str.split("").each_with_index do |char, idx|
    next if char == " "
    angle = start_angle + idx * step
    # textangle = start_angle - idx * incr
    textangle = 90 - angle
    puts "text '#{char}' MR#{textangle} (P #{rad} #{angle});"
  end
end

text_arc("radiata v1 11-29-2013", 28, 42, 2)
text_arc("bryan duxbury", 25, 50, 2)
