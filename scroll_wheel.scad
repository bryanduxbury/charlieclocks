id = 35;
od = 40;
triangle_pitch = 4;
triangle_tip_width = 0.007 * 25.4 * 2;
triangle_gap = 4;
track_spacing = 0.4;

function polar(radius, theta) = [radius * cos(theta), radius * sin(theta)];

module chain_hull() {
  union() {
    for (cnum=[0:$children-2]) {
      hull() {
        child(cnum);
        child(cnum+1);
      }
    }
  }
}

module curved_triangle(r, pitch, separation, gap) {
  assign(num_steps = 36)
  assign(top_d = pitch - 2 * separation)
  assign(bottom_d = triangle_tip_width)
  assign(delta = top_d - bottom_d)
  assign(r_incr = delta / (num_steps-1) / 2)
  assign(b_incr=116/(num_steps - 1))
  render()
  for (i=[0:(num_steps-2)]) {
    hull() {
      rotate([0, 0, b_incr * i]) 
        translate([r, 0, 0]) 
          square(size=[top_d - r_incr * i * 2, 0.01], center=true);
      rotate([0, 0, b_incr * (i+1)]) 
        translate([r, 0, 0]) 
          square(size=[top_d - r_incr * i * 2, 0.01], center=true);
    }
  }
}

module rotor_section(inner_radius, outer_radius, pitch, separation, gap) {
  assign(rotor_width=outer_radius - inner_radius)
  assign(triangles_per_side = ceil(rotor_width / pitch))
  intersection() {
    difference() {
      union() {
        translate([rotor_width/2 + inner_radius, 0, 0]) 
          square(size=[rotor_width, gap], center=true);

        // echo ("triangles per side:", triangles_per_side);
        for (i=[0:triangles_per_side]) {
          // echo("r", inner_radius + i * pitch);
          curved_triangle(inner_radius + i * pitch, pitch, separation, gap);
        }
        
        rotate([180, 0, 0]) 
        for (i=[0:triangles_per_side-1]) {
          // echo("r", inner_radius + i * pitch);
          curved_triangle(inner_radius + i * pitch + pitch/2, pitch, separation, gap);
        }
      }
      circle(r=inner_radius, $fn=120);
    }
    circle(r=outer_radius, $fn=120);
  }
}

module rotor(inner_radius, outer_radius, pitch, separation, gap) {
  for (i=[0:2]) {
    rotate([0, 0, 120 * i]) 
      rotor_section(inner_radius, outer_radius, pitch, separation, gap);
  }
}

rotate([0, 0, 90]) 
  rotor(30, 35, 2.5, 0.35, 2);