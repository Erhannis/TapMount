/**
Run get_deps.sh to clone dependencies into a linked folder in your home directory.

Print with about -0.16m horizontal expansion, so things can actually fit together.
*/

use <deps.link/BOSL/nema_steppers.scad>
use <deps.link/BOSL/joiners.scad>
use <deps.link/BOSL/shapes.scad>
use <deps.link/erhannisScad/misc.scad>
use <deps.link/erhannisScad/auto_lid.scad>
use <deps.link/scadFluidics/common.scad>
use <deps.link/quickfitPlate/blank_plate.scad>
use <deps.link/getriebe/Getriebe.scad>
use <deps.link/gearbox/gearbox.scad>

$FOREVER = 1000;
DUMMY = false;
$fn = DUMMY ? 10 : 60;

TAP_9_D = 9+0.3;
TAP_18_D = 17.95+0.3;

MOUNT_D = 25;
MOUNT_STICKOUT = 10;
MOUNT_H = 30;
MOUNT_WINGS = 10;
MOUNT_T = 10;
MOUNT_SY = MOUNT_D+2*MOUNT_WINGS;

SOCKET_CHAMFER_H = 3;
BASE_PLATFORM_H = 10;
BASE_PLATFORM_L = MOUNT_D+MOUNT_STICKOUT+10;
BASE_H = MOUNT_H + BASE_PLATFORM_H + 50 + SOCKET_CHAMFER_H;
BASE_WALL = 10;
BASE_SX = MOUNT_T+2*BASE_WALL;
BASE_SY = MOUNT_SY+2*BASE_WALL;

BASE_BACKPLATE_SX = 20;

echo("clearance", MOUNT_D/2+MOUNT_STICKOUT);

// M5 bolts
BASE_SCREW_D = 5;
BASE_SCREW_HEAD_D = 8.75+0.25;
BASE_SCREW_HEAD_H = 5+0.5;

module mount(tap_d=TAP_18_D) {
    linear_extrude(height=MOUNT_H) difference() {
        union() {
            circle(d=MOUNT_D);
            tx(MOUNT_T/2+MOUNT_D/2+MOUNT_STICKOUT+BASE_WALL) square([MOUNT_T, MOUNT_SY], center=true);
            ty(-MOUNT_D/2) square([MOUNT_D/2+MOUNT_STICKOUT+BASE_WALL, MOUNT_D]);
        }
        circle(d=tap_d);
    }
}

module baseChamfer(h=3) {
    minkowski() {
        linear_extrude(height=0.00001) projection() mount(0);
        cmirror([0,0,1]) cylinder(d1=h*2,d2=0,h=h);
    }
}

module base() {
    difference() {
        union() {
            // Main body
            cube([BASE_SX, BASE_SY, BASE_H]);
            
            // Platform
            tx(-BASE_PLATFORM_L) cube([BASE_PLATFORM_L, BASE_SY, BASE_PLATFORM_H]);
            
            // Backplate
            tx(BASE_SX) cube([BASE_BACKPLATE_SX, BASE_SY, BASE_PLATFORM_H]);
        }
        translate([
            BASE_SX/2-(MOUNT_T/2+MOUNT_D/2+MOUNT_STICKOUT+BASE_WALL),
            BASE_SY/2,
            BASE_H-MOUNT_H-SOCKET_CHAMFER_H
        ]) {
            // Mount slot
            mount(0);
            
            // Chamfers, mmm
            tz(MOUNT_H+SOCKET_CHAMFER_H) baseChamfer();
            
            // Platform center see-through
            cylinder(d=MOUNT_D,h=$FOREVER,center=true);
        }

        // Screw holes
        SCREW_OFFSET = BASE_SCREW_HEAD_D*0.75;
        for (dx = [
                BASE_SX+BASE_BACKPLATE_SX-SCREW_OFFSET,
                -BASE_PLATFORM_L+SCREW_OFFSET
            ]) {
            for (dy = [
                    SCREW_OFFSET,
                    BASE_SY-SCREW_OFFSET,
                ]) {
                translate([dx, dy, 0]) {
                    cylinder(d=BASE_SCREW_D,h=$FOREVER,center=true);
                    tz(BASE_PLATFORM_H-BASE_SCREW_HEAD_H) cylinder(d=BASE_SCREW_HEAD_D,h=$FOREVER);
                }
            }
        }
        //OYm([0,5,0]);
    }
}

ty(-40) mount(TAP_9_D);
ty(-90) mount(TAP_18_D);
base();

// For vis only
*translate([
    BASE_SX/2-(MOUNT_T/2+MOUNT_D/2+MOUNT_STICKOUT+BASE_WALL),
    BASE_SY/2,
    BASE_H-MOUNT_H-SOCKET_CHAMFER_H
]) mount();
