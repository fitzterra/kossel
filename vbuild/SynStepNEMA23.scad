/**
 * This is a simulation of a SynStep stepper motor recovered from some old
 * printer.
 *
 * It's a NEMA23 motor with a pressed on gear with quite sharp teeth which
 * should work very well for moving filament.
 **/

ssShow = false;


ssBodyD = 56.4;     // NEMA23 standard body diameter
ssMountD = 47.1;    // NEMA23 standard distance between mount hole centers
ssBodyH = 38.6;     // Body height incl mount plate, excl round boss on face
ssMPlateH = 4.85;   // Mount plate height - included in body height (ssBodyH)
ssMPlateCD = 5;     // Mount plate corner diameter
ssBossH = 1.2;   // Height of boss on mount plate
ssBossD = 38;    // Diameter of boss on mount plate
ssShaftD = 6.35;    // Standard NEMA23 shaft diameter
ssShaftL = 13;    // How far the shaft protrudes above the mount plate extrusion
ssGearD = 13;   // Gear diameter
ssGearH = 10;     // Gear height - flush with end of shaft
ssMountHD = 4;    // M4 mount holes - NEMA23 spec is apparently should be 5.5mm


module SynStepNEMA23() {
    $fn = 64;
    difference() {
        union() {
            color("Silver") {
            // Main body
            cylinder(d=ssBodyD, h=ssBodyH);
            // Mount plate
            hull()
                for(x=[-ssBodyD/2+ssMPlateCD/2, ssBodyD/2-ssMPlateCD/2])
                    for(y=[-ssBodyD/2+ssMPlateCD/2, ssBodyD/2-ssMPlateCD/2])
                        translate([x, y, ssBodyH-ssMPlateH])
                            cylinder(d=ssMPlateCD, h=ssMPlateH);
            // Shaft
            cylinder(d=ssShaftD, h=ssBodyH+ssBossH+ssShaftL+0.11);
            } 
            color([140/255, 140/255, 140/255]) {
                // Extrusion on mount plate
                translate([0, 0, ssBodyH])
                    cylinder(d=ssBossD, h=ssBossH);
                // Gear
                translate([0, 0, ssBodyH+ssBossH+ssShaftL-ssGearH])
                    difference() {
                        cylinder(d=ssGearD, h=ssGearH);
                        cylinder(d=ssShaftD+0.2, h=ssGearH+0.1);
                    }
            }
        }
        // Mount holes
        for(x=[-ssMountD/2, ssMountD/2])
            for(y=[-ssMountD/2, ssMountD/2])
                translate([x, y, ssBodyH-ssMPlateH-0.1])
                    cylinder(d=ssMountHD, h=ssMPlateH+0.2);
        // Hole in bottom center
        translate([0, 0, -0.1])
            cylinder(d=ssShaftD+0.2, h=3.6);
        // Wire exit
        translate([0, -ssBodyD/2+1, 6.5])
            rotate([90, 0, 0])
            difference() {
                cylinder(d=9, h=5, center=true);
                translate([0, 4.5, 0])
                    cube([10, 10, 6], center=true);
            }
    }
}


if(ssShow)
    SynStepNEMA23();
