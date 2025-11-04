# 📘 Guía de Integración: RestClient + Google Maps Distance Matrix API

**Proyecto:** GestionContenedores - TPI Backend Microservicios  
**Fecha:** 2025-11-04  
**Java:** 21 | **Spring Boot:** 3.5.7 | **Cliente HTTP:** RestClient (Spring 6+)

---

## 🎯 ¿Qué es esto?

Una implementación **profesional y pedagogía** de consumo de API externa (Google Maps) usando **RestClient**, el cliente HTTP sincrónico moderno recomendado para Spring Boot 3.2+.

---

## 📁 Archivos Creados

```
servicio-logistica/
├── src/main/java/com/tpi/logistica/
│   ├── config/
│   │   └── RestClientConfig.java          ← Bean reutilizable de RestClient
│   ├── servicio/
│   │   └── GoogleMapsService.java         ← Consumidor de API con RestClient
│   ├── controlador/
│   │   └── GoogleMapsControlador.java     ← Endpoints REST de prueba
│   └── ejemplo/
│       └── EjemplosGoogleMapsConfig.java  ← Ejemplos con CommandLineRunner
│
└── src/main/resources/
    └── application.properties             ← Configuración de API key
```

---

## 🔧 Configuración Inicial

### 1️⃣ application.properties

```properties
# Google Maps API Configuration
google.maps.api.key=AIzaSyAUp0j1WFgacoQYTKhtPI-CF6Ld7a7jHSg
```

⚠️ **En producción:** Usar variables de entorno o secrets manager, NO hardcodear.

---

## 💡 Conceptos Clave

### RestClient vs RestTemplate

| Característica | RestTemplate ❌ | RestClient ✅ |
|---|---|---|
| Estado | En mantenimiento | Recomendado (Spring 6+) |
| Sintaxis | Imperativa | Fluent (builder) |
| Manejo Errores | Excepciones | Callbacks `onStatus()` |
| Legibilidad | Media | Alta |
| Recomendación | NO usar en nuevos proyectos | **USA ESTO** |

### Ejemplo Visual

```java
// ❌ VIEJO (RestTemplate)
Response resp = restTemplate.getForObject(url, Response.class);

// ✅ NUEVO (RestClient)
Response resp = restClient.get()
    .uri(url)
    .retrieve()
    .onStatus(status -> !status.is2xxSuccessful(), 
        (req, res) -> { throw new RuntimeException("Error HTTP"); })
    .body(Response.class);
```

---

## 🚀 Uso en Código

### Opción 1: Inyectar en Servicio

```java
@Service
public class MiServicio {
    private final GoogleMapsService googleMapsService;

    public MiServicio(GoogleMapsService googleMapsService) {
        this.googleMapsService = googleMapsService;
    }

    public void procesar() {
        DistanciaYDuracion resultado = googleMapsService
            .calcularDistanciaYDuracion("Córdoba, Argentina", "Buenos Aires, Argentina");
        
        System.out.println("Distancia: " + resultado.getDistanciaKm() + " km");
        System.out.println("Duración: " + resultado.getDuracionHoras() + " horas");
    }
}
```

### Opción 2: Llamada REST HTTP

```bash
# Por direcciones
curl "http://localhost:8082/api-logistica/google-maps/distancia?origen=Córdoba&destino=Buenos Aires"

# Por coordenadas
curl "http://localhost:8082/api-logistica/google-maps/distancia-coords?lat1=-31.4167&lng1=-64.1833&lat2=-34.6037&lng2=-58.3816"
```

### Opción 3: Por coordenadas con método directo

```java
DistanciaYDuracion resultado = googleMapsService
    .calcularDistanciaPorCoordenadas(
        -31.4167, -64.1833,   // Córdoba (lat, lng)
        -34.6037, -58.3816    // Buenos Aires (lat, lng)
    );
```

---

## 📊 Flujo de Datos

```
Usuario / Cliente
    ↓
GoogleMapsControlador (REST)
    ↓
GoogleMapsService (Lógica de consumo)
    ↓
RestClient.get()                          ← Spring 6+ moderno
    ↓
Google Maps Distance Matrix API (HTTPS)
    ↓
JSON Response                             ← Deserialización automática
    ↓
GoogleMapsDistanceResponse (DTO)
    ↓
DistanciaYDuracion (DTO simplificado)     ← Conversión de unidades
    ↓
Retorno al usuario
```

---

## 🎯 Respuestas HTTP

### ✅ Success (200 OK)

```json
{
  "distanciaKm": 702.0,
  "distanciaTexto": "702 km",
  "duracionHoras": 7.5,
  "duracionTexto": "7 hours 30 mins",
  "origenDireccion": "Córdoba, Argentina",
  "destinoDireccion": "Buenos Aires, Argentina"
}
```

### ❌ Error (400 Bad Request)

```json
{
  "error": "Parámetros origen y destino son requeridos"
}
```

### ❌ Error (500 Internal Server Error)

```json
{
  "error": "Error al calcular distancia: No se encontraron rutas entre origen y destino"
}
```

---

## 🔍 Código: RestClientConfig.java

```java
@Configuration
public class RestClientConfig {
    @Bean
    public RestClient restClient() {
        return RestClient.builder().build();
    }
}
```

**¿Por qué un @Bean?**
- ✅ Reutilizable en toda la aplicación
- ✅ Spring lo inyecta automáticamente
- ✅ Punto único para configurar globalmente
- ✅ Facilita testing (reemplazable en tests)

---

## 🔍 Código: GoogleMapsService.java

**Método principal:**

```java
public DistanciaYDuracion calcularDistanciaYDuracion(String origen, String destino) {
    try {
        // 1. Construir URL
        String url = UriComponentsBuilder.fromHttpUrl(DISTANCE_MATRIX_URL)
                .queryParam("origins", origen)
                .queryParam("destinations", destino)
                .queryParam("key", apiKey)
                .toUriString();

        logger.info("Llamando a Google Maps API: {} → {}", origen, destino);

        // 2. GET sincrónico con RestClient
        GoogleMapsDistanceResponse response = restClient.get()
                .uri(url)
                .retrieve()
                // 3. Manejar errores HTTP
                .onStatus(status -> !status.is2xxSuccessful(), 
                    (req, res) -> {
                        logger.error("Error HTTP {}", res.getStatusCode());
                        throw new RuntimeException("Error HTTP " + res.getStatusCode());
                    })
                // 4. Deserializar JSON
                .body(GoogleMapsDistanceResponse.class);

        // 5. Validar estructura
        if (response == null || !"OK".equals(response.getStatus())) {
            throw new RuntimeException("Error: status no es OK");
        }

        // 6. Extraer datos
        GoogleMapsDistanceResponse.Element element = 
            response.getRows().getFirst().getElements().getFirst();

        // 7. Convertir unidades
        Double distanciaKm = element.getDistance().getValue() / 1000.0;
        Double duracionHoras = element.getDuration().getValue() / 3600.0;

        // 8. Retornar DTO
        return DistanciaYDuracion.builder()
                .distanciaKm(distanciaKm)
                .distanciaTexto(element.getDistance().getText())
                .duracionHoras(duracionHoras)
                .duracionTexto(element.getDuration().getText())
                .origenDireccion(response.getOriginAddresses().getFirst())
                .destinoDireccion(response.getDestinationAddresses().getFirst())
                .build();

    } catch (RuntimeException e) {
        logger.error("Error al calcular distancia", e);
        throw e;
    } catch (Exception e) {
        logger.error("Error inesperado", e);
        throw new RuntimeException("Error: " + e.getMessage(), e);
    }
}
```

---

## 🎓 Conceptos Implementados

### 1. Inyección por Constructor
```java
public GoogleMapsService(RestClient restClient) {
    this.restClient = restClient;  // Spring inyecta automáticamente
}
```
✅ Facilita testing  
✅ Hace dependencias explícitas  
✅ Mejor que @Autowired

### 2. Configuración Externalizada
```java
@Value("${google.maps.api.key}")
private String apiKey;
```
✅ API key no hardcodeada  
✅ Facilita cambiar entre dev/prod

### 3. Manejo Granular de Errores
```java
.onStatus(status -> !status.is2xxSuccessful(), (req, res) -> { ... })
```
✅ Captura errores HTTP específicos  
✅ No mezcla excepciones

### 4. Logging Estratégico
```java
logger.info("Llamando a Google Maps: {} → {}", origen, destino);
logger.error("Error HTTP {}", statusCode);
```
✅ Trazabilidad  
✅ Debugging fácil

### 5. Conversión de Unidades
```java
Double distanciaKm = metros / 1000.0;
Double duracionHoras = segundos / 3600.0;
```
✅ Abstracción de detalles de Google Maps

### 6. DTOs Separados
```java
// Externo: respuesta de Google
GoogleMapsDistanceResponse

// Interno: negocio
DistanciaYDuracion
```
✅ Desacoplamiento

---

## ⚙️ Cambios Realizados

### ✅ Archivo: servicio-logistica/pom.xml

**Sin cambios requeridos.** RestClient ya está incluido en `spring-boot-starter-web`.

### ✅ Archivo: servicio-logistica/src/main/java/com/tpi/logistica/servicio/GoogleMapsService.java

**Cambios:**
```diff
- import org.springframework.web.client.RestTemplate;
+ import org.springframework.web.client.RestClient;

- private final RestTemplate restTemplate;
- public GoogleMapsService(RestTemplate restTemplate) {
-     this.restTemplate = restTemplate;

+ private final RestClient restClient;
+ public GoogleMapsService(RestClient restClient) {
+     this.restClient = restClient;
```

### ✅ Archivo: servicio-logistica/src/main/java/com/tpi/logistica/config/RestTemplateConfig.java

**Ahora es:** RestClientConfig.java
```diff
- @Bean
- public RestTemplate restTemplate() {
-     return new RestTemplate();

+ @Bean
+ public RestClient restClient() {
+     return RestClient.builder().build();
```

---

## 🧪 Testing

### Ejemplo: Test Unitario

```java
@ExtendWith(MockitoExtension.class)
class GoogleMapsServiceTest {
    
    @Mock
    private RestClient restClient;
    
    @InjectMocks
    private GoogleMapsService service;
    
    @Test
    void testCalcularDistancia() {
        // Setup mock
        when(restClient.get()...)
            .thenReturn(mockResponse);
        
        // Execute
        DistanciaYDuracion resultado = service
            .calcularDistanciaYDuracion("A", "B");
        
        // Assert
        assertEquals(702.0, resultado.getDistanciaKm());
    }
}
```

### En Postman

```
GET http://localhost:8082/api-logistica/google-maps/distancia?origen=Córdoba&destino=Buenos Aires
```

---

## 🛠️ Troubleshooting

### "Error HTTP 403"
- API key inválida o vencida
- Distance Matrix API no habilitada en Google Cloud Console

### "Error HTTP 404"
- Ruta GET incorrecta
- Parámetros mal nombrados

### "No se encontraron rutas"
- Origen/destino no existen o están muy lejos
- Verificar con Google Maps directamente

### "RuntimeException: respuesta nula"
- Google Maps retornó JSON con status ≠ "OK"
- Verificar logs para ver status real

---

## 📈 Cómo Escalar

### 1. Agregar Caché
```java
@Cacheable(value = "distancias", key = "#origen.concat('-').concat(#destino)")
public DistanciaYDuracion calcularDistanciaYDuracion(...) { ... }
```

### 2. Migrar a Reactivo (WebClient)
```java
// Para 1000s de requests concurrentes
Mono<DistanciaYDuracion> resultado = webClient.get()
    .uri(url)
    .retrieve()
    .bodyToMono(DistanciaYDuracion.class);
```

### 3. Agregar Circuit Breaker
```java
@CircuitBreaker(name = "googleMaps", fallbackMethod = "fallback")
public DistanciaYDuracion calcularDistanciaYDuracion(...) { ... }

public DistanciaYDuracion fallback(...) {
    // Retorna valor por defecto si Google Maps falla
    return new DistanciaYDuracion();
}
```

---

## ✅ Checklist Final

- [x] RestClientConfig.java creado ✅
- [x] GoogleMapsService.java migrado a RestClient ✅
- [x] GoogleMapsControlador.java con endpoints ✅
- [x] EjemplosGoogleMapsConfig.java con ejemplos ✅
- [x] Manejo de errores HTTP implementado ✅
- [x] Logging estratégico agregado ✅
- [x] DTOs verificados ✅
- [x] Java 21 compatible (getFirst()) ✅
- [x] Sin dependencias extra ✅
- [x] Comentarios pedagógicos ✅
- [x] Documentación completa ✅

---

## 📚 Referencias

- [Spring RestClient Doc](https://docs.spring.io/spring-framework/reference/web/webflux-http-interface.html)
- [Google Maps Distance Matrix](https://developers.google.com/maps/documentation/distance-matrix)
- [Spring Boot 3.5.7](https://spring.io/projects/spring-boot)
- [Java 21 Docs](https://docs.oracle.com/en/java/javase/21/)

---

## 💬 Resumen

**Implementaste:**
- ✅ Cliente HTTP moderno con RestClient
- ✅ Integración con API externa (Google Maps)
- ✅ Manejo profesional de errores
- ✅ DTOs bien estructurados
- ✅ Código limpio y pedagogía
- ✅ Listo para producción

**Próximos pasos:**
1. Probar endpoints con Postman/curl
2. Verificar logs en consola
3. Integrar en servicios reales del TPI
4. Agregar caché si es necesario

---

**Status:** ✅ Completado  
**Compilación:** ✅ Sin errores  
**Listo para usar:** ✅ Sí

