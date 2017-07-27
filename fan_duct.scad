//-- Customizable fan duct and mount generator for a kossel effector
//
//-- Modified from https://www.thingiverse.com/thing:540716 by:
//-- AndrewBCN - Barcelona, November 2014

//----------------------------------------
// Most parameters can be modified via customizer. The duct definition can not
// though, and this has to be done in the code, until a possibly more suitable
// method is found.
// ---------------------------------------


// What output to generate
output = "assembly"; //["assembly", "duct", "mount", "printplate", "printduct", "printmount"]

// If generating an assembly, the duct angle can be adjusted here
assyDuctAngle = 0; //[-180:180]

// Radius for an M3 hole
m3_radius = 3/2;

// Circle granulatiry
$fn=96;
// Set to true to show the duct with colors.
useColor= false;

/* [Fan Base] */
// Size of the fan in mm
fanSize = 40;
// Radius for fan base corners
cornerR = 1;   // [1, 2, 3]
// Fan base Thickness
baseThickness = 4; // [2:0.25:6]
// Distance between holes in fan base
holePitch = 32;
// Mount method - tap or recess for a nut
mountMeth = "tap"; // ["tap", "nut"]
// Mount hole diameter based on mount method 
holeDia = mountMeth=="tap" ? 2.6 : 3.1;
// Nut diameter if mounting with a recessed nut
nutDia = 6.9;

/* [Funnel] */
// Funnel inset from edges
funnelInset = 0.3; //[0:0.1:1]
// Funnel wall thickness
wallThickness = 1.2;
// Height for each section of the funnel
sh = [5, 4, 10, 12, 8];
// Function to calculate the total height for a given section
function sectHeight(s, h=0) = s==0 ? h+sh[s] : sectHeight(s-1, h+sh[s]);

/* [Mount] */
// Diameter for the mount on the effector side
mountDia=8;
// How thick to make the mount
mountThickness=3;
// Length of the mount arm
mountLen = 4;
// Tab mount hole offset from top of mount surface
mountTabZOffs = m3_radius+1;


/* [Hinge] */
// Number of hinge tabs on the duct - only handles 3 atm
hingeTabs = 3; // [3]
// Width for hinge tab - also see hingeTabClear
hingeTabWidth = 2.8;
// Clearence between hinge tabs
hingeTabClear = 0.2;
// Clearence for hinge rounding to interconnecting body
hingeConnectClear = 1;
// Radius for the hinge roundings
hingeRad = 4;
// Offset from the fan rim to the center of the hinge tab holes
hingeYOffs = 3.8;
// Offset from the top of the fan base (fan side) for the center of hinge tab hole
hingeZOffs = 4;

/* [Hidden] */
funnelR = fanSize/2-funnelInset;
// Funnel definition
funnelDef = [
    [   // Base
        // Translate, scale, rotate, radius or [x, y], (optional color)
        [0,0,0], [1,1,1], [0,0,0], funnelR, "green"
    ],
    [   // Section 0
        // Translate, scale, rotate, radius or [x, y], (optional color)
        [0, 0, sectHeight(0)], [1,0.97,1], [2,0,0], funnelR/1.1, "purple"
    ],
    [   // Section 1
        // Translate, scale, rotate, radius or [x, y], (optional color)
        [0, 0, sectHeight(1)], [1,0.93,1], [4,0,0], funnelR/1.2, "red"
    ],
    [   // Section 2
        // Translate, scale, rotate, radius or [x, y], (optional color)
        [0, -3, sectHeight(2)], [0.8,0.6,1], [8,0,0], funnelR/1.25, "orange"
    ],
    [   // Section 3
        // Translate, scale, rotate, radius or [x, y], (optional color)
        [-2, -6, sectHeight(3)], [1,1,1], [-0,0,0], [funnelR/1.3, funnelR/3], "gold"
    ],
    [   // Section 4
        // Translate, scale, rotate, radius or [x, y], (optional color)
        [-4, -12, sectHeight(4)], [1,1,1], [-20,0,0], [funnelR/1.5, funnelR/4.5]
    ],
];


/**
 * Module to generate a mount pivot for the parts fan duct. The mount fits to
 * the bottom of the effector on one of the center mount posts between adjacent
 * arm mount cones.
 **/
module DuctMount() {
    mountTabZOffs = m3_radius+1; // Tab mount hole offset from top of mount surface
    numTabs = hingeTabs-1; // Always one less than the duct hinge tab count
    // Calculate offset left of Y for first tab center
    tabXOffs = -numTabs/2*hingeTabWidth;

    difference() {
        union() {
            // Mount point
            cylinder(d=mountDia, h=mountThickness);
            // Arm
            translate([-mountDia/2, -mountLen-mountDia/2, 0])
                cube([mountDia, mountLen+mountDia/2, mountThickness]);
            // Hinge tabs
            translate([tabXOffs, -mountLen-mountDia/2-hingeRad-hingeConnectClear, mountTabZOffs])
                for(x = [0:2:numTabs*2-1])
                    translate([x*hingeTabWidth, 0, 0]) {
                        hull() {
                            rotate([0, -90, 0])
                                cylinder(r=hingeRad, h=hingeTabWidth-hingeTabClear*2, center=true);
                            translate([-hingeTabWidth/2+hingeTabClear, 0, -mountTabZOffs])
                                cube([hingeTabWidth-hingeTabClear*2, hingeRad+hingeConnectClear, mountTabZOffs]);
                        }
                    }

        }
        // Mount hole for effector
        translate([0, 0, -0.1])
            cylinder(r=m3_radius, h=mountThickness+0.2);
        // Mount holes for hinge
        #translate([0, -mountLen-mountDia/2-hingeRad-hingeConnectClear, mountTabZOffs])
            rotate([0, -90, 0])
                cylinder(r=m3_radius, h=numTabs*4*hingeTabWidth, center=true);
        // Flatten anything sticking out on the hinge tabs
        translate([-mountDia-2, -mountLen-mountDia*2, -5])
            cube([mountDia*2+4, mountLen+mountDia*2, 5]); 
    }

}

/**
 * Moduel to generate a parametric funnel like object consisting of sections
 * stacked on top of each other.
 *
 * Each section is made up of a circle, or box/rectangle as the base, with
 * another circle or rectangle above it which is then hulled together and
 * hollowed out to the desired wall thickness.
 *
 * The bottom of the next section starts off with the shape from the top of the
 * previous section, and then has it's own shape as it's top section, which
 * again becomes the bottom of the next section and so on.
 *
 * The definition for the shape of each section interface can be transformed in
 * the x/y/z plane, scaled in the x/y plane and rotated in any plane. This allows
 * for almost any funnel like shape to created.
 *
 * To define the funnel shape, each section interface needs to be defined in
 * terms of it's center position (translate parameter), it's scaling in the x/y
 * plane (scale parameter), it's rotation in any plane (rotate parameter) and
 * it shape of either a circle or a box/rectagle.
 *
 * For example:
 *
 * funnelDef = [    // the definition is list of section lists
 *      [   // This is the base of the first section
 *          [0,0,0],    // Translation parameter, this starts in the center
 *          [1,1,1],    // Scale parameter - all to 100% scale
 *          [0,0,0],    // Rotate parameter - no rotation
 *          10,         // Shape is a scaled/rotated circle with radius=10
 *          "green"     // Optional color for this section
 *      ],
 *      [   // Interface between 1st and 2nd section
 *          [0,0,10],    // Translate: centered in x/y, 10 high
 *          [1,0.8,1],   // Scale down to 80% in y plane
 *          [5,0,0],     // Rotate 5° in x plane
 *          8,           // Circle with radius=8
 *          "red"        // Optional color for this section
 *      ],
 *      [   // Interface between 2nd and 3rd section
 *          [5,8,18],    // Translate: 5,8 off centered and 18 high
 *          [1,1,1],     // No scaling
 *          [10,5,5],    // Rotate 10° in x plane, 5 in y plane and 5 in z plane
 *          [10, 12],    // Rectangle of 10x12
 *                       // Last interface color has no meaning
 *      ],
 * ]
 *
 * @param wallT: The thickness for the funnel wall
 * @param fDef: The list defining the funnel interfaces
 * @param useColor: Set to true to color each section if it has a color name
 *
 **/
module funnel(wallT, fDef, useColor=false) {
    $fn=64;

    /**
     * Module to create one section.
     *
     * @param wt: Wall thickness
     * @param trS: Translation for section start: [x,y,z]
     * @param sclS: Scale for section start: [x, y, z] - z should be 1
     * @param rotS: Rotation for section start: [x, y, z]
     * @param objS: Object for start, either a radius for a circle, or [x,y] for a rectangle
     * @param trE: Translation for section end: [x,y,z]
     * @param sclE: Scale for section end: [x, y, z] - z should be 1
     * @param rotE: Rotation for section end: [x, y, z]
     * @param objE: Object for end, either a radius for a circle, or [x,y] for a rectangle
     **/
    module sect(wt, trS, sclS, rotS, objS, trE, sclE, rotE, objE) {
        //echo(wt=wt, trS=trS, sclS=sclS, rotS=rotS, objS=objS, trE=trE, sclE=sclE, rotE=rotE, objE=objE);
        //echo("len is", len(objS));
        difference() {
            // Outer
            hull() {
                translate(trS)
                    scale(sclS)
                        rotate(rotS)
                            if(len(objS)==2)
                                cube([objS[0], objS[1], 0.1], center=true);
                            else
                                cylinder(r=objS, h=0.1, center=true);
                translate(trE)
                    scale(sclE)
                        rotate(rotE)
                            if(len(objE)==2)
                                cube([objE[0], objE[1], 0.1], center=true);
                            else
                                cylinder(r=objE, h=0.1, center=true);
            }
            // Inner by wall thickness
            hull() {
                translate([trS[0], trS[1], trS[2]-0.01])
                    scale(sclS)
                        rotate(rotS)
                            if(len(objS)==2)
                                cube([objS[0]-wt, objS[1]-wt, 0.1], center=true);
                            else
                                cylinder(r=objS-wt, h=0.1, center=true);
                translate([trE[0], trE[1], trE[2]+0.01])
                    scale(sclE)
                        rotate(rotE)
                            if(len(objE)==2)
                                cube([objE[0]-wt, objE[1]-wt, 0.1], center=true);
                            else
                                cylinder(r=objE-wt, h=0.1, center=true);
            }
        }
    }

    // Draw all sections
    f = fDef;
    for(s=[0:1:len(f)-2]) {
        color(useColor ? f[s][4] : undef)
            sect(wallT, f[s][0], f[s][1], f[s][2], f[s][3], f[s+1][0], f[s+1][1], f[s+1][2], f[s+1][3]);
    }
}

module hinge() {
    // Clearence for interconnecting tab rounding
    cl = hingeConnectClear;
    // Calculate the x offset where the first hinge would start left of y
    xOffs = -floor((hingeTabs*2-1)/2)*hingeTabWidth - hingeTabWidth/2;

    difference() {
        // Start left of Y with the hinge tabs
        translate([xOffs, 0, 0])
            // Step through each tab pos, but skip the empty slots this side of the hinge
            for(x = [0:2:hingeTabs*2-1])
                hull() {
                    translate([x*hingeTabWidth+hingeTabClear, -hingeYOffs-cl, 0]) {
                        cube([hingeTabWidth-hingeTabClear*2, hingeYOffs+1+cl, hingeZOffs]);
                    translate([hingeTabWidth/2-hingeTabClear, 0, hingeZOffs])
                        rotate([0, -90, 0])
                            cylinder(r=hingeRad, h=hingeTabWidth-hingeTabClear*2, center=true);
                    }
                }

        // Flatten anything on the fan side
        translate([xOffs-1, -hingeYOffs-hingeRad-2, -hingeRad-1])
            cube([hingeTabs*2*hingeTabWidth+1, hingeYOffs+hingeRad+4, hingeRad+1]);
        // Holes
        translate([0, -hingeYOffs-cl, hingeZOffs])
            rotate([0, -90, 0])
                cylinder(d=3, h=hingeTabs*2*hingeTabWidth, center=true);
    }

}

/**
 * Base for mounting the fan, and ontop of which we will add the funnel
 **/
module base() {
    difference() {
        union() {
            // The base
            hull() {
                for(x=[-fanSize/2+cornerR, fanSize/2-cornerR],
                    y=[-fanSize/2+cornerR, fanSize/2-cornerR])
                    translate([x, y, baseThickness/2])
                        cylinder(r=cornerR, h=baseThickness, center=true);
            }
            // Funnel base
            translate([0,0,baseThickness])
                cylinder(r=fanSize/2-funnelInset,h=1);
        }
        // Mounting holes
        for(x=[-holePitch/2, holePitch/2],
            y=[-holePitch/2, holePitch/2])
            translate([x, y, baseThickness/2]) {
                cylinder(d=holeDia, h=baseThickness+0.2, center=true);
                // Nut recess if needed
                if(mountMeth=="nut")
                    translate([0, 0, baseThickness/2])
                        cylinder(r=nutDia/2, h=baseThickness, center=true, $fn=6);
            }

        // Inner cutout
        translate([0, 0, -0.1])
            cylinder(r=fanSize/2-funnelInset-wallThickness, h=baseThickness+1.2);
    }
    // Add the hinge
    translate([0, -fanSize/2, 0])
        hinge();
}

/**
 * Generates the full fan duct
 *
 * @param hingeAt0: If true, set the center of the hinge at [0, 0, 0] to allow
 *        for easy pivoting on the hinge in assemblies.
 **/
module Duct(hingeAt0=false) {
    yCenter = fanSize/2+hingeYOffs+hingeConnectClear;
    zCenter = -hingeZOffs;
    translate([0, hingeAt0 ? yCenter : 0, hingeAt0 ? zCenter : 0]) {
        base();
        translate([0, 0, baseThickness+1])
            funnel(wallThickness, funnelDef, useColor);
    }
}

module DuctAssembly(ductAngle=0) {
    // We move the hinge to [0,0,0] to make the duct rotate easy, but then have
    // to move it all back again to getthe pivot mount at [0,0,0]
    translate([0, -(mountDia/2+mountLen+hingeConnectClear+hingeRad), -mountTabZOffs])  {
        // Move mount to get hinge center at [0,0,0]
        translate([0, mountDia/2+mountLen+hingeConnectClear+hingeRad, mountTabZOffs]) 
            rotate([0, 180, 0])
                DuctMount();
        // The duct with hinge center at [0,0,0]
        rotate([ductAngle, 180, 180])
            Duct(true);
    }
}

if(output=="duct")
    Duct();
else if(output=="mount")
    DuctMount();
else if(output=="assembly")
    DuctAssembly(assyDuctAngle);
else if(output=="printplate") {
    Duct();
    translate([fanSize/2+mountDia, 0, 0])
    DuctMount();
} else if(output=="printduct")
    Duct();
else if(output=="printmount")
    DuctMount();
