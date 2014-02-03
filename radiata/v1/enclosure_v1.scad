use <pcba_mockup.scad>;

l = 0.005 * 25.4;

pcba_x = 40;
pcba_y = 42;
pcba_z = 4;

outside_margin_w = 3;

screw_head_d = 5.2;
screw_shaft_d = 2.85;

stand_width = 20;

rest_angle = 15;

acrylic_t = 1.6;

tab_width = 3;

module _clear_acrylic() {
  color([255/255, 255/255, 255/255, 0.5]) {
    linear_extrude(center=true, height=acrylic_t) {
      child(0);
    }
  }
}

module _black_acrylic() {
  color("black") {
    linear_extrude(center=true, height=acrylic_t) {
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
    _outline(pcba_x+outside_margin_w, pcba_y, pcba_z+outside_margin_w);
    _outline(pcba_x+l, pcba_y, pcba_z+l);
  }
}

module face_retainer() {
  difference() {
    _outline(pcba_x+outside_margin_w, pcba_y, pcba_z+outside_margin_w);
    circle(r=38.75, $fn=120);

    for (i=[0:3])
    rotate([0, 0, 90 * i]) {
      rotate([0, 0, 45]) translate([pcba_y, 0, 0]) circle(r=screw_shaft_d/2-l/2, $fn=36);
    }
  }
}

module face() {
  difference() {
    _outline(pcba_x+outside_margin_w, pcba_y, pcba_z+outside_margin_w);

    for (i=[0:3])
    rotate([0, 0, 90 * i]) {
      rotate([0, 0, 45]) translate([pcba_y, 0, 0]) circle(r=screw_head_d/2, $fn=36);
    }
  }
}

module back_retainer() {
  difference() {
    _outline(pcba_x+outside_margin_w, pcba_y, pcba_z+outside_margin_w);
    circle(r=17, $fn=120);

    for (i=[0:3])
    rotate([0, 0, 90 * i]) {
      rotate([0, 0, 45]) translate([pcba_y, 0, 0]) circle(r=screw_shaft_d/2-2*l, $fn=36);
    }

    for (x=[-1,1]) 
    translate([x * (stand_width/2 - acrylic_t/2), -pcba_x-outside_margin_w, 0]) {
      translate([0, pcba_x - 18 + outside_margin_w - tab_width/2, 0]) 
        square(size=[acrylic_t-l, tab_width-l], center=true);
      translate([0, acrylic_t/2 / tan((90-rest_angle)/2) + tab_width, 0]) 
        square(size=[acrylic_t-l, tab_width-l], center=true);
    }
  }
}

module back() {
  difference() {
    _outline(18, 19, 2);
    // for (i=[0:5]) {
    //   rotate([0, 0, 60 * i + 90]) 
    //     translate([8, 0, 0]) circle(r=1, $fn=12);
    // }

    // optional: cut outs for the switches
    for (a = [30, 150]) {
      rotate([0, 0, a]) translate([13, 0, 0]) square(size=[6.5, 6.5], center=true);
    }

    // power cord
    translate([0, -15, 0]) circle(r=2, $fn=32);
  }
}

module stand_side() {
  assign(h = pcba_x - 18 + outside_margin_w)
  assign(d = (pcba_x + outside_margin_w) * 2 * sin(rest_angle)) 
  difference() {
    union() {
      hull() {
        translate([acrylic_t/2-l/2, h - acrylic_t/2, 0]) 
          square(size=[acrylic_t, acrylic_t+l], center=true);

        translate([acrylic_t/2-l/2, acrylic_t/2 / tan((90-rest_angle)/2), 0]) 
          circle(r=acrylic_t/2, $fn=36);

        rotate([0, 0, rest_angle]) translate([d-acrylic_t/2, acrylic_t/2, 0]) 
          circle(r=acrylic_t/2, $fn=36);
      }

      translate([0, h - tab_width/2, 0]) 
        square(size=[2 * acrylic_t, tab_width+l], center=true);
      translate([0, acrylic_t/2 / tan((90-rest_angle)/2) + tab_width, 0]) 
        square(size=[2 * acrylic_t, tab_width+l], center=true);
    }

    rotate([0, 0, rest_angle]) translate([0, acrylic_t * 1.5, 0]) {
      translate([3+tab_width/2, 0, 0]) square(size=[tab_width-l, acrylic_t-l], center=true);
      translate([d - 3 - tab_width/2, 0, 0]) square(size=[tab_width-l, acrylic_t-l], center=true);
    }
  }
}

module stand_bottom() {
  assign(d = (pcba_x + outside_margin_w) * 2 * sin(rest_angle)) 
  translate([0, -(d)/2, 0]) 
  union() {
    square(size=[stand_width-2*acrylic_t+l, d-6+l], center=true);
    for (x=[-1,1], y=[-1,1]) {
      translate([x * (stand_width-2*acrylic_t)/2, y * ((d-6) / 2 - tab_width/2), 0]) 
        square(size=[acrylic_t*2+l, tab_width+l], center=true);
    }
  }
}


module assembled() {
  pcba();
  _clear_acrylic() midring();
  translate([0, 0, acrylic_t]) _clear_acrylic() face_retainer();
  translate([0, 0, acrylic_t * 2]) _clear_acrylic() face();

  translate([0, 0, -acrylic_t]) _clear_acrylic() back_retainer();
  translate([0, 0, -acrylic_t * 2]) _clear_acrylic() back();
  for (x=[-1,1]) {
    translate([x * (stand_width / 2 - acrylic_t/2), -pcba_x-outside_margin_w, -acrylic_t * 1.5]) 
      rotate([0, 90, 0]) _clear_acrylic() stand_side();
  }
  
  assign(d = (pcba_x + outside_margin_w) * 2 * sin(rest_angle)) 
  translate([0, -pcba_x - outside_margin_w + acrylic_t * 1.5, -acrylic_t * 1]) 
    rotate([90+rest_angle, 0, 0]) 
        _clear_acrylic() stand_bottom();

}

rotate([0, 0, $t * 360]) {
  // a mock "ground" plane so we can see how the object rests
  translate([0, 0, -(pcba_x + outside_margin_w) * cos(rest_angle) - 0.25]) 
    cube(size=[200, 200, 0.5], center=true);

  rotate([90-rest_angle, 0, 0]) 
    translate([0, 0, acrylic_t * 1.5]) 
      assembled();
}

