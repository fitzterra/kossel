// The effector with magneticly detachable z-probe.

$fn=64;

use <effector_e3d.scad>

print = false;       // Draw for printing
probeTop = true;
probeBot = true;
probeCradle = true;
probeCradMount = true;
assembly = true;    // Show assembly to effector


/**
 * A microswitch activated probe that sits in a cradle attached to the frame
 * until needed. The probe has two magnets at the top, that lines up to two
 * magnets in a top bar that attaches to the bottom of the effector. When the
 * probe is needed, the effector moves to slightly above the probe to allow the
 * two sets of magnets to attract each other and connect the probe to the
 * effector. The magnets are also the electrical connection between the
 * microswitch and the probe cable running to the effector.
 * To return the probe to the cradle, the effector moves the probe to above the
 * cradle, lowers it into the cradle then moves away at the same Z level to
 * allow the cradle to pull the probe off the effector.
 *
 * @param top: Draw the probe top that attaches to the effector
 * @param bottom: Draw the probe bottom that houses the microswitch
 * @param cradle: Draw the cradle for storing the probe bottom
 * @param bracket: Draw the cradle bracket that attaches to the extrusion frame
 * @param print: Layout out as a plate for printing
 * @param assemble: Layout to show assembly
 *
 * Note: If both print and assembly are false, the requested parts are simply
 * all shown.
 **/
module ZProbe(top=true, bottom=true, cradle=true, bracket=true, print=true, assemble=false) {
    w = 28;         // Total width
    d = 8;          // Total depth

    magDia = 6;     // diameter for magnets
    magR = 1.1;     // Mag thickness - 0.1 for additional tollerence
    magTol = 0.2;   // Magnet diameter tollerence
    magC2C = 20;    // Center to center for the magnets

    topH = 3;       // Height for the top mount
    topMountDia = 3;// Dimeter for the top mount hole
    
    botH = 20;      // Total height for the bottom part
    barH = 6;       // Height of the bar to mount the switch
    recW = 16;      // Width of the recess in the bar for the switch
    recD = 3;       // Depth for this recess
    mntSlotH = 3.5; // Height for center of mount slot in bar from bottom
    mntSlotW = 10;  // Width of the total mount slot - end rounds center to center
    mntSlotDia = 2.2;// Diameter of the mount slot

    cradClearance = 2;   // Total clearance all round for cradle
    cradWallT = 2;       // Cradle wall thickness
    cradBoltD1 = 4;      // Shaft diameter for mounting bolt
    cradBoltD2 = 7.4;      // Top diameter for mounting bolt countersunk head
    cradBoltHeadH = 2.5; // Height for mount bolt countersunk head

    m3 = 3;         // M3 screw hole size;

    // Extra length in both X and Y for cradle over probe base/top
    cradExtra = cradWallT*2+cradClearance*2;
    // Length for cradle bracket on extrusion:
    // 2mm clearance on the edge, m3 hole for mounting to the extrusion, 5mm
    // clearance to edge of mount bolt hole, then the mount bolt hole and the
    // same clearances and holes to the other side.
    cradBracketL = 2 + m3 + 5 + cradBoltD1 + 5 + m3 + 2;

    extrusion = 15;     // Extrusion size for the cradle mount bracket


    module Top() {
        difference() {
            // The base block
            cube([w, d, topH]);
            // Mount hole
            translate([w/2, d/2, -1])
                cylinder(d=topMountDia, h = topH+2);
            // Magnet recesses
            for(x=[(w-magC2C)/2, w-(w-magC2C)/2])
                translate([x, d/2, topH-magR]) {
                    cylinder(d=magDia+2*magTol, h=magR+1);
                    translate([0, 0, -2])
                        cylinder(d1=2, d2=magDia/1.5, h=2.1);
                    translate([0, -d/4-0.2, magR-topH/2])
                        cube([2, d/2, topH+2], center=true);
                }

        }
    }

    module Bottom() {
        colW = w-magC2C;    // Width of the U columns

        difference() {
            // The master stock to work from
            cube([w, d, botH]);
            // Cut out the middle to form the U
            translate([colW, -1, barH])
                cube([w-colW*2, d+2, botH]);
            // Recess in the bar for the switch
            translate([(w-recW)/2, -1, -1])
                cube([recW, recD+1, barH+1]);
            // The switch mount slot
            for(x=[(w-mntSlotW)/2, w-(w-mntSlotW)/2])
                translate([x, -1, mntSlotH])
                    rotate([-90, 0, 0])
                        cylinder(d=mntSlotDia, h=d+2);
            translate([(w-mntSlotW)/2, -1, mntSlotH-mntSlotDia/2])
                cube([mntSlotW, d+2, mntSlotDia]);
            // Magnet recesses
            for(x=[(w-magC2C)/2, w-(w-magC2C)/2])
                translate([x, d/2, botH-magR]) {
                    cylinder(d=magDia+2*magTol, h=magR+1);
                    translate([0, 0, -2])
                        cylinder(d1=2, d2=magDia/1.5, h=2.1);
                    translate([0, -d/4-0.2, magR-topH/2])
                        cube([2, d/2, topH+0.2], center=true);
                }
        }
    }

    module Cradle() {
        w = w + cradExtra;    // Total width
        h = botH + cradWallT; // Height only as high as the bottom
        d = d + cradExtra;    // Total depth
        swCutD = cradWallT+cradClearance+recD;    // Depth for switch cutout in bottom

        difference() {
            // Base stock for cradle
            cube([w, d, h]);
            // Cutout for switch
            translate([w/4, -1, cradWallT])
                cube([w/2, d+2, h]);
            translate([w/4, -1, -1])
                cube([w/2, swCutD+1, cradWallT+2]);
            // Middle cutout
            translate([cradWallT, cradWallT, cradWallT])
                cube([w-cradWallT*2, d-cradWallT*2, h]);
            // Hole for mount bolt
            translate([w/2, swCutD+(d-swCutD)/2, cradWallT-cradBoltHeadH+0.1])
                cylinder(d1=cradBoltD1, d2=cradBoltD2, h=cradBoltHeadH);
        }
    }

    module CradleExtrusionBracket() {
        w = extrusion;      // Width
        l = cradBracketL;    // Bracket length
        h = cradWallT;       // Height

        difference() {
            // Main bracket stock
            union() {
                cube([l, w, h]);
                translate([l/2, w/2, h])
                    cylinder(d=m3+4, h=cradWallT*2);
            }
            // Bolt hole
            translate([l/2, w/2, -1])
                cylinder(d=cradBoltD1-0.2, h=h+cradWallT*2+2);
            // Holes for extrusion
            for(x=[2+m3/2, l-2-m3/2])
                translate([x, w/2, -1])
                    cylinder(d=m3, h=h+2);
        }

    }

    // Layout for printing?
    if(print) {
        if(top)
            translate([0, -d-5, 0])
                Top();
        if(bottom)
            // Prints best on it's side
            translate([0, 0, d])
                rotate([-90, 0, 0])
                    Bottom();
        if(cradle)
            translate([-d-cradExtra-5, (w+cradExtra)/2, 0])
                rotate([0, 0, -90])
                    Cradle();
        if(bracket)
            translate([-d-cradExtra-5-extrusion-5, cradBracketL/2, 0])
                rotate([0, 0, -90])
                    CradleExtrusionBracket();

    } else if (assemble) {
        // Show assembly
        if(top)
            translate([-w/2, d/2, 0])
            rotate([180, 0, 0])
            Top();
        translate([0, 0, -topH-0.2-botH]) {
            if(bottom)
                translate([-w/2, -d/2, 0])
                Bottom();
            translate([0, 0, -cradWallT-5]) {
                if(cradle)
                    translate([-(w+cradExtra)/2, -(d+cradExtra)/2, 0])
                        Cradle();
                if(bracket)
                    translate([-cradBracketL/2, -d/2, -20]) {
                        CradleExtrusionBracket();
                        // The bolt and nut
                        color("silver")
                            translate([cradBracketL/2, extrusion/2, 0]) {
                                cylinder(d=cradBoltD1, h=20);
                                translate([0, 0, 20+(cradWallT-cradBoltHeadH)])
                                    cylinder(d1=cradBoltD1, d2=cradBoltD2, h=cradBoltHeadH);
                                translate([0, 0, 20-3.5])
                                    cylinder(d=cradBoltD1*2, h=3.5, $fn=6);
                            }
                    }
            }
        }
    } else {
        // Just show all parts.
        if(top)
            translate([0, d+10, 0])
            Top();
        if(bottom)
            translate([0, 5, 0])
            Bottom();
        if(cradle)
            translate([0, -5-d-cradExtra, 0])
            Cradle();
        if(bracket)
            translate([0, -5-d-cradExtra-5-extrusion, 0])
            CradleExtrusionBracket();
    }

}

if (print) {
    ZProbe(top=probeTop, bottom=probeBot, cradle=probeCradle, bracket=probeCradMount);
} else if (assembly) {
    translate([0, 0, 5])
        rotate([0, 0, 0])
            EffectorE3D();

    translate([0, -23, 0])
        rotate([0, 0, 180])
            ZProbe(print=false, assemble=true);
} else {
    ZProbe(top=probeTop, bottom=probeBot, cradle=probeCradle,
               bracket=probeCradMount, print=false, assemble=false);
}
