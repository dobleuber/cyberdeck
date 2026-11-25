// Maquetas de concepto: solo volúmenes para juzgar la forma. No es un diseño imprimible.
$fn = 28;
C_ALU = "#c4c8cf"; C_ALU2 = "#8f949d"; C_CAP = "#1b1c20"; C_BODY = "#262a31"; C_BODY2 = "#3a404b";
C_ACC = "#f0761f"; C_GLOW = "#35e0d0"; C_SCR = "#0b3a3a"; C_TXT = "#46f0b4"; C_BEZ = "#0b0c0f";
C_PCB = "#1f7a55"; C_BAT = "#4a5a6e"; C_GOLD = "#c9a23a"; C_TUBE = "#9aa0aa";

// ---- Master Forge (medido: 222 x 115, cuña 41 -> 14; centro 52-57 de largo, 11,5 -> 28,5 de grueso con calibre). Origen: centro, borde de palmas en y=0 ----
module pt(p) { translate(p) sphere(r = 0.6, $fn = 6); }
module forge_half() {
  color(C_ALU) hull() {
    for (p = [[-4,97],[-86,115],[-112,77],[-89,19],[-53,0],[-40,0],[-4,40]]) pt([p[0], p[1], 0]);
    for (p = [[-82,24],[-50,8],[-30,48],[-80,60]]) pt([p[0], p[1], 41]);        // placa de palma
    pt([-4,97,11.5]); pt([-84,111,15]);                          // borde lejano
    pt([-108,78,26]); pt([-4,45,28.5]);
  }
  // palancas de dedos sobre la rampa
  for (p = [[-78,86],[-66,71],[-84,64],[-58,52],[-72,43],[-50,33]]) {
    z = 41 - max(0, p[1] - 58) * 0.47;
    color(C_CAP) translate([p[0], p[1], z - 1]) rotate([-24, 0, 0]) { cylinder(d = 5, h = 6); translate([0,0,5]) cylinder(d1 = 13, d2 = 12, h = 4); }
  }
  // palancas de pulgar, en la cara interior
  for (p = [[-47,10],[-33,19]]) color(C_CAP) translate([p[0], p[1], 27]) rotate([0, 28, 0]) { cylinder(d = 5, h = 6); translate([0,0,5]) cylinder(d1 = 13, d2 = 12, h = 4); }
  // resplandor de los LED en la base
  color(C_GLOW) translate([-98, 30, 0]) cube([60, 60, 0.6]);
}
module forge() {
  forge_half(); mirror([1,0,0]) forge_half();
  color(C_ALU2) translate([-36.5, 97, 0.7]) cube([73, 6, 10.3]);     // puente
  color(C_CAP) for (s = [-1, 1]) translate([s*28, 103, 5.8]) rotate([-90, 0, 0]) cylinder(d = 5.5, h = 2.2);
  color(C_CAP) hull() { translate([-4.4, 40, 0]) cube([8.8, 57, 0.1]); translate([-4.4, 45, 28.3]) cube([8.8, 0.1, 0.1]); translate([-4.4, 96.9, 11.3]) cube([8.8, 0.1, 0.1]); }   // unión central
}
module pantalla(marco = 3) {          // 5": marco y zona encendida; centrada, cara hacia +z
  color(C_BEZ) translate([-63.5, -42, 0]) cube([127, 84, 1]);
  color(C_SCR) translate([-54.5, -33, 1]) cube([109, 66, 0.5]);
  color(C_TXT) for (i = [0:6]) translate([-50, 25 - i*8, 1.5]) cube([[70,46,88,30,62,52,18][i], 2.2, 0.3]);
}
module placa(fan = true) {            // Orange Pi 5 Pro 89 x 56 con disipador y ventilador
  color(C_PCB) cube([89, 56, 1.6]);
  color("#777c85") translate([24, 8, 1.6]) cube([40, 40, 12]);
  if (fan) { color("#0e0f12") translate([44, 28, 13.6]) cylinder(d = 40, h = 10); color(C_ACC) translate([44, 28, 23.6]) cylinder(d = 12, h = 0.8); }
  color("#b9bcc2") { translate([2, 4, 1.6]) cube([14, 13, 13]); translate([2, 22, 1.6]) cube([17, 14, 13]); }
}
module bateria() { color(C_BAT) hull() for (x = [4, 136], y = [4, 66]) translate([x, y, 0]) cylinder(r = 4, h = 17); }
module antena(l = 105) { color(C_GOLD) cylinder(d = 8, h = 8); color("#0d0e11") translate([0,0,8]) cylinder(d = 9, h = l); }
module trackball() { color("#0d0e11") cylinder(d1 = 40, d2 = 34, h = 10); color(C_ACC) translate([0,0,11]) sphere(d = 27, $fn = 40); }
module palanquita() { color("#b9bcc2") cylinder(d = 6, h = 3); color("#d9dce2") translate([0,0,3]) rotate([18,0,0]) cylinder(d1 = 3, d2 = 4, h = 11); }
module tubo(a, b, d = 8) { hull() { translate(a) sphere(d = d); translate(b) sphere(d = d); } }

module tira(a, b, w = 1.8) { color(C_ACC) hull() { translate(a) cube(w, center = true); translate(b) cube(w, center = true); } }
module eje(p, l = 28, d = 12) { color(C_ACC) translate(p) rotate([0, 90, 0]) cylinder(d = d, h = l, center = true); }
module eslabon(p, q, sep = 11) { color(C_ALU) for (x = [-sep, sep]) hull() { translate([x, p[1], p[2]]) rotate([0,90,0]) cylinder(d = 10, h = 3, center = true); translate([x, q[1], q[2]]) rotate([0,90,0]) cylinder(d = 10, h = 3, center = true); } }
module capsula() {                 // pantalla en carcasa con visera; cara hacia +z, "arriba" hacia +y
  color(C_BODY2) hull() { for (x = [-70, 70], y = [-48, 48]) pt([x, y, 0]); for (x = [-62, 62], y = [-42, 42]) pt([x, y, -14]); }
  translate([0, 0, 0]) pantalla();
  color(C_BODY) { translate([-70, 46, 0]) cube([140, 4, 11]); for (x = [-70, 67]) hull() { translate([x, 46, 0]) cube([3, 4, 11]); translate([x, -30, 0]) cube([3, 4, 1.5]); } }
  color(C_ACC) translate([-70, 48.6, 9.4]) cube([140, 1.6, 1.8]);
}
module espiral(a, b, r = 5, vueltas = 9, d = 2.6) {   // cable en espiral entre a y b
  n = vueltas * 10; v = b - a; L = norm(v); u = v / L;
  w0 = cross(u, [1, 0.3, 0.2]); w = w0 / norm(w0); k = cross(u, w);
  color("#111316") for (i = [0:n-1]) hull() {
    translate(a + u * (L * i / n) + r * (cos(360 * vueltas * i / n) * w + sin(360 * vueltas * i / n) * k)) sphere(d = d, $fn = 8);
    translate(a + u * (L * (i+1) / n) + r * (cos(360 * vueltas * (i+1) / n) * w + sin(360 * vueltas * (i+1) / n) * k)) sphere(d = d, $fn = 8);
  }
}
