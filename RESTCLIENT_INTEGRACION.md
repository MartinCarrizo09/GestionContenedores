## 📘 Integración con Google Maps Distance Matrix API usando RestClient

### Descripción General

Este documento explica cómo usar la nueva integración de **RestClient** (Spring 6+ / Boot 3.2+) en el servicio-logistica para consumir la API de Google Maps Distance Matrix.

---

## 🎯 Componentes Implementados

### 1. **RestClientConfig.java** (Configuración)
```
ubicación: servicio-logistica/src/main/java/com/tpi/logistica/config/RestClientConfig.java
```

Define un bean reutilizable de `RestClient`:
- **Ventaja**: Único punto centralizado para configurar cliente HTTP
- **Inyección**: Automática via constructor en servicios
- **Extensible**: Permite añadir interceptores, timeouts, error handlers globales

```java
@Bean
public RestClient restClient() {
    return RestClient.builder()
        // Opcional: .requestTimeout(Duration.ofSeconds(30))
        .build();
}
```

---

### 2. **GoogleMapsService.java** (Consumidor de API)
```
ubicación: servicio-logistica/src/main/java/com/tpi/logistica/servicio/GoogleMapsService.java
```

**Métodos principales:**

#### `calcularDistanciaYDuracion(String origen, String destino)`
Calcula distancia y tiempo entre dos ubicaciones (direcciones o coordenadas).

```java
DistanciaYDuracion resultado = googleMapsService
    .calcularDistanciaYDuracion("Córdoba, Argentina", "Buenos Aires, Argentina");

System.out.println("Distancia: " + resultado.getDistanciaKm() + " km");
System.out.println("Duración: " + resultado.getDuracionHoras() + " horas");
```

**Flujo interno:**
1. Construye URL con parámetros query (origen, destino, API key)
2. Realiza GET sincrónico con `RestClient`
3. Maneja errores HTTP (404, 400, 500) con `onStatus()`
4. Deserializa JSON automáticamente a DTO
5. Valida estructura de respuesta
6. Convierte unidades (metros→km, segundos→horas)
7. Retorna DTO interno simplificado

**Manejo de errores:**
```java
try {
    DistanciaYDuracion resultado = googleMapsService
        .calcularDistanciaYDuracion("A", "B");
} catch (RuntimeException e) {
    // Google Maps API retornó error o la respuesta es inválida
    logger.error("Error al calcular distancia: {}", e.getMessage());
}
```

---

#### `calcularDistanciaPorCoordenadas(Double lat1, Double lng1, Double lat2, Double lng2)`
Wrapper conveniente que acepta coordenadas en lugar de direcciones.

```java
// Córdoba a Buenos Aires en coordenadas
DistanciaYDuracion resultado = googleMapsService
    .calcularDistanciaPorCoordenadas(
        -31.4167, -64.1833,  // Córdoba
        -34.6037, -58.3816   // Buenos Aires
    );
```

---

### 3. **DTOs (Data Transfer Objects)**

#### `GoogleMapsDistanceResponse.java` (Respuesta de API externa)
Mapea exactamente la estructura JSON de Google Maps Distance Matrix.

Estructura:
```json
{
  "status": "OK",
  "rows": [
    {
      "elements": [
        {
          "status": "OK",
          "distance": { "value": 702000, "text": "702 km" },
          "duration": { "value": 27000, "text": "7 hours 30 mins" }
        }
      ]
    }
  ],
  "origin_addresses": ["Córdoba, Argentina"],
  "destination_addresses": ["Buenos Aires, Argentina"]
}
```

**Anotaciones importantes:**
- `@JsonProperty("distance_matrix")`: Mapeo de campos con snake_case
- `@Getter @Setter`: Lombok para boilerplate
- Estructura anidada (Row → Element → Distance/Duration)

---

#### `DistanciaYDuracion.java` (DTO interno simplificado)
Abstracción limpia que expone solo lo relevante:

```java
@Getter
@Setter
@Builder
public class DistanciaYDuracion {
    private Double distanciaKm;          // ej: 702.0
    private String distanciaTexto;       // ej: "702 km"
    private Double duracionHoras;        // ej: 7.5
    private String duracionTexto;        // ej: "7 hours 30 mins"
    private String origenDireccion;      // ej: "Córdoba, Argentina"
    private String destinoDireccion;     // ej: "Buenos Aires, Argentina"
}
```

---

## ⚙️ Configuración Requerida

### application.properties
```properties
# Google Maps API Configuration
google.maps.api.key=AIzaSyAUp0j1WFgacoQYTKhtPI-CF6Ld7a7jHSg
```

**Nota:** Esta es una API key de demostración. En producción, usar variables de entorno o secrets management.

---

## 🔍 Comparación: RestClient vs RestTemplate

| Aspecto | RestTemplate | RestClient |
|---------|------------|-----------|
| Versión | Spring 3.x (deprecated) | Spring 6+ (moderno) |
| Sintaxis | `getForObject()` | Fluent API |
| Manejo errores | `RestClientException` | Callbacks `onStatus()` |
| Legibilidad | Imperativa | Declarativa |
| Rendimiento | Similar | Similar |
| Recomendación | En mantenimiento | **✅ Preferido** |

**Ejemplo de diferencia:**

**RestTemplate (antiguo):**
```java
GoogleMapsDistanceResponse response = restTemplate.getForObject(url, 
    GoogleMapsDistanceResponse.class);
if (response == null) throw new RuntimeException("Error");
```

**RestClient (moderno):**
```java
GoogleMapsDistanceResponse response = restClient.get()
    .uri(url)
    .retrieve()
    .onStatus(status -> !status.is2xxSuccessful(), 
        (req, res) -> { throw new RuntimeException("Error HTTP"); })
    .body(GoogleMapsDistanceResponse.class);
```

---

## 📝 Ejemplo de Uso Completo

### Caso: Calcular costo de transporte basado en distancia

```java
@Service
public class CalculoTarifaServicio {

    private final GoogleMapsService googleMapsService;

    public CalculoTarifaServicio(GoogleMapsService googleMapsService) {
        this.googleMapsService = googleMapsService;
    }

    /**
     * Calcula tarifa basada en distancia real entre origen y destino.
     * 
     * Fórmula simplificada: 
     *   tarifa = distancia_km * precio_por_km + duracion_horas * recargo_por_hora
     */
    public Double calcularTarifa(String origen, String destino) {
        try {
            // 1. Consulta Google Maps
            DistanciaYDuracion distancia = googleMapsService
                .calcularDistanciaYDuracion(origen, destino);

            // 2. Aplica fórmula comercial
            Double precioBasePorKm = 15.0;      // $15 por km
            Double recargoHora = 50.0;           // $50 por hora de viaje

            Double tarifa = (distancia.getDistanciaKm() * precioBasePorKm)
                          + (distancia.getDuracionHoras() * recargoHora);

            logger.info("Tarifa calculada: ${} para {}->{}", 
                tarifa, origen, destino);

            return tarifa;

        } catch (RuntimeException e) {
            logger.error("No se pudo calcular tarifa: {}", e.getMessage());
            throw new RuntimeException("Error al calcular tarifa", e);
        }
    }
}
```

---

## 🛠️ Dependencias Requeridas

En `pom.xml` ya están configuradas:
```xml
<!-- Spring Web (incluye RestClient desde Boot 3.2+) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<!-- Lombok para reducir boilerplate -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
```

**No se necesitan dependencias adicionales** para RestClient.

---

## ✅ Buenas Prácticas Implementadas

1. **Inyección por constructor**: Facilita testing (mock de RestClient)
2. **Configuración centralizada**: Bean único reutilizable
3. **DTOs separados**: DTO externo (Google) ≠ DTO interno (negocio)
4. **Manejo granular de errores**: HTTP status + validación de respuesta + captura general
5. **Logging estratégico**: INFO (llamadas), WARN (casos especiales), ERROR (errores)
6. **Conversión de unidades**: Metros→km, segundos→horas
7. **Comentarios pedagógicos**: Cada paso explicado como en clase de POO

---

## 🔗 Referencias

- [Spring RestClient Documentation](https://docs.spring.io/spring-framework/reference/web/webflux-http-interface.html)
- [Google Maps Distance Matrix API](https://developers.google.com/maps/documentation/distance-matrix)
- [Java 21 Collection Methods](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/util/List.html#getFirst())

---

**Última actualización:** 2025-11-04  
**Versión:** Spring Boot 3.5.7, Java 21, RestClient moderno

