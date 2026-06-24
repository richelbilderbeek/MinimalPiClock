include <../../../BOSL2/std.scad>
include <../../../BOSL2/threading.scad>


// outer_diameter: the outer diameter of the part, where the thread ends
// inner_diameter: the diameter of the hole
// pitch: depth of the threads
//

//              *****       Air
//          ***       ***          
//        **             **        
//       *                 *       
//      *   Thread          *      
//     *                     *     
//    *          ***          *    
//    *        **   **        *    
//    *       *       *       *    
//    *       *       *       *    
//    *       * Hole  *       *    
//    *       *       *       *    
//    *        **   **        *    
//    *          ***          *    
//     *                     *     
//      *                   *      
//       *                 *       
//        **             **        
//          ***       ***          
//              *****          
//    
//           |-------| inner_diameter
//    |----------------------| outer_diameter
module draw_bolt(
  hole_diameter,
  wall_thickness,
  pitch = 1,
  height = 10
) {
  assert(hole_diameter > 0);
  assert(wall_thickness > 0);
  assert(pitch > 0);
  assert(height > 0);

  // diameter where the thread starts
  screw_inner_diameter = hole_diameter + wall_thickness;
  screw_outer_diameter = screw_inner_diameter + pitch;
  difference() {
    threaded_rod(d = screw_outer_diameter, l = height, pitch = pitch);
    cylinder(h = height, d = hole_diameter, center = true);
  }
}

module draw_nut(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height
) {
  assert(hole_diameter > 0);
  assert(wall_thickness > 0);
  assert(pitch > 0);
  assert(air_gap > 0);
  assert(height > 0);
  // Where the thread end
  thread_inner_diameter = hole_diameter + wall_thickness + pitch + air_gap;
  // Where the thread starts
  thread_outer_diameter = thread_inner_diameter + wall_thickness;
  // Where the object end
  outer_diameter = thread_inner_diameter + wall_thickness;
  intersection() {
    threaded_nut(
      shape = "square", 
      nutwidth = outer_diameter, 
      id = thread_inner_diameter, 
      h = height, 
      pitch = pitch,
      ibevel = false,
      spin = 180
    );  
    cylinder(height, d = outer_diameter, center = true);

  }
}

// screw_outer_diameter: the outer diameter of the screw
// inner_hole_diameter: the diameter of the inner hole



//                XXXXXXXXXXX                                                      
//           XXXXX           XXXXX                                                 
//         XX     XXXXXXXXXXX     XX                                               
//       XX   XXXX           XXXX   XX                                             
//      X   XX    XXXXXXXXXXX    XX   X                                            
//     X  XX   XXX           XXX   XX  X                                           
//    X  X   XX    XXXXXXXXX    XX   X  X                                          
//   X  X   X   XXX         XXX   X   X  X                                         
//  X   X  X   X               X   X  X   X                                        
//  X  X  X   X                 X   X  X  X                                        
//  X  X  X   X      Hole       X   X  X  X                                        
//  X  X  X   X                 X   X  X  X                                        
//  X   X  X   X               X   X  X   X                                        
//   X  X   X   XXX         XXX   X   X  X                                         
//    X  X   XX    XXXXXXXXX    XX   X  X                                          
//     X  XX   XXX           XXX   XX  X                                           
//      X   XX    XXXXXXXXXXX    XX   X                                            
//       XX   XXXX           XXXX   XX                                             
//         XX     XXXXXXXXXXX     XX                                               
//           XXXXX           XXXXX                                                 
//                XXXXXXXXXXX                                                      
//                                                                                 
//                                                                                 
//            |-----------------|     Hole diameter
//        |---|                 |---| Vertical wall thickness of inner part 
//        |-------------------------| Inner diameter of thread going inward
//     |--|                         |--| Thread pitch inner part
//     |-------------------------------| Outer diameter of thread going inward
//
//
//        |-------------------------| Inner diameter of thread going inward
//     |--|                         |--| Thread pitch outer part
//     |-------------------------------| Outer diameter of thread going inward
//  |--|                               |--| Vertical wall thickness of outer part
//  |-------------------------------------| Outer diameter of sphere                                                                                
//                                                                                 //                                                                                 
//                                                                                 
module draw_connector(
  hole_diameter = 100,
  wall_thickness = 2,
  pitch = 4,
  air_gap = 1,
  height = 10,
  second_part_translation = [0, 0, 0]
) {
  assert(hole_diameter > 0);
  assert(wall_thickness > 0);
  assert(pitch > 0);
  assert(air_gap > 0);
  assert(pitch > air_gap, "The grooves must overlap vertically");
  assert(height > 0);
  // Inner, red, part
  color([1, 0, 0])
    draw_bolt(
      hole_diameter = hole_diameter,
      wall_thickness = wall_thickness,
      pitch = pitch,
      height = height
    );
  // Outer, blue, part
  translate(second_part_translation)
    color([0, 0, 1])
      draw_nut(
        hole_diameter = hole_diameter,
        wall_thickness = wall_thickness,
        pitch = pitch,
        air_gap = air_gap,
        height = height
      );

}


display = "part";
//display = "cutout";

hole_diameter = 100;
wall_thickness = 2;
pitch = 4;
air_gap = 1;
height = 10;

if (display == "cutout") {
  // Show cutout
  difference() {
    draw_connector();
      translate([-500,0,-500])
          cube([1000, 100, 1000]);
  }
} 
else {
  draw_connector(
    hole_diameter = hole_diameter,
    wall_thickness = wall_thickness,
    pitch = pitch,
    air_gap = air_gap,
    height = height,
    second_part_translation = [hole_diameter + wall_thickness + pitch + air_gap + wall_thickness, 0, 0]
  );
}

//color([1,0,0])
//  cube([25, 1, 1], true);

/*

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


module inner_screw() {
  difference() {
    threaded_rod(l = thread_depth, pitch=pitch, d=d,starts=starts,anchor=BOTTOM,end_len=.44);
    cylinder(100, 40, 40);
  }
}

module display_all() {
  //translate([200, 0, 0])
  //  inner_screw();
  //translate([400, 0, 0])
  //  outer_screw();
  difference() {
    inner_screw();
      cube([100, 100, 100]);
  }
  difference() {
    outer_screw();
      cube([100, 100, 100]);
  }

}

display_all();
*/

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