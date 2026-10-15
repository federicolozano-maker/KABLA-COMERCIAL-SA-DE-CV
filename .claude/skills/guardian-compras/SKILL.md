---
name: guardian-compras
description: Revisa cada lunes las órdenes de compra de Kabla que propone Compras, antes de que salgan, y dictamina cada una (aprobar, reducir o rechazar) con la razón y los pesos en juego, usando datos de NetSuite. Se usa con /guardian-compras [fecha].
argument-hint: "[fecha AAAA-MM-DD]"
---

# Guardián de compras · Kabla  

Estado: reglas cerradas el 15-oct-2026. Pendiente: vida útil por artículo para la regla 2 (hoy solo 20% de los lotes con existencia tiene caducidad capturada).

## Qué lee (NetSuite)
- Órdenes propuestas: órdenes de compra en "Pendiente de aprobación" (aprobación de OC activada en NetSuite por decisión de la Dirección, 15-oct-2026).
- Por línea: artículo, tipo de producto (custitem3), cantidad, precio (rate, en pesos), proveedor, fecha esperada de llegada. El importe en pesos es cantidad × rate (netamount viene en la moneda del proveedor).
- Inventario vendible y venta 12 meses (definiciones de CLAUDE.md), órdenes abiertas de clientes y lotes con caducidad.

## Alcance
Solo mercancía para venta. No revisa compras de suministros internos (cajas, etiquetas, uso de almacén o taller, activo fijo), servicios ni gastos.

## Reglas (Dirección General, 15-oct-2026)
1. Cobertura según tipo de producto (custitem3):
   - De Línea – Básico (y De Línea, De Línea – Variable): días de inventario después de la compra = (stock vendible + en tránsito + cantidad de la OC) / venta diaria ≤ 180. Si se pasa, reduce a la cantidad que deja 180 días.
   - De Línea – Emergente: sin tope de cobertura.
   - Bajo pedido y Bajo pedido especial: el inventario debe ser 0. Solo aprueba la cantidad respaldada por pedidos de cliente abiertos; todo lo demás es sobreinventario y se reduce.
   - Bajo Proyecto: igual que Bajo pedido.
   - Descontinuado, Hasta Agotar Existencias y Outlet: se rechaza cualquier compra.
2. Caducidad: rechaza o reduce si la cobertura después de la compra supera la vida útil restante con que llega el lote.
3. Margen de analizadores: (DISTRIBUIDOR IV − costo puesto − 15% de DISTRIBUIDOR IV por gastos) / DISTRIBUIDOR IV ≥ 10%. Costo puesto = precio de la OC × 1.12. Analizador = artículo cuyo nombre empieza con "Analizador" o "Contador". No aplica a alcoholímetros ni refacciones. Si no cumple, se rechaza y se indica el precio de compra máximo que sí cumple.
4. Mejor precio: Kabla no acepta mínimos de compra (MOQ). Si el precio unitario de la OC es mayor al mejor precio pagado a ese proveedor por el mismo artículo en 12 meses, la línea se marca "renegociar" con la diferencia en pesos.
5. Sin mínimos contractuales: ninguna regla de penalización por proveedor.

## Cómo correr
1. Corre `agentes/guardian-compras/sql/lineas_oc.sql` con las fechas de la semana (o el estatus Pendiente de aprobación) para traer cada línea con sus datos de NetSuite.
2. Guarda el resultado como JSON y corre `python3 agentes/guardian-compras/dictaminar.py <json> <fecha>`: aplica las reglas y genera el Excel con marca Kabla.
3. Sube el Excel a Drive › CLAUDE CODE TALLER › entregables › dictamenes y agrega la fila a la bitácora.

## Entrega
- Excel con fecha en Drive › CLAUDE CODE TALLER › entregables › dictamenes, con marca Kabla.
- Resumen: órdenes revisadas, aprobadas, reducidas y rechazadas, y pesos que se evitó comprometer.
- Entrada en `bitacora/guardian-compras.csv`.

## Límites
- Nunca modifica ni aprueba órdenes en NetSuite: solo dictamina. Firma la Dirección General.
