include <dimlines/dimlines.scad>
include <variables.txt>



module layer()
{
    union(){
	difference() {
		union() {
			cube([P_LENGTH, P_LENGTH, P_Z_C1], center = true);	
		}
		union() {
		    //active area
			cube([P_WIRE_X, P_WIRE_X, P_Z_C1a], center = true);
			
			//threads
			translate([ HOLE_X,  HOLE_X, -P_Z_C1/2]) cylinder(h=HOLE_H, r=HOLE_R, center=false, $fn=100);
			translate([-HOLE_X,  HOLE_X, -P_Z_C1/2]) cylinder(h=HOLE_H, r=HOLE_R, center=false, $fn=100);
			translate([ HOLE_X, -HOLE_X, -P_Z_C1/2]) cylinder(h=HOLE_H, r=HOLE_R, center=false, $fn=100);
			translate([-HOLE_X, -HOLE_X, -P_Z_C1/2]) cylinder(h=HOLE_H, r=HOLE_R, center=false, $fn=100);
			
			// PCB spaces
			translate([0,  P_WIDTH-CONVERTER_PCB_WIDTH/2,  P_Z_ETCH+0.01]) cube([CONVERTER_PCB_LENGTH, CONVERTER_PCB_WIDTH, P_Z_ETCH], center=true);
			translate([0, -(P_WIDTH/2+P_WIRE_X/4),  P_Z_ETCH+0.01]) cube([P_WIRE_X, PCB_WIDTH, P_Z_ETCH], center=true);
			
			//solder etches
			translate([-(P_WIDTH/2+P_WIRE_X/4),  0, -(P_Z_ETCH+0.01)]) cube([PCB_WIDTH, P_WIRE_X, SOLDER_ETCH], center=true);
			translate([  P_WIDTH/2+P_WIRE_X/4 ,  0, -(P_Z_ETCH+0.01)]) cube([PCB_WIDTH, P_WIRE_X, SOLDER_ETCH], center=true);
	 
		}
	}
	}
	{
	translate([0,  P_WIDTH-CONVERTER_PCB_WIDTH+CONVERTER_PCB_WIDTH/2,  P_Z_ETCH+0.01+0.1]) color([1,0,1]) cube([CONVERTER_PCB_LENGTH, CONVERTER_PCB_WIDTH2, P_Z_ETCH], center=true);
	translate([0, -(P_WIDTH/2+P_WIRE_X/4),  P_Z_ETCH+0.01+0.1]) color([1,0,1])cube([P_WIRE_X, PCB_WIDTH, P_Z_ETCH], center=true);
	
	}
}

module anode()
{
    layer();
    // wires        
    for(i = [1:N_ANODE]) 
        translate([-P_WIRE_X/2+i*GAP_ANODE,P_WIDTH/2+P_WIRE_X/4, P_Z_C1+0.1]) rotate([90, 0, 0]) color([0,0,0])cylinder(h=P_WIDTH+P_WIRE_X/2, r=R_WIRE, center=false, $fn=100);		
}

module cathode()
{
    layer();
    // wires        
    for(i = [1:N_CATHODE]) 
        translate([-P_WIRE_X/2+i*GAP_CATHODE,P_WIDTH/2+P_WIRE_X/4, P_Z_C1+0.1]) rotate([90, 0, 0]) color([1,0,0])cylinder(h=P_WIDTH+P_WIRE_X/2, r=R_WIRE, center=false, $fn=100);		
}

//1st direction measurement
//cathode1
translate([ 0, 0, P_Z_C1*15]) rotate([0, 0, 0]) cathode();
//anode
translate([ 0, 0, P_Z_C1*10]) rotate([0, 0, 90]) anode();
//cathode2
translate([ 0, 0, P_Z_C1*5]) rotate([0, 0, 0]) cathode();

//2nd direction measurement
//cathode1
translate([ 0, 0, -P_Z_C1*5]) rotate([0, 0, 90]) cathode();
//anode
translate([ 0, 0, -P_Z_C1*10]) rotate([0, 0, 0]) anode();
//cathode2
translate([ 0, 0, -P_Z_C1*15]) rotate([0, 0, 90]) cathode();
