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

part_1_x = -outer_width - outer_depth;
part_1_y = -outer_depth / 2;

part_2_x = part_1_x + outer_width + wall_thickness + spacing;
part_2_y = part_1_y;

part_3_x = part_2_x + outer_height + wall_thickness + spacing;
part_3_y = part_2_y;

part_4_x = part_3_x + outer_width + wall_thickness + spacing;
part_4_y = part_3_y;

part_5_x = part_3_x;
part_5_y = part_3_y + outer_depth + wall_thickness + spacing;

part_6_x = part_3_x;
part_6_y = part_3_y - (outer_depth / 2) - (outer_height / 2) - (3 * wall_thickness) - spacing;

//
//        +--+  +--+  +--+
//        |  |  |  |  |  |
//        +..+--+..+--+..+--+--+
//        |                 .  |
//     +--+                 +--+
//     |  .                 |   
//     +--+                 +--+
//        |                 .  |
//     +--+                 +--+
//     |  .                 |
//     +--+--+..+--+..+--+..+
//           |  |  |  |  |  |
//           +--+  +--+  +--+
//
module draw_piece(
  part_x,
  part_y,
  inner_dx,
  inner_dy,
  n_teeth
) {
  translate([part_x, part_y, 0])
    cube([inner_dx, inner_dy, wall_thickness]);

  x_teeth_length = inner_dx / n_teeth;
  y_teeth_length = inner_dy / n_teeth;

  // Left teeth
  for (i = [0:n_teeth/2-1])
    translate([part_x, part_y, 0])
      translate([-wall_thickness, i * y_teeth_length  * 2,0])
        translate([0, teeth_air, 0])
          cube([wall_thickness,y_teeth_length - teeth_air,wall_thickness]);
  // Right teeth
  for (i = [0:n_teeth/2-1])
    translate([part_x, part_y, 0])
      translate([inner_dx, y_teeth_length + (i * y_teeth_length  * 2),0])
        translate([0, teeth_air, 0])
          cube([wall_thickness,y_teeth_length - teeth_air,wall_thickness]);
  // Top, between 5 and 1
  for (i = [0:n_teeth/2-1])
    translate([part_x, part_y, 0])
      translate([0 + (i * x_teeth_length  * 2), inner_dy, 0])
        translate([teeth_air, 0, 0])
          cube([x_teeth_length - teeth_air, wall_thickness,wall_thickness]);
  // Bottom teeth, between 1 and 6 
  for (i = [0:n_teeth/2-1])
    translate([part_x, part_y, 0])
      translate([x_teeth_length + (i * x_teeth_length  * 2), -wall_thickness,0])
        translate([teeth_air, 0, 0])
          cube([x_teeth_length - teeth_air, wall_thickness, wall_thickness]);

}


//     +-+
//     |5|
// +-+-+-+-+
// |1|2|3|4|
// +-+-+-+-+
//     |6|
//     +-+

draw_piece(
  part_1_x, // part_x 
  part_1_y,  // part_y
  inner_width, // inner_dx
  inner_depth, // inner_dy
  n_teeth // n_teeth
);

draw_piece(
  part_2_x, // part_x 
  part_2_y,  // part_y
  inner_height, // inner_dx
  inner_depth, // inner_dy
  n_teeth // n_teeth
);


difference() {
  union() {
    draw_piece(
      part_3_x, // part_x 
      part_3_y,  // part_y
      inner_width, // inner_dx
      inner_depth, // inner_dy
      n_teeth // n_teeth
    );
  }

  translate([part_3_x + piezo_radius + wall_thickness, part_3_y + piezo_radius + wall_thickness, 0.5])
    cylinder(10, (piezo_diameter / 2) + (teeth_air * 2), (piezo_diameter / 2) + (teeth_air * 2));
  translate([part_3_x + piezo_radius + wall_thickness, part_3_y + piezo_radius + wall_thickness, -5])
    cylinder(10, piezo_radius - (teeth_air * 2), piezo_radius - (teeth_air * 2));
}

difference() {
  union() {
    draw_piece(
      part_4_x, // part_x 
      part_4_y,  // part_y
      inner_height, // inner_dx
      inner_depth, // inner_dy
      n_teeth // n_teeth
    );
  }
  translate([part_4_x + cable_radius + (inner_height / 4) + wall_thickness, part_4_y + cable_radius + (inner_depth / 2) + wall_thickness, -5])
    cylinder(10, cable_radius + (teeth_air * 2), cable_radius + (teeth_air * 2));

}

draw_piece(
  part_5_x, // part_x 
  part_5_y,  // part_y
  inner_width, // inner_dx
  inner_height, // inner_dy
  n_teeth // n_teeth
);


draw_piece(
  part_6_x, // part_x 
  part_6_y,  // part_y
  inner_width, // inner_dx
  inner_height, // inner_dy
  n_teeth // n_teeth
);


