puts "mark (40 40);"
range = 360.0
(1..9).to_a.reverse.each_with_index do |rn, idx|
  angle = range / 9 * (idx) + 90
  # xy = rotate(0, 11, angle)
  puts "move RN#{rn} (P 9.25 #{angle});"
  puts "rotate =R#{90+angle} RN#{rn};"
end

puts "mark (40 40);"
puts "mark (P 15 0);"
puts "move 'rs1' (P 2 0);"
puts "rotate =R90 'rs1';"
puts "move 'rr1' (P -2 180);"
puts "rotate =R90 'rr1';"