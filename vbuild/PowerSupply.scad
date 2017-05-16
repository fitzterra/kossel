/**
 * Model of 24V power supply to be used for the printer and mounting brackets
 * to mount the PSU to the frame as well as to mount a power socket and switch
 * to the PSU.
 *
 * Source: http://www.banggood.com/AC-85-265V-To-DC-24V-15A-360W-Switch-Power-Supply-Driver-Transformer-Adapter-For-LED-Strip-Light-p-1022824.html
 **/
$fn=64;

use <fillets/fillets.scad>
include <../configuration.scad>;
use <EndstopWireGuide.scad>

// Draw options
print = false;       // Set to true to generate print ouptut
hookSample = false; // Set to true to only generate a sample of the hook to test fit
assembly = true;    // Set to true to generate assembly output if not printing
bracket = "V";        // Set to "V" or "hook" to select bracket type.

// Main PSU dimensions
psuW = 115;    // Width
psuL = 215;    // Length
psuH = 50;     // Height
psuBMountHolesX = 50;   // Bottom mount holes center to center in X plane
psuBMountHolesY = 150;  // Bottom mount holes center to center in Y plane
psuSMountHolesZ = 23;   // Side mount holes center to center in Z plane
psuSMountHolesBotOffs = 12;    // Offset from top to center of top side mount hole
psuMountHoleDia = 4;

// Common dimensions needed for mount bracket
extrusion = 15;         // Extrusion size
beamGap = extrusion;    // Gap between bottom frame beams
frameH = extrusion*2 + beamGap; // Total height of the bottom frame beams
M4hd1 = 8;   // Diameter of top of M4 sunken head screw
M4hd2 = 4.2;   // Diameter of bottom (shaft side) of M4 sunken head screw
M4hh = 2.7; // Height of M4 sunken screw head


/** 
 * Models the PSU.
 **/
module PSU() {
    w = psuW;    // Width
    l = psuL;    // Length
    h = psuH;     // Height
    plateTh = 2;    // Thickness of the plate
    bottomLip = 6;  // Lip + PCB height
    connInset = 23; // Inset amount in box for connectors
    connW = 11;
    connH = 12;
    connD = 15;
    connWallTh = 0.8;
    connCnt = 9;
    wireDia = 3;
    wireColors = ["red", "red", "red",          // The 24V+ outputs
                  "black", "black", "black",    // The output GNDs
                  "green", "brown", "blue"];    // The 220V input
    bMountHolesX = psuBMountHolesX;
    bMountHolesY = psuBMountHolesY;
    sMountHolesZ = psuSMountHolesZ;
    sMountHolesBotOffs = psuSMountHolesBotOffs;
    mountHoleDia = psuMountHoleDia;

    color("silver")
    difference() {
        // The main box
        cube([w, l, h]);
        // The cutout for the connectors side
        translate([plateTh, -1, bottomLip])
            cube([w-2*plateTh, connInset+1, h]);
        // Mounting holes at the bottom.
        for(x=[(w-bMountHolesX)/2, (w+bMountHolesX)/2])
            for(y=[(l-bMountHolesY)/2, (l+bMountHolesY)/2])
                translate([x, y, -1])
                    cylinder(d=mountHoleDia, h=6);
        // Mounting holes on the sides
        for(z=[0, sMountHolesZ])
            // They are the same spacing in the Y plane as on the bottom
            for(y=[(l-bMountHolesY)/2, (l+bMountHolesY)/2]) {
                // Right side
                translate([w+1, y, sMountHolesBotOffs+z])
                    rotate([0, -90, 0])
                        cylinder(d=mountHoleDia, h=6);
                // Left side only has holes at the bottom
                if(z==0)
                    translate([-1, y, sMountHolesBotOffs+z])
                        rotate([0, 90, 0])
                            cylinder(d=mountHoleDia, h=6);
            }


    }
    // The connectors
    translate([16, 1, bottomLip])
        for(n=[0:connCnt-1]) {
            translate([n*(connW-connWallTh), 0, 0]) {
                color([55/255, 55/255, 55/255], 1)
                difference() {
                    cube([connW, connD, connH]);
                    translate([connWallTh, -1, connH*6/10])
                        cube([connW-2*connWallTh, connD-connWallTh+1, connH]);
                }
                // A wire
                translate([(connW-connWallTh)/2, -5, connH*6/10+wireDia])
                    rotate([-90, 0, 0])
                        color(wireColors[n])
                        cylinder(d=wireDia, h=connD+5, $fn=90);
            }
    }
}

/**
 * Bracket to mount a standard 220V "kettle" socket to the side of the PSU.
 **/
module PowerSocketBracket() {
    t = 3;  // Thickness of all parts
    w = 50; // Base width
    d = 5+5+t; // Depth of base
    h = 16; // Height of mount uprights - on top of base
    sw = 28;    // Width of the socket between the mount uprights
    psuMC = 23; // Distance between centers of PSU mounting holes

    sMC = 40;  // Centers of socket mount holes
    sMH = 9.5; // Height of socket mount hole from base
    sMHd = 2.5; // Diameter of socket mount hole - will get a thread cut

    difference() {
        union() {
            // The base
            cube([w, d, t]);
            // Mount upright
            translate([0, d-t, t]) {
                cube([w, t, h]);
                fil_linear_i(w, 3);
            }
        }
        // Cut out for socket
        translate([(w-sw)/2, 0, t])
            cube([sw, d+0.2, h+0.1]);
        // PSU screw holes
        for(x=[(w-psuMC)/2, (w+psuMC)/2])
            translate([x, (d-t)/2, -0.1]) {
                cylinder(d=M4hd2, h=t);
                translate([0, 0, t-M4hh])
                    cylinder(d1=M4hd2, d2=M4hd1, h=M4hh+0.5);
            }
        // Socket holes
        for(x=[(w-sMC)/2, (w+sMC)/2])
            translate([x, d-t-0.1, t+sMH])
                rotate([-90, 0, 0])
                    cylinder(d=sMHd, h=t+0.2);
    }
}

/**
 * Bracket to mount the PSU on the side of the printer frame bottom beams.
 **/
module MountBracket() {
    t = 3;          // Thickness for the brackets
    w = extrusion;  // Width
    // Height goes to top mount hole plus some extra
    h = (psuW-psuBMountHolesX)/2 + psuBMountHolesX + psuMountHoleDia/2 + t;
    // To allow some tollerance for mount hooks to not fit too tightly on frame beams.
    tol = 0.5;

    // Vertical plate
    difference() {
        cube([t, h, w]);
        // PSU screw holes
        for(y=[(psuW-psuBMountHolesX)/2, (psuW+psuBMountHolesX)/2])
            translate([0, y, w/2])
                rotate([0, 90, 0])
                    translate([0, 0, -0.4 ]) {
                    cylinder(d=M4hd2, h=t);
                    translate([0, 0, t-M4hh])
                        cylinder(d1=M4hd2, d2=M4hd1, h=M4hh+0.5);
            }
    }

    // Mount hooks - bottom and top
    for(y=[extrusion, frameH])
        translate([t, y-extrusion/2, 0]) {
            difference() {
                // Main cube stock
                cube([extrusion+t+tol, extrusion/2+t+tol, w]);
                // Cut our the extrusion bit
                translate([-1, -1, -1])
                    cube([extrusion+tol+1, extrusion/2+tol+1, w+2]);
                // Fillet the bracket top edge
                translate([extrusion+tol+t, extrusion/2+tol+t, 0])
                    rotate([0, -90, 0])
                        fil_linear_i(w, 2);
                // Mounting hole
                translate([extrusion/2, extrusion/2-1, w/2])
                    rotate([-90])
                        cylinder(d=3, h=t+2);
            }
            // Fillet the hook bottom outer corner
            translate([extrusion+tol, extrusion/2+tol, 0])
                rotate([0, -90, 0])
                    fil_linear_i(w, 1);
            // Fillet the hook bottom inner corner
            translate([0, extrusion/2+tol, 0])
                rotate([0, -90, 90])
                    fil_linear_i(w, 1);
            // Fillet the hook upper inner corner
            translate([0, extrusion/2+t+tol, 0])
                rotate([0, -90, 180])
                    fil_linear_i(w, 2);
        }
}

/**
 * A V-type mount bracket to mount the PSU verically on an upright post.
 **/
module V_MountBracket() {
    d = 24; // Depth from extrusion post to back of PSU
    t = 3;  // Thickess for the bracket
    h = 10; // Bracket height
    fl = 12;// Length of each foot on the PSU
    // The angle for the arms
    o = d-t*2;
    a = (psuBMountHolesX-fl-extrusion)/2;
    armA = atan(o/a);
    echo("armA:", armA);
    echo("o:", o);
    echo("a:", a);

    difference() {
        union() {
            // The PSU side feet
            for(x=[-psuBMountHolesX/2, psuBMountHolesX/2])
                translate([x, 0, 0])
                    cube([fl, t, h], center=true);
            // The extrusion side
            translate([0, d-t, 0])
                cube([extrusion, t, h], center=true);
            // The two arms
            for(p=[  [(-psuBMountHolesX+fl)/2, -90+armA, -t],
                     [(psuBMountHolesX-fl)/2, 90-armA, 0]
                ])
                translate([p[0], -t/2, -h/2])
                    rotate([0, 0, p[1]])
                        translate([p[2], 0, 0])
                            cube([t, d*2, h], center=false);
        }
        // Clear away the arms overlapping the top
        translate([-psuBMountHolesX/2, d-t/2, -h/2-1])
            cube([psuBMountHolesX, d, h+2], center=false);
        // Mount holes for PSU
        for(x=[-psuBMountHolesX/2, psuBMountHolesX/2])
            translate([x, 0, 0])
                rotate([90, 0, 0])
                    cylinder(d=psuMountHoleDia, h=h+1, center=true);
        // Extrusion mount hole
        translate([0, d-t, 0])
            rotate([90, 0, 0])
                cylinder(r=m3_wide_radius, h=h+1, center=true);
    }
    translate([0, d-t/2, 0])
    EndStopWireGuideV2(h, false);

}

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

module HookAssembly() {
    color("Silver")
        translate([extrusion/2, -30, extrusion/2])
        rotate([0, 90, 90]) {
            extrusion_15(psuL+60);
            translate([-30, 0, 0])
                extrusion_15(psuL+60);
        }
    translate([-3, 0, 0])
        rotate([0, -90, 0]) {
            PSU();
            translate([psuW, (psuL+psuBMountHolesY)/2-5, (psuH+psuSMountHolesZ)/2+psuSMountHolesBotOffs])
                rotate([0, 90, 0])
                    PowerSocketBracket();
    }
    for(y=[(psuL-psuBMountHolesY)/2, (psuL+psuBMountHolesY)/2])
        translate([-3, y+extrusion/2, 0])
            rotate([90, 0, 0])
                MountBracket();
}

module VAssembly() {
    color("Silver")
        translate([0, extrusion/2, 0])
            extrusion_15(psuL+60);
    for(z=[0, psuBMountHolesY])
        translate([0, -24+3/2, z+(psuL-psuBMountHolesY)/2])
            V_MountBracket();
    translate([-psuW/2, -24, 0])
        rotate([90, 0, 0])
            PSU();
}

// Generate output
if(print) {
    if(bracket=="hook") 
        if(hookSample==false) {
            PowerSocketBracket();
            for(x=[0, extrusion+10])
                translate([x, 20, 0])
                    MountBracket();
        } else {
            // Cut a sample print to see if the hook will fit
            difference() {
                MountBracket();
                translate([-1, -1, 5])
                    cube(160);
                translate([-1, 22, -1])
                    cube(100);
            }
        }
    else  // V-Bracket
        for(y=[0, 30])
            translate([0, y, 0])
                V_MountBracket();
} else if(assembly) {
    if(bracket=="hook")
        HookAssembly();
    else
        VAssembly();
} else {
    // Just show all parts
    translate([-psuW-10, 0, 0])
        PSU();
    if (bracket=="hook") {
        PowerSocketBracket();
        for(x=[0, extrusion+20])
            translate([x, 40, 0])
                MountBracket();
    } else {
        translate([30, 0, 0])
            V_MountBracket();
        translate([30, 30, 0])
            V_MountBracket();
    }
}

