def arc(signal, rad, from, to, stepsize)
  delta = (to % 360) - (from % 360)
  numsteps = (delta / stepsize.to_f).ceil
  actualstep = delta / numsteps
  print "wire '#{signal}'"
  (0..numsteps).each do |stepnum|
    print " (P #{rad} #{from + stepnum * actualstep})"
  end
  puts ";"
end

def polar(r, theta)
  "(P #{r} #{theta})"
end

def wire(signal, from, to)
  puts "wire '#{signal}' #{from} #{to};"
end

def via(signal, pos)
  puts "via '#{signal}' #{pos};"
end

puts "mark (40 40);"
puts "rip *;"

# contiguous sections of leds, between all the same "highs"

offset_angle = 90
(0..58).each_with_index do |led, idx|
  next if idx % 8 == 7
  angle = 84 + idx * -6
  puts "route 0.381 (P 34.25 #{angle}) (P 34.25 #{angle - 6});"
end

# bus rings: one for each charlie control pin

rads = []
(1..9).each_with_index do |bus, idx|
  rads << 30.75 - 3 - 1.25 * idx
end
rads = rads.reverse

(1..9).to_a.reverse.each_with_index do |bus, idx|
  print "wire 'n_#{bus}' 0.381 "
  # (0..120).each do |step|
  #   print "(P #{rads[bus-1]} #{step * 3})"
  # end
  startstep = idx + 1
  laststep = 120 - ((bus - 1) * 2 - 1)
  if bus == 1
    laststep = 120
  end
  (startstep..laststep).each do |step|
    print "(P #{rads[bus-1]} #{90 + (step - 1) * 3})"
  end
  if bus == 1
    print " (P 34.5 #{90 + (laststep - 1) * 3})"
    print " (P 34.5 #{90 + (laststep - 1) * 3 - 3})"
  else
    print " (P 30.75 #{90 + (laststep - 1) * 3})"
  end
  
  puts ";"
end

resistor_angles = []
(1..9).to_a.reverse.each_with_index do |resistor, idx|
  angle = 360.0 / 9 * (idx) + 90
  resistor_angles.unshift(angle)
end

inside_rads = []
(1..9).each_with_index do |resistor, idx|
  inside_rads << (30.75 - 3 - 9*1.25) - 1 * idx
end

# connections from control pin resistors to the bus rings


outer_rad = (30.75 - 3 - 9*1.25)
inner_rad = (30.75 - 3 - 10*1.25)

wire('n_1', polar(13.5, resistor_angles[1-1]), polar(inner_rad, resistor_angles[1-1]))
arc("n_1", inner_rad, resistor_angles[1-1], 87, 3)
wire('n_1', polar(inner_rad, 87), polar(rads[1-1], 87))
wire('n_1', polar(37.5, 87), polar(32.5, 87))

wire('n_2', polar(13.5, resistor_angles[2-1]), polar(outer_rad, resistor_angles[2-1]))
arc("n_2", outer_rad, resistor_angles[2-1], 81, 3)
via('n_2', polar(outer_rad, 81))
via('n_2', polar(rads[2-1], 81))
arc('n_2', 37.5, 39, 57, 3)
wire("n_2", polar(37.5, 39), polar(29, 39))
via("n_2", polar(29, 39))
via("n_2", polar(rads[2-1], 39))
arc('n_2', 34.25, 36, 39, 3)

wire('n_3', polar(13.5, resistor_angles[3-1]), polar(outer_rad, resistor_angles[3-1]))
arc("n_3", outer_rad, 279, resistor_angles[3-1], 3)
via("n_3", polar(outer_rad, 279))
via("n_3", polar(rads[3-1], 279))

wire('n_4', polar(13.5, resistor_angles[4-1]), polar(inner_rad, resistor_angles[4-1]))
arc("n_4", inner_rad, 273, resistor_angles[4-1], 3)
via("n_4", polar(inner_rad, 273))
via("n_4", polar(rads[4-1], 273))

wire('n_5', polar(13.5, resistor_angles[5-1]), polar(inner_rad, resistor_angles[5-1]))
arc("n_5", inner_rad, resistor_angles[5-1], 267, 3)
via("n_5", polar(inner_rad, 267))
via("n_5", polar(rads[5-1], 267))

wire('n_6', polar(13.5, resistor_angles[6-1]), polar(outer_rad, resistor_angles[6-1]))
arc('n_6', outer_rad, resistor_angles[6-1], 261, 3)
via("n_6", polar(outer_rad, 261))
via("n_6", polar(rads[6-1], 261))

wire('n_7', polar(13.5, resistor_angles[7-1]), polar(outer_rad, resistor_angles[7-1]))
arc("n_7", outer_rad, 96, resistor_angles[7-1], 3)
wire('n_7', polar(outer_rad, 96), polar(rads[7-1], 96))
arc('n_7', 37.5, 129, 147, 3)
wire('n_7', polar(37.5, 129), polar(29, 129))
via("n_7", polar(29, 129))
via("n_7", polar(rads[7-1], 129))

puts "wire 'n_8' (P 13.5 #{resistor_angles[8-1]}) (P #{inner_rad} #{resistor_angles[8-1]});"
arc("n_8", inner_rad, 93, resistor_angles[8-1], 3)
puts "wire 'n_8' (P #{inner_rad} 93) (P #{rads[8-1]} 93);"
arc("n_8", 37.5 + 1.5, 3, 117, 3)
[3, 33, 63, 93, 117].each do |theta|
  wire('n_8', polar(37.5+1.5, theta), polar(37.5, theta))
end
wire("n_8", polar(37.5, 93), polar(34.25, 93))
via("n_8", polar(34.25, 93))
via("n_8", polar(rads[8-1], 93))


wire('n_9', polar(13.5, 90), polar(30.75, 90))
arc("n_9", 37.5 + 1.5, 123, 333, 3)
[123, 153, 183, 213, 243, 273, 303, 333].each do |theta|
  wire('n_9', polar(37.5+1.5, theta), polar(37.5, theta))
end
arc('n_9', 37.5 - 1.5, 111, 123, 3)
wire('n_9', polar(37.5-1.5, 111), polar(rads[9-1], 111))
wire('n_9', polar(37.5-1.5, 123), polar(37.5, 123))


# (1..9).to_a.each_with_index do |bus, idx|
#   if bus == 8
#     puts "wire 'n_#{bus}' (P 13.5 #{resistor_angles[idx]}) (P 15.5 #{resistor_angles[idx]});"
#   else
#     puts "wire 'n_#{bus}' (P 13.5 #{resistor_angles[idx]}) (P 16 #{resistor_angles[idx]});"
#   end
#   
#   if bus > 1 && bus < 7
#     puts "via 'n_#{bus}' (P 16 #{resistor_angles[idx]});"
#     puts "via 'n_#{bus}' (P #{rads[bus-1]} #{resistor_angles[idx]});"
#   end
#   if bus == 1
#     puts "wire 'n_#{bus}' (P 16 #{resistor_angles[idx]}) (P #{rads[bus-1]} #{resistor_angles[idx]});"
#   end
#   if bus == 7
#     puts "wire 'n_7' (P #{rads[7-1]} 96) (P 16.5 96);"
#     (96..resistor_angles[idx]-1).each do |degree|
#       puts "wire 'n_7' (P 16.5 #{degree}) (P 16.5 #{degree+1});"
#     end
#     puts "wire 'n_7' (P 16.5 #{resistor_angles[idx]}) (P 12.5 #{resistor_angles[idx]});"
#   end
#   if bus == 8
#     puts "wire 'n_8' (P #{rads[8-1]} 93) (P 15.5 93);"
#     (93..resistor_angles[idx]-1).each do |degree|
#       puts "wire 'n_8' (P 15.5 #{degree}) (P 15.5 #{degree+1});"
#     end
#   end
#   if bus == 9
#     puts "wire 'n_9' (P 30.75 90) (P 16 90);"
#   end
#   # ((90 + idx * 2 * 3)..(resistor_angles[bus-1] + 6)).each_with_index do |deg, idx2|
#   #   next if idx2 % 2 == 1
#   #   print " (P #{inside_rads[bus-1]} #{deg})"
#   # end
#   # puts ";"
# end

# (1..9).to_a.reverse.each_with_index do |bus, idx|
#   print "wire 'n_#{bus}' (P #{rads[bus-1]} #{90 + idx * 2 * 3})"
#   ((90 + idx * 2 * 3)..(resistor_angles[bus-1] + 6)).each_with_index do |deg, idx2|
#     next if idx2 % 2 == 1
#     print " (P #{inside_rads[bus-1]} #{deg})"
#   end
#   puts ";"
# end
# 
# 

# connections from low side of each led to the bus rings

led_num = -1
(2..7).each_with_index do |high_led, seg_idx|
  ((1..9).to_a - [high_led]).each_with_index do |low_led, idx|
    led_num += 1
    # next if high_led == 8 && low_led > 4

    startangle = 84 - 8*6 + led_num * -6
    
    if low_led == 9
      puts "wire 'n_9' (P 30.75 #{startangle}) (P #{rads[9-1]} #{startangle});"
      next
    end
    
    # puts "rats;"
    if high_led != 1
      puts "via 'n_#{low_led}' (P 29 #{startangle});"
    end
    puts "via 'n_#{low_led}' (P #{rads[low_led-1]} #{startangle});"
    
    puts "wire 'n_#{low_led}' (P 30.75 #{startangle}) (P 29 #{startangle});"
    # puts "CHANGE LAYER TOP;"
    #     puts "wire 'n_#{low_led}' 0.381 (P 30.75 #{startangle}) (P 28.75 #{startangle});"
    #     puts "CHANGE LAYER BOTTOM;"
    #     puts "wire 'n_#{low_led}' 0.381 (P 28.75 #{startangle}) (P #{rads[low_led-1]} #{startangle});"
    #     puts "CHANGE LAYER TOP;"

  end
end

[5, 6, 7].each_with_index do |low_led, idx|
  startangle = 90 + 18 - idx * 6;
  puts "via 'n_#{low_led}' (P 29 #{startangle});"
  puts "via 'n_#{low_led}' (P #{rads[low_led-1]} #{startangle});"
  
  puts "wire 'n_#{low_led}' (P 30.75 #{startangle}) (P 29 #{startangle});"
end

# wires and vias for all of the "hour" leds

# ([8].product((1..4).to_a) + ([9].product((1..8).to_a))).each_with_index do |led_pair, idx|
#   base_angle = -30 * idx + 90
#   # puts "via 'n_#{led_pair.first}' (P 37.5 #{base_angle + 9});"
#   # puts "via 'n_#{led_pair.first}' (P #{rads[led_pair.first-1]} #{base_angle + 9});"
#   # puts "wire 'n_#{led_pair.first}' (P 37.5 #{base_angle + 3}) (P 37.5 #{base_angle + 9});"
#   # puts "via 'n_#{led_pair.last}' (P 37.5 #{base_angle - 9});"
#   # puts "via 'n_#{led_pair.last}' (P #{rads[led_pair.last-1]} #{base_angle - 9});"
#   # puts "wire 'n_#{led_pair.last}' (P 37.5 #{base_angle - 3}) (P 37.5 #{base_angle - 9});"
#   
#   # puts "change layer top;"
#   # puts "wire 'n_#{led_pair.first}' 0.381 (P 37.6 #{base_angle - 3}) (P 35.6 #{base_angle - 3});"
#   # puts "via 'n_#{led_pair.first}' (P 35.6 #{base_angle - 3});"
#   # puts "via 'n_#{led_pair.first}' (P #{rads[led_pair.first-1]} #{base_angle - 3});"
#   # puts "change layer bottom;"
#   # puts "wire 'n_#{led_pair.first}' 0.381 (P 35.6 #{base_angle - 3}) (P #{rads[led_pair.first-1]} #{base_angle - 3});"
#   # 
#   # puts "change layer top;"
#   # puts "wire 'n_#{led_pair.last}' 0.381 (P 37.6 #{base_angle + 3}) (P 35.6 #{base_angle + 3});"
#   # puts "via 'n_#{led_pair.last}' (P 35.6 #{base_angle + 3});"
#   # puts "via 'n_#{led_pair.last}' (P #{rads[led_pair.last-1]} #{base_angle + 3});"
#   # puts "change layer bottom;"
#   # puts "wire 'n_#{led_pair.last}' 0.381 (P 35.6 #{base_angle + 3}) (P #{rads[led_pair.last-1]} #{base_angle + 3});"
#   
# end
# # 
# # range = 360.0
# # (1..9).each_with_index do |rn, idx|
# #   r = 12
# #   angle = idx * 6 + 90
# #   # angle = range / 9 * (idx + 3) + 90
# #   # # angle = -7 * 6 * (idx) + 90 + (7*6) + 6
# #   # r = 10.5 + 1.5
# #   # # puts "via 'n_#{rn}' (P #{rads[rn-1]} #{(angle / 6).to_i * 6 + 3});"
# #   # puts "via 'n_#{rn}' (P #{r} #{angle});"
# # end
# # 
# # # rads2 = []
# # # (1..9).each_with_index do |bus, idx|
# # #   # rads2 << 11.5 + idx * 0.25
# # #   rads2 << 12.4
# # # end
# # # 
# # # (1..9).each_with_index do |led_num, idx|
# # #   angle = 90 - 1.5 * 6 + -2 * idx * 6
# # #   puts "via 'n_#{led_num}' (P #{rads[led_num-1]} #{angle});"
# # #   puts "via 'n_#{led_num}' (P #{rads2[led_num-1]} #{angle});"
# # # end

puts "rats;"