"""Prueba de resistencia por elementos finitos sobre vóxeles (ladrillos de 8 nodos, elasticidad lineal).

Uso desde otro script:
    from fea import Modelo
    m = Modelo("pieza.stl", h=0.75, E=2100, nu=0.36)
    m.fijar("tornillo_izq", caja, ejes="xyz")
    r = m.resolver("peso", zonas=[caja1, caja2], punto=(x, y, z), fuerza=(fx, fy, fz))

Unidades: mm, N, MPa. Una caja es (x0, x1, y0, y1, z0, z1). La carga actúa en `punto` y se reparte sobre los
nodos de las `zonas` como lo haría una pieza rígida (fuerza y momento). Es un modelo tosco: los escalones de
los vóxeles exageran la tensión en las esquinas, así que la tensión se lee por su percentil 99 y por zonas.
"""
import numpy as np
import scipy.sparse as sp
import scipy.sparse.linalg as spla
import trimesh

_G = 1 / np.sqrt(3)
_NODOS = np.array([[0, 0, 0], [1, 0, 0], [1, 1, 0], [0, 1, 0], [0, 0, 1], [1, 0, 1], [1, 1, 1], [0, 1, 1]])


def _D(E, nu):
    lam, mu = E * nu / ((1 + nu) * (1 - 2 * nu)), E / (2 * (1 + nu))
    D = np.zeros((6, 6))
    D[:3, :3] = lam
    D[np.arange(3), np.arange(3)] += 2 * mu
    D[np.arange(3, 6), np.arange(3, 6)] = mu
    return D


def _B(xi, h):
    """Matriz deformación-desplazamiento de un cubo de lado h en el punto xi (coordenadas -1..1)."""
    s = 2 * _NODOS - 1
    dN = np.array([[s[a, i] * np.prod([1 + s[a, j] * xi[j] for j in range(3) if j != i]) / 8 for a in range(8)] for i in range(3)]) * 2 / h
    B = np.zeros((6, 24))
    for a in range(8):
        dx, dy, dz = dN[:, a]
        B[:, 3 * a:3 * a + 3] = [[dx, 0, 0], [0, dy, 0], [0, 0, dz], [dy, dx, 0], [0, dz, dy], [dz, 0, dx]]
    return B


class Modelo:
    def __init__(self, stl, h=0.75, E=2100.0, nu=0.36):
        self.h, self.E, self.nu = h, E, nu
        malla = trimesh.load(stl)
        self.volumen = float(abs(malla.volume))
        lo, hi = malla.bounds
        self.lo = lo - 1e-4                                   # centros de celda a medio vóxel de las caras
        n = np.ceil((hi - self.lo) / h - 1e-3).astype(int)
        self.n = n
        # Qué celdas quedan dentro: un rayo vertical por columna y se cuentan los cruces (poca memoria).
        ij = np.indices(n[:2]).reshape(2, -1).T
        zc = self.lo[2] + (np.arange(n[2]) + 0.5) * h
        dentro = np.zeros((len(ij), n[2]), bool)
        for i in range(0, len(ij), 1500):
            parte = ij[i:i + 1500]
            orig = np.column_stack([self.lo[0] + (parte[:, 0] + 0.5) * h + 1.37e-4, self.lo[1] + (parte[:, 1] + 0.5) * h + 0.71e-4,
                                    np.full(len(parte), self.lo[2] - 20.0)])
            hits, rayo, _ = malla.ray.intersects_location(orig, np.tile([0.0, 0.0, 1.0], (len(parte), 1)), multiple_hits=True)
            cruces = np.zeros((len(parte), n[2] + 1), int)
            np.add.at(cruces, (rayo, np.searchsorted(zc, hits[:, 2])), 1)
            dentro[i:i + 1500] = np.cumsum(cruces, axis=1)[:, :n[2]] % 2 == 1
        cols, ks = np.nonzero(dentro)
        idx = np.column_stack([ij[cols], ks])
        self.celdas = idx
        self.centros = self.lo + (idx + 0.5) * h
        nn = n + 1
        nid = lambda ijk: (ijk[:, 0] * nn[1] + ijk[:, 1]) * nn[2] + ijk[:, 2]
        conn = np.stack([nid(self.celdas + d) for d in _NODOS], axis=1)
        usados, conn = np.unique(conn, return_inverse=True)
        self.conn = conn.reshape(-1, 8)
        ijk = np.stack([usados // (nn[1] * nn[2]), (usados // nn[2]) % nn[1], usados % nn[2]], axis=1)
        self.nodos = self.lo + ijk * h
        self.D = _D(E, nu)
        KE = sum(_B(np.array(g) * _G, h).T @ self.D @ _B(np.array(g) * _G, h) * (h / 2) ** 3
                 for g in np.array(np.meshgrid([-1, 1], [-1, 1], [-1, 1])).reshape(3, -1).T)
        dof = (3 * self.conn[:, :, None] + np.arange(3)).reshape(len(self.conn), 24)
        self.dof = dof
        rows, cols = np.repeat(dof, 24, axis=1).ravel(), np.tile(dof, (1, 24)).ravel()
        self.K = sp.coo_matrix((np.tile(KE.ravel(), len(dof)), (rows, cols)), shape=(3 * len(self.nodos),) * 2).tocsr()
        self.B0 = _B(np.zeros(3), h)
        self.fijos = {}

    def _en(self, caja, pts):
        x0, x1, y0, y1, z0, z1 = caja
        e = 1e-6
        return ((pts[:, 0] >= x0 - e) & (pts[:, 0] <= x1 + e) & (pts[:, 1] >= y0 - e) & (pts[:, 1] <= y1 + e)
                & (pts[:, 2] >= z0 - e) & (pts[:, 2] <= z1 + e))

    def fijar(self, nombre, caja, ejes="xyz"):
        nodos = np.flatnonzero(self._en(caja, self.nodos))
        assert len(nodos), f"el apoyo {nombre!r} no toca material"
        self.fijos[nombre] = (nodos, ["xyz".index(c) for c in ejes])

    def resolver(self, nombre, zonas, punto=None, fuerza=None, cargas=None, tol=1e-8, otras=None):
        """`cargas` es una lista de (punto, fuerza); o una sola con `punto` y `fuerza`.
        `otras`: lista de (nodos, fuerza) que se reparten por igual entre esos nodos (fuerzas aparte de las de `zonas`)."""
        cargas = cargas or [(punto, fuerza)]
        punto = cargas[0][0]
        N = len(self.nodos)
        f = np.zeros((N, 3))
        sel = np.zeros(N, bool)
        for z in zonas:
            sel |= self._en(z, self.nodos)
        assert sel.sum() >= 4, f"la carga {nombre!r} no toca material"
        r = self.nodos[sel] - self.nodos[sel].mean(axis=0)
        c0 = self.nodos[sel].mean(axis=0)
        F = sum(np.asarray(f_, float) for _, f_ in cargas)
        M = sum(np.cross(np.asarray(p_, float) - c0, np.asarray(f_, float)) for p_, f_ in cargas)
        I = (r ** 2).sum() * np.eye(3) - r.T @ r
        f[sel] = F / sel.sum() + np.cross(np.linalg.pinv(I) @ M, r)
        for nodos_o, f_o in (otras or []):
            f[nodos_o] += np.asarray(f_o, float) / len(nodos_o)
        fijo = np.zeros(3 * N, bool)
        for nodos, ejes in self.fijos.values():
            for e in ejes:
                fijo[3 * nodos + e] = True
        libre = ~fijo
        Kll = self.K[libre][:, libre]
        b = f.ravel()[libre]
        d = Kll.diagonal()
        u, info = spla.cg(Kll, b, rtol=tol, maxiter=20000, M=sp.diags(1 / d))
        assert info == 0, f"el cálculo de {nombre!r} no convergió"
        U = np.zeros(3 * N)
        U[libre] = u
        reac = (self.K @ U - f.ravel()).reshape(N, 3)
        ue = U[self.dof]
        eps = ue @ self.B0.T
        sig = eps @ self.D.T
        vm = np.sqrt(0.5 * ((sig[:, 0] - sig[:, 1]) ** 2 + (sig[:, 1] - sig[:, 2]) ** 2 + (sig[:, 2] - sig[:, 0]) ** 2)
                     + 3 * (sig[:, 3] ** 2 + sig[:, 4] ** 2 + sig[:, 5] ** 2))
        Un = U.reshape(N, 3)
        # desplazamiento del punto de carga: movimiento rígido medio de la zona cargada
        c = self.nodos[sel].mean(axis=0)
        A = np.zeros((3 * sel.sum(), 6))
        for k in range(3):
            A[k::3, k] = 1
        rr = self.nodos[sel] - c
        A[0::3, 4], A[0::3, 5] = rr[:, 2], -rr[:, 1]
        A[1::3, 3], A[1::3, 5] = -rr[:, 2], rr[:, 0]
        A[2::3, 3], A[2::3, 4] = rr[:, 1], -rr[:, 0]
        q = np.linalg.lstsq(A, Un[sel].ravel(), rcond=None)[0]
        p = np.asarray(punto, float) - c
        up = q[:3] + np.cross(q[3:], p)
        lejos = np.ones(len(self.centros), bool)                 # tensión lejos de apoyos y zonas cargadas
        for nodos, _ in self.fijos.values():
            p0, p1 = self.nodos[nodos].min(axis=0) - 2.5 * self.h, self.nodos[nodos].max(axis=0) + 2.5 * self.h
            lejos &= ~self._en((p0[0], p1[0], p0[1], p1[1], p0[2], p1[2]), self.centros)
        for nodos_o, _ in (otras or []):
            p0, p1 = self.nodos[nodos_o].min(axis=0) - 2.5 * self.h, self.nodos[nodos_o].max(axis=0) + 2.5 * self.h
            lejos &= ~self._en((p0[0], p1[0], p0[1], p1[1], p0[2], p1[2]), self.centros)
        for z in zonas:
            x0, x1, y0, y1, z0, z1 = z
            g = 2 * self.h
            lejos &= ~self._en((x0 - g, x1 + g, y0 - g, y1 + g, z0 - g, z1 + g), self.centros)
        return {"nombre": nombre, "fuerza": F, "momento": M, "u_punto": up, "mover": (lambda P, q=q, c=c: q[:3] + np.cross(q[3:], np.asarray(P, float) - c)), "u_max": float(np.linalg.norm(Un, axis=1).max()),
                "vm": vm, "lejos": lejos, "vm_p99": float(np.percentile(vm[lejos], 99)) if lejos.any() else float("nan"),
                "vm_max": float(vm[lejos].max()) if lejos.any() else float("nan"),
                "reacciones": {k: reac[nodos].sum(axis=0) for k, (nodos, _) in self.fijos.items()}, "U": Un}
