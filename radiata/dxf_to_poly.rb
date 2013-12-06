class Array
  def index_by
    self.inject({}) {|accum, element| accum[yield(element)] = element; accum }
  end
end

segments = []

while x = gets
  x.chomp!
  if x == "LINE"
    gets
    gets
    
    # print "wire 0.0254"
    gets
    x1 = gets.chomp.strip
    gets
    x2 = gets.chomp.strip
    gets
    y1 = gets.chomp.strip
    gets
    y2 = gets.chomp.strip
    # print " (R #{x1} #{y1}) (R #{x2} #{y2})"
    # puts ";"
    segments << [[x1, y1], [x2, y2]]
    gets
  end
end

segments_by_start = segments.index_by(&:first)

polygons = []

until segments.empty?
  pts = []
  # pull off the next segment
  start = segments.shift
  pts << start.first
  cur = segments_by_start[start.last]
  while cur != start
    segments.delete(cur)
    pts << cur.first
    cur = segments_by_start[cur.last]
  end
  pts << start.first
  polygons << pts
end

# puts polygons.size

for polygon in polygons
  print "poly"
  for pt in polygon
    print " (R #{pt.first} #{pt.last})"
  end
  puts ";"
end