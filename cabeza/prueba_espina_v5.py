"""(v5, 2026-11-24: nudillo de 9 mm, cabeza «mochila» con la caja de metacrilato: 0,45 kg y más fondo.)
Prueba de resistencia de la espina v4 (espina_fea.stl: lomo y cuello, sin la banda ni la garra, que trabajan a
tracción y se comprueban a mano). La cabeza inclinada 40°, con la articulación apretada.
Los apoyos sobre el teclado solo empujan: en cada caso se sueltan los que saldrían a tracción y se repite.
La banda entra como: el tornillo que tira de la punta hacia abajo, una sujeción hacia abajo en el pie del cuello
(la banda contra el canto inferior del puente) y su tensión tirando del pie del cuello hacia delante."""
import json, sys, time
import numpy as np
sys.path.insert(0, ".")
from fea import Modelo

STL = sys.argv[1] if len(sys.argv) > 1 else "espina_fea_v5.stl"
H = float(sys.argv[2]) if len(sys.argv) > 2 else 0.7
MAT = dict(E=2100.0, nu=0.36, capas=22.0, plano=45.0)     # PETG: rotura entre capas y dentro de la capa, MPa
# --- las mismas medidas que espina.scad ---
cf_y, c_h0, c_h1, c_Lt, g, an, apoyo, t_del = 97.0, 11.5, 28.5, 52.0, 0.4, 16.0, 10.0, 6.0
yr = cf_y + 6 + 0.8                                        # cara interior del cuello
T_BANDA = 120.0                                            # tensión de la banda: 60 N de apriete + lo que añade el peor caso
yA = cf_y - c_Lt; ys = 39.54                               # tornillo de la garra
zu = lambda y: c_h0 + g + (cf_y - y) * (c_h1 - c_h0) / c_Lt
masa = 0.45                                               # cabeza completa con la Orange Pi en su caja, kg (estimada: 127 g impresos + pantalla ~110 g + caja ~180 g + cables)
a = np.radians(50)                                        # 90° - inclinación
R = np.array([[1, 0, 0], [0, np.cos(a), -np.sin(a)], [0, np.sin(a), np.cos(a)]])
eje = np.array([0, 118, 23.0]); bis = np.array([0, -59.5, -10.7])
G = lambda p: eje + R @ (np.asarray(p, float) - bis)      # punto de la cabeza -> ejes del teclado
cdg, arriba, esquina = G([-2, -5, -24]), G([0, 50.7, 2.4]), G([64, 50.7, 2.4])
n = R @ [0, 0, 1]
peso = (cdg, (0, 0, -9.81 * masa))
casos = {
    "peso x3 (sacudidas)":   [(cdg, (0, 0, -3 * 9.81 * masa))],
    "empujar arriba, 15 N":  [(arriba, tuple(-15 * n)), peso],
    "tirar de arriba, 15 N": [(arriba, tuple(15 * n)), peso],
    "golpe lateral, 12 N":   [(esquina, (12, 0, 0)), peso],
    "apoyarse encima, 30 N": [(arriba, (0, 0, -30)), peso],
}
zonas = [(-an / 2, an / 2, 118 - 5.5, 118 + 5.5, 23 - 5.5, 23 + 5.5)]      # alrededor del eje
SOLO = int(sys.argv[3]) if len(sys.argv) > 3 else None                   # un solo caso (para lanzarlos en paralelo)
if SOLO is not None:
    casos = dict([list(casos.items())[SOLO]])

t0 = time.time()
m = Modelo(STL, h=H, E=MAT["E"], nu=MAT["nu"])
P = m.nodos
print(f"{STL}: {len(m.celdas)} celdas de {H} mm, volumen {m.volumen:.0f} mm3", flush=True)
# Apoyos posibles: (nodos, eje, signo que debe tener la reacción sobre la espina)
piel = P[:, 2] <= zu(P[:, 1]) + 0.55 * H
# Los apoyos son líneas de contacto (el canto donde de verdad carga al bascular), partidas en izquierda y derecha.
tras = piel & (P[:, 1] >= cf_y - 1.8) & (P[:, 1] <= cf_y + 0.3) & (P[:, 2] > c_h0 - 2)
dela = piel & (P[:, 1] >= yA - 0.1) & (P[:, 1] <= yA + 2.0)
labi = (P[:, 2] <= 0.3) & (P[:, 1] >= yr - 0.1) & (P[:, 1] <= yr + 1.6)        # pie del cuello, donde nace la banda
pie_cuello = np.flatnonzero((P[:, 2] <= 0.8) & (P[:, 1] >= yr - 0.1) & (P[:, 1] <= yr + 2.2))
cand = {}
for lado, mx in (("izq", P[:, 0] < -4.6), ("der", P[:, 0] > 4.6)):
    cand[f"apoyo trasero {lado}"] = (tras & mx, 2, +1)
    cand[f"apoyo delantero {lado}"] = (dela & mx, 2, +1)
    cand[f"banda atrás {lado}"] = (labi & mx, 2, -1)
tor = (np.abs(P[:, 0]) <= 4.0) & (np.abs(P[:, 1] - ys) <= 6.2) & (P[:, 2] >= zu(yA) + t_del - 1.6) & (P[:, 1] < yA)     # bajo la arandela, a los lados de la ranura
cand["tornillo (tira hacia abajo)"] = (tor, 2, -1)
# Lo que frena a lo largo y a lo ancho es el roce de los apoyos apretados; se pone solo en el apoyo trasero para que
# el vuelco lo aguanten las fuerzas verticales (lo más exigente para la espina).
for k, (msk, *_) in cand.items():
    assert msk.sum() >= 3, f"el apoyo {k!r} no toca material ({msk.sum()})"

res = {}
for nombre, cargas in casos.items():
    activos = set(cand)
    for vuelta in range(10):
        m.fijos = {"roce a lo ancho": (np.flatnonzero(tras | dela), [0]), "roce a lo largo": (np.flatnonzero(tras), [1])}
        for k in activos:
            msk, e, _ = cand[k]
            m.fijos[k] = (np.flatnonzero(msk), [e])
        r = m.resolver(nombre, zonas, cargas=cargas, tol=1e-7, otras=[(pie_cuello, (0, -T_BANDA, 0))])
        assert r["u_max"] < 50, f"{nombre}: apoyos insuficientes {sorted(activos)}"
        mal = {k: r["reacciones"][k][cand[k][1]] * cand[k][2] for k in activos}
        peor_k = min(mal, key=mal.get)
        if mal[peor_k] >= -0.05:
            break
        activos.discard(peor_k)                      # se suelta solo el que más tira, y se repite
    fz = {k: float(r["reacciones"][k][cand[k][1]]) for k in sorted(activos)}
    vm = r["vm"]; lejos = r["lejos"]
    res[nombre] = dict(apoyos_N={k: round(v, 1) for k, v in fz.items()}, vueltas=vuelta + 1,
                       roce_ancho_N=round(float(r["reacciones"]["roce a lo ancho"][0]), 1), roce_largo_N=round(float(r["reacciones"]["roce a lo largo"][1]), 1),
                       flecha_borde_pantalla_mm=round(float(np.linalg.norm(r["mover"](arriba))), 3),
                       vm_p99=round(r["vm_p99"], 2), vm_max=round(r["vm_max"], 2))
    print(f"  {nombre:<24} borde de la pantalla se mueve {res[nombre]['flecha_borde_pantalla_mm']:.2f} mm; tensión p99 {r['vm_p99']:.2f}, máx {r['vm_max']:.2f} MPa "
          f"({vuelta + 1} vueltas, {time.time() - t0:.0f} s)\n      " + "; ".join(f"{k} {v:+.1f}" for k, v in fz.items()) + f"; roce a lo largo {res[nombre]['roce_largo_N']:+.1f}, a lo ancho {res[nombre]['roce_ancho_N']:+.1f}", flush=True)
    res[nombre]["_vm"] = vm; res[nombre]["_lejos"] = lejos
if SOLO is not None:
    k = next(iter(res))
    np.savez(f"out_espina_v5_{SOLO}.npz", centros=m.centros, vm=res[k]["_vm"], lejos=res[k]["_lejos"])
    json.dump({k: {a: b for a, b in res[k].items() if not a.startswith("_")}, "_celdas": len(m.celdas), "_h": H}, open(f"out_espina_v5_{SOLO}.json", "w"), indent=1, ensure_ascii=False)
    sys.exit(0)
peor = max(res, key=lambda k: res[k]["vm_max"])
print(f"peor caso: {peor}; margen frente a rotura entre capas (PETG {MAT['capas']} MPa, tensión x1,15): {MAT['capas'] / (1.15 * res[peor]['vm_max']):.1f}; "
      f"dentro de la capa ({MAT['plano']} MPa): {MAT['plano'] / (1.15 * res[peor]['vm_max']):.1f}")
np.savez("out_espina_v5.npz", centros=m.centros, vm=res[peor]["_vm"], lejos=res[peor]["_lejos"])
json.dump({k: {a: b for a, b in v.items() if not a.startswith("_")} for k, v in res.items()} | {"_peor": peor, "_celdas": len(m.celdas), "_h": H},
          open("out_espina_v5.json", "w"), indent=1, ensure_ascii=False)
print(f"{time.time() - t0:.0f} s")
