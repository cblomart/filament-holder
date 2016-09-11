bobine_diameter=200;
bobine_height=105;
bobine_center=50;

axle_diameter=30;
axle_buffer=10;
axle_flex=30;
axle_clip=0.7;

support_height=6;
support_border=4;
support_bobine_clearance=2;
support_play=.1;
supports=3;

profile_height=20;
profile_inset=6;
profile_inset_deep=2;

play = 0.4;
real_axle_diameter = axle_diameter - 2 * play;
real_internal_cube = sqrt(2*pow((axle_diameter-4-2*play)/2,2));

module ring(in,out,h) {
    difference() {
        cylinder(d=out,h=h);
        translate([0,0,-1]) cylinder(d=in,h=h+2);
    }
}

module bobine() {
    union() {
        ring(in=bobine_center,out=bobine_center+4,h=bobine_height);
        ring(in=bobine_center,out=bobine_diameter,h=2);
        translate([0,0,bobine_height-2]) ring(in=bobine_center,out=bobine_diameter,h=2);
    }
}

module axle() {
    difference() {
        union() {
            //ring(in=axle_diameter-4,out=axle_diameter,h=axle_buffer+bobine_height);
            difference() {
                cylinder(d=real_axle_diameter,h=bobine_height+axle_buffer);
                union() {
                    linear_extrude(height=bobine_height+axle_buffer,twist=360,slices=300) translate([-real_internal_cube/2,-real_internal_cube/2,0]) square([real_internal_cube,real_internal_cube]);
                    linear_extrude(height=bobine_height+axle_buffer,twist=-360,slices=300) translate([-real_internal_cube/2,-real_internal_cube/2,0]) square([real_internal_cube,real_internal_cube]);
                }
            }
            ring(in=real_axle_diameter,out=real_axle_diameter+axle_clip,h=1);
            translate([0,0,support_height-axle_clip]) ring(in=real_axle_diameter,out=real_axle_diameter+axle_clip,h=1);
            translate([0,0,axle_buffer+bobine_height-axle_clip]) ring(in=real_axle_diameter,out=real_axle_diameter+axle_clip,h=axle_clip);
        }
        translate([-(axle_diameter+4)/2,-axle_clip]) cube([axle_diameter+4,axle_clip*2,axle_flex]);
        translate([-(axle_diameter+4)/2,-axle_clip,axle_buffer+bobine_height-axle_flex]) cube([axle_diameter+4,axle_clip*2,axle_flex]);
        rotate([0,0,90]) {
            translate([-(axle_diameter+4)/2,-axle_clip]) cube([axle_diameter+4,axle_clip*2,axle_flex]);
            translate([-(axle_diameter+4)/2,-axle_clip,axle_buffer+bobine_height-axle_flex]) cube([axle_diameter+4,axle_clip*2,axle_flex]);
        }
    }
}

module support() {
    difference() {
        union() {
            //round support for axle
            translate([support_bobine_clearance+(bobine_diameter/2),support_border+axle_diameter/2]) cylinder(d=2*support_border+axle_diameter,h=support_height);
            //profile corner
            cube([support_border,profile_height+support_border,support_height]);
            //top 
            translate([-profile_height,0,0]) cube([support_bobine_clearance+(bobine_diameter/2)+profile_height,support_border,support_height]);
            //bottom
            length = sqrt(pow(support_bobine_clearance+(bobine_diameter/2),2)+pow(support_border+axle_diameter-profile_height,2));
            angle =  acos((support_bobine_clearance+(bobine_diameter/2))/length);
            translate([0,profile_height+support_border,0]) rotate([0,0,angle])translate([0,-support_border,0]) cube([length,support_border,support_height]);
            //support beams
            dlength = support_bobine_clearance+(bobine_diameter/2)+(axle_diameter/2);
            for(i=[1:supports+1]) {
                previous_offset = log((i-1)*10/(supports+2))*(support_bobine_clearance+(bobine_diameter/2));
                offset = log(i*10/(supports+2))*(support_bobine_clearance+(bobine_diameter/2));
                //height = ((offset / (support_bobine_clearance+(bobine_diameter/2) + (axle_diameter/2))) * (profile_height + support_border)) + axle_diameter - (support_border);
                height = profile_height + support_border + ( offset / dlength) * (support_border + axle_diameter - profile_height);
                // height
                translate([offset,0,0]) cube([support_border,height,support_height]);
                // diagonal
                if (i>1) {
                    dlength = sqrt(pow(offset-previous_offset,2)+pow(height,2));
                    dangle = acos((offset-previous_offset)/dlength);
                    translate([previous_offset+support_border*2/3,0,0]) difference(){
                        rotate([0,0,dangle]) translate([support_border/2,-support_border/2,0]) cube([dlength-support_border,support_border,support_height]);
                        translate([0,-support_border,0]) cube([3*support_border,support_border,support_height]);
                    }
                } else {
                    dlength = sqrt(pow(offset,2)+pow(height,2));
                    dangle = acos((offset)/dlength);
                    translate([support_border*2/3,0,0]) difference() {
                        rotate([0,0,dangle]) translate([support_border/2,-support_border/2,0]) cube([dlength-support_border,support_border,support_height]);
                        translate([0,-support_border,0]) cube([3*support_border,support_border,support_height]);
                    }
                }
            }
            // profile hook
            translate([-profile_inset_deep,support_border+profile_height/2-profile_inset/2,0]) cube([profile_inset_deep,profile_inset,support_height]);
            translate([-profile_height/2-profile_inset/2,support_border,0]) cube([profile_inset,profile_inset_deep,support_height]);
            translate([-profile_height-support_border,0,0]) cube([support_border,profile_height/2+support_border+profile_inset/2,support_height]);
            translate([-profile_height,support_border+profile_height/2-profile_inset/2,0]) linear_extrude(height=support_height) polygon(points=[[0,0],[profile_inset_deep,0],[0,profile_inset]], paths=[[0,1,2]]);
        }
        translate([support_bobine_clearance+(bobine_diameter/2)+support_play,support_border+axle_diameter/2,-1]) cylinder(d=axle_diameter+2*support_play,support_height+2);
        translate([support_bobine_clearance+(bobine_diameter/2)+support_play,support_border+axle_diameter/2]) ring(in=axle_diameter+2*support_play,out=axle_diameter+2*(axle_clip+support_play),h=axle_clip+support_play);
        translate([support_bobine_clearance+(bobine_diameter/2)+support_play,support_border+axle_diameter/2,support_height-axle_clip-support_play]) ring(in=axle_diameter+2*support_play,out=axle_diameter+2*(axle_clip+support_play),h=axle_clip+support_play+1);
        
    }    
}

//color([1,0,0,0.1]) translate([bobine_diameter/2,bobine_diameter/2,10]) bobine();
//translate([bobine_diameter/2,bobine_diameter/2,0]) axle();
//translate([-support_bobine_clearance,bobine_diameter/2-(axle_diameter/2)-support_border,0]) support();
axle();
//support();

