/**
 * Model of 24V power supply to be used for the printer.
 *
 * This is modeled from images and only the main outer dimensions and the rest
 * of the dimensions are educated guesses until I get the PSU to make proper
 * measurements.
 **/


module PSU() {
    w = 115;    // Width
    l = 215;    // Length
    h = 50;     // Height
    plateTh = 2;    // Thickness of the plate
    bottomLip = 6;  // Lip + PCB height
    connInset = 23; // Inset amount in box for connectors
    connW = 11;
    connH = 12;
    connD = 15;
    connWallTh = 0.8;
    connCnt = 9;
    wireDia = 3;
    wireColors = ["red", "red", "red",          // The 24V+ outputs
                  "black", "black", "black",    // The output GNDs
                  "green", "brown", "blue"];    // The 220V input

    color("silver")
    difference() {
        // The main box
        cube([w, l, h]);
        // The cutout for the connectors side
        translate([plateTh, -1, bottomLip])
            cube([w-2*plateTh, connInset+1, h]);
    }
    // The connectors
    translate([16, 1, bottomLip])
        for(n=[0:connCnt-1]) {
            translate([n*(connW-connWallTh), 0, 0]) {
                color([55/255, 55/255, 55/255], 1)
                difference() {
                    cube([connW, connD, connH]);
                    translate([connWallTh, -1, connH*6/10])
                        cube([connW-2*connWallTh, connD-connWallTh+1, connH]);
                }
                // A wire
                translate([(connW-connWallTh)/2, -5, connH*6/10+wireDia])
                    rotate([-90, 0, 0])
                        color(wireColors[n])
                        cylinder(d=wireDia, h=connD+5, $fn=90);
            }
    }
}

PSU();
