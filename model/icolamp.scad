$fn=50;
/* This model generates components for an icosahedron lamp.  The lamp is composed
 * of a number of 'sections' (each of which makes up one face of the lamp).
 * Icosahedrons have 20 faces of equilateral triangles, all of which have the same
 * edge lengths.
 *
 * Each section can be thought of a triangular face at the surface of the
 * icosahedron extruded and tapering towards the point at the centre of the
 * icosahedron (so essentially, a pyramid).
 *
 * The centre of the icosahedron is cavity to allow a string of LEDs to be placed.
 * There is then a "lid" and a "lens".  The lid is a shallow cover which holds
 * the LED in place within the lens, and the lens is a hollow truncated pyramid,
 * with a thin cover at its base (presumably white or translucent plastic), and
 * an open top, which will be covered by the lid.
 *
 * Units of length are in mm.
 * Units of angle are in degrees.
 */

// lensDepth is the distance from the base of the lens to the top of the lens
// using a line perpendicular to the base, towards the central point of the
// icosahedron.
lensDepth = 30;

// cavityDepth is the distance from the top of the lens to the central point of
// the icosahedron.
cavityDepth = 40;

// wallWidth is the width of the walls of the icosahedron segments
wallWidth = 1;

// ledHoleSize is the diameter of the hole to be made in the segment lids,
// into which the LEDs should be inserted
ledHoleSize = 12.5;

// lensThickness is the thickness of the outer part of the lens, which will
// act to diffuse the light.  I based 0.6mm on the fact I wanted two layers
// of plastic at 0.3mm layer height
lensThickness = 0.6;

// some tolerance to add to parts that should fit together
tolerance = 0.03;

// the depth of the lip on the lid, which inserts into the lens in order
// ensure it is positioned securely
lidLipSize = 2;

// the base of the lamp is an icosahedron section that has been extended.
// baseAdditionalHeight is the additional height of the base section compared
// to the other lamp sections
baseAdditionalHeight = 30;
// in addition to the extended icosahedron section, there's the option to
// have a vertical triangular base extending from the base icosahedon section.
// baseSquareHeight is the height of the vertical extension at the base.
baseSquareHeight = 10;

// the diameter around the centre of the power jack that should be flattened
// for it to sit square.  Note that this must include any clearance required
// for the nut behind the power jack to be tightened.
powerOuterDiameter = 13 + 2 * wallWidth;

// some power sockets have a pill-shaped part which inserts into the body
// of the case. The following terms use 'diameter' mainly because the component
// I was using was rounded...
//
// powerHorizDiameter is the width of the hole to be made for the power jack
powerHorizDiameter = 7.5;
// powerVertDiameter is the height of the hole to be made for the power jack
powerVertDiameter = 9;
// powerHeightFromBase is the distance from the centre of the power jack to
// the base of the unit (i.e. how far from the table do you want the jack...)
powerHeightFromBase = 10;
// switchDiameter is the diameter of the hole to be made for the power switch
switchDiameter = 16.5;

/*
 * End of configuration
 */

// outerDepth is the distance from the centre of the icosahedron to the outer
// face of the lens.
outerDepth = lensDepth + cavityDepth;

// icoRadiusToFaceEdgeLength calculates the length of an edge of an equilateral
// triangle making up a face of the icosahedron given the distance (radius) of
// the face of the icosahedron to the centre of the icosahedron (taken on the
// line perpendicular to the centre of the face through the centre of the
// icosahedron)
function icoRadiusToFaceEdgeLength(radius) = radius * 12 / (sqrt(3) * (3 + sqrt(5)));

// the points of an equilateral triangle can be though of as three points distributed
// evently on a circle of a given radius.
// icoRadiusToFaceRadius calculates the radius of that circle for the triangle
// that defines the face of an icosahedron where the face is distance 'radius'
// from the centre of the icosahedon.
function icoRadiusToFaceRadius(radius) = icoRadiusToFaceEdgeLength(radius) / sqrt(3);

// faceRadiusMinusWallWidth calculates the radius of the circle on which
// an equilateral triangle's points lie, where the sides of that new triangle
// are "wallWidth" perpendicular distance from the equilateral triangle described
// by a circle of radius "radius".
function faceRadiusMinusWallWidth(radius, wallWidth) = radius - 2 * wallWidth;

// pyramid defines an extrusion of an equilateral triangle whose points lie on
// a circle of radius r towards a singular point at the centre of that triangle
// and h above it.
module pyramid(r, h) {
  vertices = [[r,0,0], [r * cos(120),r * sin(120),0], [r * cos(240), r * sin(240),0],[0,0,h]];
  polyhedron(points=vertices,faces=[[0,1,2],[1,0,3],[0,2,3],[2,1,3]]);
}

// extrudedTriangle simply extrudes an equilateral triangle whose points lie
// on a circle of radius r to a depth of 'depth'
module extrudedTriangle(r, depth) {
  vertices = [[r,0,0], [r * cos(120),r * sin(120),0], [r * cos(240), r * sin(240),0],[r,0,depth], [r * cos(120),r * sin(120),depth], [r * cos(240), r * sin(240),depth]];
  polyhedron(points=vertices,faces=[[0,1,2],[3,5,4],[0,3,4,1],[1,4,5,2],[2,5,3,0]]);
}

// icoSection is truncated pyramid where the base is `outerDepth` from what would
// normally be the peak of the pyramid, but where the top of the pyramid is removed
// at a distance of `innerDepth` from what would have been the peak.
module icoSection(innerDepth, outerDepth) {
  difference() {
    pyramid(icoRadiusToFaceRadius(outerDepth), outerDepth);
    translate([0,0,outerDepth - innerDepth])
      pyramid(icoRadiusToFaceRadius(innerDepth), outerDepth);
  }
}

// icoLens defines the lens component of the icosahedron section.  It is essentially
// a hollowed out icoSection.
// with the wider part of the lens at the bottom:
// innerDepth defines the distance of the top of the lens from the centre of
//  the icosahedron.
// outerDepth defines the distance of the bottom of the lens from the centre
//   of the icosahedron.
// wallWidth defines the width of the walls of the section.
// lensWidth defines how thick the bottom part of the lens should be.  This
//   will act as the diffuser when the lamp is built.
module icoLens(innerDepth, outerDepth, wallWidth, lensWidth) {
  difference() {
    icoSection(innerDepth, outerDepth);
    translate([0,0,lensWidth])
      pyramid(faceRadiusMinusWallWidth(icoRadiusToFaceRadius(outerDepth - lensWidth),wallWidth),outerDepth - lensWidth);
  }
}

// icoLid defines the part that sits on the top of a lens, and holds the LED
// for that lens in place.  It has a lip, which sits inside the lens in order to
// help it sit correctly.
// ledHoleDiameter is the diameter of the hole that should be made to insert the LED
// innerDepth is the distance from the top of the *lens* to the centre of the icosahedron.
// wallWidth is the thickness of the lid.
// lipSize the depth of the lip that sits inside the lens.
module icoLid(ledHoleDiameter,innerDepth, wallWidth,lipSize) {
  difference() {
    union() {
      icoSection(innerDepth-wallWidth, innerDepth);
      translate([0,0,-lipSize])
      difference(){
        extrudedTriangle(faceRadiusMinusWallWidth(icoRadiusToFaceRadius(innerDepth),wallWidth + tolerance), lipSize);
        extrudedTriangle(faceRadiusMinusWallWidth(icoRadiusToFaceRadius(innerDepth),2 * wallWidth), lipSize);
      }
    }
    translate([0,0,-wallWidth]) cylinder(r=ledHoleDiameter/2, h=wallWidth * 2);
  }
}

// icosahedronQuadrant defines one quarter of an icosahedron (though note that)
// the final lamp cannot be composed of the four icosahedrons placed together.
// This is useful for producing a jig to aid gluing the lenses together.
module icosahedronQuadrant(outerDepth,cavityDepth, wallWidth, ledHoleSize, sections=5) {
  translate([0,0,icoRadiusToFaceEdgeLength(outerDepth) * sin(72)])
  rotate(a=180,v=[1,0,0])
  for (i=[0:(sections-1)]) {
    rotate(a=360/5 *i)
    rotate(a=atan(icoRadiusToFaceRadius(outerDepth) / outerDepth),v=[0,1,0])
    translate([-icoRadiusToFaceRadius(outerDepth),0,0]) union() {
      //icoLens(cavityDepth,outerDepth,wallWidth,lensThickness);
      translate([0,0,lensDepth]) icoLid(ledHoleSize, cavityDepth, wallWidth);
    }
  }
}

// powerSection is the extruded cross-section of the power jack. It is used to
// cut a hole in the base of the lamp into which the power jack can be inserted.
module powerSection(width, height, depth) {
  endRadius = width/2;
  midSectionHeight = height - width;
  union(){
    translate([0,endRadius,0]) cylinder(r=endRadius, h=depth);
    if (midSectionHeight > 0) {
      translate([-width/2,endRadius,0]) cube(size=[width, midSectionHeight, depth]);
    }
    translate([0,height-endRadius,0]) cylinder(r=width/2, h=depth);
  }
}

// base is the extended icosahedron segment on which the lamp rests.  It also
// contains the power jack, and switch, and houses the electronics.  The base
// itself has no top nor bottom.  The bottom is provided by 'baseLid', defined below.
module base(innerDepth, outerDepth, powerOuterDiameter, powerHeightFromBase, switchDiameter, wallWidth) {
  standoffHeight = powerHeightFromBase + powerOuterDiameter / 2 + 2 * wallWidth- baseSquareHeight;
  // standoffBaseStart is he 'back' of the unit at the base
  standoffBaseStart = icoRadiusToFaceRadius(outerDepth)  * cos(120);
  // standoffBaseStop is the back of the unit at the height from the base at
  // which the power socket standoff stops
  standoffBaseStop = (icoRadiusToFaceRadius(outerDepth - standoffHeight)) * cos(120);
  standoffWidth = powerOuterDiameter + 2 * wallWidth;
  standoffDepth = -standoffBaseStart + standoffBaseStop;

  // locate the power switch just above the power socket
  switchHeight = standoffHeight + sqrt(pow(switchDiameter,2) * (1 - pow(standoffBaseStart / outerDepth, 2))) / 2;

  difference(){
    union(){
      // vertical extrusion at the base
      extrudedTriangle(icoRadiusToFaceRadius(outerDepth),-baseSquareHeight);
      // icosahedron section
      icoSection(innerDepth, outerDepth);
      //standoff for power, such that the socket is mounted vertically
      translate([standoffBaseStart,-standoffWidth/2]) {
        cube(size=[standoffDepth,standoffWidth,powerHeightFromBase - baseSquareHeight], center=false);
        translate([0,standoffWidth/2,powerHeightFromBase - baseSquareHeight]) rotate(a=90,v=[0,1,0])
          cylinder(r=standoffWidth/2, h=10);
      }
    }

    union(){
      // hollow out the power socket standoff
      translate([standoffBaseStart + wallWidth, wallWidth -standoffWidth/2]) {
        cube(size=[standoffDepth-wallWidth,standoffWidth - 2 * wallWidth, powerHeightFromBase - baseSquareHeight], center=false);
        translate([0,standoffWidth/2-wallWidth,powerHeightFromBase - baseSquareHeight]) rotate(a=90,v=[0,1,0])
          cylinder(r=standoffWidth/2 - wallWidth, h=10);
      }

      // cut out a hole for the power switch
      translate([standoffBaseStart * (outerDepth - switchHeight) / outerDepth,0,switchHeight])
        rotate(a=atan(outerDepth / standoffBaseStart),v=[0,1,0]) cylinder(r=switchDiameter/2, h=2 * wallWidth, center=true);

      // hollow out the icosahedon section,
      pyramid(faceRadiusMinusWallWidth(icoRadiusToFaceRadius(outerDepth),wallWidth),outerDepth);

      // hollow out the vertical base
      extrudedTriangle(faceRadiusMinusWallWidth(icoRadiusToFaceRadius(outerDepth),wallWidth),-baseSquareHeight);

      // cut a hole for the power socket
      translate([standoffBaseStart-wallWidth,0,powerHeightFromBase - baseSquareHeight - powerVertDiameter/2]) rotate(a=90,v=[1,0,0]) rotate(a=90,v=[0,1,0])
        powerSection(powerHorizDiameter,powerVertDiameter,wallWidth*2);
    }
  }
}

// baseLid is a lid on which the base sits, to seal off the bottom of the lamp.
// outerDepth is the depth of the extended base icosahedron *excluding* any vertical extension.
// wallWidth is the width of the sides of the base.
// lipSize is the height of a lip that extends around the inside of the lid, and sits inside the base to help locate the lid.
module baseLid(outerDepth, wallWidth,lipSize=2) {
  extrudedTriangle(icoRadiusToFaceRadius(outerDepth),wallWidth);
  translate([0,0,wallWidth])
  difference(){
    extrudedTriangle(faceRadiusMinusWallWidth(icoRadiusToFaceRadius(outerDepth),wallWidth+0.5),lipSize);
    extrudedTriangle(faceRadiusMinusWallWidth(icoRadiusToFaceRadius(outerDepth),2*wallWidth+0.5),lipSize);
  }

}

// 1 of these
// icoLid(ledHoleSize, cavityDepth, wallWidth, lidLipSize);

// 3 of these
// icosahedronQuadrant(outerDepth,cavityDepth,wallWidth,ledHoleSize);

// 1 of these
// icosahedronQuadrant(outerDepth,cavityDepth,wallWidth,ledHoleSize,3);

// 19 of these
//icoLens(cavityDepth,outerDepth,wallWidth,0.6);

// 1 of these
// I made the wall thicker just to add some more support
// base(cavityDepth, outerDepth + baseAdditionalHeight, powerOuterDiameter, powerHeightFromBase, switchDiameter,1.5*wallWidth);

// 1 of these
// wall width must match the wall width used on the base
//baseLid(outerDepth+baseAdditionalHeight,1.5*wallWidth);
