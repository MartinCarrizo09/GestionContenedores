# Reporte de EjecuciÃ³n de Casos de Prueba - Sistema TPI
Fecha: 2025-11-11 11:52:48

## Resumen
- Total de casos: 100
- Exitosos: 45
- Fallidos: 55
- Tasa de Ã©xito: 45%

## Detalle de Casos

### âœ… [001] 
- **Endpoint**: GET /api-gestion/clientes
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":2,"nombre":"MarÃ­a Elena","apellido":"MartÃ­nez","email":"mmartinez@transportesunidos.com","telefono":"+54 351 400-2000"},{"id":3,"nombre":"Roberto","apellido":"GÃ³mez","email":"rgomez@elprogreso.com","telefono":"+54 351 400-3000"},{"id":4,"nombre":"Ana Paula","apellido":"FernÃ¡ndez","email":"afernandez@districentral.com","telefono":"+54 351 400-4000"},{"id":5,"nombre":"Diego","apellido":"LÃ³pez","email":"dlopez@exportargentina.com","telefono":"+54 351 400-5000"},{"id":6,"nombre":"Patrici...` 

### âŒ [002] 
- **Endpoint**: GET /api-gestion/clientes/1
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âœ… [003] 
- **Endpoint**: GET /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK

### âŒ [004] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x61

### âœ… [005] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 409
- **Status obtenido**: 409
- **Resultado**: OK
- **Error**: Ya existe un cliente con ese correo electrónico

### âœ… [006] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 400
- **Status obtenido**: 400
- **Resultado**: OK
- **Error**: Debe ingresar un correo válido

### âŒ [007] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 400
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x6e

### âŒ [008] 
- **Endpoint**: PUT /api-gestion/clientes/1
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x72

### âœ… [009] 
- **Endpoint**: PUT /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK
- **Error**: Cliente no encontrado

### âŒ [010] 
- **Endpoint**: DELETE /api-gestion/clientes/1
- **Status esperado**: 204
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Cliente no encontrado con ID: 1

### âœ… [011] 
- **Endpoint**: DELETE /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK
- **Error**: Cliente no encontrado con ID: 999

### âœ… [012] 
- **Endpoint**: GET /api-gestion/contenedores
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":2,"codigoIdentificacion":"CONT-40-00002","peso":4097.4,"volumen":60.23,"cliente":{"id":2,"nombre":"MarÃ­a Elena","apellido":"MartÃ­nez","email":"mmartinez@transportesunidos.com","telefono":"+54 351 400-2000"}},{"id":3,"codigoIdentificacion":"REEF-20-00003","peso":3183.82,"volumen":28.1,"cliente":{"id":3,"nombre":"Roberto","apellido":"GÃ³mez","email":"rgomez@elprogreso.com","telefono":"+54 351 400-3000"}},{"id":4,"codigoIdentificacion":"REEF-40-00004","peso":4571.63,"volumen":62.26,"client...` 

### âœ… [013] 
- **Endpoint**: GET /api-gestion/contenedores/cliente/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âŒ [014] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-001
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âœ… [015] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-999
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK

### âŒ [016] 
- **Endpoint**: GET /api-gestion/contenedores/1/estado
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Contenedor no encontrado

### âŒ [017] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-001/estado
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Contenedor no encontrado con código: CONT-001

### âŒ [018] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: El cliente indicado no existe

### âŒ [019] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 409
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: El cliente indicado no existe

### âœ… [020] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK
- **Error**: El cliente indicado no existe

### âœ… [021] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 400
- **Status obtenido**: 400
- **Resultado**: OK
- **Error**: El peso del contenedor debe ser mayor a 0

### âŒ [022] 
- **Endpoint**: PUT /api-gestion/contenedores/1
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Contenedor no encontrado

### âŒ [023] 
- **Endpoint**: DELETE /api-gestion/contenedores/1
- **Status esperado**: 204
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Contenedor no encontrado con ID: 1

### âœ… [024] 
- **Endpoint**: GET /api-gestion/depositos
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":2,"nombre":"DepÃ³sito Zona Norte","direccion":"Ruta 9 Km 680, CÃ³rdoba","latitud":-31.35,"longitud":-64.15,"costoEstadiaXdia":120.0},{"id":3,"nombre":"DepÃ³sito Zona Sur","direccion":"Camino a Alta Gracia Km 12, CÃ³rdoba","latitud":-31.5,"longitud":-64.2,"costoEstadiaXdia":130.0},{"id":4,"nombre":"DepÃ³sito Zona Este","direccion":"Ruta E-55 Km 8, CÃ³rdoba","latitud":-31.4,"longitud":-64.1,"costoEstadiaXdia":125.0},{"id":5,"nombre":"DepÃ³sito Zona Oeste","direccion":"Av. de CircunvalaciÃ³n...` 

### âŒ [025] 
- **Endpoint**: GET /api-gestion/depositos/1
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âŒ [026] 
- **Endpoint**: POST /api-gestion/depositos
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x73

### âŒ [027] 
- **Endpoint**: PUT /api-gestion/depositos/1
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x73

### âŒ [028] 
- **Endpoint**: DELETE /api-gestion/depositos/1
- **Status esperado**: 204
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Depósito no encontrado con ID: 1

### âœ… [029] 
- **Endpoint**: GET /api-gestion/tarifas
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":2,"descripcion":"Tarifa Contenedor PequeÃ±o - Media Distancia","rangoPesoMin":0.0,"rangoPesoMax":3000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":35.0,"valor":4500.0},{"id":3,"descripcion":"Tarifa Contenedor PequeÃ±o - Larga Distancia","rangoPesoMin":0.0,"rangoPesoMax":3000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":35.0,"valor":7000.0},{"id":4,"descripcion":"Tarifa Contenedor Mediano - Corta Distancia","rangoPesoMin":3001.0,"rangoPesoMax":4500.0,"rangoVolumenMin":35.0,"rangoVolumenMax":70.0...` 

### âœ… [030] 
- **Endpoint**: GET /api-gestion/tarifas/aplicable?peso=500&volumen=2.5
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":2,"descripcion":"Tarifa Contenedor PequeÃ±o - Media Distancia","rangoPesoMin":0.0,"rangoPesoMax":3000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":35.0,"valor":4500.0}` 

### âŒ [031] 
- **Endpoint**: GET /api-gestion/tarifas/aplicable?peso=10000&volumen=50
- **Status esperado**: 404
- **Status obtenido**: 200
- **Resultado**: FAIL
- **Respuesta**: `{"id":15,"descripcion":"Tarifa Express - Cualquier TamaÃ±o","rangoPesoMin":0.0,"rangoPesoMax":50000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":500.0,"valor":15000.0}` 

### âŒ [032] 
- **Endpoint**: POST /api-gestion/tarifas
- **Status esperado**: 200
- **Status obtenido**: 400
- **Resultado**: FAIL
- **Error**: La descripción es obligatoria

### âŒ [033] 
- **Endpoint**: PUT /api-gestion/tarifas/1
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x6e

### âŒ [034] 
- **Endpoint**: DELETE /api-gestion/tarifas/1
- **Status esperado**: 204
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Tarifa no encontrada con ID: 1

### âœ… [035] 
- **Endpoint**: GET /api-flota/camiones
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"patente":"ABC123","nombreTransportista":"Carlos RodrÃ­guez","telefonoTransportista":"+54 351 111-2222","capacidadPeso":3500.0,"capacidadVolumen":25.0,"disponible":true,"consumoCombustibleKm":0.25,"costoPorKm":100.0},{"patente":"DEF456","nombreTransportista":"Laura MartÃ­nez","telefonoTransportista":"+54 351 333-4444","capacidadPeso":4000.0,"capacidadVolumen":28.0,"disponible":true,"consumoCombustibleKm":0.28,"costoPorKm":105.0},{"patente":"GHI789","nombreTransportista":"Roberto SÃ¡nchez","tel...` 

### âœ… [036] 
- **Endpoint**: GET /api-flota/camiones/disponibles
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"patente":"ABC123","nombreTransportista":"Carlos RodrÃ­guez","telefonoTransportista":"+54 351 111-2222","capacidadPeso":3500.0,"capacidadVolumen":25.0,"disponible":true,"consumoCombustibleKm":0.25,"costoPorKm":100.0},{"patente":"DEF456","nombreTransportista":"Laura MartÃ­nez","telefonoTransportista":"+54 351 333-4444","capacidadPeso":4000.0,"capacidadVolumen":28.0,"disponible":true,"consumoCombustibleKm":0.28,"costoPorKm":105.0},{"patente":"GHI789","nombreTransportista":"Roberto SÃ¡nchez","tel...` 

### âœ… [037] 
- **Endpoint**: GET /api-flota/camiones/AA123BB
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"patente":"AA123BB","nombreTransportista":"Transportes S.A. Renovado","telefonoTransportista":"3511234999","capacidadPeso":5500.0,"capacidadVolumen":32.0,"disponible":false,"consumoCombustibleKm":0.33,"costoPorKm":155.0}` 

### âœ… [038] 
- **Endpoint**: GET /api-flota/camiones/ZZ999ZZ
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK

### âœ… [039] 
- **Endpoint**: GET /api-flota/camiones/aptos?peso=2000&volumen=15
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"patente":"ABC123","nombreTransportista":"Carlos RodrÃ­guez","telefonoTransportista":"+54 351 111-2222","capacidadPeso":3500.0,"capacidadVolumen":25.0,"disponible":true,"consumoCombustibleKm":0.25,"costoPorKm":100.0},{"patente":"DEF456","nombreTransportista":"Laura MartÃ­nez","telefonoTransportista":"+54 351 333-4444","capacidadPeso":4000.0,"capacidadVolumen":28.0,"disponible":true,"consumoCombustibleKm":0.28,"costoPorKm":105.0},{"patente":"GHI789","nombreTransportista":"Roberto SÃ¡nchez","tel...` 

### âœ… [040] 
- **Endpoint**: POST /api-flota/camiones
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"patente":"BB456CC","nombreTransportista":"LogiTrans","telefonoTransportista":"3517654321","capacidadPeso":8000.0,"capacidadVolumen":40.0,"disponible":true,"consumoCombustibleKm":0.42,"costoPorKm":180.0}` 

### âœ… [041] 
- **Endpoint**: POST /api-flota/camiones
- **Status esperado**: 409
- **Status obtenido**: 409
- **Resultado**: OK
- **Error**: Ya existe un camión con esa patente

### âœ… [042] 
- **Endpoint**: POST /api-flota/camiones
- **Status esperado**: 400
- **Status obtenido**: 400
- **Resultado**: OK
- **Error**: La capacidad de peso debe ser mayor o igual a 0

### âœ… [043] 
- **Endpoint**: PUT /api-flota/camiones/AA123BB
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"patente":"AA123BB","nombreTransportista":"Transportes S.A. Renovado","telefonoTransportista":"3511234999","capacidadPeso":5500.0,"capacidadVolumen":32.0,"disponible":true,"consumoCombustibleKm":0.33,"costoPorKm":155.0}` 

### âœ… [044] 
- **Endpoint**: PATCH /api-flota/camiones/AA123BB/disponibilidad?disponible=false
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"patente":"AA123BB","nombreTransportista":"Transportes S.A. Renovado","telefonoTransportista":"3511234999","capacidadPeso":5500.0,"capacidadVolumen":32.0,"disponible":false,"consumoCombustibleKm":0.33,"costoPorKm":155.0}` 

### âœ… [045] 
- **Endpoint**: PATCH /api-flota/camiones/ZZ999ZZ/disponibilidad?disponible=true
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK
- **Error**: Camión no encontrado

### âŒ [046] 
- **Endpoint**: DELETE /api-flota/camiones/BB456CC
- **Status esperado**: 204
- **Status obtenido**: 200
- **Resultado**: FAIL

### âœ… [047] 
- **Endpoint**: GET /api-logistica/solicitudes
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":2,"numeroSeguimiento":"TRACK-2025-002","idContenedor":5,"idCliente":2,"origenDireccion":"CÃ³rdoba Capital, CÃ³rdoba, Argentina","origenLatitud":-31.4201,"origenLongitud":-64.1888,"destinoDireccion":"Mendoza, Mendoza, Argentina","destinoLatitud":-32.8895,"destinoLongitud":-68.8458,"estado":"BORRADOR","costoEstimado":null,"tiempoEstimado":null,"costoFinal":null,"tiempoReal":null},{"id":3,"numeroSeguimiento":"TRACK-2025-003","idContenedor":10,"idCliente":3,"origenDireccion":"Rosario, Santa F...` 

### âŒ [048] 
- **Endpoint**: GET /api-logistica/solicitudes/1
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âœ… [049] 
- **Endpoint**: GET /api-logistica/solicitudes/999
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK

### âŒ [050] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento/SEG-2024-001
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âœ… [051] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento/SEG-INVALIDO
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK

### âœ… [052] 
- **Endpoint**: GET /api-logistica/solicitudes/cliente/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âœ… [053] 
- **Endpoint**: GET /api-logistica/solicitudes/estado/PENDIENTE
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âŒ [054] 
- **Endpoint**: POST /api-logistica/solicitudes
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x6e

### âŒ [055] 
- **Endpoint**: POST /api-logistica/solicitudes
- **Status esperado**: 409
- **Status obtenido**: 400
- **Resultado**: FAIL
- **Error**: El estado es obligatorio

### âŒ [056] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 200
- **Status obtenido**: 400
- **Resultado**: FAIL
- **Error**: El peso del contenedor es obligatorio, El volumen del contenedor es obligatorio

### âŒ [057] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 200
- **Status obtenido**: 400
- **Resultado**: FAIL
- **Error**: El peso del contenedor es obligatorio, El volumen del contenedor es obligatorio

### âŒ [058] 
- **Endpoint**: PUT /api-logistica/solicitudes/1
- **Status esperado**: 200
- **Status obtenido**: 400
- **Resultado**: FAIL
- **Error**: El estado es obligatorio

### âŒ [059] 
- **Endpoint**: DELETE /api-logistica/solicitudes/1
- **Status esperado**: 204
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada con ID: 1

### âŒ [060] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x6e

### âŒ [061] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 404
- **Status obtenido**: 200
- **Resultado**: FAIL
- **Respuesta**: `{"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554,"tramos":[{"origenDescripcion":"Blvd. San Juan 296, X5000 CÃ³rdoba, Argentina","destinoDescripcion":"5012, X5000 CÃ³rdoba, Argentina","distanciaKm":6.194,"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554}]}` 

### âœ… [062] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554,"tramos":[{"origenDescripcion":"Blvd. San Juan 296, X5000 CÃ³rdoba, Argentina","destinoDescripcion":"5012, X5000 CÃ³rdoba, Argentina","distanciaKm":6.194,"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554}]}` 

### âŒ [063] 
- **Endpoint**: POST /api-logistica/solicitudes/1/asignar-ruta
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x6e

### âŒ [064] 
- **Endpoint**: POST /api-logistica/solicitudes/999/asignar-ruta
- **Status esperado**: 404
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada

### âŒ [065] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento-detallado/SEG-2024-001
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada

### âŒ [066] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento-detallado/SEG-INVALIDO
- **Status esperado**: 404
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada

### âœ… [067] 
- **Endpoint**: GET /api-logistica/solicitudes/pendientes
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"idSolicitud":2,"numeroSeguimiento":"TRACK-2025-002","idContenedor":5,"idCliente":2,"estado":"BORRADOR","ubicacionActual":"ORIGEN","descripcionUbicacion":"En punto de origen: CÃ³rdoba Capital, CÃ³rdoba, Argentina","tramoActual":null,"costoEstimado":null,"costoFinal":null},{"idSolicitud":3,"numeroSeguimiento":"TRACK-2025-003","idContenedor":10,"idCliente":3,"estado":"BORRADOR","ubicacionActual":"ORIGEN","descripcionUbicacion":"En punto de origen: Rosario, Santa Fe, Argentina","tramoActual":null...` 

### âœ… [068] 
- **Endpoint**: GET /api-logistica/solicitudes/pendientes?estado=PENDIENTE&idContenedor=1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âœ… [069] 
- **Endpoint**: GET /api-logistica/tramos
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âŒ [070] 
- **Endpoint**: GET /api-logistica/tramos/1
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âœ… [071] 
- **Endpoint**: GET /api-logistica/tramos/ruta/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âœ… [072] 
- **Endpoint**: GET /api-logistica/tramos/camion/AA123BB
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âœ… [073] 
- **Endpoint**: GET /api-logistica/tramos/estado/PENDIENTE
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âŒ [074] 
- **Endpoint**: POST /api-logistica/tramos
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x6e

### âŒ [075] 
- **Endpoint**: PUT /api-logistica/tramos/1
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: JSON parse error: Invalid UTF-8 middle byte 0x6e

### âŒ [076] 
- **Endpoint**: DELETE /api-logistica/tramos/1
- **Status esperado**: 204
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

### âŒ [077] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=AA123BB&peso=1500&volumen=2.5
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âœ… [078] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=ZZ999ZZ&peso=1500&volumen=2.5
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK
- **Error**: Tramo no encontrado

### âŒ [079] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=AA123BB&peso=100000&volumen=2.5
- **Status esperado**: 400
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âŒ [080] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âŒ [081] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 409
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âŒ [082] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 409
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âŒ [083] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âŒ [084] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 409
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âŒ [085] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=-5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 400
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado

### âœ… [086] 
- **Endpoint**: GET /api-logistica/rutas
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âŒ [087] 
- **Endpoint**: GET /api-logistica/rutas/1
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âœ… [088] 
- **Endpoint**: GET /api-logistica/rutas/solicitud/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âŒ [089] 
- **Endpoint**: POST /api-logistica/rutas
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: El recurso referenciado no existe

### âŒ [090] 
- **Endpoint**: PUT /api-logistica/rutas/1
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Ruta no encontrada

### âŒ [091] 
- **Endpoint**: DELETE /api-logistica/rutas/1
- **Status esperado**: 204
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Ruta no encontrada con ID: 1

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

### âœ… [094] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 403
- **Status obtenido**: 403
- **Resultado**: OK

### âœ… [095] 
- **Endpoint**: DELETE /api-logistica/solicitudes/1
- **Status esperado**: 403
- **Status obtenido**: 403
- **Resultado**: OK

### âŒ [096] 
- **Endpoint**: GET /api-gestion/actuator/health
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: No static resource actuator/health.

### âŒ [097] 
- **Endpoint**: GET /api-flota/actuator/metrics
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: No static resource actuator/metrics.

### âŒ [098] 
- **Endpoint**: GET /api-*/swagger-ui/index.html
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

### âœ… [099] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 400
- **Status obtenido**: 400
- **Resultado**: OK
- **Error**: El volumen del contenedor es obligatorio, El peso del contenedor es obligatorio, El email del cliente debe ser válido

### âŒ [100] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=10.5&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado


