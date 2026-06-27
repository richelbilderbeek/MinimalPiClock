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

???- question "Can you give some measured print times?"

    Yes, here are measured print times:

    Shere|Printing time (mins)
    -----|--------------------
    Lower|123
    Upper|138
    Both |267

    From these numbers, we can conclude that it is shorter to print each
    half-sphere in isolation: it takes 261 mins for printing each half
    in isolation winning 6 minutes. However, in those 6 minutes
    between prints, time is lost by manually removing the printed first half
    and starting the printer to do the other half.

For historians, see [the casing's history](../casings_history/README.md)
