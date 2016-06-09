include <configuration.scad>;

capHeight = 8;

module cap() {
    h = capHeight;
    translate([0, 0, h/2])
    intersection() {
        cube([42.2, 42.2, h], center=true);
        rotate([0, 0, 45])
            cube([55, 55, h], center=true);
    }
}

module nema17() {
    // NEMA 17 stepper motor.
    difference() {
        union() {
            translate([0, 0, -motor_length/2])
                color([20/255, 20/255, 20/255])
                intersection() {
                    cube([42.2, 42.2, motor_length-2*capHeight], center=true);
                    cylinder(r=25.1, h=motor_length+1, center=true, $fn=60);
                }
            color("silver") {
            for(h=[-capHeight, -motor_length])
                translate([0, 0, h])
                    cap();
            cylinder(r=11, h=2, center=false, $fn=64);
            cylinder(r=2.5, h=24, center=false, $fn=64);
            }
        }
        for (a = [0:90:359]) {
            rotate([0, 0, a])
                translate([15.5, 15.5, 0])
                    cylinder(r=m3_radius, h=10, center=true, $fn=12);
        }
    }
}

nema17();
