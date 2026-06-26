// From https://github.com/BelfrySCAD/BOSL2
include <../../../BOSL2/std.scad>
include <../../../BOSL2/threading.scad>
include <../../../BOSL2/std.scad>

// From https://github.com/brodykenrick/text_on_OpenSCAD
include <../../../text_on_OpenSCAD/text_on.scad>

pi = 3.141592653589793238462643383279502884197;

params = create_params(
  hole_diameter = 60,
  wall_thickness = pi,
  pitch = 4,
  air_gap = 2,
  height = 10,
  font_size = 7,
  wire_hole_diameter = 3.4 + 1.0, // Add uncertainty
  speaker_hole_diameter = 2.0 + 1.0 // Add uncertainty
);
// Either display to print or display to check
// 0: to print
// 1: assambled
// 2: cutout
// 3: cutout
display_mode = 1;

if (struct_val(params, "wall_thickness") <= 2.0) {
  echo("Warning: a wall thickness below 2 mm results in a fragile casing");
}


function create_params(
  hole_diameter,
  wall_thickness,
  pitch,
  air_gap,
  height,
  font_size,
  wire_hole_diameter,
  speaker_hole_diameter
) 
  = struct_set(
    [],  
    [
      "hole_diameter", hole_diameter, 
      "wall_thickness", wall_thickness, 
      "pitch", pitch, 
      "air_gap", air_gap, 
      "height", height,
      "font_size", font_size,
      "wire_hole_diameter", wire_hole_diameter,
      "speaker_hole_diameter", speaker_hole_diameter,
      // Helpers
      "bolt_thread_inner_diameter", hole_diameter + wall_thickness,
      "bolt_thread_outer_diameter", hole_diameter + wall_thickness + pitch,
      "nut_thread_inner_diameter",  hole_diameter + wall_thickness + pitch + air_gap,
      "nut_thread_outer_diameter",  hole_diameter + wall_thickness + pitch + air_gap + pitch,
      "nut_outer_diameter",         hole_diameter + wall_thickness + pitch + air_gap + pitch + wall_thickness,
      "sphere_diameter",            hole_diameter + wall_thickness + pitch + air_gap + pitch + wall_thickness + wall_thickness
    ]
  );

module check_params(params) 
{
  assert(is_struct(params), "params must be a struct. Tip: use 'create_params'");

  // Get the variables
  hole_diameter = struct_val(params, "hole_diameter");
  wall_thickness = struct_val(params, "wall_thickness");
  pitch = struct_val(params, "pitch");
  air_gap = struct_val(params, "air_gap");
  height = struct_val(params, "height");
  bolt_thread_inner_diameter = struct_val(params, "bolt_thread_inner_diameter");
  bolt_thread_outer_diameter = struct_val(params, "bolt_thread_outer_diameter");
  nut_thread_inner_diameter = struct_val(params, "nut_thread_inner_diameter");
  nut_thread_outer_diameter = struct_val(params, "nut_thread_outer_diameter");
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");
  sphere_diameter = struct_val(params, "sphere_diameter");
  wire_hole_diameter = struct_val(params, "wire_hole_diameter");
  font_size = struct_val(params, "font_size");

  // Variables must make sense
  assert(wall_thickness > 0);
  assert(pitch > 0);
  assert(air_gap > 0); 
  assert(height > 0);
  assert(wire_hole_diameter > 0);
  assert(font_size > 0);

  // Diameters go up
  assert(hole_diameter > 0);
  assert(bolt_thread_inner_diameter > hole_diameter);
  assert(bolt_thread_outer_diameter > bolt_thread_inner_diameter);
  assert(nut_thread_inner_diameter > bolt_thread_outer_diameter);
  assert(nut_thread_outer_diameter > nut_thread_inner_diameter);
  assert(nut_outer_diameter > nut_thread_outer_diameter);
  assert(sphere_diameter > nut_outer_diameter);

  // Other constraints
  assert(air_gap > 1, "An air gap between 0-1 mm is too narrow for the screw to turn"); 
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
module draw_bolt(params)
{
  check_params(params);
  height = struct_val(params, "height");
  pitch = struct_val(params, "pitch");
  hole_diameter = struct_val(params, "hole_diameter");
  bolt_thread_inner_diameter = struct_val(params, "bolt_thread_inner_diameter");
  bolt_thread_outer_diameter = struct_val(params, "bolt_thread_outer_diameter");
  color([1, 0, 0])
    difference() {
      threaded_rod(d = bolt_thread_outer_diameter, l = height, pitch = pitch);
      cylinder(h = height, d = hole_diameter, center = true);
    }
}

// Upper, outer, blue, part
module draw_nut(params)
{
  check_params(params);

  height = struct_val(params, "height");
  pitch = struct_val(params, "pitch");
  nut_thread_inner_diameter = struct_val(params, "nut_thread_inner_diameter");
  nut_thread_outer_diameter = struct_val(params, "nut_thread_outer_diameter");
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");

  color([0, 0, 1])
    intersection() {
      threaded_nut(
        shape = "square", 
        nutwidth = nut_outer_diameter, 
        id = nut_thread_inner_diameter, 
        h = height, 
        pitch = pitch,
        ibevel = false,
        spin = 180
      );  
      cylinder(height, d = nut_outer_diameter, center = true);
    }
}


module draw_sphere(params) 
{
  check_params(params);
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");
  spere_diameter = struct_val(params, "sphere_diameter");
  assert(struct_val(params, "sphere_diameter") == spere_diameter);
  // Outer sphere, lower half cut off
  color([0,1,0])
    difference() {
      sphere(d = spere_diameter);
      sphere(d = nut_outer_diameter);
    };
}


module draw_upper_sphere(params) 
{
  check_params(params);
  height = struct_val(params, "height");
  hole_diameter = struct_val(params, "hole_diameter");
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");
  spere_diameter = struct_val(params, "sphere_diameter");
  wire_hole_diameter = struct_val(params, "wire_hole_diameter");
  font_size = struct_val(params, "font_size");
  // Add a hole
  // Outer sphere, lower half cut off
  color([0,1,0])
    difference() {
      draw_sphere(params);
      translate([-(spere_diameter / 2), -(spere_diameter / 2), -spere_diameter - (height / 2)])
        cube(spere_diameter);
    };
  // Connect sphere to nut
  color([0.5,1,0.5])
    // Make the open ring go down directly to prevent scaffolding
    intersection() {
      // Open ring that connects out wall to nut
      difference() {
        translate([0, 0, +(height / 2) + (spere_diameter / 2)])
          cylinder(h = spere_diameter, d = nut_outer_diameter, center = true);
        translate([0, 0, +(height / 2) + (spere_diameter / 2)])
          cylinder(h = spere_diameter, d = hole_diameter, center = true);
      }
      sphere(d = spere_diameter);
    };


  text_on_sphere(t = "Minimal Pi Clock", r = spere_diameter / 2, size = font_size);
}

module draw_lower_sphere_without_holes(params)
{
  check_params(params);
  height = struct_val(params, "height");
  hole_diameter = struct_val(params, "hole_diameter");
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");
  spere_diameter = struct_val(params, "sphere_diameter");
  wall_thickness = struct_val(params, "wall_thickness");
  wire_hole_diameter = struct_val(params, "wire_hole_diameter");
  speaker_hole_diameter = struct_val(params, "speaker_hole_diameter");
  // Outer sphere, upper half cut off
  color([0,1,0])
    difference() {
      draw_sphere(params);
      translate([-(spere_diameter / 2), -(spere_diameter / 2), -(height / 2)])
        cube(spere_diameter);
    };
  // Connect sphere to bolt
  color([0.5,1,0.5])
    // Make the open ring go down directly to prevent scaffolding
    intersection() {
      // Open ring that connects out wall to inner bolt
      difference() {
        translate([0, 0, -(height / 2) - (spere_diameter / 2)])
          cylinder(h = spere_diameter, d = nut_outer_diameter, center = true);
        translate([0, 0, -(height / 2) - (spere_diameter / 2)])
          cylinder(h = spere_diameter, d = hole_diameter, center = true);
      }
      sphere(d = spere_diameter);
    };
}

module draw_lower_sphere(params)
{
  check_params(params);
  height = struct_val(params, "height");
  hole_diameter = struct_val(params, "hole_diameter");
  nut_outer_diameter = struct_val(params, "nut_outer_diameter");
  spere_diameter = struct_val(params, "sphere_diameter");
  wall_thickness = struct_val(params, "wall_thickness");
  wire_hole_diameter = struct_val(params, "wire_hole_diameter");
  speaker_hole_diameter = struct_val(params, "speaker_hole_diameter");
  // Outer sphere, upper half cut off
  color([0,1,0])
    difference() {
    draw_lower_sphere_without_holes(params);
    rotate([70, 0, 0])
      translate([0, 0, -spere_diameter])
        cylinder(spere_diameter, d = wire_hole_diameter);
      rotate([-70, 0, 0])
        translate([0, 0, -spere_diameter])
          cylinder(spere_diameter, d = speaker_hole_diameter);
    }
}

// The upper half has the nut
module draw_upper_half(params) 
{
  check_params(params);
  draw_upper_sphere(params);
  draw_nut(params);
}

// The upper half has the bolt
module draw_lower_half(params) 
{
  check_params(params);
  draw_lower_sphere(params);
  draw_bolt(params);
}

//-----------------------------------------------------------------------
// Program starts here
//-----------------------------------------------------------------------
if (display_mode == 0) 
{
  // Make the outsides be up; only scaffolding marks on the inside
  draw_upper_half(params);
  spere_diameter = struct_val(params, "sphere_diameter");
  translate([spere_diameter + 1, 0, 0])
  rotate([180, 0, 0])
  draw_lower_half(params);
}
else if (display_mode == 1) 
{
  draw_lower_half(params);
  draw_upper_half(params);
}
else if (display_mode == 2) 
{
  // Show cutout
  difference() {
    draw_lower_half(params);
    translate([-500,0,-500])
      cube([1000, 100, 1000]);
  }
  difference() {
    draw_upper_half(params);
    translate([-500,0,-500])
      cube([1000, 100, 1000]);
  }
} 
else if (display_mode == 3) 
{
  // Show cutout
  difference() {
    draw_lower_half(params);
    translate([0,-500,-500])
      cube([100, 1000, 1000]);
  }
  difference() {
    draw_upper_half(params);
    translate([0,-500,-500])
      cube([100, 1000, 1000]);
  }
} 
    