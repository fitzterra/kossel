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
 * very well for moving filament. As an idler roller, I'll be useing a little
 * metal roller from and old hard drive. The roller has an rubber sleeve around
 * the outer diameter that could work nicely to keep enough friction between
 * filament and gear. I'm just not sure the rubber sleeve will hold up for too
 * long. Will have to see :-)
 *
 * The output side will have a space for inserting a Bowden tube as filament
 * path to the hotend.
 *
 * The design is based of this 'Compact Bowden Extruder, direct drive 1.75mm'
 * design on Thingiverse: https://www.thingiverse.com/thing:275593
 **/

//------ Draw parameters ------//
draw = "assembly"; // or "motor", "roller", "base", "arm", plate"
//draw = "motor";
//draw = "roller";
//draw = "base";
//draw = "arm";
//draw = "plate";


$fn=128;

//~~~~~~~~~~~ Extruder driver params ~~~~~~~~~~
filamentD = 1.75;   // Filament diameter
mpT = 4;    // Thickness for mount plate
bowdenD = 4;    // Bowden tube diameter
bfL = 12;   // Total length for bowden tube fitting
bfO = 3;    // The offset from the edge of the feed path to the start of the bowden tube
bfWT = 3;   // Thickness of the walls around the bowden fitting
feTH = 3;   // Filament entry port taper height
feTD = filamentD*2.5;   // Filament entry port taper diameter
fpb2a = 2;   // Spacing from feed path block to roller arm

//~~~~~~~~~ Stepper parameters ~~~~~~~~~~~~
bodyD = 56.5; // Body diameter
bodyH = 38.6; // Body height incl mount plate, excl extrusion around shaft
mPlateH = 4.85; // Mount plate height - included in body height (bodyH)
mPlateCD = 5;   // Mount plate corner diameter
mPlateEH = 1.2;   // Height of extrusion on mount plate
mPlateED = 38;   // Diameter of extrusion on mount plate
shaftD = 6.3;   // Shaft diameter
shaftL = 13;    // How far the shaft protrudes above the mount plate extrusion
gearD = 13.2;   // Gear diameter
gearH = 10;     // Gear height - flush with end of shaft
mountHD = 4;    // M4 mount holes
mountHO = 4.5;  // Mount hole center offset from both edges
mountHDD = 2.6; // Mount hole counter sunk depth - added allowences for tight printing
mountHD2 = 8;   // Mount hole counter sunk top diameter - added allowences for tight printing

// ~~~~~~~~~~ Roller parameters ~~~~~~~~~~~~~
rOD = 12.3;  // Main OD
rH = 7;      // Main height without shaft
rSOD = 6.4;  // Shaft OD
rSH = 2.8;   // Shaft height
rID = 3.2;   // ID
rRW = 1.85;  // Recess width
rRD = 0.7;   // Recess depth
rSW = 1.2;   // Outer shell width
rSRW = 1.55; // Outer shell ridge width
rSRH = 1.4;  // Outer shell ridge height
rSD = 2.9;   // Diameter of shaft axel for roller
rFOD = rOD+rSW*2;  // Roller full OD including outer shell
rFROD = rOD + rSRW*2;// Roller full OD on the ridge on the outer shell`

//~~~~~~~~~~ Calculations ~~~~~~~~~
filOffsY = gearD/2+filamentD/2; // Filament center offset from gear
filOffsZ = shaftL+mPlateEH-gearH/2;      // Filament center offset on gear height
fpbW = filOffsY * 2; // Feed path block width
fpbH = shaftL+mPlateEH; // Feed Path Block Height including mount plate thickness
efshD = mPlateED+1;   // THe main feeder hole must fit over the raised bit around the motor shaft
btX = efshD/2+bfO; // The offset in the X direction from center where the bowden tube should start
rlrOffsY = (gearD+rFROD)/2; // Roller offset from center of gear in Y plane
rlrOffsZ = mPlateEH+shaftL-(rH+gearH)/2; // Roller offset from motor face plate in Z plane
raH = (rlrOffsZ-mpT)*2+rH+rSH; // Roller arm height

/**
 * Simulates the StepSyn stepper motor.
 ***/
module StepSynStepper() {
    difference() {
        union() {
            color("Silver") {
            // Main body
            cylinder(d=bodyD, h=bodyH);
            // Mount plate
            hull()
                for(x=[-bodyD/2+mPlateCD/2, bodyD/2-mPlateCD/2])
                    for(y=[-bodyD/2+mPlateCD/2, bodyD/2-mPlateCD/2])
                        translate([x, y, bodyH-mPlateH])
                            cylinder(d=mPlateCD, h=mPlateH);
            // Shaft
            cylinder(d=shaftD, h=bodyH+mPlateEH+shaftL);
            } // color
            color([140/255, 140/255, 140/255]) {
            // Extrusion on mount plate
            translate([0, 0, bodyH])
                cylinder(d=mPlateED, h=mPlateEH);
            // Gear
            translate([0, 0, bodyH+mPlateEH+shaftL-gearH])
                difference() {
                    cylinder(d=gearD, h=gearH);
                    cylinder(d=shaftD+0.2, h=gearH+0.1);
                }
            }
        }
        // Mount holes
        for(x=[-bodyD/2+mountHO, bodyD/2-mountHO])
            for(y=[-bodyD/2+mountHO, bodyD/2-mountHO])
                translate([x, y, bodyH-mPlateH-0.1])
                    cylinder(d=mountHD, h=mPlateH+0.2);
        // Hole in bottom center
        translate([0, 0, -0.1])
            cylinder(d=shaftD+0.2, h=3.6);
        // Wire exit
        translate([0, -bodyD/2+1, 6.5])
            rotate([90, 0, 0])
            difference() {
                cylinder(d=9, h=5, center=true);
                translate([0, 4.5, 0])
                    cube([10, 10, 6], center=true);
            }
    }
}

/**
 * This is a roller than comes from an old hard drive that may be usable as the
 * filament guide/idler roller.
 **/
module Roller() {

    // Main roller part
    color("Silver")
    difference() {
        union() {
            // Main body
            cylinder(d=rOD, h=rH);
            // Protruding shaft
            translate([0, 0, rH])
                cylinder(d=rSOD, h=rSH);
        }
        // Drill shaft hole
        translate([0, 0, -0.1])
            cylinder(d=rID, h=rH+rSH+0.2);
        // Cut out central recess ring
        translate([0, 0, rH/2])
            difference() {
                cylinder(d=rOD+1, h=rRW, center=true);
                cylinder(d=rOD-rRD*2, h=rRW, center=true); 
            }
    }
    // Outer shell
    color("tan", 0.9)
    difference() {
        union() {
            // The main shell, slightly smaller than the roller to avoid the
            // openSCAD artefacts in preview
            translate([0, 0, 0.01])
                cylinder(d=rFOD, h=rH-0.02);
            // The top lip
            translate([0, 0, rH-rSRH-0.01])
                cylinder(d=rFROD, h=rSRH);
        }
        // Cut out the inner part for the roller
        translate([0, 0, -1])
            cylinder(d=rOD, h=rH+2);
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
                for(x=[-bodyD/2+mPlateCD/2, bodyD/2-mPlateCD/2])
                    for(y=[-bodyD/2+mPlateCD/2, bodyD/2-mPlateCD/2])
                        translate([x, y, 0])
                            cylinder(d=mPlateCD, h=mpT, center=true);
            // Filament feed path block
            translate([-bodyD/2, -fpbW, -mpT/2])
                cube([bodyD, fpbW*2, fpbH]);
            // Bowden fitting
            translate([bfL/2+btX, filOffsY, -mpT/2+filOffsZ])
                rotate([0, -90, 0])
                    cylinder(d1=bowdenD+bfWT*2, d2=(bowdenD+bfWT*2)*1.5, h=bfL, center=true);
        }
        // Flat off the bowden fitting protrution
        translate([0, -fpbW, fpbH-mpT/2])
            cube([bodyD, fpbW*2, 10]);
        // Sloped feed path block
        translate([0, -fpbW, mpT/2+fpbW])
            rotate([0, -90, 0])
                cylinder(r=fpbW, h=bodyD+0.2+20, center=true);
        // Mount holes
        for(x=[-bodyD/2+mountHO, bodyD/2-mountHO])
            for(y=[-bodyD/2+mountHO, bodyD/2-mountHO])
                translate([x, y, 0]) {
                    cylinder(d=mountHD, h=mpT+0.2, center=true);
                    translate([0, 0, mpT/2-mountHDD])
                        cylinder(d1=mountHD, d2=mountHD2, h=mountHDD+0.1);
                }
        // Hole to fit over central extrusion
        cylinder(d=efshD, h=(mpT+fpbH+0.1)*2, center=true);
        // Filament path
        translate([0, filOffsY, -mpT/2+filOffsZ]) {
            // Path
            rotate([0, -90, 0])
                cylinder(d=filamentD+0.4, h=bodyD+8, center=true);
            // Tappered input
            for(x=[-bodyD/2+feTH/2-0.1, -feTH/2+efshD/2])
            translate([x, 0, 0])
                rotate([0, -90, 0])
                    cylinder(d1=filamentD+0.4, d2=feTD, h=feTH, center=true);
        }
        // Bowden Fitting hole
        translate([bfL/2+btX, filOffsY, -mpT/2+filOffsZ]) {
            rotate([0, -90, 0])
                cylinder(d=bowdenD, h=bfL+0.1, center=true);
            translate([-bfL/2, -(bowdenD-0.6)/2, 0])
            cube([bfL+0.1, bowdenD-0.6, bowdenD+bfWT*2]);
        }
        // Roller arm round cutout
        translate([0, rlrOffsY*2, mpT/2])
            cylinder(d=rFOD*3, h=fpbH+0.1);
        // Tension bolt hole
        translate([-bodyD/2+(bodyD-mPlateED)/4, filOffsY+3, fpbH/2])
            rotate([-90, 0, 0])
                cylinder(d=3, h=bodyD/2+0.2);
    }
}

/**
 * The arm the tension roller attaches to.
 *
 * @param zH: The z position. Default to lisft the arm to just above the base
 *            to make it easier to show an assembly. Set to 0 when printing.
 **/
module RollerArm(zH=mpT+0.2) {
    
    // Lift it up if needed
    translate([0, 0, zH])
    difference() {
        union() {
            hull() {
                // Just the base block for the lower part of the hull
                translate([-bodyD/2, fpbW+2, 0])
                    cube([bodyD, fpb2a, raH]);
                // The rounded corners for the upper hull points
                for(x=[-bodyD/2+mPlateCD/2, bodyD/2-mPlateCD/2])
                    translate([x, bodyD/2-mPlateCD/2, 0])
                        cylinder(d=mPlateCD, h=raH);
            }
            // The roller fitment area
            translate([0, rlrOffsY*2, 0])
                cylinder(d=rFOD*2.8, h=raH);

        }
        // Cut off excess from roller fitment area
        translate([-bodyD/2, bodyD/2, -0.1])
            cube([bodyD, rFOD*2.8, raH+0.2]);
        // Pivot hole
        translate([bodyD/2-mountHO, bodyD/2-mountHO, -0.1])
            cylinder(d=mountHD, h=raH+0.2);
        // The roller fitment area with 0.4mm clearence top and bottom
        translate([0, rlrOffsY, raH/2]) {
            cylinder(d=rFOD+4, h=rH+rSH+0.8, center=true);
            translate([0, -rFOD/4, 0])
                cube([rFOD+4, rFOD/2, rH+rSH+0.8], center=true);
        }
        // Roller shaft holes
        translate([0, rlrOffsY, raH/2])
            cylinder(d=rSD, raH+2, center=true);
        // Tension bolt hole
        translate([-bodyD/2+(bodyD-mPlateED)/4, 0, (fpbH-mpT)/2])
            rotate([-90, 0, 0])
                cylinder(d=3, h=bodyD/2+0.2);
    }
}

/**
 * Module to show the full assembly
 **/
module Assembly() {
    // The motor
    translate([0, 0, -bodyH])
        StepSynStepper();

    // The roller
    translate([0, rlrOffsY, rlrOffsZ])
        Roller();

    // A piece of filament
    color("cyan")
        translate([0, filOffsY, filOffsZ])
            rotate([0, -90, 0])
                cylinder(d=filamentD, h=bodyD*2, center=true);
    // A piece of Bowden tubing`
    color("white", 0.8)
        translate([10+btX, filOffsY, filOffsZ])
            rotate([0, -90, 0])
                cylinder(d=bowdenD, h=20, center=true);
    
    color("lime") {
    // The base
    ExtruderBase();
    // The tension arm
    RollerArm();
    }
}

if(draw=="assembly")
    Assembly();
else if(draw=="motor")
    StepSynStepper();
else if(draw=="roller")
    Roller();
else if(draw=="base")
    ExtruderBase();
else if(draw=="arm")
    RollerArm();
else if(draw=="plate") {
    ExtruderBase();
    translate([-bodyD-5, 0, 0])
        rotate([0, 0, -90])
            RollerArm(0);
}
