id = 35;
od = 40;
triangle_pitch = 4;
triangle_tip_width = 0.4;
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
  assign(delta = pitch - 2 * separation - triangle_tip_width)
  assign(b_incr=116/(num_steps - 1))
  render()
  for (i=[0:(num_steps-1)]) {
    hull() {
      translate(polar(r, b_incr * i)) circle(r=delta / 2 / num_steps * (num_steps-i), $fn=12);
      translate(polar(r, b_incr * (i+1))) circle(r=delta / 2 / num_steps * (num_steps-(i+1)), $fn=12);
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

rotor(33.5, 39.5, 3, 0.2, 2);