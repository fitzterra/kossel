// Origin: http://www.thingiverse.com/thing:788137
// Modified: Tom Coetser <fitzterra@icave.net> 2016
//   * A complete reorganization and quite a bit of rewritten code.
//   * Also combined all parts into one file with rendering and printing config
//     options.
include <configuration.scad>;
use <e3d-type-hotend.scad>;
use <e3d_v6_all_metall_hotend.scad>;

// Print and render options. Comment/uncomment those parts to be rendered or printed.
// This defines the hotend to use, see the comments in renderParts for parts
// that are affected.
hotend = 6;     // Either 5 for the E3Dv5 or 6 for the E3Dv6 hotend.
hotendv6mount = "clamp";    // For the split clamp moulded to the effector
//hotendv6mount = "holder";   // For v6 split holder mounted onto effector mount tabs

renderParts = [
    //"all",          // This is more usefull with print==true
    "effector",
    "hotend",       // Depends on hotend variable above
    "v6Clamp",   // Only rendered if hotend==6 and hotendv6mount=="clamp"
    "v6_holder", // Only rendered if hotend==6 and hotendv6mount=="holder"
    // -- Only when hotend is v5
    //"posts",
    //"groove_mount",
    //"mount_cap",
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
m3_bolt_head_d = 5.4;   // Head diameter of m3 cap head bolt
m3_bolt_head_h = 3.5;   // Head height of m3 cap head bolt

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
m3_cap_dia = m3_bolt_head_d + tol; // Diameter of the hex cap M3 screw for sinking
m3_cap_height = m3_bolt_head_h + 1.3;  // Cap height plus a little extra for sinking

// Pen holder params
pen_holder_height = height-4;
pen_holder_id = 9.3;                // Inner Diameter for pen hole
pen_holder_od = pen_holder_id + 8;  // Outer Diameter for pen hole

// E3d V6 parameters
v6ClampHeight = 12; // Height above effector for hot end top for v6
v6ZProbeMount = true; // True to add a mount block between the the rod cones
                      // at 180° to mount the detachable ZProbe top plate

// E3D V6 Holder that fits onto the standard V5 effector parameters
v6holder_rMajor = offset-4; // Radius for bottom side
v6holder_rMinor = offset-8; // Radius for top side
v6holder_height = 8;
v6holder_z_offs = v6holder_height; // Height offset for hotend top from bottom of holder.
v6holder_bolt_offs = 10;  // Offset for clamp bolts from center in horizontal plane
v6holder_tab_h = 5;     // Height of the tabs for mounting to the effector.


/**
 * Creates a cutter for cutting the center hole in the effector for a V6 hotend
 * using the upper clamp mount.
 *
 * The clamp is in two parts and to be able to get the effector out, the cut
 * should be inset slightly to the one side to allow the hotend to be inserted
 * and then slide back to fit into the mounting ridges.
 *
 * This module allows for creating a cutter for either the clamp, or the
 * effector. For the clamp itself, no sliding cut is needed. This is only
 * needed for the effector.
 *
 * @param slide: If true, creates a cuttor for the effector, if false if
 *               creates a cutter for the clamp.
 **/
module v6Cutter(slide=true) {
    $fn = 96;

    // These values are from e3d_v6_all_metall_hotend.scad for the Chinese
    // knockoff version of the E3D V6 hotend.
    cyl1 = [8, 3.7];        // Top cylinder where bowden fitting screws in
    cyl2 = [6, 6];          // Thinner cylinder for clamping
    cyl3 = [8, 6.6];        // Cylider below clamp cylinder all the way to fins
    cyl4 = [11.15, 10];     // Cylinder for fins - part height
    slideOffs = (cyl3[0] - cyl2[0])*2; // Length that will allow sliding hotend out

    translate([0, 0, v6ClampHeight+0.05]) {
        scale([1.05, 1.05, 1.05])
            e3d_knockoff(true, 0);
        if(slide) {
        translate([slideOffs, 0, 0])
            scale([1.05, 1.05, 1.05])
                e3d_knockoff(true, 0);
        scale([1.05, 1.05, 1.05])
            union() {
                translate([0, -cyl2[0], -cyl1[1]-cyl2[1]]) {
                    cube([slideOffs, cyl2[0]*2, cyl2[1]]);
                    translate([0, -(cyl3[0]-cyl2[0]), -cyl3[1]]) {
                        cube([slideOffs, cyl3[0]*2, cyl3[1]]);
                        translate([0, -(cyl4[0]-cyl3[0]), -cyl4[1]])
                            cube([slideOffs, cyl4[0]*2, cyl4[1]]);
                    }
                }
            }
        }
    }
}

/**
 * Creates a clamp to be placed on top of the effector for a V6 hotend. Either
 * the right or left side can be selected.
 *
 * The bolt parameters may need some adjustment depending on your needs.
 *
 * @param left: If true, generates the left side, else the right side.
 **/
module v6Clamp(left=true) {
    $fn = 96;
    boltLen = 25;
    boltInset = 3;
    boltHeadHeight = 3;
    boltHeadDia = m3_bolt_head_d + 0.6;    // 0.6 is for fit tollerance
    nutHeight = 6;

    difference() {
        cylinder(r1=offset-2, r2=offset*2/3, h=v6ClampHeight);
        for(y=[-offset/2, offset/2])
            translate([-boltInset, y, m3_nut_radius+3])
                rotate([0, 90, 0]) {
                    cylinder(r=(tapM3s?m3_tap_radius:m3_wide_radius),
                             h=boltLen, center=true);
                    translate([0, 0, boltLen/2])
                        cylinder(d=boltHeadDia, h=boltHeadHeight+10);
                    if(!tapM3s)
                        translate([0, 0, -boltLen/2-10])
                            cylinder(r=m3_nut_radius*1.05, h=nutHeight+10, $fn=6);
                }
        v6Cutter(false);
        translate([left?-0.5:-offset-2, -offset-2, -0.1])
            cube([offset+2.5, offset*2+4, v6ClampHeight+0.2]);
    }
}

/**
 * Module that generates the effector base
 **/
module EffectorE3D(v6clamp=false) {
    difference() {
        // Main effector including rod mount blocks and endcap mount blocks if not V6
        union() {
            // Main pug
            cylinder(r=offset-2, h=height, center=true, $fn=120);
            // Add the rod connectors and post mounting blocks for non v6
            for (a = [60:120:359])
                rotate([0, 0, a]) {
                    // Mount block posts to upper hotend end cap for non v6
                    if(!v6clamp || (a==180 && v6clamp && v6ZProbeMount))
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
        // Mounting holes for posts to upper hotend end cap if not V6
        if(!v6clamp || (v6clamp && v6ZProbeMount))
            for (a = !v6clamp ? [0:120:359] : [120])
                rotate([0, 0, a+60]) {
                    // Bolt hole
                    translate([0, mount_radius, 0])
                        cylinder(r=(tapM3s?m3_tap_radius:m3_wide_radius), h=2*height,
                                 center=true, $fn=12); 
                // Nut recess if not tapping
                if(tapM3s!=true)
                    translate([0, mount_radius, -height/2-0.1])
                        rotate([0, 0, 30])
                            cylinder(r=m3_nut_radius, h=5+0.1,
                                     center=false, $fn=6);

            }

        // Hole for hotend if not v6
        if(!v6clamp)
            translate([0, 0, -height/2-0.1])
                cylinder(r1=hotend_radius+1, r2=hotend_radius, h=height+1, $fn=120);
        else {
            translate([0, 0, height/2])
            v6Cutter();
        }
    }
    if(v6clamp)
            translate([0, 0, height/2])
        v6Clamp();
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

/*
 * This is another option for fitting an E3D v6 hotend, and is based on the
 * PenHolder. This will allow the V6 hotend to be clamped in a holder that fits
 * on top of the V5 effector and bolts on to the tabs between the rod holders
 * on the effector used for the V5 pillars.
 *
 * This mount should work almost better than the built in v6 mount option for
 * modifying the effector for a v6 fit.
 **/
module E3DV6Holder() {
    boltHeadDia = m3_bolt_head_d + 0.6;    // 0.6 is for fit tollerance
    
    // Width of the mounting tabs. This is hardcoded in EffectorE3D.
    tab_width = 7;
    // There is an additional 4mm from the center of the mount screw to end of
    // the mount tab on the effector.
    tab_len = mount_radius + 4;
    tab_height = 5;

    // Main hotend clamp
    difference() {
        // Clamp and mount tabs
        union() {
            // Base clamp
            cylinder(r=v6holder_rMajor, r2=v6holder_rMinor, h=v6holder_height, $fn=120);
            // Mounting tabs
            for(a=[0:120:359])
                rotate([0, 0, a])
                    translate([-tab_width/2, -tab_len, 0])
                        difference() {
                            // Tab
                            cube([tab_width, tab_len, v6holder_tab_h]);
                            // Mount hole
                            translate([tab_width/2, tab_len-mount_radius, -0.1])
                                cylinder(r=m3_radius, h=v6holder_tab_h+0.2, $fn=120);
                        }
        }
        // Cutout for hotend. NOTE: The v6Cutter positions the cutter at
        // v6ClampHeight which we need to neutralize here first before applying
        // v6holder_z_offs. The cutter should really not position to
        // v6ClampHeight anymore, but this first needs fixing everywhere
        // v6Cutter is used. 
        translate([0, 0, -v6ClampHeight+v6holder_z_offs])
            v6Cutter(false);
        // Bolt holes
        for(x=[-v6holder_bolt_offs, v6holder_bolt_offs])
            translate([x, 0, v6holder_height/2]) {
                // Shaft hole
                rotate([90, 0, 0])
                    cylinder(r=tapM3s?m3_tap_radius:m3_wide_radius,
                             h=v6holder_rMajor*2, center=true, $fn=92);
                // Head hole
                translate([0, -v6holder_rMajor, 0])
                    rotate([-90, 0, 0])
                        cylinder(d=boltHeadDia, h=v6holder_rMajor*5/8, $fn=92);
                // Nut recess if not tapping M3 holes
                if(!tapM3s)
                translate([0, v6holder_rMajor, 0])
                    rotate([90, 0, 0])
                        cylinder(r=m3_nut_radius+0.3, h=v6holder_rMajor*4/8, $fn=6);
            }
        // Slice it down the middel, leaving a 1mm gap
        translate([0, 0, v6holder_height/2])
            cube([v6holder_rMajor*2.1, 1, v6holder_height+2], center=true);
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

// Indicator for when using a V6 hotend and the moulded clamp fixed on top of
// the effector with the loose clamp
v6Moulded = hotend==6 && hotendv6mount=="clamp";
for (p=renderParts) {
    if(p=="effector" || p=="all")
        // Effector is always center whether printing or not
        translate([0, 0, height/2])
            EffectorE3D(v6Moulded);
    // Show the hotend only if not printing
    if(print==false && (p=="hotend" || p=="all"))
        translate([0, 0, hotend==5?-1:height+0.2+(hotendv6mount=="clamp"?v6ClampHeight:v6holder_z_offs)])
            if(hotend==5)
                E3DHotEnd();
            else
                color("silver")
                rotate([0, 0, 240])
                    e3d_knockoff();
    if(v6Moulded && (p=="v6Clamp" || p=="all"))
        translate([print?offset*1.5:0, 0, !print?height:0])
                v6Clamp(false);
    if(!v6Moulded && hotend==6 && (p=="v6_holder" || p=="all"))
        translate([print?offset*2.5:0, 0, !print?height:0])
            E3DV6Holder();
    if(hotend==5) {
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
        if(p=="pen_holder" || p=="all")
            if(print==false)
                translate([0, 0, height+pen_holder_height/2+1])
                    PenHolder();
            else {
                translate([0, -mount_radius*2, pen_holder_height/2])
                    PenHolder();
            }
    }
}
echo("M3 bolts for mount posts when tapping into effector:", mount_cap_height-m3_cap_height+post_height+height*2/3);

