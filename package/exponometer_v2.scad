include <../lib/threads.scad>

r = 5; 

module main_profile(xm, ym, zm, xb, yb, zb) {
    Points = [
        [  -xm/2,  0,  0+r ],        //0
        [   xm/2,  0,  0+r ],        //1
        [  -xb/2,  r,  zm + zb ],    //2
        [   xb/2,  r,  zm + zb ],    //3
        [  -xm/2,  yb, 0+r ],        //4
        [   xm/2,  yb, 0+r ],        //5
        [  -xb/2,  yb, zm + zb ],    //6
        [   xb/2,  yb, zm + zb ],    //7
    
        [  -xm/2,  ym, 0+r ],        //8
        [   xm/2,  ym, 0+r ],        //9
        [  -(xm+xb)/4,  ym, zm  ],   //10
        [   (xm+xb)/4,  ym, zm  ],   //11
        
        [  -xm/2+r,  ym+r, r+r ],    //12
        [   xm/2-r,  ym+r, r+r ],    //13
        
    ]; 
  
    Faces = [
            [0,1,3,2],  
            [0,4,5,1],  
            [0,2,6,4],  
            [1,5,7,3],  
            [2,3,7,6],
            
            [6,7,11,10],
            [5,9,11,7],
            [6,10,8,4],
            [4,8,9,5],
            
            [10,12,8],
            [10,11,13,12],
            [8,12,13,9],
            [11,9,13],
    ]; 
    minkowski() {
    //union() {
        polyhedron( Points, Faces );
        sphere(r=5);
    }
}

module hole_container(dia, w, side) {
    sensorx = -w/2;
    sensory = 70;
    sensorz = 9-4+side+r;
    
    ext_len = dia;//-2*side;
    int_dia = dia - side;
    
    translate([ext_len, sensory, sensorz]) {
        rotate([0, 90, 0])
            cylinder(d=dia, h=w+ext_len, center=true);
    }  
}
module hole(dia, w, side, angel) {
    sensorx = -w/2;
    sensory = 70;
    sensorz = 9-4+side+r;
    
    ext_len = dia;//-2*side;
    int_dia = dia - side;
    hole_lenght = int_dia/(2*tan(angel/2));
    
    translate([ext_len, sensory, sensorz]) {
        translate([w/2+ext_len/2, 0, 0]) {
            rotate([45,0,0]) rotate([0,-90,0])
                #cylinder(r2=1, r1=int_dia/2, h=hole_lenght, $fn=4);
        }
    }  
}

module button() {
    difference() {
        union() {
            cylinder(d=4, h=4);
            cylinder(d=5, h=1.5);
        }
        cylinder(d=3, h=2);
    }
    
}

module button_hole_neg() {
    union() {
        cylinder(d=4, h=4);
        cylinder(d=5, h=1.5);
    }
}


module main_board_container_negative(w, l, h) {
    main_support_l = 3;
    main_support_h = 8-1.6;
    side_support_w = 3;
    side_support_h = 12-1.2;
    union() {
        difference() {
            cube([w,l, h],center = true);
            translate([0, l/2-main_support_l/2, h/2-main_support_h/2])
                cube([w, main_support_l, main_support_h], center=true);
            translate([0, -l/2+main_support_l/2, h/2-main_support_h/2])
                cube([w, main_support_l, main_support_h], center=true);
            translate([-w/2+side_support_w/2, 0, h/2-side_support_h/2])
                cube([side_support_w, l, side_support_h], center=true);
        }
        translate([w/2-(5+24/2), -l/2+(47+14/2), -h/2-5])
            cube([25, 14, 10], center=true);
        translate([w/2-10, -l/2+8, -h/2])
            rotate([180,0,0])
                button_hole_neg();
        translate([w/2-10-10, -l/2+8, -h/2])
            rotate([180,0,0])
                button_hole_neg();
        translate([w/2-10-10, -l/2+8+8, -h/2])
            rotate([180,0,0])
                button_hole_neg();
    }
}

module nut_holder_ext(h) {
    d_thread = 3;
    cylinder(d=(d_thread+3), h, center=true);
}

module nut_holder_int(h) {
    d_thread = 3;
    translate([0,0,-h/2])
        metric_thread(diameter=d_thread, pitch=0.5, length=h,internal=true);
        //cylinder(d=d_thread, h=h);
    translate([0,0,h/2-1])
        cylinder(d1=d_thread, d2=(d_thread+3), h=2, center=true);
}


module main_box(batx, baty, batz, mainx, mainy, mainz, side, angle) {
    difference() {   
        union() {
            main_profile(mainx+2*side-r, mainy+2*side-r, mainz+3*side-r,
                batx+2*side-r, baty+2*side-r, batz+2*side-r);
            hole_container(mainz-side, mainx, side/2);
        }
        
        translate([0, baty/2+side, mainz+batz/2+2*side])
            cube([batx,baty,batz+side],center = true);
        translate([0, mainy/2, mainz/2+side])
            main_board_container_negative(mainx,mainy,mainz);
        translate([batx/2-3, 5+side, side])
            cylinder(r=3, h= mainz+batz);
        translate([0, mainy+r, (mainz+batz)/2])
            cube([mainx/2,3,mainz+batz],center = true);
        hole(mainz-side, mainx, side/2, angle);
    }
}

module main_box_nuts(batx, baty, batz, mainx, mainy, mainz, side, angle) {
    difference() {
        union() {
            main_box(batx, baty, batz, mainx, mainy, mainz, side, angle);
            translate([mainx/2, side, (mainz+side)/2+1])
                    nut_holder_ext(mainz);
            translate([-mainx/2+side, mainy, (mainz+side)/2+1])
                    nut_holder_ext(mainz+side);
            translate([0, side+0.5,    mainz+(batz+side)/2+side+2])
                    nut_holder_ext(batz+side);
            translate([0, baty+r-side, mainz+(batz+side)/2+side+2])
                    nut_holder_ext(batz+side);
        }
        translate([mainx/2, side, (mainz+side)/2 - 0])
            rotate([180,0,0])
                nut_holder_int(mainz+side);
        translate([-mainx/2+side, mainy, (mainz+side)/2-0])
            rotate([180,0,0])
                nut_holder_int(mainz+side);
        translate([0, side+0.5, mainz+(batz+side)/2+side+4])
                nut_holder_int(batz+side);
        translate([0, baty+r-side, mainz+(batz+side)/2+side+4])
                nut_holder_int(batz+side);
    }
}

module low_cap(w, l, side) {
    union() {
        translate([0,(l+r)/2-r, side])
            cube([w+r+4*side, l+25, side/2], center=true);
        translate([0,(l+r)/2-r, side/2])
            cube([w+r+4*side, l+25, side], center=true);
    }
}
module upper_cap(w, l, z, side) {
    union() {
        translate([0,(l+r)/2, z+side])
            cube([w+r+2*side, l+4*r, side/2], center=true);
        translate([0,(l+r)/2, z+side/2])
            cube([w+r, l+4*r, side/2], center=true);
    }
}
module main_box_print(batx, baty, batz, mainx, mainy, mainz, side, angle) {
    translate([0, 0, -side-0.6])  
    difference() {
        main_box_nuts(batx, baty, batz, mainx, mainy, mainz, side, angle);
        low_cap(mainx, mainy, side);
        upper_cap(batx, baty, mainz+batz+2*side+0.5,side);
    }
}

module low_cap_print(batx, baty, batz, mainx, mainy, mainz, side, angle) {
    rotate([-180,0,0]) translate([0,0,-4])
    intersection() {
        main_box_nuts(batx, baty, batz, mainx, mainy, mainz, side, angle);
        low_cap(mainx, mainy, side);
    }
}
module upper_cap_print(batx, baty, batz, mainx, mainy, mainz, side, angle) {
    translate([0,0,-36])
        intersection() {
        main_box_nuts(batx, baty, batz, mainx, mainy, mainz, side, angle);
        upper_cap(batx, baty, mainz+batz+2*side+0.5,side);
        }
}

$fn=50;
    batx = 24;
    baty = 54+2*3+1.5;
    batz = 11;
    mainx = 37.5;
    mainy = 81;
    mainz = 18;
    side = 3;
    angle = 25;

//main_box();
//hole(20, 70, 3,20);
//main_board_container_negative(37, 81, 16);
//main_box_print(batx, baty, batz, mainx, mainy, mainz, side, angle);
//main_box_nuts(batx, baty, batz, mainx, mainy, mainz, side, angle);
//upper_cap_print(batx, baty, batz, mainx, mainy, mainz, side, angle);
//low_cap_print(batx, baty, batz, mainx, mainy, mainz, side, angle);
//nut_holder(10);
//button_hole_neg();
button();