range = 360.0
(1..9).to_a.reverse.each_with_index do |rn, idx|
  angle = range / 9 * (idx) + 90
  # xy = rotate(0, 11, angle)
  puts "move RN#{rn} (P 9.25 #{angle});"
  puts "rotate =R#{90+angle} RN#{rn};"
end