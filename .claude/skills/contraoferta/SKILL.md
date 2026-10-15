---
name: contraoferta
description: Calcula el precio mínimo que un vendedor de Kabla puede autorizar ante una cotización de la competencia o una cotización propia estancada, con la regla de precio de la Dirección General y datos vivos de NetSuite. Se usa con /contraoferta seguido del artículo (nombre, SKU o id) y, si existe, el precio rival.
argument-hint: "<artículo o SKU> [precio rival] [cliente]"
---

# Agente de contraoferta · Kabla

Meta: que el vendedor tenga un precio autorizado en minutos, dentro de la regla de la Dirección, en lugar de esperar más de un día.

## Pasos
1. Identifica el artículo en NetSuite con `ns_runCustomSuiteQL` (busca por `itemid` o `displayname`, solo `isinactive = 'F'`). Si hay varios candidatos, muéstralos y pide elegir; no adivines.
2. Corre `agentes/contraoferta/sql/piso_precio.sql` sustituyendo `:ITEM_IDS` por el id. No cambies la lógica del SQL: es la política de precio.
3. Si `control` empieza con `ESCALAR`, no autorices: arma el caso para el gerente comercial y explica qué dato falta.
4. Con precio rival:
   - Rival ≥ piso → precio autorizado = precio rival (empatar). Si el rival está arriba de DISTRIBUIDOR IV, sugiere quedarse en DISTRIBUIDOR IV.
   - Rival < piso → precio autorizado = piso, y se escala al gerente comercial si el vendedor necesita bajar más.
   Sin precio rival (cotización propia estancada 10 días o más) → propone el piso solo si es menor al precio cotizado; si no, recomienda llamada de seguimiento.
5. Responde en 6 líneas máximo: artículo, precio autorizado, piso y su razón, margen sobre costo puesto (%), días de inventario y stock vendible, y si requiere firma.
6. Registra la corrida en `bitacora/contraoferta.csv` (fecha, artículo, id, precio rival, piso, precio autorizado, control, usuario).

## Límites
- Nunca modifica precios, cotizaciones ni pedidos en NetSuite; solo calcula y propone.
- Cuentas con ejecutivo asignado (no "TELEMARKETING KABLA") o que compran $100,000 o más al año: el agente propone y el vendedor envía. Cuentas pequeñas o de telemarketing: puede redactar el correo al cliente listo para enviar.
- Nunca autoriza precio debajo del piso.
