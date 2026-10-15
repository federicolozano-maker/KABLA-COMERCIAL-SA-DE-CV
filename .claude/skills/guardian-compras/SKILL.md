---
name: guardian-compras
description: Revisa cada lunes las órdenes de compra de Kabla que propone Compras, antes de que salgan, y dictamina cada una (aprobar, reducir o rechazar) con la razón y los pesos en juego, usando datos de NetSuite. Se usa con /guardian-compras [fecha].
argument-hint: "[fecha AAAA-MM-DD]"
---

# Guardián de compras · Kabla  (BORRADOR: faltan 3 decisiones)

Estado: en definición. No correr hasta cerrar los pendientes marcados con ⚠.

## Qué lee (NetSuite)
- Órdenes propuestas: órdenes de compra en "Pendiente de aprobación" (aprobación de OC activada en NetSuite por decisión de la Dirección, 15-oct-2026).
- Por línea: artículo, tipo de producto (custitem3), cantidad, precio (rate, en pesos), proveedor, fecha esperada de llegada. El importe en pesos es cantidad × rate (netamount viene en la moneda del proveedor).
- Inventario vendible y venta 12 meses (definiciones de CLAUDE.md), órdenes abiertas de clientes y lotes con caducidad.

## Reglas (Dirección General, 15-oct-2026)
1. Cobertura según tipo de producto (custitem3):
   - De Línea – Básico (y De Línea, De Línea – Variable ⚠ confirmar): días de inventario después de la compra = (stock vendible + en tránsito + cantidad de la OC) / venta diaria ≤ 180. Si se pasa, reduce a la cantidad que deja 180 días.
   - De Línea – Emergente: sin tope de cobertura.
   - Bajo pedido y Bajo pedido especial: el inventario debe ser 0. Solo aprueba la cantidad respaldada por pedidos de cliente abiertos; todo lo demás es sobreinventario y se reduce.
   - ⚠ Bajo Proyecto, Descontinuado, Hasta Agotar Existencias, Outlet: tratamiento por confirmar (propuesta: Bajo Proyecto como Bajo pedido; Descontinuado, Hasta Agotar y Outlet se rechazan).
2. Caducidad: rechaza o reduce si la cobertura después de la compra supera la vida útil restante con que llega el lote.
3. Margen de analizadores: (DISTRIBUIDOR IV − costo puesto − gastos) / DISTRIBUIDOR IV ≥ 10%. Aplica solo a analizadores (química, inmunoensayo como Maglumi X3, Selectra, hematología). No aplica a alcoholímetros ni refacciones. ⚠ Falta % de gastos.
4. Mejor precio: Kabla no acepta mínimos de compra (MOQ). Si el precio unitario de la OC es mayor al mejor precio pagado a ese proveedor por el mismo artículo en 12 meses, la línea se marca "renegociar" con la diferencia en pesos.
5. Sin mínimos contractuales: ninguna regla de penalización por proveedor.

## Entrega
- Excel con fecha en Drive › CLAUDE CODE TALLER › entregables › dictamenes, con marca Kabla.
- Resumen: órdenes revisadas, aprobadas, reducidas y rechazadas, y pesos que se evitó comprometer.
- Entrada en `bitacora/guardian-compras.csv`.

## Límites
- Nunca modifica ni aprueba órdenes en NetSuite: solo dictamina. Firma la Dirección General.
