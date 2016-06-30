// Glass mounting tab with a glass grip lip.
//
// This tab only works for a glass size that is large enough to overlap the
// horizontal beams. It can be moved away from the beam center on all three
// sides, but still snuggly grip the class in the exact curved grip when all
// three sides are secured right up to the glass.


// For 'extrusion' and 'thickness' values
include <configuration.scad>;

tab_width = 25;
tab_len = 20;       // This is the length from the extrusion into the body
grip_thickness = 4; // How thick the grip part on top should be
glass_diameter = 250; // Diameter of the glass
// How far the glass needs to be offset from the mounting screw head. This
// should be large enough to give enough space for the screw head if the glass
// sticks out above the grip lip.
// Assuming the M3 screws being used has a 6mm head size, then about 3.8mm will give enough clearance.
glass_screwhead_offset = (extrusion/2)/2;

// Make the round edge line up with the outside of OpenBeam.
screw_offset = tab_width/2 - extrusion/2;
// The length of the inset into the frame, but the square part starts at the
// center of the round part.`
cube_length = tab_len + (extrusion - tab_width/2);
// The full tab thickness before cutting out the glass fitting part.
tab_thickness = thickness + grip_thickness;

module glass_tab() {
  difference() {
    translate([0, screw_offset, 0])
        union() {
          cylinder(r=tab_width/2, h=tab_thickness, center=true);
          translate([0, cube_length/2, 0])
            cube([tab_width, cube_length, tab_thickness], center=true);
        }
    // The screw hole
    cylinder(r=m3_wide_radius, h=20, center=true, $fn=12);
    // The cutout for the tab grip
    translate([0, glass_screwhead_offset+glass_diameter/2, thickness/2+1])
        #cylinder(d=glass_diameter, h=grip_thickness+2, center=true, $fn=256);
  }
}

translate([0, 0, tab_thickness/2])
    glass_tab();
// Measure to make sure tab length is correct
*translate([tab_width/2, extrusion/2, 0])
    cube([2, tab_len, 10]);
// Horizontal OpenBeam.
translate([0, 0, -extrusion/2])
    %cube([100, extrusion, extrusion], center=true);
