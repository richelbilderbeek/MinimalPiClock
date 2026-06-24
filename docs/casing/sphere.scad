include <../../../BOSL2/std.scad>
include <../../../BOSL2/threading.scad>

// Lower, inner, red, part
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
  pitch,
  height
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

// Upper, outer, blue, part
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
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height,
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

module draw_shell(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height
) {
  thread_inner_diameter = hole_diameter + wall_thickness + pitch + air_gap;
  // Where the thread starts
  thread_outer_diameter = thread_inner_diameter + wall_thickness;
  // Where the out screw ends
  outer_diameter = thread_inner_diameter + wall_thickness;
  // The end of the sphere
  spere_diameter = outer_diameter + wall_thickness;
  color([0,1,0])
  difference() {
    sphere(d = spere_diameter);
    sphere(d = outer_diameter);
  }

}

module draw_upper_sphere(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height
) {
  thread_inner_diameter = hole_diameter + wall_thickness + pitch + air_gap;
  // Where the thread starts
  thread_outer_diameter = thread_inner_diameter + wall_thickness;
  // Where the out screw ends
  outer_diameter = thread_inner_diameter + wall_thickness;
  // The end of the sphere
  spere_diameter = outer_diameter + wall_thickness;
  color([0,1,0])
  difference() {
    difference() {
      sphere(d = spere_diameter);
      sphere(d = outer_diameter);
    };
    translate([-(spere_diameter / 2), -(spere_diameter / 2), -spere_diameter - (height / 2)])
    cube(spere_diameter);
  }
}

module draw_lower_sphere(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height
) {
  thread_inner_diameter = hole_diameter + wall_thickness + pitch + air_gap;
  // Where the thread starts
  thread_outer_diameter = thread_inner_diameter + wall_thickness;
  // Where the out screw ends
  outer_diameter = thread_inner_diameter + wall_thickness;
  // The end of the sphere
  spere_diameter = outer_diameter + wall_thickness;
  color([0,1,0])
  difference() {
    difference() {
      sphere(d = spere_diameter);
      sphere(d = outer_diameter);
    };
    translate([-(spere_diameter / 2), -(spere_diameter / 2), -(height / 2)])
      cube(spere_diameter);
  };
  difference() {
    translate([0, 0, -(height / 2)])
      cylinder(h = wall_thickness, d = spere_diameter - wall_thickness, center = true);
    translate([0, 0, -(height / 2)])
      cylinder(h = wall_thickness, d = hole_diameter, center = true);
  };
}

// The upper half has the nut
module draw_upper_half(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height
) {
  draw_upper_sphere(
    hole_diameter = hole_diameter,
    wall_thickness = wall_thickness,
    pitch = pitch,
    air_gap = air_gap,
    height = height
  );
  draw_nut(
    hole_diameter = hole_diameter,
    wall_thickness = wall_thickness,
    pitch = pitch,
    air_gap = air_gap,
    height = height
  );
}

// The upper half has the bolt
module draw_lower_half(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height
) {
  draw_lower_sphere(
    hole_diameter = hole_diameter,
    wall_thickness = wall_thickness,
    pitch = pitch,
    air_gap = air_gap,
    height = height
  );
  draw_bolt(
    hole_diameter = hole_diameter,
    wall_thickness = wall_thickness,
    pitch = pitch,
    // air_gap = air_gap,
    height = height
  );
}



module draw_casing(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height
) {
  difference() {
    union() {
      draw_connector(
        hole_diameter = hole_diameter,
        wall_thickness = wall_thickness,
        pitch = pitch,
        air_gap = air_gap,
        height = height
      );
      draw_shell(
        hole_diameter = hole_diameter,
        wall_thickness = wall_thickness,
        pitch = pitch,
        air_gap = air_gap,
        height = height
      );
    };
  }
}

hole_diameter = 60;
wall_thickness = 2;
pitch = 4;
air_gap = 2;
assert(air_gap > 1, "An air gap of 1 mm will not work on the UMS printers");
height = 10;

//display = "connector";
//display = "cutout";
//display = "lower_half";
//display = "upper_half";
display = "printable";

if (display == "printable") {

  rotate([180, 0, 0])
    draw_lower_half(
      hole_diameter = hole_diameter,
      wall_thickness = wall_thickness,
      pitch = pitch,
      air_gap = air_gap,
      height = height
    );

  thread_inner_diameter = hole_diameter + wall_thickness + pitch + air_gap;
  thread_outer_diameter = thread_inner_diameter + wall_thickness;
  outer_diameter = thread_inner_diameter + wall_thickness;
  spere_diameter = outer_diameter + wall_thickness;

  translate([spere_diameter + air_gap, 0, 0])
  draw_upper_half(
    hole_diameter = hole_diameter,
    wall_thickness = wall_thickness,
    pitch = pitch,
    air_gap = air_gap,
    height = height
  );
}

if (display == "lower_half") {
  // Show cutout
  difference() {
    draw_lower_half(
      hole_diameter = hole_diameter,
      wall_thickness = wall_thickness,
      pitch = pitch,
      air_gap = air_gap,
      height = height
    );
    translate([-500,0,-500])
      cube([1000, 100, 1000]);
  }
}

if (display == "upper_half") {
  // Show cutout
  difference() {
    draw_upper_half(
      hole_diameter = hole_diameter,
      wall_thickness = wall_thickness,
      pitch = pitch,
      air_gap = air_gap,
      height = height
    );
    translate([-500,0,-500])
      cube([1000, 100, 1000]);
  }
}

if (display == "cutout") {
  // Show cutout
  difference() {
    draw_lower_half(
      hole_diameter = hole_diameter,
      wall_thickness = wall_thickness,
      pitch = pitch,
      air_gap = air_gap,
      height = height
    );
    translate([-500,0,-500])
      cube([1000, 100, 1000]);
  }
  difference() {
    draw_upper_half(
      hole_diameter = hole_diameter,
      wall_thickness = wall_thickness,
      pitch = pitch,
      air_gap = air_gap,
      height = height
    );
    translate([-500,0,-500])
      cube([1000, 100, 1000]);
  }
}
 
if (display == "connector"){
  draw_connector(
    hole_diameter = hole_diameter,
    wall_thickness = wall_thickness,
    pitch = pitch,
    air_gap = air_gap,
    height = height,
    second_part_translation = [hole_diameter + wall_thickness + pitch + air_gap + wall_thickness, 0, 0]
  );
}
