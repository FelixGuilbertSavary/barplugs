india = 16; // Handlebar inside diameter
outdia = 31; // Cap outside diameter
outz = 4.5; // Cap's thickness
cap_curve_r = outz - 2; // Cap curve radius

inlen = 25; // Inside overall length

minthick = 1.5; // minimum thickness

insert_dia = 5.9; // Threaded insert diameter
insert_len = 5; // Threaded insert length 
screwdia = 4.5; // Bolt shaft diameter
screw_headdia = 7.5; // Bolt head diameter
screw_headlen = 5; // Bolt head length

slot_count = 5; // Number of slots
slot_width = 4; // Width 

steps = 3;
step_h = 0.16;

$fn = 50;

all();

module all()
{
    union()
    {
        difference()
        {
            insert_hub_z = inlen - minthick * 3;
            
            union()
            {
                // Plug end, part actually seen once installed
                rotate([0,180,0])
                    curved_cyl(dia = outdia, curve_r = cap_curve_r, h=outz);
                
                // Screw head guard for
                curved_cyl(dia = screw_headdia + 2, curve_r = 1, h=screw_headlen -outz + minthick);
                
                extra_len = 5; // Length of the ellipsoid that gets cut to connect to the cap.
                total_egg_len = inlen + extra_len;
                
                difference()
                {
                    union()
                    {
                        // Create an ellipsoid with cut windows
                        intersection()
                        {
                            translate([0,0,total_egg_len/2 - extra_len])
                                ellipsoid(india, total_egg_len, extra_len, 1);
                            
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
                        translate([0,0,insert_hub_z])
                            curved_cyl(insert_dia + minthick * 2, 1, insert_len + minthick * 2);
                        
                    }
                    
                    // Carve the inside of the ellipsoid
                    translate([0,0,total_egg_len/2 - extra_len])
                         ellipsoid(india - minthick * 2, total_egg_len - minthick * 2, 0, 0);
                }
                
            }

            // Insert slot
            translate([0,0,insert_hub_z + minthick * 2])
                cylinder(d = insert_dia, h=insert_len);
            
            // Bolt
            translate([0,0,-outz])
                screw(screw_headdia, screw_headlen, screwdia, inlen +  15);
        }
    
        // Helps the printer printing bridges around the hole for the bolt.
        translate([0,0,-outz + screw_headlen])
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

module ellipsoid(dia, length, skirt_pos, skirt_r)
{    
    ratio = length / dia;
    
    // skirt position on the original round sphere, before transformation
    skirt_zpos = dia/2 - skirt_pos / ratio;
    angle = 90 - acos(skirt_zpos * 2 / dia);
    skirt_dia = 2* sqrt(pow(dia/2, 2) - pow(skirt_zpos, 2));
    skirt_dia2 = 2* sqrt(pow(dia/2, 2) - pow(skirt_zpos - filet_h(skirt_dia, skirt_r, angle), 2));
    
    scale([1, 1, ratio]) 
    {
        union()
        {
            sphere(d=dia);
            translate([0,0,-skirt_zpos])
                filet(skirt_dia2, skirt_r, angle);
        }
    }
}

function filet_h(dia, curve_r, angle) =  curve_r + sin(angle) * curve_r;

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