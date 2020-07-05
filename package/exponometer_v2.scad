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

module hole_container(dia, w, side, angel) {
    sensorx = -w/2;
    sensory = 70;
    sensorz = 9;
    
    ext_len = dia;//-2*side;
    int_dia = dia - side;
    hole_lenght = int_dia/(2*tan(angel/2));
    
    translate([ext_len, sensory, sensorz]) {
        rotate([0, 90, 0])
            cylinder(d=dia, h=w+ext_len, center=true);
    }  
}
module hole(dia, w, side, angel) {
    sensorx = -w/2;
    sensory = 70;
    sensorz = 9;
    
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

module main_board_container_negative(w, l, h) {
    main_support_l = 3;
    main_support_h = 8-1.6;
    side_support_w = 3;
    side_support_h = 10-1.2;
    difference() {
        cube([w,l, h],center = true);
        translate([0, l/2-main_support_l/2, h/2-main_support_h/2])
            cube([w, main_support_l, main_support_h], center=true);
        translate([0, -l/2+main_support_l/2, h/2-main_support_h/2])
            cube([w, main_support_l, main_support_h], center=true);
        translate([-w/2+side_support_w/2, 0, h/2-side_support_h/2])
            cube([side_support_w, l, side_support_h], center=true);

    }
}
module main_box() {
    batx = 24;
    baty = 54;
    batz = 10;
    mainx = 37;
    mainy = 81;
    mainz = 16;
    side = 3;
    angle = 25;
 
    difference() {   
        union() {
            main_profile(mainx+2*side-r, mainy+2*side-r, mainz+side-r,
                batx+2*side-r, baty+2*side-r, batz+side-r);
            hole_container(mainz, mainx, side, angle);
        }
        
        translate([0, baty/2+side, mainz+batz/2+side])
            cube([batx,baty,batz++2*side],center = true);
        translate([0, mainy/2, mainz/2-side])
            main_board_container_negative(mainx,mainy,mainz+side);
        translate([0, 5+side, 0])
            cylinder(r=5, h= 40);
        translate([0, mainy+r, (mainz+batz)/2])
            cube([mainx/2,3,mainz+batz],center = true);
        hole(mainz, mainx, side, angle);
    }
}

$fn=50;
main_box();
//hole(20, 70, 3,20);
//main_board_container_negative(37, 81, 16);