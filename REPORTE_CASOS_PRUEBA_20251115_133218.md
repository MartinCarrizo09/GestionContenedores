# Reporte de EjecuciÃ³n de Casos de Prueba - Sistema TPI
Fecha: 2025-11-15 13:32:18

## Resumen
- Total de casos: 100
- Exitosos: 2
- Fallidos: 98
- Tasa de Ã©xito: 2%

## Detalle de Casos

### âŒ [001] 
- **Endpoint**: GET /api-gestion/clientes
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [002] 
- **Endpoint**: GET /api-gestion/clientes/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [003] 
- **Endpoint**: GET /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [004] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [005] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 409
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [006] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 400
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [007] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 400
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [008] 
- **Endpoint**: PUT /api-gestion/clientes/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [009] 
- **Endpoint**: PUT /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [010] 
- **Endpoint**: DELETE /api-gestion/clientes/1
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [011] 
- **Endpoint**: DELETE /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [012] 
- **Endpoint**: GET /api-gestion/contenedores
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [013] 
- **Endpoint**: GET /api-gestion/contenedores/cliente/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [014] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-001
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [015] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-999
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [016] 
- **Endpoint**: GET /api-gestion/contenedores/1/estado
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [017] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-001/estado
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [018] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [019] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 409
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [020] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [021] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 400
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [022] 
- **Endpoint**: PUT /api-gestion/contenedores/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [023] 
- **Endpoint**: DELETE /api-gestion/contenedores/1
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [024] 
- **Endpoint**: GET /api-gestion/depositos
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [025] 
- **Endpoint**: GET /api-gestion/depositos/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [026] 
- **Endpoint**: POST /api-gestion/depositos
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [027] 
- **Endpoint**: PUT /api-gestion/depositos/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [028] 
- **Endpoint**: DELETE /api-gestion/depositos/1
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [029] 
- **Endpoint**: GET /api-gestion/tarifas
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [030] 
- **Endpoint**: GET /api-gestion/tarifas/aplicable?peso=500&volumen=2.5
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [031] 
- **Endpoint**: GET /api-gestion/tarifas/aplicable?peso=10000&volumen=50
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [032] 
- **Endpoint**: POST /api-gestion/tarifas
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [033] 
- **Endpoint**: PUT /api-gestion/tarifas/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [034] 
- **Endpoint**: DELETE /api-gestion/tarifas/1
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [035] 
- **Endpoint**: GET /api-flota/camiones
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [036] 
- **Endpoint**: GET /api-flota/camiones/disponibles
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [037] 
- **Endpoint**: GET /api-flota/camiones/AA123BB
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [038] 
- **Endpoint**: GET /api-flota/camiones/ZZ999ZZ
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [039] 
- **Endpoint**: GET /api-flota/camiones/aptos?peso=2000&volumen=15
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [040] 
- **Endpoint**: POST /api-flota/camiones
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [041] 
- **Endpoint**: POST /api-flota/camiones
- **Status esperado**: 409
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [042] 
- **Endpoint**: POST /api-flota/camiones
- **Status esperado**: 400
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [043] 
- **Endpoint**: PUT /api-flota/camiones/AA123BB
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [044] 
- **Endpoint**: PATCH /api-flota/camiones/AA123BB/disponibilidad?disponible=false
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [045] 
- **Endpoint**: PATCH /api-flota/camiones/ZZ999ZZ/disponibilidad?disponible=true
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [046] 
- **Endpoint**: DELETE /api-flota/camiones/BB456CC
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [047] 
- **Endpoint**: GET /api-logistica/solicitudes
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [048] 
- **Endpoint**: GET /api-logistica/solicitudes/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [049] 
- **Endpoint**: GET /api-logistica/solicitudes/999
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [050] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento/SEG-2024-001
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [051] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento/SEG-INVALIDO
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [052] 
- **Endpoint**: GET /api-logistica/solicitudes/cliente/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [053] 
- **Endpoint**: GET /api-logistica/solicitudes/estado/PENDIENTE
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [054] 
- **Endpoint**: POST /api-logistica/solicitudes
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [055] 
- **Endpoint**: POST /api-logistica/solicitudes
- **Status esperado**: 409
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [056] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [057] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [058] 
- **Endpoint**: PUT /api-logistica/solicitudes/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [059] 
- **Endpoint**: DELETE /api-logistica/solicitudes/1
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [060] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [061] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [062] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [063] 
- **Endpoint**: POST /api-logistica/solicitudes/1/asignar-ruta
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [064] 
- **Endpoint**: POST /api-logistica/solicitudes/999/asignar-ruta
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [065] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento-detallado/SEG-2024-001
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [066] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento-detallado/SEG-INVALIDO
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [067] 
- **Endpoint**: GET /api-logistica/solicitudes/pendientes
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [068] 
- **Endpoint**: GET /api-logistica/solicitudes/pendientes?estado=PENDIENTE&idContenedor=1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [069] 
- **Endpoint**: GET /api-logistica/tramos
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [070] 
- **Endpoint**: GET /api-logistica/tramos/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [071] 
- **Endpoint**: GET /api-logistica/tramos/ruta/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [072] 
- **Endpoint**: GET /api-logistica/tramos/camion/AA123BB
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [073] 
- **Endpoint**: GET /api-logistica/tramos/estado/PENDIENTE
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [074] 
- **Endpoint**: POST /api-logistica/tramos
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [075] 
- **Endpoint**: PUT /api-logistica/tramos/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [076] 
- **Endpoint**: DELETE /api-logistica/tramos/1
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [077] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=AA123BB&peso=1500&volumen=2.5
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [078] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=ZZ999ZZ&peso=1500&volumen=2.5
- **Status esperado**: 404
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [079] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=AA123BB&peso=100000&volumen=2.5
- **Status esperado**: 400
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [080] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [081] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 409
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [082] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 409
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [083] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [084] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 409
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [085] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=-5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 400
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [086] 
- **Endpoint**: GET /api-logistica/rutas
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [087] 
- **Endpoint**: GET /api-logistica/rutas/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [088] 
- **Endpoint**: GET /api-logistica/rutas/solicitud/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [089] 
- **Endpoint**: POST /api-logistica/rutas
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [090] 
- **Endpoint**: PUT /api-logistica/rutas/1
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [091] 
- **Endpoint**: DELETE /api-logistica/rutas/1
- **Status esperado**: 204
- **Status obtenido**: 401
- **Resultado**: FAIL

### âœ… [092] 
- **Endpoint**: GET /api-gestion/clientes
- **Status esperado**: 401
- **Status obtenido**: 401
- **Resultado**: OK

### âœ… [093] 
- **Endpoint**: GET /api-flota/camiones
- **Status esperado**: 401
- **Status obtenido**: 401
- **Resultado**: OK

### âŒ [094] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 403
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [095] 
- **Endpoint**: DELETE /api-logistica/solicitudes/1
- **Status esperado**: 403
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [096] 
- **Endpoint**: GET /api-gestion/actuator/health
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [097] 
- **Endpoint**: GET /api-flota/actuator/metrics
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [098] 
- **Endpoint**: GET /api-*/swagger-ui/index.html
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [099] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 400
- **Status obtenido**: 401
- **Resultado**: FAIL

### âŒ [100] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=10.5&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 200
- **Status obtenido**: 401
- **Resultado**: FAIL


