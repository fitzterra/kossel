// The build plate I will be using for this build is an aluminium heated plate
// with a diameter of 220mm while the frame size needs a build plate of about
// 244mm diameter to fit on all three sides.
//
// An extension bracket to fit on the insides of all three frame sections will
// be used to make the the build plate fit.
//
// The bracket will consist os a stip of metal or aluminium the bolts onto the
// top of the frame extrusion in the center of each of the horizontal beams.
//
// For support a printed gusset will fit beneath the plate and against the
// extrusion frame. The gusset will be printed in ABS, but for extra protection
// from the heated bed, a layer of 3mm rubber will be used between the gusset
// and alu/metal plate.


plateT = 1.5;       // Thickness of the metal plate used for the extension top
isolationT = 3;     // Thickness of the isolation rubber between gusset and plate
extend = 20;        // The distance to extend into the frame

extrusion = 15;     // Openbeam extrusion size;


/**
 * This module is used to create a dynamic length extrusion from a 1000mm 1515
 * extrusion STL file
 **/
module extrusion_15(len=240) {
  difference() {
    import("1515_1000mm.stl", convexity=10);
    translate([-10,-10,len])
        cube([20,20,(1000-len)+2]);
  }
}

/**
 * To make adjustment easier, the gusset has a slot, much like the openbeam
 * extrusions, at the top.
 *
 * NOTE! The gusset is generated upside down, which is also the correct
 * orientation for printing.
 *
 * @param ext: The amount of extention into the frame.
 **/
module Gusset() {
    topT = plateT;          // Thickness of the top metal/alu strip
    isoT = isolationT;      // Thickness of the isolation rubber

    slotLipH = 2.5;     // Height of the upper lips of the slot
    slotDepth = 6;
    slotWidthT = 3.4;
    slotWidthB = 6.2;
    slotLipW = (slotWidthB-slotWidthT)/2;

    w = extrusion;      // Bracket width is the same as the extrusion width
    h = extrusion-isoT; // Max height of the bracket
    l = extend;            // Length it extends into the frame

    difference() {
        // The main stock - upside down
        cube([w, l, h]);
        // Slot for the M3 nuts to go in
        translate([-slotWidthB/2+w/2, l+1, slotLipH])
            rotate([90, 0, 0])
                linear_extrude(height=l+2, convexity=10)
                    polygon(points=[
                                [0, 0],
                                [slotLipW, 0],
                                [slotLipW, -slotLipH-0.5],
                                [slotLipW+slotWidthT, -slotLipH-0.5],
                                [slotLipW+slotWidthT, 0],
                                [slotWidthB, 0],
                                [slotWidthB, slotDepth-slotLipH],
                                [slotWidthB-slotLipW, slotDepth-slotLipH+slotLipH],
                                [slotLipW, slotDepth-slotLipH+slotLipH],
                                [0, slotDepth-slotLipH]
                            ]);
        // Slanted edge
        translate([-1, 5+0.1, h+0.1])
            rotate([0, 90, 0])
                linear_extrude(height=w+2, convexity=10)
                    polygon(points=[
                                [0, 0],
                                [h-5, l-5],
                                [0, l-5],
                            ]);
    }

}

/**
 * Shows a demo of what the gusset with rubber isolation and metal plate will
 * look like.
 **/
module BracketAssembly() {
    $fn=64;

    translate([extrusion/2, 0, 0])
        rotate([0, 180, 0])
            Gusset();
    difference() {
        union() {
            translate([-extrusion/2, 0, 0])
                color("gray")
                    cube([extrusion, extend, isolationT]);
            translate([-extrusion/2, -extrusion, isolationT])
                color("Silver")
                    cube([extrusion, extend+extrusion, plateT]);
        }
        // Slot the plate and isolation
        translate([0, extend/4, -1]) {
            cylinder(d=3, h=isolationT+plateT+2);
            translate([0, extend/2, 0])
                cylinder(d=3, h=isolationT+plateT+2);
            translate([-3/2, 0, 0])
                cube([3, extend/2, isolationT+plateT+2]);
        }
        // Extrusion mount hole
        translate([0, -extrusion/2, 0])
            cylinder(d=3, h=isolationT+plateT+2);
    }
    color("Silver")
    translate([-25, -7.5, -7.5+isolationT])
        rotate([0, 90, 0])
            extrusion_15(50);
}

Gusset();
*translate([30, 0, 0])
    BracketAssembly();
