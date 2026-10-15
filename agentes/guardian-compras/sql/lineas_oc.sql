-- Líneas de órdenes de compra a dictaminar · Kabla Comercial
-- :DESDE y :HASTA en formato AAAA-MM-DD. En operación normal, filtrar además por estatus "Pendiente de aprobación".
SELECT t.id oc_id, t.tranid oc, BUILTIN.DF(t.entity) proveedor, t.entity proveedor_id, t.trandate fecha_oc,
  tl.id linea_id, tl.item, BUILTIN.DF(tl.item) articulo, BUILTIN.DF(i.custitem3) tipo_producto,
  tl.quantity cant, tl.rate precio, tl.expectedreceiptdate llegada,
  (SELECT SUM(ib.quantityonhand) FROM InventoryBalance ib WHERE ib.item = tl.item AND BUILTIN.DF(ib.location) IN ('ALMACEN LINDAVISTA','ALMACEN CIUDAD DE MEXICO','ALMACEN GUADALAJARA','ALMACEN TIJUANA','KABLA ALMACEN MATRIZ','KABLA CADUCIDAD CORTA')) stock_vendible,
  (SELECT SUM(p.quantity - NVL(p.quantityshiprecv,0)) FROM transaction po JOIN transactionLine p ON p.transaction = po.id WHERE po.type = 'PurchOrd' AND p.item = tl.item AND p.mainline = 'F' AND p.isclosed = 'F' AND po.id <> t.id AND p.quantity > NVL(p.quantityshiprecv,0)) en_transito,
  (SELECT -SUM(v.quantity) FROM transaction f JOIN transactionLine v ON v.transaction = f.id WHERE f.type = 'CustInvc' AND f.trandate >= ADD_MONTHS(SYSDATE,-12) AND v.mainline = 'F' AND v.item = tl.item) venta_12m,
  (SELECT SUM(ABS(s.quantity) - NVL(ABS(s.quantityshiprecv),0)) FROM transaction so JOIN transactionLine s ON s.transaction = so.id WHERE so.type = 'SalesOrd' AND s.item = tl.item AND s.mainline = 'F' AND s.isclosed = 'F' AND ABS(s.quantity) > NVL(ABS(s.quantityshiprecv),0)) pedidos_abiertos,
  (SELECT MAX(pr.unitPrice) FROM pricing pr WHERE pr.item = tl.item AND BUILTIN.DF(pr.priceLevel) = 'DISTRIBUIDOR IV' AND BUILTIN.DF(pr.currency) = 'Pesos') dist_iv,
  (SELECT MIN(h.rate) FROM transaction ho JOIN transactionLine h ON h.transaction = ho.id WHERE ho.type = 'PurchOrd' AND ho.entity = t.entity AND h.item = tl.item AND h.mainline = 'F' AND h.rate > 0 AND ho.id <> t.id AND ho.trandate >= ADD_MONTHS(SYSDATE,-12)) mejor_precio_12m
FROM transaction t JOIN transactionLine tl ON tl.transaction = t.id JOIN item i ON i.id = tl.item
WHERE t.type = 'PurchOrd' AND tl.mainline = 'F' AND i.itemtype = 'InvtPart'
  AND t.trandate >= TO_DATE(':DESDE','YYYY-MM-DD') AND t.trandate <= TO_DATE(':HASTA','YYYY-MM-DD')
ORDER BY t.tranid, tl.id
