-- Piso de precio autorizado por artículo · Kabla Comercial
-- Reemplaza :ITEM_IDS por la lista de ids internos de NetSuite (ej. 27444, 708)
SELECT x.id, x.articulo, x.tipo, x.costo_base, x.costo_puesto, x.stock_vendible, x.venta_12m,
       CASE WHEN NVL(x.venta_12m,0) <= 0 THEN NULL ELSE ROUND(NVL(x.stock_vendible,0) / (x.venta_12m / 365)) END dias_inventario,
       x.dist_iv, x.lista,
       CASE
         WHEN x.tipo = 'ALCOHOLIMETRO' OR x.costo_base IS NULL THEN ROUND(x.dist_iv * 0.90, 2)
         WHEN x.tipo = 'EQUIPO' THEN ROUND(x.costo_puesto * 1.10, 2)
         WHEN NVL(x.stock_vendible,0) <= 0 OR NVL(x.venta_12m,0) <= 0 THEN x.dist_iv
         WHEN x.stock_vendible / (x.venta_12m / 365) < 90 THEN x.dist_iv
         WHEN x.stock_vendible / (x.venta_12m / 365) <= 180 THEN ROUND(x.costo_puesto * 1.15, 2)
         ELSE x.costo_puesto
       END piso,
       CASE
         WHEN x.tipo = 'ALCOHOLIMETRO' THEN 'Alcoholímetro: DISTRIBUIDOR IV menos 10%'
         WHEN x.costo_base IS NULL THEN 'Sin costo en NetSuite: DISTRIBUIDOR IV menos 10%'
         WHEN x.tipo = 'EQUIPO' THEN 'Equipo: costo puesto más 10%'
         WHEN NVL(x.stock_vendible,0) <= 0 THEN 'Sin stock vendible: no baja de DISTRIBUIDOR IV'
         WHEN NVL(x.venta_12m,0) <= 0 THEN 'Sin venta en 12 meses: no baja de DISTRIBUIDOR IV (revisar)'
         WHEN x.stock_vendible / (x.venta_12m / 365) < 90 THEN 'Alta rotación (menos de 90 días): no baja de DISTRIBUIDOR IV'
         WHEN x.stock_vendible / (x.venta_12m / 365) <= 180 THEN 'Stock normal (90 a 180 días): costo puesto más 15%'
         ELSE 'Sobreinventario (más de 180 días): hasta costo puesto'
       END razon,
       CASE WHEN NVL(x.dist_iv,0) <= 0 AND (x.tipo = 'ALCOHOLIMETRO' OR x.costo_base IS NULL) THEN 'ESCALAR: sin DISTRIBUIDOR IV ni costo'
            WHEN NVL(x.dist_iv,0) <= 0 AND x.tipo = 'CONSUMIBLE' AND (NVL(x.stock_vendible,0) <= 0 OR NVL(x.venta_12m,0) <= 0 OR x.stock_vendible / (x.venta_12m / 365) < 90) THEN 'ESCALAR: sin DISTRIBUIDOR IV'
            ELSE 'OK' END control
FROM (
  SELECT i.id, i.itemid articulo,
    CASE
      WHEN LOWER(i.itemid) LIKE 'alcoholimetro%' OR LOWER(i.itemid) LIKE 'alcoholímetro%' THEN 'ALCOHOLIMETRO'
      WHEN BUILTIN.DF(i.custitem3) = 'Refacciones' THEN 'CONSUMIBLE'
      WHEN i.isserialitem = 'T' OR BUILTIN.DF(i.class) = 'Equipos' OR NVL(NULLIF(i.averagecost,0), i.lastpurchaseprice) >= 50000 THEN 'EQUIPO'
      ELSE 'CONSUMIBLE'
    END tipo,
    NVL(NULLIF(i.averagecost,0), NULLIF(i.lastpurchaseprice,0)) costo_base,
    ROUND(NVL(NULLIF(i.averagecost,0), NULLIF(i.lastpurchaseprice,0)) * 1.12, 2) costo_puesto,
    (SELECT SUM(ib.quantityonhand) FROM InventoryBalance ib WHERE ib.item = i.id AND BUILTIN.DF(ib.location) IN ('ALMACEN LINDAVISTA','ALMACEN CIUDAD DE MEXICO','ALMACEN GUADALAJARA','ALMACEN TIJUANA','KABLA ALMACEN MATRIZ','KABLA CADUCIDAD CORTA')) stock_vendible,
    (SELECT -SUM(tl.quantity) FROM transaction t JOIN transactionLine tl ON tl.transaction = t.id WHERE t.type = 'CustInvc' AND t.trandate >= ADD_MONTHS(SYSDATE,-12) AND tl.mainline = 'F' AND tl.item = i.id) venta_12m,
    (SELECT MAX(p.unitPrice) FROM pricing p WHERE p.item = i.id AND BUILTIN.DF(p.priceLevel) = 'DISTRIBUIDOR IV' AND BUILTIN.DF(p.currency) = 'Pesos') dist_iv,
    (SELECT MAX(p.unitPrice) FROM pricing p WHERE p.item = i.id AND BUILTIN.DF(p.priceLevel) = 'LISTA' AND BUILTIN.DF(p.currency) = 'Pesos') lista
  FROM item i
  WHERE i.id IN (:ITEM_IDS)
) x
