def arc(signal, rad, from, to, stepsize)
  if from > to
    to += 360
  end
  # to = to % 360
  # from = from % 360
  # if to < from
  delta = to - from
  # $stderr.puts delta
  numsteps = (delta / stepsize.to_f).ceil
  # $stderr.puts numsteps
  actualstep = delta / numsteps
  # $stderr.puts actualstep
  print "wire '#{signal}'"
  (0..numsteps).each do |stepnum|
    print " (P #{rad} #{(from + stepnum * actualstep) % 360})"
  end
  puts ";"
end

def polar(r, theta)
  "(P #{r} #{theta})"
end

def wire(signal, from, to)
  puts "wire '#{signal}' #{from} #{to};"
end

def radial(signal, r1, r2, theta)
  wire(signal, polar(r1, theta), polar(r2, theta))
end

def via(signal, pos)
  puts "via '#{signal}' #{pos};"
end

def bottom
  puts "change layer bottom;"
  yield
  puts "change layer top;"
end

puts "mark (40 40);"
puts "change drill 0.3048;"
puts "set wire_bend 2;"
puts "set snap_bended off;"
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
  startstep = [idx + 1, 4].min
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

radial('n_1', 12.5, inner_rad, resistor_angles[1-1]-6)
arc("n_1", inner_rad, resistor_angles[1-1] - 6, 87, 3)
wire('n_1', polar(inner_rad, 87), polar(rads[1-1], 87))
wire('n_1', polar(37.5, 87), polar(32.5, 87))
arc("n_1", 37.5, 321, 327, 3)
via("n_1", polar(37.5, 321))
bottom do
  radial("n_1", 37.5, 37.5 + 1.5, 321)
  arc("n_1", 37.5 + 1.5, 321, 48, 3)
  radial("n_1", 37.5 - 1.5, 37.5 + 1.5, 48)
  via("n_1", polar(37.5 - 1.5, 48))
end
radial("n_1", 37.5 - 1.5, 34.5, 48)


radial('n_2', 12.5, outer_rad, resistor_angles[2-1]-6)
arc("n_2", outer_rad, resistor_angles[2-1]-6, 81, 3)
via('n_2', polar(outer_rad, 81))
via('n_2', polar(rads[2-1], 81))
arc('n_2', 37.5, 39, 57, 3)
wire("n_2", polar(37.5, 39), polar(29, 39))
via("n_2", polar(29, 39))
via("n_2", polar(rads[2-1], 39))
arc('n_2', 34.25, 36, 39, 3)
arc('n_2', 37.5, 291, 297, 3)
via("n_2", polar(37.5, 291))
# via("n_2", polar(29, 291))
# arc("n_2", 29, 291, 294, 3)
bottom do
  radial("n_2", 29, rads[2-1], 39)
  radial("n_2", outer_rad, rads[2-1], 81)
end
via("n_2", polar(37.5, 54))
bottom do
  arc("n_2", 37.5, 54, 291, 3)
end


radial('n_3', 12.5, outer_rad, resistor_angles[3-1]+6)
arc("n_3", outer_rad, 279, resistor_angles[3-1]+6, 3)
via("n_3", polar(outer_rad, 279))
via("n_3", polar(rads[3-1], 279))
arc("n_3", 37.5-1.5, 351, 27, 3)
radial("n_3", 37.5-1.5, 29, 351)
radial("n_3", 37.5-1.5, 37.5, 27)
via("n_3", polar(29, 351))
via("n_3", polar(rads[3-1], 351))
arc("n_3", 34.25, 348, 351, 3)
radial("n_3", 37.5 - 1.5, 37.5, 267)
arc("n_3", 37.5 - 1.5, 267, 306, 3)
radial("n_3", 37.5 - 1.5, 34.25, 306)
bottom do
  radial("n_3", outer_rad, rads[3-1], 279)
  radial("n_3", 29, rads[3-1], 351)
end

radial('n_4', 12.5, inner_rad, resistor_angles[4-1]+6)
arc("n_4", inner_rad, 273, resistor_angles[4-1]+6, 3)
via("n_4", polar(inner_rad, 273))
via("n_4", polar(rads[4-1], 273))
radial("n_4", 37.5 - 1.5, 37.5, 237)
arc("n_4", 37.5 - 1.5, 237, 255, 3)
radial("n_4", 37.5 - 1.5, 29, 255)
via("n_4", polar(29, 255))
via("n_4", polar(rads[4-1], 255))
arc("n_4", 34.25, 255, 258, 3)
arc("n_4", 37.5, 351, 357, 3)
via("n_4", polar(37.5, 351))
bottom do
  radial("n_4", 37.5, 37.5 - 1.5, 351)
  arc("n_4", 37.5 - 1.5, 258, 351, 3)
end
via("n_4", polar(37.5 - 1.5, 258))
radial("n_4", 37.5 - 1.5, 34.5, 258)

bottom do
  radial("n_4", inner_rad, rads[4-1], 273)
  radial("n_4", 29, rads[4-1], 255)
end

radial('n_5', 12.5, inner_rad, resistor_angles[5-1]-6)
arc("n_5", inner_rad, resistor_angles[5-1]-6, 267, 3)
via("n_5", polar(inner_rad, 267))
via("n_5", polar(rads[5-1], 267))
radial("n_5", 37.5, 29, 207)
via("n_5", polar(29, 207))
via("n_5", polar(rads[5-1], 207))
arc("n_5", 34.25, 207, 210, 3)
bottom do
  radial("n_5", inner_rad, rads[5-1], 267)
  radial("n_5", 29, rads[5-1], 207)
end

radial('n_6', 12.5, outer_rad, resistor_angles[6-1]- 6)
arc('n_6', outer_rad, resistor_angles[6-1]-6, 261, 3)
via("n_6", polar(outer_rad, 261))
via("n_6", polar(rads[6-1], 261))
arc("n_6", 37.5, 159, 177, 3)
radial("n_6", 37.5, 29, 159)
via("n_6", polar(29, 159))
via("n_6", polar(rads[6-1], 159))
arc("n_6", 34.25, 159, 162, 3)
bottom do
  radial("n_6", outer_rad, rads[6-1], 261)
  radial("n_6", 29, rads[6-1], 159)
end

radial('n_7', 12.5, outer_rad, resistor_angles[7-1]+6)
arc("n_7", outer_rad, 96, resistor_angles[7-1]+6, 3)
wire('n_7', polar(outer_rad, 96), polar(rads[7-1], 96))
arc('n_7', 37.5, 129, 147, 3)
wire('n_7', polar(37.5, 129), polar(29, 129))
via("n_7", polar(29, 129))
via("n_7", polar(rads[7-1], 129))
bottom do
  radial("n_7", 29, rads[7-1], 129)
end

radial('n_8', 12.5, inner_rad, resistor_angles[8-1]+6)
arc("n_8", inner_rad, 93, resistor_angles[8-1]+6, 3)
puts "wire 'n_8' (P #{inner_rad} 93) (P #{rads[8-1]} 93);"
arc("n_8", 37.5 + 1.5, 3, 117, 3)
[3, 33, 63, 93, 117].each do |theta|
  wire('n_8', polar(37.5+1.5, theta), polar(37.5, theta))
end
wire("n_8", polar(37.5, 93), polar(34.25, 93))
via("n_8", polar(29, 93))
via("n_8", polar(rads[8-1], 93))
bottom do
  radial('n_8', rads[8-1], 29, 93)
end
radial('n_8', 29, 36.5, 93)


wire('n_9', polar(13.5, 90), polar(30.75, 90))
arc("n_9", 37.5 + 1.5, 123, 333, 3)
[123, 153, 183, 213, 243, 273, 303, 333].each do |theta|
  wire('n_9', polar(37.5+1.5, theta), polar(37.5, theta))
end
arc('n_9', 37.5 - 1.5, 111, 123, 3)
wire('n_9', polar(37.5-1.5, 111), polar(rads[9-1], 111))
wire('n_9', polar(37.5-1.5, 123), polar(37.5, 123))

# connections from low side of each led to the bus rings

led_num = -1
(2..7).each_with_index do |high_led, seg_idx|
  ((1..9).to_a - [high_led]).each_with_index do |low_led, idx|
    led_num += 1
    # next if high_led == 8 && low_led > 4

    startangle = 84 - 8*6 + led_num * -6

    if low_led == 9
      # puts "wire 'n_9' (P 30.75 #{startangle}) (P #{rads[9-1]} #{startangle});"
      radial("n_9", 30.75, rads[9-1], startangle)
      next
    end

    # puts "rats;"
    if high_led != 1
      via("n_#{low_led}", polar(29, startangle))
    end
    via("n_#{low_led}", polar(rads[low_led-1], startangle))

    radial("n_#{low_led}", 30.75, 29, startangle)
    bottom do
      radial("n_#{low_led}", 29, rads[low_led-1], startangle)
    end
  end
end

[5, 6, 7].each_with_index do |low_led, idx|
  startangle = 90 + 18 - idx * 6;
  via("n_#{low_led}", polar(29, startangle))
  via("n_#{low_led}", polar(rads[low_led-1], startangle))

  radial("n_#{low_led}", 30.75, 29, startangle)
  bottom do
    radial("n_#{low_led}", 29, rads[low_led-1], startangle)
  end
end

# bottom do
#   radial("n_8", 34.25, rads[8-1], 93)
# 
#   
# 
#   
# 
#   radial("n_4", 37.5, 29, 339)
# 
#   radial("n_3", 29, rads[3-1], 351)
# 
#   radial("n_2", 29, 37.5, 291)
#   radial("n_2", outer_rad, rads[2-1], 81)
# 
#   radial("n_1", 37.5-1.5, 29, 345)
# end

puts "rats;"