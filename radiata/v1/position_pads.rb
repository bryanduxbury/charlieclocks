
names = %w(SCL MISO MOSI RESET VCC GND)

names.each_with_index do |name, idx|
  puts "move #{name} (P 6.5 #{60*idx});"
end