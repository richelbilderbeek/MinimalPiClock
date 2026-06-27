// Made by Claude. I, Richel, think it is quite a bad design :-/
//
// === Dimensions ===
outer_width     = 40; // mm  (X when assembled)
outer_depth     = 30; // mm  (Y when assembled)
outer_height    = 20; // mm  (Z when assembled)
wall_thickness  = 2;  // mm
inner_width     = outer_width  - wall_thickness;
inner_depth     = outer_depth  - wall_thickness;
inner_height    = outer_height - wall_thickness;

n_teeth         = 10;
teeth_air       = 0.25; // gap per tooth side, mm
piezo_diameter  = 12;   // mm
piezo_radius    = piezo_diameter / 2;
cable_diameter  = 5;    // mm
cable_radius    = cable_diameter / 2;

spacing         = 3;    // gap between unconnected panels in the flat layout

//
// Panel roles (assembled box):
//   1 = bottom   (has piezo cutout — glued first while flat, fully accessible)
//   2 = left side
//   3 = top
//   4 = right side (has cable hole at bottom edge when assembled)
//   5 = front
//   6 = back
//
// New flat layout — connected vertical strip + wings:
//
//         [5 front]       w×h
//         [3 top  ]       w×d
//   [2 L] [1 botm ] [4 R] h×d | w×d | h×d
//         [6 back ]       w×h
//
// Panels 5-3-1-6 are directly connected (share an edge, no gap).
// Panels 2 and 4 sit beside panel 1 with a small spacing gap
// (they still need teeth on that edge to lock in).
//
// Assembly order:
//   1. Glue piezo to panel 1 (bottom) while it lies flat — easy access.
//   2. Fold 5-3-1-6 strip into a U, add panel 2 and 4 as sides, lastly close.
//   3. Route cable through hole in panel 4 (right side, near bottom edge).

// -----------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------

// Teeth along the LEFT edge of a panel (pointing left, every other slot)
module teeth_left(dx, dy, nt) {
    yt = dy / nt;
    for (i = [0 : nt/2 - 1])
        translate([-wall_thickness, i * yt * 2 + teeth_air, 0])
            cube([wall_thickness, yt - teeth_air, wall_thickness]);
}

// Teeth along the RIGHT edge
module teeth_right(dx, dy, nt) {
    yt = dy / nt;
    for (i = [0 : nt/2 - 1])
        translate([dx, yt + i * yt * 2 + teeth_air, 0])
            cube([wall_thickness, yt - teeth_air, wall_thickness]);
}

// Teeth along the TOP edge (pointing up)
module teeth_top(dx, dy, nt) {
    xt = dx / nt;
    for (i = [0 : nt/2 - 1])
        translate([i * xt * 2 + teeth_air, dy, 0])
            cube([xt - teeth_air, wall_thickness, wall_thickness]);
}

// Teeth along the BOTTOM edge (pointing down)
module teeth_bottom(dx, dy, nt) {
    xt = dx / nt;
    for (i = [0 : nt/2 - 1])
        translate([xt + i * xt * 2 + teeth_air, -wall_thickness, 0])
            cube([xt - teeth_air, wall_thickness, wall_thickness]);
}

// -----------------------------------------------------------------------
// Generic panel: face + selective teeth on each of the 4 edges.
// Flags: tl=left, tr=right, tt=top, tb=bottom  (1=draw teeth, 0=plain edge)
// -----------------------------------------------------------------------
module panel(dx, dy, nt, tl=1, tr=1, tt=1, tb=1) {
    cube([dx, dy, wall_thickness]);
    if (tl) teeth_left(dx, dy, nt);
    if (tr) teeth_right(dx, dy, nt);
    if (tt) teeth_top(dx, dy, nt);
    if (tb) teeth_bottom(dx, dy, nt);
}

// -----------------------------------------------------------------------
// Panel 1 — bottom, with piezo mounting recess + through-hole
// Piezo sits centred in X, near the front in Y (accessible, away from cable)
// -----------------------------------------------------------------------
module panel_bottom() {
    difference() {
        panel(inner_width, inner_depth, n_teeth, tl=1, tr=1, tt=0, tb=0);
        // Recess ring: lets the piezo lip sit flush
        translate([inner_width/2, inner_depth/4, wall_thickness - 0.5])
            cylinder(h=1.5, r=piezo_radius + teeth_air, $fn=64);
        // Through-hole: sound can pass / wire can be routed if needed
        translate([inner_width/2, inner_depth/4, -1])
            cylinder(h=wall_thickness + 2, r=piezo_radius - 1, $fn=64);
    }
}

// -----------------------------------------------------------------------
// Panel 4 — right side, cable hole near the bottom-assembled edge
// -----------------------------------------------------------------------
module panel_right() {
    difference() {
        panel(inner_height, inner_depth, n_teeth, tl=1, tr=1, tt=0, tb=0);
        // Cable hole: centred in depth, close to the bottom edge (y≈cable_radius+wt)
        translate([inner_height/2, inner_depth/2, -1])
            cylinder(h=wall_thickness + 2, r=cable_radius + teeth_air, $fn=32);
    }
}

// -----------------------------------------------------------------------
// Flat layout
//
// The strip 5→3→1→6 is laid out top-to-bottom, connected (no gap).
// Panel widths in the strip direction:
//   5 (front): inner_height tall
//   3 (top)  : inner_depth tall
//   1 (botm) : inner_depth tall
//   6 (back) : inner_height tall
//
// Panels 2 (left) and 4 (right) sit beside panel 1 with spacing.
// -----------------------------------------------------------------------

// Origin of the strip: panel 5 starts at (0,0)
p5_x = 0;
p5_y = 0;

p3_x = p5_x;
p3_y = p5_y - inner_depth;        // directly below panel 5 (front)
// (no gap — shared edge)

p1_x = p3_x;
p1_y = p3_y - inner_depth;        // directly below panel 3 (top)

p6_x = p1_x;
p6_y = p1_y - inner_height;       // directly below panel 1 (bottom)

// Left panel (2) beside panel 1
p2_x = p1_x - inner_height - spacing;
p2_y = p1_y;

// Right panel (4) beside panel 1
p4_x = p1_x + inner_width + spacing;
p4_y = p1_y;

//
//        [5 front  ] — top of strip, free top/left/right teeth
//        [3 top    ] — free left/right teeth
//  [2 L] [1 bottom ] [4 R]
//        [6 back   ] — free left/right/bottom teeth
//

// --- Panel 5: front  (w × h), free on left, right, top ---
translate([p5_x, p5_y, 0])
    panel(inner_width, inner_height, n_teeth, tl=1, tr=1, tt=1, tb=0);

// --- Panel 3: top  (w × d), free on left, right ---
translate([p3_x, p3_y, 0])
    panel(inner_width, inner_depth, n_teeth, tl=1, tr=1, tt=0, tb=0);

// --- Panel 1: bottom (w × d), piezo cutout, free on left, right ---
translate([p1_x, p1_y, 0])
    panel_bottom();

// --- Panel 6: back (w × h), free on left, right, bottom ---
translate([p6_x, p6_y, 0])
    panel(inner_width, inner_height, n_teeth, tl=1, tr=1, tt=0, tb=1);

// --- Panel 2: left side (h × d), free on left, top, bottom ---
translate([p2_x, p2_y, 0])
    panel(inner_height, inner_depth, n_teeth, tl=1, tr=0, tt=1, tb=1);

// --- Panel 4: right side (h × d), cable hole, free on right, top, bottom ---
translate([p4_x, p4_y, 0])
    panel_right();
