def rotate(x,y,theta)
  [Math.cos(theta/180 * Math::PI) * (x) - Math.sin(theta/180 * Math::PI) * (y), Math.sin(theta/180 * Math::PI) * (x) + Math.cos(theta/180 * Math::PI) * (y)]
end

led_names = []
(1..9).each do |high|
  ((1..9).to_a - [high]).each do |low|
    led_names << "led_#{high}_#{low}"
  end
end

dy = 32.5
angle = 0.0
(0..59).each do |idx|
  xy = rotate(0, dy, angle)
  puts "move #{led_names[idx]} (#{40 + xy.first} #{40 + xy.last});"
  puts "rotate =R#{angle+180} #{led_names[idx]};"
  angle += 6
end

dy = 37.5
angle = 0.0
(60..71).each do |idx|
  xy = rotate(0, dy, angle)
  puts "move #{led_names[idx]} (#{40 + xy.first} #{40 + xy.last});"
  puts "rotate =R#{angle + 90} #{led_names[idx]};"
  angle += 30
end