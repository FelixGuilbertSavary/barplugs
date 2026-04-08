india = 16;
outdia = 31;
outz = 4.5;
inlen = 20;

minthick = 1.5;

screw_headdia = 10;
screwdia = 4;
screw_basedia = 6;
top_dia = screwdia*2;
top_len = 2;

window_count = 5;
window_width = 4;

$fn = 18;

difference()
{
all();
//    translate([0,0,-50])
//cube(100);
}
//win_egg(india, inlen + 5, minthick, window_count, window_width, top_dia, top_len);

module all()
{
    difference()
    {
        union()
        {

            curved_cyl(dia = outdia, curve_r = outz, h=10);

            difference()
            {
                translate([0,0,5])
                win_egg(india, inlen + 5, minthick, window_count, window_width, top_dia, top_len);
                translate([-50,-50,-100.1])
                    cube(100);
            }
        }
        
        translate([0,0,-1])
        screw(screwdia, screw_headdia, inlen + outz );
        
        translate([0,0,-outz])
        cylinder(d=screw_basedia, h=outz);
        
        
    }
}

module win_egg(dia, length, thick, win_count, win_width, top_dia, top_len)
{
    intersection()
    {
        eggshell(dia, length, thick, top_dia, top_len);
        
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
            
            cylinder(d=top_dia, h=length/2 + top_len);
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

module eggshell(dia, length, thick, top_dia, top_len)
{
    difference()
    {
        union()
        {
            resize([dia, dia, length]) 
                sphere(dia);
            cylinder(d=top_dia, h=length/2 + top_len);
        }

        resize([dia-thick*2, dia-thick*2, length-thick*2]) 
            sphere(dia);
    }
}

module curved_cyl(dia, curve_r, h)
{
    difference()
    {
    hull()
        {
            rotate_extrude(angle = 360) 
            {
                translate([dia/2 -curve_r  ,0,0])
                    circle(d=curve_r * 2);
            }
        }
        cylinder(d=dia + 0.5, h=h);
        
    }
}