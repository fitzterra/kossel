// Jigs to help cut rods to exact lenghts and to help fix rod ends to rods.
// These jigs are meant to be attached to OpenBeam extrusions as the base guide.

$fn=64;

// What to generate?
//make = "JointJig";
make = "CutJig";
// Show usage sample?
usage=true;

tol=0.6;        // Tolerance for additional clearances
obSize=15;      // OpenBeam size

/**
 * Jig to help poistion rods to traxxas rod ends before glueing the ends to the
 * rods. Two of these jigs are needed for each end.
 * This jig is meant to work with Traxxas 5347 rod ends, but parameters should
 * be adjustable for any size rod end.
 * The balljoint should be placed inside the rod end, and a bolt through the
 * joint goes into the OpenBeam. Another bolt in the other hole secures it to
 * the jig to the OpenBeam.
 **/
module RodEndJig() {
    trxLip2Edge=10; // From the start of the lip at the shaft end to the apex of the
                    // rouded outer edge of the traxxas joint.
    trxHoleDia=5.5; // Diameter of traxas hole into which the ball joint fits.
    trxLip2Hole=2.3; // From the start of the lip to the edge of the hole.
    trxC2Lip=trxLip2Hole+trxHoleDia/2;    // Center of traxxas hole to start of lip
    trxWidth=10;
    jigLen=trxLip2Edge+10; // Length of the jig - the extra is to make room for a second screw
    baseHeight=4;   // Height of the jig bas to the bottom of the Traxxas end
    fullHeight=baseHeight+4; // Full height for the jig
    difference() {
        //The base
        translate([-trxC2Lip, -obSize/2, 0])
            cube([jigLen, obSize, fullHeight]);

        // Joint indentation
        translate([0, 0, baseHeight])
        union() {
            cylinder(d=trxWidth+tol, h=fullHeight);
            translate([-trxC2Lip-1, -(trxWidth+tol)/2, 0])
                cube([trxC2Lip+1, trxWidth+tol, fullHeight]);
        }

        // Mounting holes
        for (x=[0, jigLen-3-1.5-trxC2Lip])
            translate([x, 0, -1])
                cylinder(d=3, h=fullHeight+2);

        // Allow the ball joint to sink 2mm into the base
        translate([0, 0, baseHeight-2])
            cylinder(d=trxHoleDia+tol, h=fullHeight);
    }
}

/**
 * Jig to be used on OpenBeam to cut consistent and accurate rod lengths.
 **/
module RodCutterJig(cutSide=false) {
    rodDia=6;           // Diameter of rod to cut
    uprightWidth=3;    // Width of the upright stops and guides
    uprightHeight=rodDia*3/4; // Height of the upright stops and guides
    cutGuideHeight=rodDia+3; // The upright height for the cut guide helps it if
                             // is higher than rod.
    cutGap=1;          // Gap to leave for the cut blade or cut tool
    guideGap=5;        // Gap between the stop upright and guide on the stop side
    mountScrewsGap=8;   // Gap between the centers of the mounting screws
    rodClearance=2; // Some clearence between top of base and bottom of rod

    // Select the correct gap between guides based on whether this is the cut
    // side or the guide side.
    uprightGap= (cutSide==false) ? guideGap : cutGap;

    baseHeight=4;   // 8mm M3 screws works well with 4mm height
    // Calculate the base length 
    baseLen=3 +         // Some space from base edge to 1st mounting hole edge
            1.5 +       // Distance to center of 1st mounting hole
            mountScrewsGap +    // Center of 1st to center of 2nd moutning hole
            1.5 +       // Distance to far edge of 2nd mounting hole
            3 +         // Some space to 1st uprigt
            uprightWidth +  // Width of 1st upright
            uprightGap +    // Gap between uprights
            uprightWidth;   // Width of 2nd upright

    difference() {
        // Keep the jig centered around X
        translate([0, -obSize/2, 0])
            // The base and uprights
            union() {
                // The base
                cube([baseLen, obSize, baseHeight]);
                // Upright at the furthest edge away from the mounting holes.
                // For the guide side, this is simply a guide for the rod to
                // rest in, but for the cut side, this is the main cut mark
                // edge. On the cut side we want this upright to be slightly
                // higher to serve as a blade guide.
                translate([baseLen-uprightWidth, (obSize-(rodDia+4))/2, baseHeight])
                    cube([uprightWidth,
                          rodDia+4,
                          rodClearance + (cutSide==true ? cutGuideHeight : uprightHeight)]);
                // Stop or cut upright
                translate([baseLen-uprightWidth-uprightGap-uprightWidth, cutSide==false?0:(obSize-(rodDia+4))/2, baseHeight])
                    cube([uprightWidth, cutSide==false?obSize:rodDia+4, uprightHeight+rodClearance]);
            }

        // Mounting holes
        for(x=[0, mountScrewsGap])
            translate([x+3+1.5, 0, -1])
                cylinder(d=3, h=baseHeight*2);
        // Rod guides
        translate([baseLen-(cutSide==true?baseLen:uprightWidth)-0.1, 0, baseHeight+rodDia/2+rodClearance])
            rotate([0, 90, 0])
                cylinder(d=rodDia+tol, h=baseLen+2);
    }
}

/**
 * Traxxas 5347 in proper colors.
 **/
module Traxxas5347() {
    color("Silver")
        import("traxxas-5347-ball.stl");
    color([20/255, 20/255, 20/255])
        import("traxxas-5347-joint.stl");
}

/**
 * Shows how the Rod End Jigs should be used.
 * Expects to have traxxas ball and joint and 1515 extrusion STLs in the local dir.
 **/
module RodEndJigUsage() {
    rodLen = 60;
    c2e = 17.4;     // Center of Traxxas5347 ball to bottom edge
    
    module JigAndRodEnd() {
        RodEndJig();
        translate([0, 0, 5.5])
            rotate([0, 0, 180])
                Traxxas5347();
    }

    translate([rodLen+c2e*2, 0, 0])
        JigAndRodEnd();
    rotate([0, 0, 180])
        JigAndRodEnd();
    color("black")
    translate([c2e, 0, 5.5])
        rotate([0, 90, 0])
            cylinder(d=6, h=rodLen);
    color("silver")
    translate([-30, 0, -15/2])
        rotate([0, 90, 0])
        difference() {
            import("1515_1000mm.stl", convexity=10);
            translate([-10, -10, rodLen+100])
                cube([20, 20, 1000]);
        }
        
}

/**
 * Shows how the Rod Cutter Jigs should be used.
 * Expects to have 1515 extrusion STL in the local dir.
 **/
module CutJigUsage() {
    rodLen = 60;
    
    // The Jigs
    RodCutterJig(true);
    translate([52+rodLen, 0, 0])
        rotate([0, 0, 180])
            RodCutterJig(false);

    // The Rod
    color([100/255, 100/255, 100/255], 0.9)
    translate([-rodLen-28, 0, 9])
        rotate([0, 90, 0])
            cylinder(d=6, h=rodLen*3);
    
    // The OpenBeam
    color("silver")
    translate([-10, 0, -15/2])
        rotate([0, 90, 0])
        difference() {
            import("1515_1000mm.stl", convexity=10);
            translate([-10, -10, rodLen+70])
                cube([20, 20, 1000]);
        }
        
}

if(make=="JointJig") 
    if(usage==false)
       RodEndJig();
    else
        RodEndJigUsage();
else
    if(usage==false) {
        RodCutterJig(true);
        translate([60, 0, 0])
            rotate([0, 0, 180])
                RodCutterJig(false);
    }
    else
        CutJigUsage();



