//-- Parametric Traxxas 5347 carbon fiber rod connector
//-- Parametric: rod diameter can be adjusted as well as length and tolerance
//-- Assembly requires epoxy glue.
//-- AndrewBCN - Barcelona - March 2015
//-- GPLV3
//-- Please read the terms of the GPLV3 and please comply with it
//-- if remixing this part. Thank you.
//-- Origin: http://www.thingiverse.com/thing:725121
//-- Heavely modified: Tom Coetser <fitzterra@icave.net> 2016

$fn=64;

// Print tolerance
tolerance=0.6;

// Rod info
rod_dia=6.1; // Best is to meassure the actual rod diameter
rod_inset=9; // How deep should the rod side fit into the connector
rod_extra=8; // Any optional extra length to add to the rod side - extends the rod
rod_wall=2; // Wall thickness on rod side
rodDia=rod_dia+tolerance+rod_wall*2; // 2 walls per side

// Traxxas 5347 info
trx_dia=7;
trx_inset=8; // How deep should the traxxas fit into connector.
trx_extra=8; // Any optional extra length to add to traxxas side - extends the rod
trx_wall=0.6; // Wall thickness on traxxas side
trxDia = trx_dia+tolerance+trx_wall*2;    // 2 Walls per side

// Output connector info
echo("Connector rod diameter: ", rodDia);
echo("Connector full length: ", rod_inset+rod_extra+trx_inset+trx_extra);
echo("Will extend rod length by: ", rod_extra+trx_extra);

/**
 * Connector for rod end side.
 **/
module RodEnd() {
    difference() {
        // Outer cylinder
        cylinder(d=rodDia, h=rod_inset+rod_extra);
        // Cut out the inset to the specified tolerance across the diameter
        translate([0, 0, -1])
            cylinder(d=rod_dia+tolerance, h=rod_inset+1);
    }
}

/**
 * Connector for traxxas end side.
 **/
module TraxxasEnd() {
    difference() {
        // The traxxas side tapers from the rod diameter to the traxxas dia
        cylinder(d1=rodDia, d2=trxDia, h=trx_inset+trx_extra);
        translate([0, 0, trx_extra])
            cylinder(d=trx_dia+tolerance, h=trx_inset+1);
    }
}

/**
 * Complete connector
 **/
module Connector() {
    RodEnd();
    translate([0, 0, rod_inset+rod_extra])
        TraxxasEnd();
}

Connector();
