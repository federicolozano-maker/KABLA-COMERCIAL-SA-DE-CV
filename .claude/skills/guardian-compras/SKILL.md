---
name: guardian-compras
description: Revisa cada lunes las órdenes de compra de Kabla que propone Compras, antes de que salgan, y dictamina cada una (aprobar, reducir o rechazar) con la razón y los pesos en juego, usando datos de NetSuite. Se usa con /guardian-compras [fecha].
argument-hint: "[fecha AAAA-MM-DD]"
---

# Guardián de compras · Kabla  (BORRADOR: faltan decisiones de la Dirección)

Estado: en definición. No correr hasta cerrar los pendientes marcados con ⚠.

## Qué lee (NetSuite)
- ⚠ Órdenes propuestas: órdenes de compra pendientes de aprobación de la semana. Requiere activar aprobación de OC en NetSuite (hoy nacen como "Pendiente de recibir").
- Inventario vendible, venta 12 meses y días de inventario (mismas definiciones que CLAUDE.md).
- Lotes y caducidad (inventoryNumber.expirationDate).

## Reglas
1. ⚠ Presupuesto: por definir si existe presupuesto de compra por marca/línea y trimestre; alternativa: tope de cobertura post-compra.
2. Caducidad: rechaza si los días de inventario después de la compra superan la vida útil restante con que llega el lote. ⚠ Confirmar vida útil típica por línea.
3. ⚠ Margen: margen mínimo con costo puesto contra DISTRIBUIDOR IV (porcentaje por definir).
4. Sobreinventario: si el artículo ya tiene más de 180 días de inventario vendible, aprueba máximo la mitad; excepción: proveedor nacional con entrega de 4 semanas o menos.
5. ⚠ Contratos con mínimo de compra: proveedores, mínimos y penalización por definir; si recortar deja a un proveedor debajo de su mínimo, compara la penalización contra el inventario que se evita.

## Entrega
- Excel con fecha en Drive › CLAUDE CODE TALLER › entregables › dictamenes, con marca Kabla.
- Resumen: órdenes revisadas, aprobadas, reducidas y rechazadas, y pesos que se evitó comprometer.
- Entrada en `bitacora/guardian-compras.csv`.

## Límites
- Nunca modifica ni aprueba órdenes en NetSuite: solo dictamina. Firma la Dirección General.
