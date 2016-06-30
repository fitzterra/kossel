// Origin: http://www.thingiverse.com/thing:788137
// Modified: Tom Coetser <fitzterra@icave.net> 2016
//   * A complete reorganization and quite a bit of rewrittencode.
//   * Also combined all parts into one file with rendering and printing config
//     options.
include <configuration.scad>;
use <e3d-type-hotend.scad>;

// Print and render options. Comment/uncomment those parts to be rendered or printed.
renderParts = [
    //"all",          // This is more usefull with print==true
    "effector",
    //"posts",
    //"groove_mount",
    //"mount_cap",
    //"hotend",
    "pen_holder",
];
// Set true to make a plate of the selected parts above for printing
print = false;


// Set to true to make M3 holes that needs tapping directly into the plastic
// instead of using nuts. On my printer, the hex holes for M3 nuts dont always
// come out to well and the clearence on this effector to get the nuts in the
// holes for the rod ends are extra tight.
// NOTE! : This option uses the newly define m3_tap_radius in configuration.scad
tapM3s = true;

separation = 40;  // Distance between ball joint mounting faces.
offset = 23;  // Same as DELTA_EFFECTOR_OFFSET in Marlin.
mount_radius = 23;  // Position of mount posts from center
height = 10;        // Height of the effector

hotend_radius = 14;  // Hole for the hotend (J-Head diameter is 16mm).
cone_r1 = 2.5;      // Cone radii for effector ball joint connection points
cone_r2 = 14;

// Mount posts and Fan parameters
post_height=36;
fan_size = 30; // Fan width/height size. This effector is best with a 30x30 fan
fan_mount_hole_d = 24;   // Distance between mounting holes of the fan
fan_mount_depth = 10;       // Thickness of mounting plate

// Goove mount parameters
groove_mount_radius = 18;
groove_mount_height = 6;
// Radius around center where mounting holes are located
groove_mount_hole_radius = 12.5;
// Slot and lip for installation
groove_mount_slot_radius = 6.25;
groove_mount_lip_radius = 8.1;
groove_mount_lip_depth = 1;

// Mount Cap parameters
tol = 0.6;  // Additional tollerance to add to cylinder diameters for tight printing
mount_cap_dia = (offset*2)-5;   // Slightly smaller than the effector
bowden_fitting_dia = 10 + tol;  // For the hole in the top to attach the fitting
e3d_top_flange_dia = 16 + tol;  // The top flange on the hotend sunk into the cap
e3d_top_flange_height = 4 + 0.5;// Top flange height + some to sink into cap
mount_cap_height = 6;           // Height of end cap
m3_cap_dia = 5.4 + tol;         // Diameter of the hex cap M3 screw for sinking
m3_cap_height = 3.5 + 1.3;      // Cap height plus a little extra for sinking

// Pen holder params
pen_holder_height = height-4;
pen_holder_id = 9.3;                // Inner Diameter for pen hole
pen_holder_od = pen_holder_id + 8;  // Outer Diameter for pen hole

/**
 * Module that generates the effector base
 **/
module EffectorE3D() {
    difference() {
        union() {
            // Main pug
            cylinder(r=offset-2, h=height, center=true, $fn=120);
            // Add the 3 mounting blocks
            for (a = [60:120:359])
                rotate([0, 0, a]) {
                    // Mount block posts to upper hotend end cap
                    rotate([0, 0, 90])
                        translate([offset-2, 0, 0])
                            cube([12, 7, height], center=true);
                    // Mount cones for rods
                    for (s = [-1, 1])
                        scale([s, 1, 1]) {
                            translate([0, offset, 0])
                                difference() {
                                    intersection() {
                                        cube([separation, 40, height], center=true);
                                        // Horizontal cylinder for rounded edge
                                        translate([0, -4, 0])
                                            rotate([0, 90, 0])
                                                cylinder(r=10, h=separation,
                                                         center=true, $fn=200);
                                        // Cone shape for rod end connector
                                        translate([separation/2-7, 0, 0])
                                            rotate([0, 90, 0])
                                                cylinder(r1=cone_r2, r2=cone_r1,
                                                         h=14, center=true, $fn=60);
                                    }
                                    // Rod connector holes.
                                    rotate([0, 90, 0])
                                        cylinder(r=(tapM3s?m3_tap_radius:m3_radius),
                                                 h=separation+1,
                                                 center=true, $fn=12);
                                    // Recess for M3 nuts if not tapping
                                    if(tapM3s!=true)
                                        rotate([90, 0, 90])
                                            cylinder(r=m3_nut_radius,
                                                     h=separation-20,
                                                     center=true, $fn=6);
                                }
                        }
                }
        }
        // Hole for hotend
        translate([0, 0, -height/2-0.1])
            cylinder(r1=hotend_radius+1, r2=hotend_radius, h=height+1, $fn=120);
    
        // Mounting holes for posts to upper hotend end cap
        for (a = [0:120:359])
            rotate([0, 0, a+60]) {
                // Bolt hole
                translate([0, mount_radius, 0])
                    cylinder(r=(tapM3s?m3_tap_radius:m3_wide_radius), h=2*height,
                             center=true, $fn=12); 
                // Nut recess if not tapping
                if(tapM3s!=true)
                    translate([0, mount_radius, 1.5])
                        rotate([0, 0, 30])
                            cylinder(r=m3_nut_radius, h=7+0.1,
                                     center=true, $fn=6);

            }
    }
}


//=================================================
/**
 * Module that generates the three mounting posts.
 **/
module MountPosts() {
    // The original has posts that taper to the middle, but I do not like that
    // very much. Change this setting to either use the original or the same
    // radius option.
    original = false;

    // Post radius
    post_rad=4;
    // Tapper radius if original above is true
    tap_rad = 2.5;
    difference() {
        union() {
            // The main posts at 120° offsets on mount_radius
            for (a = [0:120:359])
                rotate([0, 0, a]) {
                    $fn = 64;
                    if (original) {
                        // Original tappered post
                        translate([0, mount_radius,0])
                            cylinder(r1=post_rad, r2=tap_rad, h=post_height/2);
                        translate([0, mount_radius,post_height/2])
                            cylinder(r1=tap_rad,r2=post_rad, h=post_height/2);
                    } else {
                        // Non-tappered post
                        translate([0, mount_radius,0])
                            cylinder(r=post_rad, h=post_height+a/4);
                    }
                }

            #translate([-1*mount_radius*cos(30),
                       -1*mount_radius*sin(30)-2,
                       post_height/2])
                cube([8, post_rad, post_height], center=true); 
            translate([mount_radius*cos(30),
                       -1*mount_radius*sin(30)-2,
                       post_height/2])
                cube([8, post_rad, post_height], center=true);  
            translate([0, mount_radius+2, post_height/2])
                cube([8, post_rad, post_height], center=true);  
        }

        for (a = [0:120:359])
            rotate([0, 0, a]) {
                translate([0, mount_radius, 0])
                    cylinder(r=m3_wide_radius, h=2*post_height+height, center=true, $fn=12);
            }
    }
}
  
/**
 * Cube for fan and mounting holes
 **/
module FanMount(tapM3s=false) {
    $fn = 60;
    corner_rad = 2;

    mount_hole_coords = [ 
        [ fan_mount_hole_d/2,  fan_mount_hole_d/2, 0],
        [ fan_mount_hole_d/2, -fan_mount_hole_d/2, 0],
        [-fan_mount_hole_d/2,  fan_mount_hole_d/2, 0],
        [-fan_mount_hole_d/2, -fan_mount_hole_d/2, 0] 
    ];
    difference() {
        // Main fan mount cube with rounded corners
        minkowski() {
            cube([fan_size-corner_rad,
                  fan_size-corner_rad,
                  fan_mount_depth/2], center=true);
            cylinder(r=corner_rad, h=fan_mount_depth/2, center=true);
        }
        // Central cutout
        cylinder(d=fan_size-3, h=fan_mount_depth*2, center=true, $fn=120);

        // 4 mounting bolt holes for fan
        for (i = mount_hole_coords) {
            translate(i)
                cylinder(r=(tapM3s ? m3_tap_radius : m3_radius),
                         h=fan_mount_depth*2, center=true);
            // Recesses for nuts if we do not use tapping
            if(tapM3s==false)
            translate([0, 0, -4])
                translate(i)
                    cylinder(r=m3_nut_radius, h=18, center=true, $fn=6);
        }                   
    }
}

/**
 * Module to assemble the mount posts and fan bracket, and cut out space for the
 * hotend and top plate.
 *
 * @param tapM3s: Whether to use smaller holes in fan mount for tapping, or
 *        larger holes and recesses for M3 nuts.
 * #param print: If false, the posts and fan mount are drawn as for assembly.
 *        If true, they are drawn flat for printing.
 **/
module MountPostsAssembly(tapM3s=false, print=false) {
    difference(){
        // Posts and fan bracket assembly
        union(){
            MountPosts();
            translate([0,
                       -1 * mount_radius * sin(30) + fan_mount_depth/2 - 4,
                       post_height/2 - 2])
                *rotate([90,0,0])
                    FanMount(tapM3s);
        }
        // Cut out for groove mount, leaving a 0.3mm gap below and a 1mm gap on
        // the radius
        *translate([0, 0, post_height-groove_mount_height-0.3])
            cylinder(r=groove_mount_radius+1, h=groove_mount_height+1, $fn=120);
        // Space for hotend
        *translate([0,0,0])
            cylinder(r=13, h=post_height*2, center=true, $fn=120);
    }
}

/**
 * Generates the groove mount to hold the hotend to the top end cap.
 *
 * @param tapM3s: If true, the M3 holes will use the tap diameter, else it will
 *        use the wide diameter
 **/
module GrooveMount(tapM3s=false) {
    $fn = 120;

    // Save some typing :-)
    gmr = groove_mount_radius;
    gmh = groove_mount_height;
    gmhr = groove_mount_hole_radius;
    gmsr = groove_mount_slot_radius;
    gmlr = groove_mount_lip_radius;
    gmld = groove_mount_lip_depth;

    difference() {
      cylinder(r=gmr, h=gmh);

      // Thru holes
      for (hole_angle = [0:60:360])
        translate([sin(hole_angle)*gmhr, cos(hole_angle)*gmhr, -1])
            cylinder(r=tapM3s?m3_tap_radius:m3_wide_radius, h=gmh+2);

      // Thru slot
      translate([0, 0, -1])
        cylinder(r=gmsr, h=gmh+2);
      translate([-gmsr, -gmr, -1])
        cube([2*gmsr, gmr, gmh+2]);

      // Lip 
      translate([0, 0, gmh-gmld])
        cylinder(r=gmlr, h=gmld+2);
      translate([-gmlr, -gmr, gmh-gmld])
        cube([2*gmlr, gmr, gmld+2]);

      // Cut off the sharp edges at the front
      translate([-gmr, -11/4*gmr, -1])
        cube([2*gmr, 2*gmr, gmh+2], center=false);
    }
}

//-------------------------------------------------

module Post(height, rad, tap_rad=0) {
    $fn = 64;
    difference() {
        union() {
            if (tap_rad>0) {
                // Original tappered post
                cylinder(r1=rad, r2=tap_rad, h=height/2);
                translate([0, 0, height/2])
                    cylinder(r1=tap_rad, r2=rad, h=height/2);
            } else {
                // Non-tappered post
                cylinder(r=rad, h=height);
            }
            translate([-rad, 0, 0])
                cube([rad*2, rad, height]);
        }
        translate([0, 0, -1])
            cylinder(r=m3_wide_radius, h=height+2);
    }

}

/**
 * Alternative module for mount posts.
 * NOTE! Along with the Post() module, this is still a work in progress!!
 **/
module MountPosts(print=false) {
    if(print==false) {
        // Place a post in each required position
        for (a=[0:120:359])
            rotate([0, 0, a])
                translate([0, mount_radius, 0])
                    Post(post_height, 4);
    } else {
        for(a=[0:2])
            translate([0, 0, 4])
            rotate([-90, 0, 0])
                translate([10*a, 0, 0])
                    Post(post_height, 4);

    }
}
//=================================================

/**
 * E3D hotend mount cap
 **/
module MountCap() {
    $fn=120;

    difference() {
        // Main cap and mount tabs
        union() {
            // Main cap
            cylinder(d1=mount_cap_dia, d2=mount_cap_dia-3,
                     h=mount_cap_height, center=false);
            // Three round mount tabs
            for (a = [0:120:359])
                rotate([0, 0, a]) {
                    translate([0, mount_radius, 0])
                        cylinder(r1=7.5,r2=8.0, h=mount_cap_height,
                                 center=false);
            }
        }
        // Hole for bowden fitting at the top
        translate([0, 0, -1])
            cylinder(d=bowden_fitting_dia, h=mount_cap_height+2);
        // Sunken hole for hotend top flange to fit into
        translate([0, 0, mount_cap_height-e3d_top_flange_height])
            cylinder(d=e3d_top_flange_dia, h=e3d_top_flange_height+1);

        // Holes for sunken M3 hex cap bolt in mounting tabs
        for (a = [0:120:359])
            rotate([0, 0, a]) {
                translate([0, mount_radius, -1]) {
                    // Bolt shaft hole
                    cylinder(r=m3_wide_radius, h=mount_cap_height+2);
                    // Sunken cap hole
                    cylinder(d=m3_cap_dia, h=m3_cap_height+1);
                }
            }

        // Holes for sunken M3 hex cap screws to go into E3d groove
        // mount bracket
        for (a = [0:60:359])
            rotate([0, 0, a]) {
                translate([0, groove_mount_hole_radius, -1]) {
                    // Bolt shaft hole
                    cylinder(r=m3_wide_radius, h=mount_cap_height+2);
                    // Sunken cap hole
                    cylinder(d=m3_cap_dia, h=m3_cap_height+1);
                }
            }
    }
}

/**
 * Module for a pen holder that fits on top of the effector.
 *
 * @param height: Defaults to the same height as the effector.
 **/
module PenHolder(height=pen_holder_height, ring_id=pen_holder_id, ring_od=pen_holder_od) {
    // Width of the mounting tabs. This is hardcoded in EffectorE3D.
    tab_width = 7;
    // There is an additional 4mm from the center of the mount screw to end of
    // the mount tab on the effector.
    tab_len = mount_radius + 4;
    // The inner diameter for the pen ring
    ring_id = 9.3;
    // The ring wall thickness
    ring_wall = (ring_od - ring_id)/2;

    difference() {
        union() {
            // The three mount tabs
            for (a = [30:120:290])
                rotate([0, 0, a]) {
                    translate([0, -tab_width/2, -height/2])
                        cube([tab_len, tab_width, height]);
            }
            // The center hub
            cylinder(d=ring_id+ring_wall*2, h=height, center=true, $fn=64);
        }
        // The pen hole
        cylinder(d=ring_id, h=height+1, center=true, $fn=64);
        // The tab mount and pen holder screw holes
        for (a = [30:120:290])
            rotate([0, 0, a]) {
                translate([mount_radius, 0, 0])
                    #cylinder(r=m3_wide_radius, h=height+4, center=true, $fn=12);
                rotate([0, 0, 60])
                    translate([ring_id/2+ring_wall+1, 0, 0])
                        rotate([0, -90, 0])
                            #cylinder(r=m3_tap_radius, h=ring_wall+2, $fn=12);
        }
    }
}

for (p=renderParts) {
    if(p=="effector" || p=="all")
        // Effector is always center whether printing or not
        translate([0, 0, height/2])
            EffectorE3D();
    if(p=="posts" || p=="all")
        translate([0, print?post_height+mount_radius*3/2:0, print?0:height])
            rotate([0, 0, 180])
                // Printing is handled by the assembly module
                //MountPostsAssembly(tapM3s, print);
                MountPosts(print);
    if(p=="groove_mount" || p=="all")
        if(print==false)
            translate([0, 0, height+post_height-groove_mount_height])
                GrooveMount(tapM3s);
        else {
            translate([-mount_radius-groove_mount_radius*2+5, 0, 0])
                GrooveMount(tapM3s);
        }
    if(p=="mount_cap" || p=="all")
        if(print==false)
        translate([0, 0, height+post_height+mount_cap_height])
            rotate([180, 0, 0])
                MountCap();
        else {
            translate([])
            translate([mount_radius+mount_cap_dia, 0, 0])
                MountCap();
        }
    if(print==false && (p=="hotend" || p=="all"))
        translate([0, 0, -1])
            E3DHotEnd();
    if(p=="pen_holder" || p=="all")
        if(print==false)
            translate([0, 0, height+pen_holder_height/2+1])
                PenHolder();
        else {
            translate([0, -mount_radius*2, pen_holder_height/2])
                PenHolder();
        }
}
echo("M3 bolts for mount posts when tapping into effector:", mount_cap_height-m3_cap_height+post_height+height*2/3);

