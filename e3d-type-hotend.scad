// E3D or Chinese knockoff Hottend
//
// E3D Heatsink source files: http://files.e3d-online.com/Drawings/E3D_Heat_Sink.jpg

$fn = 120;

// Parameters from sketch
// Fin details
finDia = 25;    // Diameter of a fin
finTh = 3.4-2.2;// Thickness of one fin
fin2fin = 2.2;  // Distance between fin
fins = 10;      // Number of fins
// Top mount flang info
fin2flMin = 2.1;// Distance from top fin to the thin minor flange lip
flDia = 16;     // Diameter for 2 major and one minor mount flanges
flTh = 3.7;     // Mounting flange thickness
fl2fl = 5.5;    // Distance btween mounting flanges.
// Center shafts diameters and heights
cs1 = 15;       // Widest part at the bottom closes to nossle, up to 6th fin
cs1H = 6*(fin2fin+finTh)-fin2fin; // Height for this part, incl first & last fins
cs2 = 13;       // Second part between 6th and 7th fin
cs2H = fin2fin+finTh; // Height for this part, including last fin
cs3 = 9;        // Thinest 3rd part from 7th fin and top mount flange
cs3H = 3*(fin2fin+finTh)+fin2flMin+finTh+fin2flMin;
cs4 = 12;       // Section at the top between the mount flanges
hsHeight = 50.1;// Overall heatsink height

/**
 * Module to draw and E3D or clone hotend.
 **/
module E3DHotEnd() {
    /**
     * Generates the heatsink part.
     **/
    module HeatSink() {
        difference() {
            union() {
                // Bottom Shaft
                cylinder(d=cs1, h=cs1H);
                // First six fins
                for (f=[0:5])
                    translate([0, 0, f*(finTh+fin2fin)])
                        cylinder(d=finDia, h=finTh);
                // Move to above fin 6
                translate([0, 0, cs1H]) {
                    // The single thinner center shaft
                    cylinder(d=cs2, h=cs2H);
                    // One more fin above this
                    translate([0, 0, fin2fin])
                        cylinder(d=finDia, h=finTh);
                    // Move to above 7th fin
                    translate([0, 0, cs2H]) {
                        // The third center shaft part
                        cylinder(d=cs3, h=cs3H);
                        // Next 3 fins. Each fin needs a fin2fin space first
                        for (f=[0:2])
                            translate([0, 0, f*(finTh+fin2fin)+fin2fin])
                                cylinder(d=finDia, h=finTh);
                        // The minor mount flange
                        translate([0, 0, 3*(fin2fin+finTh)+fin2flMin])
                            cylinder(d=flDia, h=finTh);
                        // Skip to bottom of bottom mount flange
                        translate([0, 0, cs3H]) {
                            cylinder(d=flDia, h=flTh);
                            // Mount shaft after skipping past bottom mount flange
                            translate([0, 0, flTh]) {
                                cylinder(d=cs4, h=fl2fl);
                                // Top flange
                                translate([0, 0, fl2fl])
                                    cylinder(d=flDia, h=flTh);
                            }
                        }
                    }
                }
            }

            // Cut out center path 
            translate([0, 0, -0.1])
                cylinder(d=6, h=hsHeight+0.2);
            // And top bowden connected space
            translate([0, 0, hsHeight-6])
                cylinder(d=10, h=6+0.2);
            translate([0, 0, hsHeight-10])
                cylinder(d1=6, d2=10, h=4+0.1);

        }
    }

    module HeatBreak() {
        parts = [
        //   dia, hght, z]
            [6  ,  5.5, 0.0],   // Bottom thread going into heater block [d, h]
            [4.7,  2.5, 5.5],   // Smooth heat break part [d, h]
            [6  , 14.0, 8.0],   // Thread part into heatsink [d, h]
            [4.7,  4.0, 22 ],   // Smooth part at top joining upper channel [d, h]
        ];
        for (p=parts) {
            translate([0, 0, p[2]])
                cylinder(d=p[0], h=p[1]);
        }
    }

    module HeaterBlock() {
        w = 20;
        d = 20;
        h = 10;

        difference() {
            translate([-w/2, -3-6/2, 0])
                cube([w, d, h]);
            translate([0, 0, -0.1])
                cylinder(d=6, h=h+0.2);
        }
    }

    module Nossle() {
        threadH = 5;    // Thread height
        threadD = 6;    // Thread diameter
        nutH = 3.5;     // Nut height
        nutD = 9.1;     // Nut diameter (furthers oposite corners)
        tapH = 3;       // Taper height
        tapD1 = 1;
        tapD2 = 4.6;

        difference() {
            union() {
                // Thread going into heater block
                cylinder(d=threadD, h=threadH);
                // Hex nut part
                translate([0, 0, -nutH])
                    cylinder(d=nutD, h=nutH, $fn=6);
                // Tapper part
                translate([0, 0, -nutH-tapH])
                    cylinder(d1=tapD1, d2=tapD2, h=tapH);
            }
            translate([0, 0, -nutH-tapH-0.1])
                cylinder(d=0.3, h=tapH+nutH+threadH+0.2);
        }

    }

    color("Silver") {
        HeatSink();
        translate([0, 0, -8])
            HeatBreak();
        translate([0, 0, -2.5-10])
            HeaterBlock();
    }
    color("DarkGoldenrod")
    translate([0, 0, -2.5-10])
        Nossle();

}


E3DHotEnd();

