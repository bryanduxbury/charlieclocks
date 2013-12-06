
for (i=[0:3]) {
  rotate([0, 0, 90 * i]) hull() {
    circle(r=40, $fn=120);
    rotate([0, 0, 45]) translate([42, 0, 0]) circle(r=4, $fn=36);
  }
}

