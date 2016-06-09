/**
 * Bracket to (possibly) temporarily mount a switch and power socket to the
 * PSU. May be kept or removed once I have decided where the PSU goes.
 **/
use <fillets/fillets.scad>
$fn=64;

module PowerSocketBracket() {
    t = 3;  // Thickness of all parts
    w = 50; // Base width
    d = 5+5+t; // Depth of base
    h = 16; // Height of mount uprights - on top of base
    sw = 28;    // Width of the socket between the mount uprights
    psu_mc = 23; // Distance between centers of PSU mounting holes

    M4hd1 = 8;   // Diameter of top of M4 sunken head screw
    M4hd2 = 4.2;   // Diameter of bottom (shaft side) of M4 sunken head screw
    M4hh = 2.7; // Height of M4 sunken screw head

    s_mc = 40;  // Centers of socket mount holes
    s_mh = 9.5; // Height of socket mount hole from base
    s_mhd = 2.5; // Diameter of socket mount hole - will get a thread cut

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
        for(x=[(w-psu_mc)/2, (w+psu_mc)/2])
            translate([x, (d-t)/2, -0.1]) {
                cylinder(d=M4hd2, h=t);
                translate([0, 0, t-M4hh])
                    cylinder(d1=M4hd2, d2=M4hd1, h=M4hh+0.5);
            }
        // Socket holes
        for(x=[(w-s_mc)/2, (w+s_mc)/2])
            translate([x, d-t-0.1, t+s_mh])
                rotate([-90, 0, 0])
                    cylinder(d=s_mhd, h=t+0.2);
    }
}


PowerSocketBracket();
