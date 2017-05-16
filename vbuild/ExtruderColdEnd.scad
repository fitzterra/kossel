/**
 * Extruder driver to fit onto a stepper motor recovered from an old printer: 
 * 
 * Make Step-Syn stepper made by Sanyo Denki Co. LTD.
 * Type: 103-775-0148
 * Voltage: 2.25V
 * Current: 1.5A
 * Resolution: 1.8°/step
 *
 * The motor has a press fitted gear with sharp tooth edges which could work
 * very well for moving filament. As an idler, I'll be using a 17x6x6 bearing.
 *
 * The output side will have a space for inserting a Bowden tube as filament
 * path to the hotend. The bowden tube may be held in place by an M4 nut
 * threaded onto the tube, or by a bowden connector screwed into the base.
 * Change the fitting type with the bfT variable.
 *
 * The design is based of this 'Compact Bowden Extruder, direct drive 1.75mm'
 * design on Thingiverse: https://www.thingiverse.com/thing:275593
 **/

include <chamfers.scad>
include <SynStepNEMA23.scad>

//------ Draw parameters ------//
print = true;
draw = "assembly"; // or "motor", "idler", "base", "arm", plate", "motormount"
//draw = "motor";
//draw = "idler";
draw = "base";
//draw = "arm";
draw = "plate";
//draw = "motormount";

$fn=128;

//~~~~~~~~~~~ Extruder driver params ~~~~~~~~~~
filamentD = 1.75;   // Filament diameter
mpT = 4;    // Thickness for mount plate
bowdenD = 4;    // Bowden tube diameter
feTH = 3;   // Filament entry port taper height
feTD = filamentD*2.5;   // Filament entry port taper diameter
mountHDD = 2.6; // Mount hole counter sunk depth - added allowences for tight printing
mountHD2 = 9;   // Mount hole counter sunk top diameter - added allowences for tight printing
taBC = 0.3; // Amount of clearance between tension arm and mount plate
taLC = 2;   // Amount of clearance between tension arm and left feed path block

//~~~~~~~~~~~ Bowden fitting params ~~~~~~~~~~
bfT = "nut"; // Either an M4 "nut" or a press fit "con"nector - "nut" or "con"
// ~~~ M4 Bowden Locking Nut parameters ~~~~~~
bfO = 7;    // The offset depth for the bowden tube into the edge of the base
// Total length for bowden tube fitting. Use this to give more support for the
// tube, but note that if will protrude from the base edge by (bfL-bfO)mm.
bfL = 0;
bfWT = 2;   // Thickness of the walls around the bowden fitting if bfL-bfO>0
M4id = 7;           // Inner diameter for an M4 nut (flat to flat dia)
M4od = M4id/cos(30);// Outer diameter for M4 nut (outer corner to corner)
M4T = 3.2;          // Thickness of the M4 nut
// ~~~ Bowden press fit connector parameters ~~~~~~
bcTD = 6;   // Diameter for hole into which connector will thread
bcHD = 4.85;// Depth of hole for connecgtor thread.

// ~~~~~~~~~~ Bearing parameters ~~~~~~~~~~~~~
bOD = 17;    // Outer diameter
bID = 6;     // Inner diameter
bH  = 6;     // Height
bOR = 1;     // Outer rim thickness
bIR = 1.5;   // Inner rim thickness
bsD = 6;     // Diameter of the idler bearing shaft - used for shaft holes in idler arm

// ~~~~~~~ Motor mount parameters ~~~~~~~~~~
mmT = 7;    // Mount thickness
mmWT = 4;   // Mount wall thickness
mmTol = 0.5;// Tollerance
mmBH = 5;   // Bracket height
mmBOH = 3;  // How far the bracket over hangs the oter edges

//~~~~~~~~~~ Calculations ~~~~~~~~~
filOffsY = ssGearD/2+filamentD/2; // Filament center offset from gear
filOffsZ = ssShaftL+ssBossH-ssGearH/2;      // Filament center offset on gear height
fpbW = filOffsY * 2; // Feed path block width
fpbH = ssShaftL+ssBossH; // Feed Path Block Height including mount plate thickness
efshD = ssBossD+1;   // Circular clearance around motor gear larger than motor boss
btX = ssBodyD/2-bfO; // The offset in the X direction from center where the bowden tube should start
iOffsY = (ssGearD+bOD)/2; // Idler offset in Y plane - touches gear by default
iOffsZ = filOffsZ-bH/2; // Idler offset in Z plane - idler center at filament path
taH = fpbH-mpT-taBC; // Tension arm height

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
 * Extruder base that mounts on the stepper
 **/
module ExtruderBase() {

    translate([0, 0, mpT/2])
    difference() {
        union() {
            // Mount plate
            hull()
                for(x=[-ssBodyD/2+ssMPlateCD/2, ssBodyD/2-ssMPlateCD/2])
                    for(y=[-ssBodyD/2+ssMPlateCD/2, ssBodyD/2-ssMPlateCD/2])
                        translate([x, y, 0])
                            cylinder(d=ssMPlateCD, h=mpT, center=true);
            // Filament feed path block
            translate([-ssBodyD/2, -fpbW, -mpT/2])
                cube([ssBodyD, fpbW*2, fpbH]);
            // Bowden fitting if using a nut and it needs to protrude out of
            // the base edge
            if(bfT=="nut" && (bfL-bfO)>0)
                translate([bfL/2+btX, filOffsY, -mpT/2+filOffsZ])
                    rotate([0, -90, 0])
                        cylinder(d1=bowdenD+bfWT*2, d2=(bowdenD+bfWT*2)*1.5, h=bfL, center=true);
        }
        // Flat off the bowden fitting protrution
        translate([0, -fpbW, fpbH-mpT/2])
            cube([ssBodyD, fpbW*2, 10]);
        // Sloped feed path block
        translate([0, -fpbW, mpT/2+fpbW])
            rotate([0, -90, 0])
                cylinder(r=fpbW, h=ssBodyD+0.2+20, center=true);
        // Mount holes
        for(x=[-ssMountD/2, ssMountD/2])
            for(y=[-ssMountD/2, ssMountD/2])
                translate([x, y, 0]) {
                    cylinder(d=ssMountHD, h=mpT+0.2, center=true);
                    translate([0, 0, mpT/2-mountHDD])
                        cylinder(d1=ssMountHD, d2=mountHD2, h=mountHDD+0.1);
                }
        // Hole to fit over central motor boss
        cylinder(d=efshD, h=(mpT+fpbH+0.1)*2, center=true);
        // Filament path
        translate([0, filOffsY, -mpT/2+filOffsZ]) {
            // Path
            rotate([0, -90, 0])
                cylinder(d=filamentD+0.4, h=ssBodyD+8, center=true);
            // Tappered input
            for(x=[-ssBodyD/2+feTH/2-0.1, -feTH/2+efshD/2])
            translate([x, 0, 0])
                rotate([0, -90, 0])
                    cylinder(d1=filamentD+0.4, d2=feTD, h=feTH, center=true);
        }
        // Bowden Fitting hole depending on fitting type
        if(bfT=="nut") {
            translate([btX, filOffsY, -mpT/2+filOffsZ]) {
                rotate([0, 90, 0])
                    cylinder(d=bowdenD+0.4, h=bfO+bfL+0.1);
                translate([0, -bowdenD/2-0.2, 0])
                    cube([bfO+bfL+0.1, bowdenD+0.4, fpbH]);
                rotate([0, 90, 0])
                    cylinder(d=M4od+0.4, h=M4T+0.4, $fn=6);
                translate([0, -M4id/2-0.2, 0])
                    cube([M4T+0.4, M4id+0.4, fpbH]);
            }
        } else {
            // Its a press fit connector
            translate([ssBodyD/2+0.1, filOffsY, -mpT/2+filOffsZ])
                rotate([0, -90, 0])
                    cylinder(d=bcHD, h=bcTD+0.2, center=false);
        }
        // Tension arm round cutout
        translate([0, iOffsY*2, mpT/2])
            cylinder(d=bOD*2.8, h=fpbH+0.1);
        // Tension bolt hole
        translate([-ssBodyD/2+(ssBodyD-ssBossD)/4, filOffsY+3, fpbH/2])
            rotate([-90, 0, 0])
                cylinder(d=3, h=ssBodyD/2+0.2);
    }
}

/**
 * The arm the tension idler attaches to.
 *
 * @param zH: The z position. Default to lift the arm to taBC above the base
 *            to make it easier to show an assembly. Set to 0 when printing.
 **/
module TensionArm(zH=mpT+taBC) {
    iC = 0.6;   // Amount of clearance above and below idler bearing

    // Lift it up if needed
    translate([0, 0, zH]) {
    difference() {
        union() {
            hull() {
                // Just the base block for the lower part of the hull
                translate([-ssBodyD/2, fpbW+taLC, 0])
                    cube([ssBodyD, taLC, taH]);
                // The rounded corners for the upper hull points
                for(x=[-ssBodyD/2+ssMPlateCD/2, ssBodyD/2-ssMPlateCD/2])
                    translate([x, ssBodyD/2-ssMPlateCD/2, 0])
                        cylinder(d=ssMPlateCD, h=taH);
            }
            // The idler bearing fitment area
            translate([0, iOffsY*2, 0])
                scale([0.7, 1, 1])
                cylinder(d=bOD*2.7, h=taH);

        }
        // Cut off excess from idler bearing fitment area
        translate([-ssBodyD/2, ssBodyD/2, -0.1])
            cube([ssBodyD, bOD*2.6, taH+0.2]);
        // Idler shaft holes
        translate([0, iOffsY, taH/2])
            cylinder(d=bsD, taH+2, center=true);
        // Pivot hole
        translate([ssMountD/2, ssMountD/2, -0.1])
            cylinder(d=ssMountHD, h=taH+0.2);
        // The idler fitment area with iC clearence top and bottom
        translate([0, iOffsY, taH/2]) {
            cylinder(d=bOD+4, h=bH+iC*2, center=true);
        }
        // Tension bolt hole
        translate([-ssBodyD/2+(ssBodyD-ssBossD)/4, 0, (fpbH-mpT)/2-taBC])
            rotate([-90, 0, 0])
            hull() {
                translate([-0.75, 0, 0])
                    cylinder(d=3, h=ssBodyD/2+0.2);
                translate([0.75, 0, 0])
                    cylinder(d=3, h=ssBodyD/2+0.2);
            }
        // Top indicator
        translate([0, ssBodyD/2-5, taH-0.5])
            linear_extrude(1.5)
                text("CompactFeed", size=4, font="DejaVu Sans:style=Book", halign="center", valign="center");
    }
    // Built in idler washers
    for(z=[(taH-bH)/2-iC, taH-(taH-bH)/2+iC])
        translate([0, iOffsY, z])
            mirror([0, 0, z>taH/2?1:0])
                difference() {
                    cylinder(d1=bID+bIR*4, d2=bID+bIR, h=iC-0.1);
                    translate([0, 0, -0.1])
                        cylinder(d=bsD, h=iC+0.2);
                }
    }
}

/**
 * Mount bracket that fits around motor to mount it to the top of the printer.
 **/
module MotorMount() {
    bs = 1; // How much to shave off the bottom when opening the mount ring
    ccw = ssBodyD/1.5; // How wide to make the center cut at the bottom

    difference() {
        union() {
            // Main body hoop stock
            cylinder(d=ssBodyD+mmWT+mmTol, h=mmT);
            // Bracket
            translate([ssBodyD/2-mmBH-bs, -ssBodyD/2-mmWT-mmTol-mmBOH, 0])
                cube([mmBH+bs, (mmWT+mmTol+mmBOH)*2+ssBodyD, mmT]);
            translate([ssBodyD/2-ssBodyD/3, -ssBodyD/2, 0])
                cube([ssBodyD/3, ssBodyD, mmT]);
            // Chamfer the foot edges
            for(y=[-ssBodyD/2-2, ssBodyD/2+2])
                translate([ssBodyD/2-mmBH-bs-2, y, 0])
                    // Top chamfer should be rotated
                    rotate([0, 0, y>0?-90:0])
                        chamfer(mmT, 2, 16);
        }
        // Cutout motor
        translate([0, 0, -0.1])
            cylinder(d=ssBodyD+mmTol, h=mmT+0.2);
        // Shave off the bottom to allow space for pulling the bracket tight
        translate([ssBodyD/2-bs, -ssBodyD/2-mmWT-mmTol-mmBOH-1, -0.1])
            cube([mmWT+bs*2, (mmWT+mmTol+mmBOH)*2+ssBodyD+2, mmT+0.2]);
        // Cut out the center
        translate([0, -ccw/2, -0.1])
            cube([ssBodyD, ccw, mmT+0.2]);
        // Mount holes
        for(y=[1, -1])
            translate([ssBodyD/2+bs, (-ssBodyD/2-mmWT-mmTol-mmBOH+2+1.5)*y, mmT/2])
                rotate([0, -90, 0])
                cylinder(d=3, h=mmBH+bs*2+2);
        
    }
    
}

/**
 * Module to show the full assembly
 **/
module Assembly() {
    // The motor
    translate([0, 0, -ssBodyH])
        SynStepNEMA23();

    // The idler bearing
    translate([0, iOffsY, iOffsZ])
        Bearing();

    // A piece of filament
    color("cyan")
        translate([0, filOffsY, filOffsZ])
            rotate([0, -90, 0])
                cylinder(d=filamentD, h=ssBodyD*2, center=true);
    // A piece of Bowden tubing`
    color("white", 0.8)
        translate([bfT=="nut"?btX:(ssBodyD/2+5), filOffsY, filOffsZ])
            rotate([0, 90, 0])
                cylinder(d=bowdenD, h=20);
    // M4 lock nut if not using a bowden connector
    if(bfT=="nut")
    color("silver", 0.8)
        translate([btX, filOffsY, filOffsZ])
            rotate([0, 90, 0])
                cylinder(d=M4od, h=M4T, $fn=6);
    
    color("lime") {
    // The base
    ExtruderBase();
    // The tension arm
    TensionArm();
    // The motor mount
    translate([0, 0, -mmT-ssMPlateH-10])
    MotorMount();
    }
}


if(draw=="assembly")
    Assembly();
else if(draw=="motor")
    SynStepNEMA23();
else if(draw=="idler")
    Bearing();
else if(draw=="base")
    ExtruderBase();
else if(draw=="arm")
    // Move and rotate if we need to print
    translate([0, 0, print?ssBodyD/2:0])
        rotate([print?-90:0, 0, 0])
            TensionArm(print?0:1);
else if(draw=="motormount")
    MotorMount();
else if(draw=="plate") {
    ExtruderBase();
    translate([ssBodyD-15, 0, ssBodyD/2])
        rotate([-90, 0, -90])
            TensionArm(0);
}

