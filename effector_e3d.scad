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
    "posts",
    "groove_mount",
    "mount_cap",
    "hotend",
    //"pen_holder",
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
post_rad = 4;   // Radius for round part of mount post - also half the square side width
fan_size = 30; // Fan width/height size. This effector is best with a 30x30 fan
fan_corner_rad = 2.25;  // Radius fan corners
fan_mount_hole_d = 24;   // Distance between mounting holes of the fan
fan_depth = 10;       // Thickness of fan
fan_blade_dia = fan_size-2; //Diameter of the hole for the blades 
fan_offs = 1.0; // The amount of clearance from the edge of the hotend hole to
                // the inside of the fan edge which will still allow the fan to
                // not interfere with the rod ends. 

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


/**
 * Generates a sample fan without blades
 **/
module FanSample(tapM3s=false) {
    $fn=80;

    mount_hole_coords = [ 
        [ fan_mount_hole_d/2,  fan_mount_hole_d/2, 0],
        [ fan_mount_hole_d/2, -fan_mount_hole_d/2, 0],
        [-fan_mount_hole_d/2,  fan_mount_hole_d/2, 0],
        [-fan_mount_hole_d/2, -fan_mount_hole_d/2, 0] 
    ];
    difference() {
        // Main fan mount cube with rounded corners
        minkowski() {
            cube([fan_size - fan_corner_rad*2,
                  fan_size - fan_corner_rad*2,
                  fan_depth/2], center=true);
            cylinder(r=fan_corner_rad, h=fan_depth/2, center=true);
        }
        // Central cutout
        cylinder(d=fan_blade_dia, h=fan_depth+0.2, center=true);

        // 4 mounting bolt holes for fan
        for (i = mount_hole_coords) {
            translate(i)
                cylinder(r=m3_radius, h=fan_depth+0.2, center=true);
        }                   
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

/**
 * Generates one mount post using post_rad and post_height defined above.
 **/
module Post() {
    $fn = 64;
    difference() {
        union() {
            cylinder(r=post_rad, h=post_height);
            translate([-post_rad, 0, 0])
                cube([post_rad*2, post_rad, post_height]);
        }
        translate([0, 0, -1])
            cylinder(r=m3_wide_radius, h=post_height+2);
    }

}

/**
 * Creates a "bracket" between two posts to which the fan can be mounted.
 * Note that although this is parameteric, the fan should still be able to fit
 * and also not interfere with the rod ends.
 **/
module FanPostsMount() {
    $fn=64;
    postWidth = post_rad*2;
    // Place a post in each required position
    difference() {
        // The solid stock from post to post to become the mount
        hull()
            for (a=[120, 240])
                rotate([0, 0, a])
                    translate([0, mount_radius, 0])
                        translate([0, 0, post_height/2])
                            cube([postWidth, postWidth, post_height], center=true);
        // We need to add the post mount holes seperately because the hull()
        // will close them if we add them when making the posts above.
        for (a=[120, 240])
            rotate([0, 0, a])
                translate([0, mount_radius, 0])
                    translate([0, 0, post_height/2])
                        cylinder(r=m3_wide_radius, post_height+0.2, center=true);
        // Cut the solid mount on the fan side to leave enough room so the fan
        // does not interfere with the rod ends. This is based on the amount of
        // offset for the fan from the hotend center hole.
        translate([0, -(hotend_radius+fan_offs+5), post_height/2])
            cube([hotend_radius*4, 10, post_height+6], center=true);
        // Hole for fan and mount screws
        translate([0, -hotend_radius, fan_size/2])
            rotate([90, 0, 0])
                union () {
                cylinder(d=fan_blade_dia+0.25, h=hotend_radius*2, center=true);
                // Mount holes
                for (x=[-fan_mount_hole_d/2, fan_mount_hole_d/2])
                    for (y=[-fan_mount_hole_d/2, fan_mount_hole_d/2])
                        translate([x, y, 0])
                            cylinder(r=m3_tap_radius, h=hotend_radius*2, center=true);
                }
        // Carve out for hotend
        translate([0, 0, -0.1])
            cylinder(r=hotend_radius, h=post_height+0.2);
        // Space for groove_mount
        translate([0, 0, post_height-groove_mount_height-0.5])
            cylinder(r=groove_mount_radius+0.5, h=groove_mount_height+0.6);
    }
}

/**
 * Alternative module for mount posts.
 * NOTE! Along with the Post() module, this is still a work in progress!!
 *
 * @param fanBracket: If true (default), it will create on post and one bracket
 *                    for a fan. If false, it will create 3 posts.
 * @param print: If true, layout will be for print, else it will be for assembly.
 **/
module MountPostsAssembly(fanBracket=true, showFan=true, print=false) {
    if(print==false) {
        // The number and positions for the posts depending on fanBracket.
        postsPos = fanBracket ? [0] : [0:120:359.9];
        // Place a post in each required position
        for (a=postsPos)
            rotate([0, 0, a])
                translate([0, mount_radius, 0])
                    Post(post_height, 4);
        // Add a fan bracket?
        if(fanBracket)
            FanPostsMount();
        // Include a sample fan?
        if(showFan)
            translate([0, -fan_depth/2-hotend_radius-fan_offs, fan_size/2])
                rotate([90, 0, 0])
                    color([20/255, 20/255, 20/255])
                        FanSample();
    } else {
        // The number and positions for the posts depending on fanBracket.
        postsPos = fanBracket ? [0] : [0:2];
        for(a=postsPos)
            translate([0, 0, 4])
                rotate([-90, 0, 0])
                    translate([10*a, 0, 0])
                        Post(post_height, 4);
        // Fan bracket?
        if(fanBracket)
            translate([0, post_height, 0])
            rotate([90, 0, 0])
                translate([hotend_radius*1.5+10, hotend_radius+fan_offs, 0])
                    FanPostsMount();

    }
}

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
                MountPostsAssembly(print=print);
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

