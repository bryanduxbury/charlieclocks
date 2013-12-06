steps = 60

offset_angle = 90 + 16 * 6
rad = 26 - 1.5

print "wire 'n_2' 0.381 "

(0...steps).each do |angle|
  print "(P #{rad} #{offset_angle + angle * 6}) "
end
puts