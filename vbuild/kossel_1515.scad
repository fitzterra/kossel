// Virtual build based on Mini Kossel Visual Calculator by Jaydmdigital:
// https://github.com/Jaydmdigital/mk_visual_calc

use <../microswitch.scad>;

$fn=60;

//Defines
sin60 = 0.866025;
cos60 = 0.5;

// Config
STLDir = "../stl/"; // Must contain trailing '/'
explode = 0.0; // Set > 0.0 to push the parts apart

// Colors
frame_color=[0/255, 255/255, 120/255, 0.98];
slide_color=[0/255, 80/255, 255/255, 0.98];
carriage_color=[0/255, 180/255, 255/255, 0.98];
endstop_color=[0/255, 80/255, 255/255, 0.98];
rod_color=[0.1,0.1,0.1,0.88];
t_slot_color="silver";
plate_color=[0.7,0.7,1.0,0.5];

// The minimul angle of the diagonal rod as full extension while still being on
// the print surface.
// Translation: With any carriage at it's lowest level, the rods on that
// carriage will angle towards the hosrizontal plane. This will move the
// effector to the furthest point away from this carriage - assuming of course
// that the other carriages moves up to allow this one to move down and extend
// the effector away from itself as described.
// The angle that the rods make at the effector side with the horizontal plane,
// is what this value limits. If this angle is 0, the rods will be level on the
// horizontal plane, but is probably not a good idea. This angle is used to
// calculate the required rod length.
delta_min_angle = 20;

// Height of motor frame vertex
frame_motor_h = 45;
frame_top_h = 15;
 
// Length of extrusions for horizontals, need cut length
frame_extrusion_l = 360;
// Length of extrusions for towers, need cut length
frame_extrusion_h = 650;
frame_extrusion_w = 15;
// The distance from the center of the extrustion to the butt edge of the
// vertex. Comes from the vertex.scad file
vertex_offset = 22.5;
// Used when calculating offsets
frame_depth = frame_extrusion_w/2;
frame_wall_thickness = 3.6;
// Need the distance from the center of the vertical beam to the center of the
// machine
frame_r = ((frame_extrusion_l + vertex_offset)/2) / sin60;
//cos(60) = Adjacent/hypotenuse so hypotenuse = adjacent/cos(60)
frame_size = frame_r + explode;
frame_offset = (frame_r * cos60) + frame_extrusion_w + explode;
// Distance to move a centered extrusion from center of build arae to where it
// needs to be in relation to verticies. There is 10mm play at the top to allow
// tensioning.
frame_top = frame_extrusion_h - 10 - frame_top_h + explode; 

// Height of effector.
effector_h = 8;

// The amount of space from the edge of the frame to front carriage mounting
// face of the slider. This comes from the mgn12_truck_thickness value in
// tower_slides.scad and tries to use the same amount of space as the original
// MGN12C rail and truck would have done. 
slider_frame_offset = 13;

// From endstop.scad
endstop_h = 15;
// The extra height added to the bottom of the endstop (below 0) by the
// microswitch
endstop_ms_h = endstop_h + 2;
// From endstop.scad
endstop_thickness = 9;

/**** Carriage parameters from carriage.scad ****/
carriage_height = 40;
// The distance from the bottom of the carriage to the pivot point, from the
// carriage.scad and after the 4mm shift to align the bottom of the
// carriage.stl with 0
carriage_pivot_offset = 32;
// From carriage.scad
carriage_depth = 13;
// How far to move the carriage away from center
carriage_r_offset = slider_frame_offset + frame_depth + explode;

// Traxxas 5347 specs
// Width at the balljoint. From Banggood and another online source this seems
// to be 10mm, but measured on a sample at GrabCAD designed from actual
// measurements, it seems to be 7mm. At 10mm it seems too big to fit the
// effector, so will make it 6mm for now and measure when they arrive.
// TODO: Get correct meassurement
balljoint_w = 7;
balljoint_d = 5.4;  // Diameter of balljoint


// ~~~ Diagonal rods ~~~
// Horizontal distance from center to pivot from effector.scad
effector_offset = 20;
DELTA_SMOOTH_ROD_OFFSET = frame_r;
// The DELTA_RADIUS is the length from a rod pivot point on the effector, to
// the pivot point on that rod on the carriage, but in a horizontal plane. In
// other words, draw a line vertically down from the center of the pivot point
// on the carriage, level with the center of the pivot point for that rod on
// the effector. The distance from this line to the effector pivot point is
// this value. 
DELTA_RADIUS = DELTA_SMOOTH_ROD_OFFSET - effector_offset - (slider_frame_offset + carriage_depth/2 + frame_depth );
// Rember we need to subtract the effect offset so we account for keeping the
// hotend tip on the edge of the build surface.
// Translation: Calculate the hypotenuse of the triangle formed with the
// effector at it's furthest point away from the carriage (twice the
// DELTA_RADIUS less one effector_offset to make sure the hotend is still on
// the build surface) as the adjacent side and the delta_min_angle at the pivot
// point of the rod on the effector. The hypotenuse of this triangle is the
// exact length required for the delta rods.
DELTA_DIAGONAL_ROD =((DELTA_RADIUS*2) - effector_offset) / cos(delta_min_angle);

// Radius for the diagonal rods.
rod_r = 6/2;
// Angle of delta diagonal rod when homed
delta_rod_angle = acos(DELTA_RADIUS/DELTA_DIAGONAL_ROD);
// The vertical distance from the pivot on the effector to the pivot on the carriage
delta_vert_l = sqrt((DELTA_DIAGONAL_ROD*DELTA_DIAGONAL_ROD)-(DELTA_RADIUS*DELTA_RADIUS));
// The -4 is the thickness of the motor frame wall
surface_r = DELTA_SMOOTH_ROD_OFFSET * sin(30) + effector_offset - frame_depth - frame_wall_thickness ;


echo("DELTA_RADIUS:", DELTA_RADIUS, "mm");
echo("DELTA_SMOOTH_ROD_OFFSET:",DELTA_SMOOTH_ROD_OFFSET,"mm");
echo("DELTA_DIAGONAL_ROD:",DELTA_DIAGONAL_ROD,"mm");
echo("DELTA vertical length:",delta_vert_l,"mm");
echo("Delta_rod_angle:",delta_rod_angle,"mm when homed");
echo("Build plate radius:",surface_r,"mm");

// The max z height position the carriage slider may be. This position is
// BOTTOM of the slider to make positioning easier.
carriage_max_z = frame_top - endstop_ms_h - carriage_height;
// The height at which to place the carriages - this will also determine the
// height of the effector and extruder.
carriage_zpos = carriage_max_z - 200;

// Position of the bottom of the effector (or Spider)
effector_z = carriage_zpos + carriage_pivot_offset - delta_vert_l - effector_h/2;

calc_slider_z = frame_top - carriage_height - endstop_h - delta_vert_l - frame_top_h;
//effector_z = calc_slider_z; // need to know where to draw the effector

plate_d = surface_r * 2;
plate_thickness = 3;
plate_z = plate_thickness/2 + frame_motor_h + 3.82;// + plate_thickness; //not added yet, but there will be glass tabes (5mm) and the plate thickness is 3)

hotend_l = 45;
calc_max_z = carriage_max_z - ( plate_z + hotend_l + delta_vert_l);
echo("Max Build Height:",calc_max_z,"mm assuming a narrow tower or cone shaped build.");

// Function to calculate the STL path for importing STLs from. It takes one
// argument which is the name of the STL to import, and returns a string which
// is the correct path to the STL. This allows STLs to be placed in subdirs
// but still have a central place to define the paths.
function STLPath(stl) = str(STLDir, stl);

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

/**
 * Module to draw one rod with Traxxas 5347 rod ends.
 * The rod will be drawn vertially with the center of the bottom ball joing
 * pivot point at 0,0,0.
 **/
module Rod() {
    pivot_len = 17.2; // Length of one rod end from end to center pivot point
    rod_len = DELTA_DIAGONAL_ROD - 2 * pivot_len;

    // Bottom rod end
    color("black")
        translate([0, 0, pivot_len])
            rotate([180, 0, 90])
                import("Traxxas5347.stl");
    // Balljoint simulator
    color("silver")
        rotate([0, 90, 0])
            cylinder(d=balljoint_d, h=balljoint_w, center=true);
    // Rod
    color(rod_color)
        translate([0, 0, pivot_len])
            cylinder(h=rod_len, r=rod_r);
    // Top rod end
    color("black")
        translate([0, 0, pivot_len+rod_len])
            rotate([0, 0, 90])
                import("Traxxas5347.stl");
    // Balljoint simulator
    color("silver")
        translate([0, 0, 2*pivot_len+rod_len])
        rotate([0, 90, 0])
            cylinder(d=balljoint_d, h=balljoint_w, center=true);
}

/**
 * Module to position a slider in the correct color on a vertical extrusion at
 * the correct height.
 **/
module Slider() {
    // Uncomment to have a reference for testing placement
    /*
    color("silver")
        extrusion_15(frame_top);
    */
    translate([0, 0, carriage_zpos])
        color(slide_color)
            import(STLPath("tower_slides.stl"));
}

/**
 * Module to place a carriage on a slider in the correct color and at the
 * correct height.
 **/
module Carriage() {
    // Uncomment to have a reference for testing placement
    /*
    color("silver")
        extrusion_15(frame_top);
    Slider();
    */

    color(carriage_color)
    // Position onto slider
    translate([0, carriage_r_offset, carriage_zpos+16])
        rotate([90, 0, 180])
            import(STLPath("carriage.stl"));
}

/**
 * Rotates and places the endstop STL file so it fit onto a vertical extrusion
 * that are centered at [0,0].
 *
 * @param level: Top ("t") or bottom ("b") endstop.
 * @param ms: Draw microswitch: true or false
 **/
module Endstop(level="b", ms=false) {
    // Uncomment to have a reference for testing placement
    /*
    frame_top = 50;
    color("silver")
        extrusion_15(frame_top);
    */

    // Rotate around y based on top or bottom
    yRot = level=="b" ? 180 : 0;

    // Z Position based on top or bottom
    // TODO: Not sure how to calculate the bottom position yet.
    zPos = level=="b" ? 100 : frame_top - frame_extrusion_w;

    // Translation to do final height positioning after extrusion positionaing
    // and rotation
    translate([0, 0, zPos])
        // Rotation to attach to the "inside" (y direction) of the frame and be
        // the right side up based the level.
        rotate([0, yRot, 180])
            // Position next to the frame
            translate([0, -(endstop_thickness+frame_extrusion_w)/2, 0]) {
                color(endstop_color)
                    import(STLPath("endstop.stl"));
                // Microswitch?
                if (ms) {
                color("darkgray", 0.7)
                // TODO: hardcoded values here should be parameterized.
                translate([0, -(endstop_thickness+6)/2, 5.5])
                    rotate([0, 180, 0])
                        microswitch();
                }
            }
}

/**
 * Module to draw the top or bottom horizontal frame extrusions on the given
 * side.
 *
 * @param level: Bottom ("b") or top ("t") extrusion. For the bottom level,
 *        both extrusions will be drawn at frame_motor_h apart.
 * @param side: Front ("f"), left ("l") or right ("r") side. The front is
 *        always parallel to the X axis. The extrusion will be drawn so that
 *        the printer center is always at 0,0 in the X,Y plane.
 **/
module frameHorizontal(level="b", side="f") {
    // Z offsets for each frame part to draw
    parts = level=="b" ? [0, frame_motor_h-frame_extrusion_w] : [frame_top];
    // Rotation direction for the side
    zRot = side=="f" ? 0 : (side=="l" ? -120 : 120);
    // TODO: calculate exploded view offsets to make the bottom parts go down
    // and out in the side angle, the bottom top part only go out in the side
    // angle, and the top part to go up and out in the side angle - based on
    // the explode value.
    color(t_slot_color)
        // Rotate to the correct side
        rotate([0, 0, zRot])
            // The bottom frame has 2 parts (z offsets) and top will only have 1
            for (z=parts)
                // From poistion [0,0,0], place the extrusion, allowing for an
                // exploded view
                translate([-frame_extrusion_l/2, -frame_offset,
                           z+frame_extrusion_w/2-explode])
                    rotate([0,90,0])
                            extrusion_15(frame_extrusion_l);
}

/**
 * Module to draw any part of any of the three towers.
 *
 * @param pos: Which of the three to draw: "l"=left, "r"=right or "b"=back
 * @param part: Which part to print: "extrusion", "frame, "slider", "carriage"
 *        or "ensdtop"
 * @param level: The level for the part: "t" for top, "b" for bottom. This is
 *        only applicable to "frame" ("b" level draws the motor mount frame
 *        parts, and "t" draws the top frame parts) and "endstop". 
 **/
module towerPart(pos="l", part="slider", level="b") {
    // Calculate the center of the verticle extrusion
    xyz = pos=="l" ? [-(sin60*frame_size), -(cos60*frame_size), 0] : (
          pos=="r" ? [(sin60*frame_size), -(cos60*frame_size), 0]:
                     [0, frame_size, 0]
     );
    // Calculate the Z rotation angle
    zRot = pos=="l" ? -60 : (pos=="r" ? 60 : 180);
    // Position it
    translate(xyz)
        // Rotate it to the frame
        rotate([0, 0, zRot])
            if(part=="extrusion")
                color(t_slot_color)
                extrusion_15(frame_extrusion_h);
            else if(part=="frame")
                color(frame_color)
                if(level=="b")
                    import(STLPath("frame_motor.stl"));
                else
                    translate([0, 0, frame_top])
                        import(STLPath("frame_top.stl"));
            else if(part=="slider")
                Slider();
            else if(part=="carriage")
                Carriage();
            else if(part=="endstop")
                Endstop(level, true);
}

/**
 * Module to draw the "spider" - effector and diagonal rods.
 **/
module Spider() {
    // The effector turned upside down and positioned at the correct angle and
    // height to be centered in the XY plane and the bottom on 0 in the Z plane.
    translate([0, 0, effector_h])
        rotate([0,180,60])
            color(frame_color)
                import(STLPath("effector.stl"));
    // Three sets of rods connected to the effector at 120° angles
    for(s=[0:2])
        rotate([0, 0, s*120])
            // Two rods on either side of the effector connector. The 1.5 extra
            // is half the witdh of the traxxas joint
            for(x=[-effector_offset-balljoint_w/2, effector_offset+balljoint_w/2])
                translate([x, 20, effector_h/2])
                    rotate([-(90-delta_rod_angle),0,0])
                        Rod();
}

module Printer() {
%cylinder(r=frame_r, h=1, center=true);
// All the horizontal frame parts.
for (s = ["f", "l", "r"])
    for (l = ["b", "t"])
        frameHorizontal(l, s);

// The vertical tower parts
for(p=["l", "b", "r"]) {
    towerPart(p, "extrusion");
    towerPart(p, "slider");
    towerPart(p, "carriage");
    for (l = ["b", "t"]) {
        towerPart(p, "frame", l);
        towerPart(p, "endstop", l);
    }
}

// The spider
translate([0, 0, effector_z])
    Spider();

//hotend
*translate([0,0,frame_motor_h + effector_h + effector_z -hotend_l/2 - explode*2]) color(t_slot_color) cylinder(h=hotend_l,r=10,center=true);

// Build plate
translate([0,0,plate_z+explode])color(plate_color)cylinder(h=plate_thickness,r=plate_d/2,center=true,$fn=120);
// Glass tabs
*for(i=[0:2]) {
 rotate(i*120){
  translate([0,-frame_offset,frame_motor_h+explode/4]) color(frame_color)import("glass_tab.stl"); //X-Z
  translate([0,-frame_offset,frame_motor_h+7.5+3+explode*2]) rotate([0,180,-30]) translate([2,-2,0])color(frame_color)import("Spiral_Bed_Clamp.stl"); // needed to translate the clamp so the hole was centered.
 }
}

//translate([20,20,frame_motor_h + effector_h/2 + effector_z - explode])
translate([20,20,effector_h/2 + effector_z - explode])
    rotate([0,-90,-90])
        color("blue")
            cylinder(h=DELTA_RADIUS, r=rod_r);
//translate([20,20+DELTA_RADIUS,frame_motor_h + effector_h/2 + effector_z - explode])
translate([20,20+DELTA_RADIUS,effector_h/2 + effector_z - explode])
    rotate([0,0,-90])
        color("orange")
            cylinder(h=delta_vert_l, r=rod_r);
//Ramps mount
//translate([-80,145,40])rotate([0,0,-120]) color(frame_color)import("mega2560_kutu_Kulak.stl");
}

Printer();

*translate([0, 0, frame_motor_h + effector_h/2 + effector_z])
    color([240/255, 90/255, 100/255], 0.1)
    difference() {
        cylinder(r=DELTA_RADIUS+effector_offset, h=2, center=true);
        cylinder(r=effector_offset, h=4, center=true);
    }
