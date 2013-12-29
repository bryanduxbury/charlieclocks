use <pcba_mockup.scad>;

l = 0.005 * 25.4;

pcba_x = 40;
pcba_y = 42;
pcba_z = 4;

screw_head_d = 5;
screw_shaft_d = 3;

stand_width = 15;

module _clear_acrylic() {
  color([255/255, 255/255, 255/255, 0.5]) {
    linear_extrude(center=true, height=1.6) {
      child(0);
    }
  }
}

module _outline(x, y, z) {
  union() {
    for (i=[0:3]) {
      rotate([0, 0, 90 * i]) hull() {
        circle(r=x, $fn=120);
        rotate([0, 0, 45]) translate([y, 0, 0]) circle(r=z, $fn=36);
      }
    }
  }
}

module midring() {
  difference() {
    _outline(pcba_x+2, pcba_y, pcba_z+2);
    _outline(pcba_x, pcba_y, pcba_z);
  }
}

module face_retainer() {
  difference() {
    _outline(pcba_x+2, pcba_y, pcba_z+2);
    circle(r=38.75, $fn=120);

    for (i=[0:3])
    rotate([0, 0, 90 * i]) {
      rotate([0, 0, 45]) translate([pcba_y, 0, 0]) circle(r=screw_shaft_d/2, $fn=36);
    }
  }
}

module face() {
  difference() {
    _outline(pcba_x+2, pcba_y, pcba_z+2);

    for (i=[0:3])
    rotate([0, 0, 90 * i]) {
      rotate([0, 0, 45]) translate([pcba_y, 0, 0]) circle(r=screw_head_d/2, $fn=36);
    }
  }
}

module back_retainer() {
  difference() {
    _outline(pcba_x+2, pcba_y, pcba_z+2);
    circle(r=17, $fn=120);

    for (i=[0:3])
    rotate([0, 0, 90 * i]) {
      rotate([0, 0, 45]) translate([pcba_y, 0, 0]) circle(r=screw_shaft_d/2-l/2, $fn=36);
    }
  }
}

module back() {
  difference() {
    _outline(18, 19, 2);
    for (i=[0:5]) {
      rotate([0, 0, 60 * i + 90]) 
        translate([8, 0, 0]) circle(r=1, $fn=12);
    }
    
    // optional: cut outs for the switches
    // for (a = [30, 150]) {
    //   rotate([0, 0, a]) translate([13, 0, 0]) square(size=[6.25, 6.25], center=true);
    // }
    
    // power cord
    translate([0, -15, 0]) circle(r=1.75, $fn=12);
  }
}

module stand_piece1() {
  assign(dim = pcba_y + pcba_z + 2)
  difference() {
    circle(r=dim, $fn=120);
    circle(r=dim - stand_width, $fn=120);
    translate([0, -(dim)/2, 0]) 
      square(size=[(dim) * 2, dim], center=true);
  }
}

module stand_piece2() {
  assign(dim = pcba_y + pcba_z + 2)
  difference() {
    circle(r=dim, $fn=120);
    circle(r=dim - stand_width, $fn=120);
    translate([0, -(dim)/2, 0]) 
      square(size=[(dim) * 2, dim], center=true);
  }
}

module stand_back() {
  
}

module stand_assembled() {
  rotate([0, 45, 0]) {
    stand_piece1();
    rotate([0, 90, 0]) stand_piece2();
  }
}


module assembled() {
  pcba();
  _clear_acrylic() midring();
  translate([0, 0, 1.6]) _clear_acrylic() face_retainer();
  translate([0, 0, 1.6 * 2]) _clear_acrylic() face();

  translate([0, 0, -1.6]) _clear_acrylic() back_retainer();
  translate([0, 0, -1.6 * 2]) _clear_acrylic() back();
}

rotate([-15, 0, 0]) translate([0, 1.5 * 1.6, 0]) stand_assembled();
rotate([75, 0, 0]) assembled();

