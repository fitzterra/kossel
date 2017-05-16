$fn = 100;

/**
 * Simple positioning knob.
 *
 * This is a simple parametric knob though which the main rotary bolt is pushed
 * and having the bolt head fit into a recess in the knob for grip.
 *
 * @param od: Required outer diameter for the knob
 * @param kp: A percentage value that describes the relationship between the
 *            outer diameter and the rounding dimeter of the outer "knobs" - play
 *            with it :-)
 * @param kb: The number of "knobbies" around the outer edge
 * @param t: Knob thickness
 * @param bd: Bolt/shaft diameter
 * @param hs: Percentage to scale the shaft hole to allow for print tolerence
 *            if needed.
 * @param sf: If the shaft the knob fits on has a flat surface, this is the
 *            distance from the flat to the opposite edge of the shaft
 * @param sh: If you want a shaft protruding from the back of the knob, this is
 *            the length of this shaft .
 * @param sd: If sh above is given, then this is the diameter of the protruding
 *            shaft.
 * @param shl:If adding a protruding shaft, the hole in the shaft will be the
 *            full length of the shaft and extend through the knob face if this
 *            value is 0 (the default). Set this to a depth to make the hole in
 *            the shaft if it should not extrend through the knob.
 * @param dd: To add a finger divot on the right, set this to the diameter of
 *            the sphere used to make the divot, and then set dr below.
 * @param dr: If adding a finger divot, this is the amount to recess it by.
 * @param c: color
 **/
module Knob(od=50, kp=50, kb=6, t=12, bd=6, hs=0, sf=0, sh=0, sd=0,
            shl=0, dd=0, dr=0, c="orange") {
    or = od/2;      // Outer radius
    cr = or*kp/100; // Center rotation radius
    br = or-cr;     // Bump/knob radius to maintain outer diameter
    // Calculate angle for each outer cylinder
    a = round(360/kb);

    module ShaftCutter() {
        h = (shl==0 ? t+sh : shl) + 0.2;
        // Start off with the shaft
        difference() {
            cylinder(d=bd, h=h);
            // Cut off if we have a flat part on the shaft
            if(sf>0)
                translate([-bd/2, -bd/2+sf, -0.1])
                    cube([bd, bd-sf+0.1, h+0.2]);
        }
    }
    color(c) {
    difference() {
        union() {
            // Fill a center in case the outers are too small to fill
            cylinder(r=cr, h=t);
            // Step though 360° at 'a' angle per step
            for(n=[0:a:360-a]) {
                // Rotate by this angle around [0,0]
                rotate([0, 0, n])
                    // Cylinder offset by cr radius
                    translate([cr, 0, 0])
                        cylinder(r=br, h=t);
            }
            // Extended shaft`
            translate([0, 0, -sh])
                cylinder(d=sd, h=sh);
        }
        // Cut the bolt/shaft hole, scaling it as required
        scale([1+hs/100, 1+hs/100, 1])
            translate([0, 0, -sh-0.1])
                ShaftCutter();
        
        // Finger Divot
        if(dd && dr)
            translate([or/2, 0, t+dd/2-dr])
                sphere(d=dd);
    }
    }
}

Knob(od=30, kp=60, kb=12, t=8, bd=6, sf=4.6, hs=12, sh=7.5, sd=10, shl=12.5, dd=35, dr=1.0);

