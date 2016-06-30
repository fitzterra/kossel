// The effector with retractable z-probe.

$fn=64;

use <../effector_e3d.scad>

print = true;       // Draw for printing
probeTop = true;
probeBot = true;
probeCradle = true;
probeCradMount = true;
assembly = true;    // Show assembly to effector


/**
 * First attempt at a Z-Probe using a 1.5mm copper or steel wire as probe. The
 * housing has a sliding "gate" at the top with a magnet positioned so that it
 * will keep the probe up when not engaged, and by sliding he gate out, it will
 * drop the probe and engage it. At the bottom of the housing two wires are
 * connected when the probe hangs over them. By tuouching the build plate with
 * the probe, it lifts off the two wires and breaks contact. The probe is
 * stored later by sliding the gate back into position with the magnet over the
 * probe, and then simply lowering the effector to push the probe up until it is
 * grabbed by the magnet again.
 *
 * This is a first attempt and does not work too well since the tollerences are
 * very tight.
 **/
module ProbeHousing1(housing=true, gate=true, print=true, baseSample=true) {

    probeDia = 3.8;     // Probe diameter
    wallT = 1.5;        // Thickness of walls
    // How far the gate is offset from the back wall. THis is to move the
    // magnet over a level part of the probe away from the bend.
    gateOffs = 1.5;
    gateW = 5;          // Gate width
    gateH = 4;          // Gate height
    gateL = 25;         // Gate length
    gateHookH = 4;      // Gate hook height
    retractLen = 18;    // How much to retract by
    magH = 2;           // Height of the magnet on top of the probe


    // Calculate stuff
    w = wallT + gateOffs + gateW + wallT;
    d = wallT + probeDia + wallT;
    h = retractLen + magH + gateH + wallT;
    contactTrW = w-wallT-probeDia;      // Override preset above


    module Housing() {
        difference() {
            union() {
            // The main block
            cube([w, d, h]);
            }

            // Probe slot
            translate([wallT, wallT, -1])
                cube([w, probeDia, h+2]);

            // Gate slots
            translate([wallT+gateOffs+gateW/2, d/2, h-wallT-gateH/2])
                #cube([gateW+0.4, d+2, gateH+0.4], center=true);

            // Cut lower walls
            translate([wallT+probeDia+0.05, w, -0.05])
                rotate([90, 0, 0])
                    linear_extrude(height=w+2)
                        polygon([[0,0], [w-(wallT+probeDia), 0],
                                 [w-(wallT+probeDia), h-wallT-gateH-wallT],
                                 [0, w-tan(1)*(w-wallT-probeDia)]]);
        }
        // The contact triangles
        // This fails to render in 2015-03.1!
        *translate([wallT+probeDia, 0, 0])
            rotate([90, 0, 90])
                linear_extrude(height=contactTrW)
                    polygon([[0,0], [d, 0], [d, probeDia], [d-0.5, probeDia],
                             [d/2, 0], [0.5, probeDia], [0, probeDia]]);
        // Here is a poor substitute for the contact triangles above
        translate([wallT+probeDia, 0, 0])
            difference() {
                cube([contactTrW, d, probeDia]);
                translate([-1, d/2, -0.5])
                    rotate([45, 0, 0])
                        cube([w, probeDia*1.1, probeDia*1.1]);
                translate([-1, 0, sqrt(pow(probeDia, 2)/2)-0.5])
                    cube([w, d, probeDia]);
            }
    }

    module Gate() {
        cube([gateL, gateH, gateW]);
        translate([0, -gateHookH, 0])
            cube([gateH, gateHookH, gateW]);

    }

    if(housing)
        if(baseSample) {
            difference() {
                cube([w*2, d*2, 4]);
                translate([w, d, -1])
                    cylinder(d=probeDia, h=6, $fn=64);
            }
            translate([w-wallT-probeDia/2, d/2, 3.9])
                Housing();
        } else {
            Housing();
        }
    if (gate)
        if (housing && print==false)
            translate([wallT+gateOffs, -probeDia*2, h-wallT-gateH])
                rotate([90, 0, 90])
                    Gate();
        else
            translate([0, -5, 0])
                Gate();

}

/**
 * Second attempt at a Z-Probe. This one is similar to ProbeHousing1, except it
 * uses a flat headed nail for the probe. This one works much better, but the
 * nail needs more weight to properly rest on and connect the two wires at the
 * shaft bottom. Worth investigating further in future.
 **/
module ProbeHousing2(housing=true, gate=true, print=true, baseSample=true) {

    headDia = 6;        // Nail/Probe Head diameter
    shaftDia = 2.5;     // Nail/Probe Shaft dia
    headTol = 0.5;      // Amount of tollerance to allow around head
    shaftTol = 0.25;    // Amount of tollerance to allow around shaft
    wallT = 1.5;        // Thickness of walls on sides
    footH = 4;          // Bottom foot height
    gateH = 3;          // Height of the gate (thickness)
    gateL = 45;         // Gate length
    gateHookH = 5;
    gateTol = 0.3;      // Tollerance for the gate slot
    magDia = 6;         // Diameter for magnet in gate
    magT = 1;           // Magnet thickness
    magTol = 0.2;       // Tollerance for magnet diameter recess
    liftH = 15;         // How much lift to allow


    // Calculations //
    // The square size of the housing
    xy = wallT*2 + headTol*2 + headDia;
    // The gate thickness
    echo ("square: ", xy);
    h = footH + liftH + gateTol*2 + gateH + wallT;
    echo ("heigt: ", h);
    // The gate width; We allow for 0.5mm on walls on either side of the nagnet
    gateW = magDia + 0.5*2;
    // The gate back wall thickness
    gateBWall = (xy-gateW)/2 + gateTol;

    module Housing() {
        difference() {
            // The main block with the front cutout and foot
            union() {
                difference() {
                    // Main block
                    cube([xy, xy, h]);
                    // Main center cutout
                    translate([wallT, -1, -1])
                        cube([xy-wallT*2, xy/2+1, footH+liftH+1]);
                    // Foot cutout to add a rounded foot
                    translate([-1, -1, -1])
                        cube([xy+2, xy/2+1, footH+1]);
                }
                // Foot
                translate([xy/2, xy/2, 0])
                    cylinder(d=xy, h=footH);
            }

            // The top cutout
            translate([wallT, -1, footH+liftH])
                cube([xy-wallT*2, xy-gateBWall+1, gateH+gateTol*2+wallT+1]);

            // The gate slots
            translate([-1, (xy-gateW)/2-gateTol, footH+liftH])
                cube([xy+2, gateW+gateTol*2, gateH+gateTol*2]);

            // Probe head slot
            translate([xy/2, xy/2, footH])
                cylinder(d=headDia+2*headTol, h=liftH);

            // Probe shaft slot
            translate([xy/2, xy/2, -1])
                cylinder(d=shaftDia+2*shaftTol, h=footH+1);


            // Cut lower walls with angle to help printing
            translate([-1, -0.1, footH])
                rotate([90, 0, 90])
                    linear_extrude(height=xy+2, convexity=10)
                        polygon([[0,    0],
                                 [xy/2, 0],
                                 [xy/2, liftH-wallT-tan(60)*xy/2],
                                 [0,    liftH-wallT]]);
        }
    }

    module Gate() {
        difference() {
            // Gate main
            cube([gateL, gateH, gateW]);
            // Magnet recess
            translate([gateL-xy-1-xy/2, -1, gateW/2])
                rotate([-90, 0, 0])
                    cylinder(d=magDia+magTol*2, h=magT+1);
        }
        // Hook
        translate([0, -gateHookH, 0])
            cube([gateH, gateHookH, gateW]);
    }

    if(housing)
        if(baseSample) {
            difference() {
                cube([xy*2, xy*2, 1.5]);
                translate([xy, xy, -1])
                    cylinder(d=shaftDia+shaftTol*2, h=6, $fn=64);
            }
            translate([xy/2, xy/2, 1.5])
                Housing();
        } else {
            Housing();
        }

    if (gate)
        if (housing && print==false)
            translate([-gateL+xy*2+1, (xy+gateW)/2, footH+liftH+gateTol])
                rotate([90, 0, 0])
                    Gate();
        else
            translate([0, -5, 0])
                Gate();

}

EffectorE3D();

translate([3, -22, 5])
    ProbeHousing1(print=false, baseSample=false);
translate([-18, 11, 5])
ProbeHousing2(print=false, baseSample=false);
