"""Hoja de medidas de la pared rota de la caja de metacrilato (lado de USB y red). Esquema sacado de la foto del
usuario: sirve para saber qué medir, no para sacar medidas."""
import math, os
from PIL import Image, ImageDraw, ImageFont
F = "/usr/share/fonts/truetype/dejavu/"
f = lambda n, s: ImageFont.truetype(F + n, s)
MONO, SANS, BOLD = "DejaVuSansMono-Bold.ttf", "DejaVuSans.ttf", "DejaVuSans-Bold.ttf"
BG, TXT, GRIS, ACC = (28, 29, 31), (230, 232, 236), (150, 154, 162), (240, 118, 31)
PIEZA, BORDE = (58, 70, 82), (140, 150, 165)
W, H = 1800, 1530
im = Image.new("RGB", (W, H), BG); d = ImageDraw.Draw(im)
d.text((48, 34), "CAJA DE METACRILATO · PARED DE USB Y RED", font=f(MONO, 26), fill=GRIS)
d.text((46, 66), "MEDIDAS DE LA PARED", font=f(BOLD, 78), fill=ACC)
d.text((48, 160), "Con el calibre en cero. Pásame los números tal como salgan, letra por letra.", font=f(SANS, 26), fill=TXT)
d.line((48, 204, W - 48, 204), fill=(70, 72, 78), width=2)

def flecha(p, q, w=4, a=12):
    d.line((*p, *q), fill=ACC, width=w)
    for s, e in ((p, q), (q, p)):
        t = math.atan2(e[1] - s[1], e[0] - s[0])
        d.polygon([s, (s[0] + a*math.cos(t + .45), s[1] + a*math.sin(t + .45)), (s[0] + a*math.cos(t - .45), s[1] + a*math.sin(t - .45))], fill=ACC)
def letra(c, x, y, r=18):
    d.ellipse((x - r, y - r, x + r, y + r), fill=ACC)
    d.text((x, y), c, font=f(BOLD, 23), fill=BG, anchor="mm")
def guia(p, q): d.line((*p, *q), fill=(110, 80, 50), width=2)

d.text((48, 232), "VISTA DE FRENTE · como en tu foto: pestaña rota arriba, ventana grande a la izquierda", font=f(MONO, 21), fill=GRIS)
x0, y0, w, h = 300, 440, 880, 470; x1, y1 = x0 + w, y0 + h
tx0, tx1, th = x0 + 352, x0 + 500, 46
wx0, wx1, wy0, wy1 = x0 + 53, x0 + 528, y0 + 108, y0 + 348        # ventana grande
vx0, vx1, vy0, vy1 = x0 + 554, x0 + 783, y0 + 113, y0 + 320       # ventana pequeña
d.rectangle((tx0, y0 - th, tx1, y0 + 4), fill=PIEZA, outline=BORDE, width=2)
d.rectangle((tx0, y1 - 4, tx1, y1 + th), fill=PIEZA, outline=BORDE, width=2)
d.rectangle((x0, y0, x1, y1), fill=PIEZA, outline=BORDE, width=2)
d.rectangle((tx0 + 2, y0 - 2, tx1 - 2, y0 + 4), fill=PIEZA); d.rectangle((tx0 + 2, y1 - 4, tx1 - 2, y1 + 2), fill=PIEZA)
d.rectangle((wx0, wy0, wx1, wy1), fill=BG, outline=BORDE, width=2)
d.rectangle((vx0, vy0, vx1, vy1), fill=BG, outline=BORDE, width=2)

# A, B: contorno
ya = y1 + th + 112
guia((x0, y1 + 4), (x0, ya + 10)); guia((x1, y1 + 4), (x1, ya + 10))
flecha((x0, ya), (x1, ya)); letra("A", (x0 + x1)/2, ya + 30)
xb = x1 + 150
guia((x1 + 4, y0), (xb + 10, y0)); guia((x1 + 4, y1), (xb + 10, y1))
flecha((xb, y0), (xb, y1)); letra("B", xb + 32, (y0 + y1)/2)
# C, D, E: pestaña de arriba
yc = y0 - 24
guia((x0, y0 - 4), (x0, yc - 10))
flecha((x0, yc), (tx0, yc)); letra("C", (x0 + tx0)/2, yc - 28)
yd = y0 - th - 40
guia((tx0, y0 - th - 4), (tx0, yd - 10)); guia((tx1, y0 - th - 4), (tx1, yd - 10))
flecha((tx0, yd), (tx1, yd)); letra("D", (tx0 + tx1)/2, yd - 28)
xe = tx1 + 44
guia((tx1 + 4, y0 - th), (xe + 10, y0 - th))
flecha((xe, y0 - th), (xe, y0), a=9); letra("E", xe + 30, y0 - th/2 - 4)
# F, G, H: pestaña de abajo
yf = y1 + 24
guia((x0, y1 + 4), (x0, yf + 10))
flecha((x0, yf), (tx0, yf)); letra("F", (x0 + tx0)/2, yf + 28)
yg = y1 + th + 40
guia((tx0, y1 + th + 4), (tx0, yg + 10)); guia((tx1, y1 + th + 4), (tx1, yg + 10))
flecha((tx0, yg), (tx1, yg)); letra("G", (tx0 + tx1)/2, yg + 28)
xh = tx1 + 44
guia((tx1 + 4, y1 + th), (xh + 10, y1 + th))
flecha((xh, y1), (xh, y1 + th), a=9); letra("H", xh + 30, y1 + th/2 + 4)
# J, K, L, M: ventana grande
yj = wy1 + 60
flecha((x0, yj), (wx0, yj), a=9); guia((wx0, wy1 + 4), (wx0, yj + 10)); letra("J", x0 + 27, yj + 30)
xk = wx0 + 110
flecha((xk, y0), (xk, wy0), a=10); letra("K", xk + 30, (y0 + wy0)/2)
yl = wy1 - 52
flecha((wx0, yl), (wx1, yl)); letra("L", (wx0 + wx1)/2 + 60, yl - 28)
xm = wx0 + 70
flecha((xm, wy0), (xm, wy1)); letra("M", xm + 30, wy0 + 60)
# N, P, Q, R: ventana pequeña
yn = vy1 + 60
flecha((vx1, yn), (x1, yn), a=10); guia((vx1, vy1 + 4), (vx1, yn + 10)); letra("N", (vx1 + x1)/2, yn + 30)
xp = vx0 + 70
flecha((xp, y0), (xp, vy0), a=10); letra("P", xp + 30, (y0 + vy0)/2)
yq = vy1 - 45
flecha((vx0, yq), (vx1, yq)); letra("Q", vx0 + 80, yq - 28)
xr = vx1 - 48
flecha((xr, vy0), (xr, vy1)); letra("R", xr - 30, vy0 + 50)

# cómo medir
bx, by = 1420, 440
d.rounded_rectangle((bx, by, W - 48, by + 470), radius=10, outline=(110, 80, 50), width=2)
d.text((bx + 20, by + 16), "Cómo medir", font=f(BOLD, 23), fill=ACC)
lineas = [("Ventanas  L  M  Q  R", TXT), ("Por dentro, con las puntas", GRIS), ("pequeñas del calibre.", GRIS), ("", GRIS),
          ("Márgenes  C  F  J  K  N  P", TXT), ("Del canto de la pieza al", GRIS), ("borde del hueco o de la", GRIS), ("pestaña.", GRIS), ("", GRIS),
          ("Pestañas  E  H", TXT), ("Lo que sobresalen del canto.", GRIS), ("", GRIS),
          ("Si la pieza está partida,", TXT), ("junta los trozos sobre la", TXT), ("mesa antes de medir.", TXT)]
for k, (tx, col) in enumerate(lineas): d.text((bx + 20, by + 62 + 26*k), tx, font=f(SANS, 19), fill=col)

# leyenda
d.line((48, 1150, W - 48, 1150), fill=(70, 72, 78), width=2)
def lista(x, y, filas):
    for c, que in filas:
        letra(c, x + 18, y + 14, r=17)
        d.text((x + 50, y), que, font=f(SANS, 22), fill=TXT)
        y += 54
lista(48, 1180, [("A", "Ancho total, sin pestañas"), ("B", "Alto total, sin pestañas"), ("C", "Del canto izquierdo a la pestaña de arriba"),
                 ("D", "Ancho de la pestaña de arriba"), ("E", "Alto de la pestaña de arriba"), ("F", "Del canto izquierdo a la pestaña de abajo")])
lista(640, 1180, [("G", "Ancho de la pestaña de abajo"), ("H", "Alto de la pestaña de abajo"), ("J", "Del canto izquierdo a la ventana grande"),
                  ("K", "Del canto de arriba a la ventana grande"), ("L", "Ancho de la ventana grande"), ("M", "Alto de la ventana grande")])
lista(1230, 1180, [("N", "De la ventana pequeña al canto derecho"), ("P", "Del canto de arriba a la ventana pequeña"),
                   ("Q", "Ancho de la ventana pequeña"), ("R", "Alto de la ventana pequeña")])
d.text((1230, 1180 + 4*54 + 8), "El grosor ya lo tengo: 3 mm.\nEl dibujo es un esquema, no está a escala.", font=f(SANS, 20), fill=GRIS, spacing=8)
im.save(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "medidas-pared-caja.png"))
print(im.size)
