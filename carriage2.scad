//include <configuration.scad>;

$fn=64;

// Belt parameters
belt_width_clamp = 6;              // width of the belt, typically 6 (mm)
belt_thickness = 1.0 - 0.05;       // slightly less than actual belt thickness for compression fit (mm)           
belt_pitch = 2.0;                  // tooth pitch on the belt, 2 for GT2 (mm)
tooth_radius = 0.8;                // belt tooth radius, 0.8 for GT2 (mm)

// Distance between connecting rod horn faces
separation = 40;
// The thickness (or height when laying flat on its back) of the carriage
thickness = 6;
// Height when standing (as would be mounted) upright
height = 40;

horn_thickness = 13;
horn_x = 8;

belt_width = 5;
belt_x = 5.6;
belt_z = 7;
corner_radius = 3.5;


m3_nut_radius = 3.0;
m3_wide_radius = 1.5;
m3_tap_radius = 1.4; // Radius for tapping M3 thread into

module carriage(sample_belts=false) {
    // Timing belt (up and down) samples.
    if(sample_belts==true) {
        translate([-belt_x, 0, belt_z + belt_width/2])
            %cube([1.7, 100, belt_width], center=true);
        translate([belt_x+1.23, 0, belt_z + belt_width/2])
            %cube([2.3, 100, belt_width], center=true);
    }

    difference() {
        union() {
            // Main body.
            translate([0, 4, thickness/2])
                cube([27, height, thickness], center=true);
            // Ball joint mount horns.
            intersection() {
                translate([0, 15, horn_thickness/2])
                    cube([separation, 18, horn_thickness], center=true);
                for (x = [-1, 1]) {
                    scale([x, 1, 1])
                        translate([horn_x, 16, horn_thickness/2])
                            rotate([0, 90, 0])
                                cylinder(r1=14, r2=2.5, h=separation/2-horn_x);
                    }
            }

            // Avoid touching diagonal push rods (carbon tube).
            difference() {
                translate([10.75, 2.5, horn_thickness/2+1])
                    cube([5.5, 37, horn_thickness-2], center=true);
                translate([23, -12, 12.5]) rotate([30, 40, 30])
                    cube([40, 40, 20], center=true);
                translate([10, -10, 0])
                    cylinder(r=m3_wide_radius+1.5, h=100, center=true);
            }

            // Belt clamps
            color("CadetBlue")
            for (y = [[9, -1], [-1, 1]]) {
                translate([2.20, y[0], horn_thickness/2+1])
                    hull() {
                        translate([ corner_radius-1.5, -y[1] * corner_radius + y[1], 0])
                            cube([3.0, 5, horn_thickness-2], center=true);
                        cylinder(h=horn_thickness-2, r=corner_radius, center=true);
                    }
            }

            // belt clip cubes
            color("SteelBlue")
            for(y=[19, -11]) {
                translate([2.20, y, horn_thickness/2+1]) {
                    difference() {
                        // Want to make the flat clamp side slightly thicker
                        // (it keeps breaking there from stress on the belt)
                        // (1mm), but the stock block is centered to line up
                        // with the teardrop loop, so we need to offset on the
                        // X axis by half the added thickness to compensate for
                        // the centering below.
                        translate([-0.5, 0, 0])
                            cube([8, 10, horn_thickness-2], center=true);
                        translate([-1.5,-5,-1.5]) {
                            cube([belt_thickness,10,10]);
                            for (mult = [0:5]) {
                                translate([1,belt_pitch*mult,0])
                                    cylinder(r=tooth_radius, h=10);
                            }
                        }
                        // Angle the belt entry points slightly
                        translate([y<0?-1.5:-3.4, y<0?3.5:-5.8, -3])
                            rotate([0, 0, y<0?40:-40])
                                cube([1.5, 3, horn_thickness]);
                    }
                    // Support for belt clips
                    translate([-7.5, -5, -1.5]) 
                        difference() {
                            cube([3, 10, 3]);
                            translate([0, -0.1, 3])
                                rotate([-90, 0, 0])
                                cylinder(d=6, h=10.2);
                        }
                }
            }
        }

        // Screws for linear slider.
        for (x = [-10, 10]) {
            for (y = [-10, 10]) {
                translate([x, y, thickness])
                cylinder(r=m3_wide_radius, h=30, center=true);
            }
        }
        // Screws for ball joints.
        #translate([-36, 16, horn_thickness/2])
            rotate([0, 90, 0])
                cylinder(r=m3_tap_radius, h=60, center=true);
        #translate([36, 16, horn_thickness/2])
            rotate([0, 90, 0])
                cylinder(r=m3_tap_radius, h=60, center=true);
        // Lock nuts for ball joints.
        *for (x = [-1, 1]) {
            scale([x, 1, 1])
                translate([horn_x-1.25, 16, horn_thickness/2])
                    rotate([0, 90, 0])
                        cylinder(r=m3_nut_radius, h=8, center=true, $fn=6);
        }

        // Slide a nut out on the rigth ball joint side, cutting as it goes
        // along to make a slot to get the nut into through the top belt clip
        // and belt retainer clamp.
        *for(z=[0:2]) {
        translate([horn_x-1.25, 16, (horn_thickness/2)+z*m3_nut_radius])
            rotate([0, 90, 0])
                cylinder(r=m3_nut_radius, h=5, center=true, $fn=6);
        }
    }
}

carriage();

*color("limegreen")
    translate([0, -16, -20.5])
        rotate([90, 0, 180])
            import("stl/tower_slides.stl");

*intersection() {
    carriage();
    translate([0, 0, 34])
    cube([15, 80, 60], center=true);
}
