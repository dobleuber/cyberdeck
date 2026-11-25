// =====================================================================================================
//  ESPINA (v4, una sola pieza): sujeta la cabeza al Master Forge abrazando su centro con un lomo por arriba,
//  un cuello por detrás, una banda de 0,8 mm por debajo y una garra que sube por el hueco de las palmas.
//  Un tornillo M3 tira de la garra hacia la punta y tensa la banda.
//  Ejes: x a lo ancho, y hacia atrás (0 = borde de las palmas), z hacia arriba (0 = cara de abajo del teclado).
//  Exportar:  openscad -o espina.stl -D 'pieza="espina"' espina.scad
// =====================================================================================================
pieza = "conjunto";      // espina (para imprimir) | conjunto (montada) | suelta | espina_fea (solo lomo y cuello, para la prueba)
$fn = 64;

// ---------- Centro del Master Forge. A, B, C y D medidos con calibre; el resto, sobre fotos con cuadrícula ----------
cf_y   = 97;     // cara lejana del teclado, en el centro
c_h0   = 11.5;   // A: grosor del teclado en el borde lejano (calibre)
c_h1   = 28.5;   // B: grosor en el extremo del centro que da a las palmas (calibre)
c_Lt   = 52;     // largo del centro por arriba (fotos): la ranura del tornillo admite +-2,5 mm
c_Lb   = 57;     // largo del centro por abajo (fotos)
pu_sal = 6;      // C: cuánto sobresale la barra del puente de la cara lejana (calibre)
pu_sob = 1.2;    // lo que podría sobresalir la barra por encima del borde lejano: se le deja ese hueco
pie_h  = 1;      // D: lo que levantan las patas de goma (calibre)
// ---------- Espina ----------
an     = 16;     // ancho de toda la pieza (cabe entre las dos ventanas de la cara de las palmas)
g      = 0.4;    // holgura con el teclado (sitio para un fieltro o goma fina)
t_del  = 6;      // grosor en la punta
apoyo  = 10;     // largo de cada apoyo sobre el teclado
cue_t  = 6.5;    // grosor del cuello, por detrás del puente
cue_h  = 0.8;    // hueco entre el cuello y la barra del puente (sitio para un fieltro)
bisel  = 2.5;
eje    = [0, 118, 23];   // eje de la articulación (a lo largo de x)
r_art  = 8;  d_eje = 5.3;
// Nudillo estrecho (v5, 2026-11-24): el tornillo de la articulación es un M5 de 20 mm, así que la espina solo conserva
// 9 mm de ancho alrededor del eje. Queda enrasado con la cara que va sobre la cama al imprimir; al otro lado se vacía
// lo que barre la oreja de la cabeza que lleva la tuerca.
nud    = [-1, 8];              // tramo de x que conserva el nudillo
or_alma = [-6.7, 7.2, 8.7, 9.3];   // alma de las orejas de la cabeza respecto al eje, con la cabeza vertical: y0, y1, z0, z1 (igual que mochila.scad)
inc_r  = [-8, 110];            // inclinaciones de la cabeza para las que se deja paso, en grados hacia atrás
// ---------- Banda y garra ----------
ba_t   = 0.8;    // grosor de la banda: menos que las patas, para que el teclado asiente en la mesa
ba_g   = 0.1;    // hueco entre banda y teclado
ba_R   = 150;    // la banda se imprime curvada con este radio, para que la garra salga abierta
ga_t   = 5.5;    // grosor de la garra
ga_hue = 3;      // hueco que queda entre la garra y la punta al apretar
ga_cab = 9;      // cabeza de la garra: fondo y alto
ran    = 2.5;    // la ranura del tornillo admite este error (a cada lado) en el largo del teclado
ac_z   = [3.5, 11.5];    // acoplamiento para un futuro trackball: dos roscas M3 en la cara de la garra

yA = cf_y - c_Lt;                 // extremo del centro, por arriba
z_b1 = -ba_g;  z_b0 = -ba_g - ba_t;   // caras de la banda
z_g1 = c_h1 + g - ga_hue;         // cara de arriba de la garra
z_g0 = z_g1 - ga_cab;
function zu(y) = c_h0 + g + (cf_y - y) * (c_h1 - c_h0) / c_Lt;            // cara de abajo del lomo
function yp(z) = cf_y - c_Lb + (c_Lb - c_Lt) * z / c_h1;                  // cara de las palmas del centro
y_g0 = yp(z_g1) - g - ga_cab;     // cara delantera de la cabeza de la garra
ys = y_g0 + 4.4;                  // tornillo M3
yn = ys - ran - 1.7 - 2.6;        // punta de la espina
yr = cf_y + pu_sal + cue_h;       // cara interior del cuello
y_f = yp(z_b1) - g;               // donde la banda se une a la garra
function zt(y) = zu(yA) + t_del + (y - yn) * (eje[2] + r_art - zu(yA) - t_del) / (yr + cue_t - yn);   // lomo

module en_x(w) { rotate([90, 0, 90]) linear_extrude(w, center = true, convexity = 10) children(); }   // perfil (y, z) -> pieza

module lomo2d() {            // lomo + cuello + articulación
  polygon([[yn, zu(yA) + 1.5], [yn + 1.5, zu(yA)], [yA, zu(yA)], [yA + apoyo, zu(yA + apoyo)], [yA + apoyo + 1, zu(yA + apoyo + 1) + 1],
           [cf_y - apoyo - 1, zu(cf_y - apoyo - 1) + 1], [cf_y - apoyo, zu(cf_y - apoyo)], [cf_y, c_h0 + g], [cf_y + 0.6, c_h0 + g + pu_sob],
           [yr, c_h0 + g + pu_sob], [yr, z_b0], [yr + cue_t - 1.5, z_b0], [yr + cue_t, z_b0 + 1.5],
           [yr + cue_t, zt(yr + cue_t)], [yn + 2, zt(yn + 2)], [yn, zt(yn) - 2]]);
  hull() {
    translate([eje[1], eje[2]]) circle(r = r_art);
    polygon([[yr, c_h0 + g + pu_sob], [yr + cue_t, 5], [yr + cue_t, zt(yr + cue_t)], [yr, zt(yr)]]);
  }
}
module garra2d() {           // en su sitio, montada
  polygon([[y_f, z_b1], [yp(z_g1) - g, z_g1], [y_g0 + 1.2, z_g1], [y_g0, z_g1 - 1.2], [y_g0, z_g0],
           [yp(z_g0 - 4) - g - ga_t, z_g0 - 4], [yp(z_b0) - g - ga_t, z_b0], [y_f, z_b0]]);
}
function arco(s) = [yr - ba_R * sin(s / ba_R * 180 / PI), (z_b0 + z_b1) / 2 - ba_R * (1 - cos(s / ba_R * 180 / PI))];
function normal(s) = [-sin(s / ba_R * 180 / PI), cos(s / ba_R * 180 / PI)];
module banda_garra2d(montada) {
  L = yr - y_f;
  if (montada) { translate([y_f - 0.2, z_b0]) square([L + 0.4, ba_t]); garra2d(); }
  else {
    n = 40;
    polygon(concat([[yr + 0.3, z_b1]], [for (i = [0:n]) arco(i * L / n) + ba_t / 2 * normal(i * L / n)],
                   [for (i = [n:-1:0]) arco(i * L / n) - ba_t / 2 * normal(i * L / n)], [[yr + 0.3, z_b0]]));
    translate(arco(L)) rotate(L / ba_R * 180 / PI) translate(-[y_f, (z_b0 + z_b1) / 2]) { garra2d(); translate([y_f - 0.01, z_b0]) square([0.3, ba_t]); }
  }
}
module barrido2d() {         // lo que barre una oreja de la cabeza al inclinarla, con 0,5 mm de holgura
  translate([eje[1], eje[2]]) for (i = [inc_r[0]:3:inc_r[1]]) rotate(-i) offset(r = 0.5) hull() {
    circle(r = r_art);
    translate([or_alma[0], or_alma[2]]) square([or_alma[1] - or_alma[0], or_alma[3] - or_alma[2]]);
  }
}
module ventanas2d() {        // aligeran y dejan ver el teclado a través
  offset(r = 1.2) offset(delta = -1.2) polygon([[yA + 21, zu(yA + 21) + 4.2], [cf_y - 16.5, zu(cf_y - 16.5) + 4.2], [cf_y - 16.5, zt(cf_y) - 3.4], [yA + 21, zt(yA + 21) - 3.4]]);
  offset(r = 1.2) offset(delta = -1.2) polygon([[cf_y - 12.5, zu(cf_y - 12.5) + 5.5], [yr + 1.5, c_h0 + g + 6.2], [yr + 1.5, zt(yr) - 3.4], [cf_y - 12.5, zt(cf_y) - 3.4]]);
}
module taladros_lomo() {
  for (s = [-1, 1]) hull() for (y = [yn - 1, yr - 1]) translate([0, y, zt(y)]) {            // biseles del lomo
    translate([s * an/2, 0, 0.05]) cube(0.1, center = true);
    translate([s * (an/2 - bisel), 0, 0.05]) cube(0.1, center = true);
    translate([s * an/2, 0, -bisel]) cube(0.1, center = true);
  }
  hull() for (d = [-ran, ran]) translate([0, ys + d, zu(yA) - 1]) cylinder(d = 3.4, h = 20);   // ranura del tornillo M3 (cabeza + arandela por arriba)
}
module taladros_garra() {    // en su sitio, montada
  translate([0, ys, z_g0 - 6]) cylinder(d = 3.4, h = 40);                                    // paso del tornillo
  translate([-2.9, y_g0 - 1, z_g0 + 3]) cube([5.8, ys - y_g0 + 1 + 3.3, 2.7]);               // ranura de la tuerca M3
  for (z = ac_z) translate([0, yp(z) - g - ga_t - 2, z]) rotate([-90, 0, 0]) {               // acoplamiento del trackball
    cylinder(d = 3.3, h = 12);
    translate([0, 0, 2 + ga_t - 2.5]) cylinder(d = 6.5, h = 6, $fn = 6);                     // tuerca, por la cara que mira al teclado
  }
}
module espina(montada = true, solo_lomo = false) {
  L = yr - y_f;  a = L / ba_R * 180 / PI;  p = arco(L);
  difference() {
    en_x(an) difference() {
      offset(r = -0.5) offset(delta = 0.5) union() { lomo2d(); if (!solo_lomo) banda_garra2d(montada); }   // redondea las esquinas interiores
      translate([eje[1], eje[2]]) circle(d = d_eje);
      ventanas2d();
    }
    taladros_lomo();
    translate([nud[0] - 5, 0, 0]) en_x(10) barrido2d();                                       // paso de la oreja de la tuerca
    if (!solo_lomo) {
      if (montada) taladros_garra();
      else translate([0, p[0], p[1]]) rotate([a, 0, 0]) translate([0, -y_f, -(z_b0 + z_b1) / 2]) taladros_garra();
    }
  }
}
module garra() { }           // (ya no es una pieza aparte)

if (pieza == "espina") translate([0, 0, an/2]) rotate([0, 90, 0]) espina(montada = false);     // de lado: sin soportes
else if (pieza == "espina_fea") espina(solo_lomo = true);
else if (pieza == "suelta") color("#f0761f") espina(montada = false);
else color("#f0761f") espina();
