// Height of the rack part in U
RackHeight = 7;
// Height of the base in mm
BaseHeight = 70; 
// Length of the rails in mm
RailLength = 434;
// Overall depth 
Depth = 200;  
Slew = 100; 
MaterialThickness = 6;

Speaker = 1;  // [0:No, 1:Yes]
SpeakerPos = 0; //[0:Front, 1:Side, 2:Back, 3:Bottom]
SpeakerXPos = 60;
SpeakerYPos = 30;
SpeakerMountingHoleSize = 5.5;

Socket = 1;  // [0:No, 1:Yes]
SocketPos = 0; //[0:Left, 1:Right] 

// Margin between parts in 2D
Margin = 5;
Render = 0;  // [0:3D, 1:2D, 2:2D-Export]

MHposx = -325;
HMposy = -200;

// usually no need to change this
Uinmm = 44.45;
U3holedistance = 116.65;
// For Intelijel 1U
U1holedistance = 35.2;
RailMountingHoleSize =6.5;

rh = ceil(RackHeight*Uinmm)+3*MaterialThickness; 
height = ceil(sqrt(rh*rh-Slew*Slew))+BaseHeight;

$fn = 60;

module socket_hole(xpos, ypos, th = MaterialThickness){
    // https://www.errorinstruments.com/a-53259897/power-supply-parts-for-case/switch-male-power-socket-for-eurorack-case/#description
    translate([xpos,ypos, th/2]){
        union(){
            cube([47.5,27.5,th+2],center = true);
            translate([0,20,0])
            cylinder(d=3.5,th+2, center = true);
            translate([0,-20,0])
            cylinder(d=4.5,th+2,center = true);
        }
    }
}

module speaker(xpos, ypos, th = MaterialThickness){ 
    // 668-1128-ND   
    translate([xpos,ypos,0]){
        //holes
        translate([-7*5,-3*5,th/2]){
            for (x = [0:14]){
                for (y = [0:6]){
                    translate([x*5,y*5,0]){
                        cylinder(d=2,th+2,center = true);
                    }
                }
            }
        }
        //mounting holes
        translate([-37.5,-20,th/2]) cylinder(d=SpeakerMountingHoleSize,th+2,center = true);
        translate([-37.5,20,th/2]) cylinder(d=SpeakerMountingHoleSize,th+2,center = true);
        translate([37.5,-20,th/2]) cylinder(d=SpeakerMountingHoleSize,th+2,center = true);
        translate([37.5,20,th/2]) cylinder(d=SpeakerMountingHoleSize,th+2,center = true);
    }
}


module railholes(xpos, ypos,holespacing, height, th = MaterialThickness){
    pos1 = (height-holespacing)/2;
    pos2 = (pos1+holespacing);
    translate([xpos,ypos,0]){
        translate([pos1,0,th/2]) cylinder(d=RailMountingHoleSize,th+2,center = true);    
        translate([pos2,0,th/2]) cylinder(d=RailMountingHoleSize,th+2,center = true);
    }
}

module holes3u(xpos, ypos, th = MaterialThickness){
    railholes(xpos,ypos,U3holedistance,3*Uinmm);
}

module holes1u(xpos, ypos, th = MaterialThickness){
    railholes(xpos,ypos,U1holedistance,Uinmm);
}

module mountingHoles(xpos = MHposx, ypos = HMposy, h = RackHeight, th = MaterialThickness){
    u3rows = RackHeight/3;
    u1rows = RackHeight%3;
    translate([xpos,ypos,0]){
        for (i = [0:u3rows-1]){
            holes3u(0+i*Uinmm*3,0);
        }
    }
    translate([xpos+(u3rows*Uinmm*3)-Uinmm,ypos,0]){
        for (i = [0:u1rows-1]){
            holes1u(0+i*Uinmm,0);
        }
    }
}

module side(h = height,bh = BaseHeight, d = Depth, th = MaterialThickness, sl = Slew){
    difference(){
        linear_extrude(height = th){
            polygon(points=[[0,0],[h,0],[h,d-sl],[bh,d],[0,d]]);
        }
        rotate([0,0,180-atan2(Slew,rh)])mountingHoles();
    }
}

module right(h = height,bh = BaseHeight, d = Depth, th = MaterialThickness, sl = Slew){
    if((Speaker==1) && (SpeakerPos==1)){
        difference(){
            side(h,bh,d,th,sl);
            rotate([0,0,90])speaker(SpeakerXPos,-SpeakerYPos);
        }
    }
    else side(h,bh,d,th,sl);
}

module left(h = height,bh = BaseHeight, d = Depth, th = MaterialThickness, sl = Slew){
    if (Socket == 1){
        difference(){
            side(h,bh,d,th,sl);
            socket_hole(60,60);
        }   
    }
    else side(h,bh,d,th,sl);
}

module back(h = height, w = RailLength, th = MaterialThickness){
    if((Speaker==1) && (SpeakerPos==2)){
        difference(){
            cube([h-2*th,w,th]);
            rotate([0,0,90])speaker(SpeakerXPos,-SpeakerYPos);
        }
    }
    else  cube([h-2*th,w,th]);
}

module bottom(d = Depth, w=RailLength, th = MaterialThickness){
    if((Speaker==1) && (SpeakerPos==3)){
        difference(){
            cube([d,w,th]);
            rotate([0,0,90])speaker(SpeakerXPos,-SpeakerYPos);
        }
    }
    else cube([d,w,th]);
}

module front(h = BaseHeight, w=RailLength, th = MaterialThickness){
    if((Speaker==1) && (SpeakerPos==0)){
        difference(){
            cube([h-th,w,th]);
            rotate([0,0,90])speaker(SpeakerXPos,-SpeakerYPos);
        }
    }
    else cube([h-th,w,th]);
}

module top(d = Depth-Slew, w=RailLength, th = MaterialThickness){
    cube([d-th,w,th]);
}

module front_top(h = BaseHeight, w=RailLength, th = MaterialThickness){
    cube([3*th,w,th]);
}

module case3d(){
    color("MediumSeaGreen"){
        translate([MaterialThickness,0,0]) back();
        translate([MaterialThickness,0,Depth-MaterialThickness]) front();
        translate([height,0,Depth-Slew,]) rotate([0,180 + atan2(Slew,rh),0])front_top();
    }
    color("RoyalBlue"){
        rotate([90,0,0]){
            if (SocketPos == 0){ 
                right();
                translate([0,0,-RailLength-MaterialThickness]) left();
            }   else{
                left();
                translate([0,0,-RailLength-MaterialThickness]) right();
            }
        }
    }
    color("MediumOrchid"){
        rotate([0,-90,0]){
            translate([0,0,-MaterialThickness]) bottom();
            translate([0,0,-height]) top();
        }
    }
}

module case2d(){
    color("MediumSeaGreen"){
        back();
        translate([height+(Depth-Slew)+Margin,0,0]) front_top();
        translate([6*Margin+Depth +BaseHeight + Slew * 2 + 3*MaterialThickness  ,0,0]) front();
    }
    color("RoyalBlue"){
        translate([-height/2 -Margin,-Margin,0]) mirror([0,1,0])  left();
        translate([height/2 ,-Margin,0]) mirror([0,1,0]) right();
    }
    color("MediumOrchid"){
        translate([-Margin-Depth,0,0]) bottom();
        translate([height,0,0]) top();
    }
}

if (Render==0) case3d();

if (Render==1) case2d();

if (Render==2){
    render(){
        projection(){
            case2d();
        }
    }
}

