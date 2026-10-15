# Modo vigilancia · guardián de compras (en prueba, paralelo a la firma actual)

Corre en días hábiles a las 08:58, 12:58 y 16:58 (hora de Monterrey). Solo lee NetSuite; nunca modifica, aprueba ni firma nada.

## Pasos
1. Lee el último id interno revisado en `bitacora/guardian-ultimo-id-oc.txt`.
2. Busca órdenes de compra nuevas (`transaction.type = 'PurchOrd' AND transaction.id > <último id>`) con líneas de artículos de inventario (`item.itemtype = 'InvtPart'`). Si no hay, termina sin notificar.
3. Trae por línea: OC, proveedor, proveedor_id, item, artículo, tipo de producto (custitem3), cantidad, rate (pesos), fecha esperada de llegada, cantidad ya recibida.
4. Para los artículos de esas líneas (lista explícita de ids en `IN (...)`; las consultas sin lista explícita tardan más de 60 s), trae por separado: stock vendible, en tránsito (OC abiertas de 6 meses), venta facturada 12 meses, pedidos de cliente abiertos (6 meses), DISTRIBUIDOR IV y mejor precio del mismo proveedor en 12 meses. Si un resultado es muy grande, agrega `RPAD('x', 2000, 'x') pad` para que se guarde en archivo y léelo con python.
5. Arma `lineas.json` (stock vendible menos lo ya recibido de la misma línea) y corre:
   `TIPO_CAMBIO_USD=<tipo de cambio del día> python3 agentes/guardian-compras/dictaminar.py lineas.json <fecha> entregables/dictamenes`
6. Manda un correo a federico.lozano@kabla.mx (Gmail) con asunto "Guardián de compras · N órdenes nuevas · $X frenados" y una tabla por OC: OC, proveedor, monto USD, dictamen (OK / REVISAR), quién firma (Gerente de compras si OK y < USD 5,000; si no, Dirección General) y la razón principal de lo que se frena. Arriba: total pedido, total que se frenaría y cuántas firma cada quien.
7. Actualiza `bitacora/guardian-ultimo-id-oc.txt` con el id más alto revisado, agrega la fila en `bitacora/guardian-compras.csv`, haz commit y push a main.

## Regla de firma (Dirección General, 15-oct-2026)
- OC que pasa todas las reglas y suma menos de USD 5,000: firma el gerente de compras.
- Todo lo demás: firma la Dirección General, con el dictamen a la vista.
