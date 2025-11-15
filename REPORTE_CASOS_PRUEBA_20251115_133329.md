# Reporte de EjecuciÃ³n de Casos de Prueba - Sistema TPI
Fecha: 2025-11-15 13:33:29

## Resumen
- Total de casos: 100
- Exitosos: 64
- Fallidos: 36
- Tasa de Ã©xito: 64%

## Detalle de Casos

### âœ… [001] 
- **Endpoint**: GET /api-gestion/clientes
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":1,"nombre":"Juan Carlos","apellido":"RodrÃ­guez","email":"jrodriguez@logisticadelsur.com","telefono":"+54 351 400-1000"},{"id":2,"nombre":"MarÃ­a Elena","apellido":"MartÃ­nez","email":"mmartinez@transportesunidos.com","telefono":"+54 351 400-2000"},{"id":3,"nombre":"Roberto","apellido":"GÃ³mez","email":"rgomez@elprogreso.com","telefono":"+54 351 400-3000"},{"id":4,"nombre":"Ana Paula","apellido":"FernÃ¡ndez","email":"afernandez@districentral.com","telefono":"+54 351 400-4000"},{"id":5,"no...` 

### âœ… [002] 
- **Endpoint**: GET /api-gestion/clientes/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"nombre":"Juan Carlos","apellido":"RodrÃ­guez","email":"jrodriguez@logisticadelsur.com","telefono":"+54 351 400-1000"}` 

### âœ… [003] 
- **Endpoint**: GET /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK

### âœ… [004] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":23,"nombre":"Mar?a","apellido":"Gonz?lez","email":"maria@mail.com","telefono":"3517890123"}` 

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

### âœ… [007] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 400
- **Status obtenido**: 400
- **Resultado**: OK
- **Error**: El nombre es obligatorio

### âœ… [008] 
- **Endpoint**: PUT /api-gestion/clientes/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"nombre":"Juan Carlos","apellido":"P?rez","email":"juancarlos@mail.com","telefono":"3516789999"}` 

### âœ… [009] 
- **Endpoint**: PUT /api-gestion/clientes/999
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK
- **Error**: Cliente no encontrado con ID: 999

### âœ… [010] 
- **Endpoint**: DELETE /api-gestion/clientes/1
- **Status esperado**: 204
- **Status obtenido**: 204
- **Resultado**: OK
- **Respuesta**: `{"Content":[],"StatusCode":204,"StatusDescription":"No Content","RawContentStream":{"CanRead":true,"CanSeek":true,"CanTimeout":false,"CanWrite":true,"Length":0,"Capacity":10000,"Position":0,"ReadTimeout":null,"WriteTimeout":null},"RawContentLength":0,"RawContent":"HTTP/1.1 204 No Content\r\nVary: Origin,Access-Control-Request-Method,Access-Control-Request-Headers\r\nX-Content-Type-Options: nosniff\r\nX-XSS-Protection: 0\r\nPragma: no-cache\r\nX-Frame-Options: DENY\r\nReferrer-Policy: no-referrer...` 

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
- **Respuesta**: `[{"id":2,"codigoIdentificacion":"CONT-40-00002","peso":3734.54,"volumen":66.64,"cliente":{"id":2,"nombre":"MarÃ­a Elena","apellido":"MartÃ­nez","email":"mmartinez@transportesunidos.com","telefono":"+54 351 400-2000"}},{"id":3,"codigoIdentificacion":"REEF-20-00003","peso":2927.55,"volumen":27.79,"cliente":{"id":3,"nombre":"Roberto","apellido":"GÃ³mez","email":"rgomez@elprogreso.com","telefono":"+54 351 400-3000"}},{"id":4,"codigoIdentificacion":"REEF-40-00004","peso":4963.07,"volumen":58.89,"clie...` 

### âœ… [013] 
- **Endpoint**: GET /api-gestion/contenedores/cliente/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK

### âœ… [014] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-001
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":203,"codigoIdentificacion":"CONT-001","peso":1500.0,"volumen":2.5,"cliente":{"id":22,"nombre":"Juan","apellido":"Perez","email":"juan.perez@test.com","telefono":"+54-11-1234-5678"}}` 

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

### âœ… [017] 
- **Endpoint**: GET /api-gestion/contenedores/codigo/CONT-001/estado
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"idContenedor":203,"codigoIdentificacion":"CONT-001","peso":1500.0,"volumen":2.5,"cliente":{"id":22,"nombre":"Juan","apellido":"Perez","email":"juan.perez@test.com"},"solicitud":null,"ubicacionActual":"SIN_SOLICITUD","descripcionUbicacion":"El contenedor no tiene una solicitud de transporte activa","tramoActual":null}` 

### âŒ [018] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: El cliente indicado no existe

### âœ… [019] 
- **Endpoint**: POST /api-gestion/contenedores
- **Status esperado**: 409
- **Status obtenido**: 409
- **Resultado**: OK
- **Error**: Ya existe un contenedor con ese código de identificación

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
- **Respuesta**: `[{"id":1,"nombre":"DepÃ³sito Central CÃ³rdoba","direccion":"Av. CircunvalaciÃ³n Km 5, CÃ³rdoba","latitud":-31.4201,"longitud":-64.1888,"costoEstadiaXdia":150.0},{"id":2,"nombre":"DepÃ³sito Zona Norte","direccion":"Ruta 9 Km 680, CÃ³rdoba","latitud":-31.35,"longitud":-64.15,"costoEstadiaXdia":120.0},{"id":3,"nombre":"DepÃ³sito Zona Sur","direccion":"Camino a Alta Gracia Km 12, CÃ³rdoba","latitud":-31.5,"longitud":-64.2,"costoEstadiaXdia":130.0},{"id":4,"nombre":"DepÃ³sito Zona Este","direccion":"...` 

### âœ… [025] 
- **Endpoint**: GET /api-gestion/depositos/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"nombre":"DepÃ³sito Central CÃ³rdoba","direccion":"Av. CircunvalaciÃ³n Km 5, CÃ³rdoba","latitud":-31.4201,"longitud":-64.1888,"costoEstadiaXdia":150.0}` 

### âœ… [026] 
- **Endpoint**: POST /api-gestion/depositos
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":13,"nombre":"Dep?sito Norte","direccion":"Ruta 9 Km 5","latitud":-31.35,"longitud":-64.15,"costoEstadiaXdia":null}` 

### âœ… [027] 
- **Endpoint**: PUT /api-gestion/depositos/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"nombre":"Dep?sito Central Renovado","direccion":"Av. Principal 123","latitud":-31.4201,"longitud":-64.1888,"costoEstadiaXdia":null}` 

### âœ… [028] 
- **Endpoint**: DELETE /api-gestion/depositos/1
- **Status esperado**: 204
- **Status obtenido**: 204
- **Resultado**: OK
- **Respuesta**: `{"Content":[],"StatusCode":204,"StatusDescription":"No Content","RawContentStream":{"CanRead":true,"CanSeek":true,"CanTimeout":false,"CanWrite":true,"Length":0,"Capacity":10000,"Position":0,"ReadTimeout":null,"WriteTimeout":null},"RawContentLength":0,"RawContent":"HTTP/1.1 204 No Content\r\nVary: Origin,Access-Control-Request-Method,Access-Control-Request-Headers\r\nX-Content-Type-Options: nosniff\r\nX-XSS-Protection: 0\r\nPragma: no-cache\r\nX-Frame-Options: DENY\r\nReferrer-Policy: no-referrer...` 

### âœ… [029] 
- **Endpoint**: GET /api-gestion/tarifas
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":1,"descripcion":"Tarifa Contenedor PequeÃ±o - Corta Distancia","rangoPesoMin":0.0,"rangoPesoMax":3000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":35.0,"valor":3000.0},{"id":2,"descripcion":"Tarifa Contenedor PequeÃ±o - Media Distancia","rangoPesoMin":0.0,"rangoPesoMax":3000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":35.0,"valor":4500.0},{"id":3,"descripcion":"Tarifa Contenedor PequeÃ±o - Larga Distancia","rangoPesoMin":0.0,"rangoPesoMax":3000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":35.0,"v...` 

### âœ… [030] 
- **Endpoint**: GET /api-gestion/tarifas/aplicable?peso=500&volumen=2.5
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"descripcion":"Tarifa Contenedor PequeÃ±o - Corta Distancia","rangoPesoMin":0.0,"rangoPesoMax":3000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":35.0,"valor":3000.0}` 

### âŒ [031] 
- **Endpoint**: GET /api-gestion/tarifas/aplicable?peso=10000&volumen=50
- **Status esperado**: 404
- **Status obtenido**: 200
- **Resultado**: FAIL
- **Respuesta**: `{"id":15,"descripcion":"Tarifa Express - Cualquier TamaÃ±o","rangoPesoMin":0.0,"rangoPesoMax":50000.0,"rangoVolumenMin":0.0,"rangoVolumenMax":500.0,"valor":15000.0}` 

### âœ… [032] 
- **Endpoint**: POST /api-gestion/tarifas
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":17,"descripcion":"Tarifa Premium","rangoPesoMin":1000.0,"rangoPesoMax":5000.0,"rangoVolumenMin":5.0,"rangoVolumenMax":20.0,"valor":15000.0}` 

### âœ… [033] 
- **Endpoint**: PUT /api-gestion/tarifas/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"descripcion":"Tarifa Est?ndar Plus","rangoPesoMin":null,"rangoPesoMax":1000.0,"rangoVolumenMin":null,"rangoVolumenMax":5.0,"valor":5500.0}` 

### âœ… [034] 
- **Endpoint**: DELETE /api-gestion/tarifas/1
- **Status esperado**: 204
- **Status obtenido**: 204
- **Resultado**: OK
- **Respuesta**: `{"Content":[],"StatusCode":204,"StatusDescription":"No Content","RawContentStream":{"CanRead":true,"CanSeek":true,"CanTimeout":false,"CanWrite":true,"Length":0,"Capacity":10000,"Position":0,"ReadTimeout":null,"WriteTimeout":null},"RawContentLength":0,"RawContent":"HTTP/1.1 204 No Content\r\nVary: Origin,Access-Control-Request-Method,Access-Control-Request-Headers\r\nX-Content-Type-Options: nosniff\r\nX-XSS-Protection: 0\r\nPragma: no-cache\r\nX-Frame-Options: DENY\r\nReferrer-Policy: no-referrer...` 

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

### âŒ [037] 
- **Endpoint**: GET /api-flota/camiones/AA123BB
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL

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

### âŒ [041] 
- **Endpoint**: POST /api-flota/camiones
- **Status esperado**: 409
- **Status obtenido**: 200
- **Resultado**: FAIL
- **Respuesta**: `{"patente":"AA123BB","nombreTransportista":"Otro Transportista","telefonoTransportista":null,"capacidadPeso":6000.0,"capacidadVolumen":35.0,"disponible":true,"consumoCombustibleKm":0.38,"costoPorKm":160.0}` 

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

### âœ… [046] 
- **Endpoint**: DELETE /api-flota/camiones/BB456CC
- **Status esperado**: 204
- **Status obtenido**: 204
- **Resultado**: OK
- **Respuesta**: `{"Content":[],"StatusCode":204,"StatusDescription":"No Content","RawContentStream":{"CanRead":true,"CanSeek":true,"CanTimeout":false,"CanWrite":true,"Length":0,"Capacity":10000,"Position":0,"ReadTimeout":null,"WriteTimeout":null},"RawContentLength":0,"RawContent":"HTTP/1.1 204 No Content\r\nVary: Origin,Access-Control-Request-Method,Access-Control-Request-Headers\r\nX-Content-Type-Options: nosniff\r\nX-XSS-Protection: 0\r\nPragma: no-cache\r\nX-Frame-Options: DENY\r\nReferrer-Policy: no-referrer...` 

### âœ… [047] 
- **Endpoint**: GET /api-logistica/solicitudes
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `[{"id":1,"numeroSeguimiento":"TRACK-2025-001","idContenedor":1,"idCliente":1,"origenDireccion":"Puerto de Buenos Aires, Buenos Aires, Argentina","origenLatitud":-34.6037,"origenLongitud":-58.3816,"destinoDireccion":"Rosario, Santa Fe, Argentina","destinoLatitud":-32.9468,"destinoLongitud":-60.6393,"estado":"BORRADOR","costoEstimado":null,"tiempoEstimado":null,"costoFinal":null,"tiempoReal":null},{"id":2,"numeroSeguimiento":"TRACK-2025-002","idContenedor":5,"idCliente":2,"origenDireccion":"CÃ³rdo...` 

### âœ… [048] 
- **Endpoint**: GET /api-logistica/solicitudes/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"numeroSeguimiento":"TRACK-2025-001","idContenedor":1,"idCliente":1,"origenDireccion":"Puerto de Buenos Aires, Buenos Aires, Argentina","origenLatitud":-34.6037,"origenLongitud":-58.3816,"destinoDireccion":"Rosario, Santa Fe, Argentina","destinoLatitud":-32.9468,"destinoLongitud":-60.6393,"estado":"BORRADOR","costoEstimado":null,"tiempoEstimado":null,"costoFinal":null,"tiempoReal":null}` 

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
- **Respuesta**: `{"id":1,"numeroSeguimiento":"TRACK-2025-001","idContenedor":1,"idCliente":1,"origenDireccion":"Puerto de Buenos Aires, Buenos Aires, Argentina","origenLatitud":-34.6037,"origenLongitud":-58.3816,"destinoDireccion":"Rosario, Santa Fe, Argentina","destinoLatitud":-32.9468,"destinoLongitud":-60.6393,"estado":"BORRADOR","costoEstimado":null,"tiempoEstimado":null,"costoFinal":null,"tiempoReal":null}` 

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
- **Error**: Error al validar cliente con servicio-gestion en http://servicio-gestion:8081/api-gestion/clientes/1: 401  on GET request for "http://servicio-gestion:8081/api-gestion/clientes/1": [no body]

### âŒ [055] 
- **Endpoint**: POST /api-logistica/solicitudes
- **Status esperado**: 409
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Error al validar cliente con servicio-gestion en http://servicio-gestion:8081/api-gestion/clientes/1: 401  on GET request for "http://servicio-gestion:8081/api-gestion/clientes/1": [no body]

### âŒ [056] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Error al crear cliente en servicio-gestion en http://servicio-gestion:8081/api-gestion/clientes: 401  on POST request for "http://servicio-gestion:8081/api-gestion/clientes": [no body]

### âŒ [057] 
- **Endpoint**: POST /api-logistica/solicitudes/completa
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Error al validar cliente con servicio-gestion en http://servicio-gestion:8081/api-gestion/clientes/1: 401  on GET request for "http://servicio-gestion:8081/api-gestion/clientes/1": [no body]

### âœ… [058] 
- **Endpoint**: PUT /api-logistica/solicitudes/1
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"id":1,"numeroSeguimiento":"SEG-2024-001-MOD","idContenedor":1,"idCliente":1,"origenDireccion":"Origen Modificado","origenLatitud":-31.42,"origenLongitud":-64.19,"destinoDireccion":"Destino Modificado","destinoLatitud":-31.4,"destinoLongitud":-64.15,"estado":"PENDIENTE","costoEstimado":null,"tiempoEstimado":null,"costoFinal":null,"tiempoReal":null}` 

### âœ… [059] 
- **Endpoint**: DELETE /api-logistica/solicitudes/1
- **Status esperado**: 204
- **Status obtenido**: 204
- **Resultado**: OK
- **Respuesta**: `{"Content":[],"StatusCode":204,"StatusDescription":"No Content","RawContentStream":{"CanRead":true,"CanSeek":true,"CanTimeout":false,"CanWrite":true,"Length":0,"Capacity":10000,"Position":0,"ReadTimeout":null,"WriteTimeout":null},"RawContentLength":0,"RawContent":"HTTP/1.1 204 No Content\r\nVary: Origin,Access-Control-Request-Method,Access-Control-Request-Headers\r\nX-Content-Type-Options: nosniff\r\nX-XSS-Protection: 0\r\nPragma: no-cache\r\nX-Frame-Options: DENY\r\nReferrer-Policy: no-referrer...` 

### âœ… [060] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"costoEstimado":6220.01,"tiempoEstimadoHoras":0.1925,"tramos":[{"origenDescripcion":"Av. VÃ©lez Sarsfield 398, X5000 CÃ³rdoba, Argentina","destinoDescripcion":"Oncativo 1095, X5004 FHK, CÃ³rdoba, Argentina","distanciaKm":3.697,"costoEstimado":6220.01,"tiempoEstimadoHoras":0.1925}]}` 

### âŒ [061] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 404
- **Status obtenido**: 200
- **Resultado**: FAIL
- **Respuesta**: `{"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554,"tramos":[{"origenDescripcion":"Plazoleta Carlos Gardel, X5000KGH, Av. Marcelo T. de Alvear 465, X5000KGH CÃ³rdoba, Argentina","destinoDescripcion":"5012, X5000 CÃ³rdoba, Argentina","distanciaKm":6.194,"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554}]}` 

### âœ… [062] 
- **Endpoint**: POST /api-logistica/solicitudes/estimar-ruta
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554,"tramos":[{"origenDescripcion":"Plazoleta Carlos Gardel, X5000KGH, Av. Marcelo T. de Alvear 465, X5000KGH CÃ³rdoba, Argentina","destinoDescripcion":"5012, X5000 CÃ³rdoba, Argentina","distanciaKm":6.194,"costoEstimado":7044.02,"tiempoEstimadoHoras":0.26555555555555554}]}` 

### âŒ [063] 
- **Endpoint**: POST /api-logistica/solicitudes/1/asignar-ruta
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada con ID: 1

### âŒ [064] 
- **Endpoint**: POST /api-logistica/solicitudes/999/asignar-ruta
- **Status esperado**: 404
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada con ID: 999

### âŒ [065] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento-detallado/SEG-2024-001
- **Status esperado**: 200
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada con número de seguimiento: SEG-2024-001

### âŒ [066] 
- **Endpoint**: GET /api-logistica/solicitudes/seguimiento-detallado/SEG-INVALIDO
- **Status esperado**: 404
- **Status obtenido**: 500
- **Resultado**: FAIL
- **Error**: Solicitud no encontrada con número de seguimiento: SEG-INVALIDO

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
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: El recurso referenciado no existe

### âŒ [075] 
- **Endpoint**: PUT /api-logistica/tramos/1
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

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
- **Error**: Tramo no encontrado con ID: 1

### âœ… [078] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=ZZ999ZZ&peso=1500&volumen=2.5
- **Status esperado**: 404
- **Status obtenido**: 404
- **Resultado**: OK
- **Error**: Tramo no encontrado con ID: 1

### âŒ [079] 
- **Endpoint**: PUT /api-logistica/tramos/1/asignar-camion?patente=AA123BB&peso=100000&volumen=2.5
- **Status esperado**: 400
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

### âŒ [080] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

### âŒ [081] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 409
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

### âŒ [082] 
- **Endpoint**: PATCH /api-logistica/tramos/1/iniciar
- **Status esperado**: 409
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

### âŒ [083] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

### âŒ [084] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 409
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

### âŒ [085] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=-5.8&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 400
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1

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
- **Error**: Ruta no encontrada con ID: 1

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

### âŒ [094] 
- **Endpoint**: POST /api-gestion/clientes
- **Status esperado**: 403
- **Status obtenido**: 200
- **Resultado**: FAIL
- **Respuesta**: `{"id":24,"nombre":"Intruso","apellido":"Malicioso","email":"intruso@mail.com","telefono":null}` 

### âœ… [095] 
- **Endpoint**: DELETE /api-logistica/solicitudes/1
- **Status esperado**: 403
- **Status obtenido**: 403
- **Resultado**: OK

### âœ… [096] 
- **Endpoint**: GET /api-gestion/actuator/health
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"status":"UP","components":{"db":{"status":"UP","details":{"database":"PostgreSQL","validationQuery":"isValid()"}},"diskSpace":{"status":"UP","details":{"total":1081101176832,"free":1009334534144,"threshold":10485760,"path":"/app/.","exists":true}},"ping":{"status":"UP"},"ssl":{"status":"UP","details":{"validChains":"","invalidChains":""}}}}` 

### âœ… [097] 
- **Endpoint**: GET /api-flota/actuator/metrics
- **Status esperado**: 200
- **Status obtenido**: 200
- **Resultado**: OK
- **Respuesta**: `{"names":["application.ready.time","application.started.time","disk.free","disk.total","executor.active","executor.completed","executor.pool.core","executor.pool.max","executor.pool.size","executor.queue.remaining","executor.queued","hikaricp.connections","hikaricp.connections.acquire","hikaricp.connections.active","hikaricp.connections.creation","hikaricp.connections.idle","hikaricp.connections.max","hikaricp.connections.min","hikaricp.connections.pending","hikaricp.connections.timeout","hikari...` 

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
- **Error**: El email del cliente debe ser válido

### âŒ [100] 
- **Endpoint**: PATCH /api-logistica/tramos/1/finalizar?kmReales=10.5&costoKmCamion=150.0&consumoCamion=0.35
- **Status esperado**: 200
- **Status obtenido**: 404
- **Resultado**: FAIL
- **Error**: Tramo no encontrado con ID: 1


