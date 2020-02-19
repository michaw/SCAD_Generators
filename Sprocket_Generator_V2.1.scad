/*

Sprocket generator v2.1

This code is based on the code written by *haand001*, who based his code on the work of 
*Talon_1* who based his code on the work of *Aleksejs*. 

Big thanks for your contributions. The aim of this code is to be easier
understood by folks that are new to OpenSCAD. The rendered sprocket can be downloaded 
as a .STL file and 3D-printed directly using any slicing program.

*/

//////////////////////
/* CHAIN-PARAMETERS */
//////////////////////

/* [Base Settings] */
// Chain roller diameter
Roller_Diameter  = 4.15;
// Plate thickness
Sprocket_Thickness = 2.95;
// Distance between the rollers (center to center)
Roller_Pitch     = 6.35;
// Makes roller spaces larger
Tolerance = 0.05;

/* [Teeth] */

// Number of teeth on the sprocket
Teeth    = 10;
// Effectively removes points on teeth
Shorten_Teeth = false;

///////////////
/* VARIABLES */
///////////////


/* [Shaft Collars] */
// Bottom shaft diameter
bottom_shaft_d = 10;
// Bottom shaft height (0 to remove)
bottom_shaft_h = 2; // = 0 to remove
// Top shaft diameter
top_shaft_d    = 15;
// Top shaft height (0 to remove)
top_shaft_h    = 3; // = 0 to remove
// Extra top shaft diameter
toptop_shaft_d = 10;
// Extra top shaft height
toptop_shaft_h = 1; // = 0 to remove

/* [Bore] */
// Larger bore diameter
Bore_Diameter_1   = 8.2;
// Smaller bore diameter (set to same as large for round bore hole)
Bore_Diameter_2   = 6.1;

/* [Holes] */
// Add holes for securing plate
Number_of_Holes = 0;
Hole_Diameter = 4;
// All holes will be distributed at this distance from the center of the bore
Hole_Offset_from_Center = 40;



///////////////////////
// RENDERING QUALITY */
///////////////////////

/* [Rendering Quality] */
// HIGH : fs=0.25 : fa=3 : fn=0
// LOW  : fs=1    : fa=7 : fn=0

// Minimum size of a fragment
fs = 0.25; 
// Minimum angle for a fragment
fa = 1; 
// Number of fragments (overrides fs & fa if non zero)
fn = 0; 

///////////////
/* MAIN CODE */
///////////////

difference()
{
    // Create a union of four shapes, 3 cylinders and 1 sprocket
    union()
    {
        // Create sprocket using the defined module
        sprocket(Teeth, Roller_Diameter, Roller_Pitch, Sprocket_Thickness, Tolerance);
        
        // Create cylinder on front side of sprocket
        translate([0, 0, Sprocket_Thickness])
            cylinder(top_shaft_h, top_shaft_d/2, top_shaft_d/2, $fs=fs, $fa=fa, $fn=fn);
        
        // Create cylinder on back side of sprocket
        rotate([0,180])
            cylinder(bottom_shaft_h, bottom_shaft_d/2, bottom_shaft_d/2, $fs=fs, $fa=fa, $fn=fn);
        
        // Create cylinder on top of the front side cylinder
        translate([0, 0, Sprocket_Thickness+top_shaft_h])
            cylinder(toptop_shaft_h, toptop_shaft_d/2, toptop_shaft_d/2, $fs=fs, $fa=fa, $fn=fn);
    }
    
    // Rest of shapes are removal of material

    // Drills out the  bore hole with 1 mm extra in both directions
    bore_height = bottom_shaft_h+Sprocket_Thickness+top_shaft_h+toptop_shaft_h+2; 

    translate([0, 0, -bottom_shaft_h-1])
    {
        intersection()
        {
            cylinder(bore_height, Bore_Diameter_1/2, Bore_Diameter_1/2, $fs=fs, $fa=fa, $fn=fn);            
            translate([-Bore_Diameter_1/2, -Bore_Diameter_2/2, 0])
            {
                cube([Bore_Diameter_1, Bore_Diameter_2, bore_height]);
            }
        }        
    }

    // Drills 'Number_of_Holes' many holes in a circle
    angle_between_holes = 360/Number_of_Holes;
    if (Number_of_Holes > 0)
    {
        for(hole_angle = [0:360/Number_of_Holes:360])
        {
            translate([Hole_Offset_from_Center/2*cos(hole_angle), Hole_Offset_from_Center/2*sin(hole_angle), -bottom_shaft_h-1])
            {
                cylinder(h = bore_height, r = Hole_Diameter/2, $fs=fs, $fa=fa, $fn=fn);
            }
        }
    }

    if (Shorten_Teeth) {
        outside_diameter = Roller_Pitch * (0.6 + 1/tan(180/Teeth) );
        translate([0,0,-1])
        {
            difference()
            {
                cylinder(h=bore_height+2, d=outside_diameter+Roller_Pitch, $fs=fs, $fa=fa, $fn=fn);
                cylinder(h=bore_height+2, d=outside_diameter, $fs=fs, $fa=fa, $fn=fn);
            }
        }
    }
}

/////////////////////
/* SPROCKET MODULE */
/////////////////////

module sprocket(Teeth=20, roller=3, Roller_Pitch=17, Sprocket_Thickness=3, Tolerance=0.2)
{
	Roller_Radius = roller/2; //We need radius in our calculations, not diameter
	distance_from_center = Roller_Pitch/(2*sin(180/Teeth));
	angle = (360/Teeth);
	
    Roller_Pitch_radius = sqrt((distance_from_center*distance_from_center) - (Roller_Pitch*(Roller_Radius+Tolerance))+((Roller_Radius+Tolerance)*(Roller_Radius+Tolerance)));
	    
    difference()
    {
		union()
        {
            // Quality parameters
            $fs = fs; 
            $fa = fa;
            $fn = fn;
            
            // Create inner cylinder with radius = Roller_Pitch_radius
			cylinder(r=Roller_Pitch_radius, h=Sprocket_Thickness);
            
            // Create outer part of the Teeth
			for(tooth=[1:Teeth])
            {
				intersection()
                {
					rotate(a=[0, 0, angle*(tooth+0.5)])
                    {
						translate([distance_from_center, 0, 0])
                        {
                            $fs = fs; 
                            $fa = fa;
                            $fn = fn;
							cylinder(r=Roller_Pitch-Roller_Radius-Tolerance, h=Sprocket_Thickness);
						}
					}
					rotate(a=[0,0,angle*(tooth-0.5)])
                    {
						translate([distance_from_center,0,0])
                        {
							cylinder(r=Roller_Pitch-Roller_Radius-Tolerance,h=Sprocket_Thickness);
						}
					}
				}
			}
		}
        
        // Cuts away the inner groove between the Teeth
		for(tooth=[1:Teeth])
        {
			rotate(a=[0, 0, angle*(tooth+0.5)])
            {
				translate([distance_from_center, 0, -1])
                {
					$fs = fs; 
                    $fa = fa;
                    $fn = fn;
                    cylinder(r=Roller_Radius+Tolerance, h=Sprocket_Thickness+2);
				}
			}
		}
	}
}


