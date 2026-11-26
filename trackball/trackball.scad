// =====================================================================================================
//  MÓDULO TRACKBALL CENTRAL: bola de 25 mm y sensor PMW3360 en el hueco de las palmas del Master Forge.
//  Dos piezas:
//   - soporte: cuña que se atornilla a las dos roscas M3 de la cara de la garra de la espina (ac_z en espina.scad)
//              y termina en un raíl de cola de milano vertical.
//   - carcasa: aloja la bola (sobre tres bolitas de 5 mm) y la placa del sensor; baja deslizando sobre el raíl.
//   - tapa:    cierra la cámara del sensor por debajo.
//  Ejes y origen iguales que en espina.scad: x a lo ancho, y hacia atrás (0 = borde de las palmas), z hacia arriba
//  (0 = cara de abajo del teclado).
//  Exportar:  openscad -o soporte.stl -D 'pieza="soporte"' trackball.scad   (también carcasa y tapa)
// =====================================================================================================
pieza = "conjunto";      // soporte | carcasa | tapa | conjunto (montado sobre el teclado) | piezas (las tres sueltas)
$fn = 72;

// ---------- Cara de la garra (de espina.scad; no cambiar sin cambiar la espina) ----------
cf_y = 97; c_Lt = 52; c_Lb = 57; c_h1 = 28.5; g_esp = 0.4; ga_t = 5.5;
ac_z = [3.5, 11.5];                                            // roscas M3 del acoplamiento
function yp(z) = cf_y - c_Lb + (c_Lb - c_Lt) * z / c_h1;       // cara de las palmas del centro del teclado
z_g0 = c_h1 + g_esp - 3 - 9;                                   // cara de abajo de la cabeza de la garra (16,9)
y_g0 = yp(z_g0 + 9) - g_esp - 9;                               // cara delantera de la cabeza de la garra
function yga(z) = z <= z_g0 - 4 ? yp(z) - g_esp - ga_t                                       // cara de la garra que mira a las palmas
                : yp(z_g0 - 4) - g_esp - ga_t + (y_g0 - yp(z_g0 - 4) + g_esp + ga_t) * min(1, (z - z_g0 + 4) / 4);

// ---------- Bola y apoyos ----------
bola   = 25;         // bola de trackball de 25 mm
h_bola = 0.75;       // holgura radial de la cavidad
bc     = [0, 13, 27];    // centro de la bola
bol_d  = 5;          // bolitas de apoyo (cerámica Si3N4 o acero), 3 unidades
bol_a  = 50;         // ángulo de los apoyos medido desde la vertical de abajo
bol_az = -90;        // giro del primer apoyo (-90 = hacia delante, los otros dos detrás a los lados)
borde  = 3;          // cuánto sube el borde de la carcasa por encima del centro de la bola

// ---------- Sensor (SUPUESTOS: medir la placa que compres y corregir) ----------
nav_pcb = 7.4;       // SUPUESTO: de la superficie de la bola a la cara de arriba de la placa (lente + 2,4 mm del datasheet)
pcb     = [28, 22, 1.6];   // SUPUESTO: placa del sensor, x por y por grosor
chip_h  = 4;         // SUPUESTO: lo que cuelga el sensor y los pines por debajo de la placa
lente   = [12, 20];  // SUPUESTO: hueco para la lente LM19-LSI, x por y (el largo de la lente va a lo largo de y)

// ---------- Carcasa, soporte y tapa ----------
cas_d  = 40;         // diámetro exterior de la carcasa
cas_z0 = 0.5;        // la carcasa queda 0,5 mm por encima de la cara de abajo del teclado (las patas levantan 1)
tapa_t = 1.6;        // grosor de la tapa

// ---------- Clics ----------
clic   = "mx";       // mx: dos switches MX en la cara delantera | 6x6: dos pulsadores 6x6 en los flancos
// Switches MX (Cherry o compatibles), uno al lado del otro, mirando hacia ti y hacia arriba
mx_c   = [0, -12.5, 13];  // centro de la cara de la placa
mx_t   = 40;         // inclinación de la placa desde la vertical (0 = mira de frente, 90 = mira arriba)
mx_paso = 19.05;     // separación entre los dos switches (la de un teclado)
mx_hue = 14;         // hueco cuadrado del switch (estándar MX)
mx_pl  = 1.5;        // grosor de la placa alrededor del hueco (lo que piden las pestañas del switch)
mx_cue = [15.4, 9];  // hueco de detrás para el cuerpo y las patas: lado y fondo
// Pulsadores 6x6 de 2 patas en los flancos (izquierdo y derecho)
pu_cuerpo = [6.2, 3.6];  // hueco del cuerpo: lado y fondo (el pulsador asoma 1,5-2 mm de la carcasa)
pu_z   = 20;         // altura del centro del pulsador
pu_dy  = -5;         // desplazamiento del pulsador respecto al centro de la bola, a lo largo de y
pu_x0  = 16;         // fondo del hueco (desde el eje de la bola)
can    = [2.2, 3];   // canal de los cables: ancho en x y en y
g      = 0.2;        // holgura entre piezas impresas
g_gar  = 0.2;        // hueco entre el soporte y la garra
asiento = 2.5;       // plástico bajo la cabeza del M3: con M3x8 la punta queda enrasada con la cara de atrás de la garra
cab_d  = 6;          // avellanado para la cabeza Allen M3
y_raiz = 29.1;       // cara delantera del soporte (vertical), donde nace el raíl
cm_p   = 3;          // fondo de la cola de milano
cm_w   = [8, 11];    // ancho de la cola de milano: en la raíz y en la punta
sop_z  = [0.5, 15];  // alto del soporte (por encima de 12,9 sigue la cabeza de la garra)
sop_w  = 16;         // ancho del soporte (el de la espina)
tope   = 1.5;        // techo de la ranura: la carcasa baja por el raíl hasta apoyar en su punta
v_ref  = [40, 0.9];  // borde de abajo de la cara interior de cada mitad: |x| = 40 - 0,9 y (de ref_forge.scad)
v_h    = 1.5;        // la carcasa se queda al menos a esta distancia de ese borde

zb  = bc[2] - bola / 2;                 // punto más bajo de la bola (superficie que lee el sensor)
z_pcb1 = zb - nav_pcb;                  // cara de arriba de la placa
z_pcb0 = z_pcb1 - pcb[2];
z_top  = bc[2] + borde;
chip_v = [12, 16];   // ventana de la tapa bajo el sensor (el chip puede asomar por ella)
assert(z_pcb0 - chip_h > cas_z0 + 0.3, "el sensor asoma por debajo de la carcasa: sube la bola o baja nav_pcb");

module cola2d(c = 0) {                  // perfil (x, y) de la cola de milano, c = holgura
  polygon([[-cm_w[0]/2 - c, y_raiz + 0.01], [cm_w[0]/2 + c, y_raiz + 0.01],
           [cm_w[1]/2 + c, y_raiz - cm_p - c], [-cm_w[1]/2 - c, y_raiz - cm_p - c]]);
}

module soporte() {
  difference() {
    union() {
      // cuña: detrás sigue la cara inclinada de la garra, delante es vertical
      rotate([90, 0, 90]) linear_extrude(sop_w, center = true)
        polygon([[y_raiz, sop_z[0]], [yga(sop_z[0]) - g_gar, sop_z[0]], [yga(z_g0 - 4) - g_gar, z_g0 - 4], [yga(sop_z[1]) - g_gar, sop_z[1]], [y_raiz, sop_z[1]]]);
      translate([0, 0, sop_z[0]]) linear_extrude(sop_z[1] - sop_z[0]) cola2d();
    }
    for (z = ac_z) translate([0, 0, z]) rotate([-90, 0, 0]) {
      translate([0, 0, y_raiz - cm_p - 1]) cylinder(d = 3.4, h = 30);                              // paso del M3
      translate([0, 0, y_raiz - cm_p - 1]) cylinder(d = cab_d, h = yga(z) - g_gar - asiento - (y_raiz - cm_p - 1));   // cabeza
    }
  }
}

module bolitas(c = 0) {                 // centros de los apoyos, a bola/2 + bol_d/2 del centro
  for (i = [0:2]) rotate([0, 0, bol_az + i * 120]) rotate([0, 180 - bol_a, 0])
    children();
}

module en_placa() { translate(mx_c) rotate([-mx_t, 0, 0]) children(); }   // marco de la placa MX: cara en y=0, mira a -y
module frente_mx() {         // bloque que sostiene los dos switches
  hull() {
    en_placa() translate([-mx_paso - 0.5, 0, -mx_paso/2 - 0.5]) cube([2 * mx_paso + 1, mx_pl, mx_paso + 1]);
    translate([-mx_paso - 0.5, bc[1] - 14, cas_z0]) cube([2 * mx_paso + 1, 1, 1]);
    translate([-mx_paso - 0.5, bc[1] - 14, cas_z0]) cube([2 * mx_paso + 1, 1, z_top - 6 - cas_z0]);
  }
}
module huecos_mx() {
  for (s = [-1, 1]) en_placa() translate([s * mx_paso / 2, 0, 0]) {
    translate([-mx_hue/2, -1, -mx_hue/2]) cube([mx_hue, mx_pl + 1.01, mx_hue]);
    translate([-mx_cue[0]/2, mx_pl, -mx_cue[0]/2]) cube([mx_cue[0], mx_cue[1], mx_cue[0]]);
  }
  // canal de los cables: de los huecos de los switches a la salida del cable, por debajo
  hull() for (s = [-1, 1]) en_placa() translate([s * mx_paso / 2 - 2, mx_pl + mx_cue[1] - 3, -mx_cue[0]/2]) cube([4, 3, 4]);
  hull() { en_placa() translate([-2, mx_pl + mx_cue[1] - 3, -mx_cue[0]/2]) cube([4, 3, 4]);
           translate([bc[0] - 4, bc[1] - cas_d/2, cas_z0 - 0.01]) cube([8, 4, 3.5]); }
}

module carcasa() {
  difference() {
    union() {
    if (clic == "mx") frente_mx();
    intersection() {
      hull() {
        translate([bc[0], bc[1], cas_z0]) cylinder(d = cas_d, h = z_top - cas_z0);
        translate([-sop_w/2, y_raiz - 6, cas_z0]) cube([sop_w, 6 - g, sop_z[1] + 6 - cas_z0]);
      }
      translate([-50, -50, 0]) cube([100, y_raiz - g + 50, 100]);                                 // plano trasero, pegado al soporte
      linear_extrude(100) polygon([[0, (v_ref[0] - v_h) / v_ref[1]], [60, (v_ref[0] - v_h - 60) / v_ref[1]],
                                   [60, -60], [-60, -60], [-60, (v_ref[0] - v_h - 60) / v_ref[1]]]);   // recorte en V
    }
    }
    // cavidad de la bola y boca para sacarla
    translate(bc) sphere(d = bola + 2 * h_bola);
    translate(bc) cylinder(d = bola + 2 * h_bola, h = 20);
    translate([bc[0], bc[1], z_top - 1]) cylinder(d1 = bola + 2 * h_bola, d2 = bola + 2 * h_bola + 3, h = 1.01);   // chaflán
    // alojamientos de las bolitas: entran desde la cavidad
    translate(bc) bolitas() translate([0, 0, bola/2 + bol_d/2 - 0.1]) {
      cylinder(d = bol_d + 0.15, h = bol_d / 2 + 0.4);   // fondo del alojamiento
      translate([0, 0, -bol_d]) cylinder(d = bol_d + 0.15, h = bol_d);
    }
    // ventana de la lente y cámara del sensor (abierta por abajo)
    translate([bc[0] - lente[0]/2, bc[1] - lente[1]/2, z_pcb1 - 0.01]) cube([lente[0], lente[1], zb - z_pcb1 + 2]);
    translate([bc[0] - pcb[0]/2 - g, bc[1] - pcb[1]/2 - g, z_pcb0]) cube([pcb[0] + 2*g, pcb[1] + 2*g, pcb[2] + 0.01]);
    translate([bc[0] - pcb[0]/2 + 1.5, bc[1] - pcb[1]/2 + 1.5, cas_z0 - 0.01]) cube([pcb[0] - 3, pcb[1] - 3, z_pcb0 - cas_z0 + 0.02]);
    translate([0, 0, cas_z0 - 0.01]) linear_extrude(tapa_t + 0.01) tapa2d(g);                     // asiento de la tapa
    // salida del cable, por delante y por abajo (con los MX sale por debajo del frente)
    translate([bc[0] - 4, bc[1] - cas_d/2 - (clic == "mx" ? 15 : 1), cas_z0 - 0.01]) cube([8, cas_d/2 + (clic == "mx" ? 14 : 0), 3.5]);
    // ranura de la cola de milano: abierta abajo, cerrada arriba; la carcasa baja desde arriba y apoya en el raíl
    translate([0, 0, cas_z0 - 1]) linear_extrude(sop_z[1] + g - cas_z0 + 1) cola2d(g);
    if (clic == "mx") huecos_mx();
    // pulsadores de los clics: hueco del cuerpo, paso de las patas y canal hasta la cámara del sensor
    if (clic == "6x6") for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) translate([bc[0], bc[1] + pu_dy, 0]) {
      translate([pu_x0, -pu_cuerpo[0]/2, pu_z - pu_cuerpo[0]/2]) cube([20, pu_cuerpo[0], pu_cuerpo[0]]);
      translate([pcb[0]/2 + g + 0.2, -pu_cuerpo[0]/2 + 0.6, pu_z - 1]) cube([pu_x0 - pcb[0]/2 - g - 0.1, pu_cuerpo[0] - 1.2, 2]);
      translate([pcb[0]/2 + g + 0.2, -can[1]/2, cas_z0 + tapa_t]) cube([can[0], can[1], pu_z - cas_z0 - tapa_t + 1]);
      translate([pcb[0]/2 - 3, -can[1]/2, cas_z0 + tapa_t]) cube([can[0] + 3.4, can[1], z_pcb0 - cas_z0 - tapa_t - 0.3]);
    }
    // tornillo de la tapa (M2 rosca en plástico), dos a los lados
    for (s = [-1, 1]) translate([bc[0] + s * tor_x, bc[1], cas_z0 - 0.01]) cylinder(d = 1.7, h = 8);
  }
}

tor_x = pcb[0]/2 + 2.6;               // tornillos M2 de la tapa
module tapa2d(c = 0) {
  offset(delta = c) union() {
    translate([bc[0] - pcb[0]/2, bc[1] - pcb[1]/2]) square([pcb[0], pcb[1]]);
    for (s = [-1, 1]) hull() { translate([bc[0] + s * tor_x, bc[1]]) circle(d = 5); translate([bc[0] + s * pcb[0]/2 - 0.5, bc[1] - 2.5]) square([1, 5]); }
  }
}
module tapa() {
  difference() {
    translate([0, 0, cas_z0]) linear_extrude(tapa_t) tapa2d();
    for (s = [-1, 1]) translate([bc[0] + s * tor_x, bc[1], cas_z0 - 1]) cylinder(d = 2.3, h = 5);
    translate([bc[0] - 4, bc[1] - pcb[1]/2 - 1, cas_z0 - 1]) cube([8, 4, 5]);                    // paso del cable
    translate([bc[0] - chip_v[0]/2, bc[1] - chip_v[1]/2, cas_z0 - 1]) cube([chip_v[0], chip_v[1], 5]);   // ventana del chip
  }
}

module mx_ref() { for (s = [-1, 1]) en_placa() translate([s * mx_paso / 2, 0, 0]) {
                    color("#e8e2d0") translate([-7, 0, -7]) cube([14, 5, 14]);                       // cuerpo, por detrás de la placa
                    color("#e8e2d0") translate([-7.8, -6.6, -7.8]) cube([15.6, 6.6, 15.6]);          // tapa del switch
                    color("#3a2a20") translate([-9, -6.6 - 3.6 - 7.5, -9]) cube([18, 7.5, 18]); } }   // keycap (de referencia)
module pulsadores_ref() { for (s = [-1, 1]) mirror([s < 0 ? 1 : 0, 0, 0]) translate([bc[0] + pu_x0, bc[1] + pu_dy, pu_z]) {
                    color("#222") translate([0, -3, -3]) cube([3.5, 6, 6]); color("#111") translate([3.5, 0, 0]) rotate([0, 90, 0]) cylinder(d = 3.5, h = 2.5); } }
module bola_ref() { color("#35e0d0") translate(bc) sphere(d = bola); color("#e6e6e6") translate(bc) bolitas() translate([0, 0, bola/2 + bol_d/2]) sphere(d = bol_d); }
module pcb_ref()  { color("#1f7a55") translate([bc[0] - pcb[0]/2, bc[1] - pcb[1]/2, z_pcb0]) cube(pcb);
                    color("#111") translate([bc[0] - 5, bc[1] - 7, z_pcb0 - chip_h]) cube([10, 14, chip_h]);
                    color("#444") translate([bc[0] - lente[0]/2 + 1, bc[1] - lente[1]/2 + 1, z_pcb1]) cube([lente[0] - 2, lente[1] - 2, nav_pcb - 2.4]); }

if (pieza == "soporte") translate([0, 0, -sop_z[0]]) soporte();                                     // de pie sobre su base
else if (pieza == "carcasa") carcasa();                                                            // tal cual, sobre su base
else if (pieza == "tapa") translate([0, 0, -cas_z0]) tapa();
else if (pieza == "piezas") { carcasa(); translate([45, 0, 0]) tapa(); translate([-40, 0, -sop_z[0]]) soporte(); }
else { color("#f0761f") soporte(); color("#3a404b") carcasa(); color("#262a31") tapa(); bola_ref(); pcb_ref(); if (clic == "mx") mx_ref(); else pulsadores_ref(); }
