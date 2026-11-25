// Vista del conjunto: Master Forge de referencia + espina + cabeza «mochila». Solo para ver, no se imprime.
include <ref_forge.scad>
use <mochila.scad>
use <espina.scad>
incl = 25;                              // inclinación de la cabeza hacia atrás
ver_cabeza = true;
eje = [0, 118, 23]; bis = [0, -59.5, -10.7];   // los mismos que en espina.scad y mochila.scad
forge();
color("#f0761f") espina();
if (ver_cabeza) translate(eje) rotate([90 - incl, 0, 0]) translate(-bis) {
  color("#f0761f") marco(); pantalla_ref(); color("#6f7887") cuerpo(); color("#d9691c") corredera(); metacrilato_ref();
}
