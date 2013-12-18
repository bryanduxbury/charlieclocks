
module pcb() {
  color("lightblue")
  linear_extrude(height=1.6, center=true)
  difference() {
    union() {
      for (i=[0:3]) {
        rotate([0, 0, 90 * i]) hull() {
          circle(r=40, $fn=120);
          rotate([0, 0, 45]) translate([42, 0, 0]) circle(r=4, $fn=36);
        }
      }
    }
    for (i=[0:3]) {
      rotate([0, 0, 45 + 90 * i]) translate([42, 0, 0]) circle(r=3/2, $fn=36);
    }
  }
}

module 1206_resistor() {
  color("black")
  translate([0, 0, 0.01 * 25.4]) 
    cube(size=[0.06 * 25.4, 0.12 * 25.4, 0.02 * 25.4], center=true);
}

module led() {
  color("red")
  union() {
    translate([0, 0, 0.25/2]) cube(size=[1.6, 3.2, 0.25], center=true);
    translate([0, 0, 0.25 + (1.1 - 0.25) / 2]) 
      cylinder(r1=1.6/2, r2=1.1/2, h=1.1-0.25, center=true, $fn=16);
  }
}

module uC() {
  translate([0, 0, 1.2/2]) {
    color("black")
    cube(size=[7.1, 7.1, 1.2], center=true);
    translate([0, 0, -0.6 + 0.10]) 
    for (a=[0:3]) {
      rotate([0, 0, a * 90])
      translate([7.1/2, 0, 0]) 
      for (p=[0:3], d=[1,-1]) {
        color("silver")
        translate([0, 0.80 * p * d, 0]) 
        cube(size=[9.25 - 7.1, 0.3, 0.20], center=true);
      }
    }
  }
}

module sot23() {
  translate([0, 0, 0.5]) {
    color("black")
    cube(size=[2.9, 1.3, 1], center=true);

    color("silver") 
    translate([0, 0, -0.5 + 0.13/2]) {
      translate([0, 1.3/2, 0]) cube(size=[0.44, 2.4 - 1.3, 0.13], center=true);
      translate([0, -1.3/2, 0]) {
        translate([1.9/2, 0, 0]) cube(size=[0.44, 2.4 - 1.3, 0.13], center=true);
        translate([-1.9/2, 0, 0]) cube(size=[0.44, 2.4 - 1.3, 0.13], center=true);
      }
    }
  }
}

module switch(args) {
  translate([0, 0, 1.8]) {
    color("gray")
    cube(size=[6, 6, 3.6], center=true);
    
    color("black")
    translate([0, 0, 3]) cylinder(r=1.1, h=6, center=true, $fn=16);
  }
}

module crystal() {
  
}

module 0603_cap() {
  color("black")
  translate([0, 0, 0.01 * 25.4]) 
    cube(size=[0.03 * 25.4, 0.06 * 25.4, 0.02 * 25.4], center=true);
}

module pcba() {
  pcb();

  // front
  translate([0, 0, 1.6/2]) rotate([0, 0, 45]) uC();
  for (i=[0:59]) {
    rotate([0, 0, i * 6]) translate([32.5, 0, 1.6/2]) rotate([0, 0, 90]) led();
  }
  for (i=[0:11]) {
    rotate([0, 0, i * 30]) translate([37.5, 0, 1.6/2]) led();
  }
  for (i=[0:8]) {
    rotate([0, 0, i * 360/9 + 90]) translate([14.5, 0, 1.6/2]) rotate([0, 0, 90]) 1206_resistor();
  }
  for (i=[0:8]) {
    rotate([0, 0, i * 360/9 + 90]) translate([9, 0, 1.6/2]) rotate([0, 0, 90]) 1206_resistor();
  }
  for (i=[0:8]) {
    rotate([0, 0, 360 / 9 * i + 90 - 12]) translate([14.75, 0, 1.6/2]) rotate([0, 0, 90]) sot23();
    rotate([0, 0, 360 / 9 * i + 90 + 12]) translate([14.75, 0, 1.6/2]) rotate([0, 0, 90]) sot23();
  }

  // back
  rotate([0, 180, 0]) {
    for (i=[0:2]) {
      rotate([0, 0, 90 + i * 120]) translate([4, 0, 1.6/2]) 0603_cap();
    }

    for (i=[0:2]) {
      rotate([0, 0, 90 + i * 120]) translate([13, 2, 1.6/2]) rotate([0, 0, 90]) 1206_resistor();
      rotate([0, 0, 90 + i * 120]) translate([13, -2, 1.6/2]) rotate([0, 0, 90]) 1206_resistor();
    }
    
    for (i=[30, 150]) {
      rotate([0, 0, i]) translate([13, 0, 1.6/2]) switch();
    }
    
    color("black")
    for (i=[0:5]) {
      rotate([0, 0, 60 * i + 90]) 
        translate([8, 0, 1.65]) cylinder(r=1, h=0.1, center=true, $fn=12);
    }
    
  }
}

pcba();