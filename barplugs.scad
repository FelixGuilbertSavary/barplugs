india = 17.5; // Handlebar inside diameter
outdia = 29; // Cap outside diameter
outz = 4.5; // Cap's thickness
cap_curve_r = outz - 2; // Cap curve radius

minthick = 1.5; // minimum thickness

cap_creux_z = 2;
cap_creux_dia = outdia - minthick*3;

inlen = 25; // Inside overall length

insert_dia = 5.9; // Threaded insert diameter
insert_len = 5; // Threaded insert length 
screwdia = 4.5; // Bolt shaft diameter
screw_headdia = 7.5; // Bolt head diameter
screw_headlen = 5; // Bolt head length

slot_count = 5; // Number of slots
slot_width = 40; // Width 

steps = 3;
step_h = 0.16;

$fn = 150;

difference()
{
    
all();
//    translate([0,0,-50])
//cube([100,100,100]);
}

module all()
{
    effective_cap_z = outz - cap_creux_z;

    union()
    {
        difference()
        {
            union()
            {
                 // Plug end, part actually seen once installed
                translate([0,0,cap_creux_z])
                difference()
                {
                    rotate([0,180,0])
                        curved_cyl(dia = outdia, curve_r = cap_curve_r, h=outz);
                    translate([0,0,0])
                    rotate([0,180,0])
                        curved_cyl(dia = cap_creux_dia, curve_r = 1, h=cap_creux_z);
                }
                
                extra_len = 5; // Length of the ellipsoid that gets cut to connect to the cap.
                total_egg_len = inlen + extra_len;
                
                // Screw head guard for screw
                screw_guard = 2 * elipse_y(total_egg_len/2 - extra_len - minthick, total_egg_len, india);
                curved_cyl(screw_guard, 1,  h = screw_headlen - effective_cap_z + minthick * 1.5);
                
                filet(screw_guard, 2*minthick/3, 0);
                
                difference()
                {
                    union()
                    {
                        // Create an ellipsoid with cut windows
                        intersection()
                        {
                            translate([0,0,total_egg_len/2 - extra_len])
//                                ellipsoid(india, total_egg_len, extra_len, 1);
                                ellipsoid(india, total_egg_len);  
                            
                            for(a = [0:slot_count - 1])
                            {
                                rotate([0,0,360 / slot_count * a])
                                {
                                    translate([0,-slot_width/2,0])
                                        cube([india, slot_width, inlen]);
                                }
                            }
                        }
                        
                        // Add the tip for the threaded insert
                        curved_cyl(insert_dia + minthick * 2, 1, inlen - minthick + insert_len);
                        
                    }
                    
                    // Carve the inside of the ellipsoid
                    translate([0,0, total_egg_len/2 - extra_len])
                         ellipsoid(india - minthick * 2, total_egg_len - minthick * 2);
                }
                
            }

            // Insert slot
            translate([0,0,inlen - minthick])
                cylinder(d = insert_dia, h=insert_len);
            
            // Bolt
            translate([0,0,-effective_cap_z])
                screw(screw_headdia, screw_headlen, screwdia, inlen +  15);
        }
    
        // Helps the printer printing bridges around the hole for the bolt.
        translate([0,0,-effective_cap_z + screw_headlen])
            for(x = [0:steps])
            {
                rotate([0,0,180/steps*x])
                translate([0,0,-step_h *x])
                    cyl_inter(screw_headdia, screwdia, step_h*x);
            }
    
    }
}

// Cylinder intersected with a cube, creating round ramps for layers
module cyl_inter(dia, width, h)
{
    difference()
    {
        cylinder(d=dia, h=h);
        translate([-width/2,-dia/2,0])
            cube([width, dia, h]);
    }
}

module screw(headdia, headlen, shaftdia, shaftlen)
{
    union()
    {
        cylinder(d=headdia,h=headlen);
        cylinder(d=shaftdia,h=shaftlen);
    }
}

module ellipsoid(dia, length)
{    
    ratio = length / dia;
   
    scale([1, 1, ratio]) 
    {
        sphere(d=dia);
    }
}

function filet_h(dia, curve_r, angle) =  curve_r + sin(angle) * curve_r;

function elipse_y(x, a, b) = sqrt( (1 - pow(x, 2) / pow(a/2, 2) ) * pow(b/2, 2));

module filet(dia, curve_r, angle)
{
    circle_h = filet_h(dia, curve_r, angle);
    y_offset = cos(angle) * curve_r;
    
    rotate_extrude()
    rotate([0,0,-90])
    difference()
    {
        translate([-circle_h, -dia/2 - y_offset,0])
             square([circle_h, dia/2 + y_offset]);
        
        translate([-curve_r, -dia/2 - y_offset, 0])
            intersection()
            {
                circle(r=curve_r);
                translate([-circle_h + curve_r, 0, 0])
                    square([curve_r * 2, curve_r]);
            }
    }
}

// Cylinder with a rounded edge.
module curved_cyl(dia, curve_r, h)
{
    translate([0,0,h-curve_r])
    rotate([0,180,0])
    union()
    {
        difference()
        {
            hull()
            {
                rotate_extrude(angle = 360) 
                {
                    translate([dia/2 - curve_r,0,0])
                        circle(d=curve_r * 2);
                }
            }
            
            cylinder(d=dia, h=curve_r);
        }
        cylinder(d=dia, h=h-curve_r);
    }
}