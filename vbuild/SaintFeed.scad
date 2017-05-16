/**
 * Experimentations with a SaintFeed type feeder for a Nema23 size motor.
 * Getting the correct taper on the thread end onto which the adjustment ring
 * fits, is the reason this feeder is not in use. Maybe I'll spend some more
 * time on it in the future :-)
 **/

include <chamfers.scad>
// Threads lib by Dan Kirshner from here: http://dkprojects.net/openscad-threads/
include <threads.scad>
include <SynStepNEMA23.scad>

// ~~~~~~~~~~ Bearing parameters ~~~~~~~~~~~~~
bOD = 17;    // Outer diameter
bID = 6;     // Inner diameter
bH  = 6;     // Height
bOR = 1;     // Outer rim thickness
bIR = 1.5;   // Inner rim thickness

// ~~~ M4 Bowden Locking Nut parameters ~~~~~~
M4id = 7;           // Inner diameter for an M4 nut (flat to flat dia)
M4od = M4id/cos(30);// Outer diameter for M4 nut (outer corner to corner)
M4T = 3.2;          // Thickness of the M4 nut

//~~~~~~~~~~~ Feeder and Ring params ~~~~~~~~~~
filamentD = 1.75;   // Filament diameter
bowdenD = 4;    // Bowden tube diameter
baseH = bH+6;     // Base height is the bearing height plus some
ringW = 7;          // Width of the tension ring
ringH = 3;          // Height of the ring wall - thread to to outer wall
adjTL = ringW+5;    // Length of adjustment thread on base
adjW = 2;           // Total width of adjustment to allow
filDrvClear = -0.2;    // Clearance for filament between gear and idlers
bXOffs = (ssGearD+bOD)/2 + filamentD + filDrvClear; // Bearing center offset in the X plane
bHClear = 2;        // Horizontal clearance around bearings
bVClear = 1;        // Vertical clearance around bearings
bowdenIS = M4T+5;   // How deep the bowden tubes are inset into the filament path
// Since the bearings being used can be secured with an M6 bolts, we will
// create holes to be tapped for M6 bolts. This is the drill/hole diameter
// for M6 taps.
M6TapD = 5.5;

//~~~~~~~~~~ Calculations ~~~~~~~~~
filPathX = (ssGearD+filamentD)/2+filDrvClear;    // Filament path offset from X
filPathZ = baseH/2; // Filament path on Z level - center of extruder
ringID = filPathX*2+M4od+5; // Tension ring inner diameter

/**
 * The idler bearings.
 **/
module Bearing() {
    od = bOD;    // Outer diameter
    id = bID;     // Inner diameter
    h  = bH ;      // Height
    or = bOR;     // Outer rim thickness
    ir = bIR;   // Inner rim thickness

    translate([0, 0, h/2]) {
        color("silver")
        difference() {
            cylinder(d=od, h=h, center=true);
            cylinder(d=id, h=h+0.2, center=true);
            for(z=[h/2-1, -h/2-0.5])
                translate([0, 0, z])
                difference() {
                    cylinder(d=od-2*or, h=1.5);
                    cylinder(d=id+2*ir, h=1.5);
                }
        }
        color([40/255, 40/255, 40/255])
        for(z=[h/2-1, -h/2+0.2])
            translate([0, 0, z])
            difference() {
                cylinder(d=od-2*or, h=0.8);
                cylinder(d=id+2*ir, h=0.8);
            }
    }

}

/**
 * Adjustment ring from the the SaintFeed gets it's name :-)
 **/
module SaintRing() {
    letters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"];
    
    difference() {
        cylinder(d=ringID+2*ringH, h=ringW);
        translate([0, 0, ringW-1.5])
            cylinder_chamfer((ringID+2*ringH)/2, 2, 1);
        translate([0, 0, 2-0.5])
            rotate([180, 0, 0])
                cylinder_chamfer((ringID+2*ringH)/2, 2, 1);
        metric_thread(diameter=ringID, pitch=adjTL/3, length=adjTL, internal=true);

        // Knurled slots
        for(r=[0:22.5:359])
            rotate([0, 0, r])
                translate([ringID/2+ringH+1, 0, ringW/2])
                    scale([1.4, 1, 1])
                    rotate([0, 0, 45])
                        cube([2, 2, ringW+0.2], center=true);

        // Letters
        for(r=[22.5/2:22.5:359]) {
            rotate([0, 0, r])
                translate([0, -ringID/2-ringH+0.5, ringW/2])
                    rotate([90, 0, 0])
                        linear_extrude(2)
                            text(letters[(r-22.5/2)/22.5], font="DejaVu Sans", size=ringW-4, halign="center", valign="center");
        }
    }

}

module SaintFeed(sRing=false, sFil=false, sIdlers=false) {
    difference() {
        union() {
            // Adjustment threaded base
            translate([0, -ssBodyD/2-adjTL, baseH/2])
                rotate([-90, 0, 0])
                intersection() {
                    metric_thread(diameter=ringID, pitch=adjTL/3, length=adjTL, taper=-adjW/adjTL);
                    translate([-ringID/2-2, -baseH/2, 0])
                        cube([ringID+4, baseH, adjTL]);
                }

            // The base
            // Adjust this inset to bring the mid point of the base closer or
            // further from the motor edges. 0 puts it on the edge.
            inset=6;
            hull() {
                for(x=[-ssBodyD/2+ssMPlateCD/2, ssBodyD/2-ssMPlateCD/2])
                    for(y=[0, ssBodyD/2-ssMPlateCD/2])
                        translate([y>0?x:x+inset*(x>0?-1:1), y, baseH/2])
                            cylinder(d=ssMPlateCD, h=baseH, center=true);
                 translate([-ringID/2-2, -ssBodyD/2, 0])
                    cube([ringID+4, 0.1, baseH]);
            }
        }

        // Pivot holes
        for(x=[ssMountD/2, -ssMountD/2])
            translate([x, ssMountD/2, -0.1]) {
                cylinder(d=ssMountHD, h=baseH+0.2);
            }

        // Cut it into two section
        translate([-adjW/2, -ssBodyD/2-adjTL-0.1, -0.1])
            cube([adjW, ssBodyD+adjTL+0.2, baseH+0.2]);

        // Space around the drive gear
        translate([0, 0, filPathZ-0.1])
            cylinder(d1=ssGearD+filamentD, d2=ssGearD*1.8, h=baseH/2+0.2);
        translate([0, 0, -0.1])
            cylinder(d1=ssGearD*1.8, d2=ssGearD+filamentD, h=baseH/2+0.2);
        cylinder(d=(filPathX)*2+0.8, h=baseH);

        // Bearing cavities and Bolt tap holes
        for(x=[-bXOffs, bXOffs])
            translate([x, 0, 0]) {
                translate([0, 0, filPathZ-bH/2-bVClear])
                    cylinder(d=bOD+bHClear*2, h=bH+bVClear*2);
                translate([0, 0, -0.1])
                    cylinder(d=M6TapD, h=baseH+0.2);
            }
        // Filament path
        for(x=[-filPathX, +filPathX])
            translate([x, 0, filPathZ])
                rotate([-90, 0, 0])
                    cylinder(d=filamentD+0.2, h=ssBodyD+adjTL*2+2, center=true);
        // Bowden tube holes
        for(y=[ssBodyD/2+0.2, -ssBodyD/2-adjTL+bowdenIS])
            // If we mirror, we need to adjust the Y
            translate([-filPathX, y>0?y-bowdenIS:y, filPathZ])
                // We need to mirror one side
                mirror([0, y>0?1:0, 0])
                    rotate([90, 0, 0]) {
                        hull() {
                            cylinder(d=bowdenD, h=bowdenIS+0.1);
                            translate([filPathX*2, 0, 0])
                                cylinder(d=bowdenD, h=bowdenIS+0.1);
                        }
                        // Additional tapered holes to guide the filament from the tube
                        // to the housing, and grooves for M4 nuts
                        for(x1=[0, filPathX*2]) {
                            translate([x1, 0, -2])
                                cylinder(d2=filamentD*2, d1=filamentD, h=2);
                            translate([x1, 0, 0.3])
                                cylinder(d=M4od+0.5, h=M4T, $fn=6);
                        }
                        // Make sure nut grooves goes to edges
                        translate([0, -M4id/2-0.25, 0.3])
                            cube([filPathX*2, M4id+0.5, M4T]);
                    }
    }
    // Bearing positioning flanges
    for(x=[-bXOffs, bXOffs])
        difference () {
            union() {
                translate([x, 0, filPathZ-bH/2-bVClear])
                    cylinder(d1=bID+bIR*3, d2=bID+bIR-0.4, h=bVClear-0.2);
                translate([x, 0, filPathZ+bH/2+0.2])
                    cylinder(d2=bID+bIR*3, d1=bID+bIR-0.4, h=bVClear-0.2);
            }
            translate([x, 0, -0.1])
                cylinder(d=M6TapD, h=baseH+0.2);
    }

    // Show the adjustment ring if needed
    if(sRing)
        translate([0, -ssBodyD/2-adjTL/3, baseH/2])
            rotate([90, 0, 0])
                SaintRing();
    // Show the idler bearings if needed
    if(sIdlers)
        for(x=[-bXOffs, bXOffs])
            translate([x, 0, filPathZ-bH/2])
                Bearing();
    // Sample filament if required
    if(sFil)
        for (x=[-filPathX, +filPathX])
            translate([x, 0, filPathZ])
                rotate([-90, 0, 0])
                    color("cyan")
                    cylinder(d=1.75, h=ssBodyD+adjTL*2+4, center=true);


}

module ssAssembly() {
    SaintFeed(true, true, true);
    translate([0, 0, -ssBodyH-ssBossH])
        SynStepNEMA23();
}


module RingAndGroove(ring=true, groove=true, print=true) {
        
        if(ring) {
            translate([print?ringID+10:0, 0, print?0:adjTL/2-3])
                difference() {
                    cylinder(d=ringID+4, h=6);
                    translate([0, 0, -0.1])
                    metric_thread(diameter=ringID+1, pitch=adjTL/3, length=adjTL, internal=true);
                }
        }

        if(groove) {
            metric_thread(diameter=ringID, pitch=adjTL/3, length=adjTL, taper=-adjW/adjTL);
        }
}

ssAssembly();
*SaintFeed();
*SaintRing();
*RingAndGroove(true, false, true);
