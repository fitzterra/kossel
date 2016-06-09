// Wire guide for endstop wires.
//
// Since this build uses the printed sliders running directly on the openbeam
// extrusion, wires can not be run inside the extrusion grooves. These guide
// brackets are installed top and bottom on the upright beams and the endstop
// wires are kept away from the upright bey them.
//

include <../configuration.scad>;

thickness = 14;  // 1mm thicker than linear rail.
width = 15;  // Same as vertical extrusion.
height = 8;
nothcW = 4;
nothchD = 4;

module EndStopWireGuide() {
    difference() {
        union() {
            // The main body
            cube([width, thickness, height], center=true);
            // The bit that fits into the extruded groove
            translate([0, 2.5, 0])
                cube([2.5, thickness, height], center=true);
        }
        // The screw hole
        translate([0, 0, 0])
            rotate([90, 0, 0]) {
                // Main shaft hole
                cylinder(r=m3_wide_radius, h=thickness+2, center=true, $fn=12);
                // Inset area for screw head
                translate([0, 0, 2+0.1])
                    cylinder(d=6, h=thickness-4, center=true, $fn=12);
                // Flared end for nut
                translate([0, 0, -thickness/2])
                    scale([1, 1, -1])
                        cylinder(r1=m3_wide_radius, r2=7, h=4, $fn=24);
            }
        // The notch in front where the wire fits in
        translate([-nothcW/2, -thickness/2-1, -height/2-1]) {
            cube([nothcW, nothchD+1, height+2]);
        }
    }
}

EndStopWireGuide();
