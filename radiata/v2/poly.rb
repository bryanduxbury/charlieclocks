puts "change layer bottom;"
print "poly (P 17 267)"
((93/3)..(267/3)).each do |step|
  print "(P 17 #{step*3})"
end
puts ";"

puts 
print "poly (P 17 87)"
((273/3)..((360+87)/3)).each do |step|
  print "(P 17 #{step*3})"
end
puts ";"