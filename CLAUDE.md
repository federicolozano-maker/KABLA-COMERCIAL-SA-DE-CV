# Kabla Comercial · Agentes

Repositorio de los agentes de Kabla Comercial, S.A. de C.V. Todo dato sale de NetSuite (conector MCP de NetSuite), Zoho CRM o BigQuery de Kabla. Nunca se usan datos de ejemplo ni de otras empresas.

## Reglas para trabajar aquí
- Idioma: español de negocio mexicano. Montos en pesos MXN con comas de miles.
- Identidad visual: todo entregable usa la marca Kabla (skill kabla-brand): Safety royal #FF8000, Onyx #444444, Open Sans, logotipo oficial.
- Los agentes nunca modifican registros de NetSuite (órdenes, precios, clientes) sin aprobación de una persona. Solo leen y proponen.
- Toda corrida deja una entrada en la bitácora del agente.

## Supuestos de negocio vigentes (decididos por la Dirección General, oct 2026)
- Costo puesto = costo promedio × 1.12 (arancel ~5% + logística 5-10%). Si no hay costo promedio, último precio de compra × 1.12. NetSuite no registra landed cost.
- Inventario vendible: ALMACEN LINDAVISTA, ALMACEN CIUDAD DE MEXICO, ALMACEN GUADALAJARA, ALMACEN TIJUANA, KABLA ALMACEN MATRIZ, KABLA CADUCIDAD CORTA. Nunca NO CONFORME, PROYECTO, CUARENTENA, DEMOS, PRESTAMO, REACONDICIONADO ni activo fijo.
- Días de inventario = stock vendible / (venta facturada 12 meses / 365). Alta rotación < 90 días; sobreinventario > 180 días.
- Rango de precio: DISTRIBUIDOR IV (piso) a LISTA.
- Equipo = artículo con número de serie, clase "Equipos" o costo ≥ $50,000. Los alcoholímetros NO son equipos.

## Agentes
| Agente | Comando | Qué hace |
|---|---|---|
| contraoferta | /contraoferta | Precio mínimo autorizado ante una cotización rival o una cotización propia estancada |
| guardian-compras | /guardian-compras | Dictamen semanal de las órdenes de compra antes de que salgan (en definición) |
