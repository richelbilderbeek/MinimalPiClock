// Made by Claude. I, Richel, think it is quite a bad design :-/
//
// ============================================================
// Piezo casing — foldable flat-pack with living hinges
// ============================================================
//
// Layout (flat):
//
//              [3 top/lid]
//                  |
//       [2 left]--[1 bottom]--[4 right]
//                  |               |
//              [5 front]       (cable hole)
//                  |
//              [6 back — piezo hole]
//
// Panels 1,2,4,5,6 are connected via living hinges (thin flex lines).
// Panel 3 (lid) is a separate piece with finger joints on all 4 edges.
// Panels 2 and 4 also have finger joints on their free top edge
// so they lock to the lid.
//
// Assembly:
//   1. Glue piezo disc into panel 6 (back) while flat — full access.
//   2. Fold 2, 4, 5, 6 up 90° along hinge lines.
//   3. The corner finger joints of 2/4 with 5/6 interlock.
//   4. Thread cable through hole in panel 4, glue panel 4 corner joints.
//   5. Drop lid (panel 3) onto the open top, press finger joints home.
//
// ============================================================

// === Parameters ===
outer_width    = 40;   // X dimension of assembled box
outer_depth    = 30;   // Y dimension
outer_height   = 20;   // Z dimension
wall_t         = 2;    // wall thickness

// Living hinge
hinge_t        = 0.4;  // thickness of flex zone (fraction of wall_t)
hinge_w        = 1.5;  // width of the flex zone along the fold line

// Finger joints
n_teeth        = 6;    // number of teeth per edge (keep even)
teeth_air      = 0.2;  // clearance per side

// Cutouts
piezo_d        = 12;
cable_d        = 5;

// Layout spacing (only between panel 3 and the cross)
spacing        = 4;

// Derived
iw = outer_width  - wall_t;
id = outer_depth  - wall_t;
ih = outer_height - wall_t;

// ============================================================
// MODULES
// ============================================================

// --- Finger teeth along an edge ---
// axis: "x" = teeth point in X dir (along a Y-length edge)
//       "y" = teeth point in Y dir (along an X-length edge)
// side: which side the teeth stick out toward (+1 or -1)
// length: length of the edge
// offset_parity: 0=teeth on even slots, 1=teeth on odd slots
//   (use opposite parities on mating edges so they interlock)

module teeth_x(length, side, parity) {
    // teeth stick out in X, edge runs in Y
    t = length / n_teeth;
    for (i = [0 : n_teeth - 1]) {
        if ((i % 2) == parity)
            translate([
                side > 0 ? 0 : -wall_t,
                i * t + teeth_air,
                0
            ])
            cube([wall_t, t - 2*teeth_air, wall_t]);
    }
}

module teeth_y(length, side, parity) {
    // teeth stick out in Y, edge runs in X
    t = length / n_teeth;
    for (i = [0 : n_teeth - 1]) {
        if ((i % 2) == parity)
            translate([
                i * t + teeth_air,
                side > 0 ? 0 : -wall_t,
                0
            ])
            cube([t - 2*teeth_air, wall_t, wall_t]);
    }
}

// --- Living hinge line ---
// Creates a thin groove across the full width of the panel
// so it can fold. Groove is cut from the top surface.
// dir: "x" = groove runs in X (fold along X axis)
//      "y" = groove runs in Y
// panel_w, panel_d: panel extents in X and Y
// pos: position of hinge along the other axis
module hinge_groove_x(panel_w, pos) {
    translate([0, pos - hinge_w/2, wall_t - hinge_t])
        cube([panel_w, hinge_w, hinge_t + 0.01]);
}
module hinge_groove_y(panel_d, pos) {
    translate([pos - hinge_w/2, 0, wall_t - hinge_t])
        cube([hinge_w, panel_d, hinge_t + 0.01]);
}

// ============================================================
// PANEL 1 — bottom (iw × id)
// Hinges to: 2 (left edge, x=0), 4 (right edge, x=iw),
//            5 (front edge, y=0), 6 (back edge, y=id)
// No finger joints on its own edges (hinge takes care of it).
// ============================================================
module panel_bottom() {
    difference() {
        cube([iw, id, wall_t]);
        // living hinges
        hinge_groove_y(id, 0);          // left edge hinge
        hinge_groove_y(id, iw);         // right edge hinge
        hinge_groove_x(iw, 0);          // front edge hinge
        hinge_groove_x(iw, id);         // back edge hinge
    }
}

// ============================================================
// PANEL 2 — left side (ih × id), attached to panel 1 left edge
// Free top edge: finger joints (locks to lid)
// Left/right edges: become corners — finger joints with 5 and 6
// Bottom edge: hinge (already on panel 1)
// ============================================================
module panel_left() {
    union() {
        difference() {
            cube([ih, id, wall_t]);
            // No grooves needed here — hinge is on panel 1
        }
        // Top edge teeth (mate with lid panel 3, parity 0)
        teeth_y(ih, +1, 0);
        // Left edge teeth (mate with panel 5 front, parity 0)
        teeth_x(id, -1, 0);
        // Right edge teeth (mate with panel 6 back, parity 0)
        teeth_x(id, +1, 0);
    }
}

// ============================================================
// PANEL 4 — right side (ih × id), attached to panel 1 right edge
// Cable hole centred in the panel (easy to route wire before closing lid)
// Free top edge: finger joints (locks to lid)
// Left/right edges: finger joints with 5 and 6
// ============================================================
module panel_right() {
    difference() {
        union() {
            cube([ih, id, wall_t]);
            // Top edge teeth (mate with lid, parity 0)
            teeth_y(ih, +1, 0);
            // Left edge (mates with panel 5)
            teeth_x(id, -1, 0);
            // Right edge (mates with panel 6)
            teeth_x(id, +1, 0);
        }
        // Cable hole — centred, near the bottom of the assembled wall
        // (bottom = the hinge side = y=0 in flat layout)
        translate([ih/2, id * 0.25, -1])
            cylinder(h=wall_t+2, r=cable_d/2 + teeth_air, $fn=32);
    }
}

// ============================================================
// PANEL 5 — front (iw × ih), attached to panel 1 front edge
// Left/right edges: finger joints with 2 and 4 (parity 1, mates 0)
// Top edge: finger joints with lid (parity 0)
// Bottom edge: hinge (on panel 1)
// ============================================================
module panel_front() {
    union() {
        cube([iw, ih, wall_t]);
        // Top edge (mates with lid, parity 0)
        teeth_y(iw, +1, 0);
        // Left edge (mates with panel 2 right side, parity 1 → interlocks with parity 0)
        teeth_x(ih, -1, 1);
        // Right edge (mates with panel 4 left side, parity 1)
        teeth_x(ih, +1, 1);
    }
}

// ============================================================
// PANEL 6 — back (iw × ih), attached to panel 1 back edge
// Piezo hole: centred, full access while flat
// Left/right edges: finger joints with 2 and 4 (parity 1)
// Top edge: finger joints with lid (parity 0)
// ============================================================
module panel_back() {
    difference() {
        union() {
            cube([iw, ih, wall_t]);
            // Top edge (mates with lid, parity 0)
            teeth_y(iw, +1, 0);
            // Left edge (mates with panel 2, parity 1)
            teeth_x(ih, -1, 1);
            // Right edge (mates with panel 4, parity 1)
            teeth_x(ih, +1, 1);
        }
        // Piezo hole — centred in the panel
        translate([iw/2, ih/2, -1])
            cylinder(h=wall_t+2, r=piezo_d/2 + teeth_air, $fn=64);
    }
}

// ============================================================
// PANEL 3 — lid (iw × id), separate piece
// All 4 edges have finger joints (parity 1, mates parity 0 on walls)
// ============================================================
module panel_lid() {
    union() {
        cube([iw, id, wall_t]);
        // All four edges, parity 1 (mates with parity 0 on walls)
        teeth_y(iw, -1, 1);           // front edge (mates panel 5)
        teeth_y(iw, +1, 1);           // back edge  (mates panel 6)
        teeth_x(id, -1, 1);           // left edge  (mates panel 2)
        teeth_x(id, +1, 1);           // right edge (mates panel 4)
    }
}

// ============================================================
// FLAT LAYOUT
//
//     [3 lid]   — above the cross, with spacing
//
//         [6 back ]
//  [2 L]  [1 botm ]  [4 R]
//         [5 front]
//
// ============================================================

// Panel 1 origin (centre of cross)
p1x = ih + wall_t;   // leave room for panel 2 to the left
p1y = ih + wall_t;   // leave room for panel 5 below

// Panel 5 (front) — below panel 1
translate([p1x, p1y - ih - wall_t, 0])  panel_front();

// Panel 6 (back) — above panel 1
translate([p1x, p1y + id + wall_t, 0])  panel_back();

// Panel 2 (left) — left of panel 1
translate([p1x - ih - wall_t, p1y, 0])  panel_left();

// Panel 4 (right) — right of panel 1
translate([p1x + iw + wall_t, p1y, 0])  panel_right();

// Panel 1 (bottom)
translate([p1x, p1y, 0])  panel_bottom();

// Panel 3 (lid) — separate, above with spacing
translate([p1x, p1y + id + ih + wall_t*2 + spacing, 0])  panel_lid();

