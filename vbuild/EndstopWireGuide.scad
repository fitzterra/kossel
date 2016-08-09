// Wire guide for endstop wires.
//
// Since this build uses the printed sliders running directly on the openbeam
// extrusion, wires can not be run inside the extrusion grooves. These guide
// brackets are installed top and bottom on the upright beams and the endstop
// wires are kept away from the upright bey them.
//

$fn=64;

include <../configuration.scad>;

depth = 16;  // Distance away from extrusion
width = 15;  // Same as vertical extrusion.
height = 8;  // Height for the guide
notchW = 4;  // Width for notch in the version 1 guide
nothchD = 4; // Depth of the notch in the version 1 guide
slotW = 2;   // Width of the wire slot in the version 2 guide
slotD = 8;   // Depth of the wire slot in the version 2 guide
// Clearance from extrusion to slot ends. This is to give the enough clearance
// to the wires so that they do not touch the backs of the sliders running on
// the extrusions.
extClear = 6;
// We're allowing 4mm penetration into the extrusion, so the screw length must
// be long enough to leave sufficient wall thinkness for srength.
screwLen = 10;
screwHeadD = 6; // Diameter for screw head

module EndStopWireGuideV1() {
    difference() {
        union() {
            // The main body
            cube([width, depth, height], center=true);
            // The bit that fits into the extruded groove
            translate([0, 2.5, 0])
                cube([2.5, depth, height], center=true);
        }
        // The screw hole
        translate([0, 0, 0])
            rotate([90, 0, 0]) {
                // Main shaft hole
                cylinder(r=m3_wide_radius, h=depth+2, center=true);
                // Inset area for screw head
                translate([0, 0, 2+0.1])
                    cylinder(d=6, h=depth-4, center=true);
                // Flared end for nut
                translate([0, 0, -depth/2])
                    scale([1, 1, -1])
                        cylinder(r1=m3_wide_radius, r2=7, h=4);
            }
        // The notch in front where the wire fits in
        translate([-notchW/2, -depth/2-1, -height/2-1]) {
            cube([notchW, nothchD+1, height+2]);
        }
    }
}

module EndStopWireGuideV2(height=height, yCent="c") {
    slot45 = slotW/4;   // Length for one side for the 45° slot corners
    // Center of slots from center of guide. the 1.5 is to ensure at least 1.5
    // wall thickness around center screw hole.
    slotC = width/4+1.5;
    // The polygon points for the slot. it is drawn with the Y plane through
    // the center of the slot.
    slotPoints = [
        [0, 0],     // Front middle of the slot
        [slotW/2-slot45, 0],    // Front right bottom 45 corner
        [slotW/2, slot45],      // Front right top 45 corner     
        [slotW/2, slotD-slot45*2],// Back right bottom 45 corner     
        [slotW/2-slot45, slotD-slot45],// Back right top 45 corner     
        [-slotW/2+slot45, slotD-slot45],// Back left top 45 corner     
        [-slotW/2, slotD-slot45*2],// Back left bottom 45 corner     
        [-slotW/2, slot45],// Front left top 45 corner     
        [-slotW/2+slot45, 0],// Front left bottom 45 corner     
    ];


    fd = 6;
    fw = 6;

    translate([0, yCent?0:-depth/2])
    difference() {
        union() {
            // The main body
            cube([width, depth, height], center=true);
            // The bit that fits into the extruded groove
            translate([0, 2.5, 0])
                cube([2.5, depth, height], center=true);
        }
        // The screw hole
        translate([0, 0, 0])
            rotate([90, 0, 0]) {
                // Main shaft hole
                cylinder(r=m3_wide_radius, h=depth+2, center=true);
                // Recess for screw head allowing screw to penetrate 4mm into extruded slot
                translate([0, 0, -depth/2+(screwLen-4)])
                    cylinder(d=screwHeadD, h=depth-2-fd);

                // Flared end for nut
                translate([0, 0, -depth/2])
                    scale([1, 1, -1])
                        cylinder(r1=m3_wide_radius, r2=7, h=4);
            }
        // The wire slots with 45° corners
        for(x=[-slotC, slotC])
            translate([x, depth/2-extClear-slotD, 0])
                linear_extrude(height=height+2, center=true, convexity=10)
                    polygon(points=slotPoints);
        // Recess the front for the screw and open wire slots
        *translate([-slotC+slotW/2-slot45, -depth/2-1, -height/2-1])
            cube([slotC*2-slotW+slot45*2, nothchD+slot45+1, height+2]);
        translate([-fw/2, -depth/2+2, -height/2-1])
            cube([fw, fd, height+2]);
        // The front gap
        translate([-1.5, -depth/2-1, -height/2-1])
            cube([3, fd, height+2]);
        translate([-slotC, depth/2-extClear-slotD, -height/2-1])
            cube([slotC*2, slot45*2, height+2]);
    }

}

*translate([-width-4, 0, 0])
    EndStopWireGuideV1();
EndStopWireGuideV2();
