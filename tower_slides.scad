// These are printed sliders for linear motion instead of rollers or MGN12C
// sliders.
//
// This is from http://www.thingiverse.com/thing:262462 with some of my own
// mods.

include <configuration.scad>;

$fn=60;

// Set this to true to create a 10mm tall test block. See the cutter_padding
// setting below.
test_block = false;
// Amount of padding to add to the extrusion cutter for your printer and print
// settings to allow a tight fit of the slider over the extrusion. Use the
// test_block setting above to print samples and play with this value until you
// find the best fit.
cutter_padding = 0.4;

extrusion_w = extrusion;    // From configuration.scad
extrusion_slot_w = 3.2;
// Thickness, or height from back of rail to front of truck. This is to match
// the amount of offset the MGN12C rails and trucks add from the vertical
// extrusions to the carraige.
mgn12_truck_thickness = 13;

// Height for the slide
slide_h = 40;
// Length of the slider direction outside of frame to inside where carraige
// attaches. This is the extrusion size from configuration.scad, plus the
// original thickness of the MGN12C truck slider, plus some additional meat
// back and front.
slide_l = extrusion_w + mgn12_truck_thickness + 5;
// The width of the slider is the same as the carraige width.
slide_w = 27;

// Width and length for the hole in front for saving print time and filament.
psaver_w = 9;
psaver_l = 13;

// Amount of space to offset the slide in the Y plane to get the center of the
// extrusion on 0 in the Y direction.
slide_y_offset = mgn12_truck_thickness -((slide_l-extrusion_w)/2);

// Whether to add holes for tensionsing screws
tension_screws = true;
// The offset from the middle up and down of where to place the upper and lower
// tension screws.
tension_screw_offset = 15;
// The diameter of the nylon tension screws. These should probably be less than
// the extrusion slots widths (taking the cutter_padding into account) unless
// your printer can support printing the internal slides broken by these holes.
tension_screw_d = 2.4;

/**
 * Module to make the cutter for the aluminium extrusion.
 *
 * It is expected that extrusion_w be set to the exact extrusion width without
 * any allowences for padding, clearences or print/plastic tollerences. The pad
 * parameter to this method should then be used to add any clearances padding
 * to the cutter die which will make sure that all extrusion surface sizes gets
 * the correct clearence when cutting the slide shape.
 *
 * @param pad: The amount of padding/clearence to allow when cutting the
 *             extrusion shape from a solid block.
 * @param cap: The height for end caps (each cap will be half this height) to add???
 */
module extrudedCutter(pad=0, cap=2) {
    ew = extrusion_w + pad;
    difference(){
     cube([ew, ew, slide_h+cap], center=true);
     for(an = [0:2]) 
      rotate(an*-90)
        translate([(ew-extrusion_slot_w)/2, 0, 0])
            cube([extrusion_slot_w, extrusion_slot_w-pad, slide_h+2], center=true);
    }
}

/**
 * Module to produce a test slider 10mm high to test and adjust padding and
 * clearences.
 *
 **/
module Tester(showExtrusion=false) {
    difference() {
        cube([extrusion_w+6, extrusion_w+6, 10], center=true);
        extrudedCutter(cutter_padding);
    }
    if (showExtrusion==true) {
        %extrudedCutter(0, 0);
    }
}

/**
 * Module to create one slider.
 **/
module Slider() {
    // Sample extrusion without any padding
    %extrudedCutter(0, 0);
    filletR = 1.5;  // Radius for fillets
    translate([0,slide_y_offset,slide_h/2])
        difference() {
            // The main slider block with filleted vertical corners
            difference() {
                minkowski() {
                    // With minkowski, we need to subtract the full size of the
                    // cylinder (r*2 and height) from the cube.
                    cube([slide_w-2*filletR, slide_l-2*filletR,slide_h-1],center=true);
                    cylinder(r=filletR, h=1, center=true);
                }
            }
            // Cutout of the extrusion and tension screws
            translate([0,-slide_y_offset,0])
                union() {
                    extrudedCutter(cutter_padding);
                    // Holes for the nylon screws to adjust tension on the
                    // extrusion.
                    if(tension_screws==true) {
                        for(z=[tension_screw_offset, -tension_screw_offset]) {
                            translate([0, 0, z])
                                rotate([0,90,0])
                                    cylinder(h=slide_w+2, d=tension_screw_d, center=true);
                            translate([0, -extrusion_w/2-slide_y_offset, z])
                                rotate([90,0,0])
                                    cylinder(h=extrusion_w, d=tension_screw_d, center=true);
                        }
                    }
                }

            // Carraige mounting holes 
            translate([0,-2,-4])
                rotate([-90,0,0])
                    for (a = [0: 1]) {
                        rotate([0,0,a*180])
                            union() {
                                translate([10, 10, (slide_h-16)/2])
                                    cylinder(r=m3_radius, h=16, center=true);
                                translate([10, -10, (slide_h-16)/2])
                                    cylinder(r=m3_radius, h=16, center=true);
                            }
                    }

            // A hole for using less plastic
            translate([0,10,0]) 
                difference() {
                    minkowski() {
                        // With minkowski, we need to subtract the full size of the
                        // cylinder (r*2 and height) from the cube.
                        cube([psaver_l-2*filletR,psaver_w-2*filletR,slide_h+2-1],center=true);
                        cylinder(r=filletR, h=1, center=true);
                    }
                }
        }
}

if (test_block==true)
    Tester(true);
else
    Slider();
