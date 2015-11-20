include <dimlines/dimlines.scad>
include <variables.txt>


module draw_frame(length, height, line_width=DIM_LINE_WIDTH) {
    line(length=length, width=line_width);
    translate([0, height, 0]) line(length=length, width=line_width);
    translate([line_width / 2, line_width / 2, 0])
    rotate([0, 0, 90])
    line(length=height - line_width, width=line_width);
    translate([length - line_width / 2, line_width / 2, 0])
    rotate([0, 0, 90])
    line(length=height - line_width, width=line_width);
}

module layer()
{
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

module layer_dim(){
translate([ 0, 0, -5]) layer();

//axis
color ("blue") translate([ -(1+P_LENGTH/2), 0, DOC_HEIGHT]) 
line(length=P_LENGTH+2, width=DIM_LINE_WIDTH, height=.01, left_arrow=false, right_arrow=false);
color ("blue") translate([0,  -(1+P_LENGTH/2), DOC_HEIGHT]) rotate (90,0,0)
line(length=P_LENGTH+2, width=DIM_LINE_WIDTH, height=.01, left_arrow=false, right_arrow=false);

// top side
    color("Black") translate([0, 0, DOC_HEIGHT])
    union() {
        translate([0, P_LENGTH/2 + DIM_SPACE*3, 0])           dimensions(P_WIRE_X/2, DIM_LINE_WIDTH*2);
        translate([0, P_LENGTH/2 + DIM_SPACE*6, 0])           dimensions(HOLE_X,     DIM_LINE_WIDTH*2);
        translate([-P_LENGTH/2, P_LENGTH/2 + DIM_SPACE*9, 0]) dimensions(P_LENGTH,   DIM_LINE_WIDTH*2);    }

// holes
   color("GREY") translate([0, 0, DOC_HEIGHT])
    union() {
        translate([HOLE_X, HOLE_X, DIM_HEIGHT]) circle_center(HOLE_R, DIM_HOLE_CENTER, DIM_LINE_WIDTH);
    }
    leader1_text = str("5X r=", HOLE_R);
    color("BLACK") translate([0, 0, DOC_HEIGHT])
    union() {
      translate([HOLE_X, HOLE_X, DIM_HEIGHT])
      leader_line(angle=+60, radius=HOLE_R, angle_length=DIM_SPACE*20,
                  horz_line_length=.5, line_width=DIM_LINE_WIDTH, text=leader1_text);
    }
    
// right side
    color("Black") translate([0, 0, DOC_HEIGHT]) rotate([0, 0, -90])
    union() {
        translate([-P_WIRE_X/2, P_WIDTH+ DIM_SPACE*3, DIM_HEIGHT]) dimensions(P_WIRE_X/2, DIM_LINE_WIDTH*2);
        translate([-HOLE_X,     P_WIDTH+ DIM_SPACE*6, DIM_HEIGHT]) dimensions(HOLE_X,     DIM_LINE_WIDTH*2);
        translate([-P_WIDTH,    P_WIDTH+ DIM_SPACE*9, DIM_HEIGHT]) dimensions(P_WIDTH,    DIM_LINE_WIDTH*2);
        translate([-P_WIDTH,    P_WIDTH+ DIM_SPACE*12,DIM_HEIGHT]) dimensions(P_ETCH_CONN,DIM_LINE_WIDTH*2);
        translate([0,           P_WIDTH+ DIM_SPACE*9, DIM_HEIGHT]) dimensions(P_WIRE_X/2, DIM_LINE_WIDTH*2);
        translate([P_WIRE_X/2,  P_WIDTH+ DIM_SPACE*9, DIM_HEIGHT]) dimensions(P_ETCH_WIRE,DIM_LINE_WIDTH*2);
        translate([P_WIRE_X/2+P_ETCH_WIRE,  P_WIDTH+ DIM_SPACE*9, DIM_HEIGHT]) dimensions(P_ETCH_WIRE,DIM_LINE_WIDTH*2);
    }

//~~~~~~~~~~~~~~~~~~~~~~~~
// side view of the object
translate([ P_LENGTH+3, P_WIDTH, -15])  rotate([90, 0, 180]) scale([1,1,5]) layer();
 width1_text = str(" d=", P_Z_C1);
 width2_text = str(" h=", P_Z_ETCH);
 color("BLACK") translate([P_LENGTH*1.5+3, P_WIDTH, DOC_HEIGHT])
 union() {
      translate([2-P_WIDTH/5, P_Z_C1*2.5, DIM_HEIGHT])
      leader_line(angle=-90, radius=0, angle_length=DIM_SPACE*30,
                  horz_line_length=.5, line_width=2*DIM_LINE_WIDTH, text=width1_text);
      translate([-2-P_WIDTH/5, 1, DIM_HEIGHT])
      leader_line(angle=-120, radius=HOLE_R, angle_length=DIM_SPACE*40,
                  horz_line_length=.5, line_width=2*DIM_LINE_WIDTH, text=width2_text);
 }


//~~~~~~~~~~~~~~~~~~~~~~~~
// 45 degree 3D view
 translate([ P_LENGTH+3, -2, -5])  rotate([45, 45, 180]) layer();

}
 

layer_dim();



translate([-P_LENGTH/2-2, -P_LENGTH/2-2, DOC_HEIGHT]) color("Black")
union() {
    draw_frame(length=2.1*P_LENGTH+6, height=P_LENGTH+6, line_width=DIM_LINE_WIDTH * 5);
    color("Black") translate([2.1*P_LENGTH+6-7, 3.5, 0]) sample_titleblock2();
}
