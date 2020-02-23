/*

Battery Plate Generator V1

This was developed to hold an array of SLA batteries.
It could be used to generate a holding plate for any regular
rectangular-based items. 

Created by Sk0pe (Micha Wotton). (c) 2020

*/


// Parameters

/* [Base Plate] */
Plate_Thickness = 2.5;
Round_corners = true;
Screw_Holes = true;

/* [Battery] */
Battery_Width = 65.5;
Battery_Length = 150.5;
Curved_Edges = true;
Curve_Radius = 0.45;

/* [Dividers] */
Divider_Width = 2.5;
Divider_Height = 5.5;

/* [Quality Settings] */
// Minimum size of a fragment
fs = 0.25; 
// Minimum angle for a fragment
fa = 1; 
// Number of fragments (overrides fs & fa if non zero)
fn = 0; 


// Setup
edgeCurveRadius = Curved_Edges ?  Curve_Radius : 0;

offsetX = Battery_Width+Divider_Width;
offsetY = Battery_Length+Divider_Width;
totalHeight = Plate_Thickness+Divider_Height;

/***************\
|  Main Process |
\***************/




difference()
{
    mainPlate();
    battery(edgeCurveRadius);
    screws();
}    


/********************\
|  Main Plate Module |
\********************/
module mainPlate() 
{
    if (Round_corners) {
        minkowski()
        {
            // Quality parameters
            $fs = fs; 
            $fa = fa;
            $fn = fn;

            translate([Divider_Width, Divider_Width, 0])
            {
                cube([Battery_Width,Battery_Length,totalHeight]);
            }
            cylinder(0.001, r=Divider_Width);
        }
    } else {
        cube([Battery_Width + 2*Divider_Width,Battery_Length + 2*Divider_Width,totalHeight]);
    }
}


/************************\
|  Single Battery Module |
\************************/
module battery(edgeCurveRadius) 
{
    translate([Divider_Width, Divider_Width, Plate_Thickness])
    {
        minkowski(){

            // Quality parameters
            $fs = fs; 
            $fa = fa;
            $fn = fn;

            translate([edgeCurveRadius, edgeCurveRadius, edgeCurveRadius]){
                cube([Battery_Width-edgeCurveRadius, Battery_Length-edgeCurveRadius, totalHeight-edgeCurveRadius]);
            }
            sphere(r=edgeCurveRadius, $fs = fs, $fa = fa, $fn = fn);
        }
    }
}


/****************\
|  Screws Module |
\****************/
module screws() 
{
    translate([(Battery_Width + 2*Divider_Width)/2, (Battery_Length + 2*Divider_Width)/4, 0.05])
    {
        cylinder(r1=0, r2=Plate_Thickness*2, h = Plate_Thickness*2, center= true, $fs = fs, $fa = fa, $fn = fn);
    }
    translate([(Battery_Width + 2*Divider_Width)/2, (Battery_Length + 2*Divider_Width)*3/4, 0.05])
    {
        cylinder(r1=0, r2=Plate_Thickness*2, h = Plate_Thickness*2, center= true, $fs = fs, $fa = fa, $fn = fn);
    }
}