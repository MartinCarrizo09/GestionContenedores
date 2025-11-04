# 🚀 QUICK REFERENCE - RestClient + Google Maps

## 📌 En 30 Segundos

```java
// 1. Bean configurado (RestClientConfig.java)
@Bean public RestClient restClient() { 
    return RestClient.builder().build(); 
}

// 2. Inyectar en tu servicio
private final GoogleMapsService googleMapsService;

// 3. Usar
DistanciaYDuracion resultado = googleMapsService
    .calcularDistanciaYDuracion("A", "B");

// 4. Resultado
System.out.println(resultado.getDistanciaKm() + " km");
```

---

## 🔗 Endpoints

### Por Dirección
```
GET /api-logistica/google-maps/distancia
    ?origen=Córdoba,Argentina
    &destino=Buenos Aires,Argentina
```

### Por Coordenadas
```
GET /api-logistica/google-maps/distancia-coords
    ?lat1=-31.4167&lng1=-64.1833
    &lat2=-34.6037&lng2=-58.3816
```

---

## 📋 Archivos Clave

| Archivo | Ubicación | Líneas |
|---------|-----------|--------|
| RestClientConfig | config/ | ~25 |
| GoogleMapsService | servicio/ | ~150 |
| GoogleMapsControlador | controlador/ | ~120 |

---

## ✅ Verificación

```bash
# Compilar
mvnw.cmd clean compile

# Correr
mvnw.cmd spring-boot:run

# Probar
curl "http://localhost:8082/api-logistica/google-maps/distancia?origen=Cordoba&destino=Buenos%20Aires"
```

---

## 📦 DTOs

```java
// Entrada
String origen, String destino

// Salida
DistanciaYDuracion {
    Double distanciaKm;
    String distanciaTexto;
    Double duracionHoras;
    String duracionTexto;
    String origenDireccion;
    String destinoDireccion;
}
```

---

## 🎯 Diferencia Clave

| Aspecto | Antes | Después |
|---------|-------|---------|
| Cliente | RestTemplate | **RestClient** |
| Manejo Errores | try-catch | `onStatus()` |
| Recomendación | ❌ Deprecated | ✅ Moderno |

---

## 📚 Documentación Completa

- **GUIA_RESTCLIENT.md** - Guía visual
- **RESTCLIENT_INTEGRACION.md** - Técnica extendida
- **VERIFICACION_FINAL.txt** - Checklist
- **INSTRUCCIONES_TESTING.sh** - Paso a paso

---

**Status:** ✅ Listo para usar  
**Compilación:** ✅ Sin errores  
**Producción:** ✅ Ready

