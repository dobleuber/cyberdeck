// =====================================================================================================
//  CABEZA «MOCHILA» — 2026-11-23
//  Marco de la pantalla de 5" con la caja de metacrilato de la Orange Pi deslizada en dos raíles a su espalda.
//  La Orange Pi no se desmonta; todos los cables van por fuera.
//  Ejes: x a la derecha (vista de frente), y hacia arriba, z hacia quien mira.
//  Origen: centro de los cuatro agujeros de la pantalla; z = 0 en la cara delantera del cristal.
//
//  Origen de cada dato:  [MEDIDO] calibre del usuario · [NORMA] medida estándar de la pieza
//                        [FOTO] estimado sobre fotos, ±1 o 2 mm · [PENDIENTE] falta confirmarlo
//
//  Piezas:  marco     (se imprime con la cara vista hacia abajo)
//           cuerpo    (se imprime con la espalda sobre la cama)
//           corredera (se imprime DE PIE, apoyada en el extremo del tope: así los raíles salen sin voladizos)
//  Exportar:  openscad -o X.stl --export-format binstl -D 'pieza="X"' mochila.scad
// =====================================================================================================
pieza = "conjunto";        // marco | cuerpo | corredera | probeta | plantilla | conjunto | despiece | nada
$fn = 48;

// ---------- Pantalla ----------
// Remedida el 2026-11-24 con el calibre ya en cero. Las medidas del 23 (111 x 84, 116 x 71, 3,5) estaban desfasadas.
ag_d   = 2.5;                       // [MEDIDO] agujeros de las orejas
ag_dx  = 116 - ag_d;                // [MEDIDO] 116 por fuera -> 113,5 entre centros
ag_dy  = 89 - ag_d;                 // [MEDIDO]  89 por fuera ->  86,5 entre centros
pcb_w  = 120;  pcb_h = 76;  pcb_t = 1.6;   // [MEDIDO] / [NORMA]
or_s   = 9;    or_a  = 8;           // [MEDIDO] oreja: cuánto sobresale del canto largo y su ancho
cr_w   = pcb_w + 0.5; cr_h = pcb_h + 0.5;  // contorno del cristal: lo medido más medio milímetro
pan_T  = 8.0;                       // [MEDIDO] del cristal al dorso del circuito
pan_comp = 2.5;                     // [FOTO]
pan_con  = 14.5 - pan_T;            // [MEDIDO] 14,5 del cristal a la punta del conector más alto
vis_w  = 108;  vis_h = 65;          // [NORMA] imagen de un panel de 5"
ven_m  = 2.5;
con_hdmi = [5, 34];                 // [FOTO] tramo del canto derecho donde está el HDMI (y): lo comprueban los dos pilares de la plantilla
con_resto = [-32, 7];               // [FOTO] tramo con el audio, los dos micro-USB y el interruptor

// ---------- Caja de metacrilato de la Orange Pi ----------
ac_l = 105;  ac_a = 71;  ac_h = 40; // [MEDIDO] largo, ancho y alto hasta la tapa
ac_t = 3;                           // [MEDIDO] espesor de las placas
ac_v = 4;                           // [MEDIDO] lo que sobresalen las placas respecto a las paredes
ac_puertos = [26, 90];              // [FOTO + plano oficial] tramo del lado largo, desde la derecha, con corriente, HDMI y audio

// ---------- Cuerpo ----------
pared = 2.2;  holg = 1.5;  frente = 2.4;
xi  = cr_w/2 + holg;                // interior, medio ancho
yi  = pcb_h/2 + or_s + holg;        // interior, media altura: caben las orejas
z_or  = -(pan_T - pcb_t);           // cara delantera de las orejas
z_pcb = -pan_T;                     // dorso del circuito
zi  = z_pcb - pan_con - 1.2;        // interior, fondo
ze  = zi - pared;                   // espalda
piv_d = 2.1;  piv_h = 1.2;
mt = [[-44.5, 44], [44.5, 44], [-44.5, -44], [44.5, -44]];       // cuatro M3 Allen que cierran el marco
cab_d = 6.2;  cab_h = 3.3;          // [NORMA] alojamiento de la cabeza cilíndrica de un M3 Allen (5,5 x 3)
cz_s = 1.6;                         // suelo de la cazoleta del marco
z_cz = frente - cab_h - cz_s;       // cara de abajo de la cazoleta: hasta ahí llegan los postes del cuerpo
// ---------- Articulación con la espina ----------
r_art = 8; d_eje = 5.3;
nud = [-1, 8];                      // tramo de x que ocupa el nudillo de la espina (espina.scad): 9 mm, para un M5 de 20 mm
or_alma_z = 6.7;                    // hasta dónde sube el alma de las orejas por encima del eje (igual que or_alma en espina.scad)
bis   = [0, -(yi + pared) - 8.8, ze + 7.2];   // eje: lo bastante bajo para que las orejas apoyen planas en la cama
or_h = 0.15;                        // holgura entre cada oreja y el nudillo. El M5 es cónico y de 20 mm [dicho por el usuario]
// Oreja izquierda: 3 mm de pared + 4 mm de tuerca cautiva. Oreja derecha: 3,6 mm con el avellanado del M5. De cabeza a punta: 20 mm.
or_c  = [[nud[0] - or_h - 7.0, nud[0] - or_h], [nud[1] + or_h, nud[1] + or_h + 3.6]];

// ---------- Corredera ----------
co_p = 3;                           // suelo
co_aire = 3.4;                     // hueco bajo el metacrilato: caben las cabezas Allen (3 mm) de los tornillos de la corredera y los tornillos del metacrilato (1 mm)
co_j = 0.6;                         // holgura a cada lado. Con 0,3 la probeta de dos labios entraba demasiado justa [probado 2026-11-24]
co_jz = 0.7;                        // holgura en el grueso de la placa
co_ap = 3.0;                        // ancho de cada apoyo
ac_tor = 11;                        // [FOTO] los cuatro tornillos del metacrilato van a unos 11 mm de cada canto largo: nada que suba puede ir en esas dos franjas
co_r = 3;                           // pared de cada raíl
co_lab = 3.3;  co_lab_t = 2.2;      // labio: cuánto pisa la placa y su grueso
ax0 = -54.5;  ax1 = ax0 + ac_l;     // la placa de abajo del metacrilato, en x
ay0 = -(yi + pared) + co_r + co_j;  ay1 = ay0 + ac_a;            // y en y: enrasada con el canto de abajo del cuerpo
cx0 = ax0 - co_j - co_r;  cx1 = ax1 + co_j + 7;                  // contorno de la corredera
cy0 = ay0 - co_j - co_r;  cy1 = ay1 + co_j + co_r;
h_apoyo = co_p + co_aire;  h_lab = h_apoyo + ac_t + co_jz;  h_top = h_lab + co_lab_t;
tc = [for (y = [ay0 + 22, ay0 + 49], x = [-30, 30]) [x, y]];   // cuatro M3 Allen: corredera -> cuerpo. Van referidos al raíl: la corredera no cambia si cambia la pantalla
cierres = [(ay0 + ay1)/2 - 11.5, (ay0 + ay1)/2 + 11.5];        // los dos tornillos de cierre, fuera de las franjas de los tornillos del metacrilato
function zc(h) = ze - h;            // altura h por detrás de la espalda del cuerpo

module rbox(x0, x1, y0, y1, z0, z1, r = 4) { hull() for (x = [x0 + r, x1 - r], y = [y0 + r, y1 - r]) translate([x, y, z0]) cylinder(r = r, h = z1 - z0); }
module caj(x0, x1, y0, y1, h0, h1) { translate([x0, y0, zc(h1)]) cube([x1 - x0, y1 - y0, h1 - h0]); }   // caja dada por alturas detrás del cuerpo
module orejas_xy() { for (sx = [-1, 1], sy = [-1, 1]) translate([sx*ag_dx/2, sy*ag_dy/2, 0]) children(); }
module pivote(h = piv_h) { cylinder(d = piv_d, h = h - 0.5); translate([0, 0, h - 0.5]) cylinder(d1 = piv_d, d2 = piv_d - 0.7, h = 0.5); }

module cuerpo() {
  difference() {
    intersection() {
      union() {
        difference() {
          rbox(-xi - pared, xi + pared, -yi - pared, yi + pared, ze, 0);
          rbox(-xi, xi, -yi, yi, zi, 1, 2.2);
        }
        orejas_xy() { translate([0, 0, zi - 0.1]) cylinder(d = 7.5, h = z_pcb - zi + 0.1); translate([0, 0, z_pcb]) pivote(); }   // postes de la pantalla
        for (m = mt) { translate([m[0], m[1], zi - 0.1]) cylinder(d = 6.5, h = z_cz - zi);                                       // postes del marco: acaban 0,1 por debajo de la cazoleta
          translate([m[0] - 1.5, min(m[1], sign(m[1])*(yi + 0.1)), zi - 0.1]) cube([3, yi + 0.1 - abs(m[1]), z_cz - zi]); }
        for (t = tc) translate([t[0], t[1], zi - 0.1]) cylinder(d = 7.5, h = 4.5);                                               // refuerzos para los tornillos de la corredera
        for (o = or_c) hull() {                                                                                                // orejas de la articulación
          translate([o[0], bis[1], bis[2]]) rotate([0, 90, 0]) cylinder(r = r_art, h = o[1] - o[0]);
          translate([o[0], -yi - pared - 0.1, ze]) cube([o[1] - o[0], 0.6, bis[2] + or_alma_z - ze]);
        }
      }
      translate([-200, -200, ze]) cube([400, 400, 100]);          // nada por debajo de la cama
    }
    for (m = mt) translate([m[0], m[1], z_cz - 12]) cylinder(d = 2.7, h = 13);                                   // rosca de M3
    for (t = tc) translate([t[0], t[1], ze - 1]) cylinder(d = 2.7, h = pared + 4.5);                             // rosca de M3
    translate([-30, bis[1], bis[2]]) rotate([0, 90, 0]) cylinder(d = d_eje, h = 60);                             // eje M5
    translate([or_c[0][0] - 0.1, bis[1], bis[2]]) rotate([0, 90, 0]) cylinder(d = 9.4, h = 4.1, $fn = 6);         // tuerca M5 cautiva, por fuera de la oreja izquierda
    translate([or_c[1][1] - 2.6, bis[1], bis[2]]) rotate([0, 90, 0]) cylinder(d1 = d_eje, d2 = d_eje + 5.2, h = 2.61);   // avellanado a 90 grados: cabeza cónica del M5 (10 x 2,8)
    // boca del HDMI de la pantalla: el enchufe entero pasa por el costado derecho y por la esquina de la espalda
    translate([pcb_w/2 + 0.5, con_hdmi[0], ze - 1]) cube([xi + pared + 1 - pcb_w/2 - 0.5, con_hdmi[1] - con_hdmi[0], -3 - ze + 1]);
    // boca para el micro-USB, el audio y el interruptor
    translate([xi - 1, con_resto[0], zi]) cube([pared + 2, con_resto[1] - con_resto[0], z_pcb + 1 - zi]);
    // ventilación en el techo
    for (i = [0:8]) translate([-33.5 + i*8, yi - 1, zi + 2.5]) rbox(0, 3, 0, pared + 2, 0, 7, 1.4);
  }
}

module marco() {
  difference() {
    union() {
      rbox(-xi - pared, xi + pared, -yi - pared, yi + pared, 0, frente);
      for (m = mt) translate([m[0], m[1], z_cz]) cylinder(d = cab_d + 2.2, h = -z_cz + 0.1);                       // cazoletas: la cabeza queda enrasada con el frente
      intersection() {                                                                  // separadores: aprietan las orejas contra sus postes
        orejas_xy() translate([0, 0, z_or]) cylinder(d = 7.5, h = -z_or + 0.1);
        for (sy = [-1, 1]) translate([-100, sy > 0 ? cr_h/2 + 0.4 : -cr_h/2 - 0.4 - 20, z_or - 1]) cube([200, 20, -z_or + 2]);
      }
    }
    translate([-vis_w/2 - ven_m, -vis_h/2 - ven_m, -1]) cube([vis_w + 2*ven_m, vis_h + 2*ven_m, frente + 2]);
    for (m = mt) translate([m[0], m[1], 0]) { translate([0, 0, frente - cab_h]) cylinder(d = cab_d, h = cab_h + 1);              // alojamiento de la cabeza
      translate([0, 0, z_cz - 1]) cylinder(d = 3.4, h = cz_s + 1 - 0.2); }                                                     // paso del tornillo; deja una piel de 0,2 que se rompe al atornillar
  }
}

module corredera() {
  difference() {
    union() {
      caj(cx0, cx1, cy0, cy1, 0, co_p);                                                  // suelo
      for (s = [0, 1]) {
        yw0 = s ? ay1 + co_j : cy0;  yin = s ? ay1 + co_j : ay0 - co_j;  d = s ? -1 : 1;  // pared del raíl y su cara interior
        caj(cx0, ax1 + co_j, yw0, yw0 + co_r, 0, h_top);                                  // pared
        caj(cx0, ax1 + co_j, min(yin, yin + d*co_ap), max(yin, yin + d*co_ap), 0, h_apoyo);   // apoyo de la placa
      }
      caj(cx0, ax1 + co_j, ay0 - co_j, ay0 - co_j + co_lab, h_lab, h_top);               // labio de abajo, entero
      // labio de arriba: solo donde no hay enchufes; su arranque lleva un chaflán para imprimirse de pie
      caj(cx0, ax1 - ac_puertos[1], ay1 + co_j - co_lab, ay1 + co_j, h_lab, h_top);
      hull() { caj(ax1 - ac_puertos[0], ax1 + co_j, ay1 + co_j - co_lab, ay1 + co_j, h_lab, h_top);
               caj(ax1 - ac_puertos[0] - co_lab, ax1 - ac_puertos[0], ay1 + co_j - 0.01, ay1 + co_j, h_lab, h_top); }
      caj(cx0, ax0 - co_j, cy0, cy1, 0, h_lab - 0.3);                                     // tope del fondo: no tapa la tarjeta microSD
      for (y = cierres) hull() {                                               // refuerzos de los dos tornillos de cierre
        translate([ax1 + co_j + 1.6, y, zc(h_apoyo)]) cylinder(d = 7, h = h_apoyo);
        translate([ax1 + co_j - 6, y - 0.05, zc(0.1)]) cube([0.1, 0.1, 0.1]);
      }
    }
    for (t = tc) translate([t[0], t[1], zc(co_p) - 0.01]) cylinder(d = 3.4, h = co_p + 1);   // M3 Allen al cuerpo: la cabeza queda en el hueco bajo el metacrilato
    for (y = cierres) translate([ax1 + co_j + 1.6, y, zc(h_apoyo) - 1]) cylinder(d = 2.7, h = h_apoyo + 2);                              // rosca de los cierres
    hull() { caj(ax1 - 5, ax1 - 4.9, ay0 - co_j, ay1 + co_j, h_apoyo, h_lab);                                                           // embocadura: la entrada se abre 0,8 mm
             caj(ax1 + co_j, ax1 + co_j + 0.1, ay0 - co_j - 0.8, ay1 + co_j + 0.8, h_apoyo - 0.8, h_lab + 0.8); }
  }
}

// Tornillos M3 Allen (cabeza 5,5 x 3) en su sitio, solo para comprobar que caben
module tornillos() {
  for (m = mt) translate([m[0], m[1], frente - cab_h]) { cylinder(d = 5.5, h = 3); translate([0, 0, -12]) cylinder(d = 2.6, h = 12); }             // marco: M3x12
  for (t = tc) translate([t[0], t[1], zc(co_p)]) { translate([0, 0, -3]) cylinder(d = 5.5, h = 3); cylinder(d = 2.6, h = 8); }                    // corredera: M3x8
  for (y = cierres) translate([ax1 + co_j + 1.6, y, zc(10)]) { translate([0, 0, -3]) cylinder(d = 5.5, h = 3); cylinder(d = 2.6, h = 10); }        // cierres: M3x10
}

// ---------- Plantilla de prueba: se imprime antes que las piezas grandes ----------
pl_b = 7;  pl_g = 1.6;  pl_p = 10;  esc = [5, 6, 7, 8, 9, 10];
module plantilla() {
  for (sy = [-1, 1]) translate([-ag_dx/2, sy*ag_dy/2 - pl_b/2, 0]) cube([ag_dx, pl_b, pl_g]);
  for (sx = [-1, 1]) translate([sx*ag_dx/2 - pl_b/2, -ag_dy/2, 0]) cube([pl_b, ag_dy, pl_g]);
  orejas_xy() { cylinder(d = 7.5, h = pl_p); translate([0, 0, pl_p]) pivote(3); }
  translate([-xi - 4.5, -15, 0]) cube([xi + 4.5 - ag_dx/2, 30, pl_g]);                               // brazo hasta la escalera
  for (i = [0:len(esc) - 1]) translate([-xi - 4.5, -15 + i*5, 0]) cube([4.5, 5, pl_p + esc[i]]);     // escalera: su cara interior es la pared del cuerpo
  for (y = [con_hdmi[0] - 3, con_hdmi[1]]) {                                                        // dos pilares: entre ellos queda la boca del HDMI
    translate([ag_dx/2, y, 0]) cube([pcb_w/2 + 5 - ag_dx/2, 3, pl_g]);
    translate([pcb_w/2 + 1, y, 0]) cube([4, 3, pl_p + 1.5]);
  }
}

// ---------- Solo para ver el conjunto ----------
module pantalla_ref() {
  color("#0b0c0f") translate([-cr_w/2, -cr_h/2, z_or + 0.6]) cube([cr_w, cr_h, -z_or - 0.6]);
  color("#0b3a3a") translate([-vis_w/2, -vis_h/2, -0.01]) cube([vis_w, vis_h, 0.3]);
  color("#2a55a8") difference() {
    union() { translate([-pcb_w/2, -pcb_h/2, z_pcb]) cube([pcb_w, pcb_h, pcb_t]);
      for (sx = [-1, 1], sy = [-1, 1]) translate([sx*ag_dx/2 - or_a/2, sy > 0 ? pcb_h/2 - 1 : -pcb_h/2 - or_s, z_pcb]) cube([or_a, or_s + 1, pcb_t]); }
    orejas_xy() translate([0, 0, z_pcb - 1]) cylinder(d = ag_d, h = 5);
  }
  color("#c9a23a") translate([pcb_w/2 - 11, 12, z_pcb - pan_con]) cube([12, 15, pan_con]);
  color("#b9bcc2") for (y = [-10, -23]) translate([pcb_w/2 - 5, y, z_pcb - 3]) cube([6, 8, 3]);
  color("#222") translate([pcb_w/2 - 11, 0, z_pcb - 5.5]) cube([12, 6.5, 5.5]);
}
module metacrilato_ref() {
  color("#9fd0f0", 0.45) { caj(ax0, ax1, ay0, ay1, h_apoyo, h_apoyo + ac_t); caj(ax0, ax1, ay0, ay1, h_apoyo + ac_h - ac_t, h_apoyo + ac_h);
    difference() { caj(ax0 + ac_v, ax1 - ac_v, ay0 + ac_v, ay1 - ac_v, h_apoyo + ac_t, h_apoyo + ac_h - ac_t);
                   caj(ax0 + ac_v + ac_t, ax1 - ac_v - ac_t, ay0 + ac_v + ac_t, ay1 - ac_v - ac_t, h_apoyo + ac_t - 1, h_apoyo + ac_h - ac_t + 1); } }
  color("#2a55a8") caj(ax1 - 6.6 - 89.1, ax1 - 6.6, ay1 - 6 - 56, ay1 - 6, h_apoyo + ac_t + 4, h_apoyo + ac_t + 5.6);        // la Orange Pi, posición aproximada
  color("#0e0f12") caj(ax1 - 6.6 - 49.5 - 15, ax1 - 6.6 - 49.5 + 15, ay1 - 6 - 27 - 15, ay1 - 6 - 27 + 15, h_apoyo + ac_h - ac_t - 8, h_apoyo + ac_h - ac_t);   // ventilador, por dentro, bajo la tapa
}

if (pieza == "marco") rotate([180, 0, 0]) translate([0, 0, -frente]) marco();
else if (pieza == "cuerpo") translate([0, 0, -ze]) cuerpo();
else if (pieza == "corredera") rotate([0, -90, 0]) translate([-cx0, 0, -ze]) corredera();     // de pie, sobre el extremo del tope
else if (pieza == "probeta") rotate([0, -90, 0]) translate([-34, 0, -ze]) intersection() { corredera(); translate([34, -100, -200]) cube([12, 200, 400]); }   // rebanada de 14 mm de los raíles, en el tramo de la derecha, que lleva los dos labios
else if (pieza == "plantilla") plantilla();
else if (pieza == "despiece") {
  translate([0, 0, 30]) color("#f0761f") marco();
  translate([0, 0, 15]) pantalla_ref();
  color("#6f7887") cuerpo();
  translate([0, 0, -25]) color("#f0761f") corredera();
  translate([0, 0, -45]) metacrilato_ref();
} else if (pieza != "nada") {
  color("#f0761f") marco(); pantalla_ref(); color("#6f7887") cuerpo(); color("#d9691c") corredera(); metacrilato_ref();
}
echo(ancho = 2*(xi + pared), alto = 2*(yi + pared), cuerpo_fondo = frente - ze, total = frente - ze + h_apoyo + ac_h, corredera = [cx1 - cx0, cy1 - cy0, h_top], eje = bis);
