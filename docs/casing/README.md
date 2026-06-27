# Casing

- OpenSCAD file: [`sphere.scad`](sphere.scad)

I designed the casing in OpenSCAD:

![Casing v0.2, in OpenSCAD](sphere_openscad_v0_2.png)

I used two OpenSCAD libraries:

- [BOSL2](https://github.com/BelfrySCAD/BOSL2): for the thread
- [text_on_OpenSCAD](https://github.com/brodykenrick/text_on_OpenSCAD):
  for the text on the machine

The code has multiple modes to display the casing.
There is a mode for displaying the two half-spheres side-by-side,
to have one print. This may be slower, however, than (displaying and) printing
each half seperately, as the 3D printer head needs to move between two half
spheres.

Shere|Printing time (mins)
-----|--------------------
Lower|123 
Upper|138
Both |?

For historians, see [the casing's history](../casings_history/README.md)
