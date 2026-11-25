// =====================================================================================================
//  PARED DE USB Y RED de la caja de metacrilato de la Orange Pi 5 Pro — repuesto impreso (2026-11-24)
//  Todas las medidas son del usuario, con calibre, sobre la pieza rota. Las letras son las de la hoja
//  medidas-pared-caja.png. Vista de frente: ventana grande a la izquierda. Origen: esquina de abajo a la izquierda.
//  Se imprime tumbada, sin soportes.   Exportar:  openscad -o pared_usb.stl --export-format binstl pared.scad
// =====================================================================================================
A = 66;      // ancho total, sin pestañas
B = 34;      // alto total, sin pestañas
C = 28;      // del canto izquierdo a la pestaña (arriba y abajo: C = F)
D = 11.6;    // ancho de la pestaña (arriba y abajo: D = G)
E = 3;       // alto de la pestaña (arriba y abajo: E = H)
J = 6;       // del canto izquierdo a la ventana grande
K = 9;       // del canto de arriba a las dos ventanas (K = P)
L = 34;      // ancho de la ventana grande
M = 16.4;    // alto de la ventana grande
N = 6.8;     // de la ventana pequeña al canto derecho
Q = 16.8;    // ancho de la ventana pequeña
R = 14;      // alto de la ventana pequeña
t = 2.8;     // espesor

h_pes = 0.2; // las pestañas se imprimen este poco más estrechas en total, para que entren en sus ranuras
h_ven = 0.15;// las ventanas se abren este poco por cada lado: un hueco impreso sale algo más pequeño que su medida

module pared2d() {
  difference() {
    union() {
      square([A, B]);
      translate([C + h_pes/2, -E]) square([D - h_pes, B + 2*E]);            // las dos pestañas
    }
    translate([J - h_ven, B - K - M - h_ven]) square([L + 2*h_ven, M + 2*h_ven]);          // ventana grande (USB)
    translate([A - N - Q - h_ven, B - K - R - h_ven]) square([Q + 2*h_ven, R + 2*h_ven]);  // ventana pequeña (red)
  }
}
linear_extrude(t) pared2d();
echo(entre_ventanas = A - N - Q - J - L, bajo_ventana_grande = B - K - M, bajo_ventana_pequena = B - K - R);
