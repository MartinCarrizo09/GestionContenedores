#!/usr/bin/env bash
# =============================================================================
# INSTRUCCIONES PARA PROBAR LA INTEGRACIÓN RESTCLIENT + GOOGLE MAPS
# =============================================================================
# Proyecto: GestionContenedores - TPI Backend Microservicios
# Fecha: 2025-11-04
# =============================================================================

# 📋 TABLA DE CONTENIDOS
# ─────────────────────────────────────────────────────────────────────────
# 1. Verificar Configuración
# 2. Compilar el Proyecto
# 3. Iniciar el Servicio
# 4. Pruebas con curl
# 5. Pruebas en Postman
# 6. Troubleshooting
# =============================================================================

# ============================================================================
# 1️⃣ VERIFICAR CONFIGURACIÓN
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "1️⃣ VERIFICAR CONFIGURACIÓN ANTES DE COMPILAR"
echo "═════════════════════════════════════════════════════════════════════"

echo ""
echo "✓ Verificar que existe: application.properties"
echo "  Ruta: servicio-logistica/src/main/resources/application.properties"
echo ""

echo "Contenido requerido:"
echo "───────────────────"
cat << 'EOF'
spring.application.name=servicio-logistica
spring.datasource.url=jdbc:h2:mem:logisticadb
spring.jpa.hibernate.ddl-auto=create-drop
server.port=8082
server.servlet.context-path=/api-logistica
google.maps.api.key=AIzaSyAUp0j1WFgacoQYTKhtPI-CF6Ld7a7jHSg
EOF

echo ""
echo "⚠️  IMPORTANTE:"
echo "   - Verificar que google.maps.api.key está presente"
echo "   - En producción: usar VARIABLE DE ENTORNO, no hardcodear"
echo ""

# ============================================================================
# 2️⃣ COMPILAR EL PROYECTO
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "2️⃣ COMPILAR EL PROYECTO"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

echo "Opción A: Compilar desde raíz (todos los servicios)"
echo "─────────────────────────────────────────────────"
cat << 'EOF'
cd C:\Users\Martin\Desktop\GestionContenedores
mvnw.cmd clean compile
EOF

echo ""
echo "Opción B: Compilar solo servicio-logistica"
echo "───────────────────────────────────────────"
cat << 'EOF'
cd C:\Users\Martin\Desktop\GestionContenedores\servicio-logistica
mvnw.cmd clean compile
EOF

echo ""
echo "Opción C: Compilar y empaquetar (JAR)"
echo "─────────────────────────────────────"
cat << 'EOF'
cd C:\Users\Martin\Desktop\GestionContenedores\servicio-logistica
mvnw.cmd clean package
EOF

echo ""
echo "✓ Si la compilación es EXITOSA, deberías ver:"
echo "  [INFO] BUILD SUCCESS"
echo ""
echo "⚠️  Si ves errores, ver sección 6️⃣ Troubleshooting"
echo ""

# ============================================================================
# 3️⃣ INICIAR EL SERVICIO
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "3️⃣ INICIAR EL SERVICIO LOGÍSTICA"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

echo "Opción A: Ejecutar desde Maven"
echo "─────────────────────────────"
cat << 'EOF'
cd C:\Users\Martin\Desktop\GestionContenedores\servicio-logistica
mvnw.cmd spring-boot:run
EOF

echo ""
echo "Opción B: Ejecutar JAR compilado"
echo "────────────────────────────────"
cat << 'EOF'
cd C:\Users\Martin\Desktop\GestionContenedores\servicio-logistica\target
java -jar servicio-logistica-0.0.1-SNAPSHOT.jar
EOF

echo ""
echo "✓ Esperar a ver en consola:"
echo "  [main] com.tpi.logistica.ServicioLogisticaApplication : Started..."
echo ""
echo "✓ El servidor estará disponible en: http://localhost:8082"
echo ""

# ============================================================================
# 4️⃣ PRUEBAS CON CURL (Command Line)
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "4️⃣ PRUEBAS CON CURL"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

echo "TEST 1: Calcular distancia entre dos ciudades"
echo "─────────────────────────────────────────────"
echo ""
echo "Comando:"
cat << 'EOF'
curl -X GET "http://localhost:8082/api-logistica/google-maps/distancia?origen=Cordoba,Argentina&destino=Buenos%20Aires,Argentina"
EOF

echo ""
echo "Respuesta esperada (200 OK):"
cat << 'EOF'
{
  "distanciaKm": 702.0,
  "distanciaTexto": "702 km",
  "duracionHoras": 7.5,
  "duracionTexto": "7 hours 30 mins",
  "origenDireccion": "Córdoba, Argentina",
  "destinoDireccion": "Buenos Aires, Argentina"
}
EOF

echo ""
echo "TEST 2: Calcular distancia por coordenadas"
echo "──────────────────────────────────────────"
echo ""
echo "Comando:"
cat << 'EOF'
curl -X GET "http://localhost:8082/api-logistica/google-maps/distancia-coords?lat1=-31.4167&lng1=-64.1833&lat2=-34.6037&lng2=-58.3816"
EOF

echo ""
echo "Respuesta esperada: Igual al TEST 1"
echo ""

echo "TEST 3: Error por parámetro faltante"
echo "────────────────────────────────────"
echo ""
echo "Comando:"
cat << 'EOF'
curl -X GET "http://localhost:8082/api-logistica/google-maps/distancia?origen=Cordoba"
EOF

echo ""
echo "Respuesta esperada (400 Bad Request):"
cat << 'EOF'
{
  "error": "Parámetros origen y destino son requeridos"
}
EOF

echo ""

# ============================================================================
# 5️⃣ PRUEBAS EN POSTMAN
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "5️⃣ PRUEBAS EN POSTMAN"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

echo "PASO 1: Abrir Postman (descargar si no tienes: https://postman.com)"
echo ""

echo "PASO 2: Crear nueva REQUEST"
echo "──────────────────────────"
cat << 'EOF'
• Method: GET
• URL: http://localhost:8082/api-logistica/google-maps/distancia
• Params:
  - origen = Córdoba, Argentina
  - destino = Buenos Aires, Argentina
EOF

echo ""
echo "PASO 3: Click en [Send]"
echo ""

echo "PASO 4: Ver respuesta en la pestaña [Body]"
cat << 'EOF'
{
  "distanciaKm": 702.0,
  ...
}
EOF

echo ""
echo "PASO 5: Guardar como colección para reusar"
echo "──────────────────────────────────────────"
echo "  • Click en [Save]"
echo "  • Nombre: GoogleMapsTests"
echo "  • Crear collection: GoogleMaps"
echo ""

# ============================================================================
# 6️⃣ TROUBLESHOOTING
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "6️⃣ TROUBLESHOOTING"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

echo "PROBLEMA: Error de compilación"
echo "───────────────────────────────"
echo "Solución:"
echo "1. Verificar Java version (debe ser 21+)"
echo "   cmd: java -version"
echo ""
echo "2. Limpiar caché de Maven"
echo "   mvnw.cmd clean"
echo ""
echo "3. Verificar pom.xml tenga <java.version>21</java.version>"
echo ""

echo "PROBLEMA: 'Connection refused' al llamar API"
echo "────────────────────────────────────────────"
echo "Solución:"
echo "1. Verificar que el servidor está corriendo"
echo "   • Ver 'Started ... in X seconds' en consola"
echo ""
echo "2. Verificar puerto (debe ser 8082)"
echo "   curl http://localhost:8082/actuator/health"
echo ""
echo "3. Si no inicia, ver errores en consola"
echo ""

echo "PROBLEMA: 'Error HTTP 403' en respuesta de Google Maps"
echo "───────────────────────────────────────────────────────"
echo "Solución:"
echo "1. Verificar API key en application.properties"
echo "2. Activar 'Distance Matrix API' en Google Cloud Console"
echo "3. Verificar quotas y límites de uso"
echo "4. Probar API key en: https://developers.google.com/maps/documentation/distance-matrix/start"
echo ""

echo "PROBLEMA: 'No se encontraron rutas entre origen y destino'"
echo "──────────────────────────────────────────────────────────"
echo "Solución:"
echo "1. Verificar que direcciones existen en Google Maps"
echo "2. Usar formato correcto: 'Ciudad, País'"
echo "3. Probar con ciudades conocidas"
echo "4. Ver logs en consola para más detalles"
echo ""

echo "PROBLEMA: Maven no encontrado"
echo "──────────────────────────────"
echo "Solución:"
echo "1. Usar Maven wrapper (mvnw.cmd) en lugar de 'mvn'"
echo "2. Estar en directorio correcto: servicio-logistica/"
echo ""

# ============================================================================
# 7️⃣ LOGS IMPORTANTES
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "7️⃣ QUÉ VER EN LOS LOGS"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

echo "Inicio exitoso:"
echo "──────────────"
cat << 'EOF'
[main] com.tpi.logistica.ServicioLogisticaApplication :
Started ServicioLogisticaApplication in 5.234 seconds (JVM running for 5.891)
EOF

echo ""
echo "Llamada a Google Maps (en la consola):"
echo "─────────────────────────────────────"
cat << 'EOF'
[http-nio-8082-exec-1] com.tpi.logistica.servicio.GoogleMapsService :
Llamando a Google Maps API: origen=Córdoba, Argentina, destino=Buenos Aires, Argentina
EOF

echo ""
echo "Resultado exitoso:"
echo "──────────────────"
cat << 'EOF'
[http-nio-8082-exec-1] com.tpi.logistica.servicio.GoogleMapsService :
Resultado exitoso: distancia=702.0km, duración=7.5h
EOF

echo ""
echo "Error HTTP:"
echo "───────────"
cat << 'EOF'
[http-nio-8082-exec-1] com.tpi.logistica.servicio.GoogleMapsService :
Error HTTP 403 al llamar Google Maps: Forbidden
EOF

echo ""

# ============================================================================
# 8️⃣ PRÓXIMOS PASOS
# ============================================================================

echo "═════════════════════════════════════════════════════════════════════"
echo "8️⃣ PRÓXIMOS PASOS"
echo "═════════════════════════════════════════════════════════════════════"
echo ""

echo "1. ✅ Probar endpoints con curl o Postman"
echo "2. ✅ Ver logs de consola"
echo "3. ✅ Integrar GoogleMapsService en tus servicios reales"
echo "4. ✅ Considerar agregar caché para mejora de rendimiento"
echo "5. ✅ En producción, usar variables de entorno para API key"
echo ""

echo "═════════════════════════════════════════════════════════════════════"
echo "FIN DE INSTRUCCIONES"
echo "═════════════════════════════════════════════════════════════════════"

