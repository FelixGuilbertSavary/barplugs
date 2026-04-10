india = 16;
outdia = 31;
outz = 4.5;
inlen = 25;

minthick = 1.5;

insert_dia = 5.9;
insert_len = 5;
screwdia = 4.5;
screw_headdia = 7.5;
screw_headlen = 4.5;

top_dia = insert_dia+3.5;
top_len = 4;

window_count = 5;
window_width = 4;

$fn = 100;

all();
//screw2(screw_headdia, screw_headlen, screwdia, 20);

//win_egg(india, inlen + 5, minthick, window_count, window_width, top_dia, top_len, 5, 2);
//eggshell(india, inlen + 5, minthick, top_dia, top_len, 5, 2);
//filet(10, 3);

//difference()
//{
//all();
//    translate([0,0,-50])
//cube(100);
//}

module all()
{
    difference()
    {
        union()
        {   
            rotate([0,180,0])
                curved_cyl(dia = outdia, curve_r = outz, h=outz);

            difference()
            {
                translate([0,0,5])
                    win_egg(india, inlen + 5, minthick, window_count, window_width, top_dia, top_len, 5, 1);
                
                translate([-50,-50,-100.1])
                    cube(100);
            }
            
            curved_cyl(dia = screw_headdia + 3, curve_r = 1.5, h=2);
        }
        
        translate([0,0,-outz + screw_headlen])
            screw2(screw_headdia, screw_headlen, screwdia, inlen +  15);
        
        translate([0,0,inlen-insert_len-1])
            cylinder(d=insert_dia,h=insert_len);
    }
}

module screw2(headdia, headlen, shaftdia, shaftlen)
{
    union()
    {
        translate([0,0,-headlen])
            cylinder(d=headdia,h=headlen);
        cylinder(d=shaftdia,h=shaftlen);
    }
}

module win_egg(dia, length, thick, win_count, win_width, top_dia, top_len, filet_pos, filet_r)
{
    intersection()
    {
        eggshell(dia, length, thick, top_dia, top_len, filet_pos, filet_r);
        
        union()
        {
            for(a = [0:win_count - 1])
            {
                rotate([0,0,360 / win_count * a])
                {
                    translate([0,-win_width/2,-length/2])
                        cube([dia, win_width, length]);
                }
            }
            
            curved_cyl(dia = top_dia, h=length/2 + top_len, curve_r = top_dia/10);
        }
    }
}

module screw(dia, head_maxdia, length)
{
    union()
    {
        cylinder(d=dia, h=length);
        
        head_z = (head_maxdia - dia) / 2;
        translate([0,0,-head_z])
            cylinder(d2=dia, d1=head_maxdia, h=head_z);
        translate([0,0,-head_z-10])
            cylinder(d=head_maxdia, h=10);
        
    }
}

module eggshell(dia, length, thick, top_dia, top_len, filet_pos, filet_r)
{
    union()
    {
        difference()
        {
            union()
            {
                resize([dia, dia, length]) 
                {
                     sphere(dia);
                }
                cylinder(d=top_dia, h=length/2 + top_len);
            }

            resize([dia-thick*2, dia-thick*2, length-thick*2]) 
                sphere(dia);
        }
        sph_pos = filet_pos * dia / length;
        sph_rad = sqrt(pow(dia/2,2) - pow(sph_pos,2));
        translate([0,0,-filet_pos])
            filet(sph_rad*2-.2, filet_r);
    }
}

module filet(dia, rad)
{
    translate([0,0,rad])
    rotate_extrude()
    {
        translate([dia/2 + rad, 0, 0])
        {
            intersection()
            {
            difference()
            {
                
                square([rad*2, rad*2], center=true);
                circle(d=rad*2);
            }
            translate([-rad, -rad,0])
                square([rad, rad]);
            }
        }
    }
}

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