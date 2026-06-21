
include <../../../BOSL2/std.scad>
include <../../../BOSL2/threading.scad>


thread_depth = 20;
thread_diameter = 90;

$fn=32;
$slop = 0.075;
d = thread_diameter;
pitch = 1; // mm, space between threads
starts = 3;


module outer_screw() {
  intersection() {
    threaded_nut(nutwidth= thread_diameter + 20,id = thread_diameter,h = thread_depth,pitch=pitch,starts=starts,anchor=BOTTOM,bevel=false,ibevel=false);
    cylinder(100, 50, 50);
  }
}

outer_screw();

module inner_screw() {
  difference() {
    threaded_rod(l = thread_depth, pitch=pitch, d=d,starts=starts,anchor=BOTTOM,end_len=.44);
    cylinder(100, 40, 40);
  }
}

inner_screw();


/*

outer_width = 40; // mm
outer_depth = 30; // mm
outer_height = 20; // mm
wall_thickness = 2; // mm
inner_width = outer_width - wall_thickness; // mm
inner_depth = outer_depth - wall_thickness; // mm
inner_height = outer_height - wall_thickness; // mm
n_teeth = 10;
x_teeth_length = inner_width / n_teeth;
y_teeth_length = inner_depth / n_teeth;
z_teeth_length = inner_height/ n_teeth;
piezo_diameter = 12; // mm
piezo_radius = piezo_diameter  / 2; // mm
cable_diameter = 5; // mm
cable_radius = cable_diameter / 2; // mm

// The teeth need some air between them.
// This is the amount of space that each tooth get shorten
// with at each side
teeth_air = 0.25; // mm

spacing = 1; // Spacing between the parts, mm

*/