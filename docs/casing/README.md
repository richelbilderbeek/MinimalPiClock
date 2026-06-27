# Casing

- OpenSCAD file: [`sphere.scad`](sphere.scad)

I designed the casing in OpenSCAD:

![Casing, in OpenSCAD](sphere_openscad.png)

I used two OpenSCAD libraries:

- [BOSL2](https://github.com/BelfrySCAD/BOSL2): for the thread
- [text_on_OpenSCAD](https://github.com/brodykenrick/text_on_OpenSCAD):
  for the text on the machine

The code has multiple modes to display the casing.
There is a mode for displaying the two half-spheres side-by-side,
to have one print. This may be slower, however, than (displaying and) printing
each half seperately, as the 3D printer head needs to move between two half
spheres.

## History of the casing

## Six pieces box

My first real casing design, in OpenSCAD:

- [six_pieces_box.scad](six_pieces_box.scad)

![Six pieces box](six_pieces_box.png)

I wanted a design without scaffolding, hence I opted
to glue to pieces together.

However, I was unhappy with this design, as it involved too much glue
and the glue was not strong enough.

I realized that
I can instead go for an open box design, where only a
lid needs to be conneced to the box-except-lid.
I decided to transition to this two pieces box design.

## Transition to two pieces box using Claude

I tried to transition to the two pieces box version
using Claude. It did not work out well

- [transition_1.scad](transition_1.scad)

![Transition 1](transition_1.png)

- [transition_2.scad](transition_2.scad)

![Transition 2](transition_2.png)

## Two pieces box

Here is an open box design:

- [two_pieces_box.scad](two_pieces_box.scad)

![two_pieces_box.png](two_pieces_box.png)

However, how to connect the lid?

I decided to start using a screw-on approach. Then, I realized,
that I might as well make the clock spherical: it fits the theme better.

This is how I landed on the final design.

## Sphere

The sphere design worked great!

My first design had a structural weakness:
the ring that connected the bolt with the outer sphere
was too thin and needed scaffolding.

![Sphere v0.1](sphere_openscad_v0_1.png)

I decided to make both the bolt and nut to extend down/up the entire
half-sphere, making it sturdier and reduce scaffolds.
