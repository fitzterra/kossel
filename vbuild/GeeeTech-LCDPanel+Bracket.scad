// LCD Panel from GeeeTech and brackets to mount it to the front bottom of the printer.

$fn = 64;

// Draw options
print = true;      // Set true to draw for printing
assemble = true;    // Set true to show an assembly of the brackets and panel if not printing

// Bracket params
d = 40;     // Total depth
h = 45;     // Total height
bw = 10;    // Width of the bracket
tw = 10;    // Width of the extrusion tabs
t = 3;      // Overall thickness
gd = 36;    // Depth for the outer edge of the gusset support
gh = 41;    // Height for the upper edge of the the gusset support
ga = atan(gh/gd);   // Angle for the gusset support
psd = 5;    // The depth of the panel supports
psl = 7;    // The length of the panel supports



// LCD params
pcbT = 1.6;     // LCD carrier PCB thickness

// Carier board params
crX = 150;      // Length
crY = 55.3;     // Width
crMountHoleD = 4;   // Mount holes diameter
crMountHoleOffs = 1;    // Mount hole offset from edges
crColor = "white";

// The buzzer, encoder and button are centered around this offset from left
ctrlXCent = crX-13.3;
// Buzzer
bzDia = 12;
bzY = crY-5-bzDia/2;
bzZ = 10;
bzColor = [20/255, 20/255, 20/255];
// Encoder
encS = 12;  // It is a square of this size
encY = 19.5;
encZ = 6.5;
encShtD = 6;
encShtZ = 19.9;
encColor = "silver";
// Button
btnS = 6.5;
btnY = 4.8;
btnZ = 2.1;
btnBtnD = 3;
btnBtnZ=1;
btnColor = "Silver";
btnBtnColor = "orange";
// Connectors
ctnW = 20;
ctnD = 8.7;
ctnH = 9;
ctnColor = [20/255, 20/255, 20/255];
// Connecters are both this far from the bottom
ctnY = 24;
ctnX = [44.5, 44.5+ctnW+2.4];   // X pos for each connector
// SDCard slot
sdW = 26.25;
sdD = 26.5;
sdH = 3;
sdColor = "Silver";
sdX = 0;
sdY = 8.25;

// LCD pcb
lpW = 98;
lpD = 60;
lpMountHoleD = 3;   // Mount holes diameter
lpMountHoleOffs = 1.25;    // Mount hole offset from edges
lpColor = "green";
// LCD
lcdW = lpW;
lcdD = 40;
lcdH = 9.8;
lcdColor = [20/255, 20/255, 20/255];
lcdX = 0;
lcdY = 10;

// Panel placements
lcdBoardX = 14;
lcdBoardY = -8;
lcdBoardZ = 5;

// The back carrier board with button, piezo, rotary encoder and card slot
module CarrierBoard() {
    // Board with mount holes
    difference() {
        color(crColor)
            cube([crX, crY, pcbT]);
        for(x=[crMountHoleOffs+crMountHoleD/2, crX-crMountHoleOffs-crMountHoleD/2])
            for(y=[crMountHoleOffs+crMountHoleD/2, crY-crMountHoleOffs-crMountHoleD/2])
                translate([x, y, -1])
                    cylinder(d=crMountHoleD, h=pcbT+2);

    }
    // The buzzer
    translate([ctrlXCent, bzY, pcbT])
        color(bzColor)
            cylinder(d=bzDia, h=bzZ);
    // The encoder
    color(encColor)
        translate([ctrlXCent-encS/2, encY, pcbT]) {
            cube([encS, encS, encZ]);
            // The shaft
            translate([encS/2, encS/2, encZ])
                cylinder(d=encShtD, h=encShtZ);

        }
    // The button
    translate([ctrlXCent-btnS/2, btnY, pcbT]) {
        color(btnColor)
            cube([btnS, btnS, btnZ]);
        translate([btnS/2, btnS/2, btnZ])
            color(btnBtnColor)
                cylinder(d=btnBtnD, h=btnBtnZ);
    }
    // The connectors and plugs
    color(ctnColor)
    for(x=ctnX) {
        // Socket
        translate([x, ctnY, -ctnH])
            cube([ctnW, ctnD, ctnH]);
        // Plug
        translate([x+1.3, ctnY+1.3, -ctnH-9])
            cube([ctnW-2*1.3, ctnD-2*1.3, 9]);
    }
    // SD Card slot
    translate([sdX, sdY, -sdH])
        color(sdColor)
            cube([sdW, sdD, sdH]);
}

// LCD board
module LCD() {
    // The pcb
    difference() {
        color(lpColor)
            cube([lpW, lpD, pcbT]);
        for(x=[lpMountHoleOffs+lpMountHoleD/2, lpW-lpMountHoleOffs-lpMountHoleD/2])
            for(y=[lpMountHoleOffs+lpMountHoleD/2, lpD-lpMountHoleOffs-lpMountHoleD/2])
                translate([x, y, -1])
                    cylinder(d=lpMountHoleD, h=pcbT+2);
    }
    // The LCD
    translate([lcdX, lcdY, pcbT])
        color(lcdColor)
            cube([lcdW, lcdD, lcdH]);
}

// The panel with carrier board and LCD board
module LCDPanel() {
    CarrierBoard();

    translate([lcdBoardX, lcdBoardY, lcdBoardZ])
        LCD();
}


// The bracket to mount to the frame.
// Default is to draw the right hand side, but passing side as "l" will draw
// the mirrored left hand side.
module Bracket(side="r") {

    mirror([side=="r" ? 0 : 1, 0, 0])
    difference() {
        union() {
            // The lower bracket
            translate([0, -d, 0])
                cube([bw, d, t]);
            // The back support bracket
            translate([0, -t, 0])
                cube([bw, t, h]);
            // The support gusset
                translate([0, -gd, 0])
                    rotate([-90+ga, 0, 0,])
                        cube([bw, t, h*1.3]);
            // The top LCD Panel support
            translate([0, -t, h])
                rotate([-90+ga, 0, 0,])
                    translate([0, 0, -psl])
                        cube([bw, psd, psl]);
            // The bottom LCD Panel support
            translate([0, -d, t])
                rotate([-90+ga, 0, 0,])
                    translate([0, 0, 0])
                        cube([bw, psd, psl]);
            // The mounting tabs
            translate([bw, -t, 0])
                difference() {
                    cube([tw, t, h]); 
                    translate([-1, -1, 15])
                        cube([tw+2, t+2, 15]);
                    for(z=[15/2, h-15/2])
                        translate([tw/2, -1, z])
                            rotate([-90, 0, 0])
                                cylinder(d=3, h=t+2);
                }
        }
        // Mount holes for the panel
        translate([bw-1-crMountHoleD/2, -d, t])
            rotate([-90+ga, 0, 0])
                for(z=[crMountHoleOffs+crMountHoleD/2, crY-crMountHoleOffs-crMountHoleD/2])
                    translate([0, -1, z])
                        rotate([-90, 0, 0])
                            cylinder(d=3, h=15);
        // Remove the overhang sticking out the bottom
        translate([-1, -d, -20])
            cube([bw+2, d, 20]);
        // Remove the overhang sticking out the back
        translate([-1, 0, 0])
            cube([bw+2, 20, h*1.3]);
    }
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


if(print) {
    translate([2, 0, 0])
    rotate([0, -90, 90])
        Bracket("r");
    translate([-2, 0, 0])
    rotate([0, 90, -90])
        Bracket("l");
} else if (assemble) {
    translate([crX-bw, 0, 0])
        Bracket("r");
    translate([bw, 0, 0])
        Bracket("l");
    translate([0, -d, t])
        rotate([ga, 0, 0])
            LCDPanel();

    color("Silver")
    translate([-30, 15/2, 15/2])
    rotate([0, 90, 0]) {
        extrusion_15(crX+60);
        translate([-30, 0, 0])
            extrusion_15(crX+60);
    }
}
