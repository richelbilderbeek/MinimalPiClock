include <../../../BOSL2/std.scad>
include <../../../BOSL2/threading.scad>

include <../../../BOSL2/std.scad>

function create_params(
  hole_diameter = 60,
  wall_thickness = 2,
  pitch = 4,
  air_gap = 2,
  height = 10,
) 
  = struct_set(
    [],  
    [
      "hole_diameter", hole_diameter, 
      "wall_thickness", wall_thickness, 
      "pitch", pitch, 
      "air_gap", air_gap, 
      "height", height,
      // Helpers
      "bolt_thread_inner_diameter", hole_diameter + wall_thickness,
      "bolt_thread_outer_diameter", hole_diameter + wall_thickness + pitch,
      "nut_thread_inner_diameter",  hole_diameter + wall_thickness + pitch + air_gap,
      "nut_thread_outer_diameter",  hole_diameter + wall_thickness + pitch + air_gap + pitch,
      "nut_outer_diameter",         hole_diameter + wall_thickness + pitch + air_gap + pitch + wall_thickness,
      "sphere_diameter",            hole_diameter + wall_thickness + pitch + air_gap + pitch + wall_thickness + wall_thickness
    ]
  );

module check_params(params) {
  assert(is_struct(params), "params must be a struct. Tip: use 'create_params'");

  hole_diameter = struct_val(params, "hole_diameter");
  assert(hole_diameter > 0);
  wall_thickness = struct_val(params, "wall_thickness");
  assert(wall_thickness > 0);
  pitch = struct_val(params, "pitch");
  assert(pitch > 0);
  air_gap = struct_val(params, "air_gap");
  assert(air_gap > 0); 
  assert(air_gap > 1, "An air gap between 0-1 mm is too narrow for the screw to turn"); 
  height = struct_val(params, "height");
  assert(height > 0);
  bolt_thread_inner_diameter = struct_val(params, "bolt_thread_inner_diameter");
  assert(bolt_thread_inner_diameter == hole_diameter + wall_thickness);
  bolt_thread_outer_diameter = struct_val(params, "bolt_thread_outer_diameter");
  assert(bolt_thread_outer_diameter == hole_diameter + wall_thickness + pitch);
  nut_thread_inner_diameter = struct_val(params, "nut_thread_inner_diameter");
  assert(nut_thread_inner_diameter == hole_diameter + wall_thickness + pitch + air_gap);
  nut_thread_outer_diameter = struct_val(params, "nut_thread_outer_diameter");
  assert(nut_thread_outer_diameter == hole_diameter + wall_thickness + pitch + air_gap + pitch);
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");
  assert(nut_outer_diameter == hole_diameter + wall_thickness + pitch + air_gap + pitch + wall_thickness);
  sphere_diameter = struct_val(params, "sphere_diameter");
  assert(sphere_diameter == hole_diameter + wall_thickness + pitch + air_gap + pitch + wall_thickness + wall_thickness);
}



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
  params
) {
  check_params(params);
  height = struct_val(params, "height");
  pitch = struct_val(params, "pitch");
  hole_diameter = struct_val(params, "hole_diameter");
  bolt_thread_inner_diameter = struct_val(params, "bolt_thread_inner_diameter");
  bolt_thread_outer_diameter = struct_val(params, "bolt_thread_outer_diameter");
  difference() {
    threaded_rod(d = bolt_thread_outer_diameter, l = height, pitch = pitch);
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
  nut_thread_inner_diameter = hole_diameter + wall_thickness + pitch + air_gap;
  // Where the thread starts
  nut_thread_outer_diameter = nut_thread_inner_diameter + wall_thickness;
  // Where the object end
  nut_outer_diameter = nut_thread_outer_diameter + wall_thickness;
  intersection() {
    threaded_nut(
      shape = "square", 
      nutwidth = nut_thread_outer_diameter, 
      id = nut_thread_inner_diameter, 
      h = height, 
      pitch = pitch,
      ibevel = false,
      spin = 180
    );  
    cylinder(height, d = nut_outer_diameter, center = true);

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
  params
) {
  check_params(params);
  height = struct_val(params, "height");
  hole_diameter = struct_val(params, "hole_diameter");
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");
  spere_diameter = struct_val(params, "sphere_diameter");
  assert(struct_val(params, "sphere_diameter") == spere_diameter);
  // Outer sphere, upper half cut off
  color([0,1,0])
    difference() {
      difference() {
        sphere(d = spere_diameter);
        sphere(d = nut_outer_diameter);
      };
      translate([-(spere_diameter / 2), -(spere_diameter / 2), -(height / 2)])
        cube(spere_diameter);
    };
  // Open ring that connects out wall to inner nut
  color([0.5,1,0.5])
    difference() {
      translate([0, 0, -(height / 2)])
        cylinder(h = wall_thickness, d = nut_outer_diameter, center = true);
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
  params
) {
  check_params(params);
  draw_lower_sphere(params);
  draw_bolt(params);
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
height = 10;

params = create_params(
  hole_diameter = 60,
  wall_thickness = 2,
  pitch = 4,
  air_gap = 2,
  height = 10
);
check_params(params);
echo_struct(params);

//display = "connector";
//display = "cutout";
//display = "lower_half";
//display = "upper_half";
display = "printable";

if (display == "printable") {

  draw_lower_half(params);

  thread_inner_diameter = hole_diameter + wall_thickness + pitch + air_gap;
  thread_outer_diameter = thread_inner_diameter + wall_thickness;
  outer_diameter = thread_inner_diameter + wall_thickness;
  spere_diameter = outer_diameter + wall_thickness;

  translate([spere_diameter + air_gap, 0, 0])
  rotate([180, 0, 0])
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
