package com.tpi.logistica.ejemplo;

import com.tpi.logistica.dto.googlemaps.DistanciaYDuracion;
import com.tpi.logistica.servicio.GoogleMapsService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Configuración de ejemplo para pruebas de integración con Google Maps.
 *
 * Esta clase implementa CommandLineRunner para ejecutar ejemplos
 * automáticamente cuando inicia la aplicación (solo en desarrollo).
 *
 * Para activar estos ejemplos, descomenta el método ejemplosGoogleMaps()
 *
 * Propósito educativo: Demostrar cómo usar:
 * - RestClient inyectado en servicios
 * - Manejo de respuestas HTTP
 * - Conversión de DTOs
 * - Logging y trazabilidad
 */
@Configuration
public class EjemplosGoogleMapsConfig {

    private static final Logger logger = LoggerFactory.getLogger(EjemplosGoogleMapsConfig.class);

    /**
     * NOTA: Este CommandLineRunner está comentado por defecto para evitar
     * llamadas innecesarias a la API de Google Maps durante inicio.
     *
     * Para activar los ejemplos:
     * 1. Descomenta el @Bean
     * 2. Reinicia la aplicación
     * 3. Verás los logs en consola con los resultados
     */
    /*
    @Bean
    public CommandLineRunner ejemplosGoogleMaps(GoogleMapsService googleMapsService) {
        return args -> {
            logger.info("\n\n╔════════════════════════════════════════════════════════════════╗");
            logger.info("║     EJEMPLOS DE INTEGRACIÓN CON GOOGLE MAPS REST CLIENT    ║");
            logger.info("╚════════════════════════════════════════════════════════════════╝\n");

            try {
                // ========== EJEMPLO 1: Distancia entre ciudades argentinas ==========
                logger.info("📍 EJEMPLO 1: Distancia entre direcciones");
                logger.info("─────────────────────────────────────────────────────────────────");

                DistanciaYDuracion distancia1 = googleMapsService
                    .calcularDistanciaYDuracion(
                        "Córdoba, Argentina",
                        "Buenos Aires, Argentina"
                    );

                logger.info("Origen: {}", distancia1.getOrigenDireccion());
                logger.info("Destino: {}", distancia1.getDestinoDireccion());
                logger.info("Distancia: {} ({} km)",
                    distancia1.getDistanciaTexto(),
                    String.format("%.2f", distancia1.getDistanciaKm()));
                logger.info("Duración: {} ({} horas)",
                    distancia1.getDuracionTexto(),
                    String.format("%.2f", distancia1.getDuracionHoras()));

                // ========== EJEMPLO 2: Distancia por coordenadas ==========
                logger.info("\n📍 EJEMPLO 2: Distancia usando coordenadas");
                logger.info("─────────────────────────────────────────────────────────────────");

                // Coordenadas: Córdoba → La Plata
                DistanciaYDuracion distancia2 = googleMapsService
                    .calcularDistanciaPorCoordenadas(
                        -31.4167, -64.1833,   // Córdoba
                        -34.9215, -57.9545    // La Plata
                    );

                logger.info("Origen: {}", distancia2.getOrigenDireccion());
                logger.info("Destino: {}", distancia2.getDestinoDireccion());
                logger.info("Distancia: {} ({} km)",
                    distancia2.getDistanciaTexto(),
                    String.format("%.2f", distancia2.getDistanciaKm()));

                // ========== EJEMPLO 3: Uso en cálculo de tarifa comercial ==========
                logger.info("\n📍 EJEMPLO 3: Cálculo de tarifa basado en distancia");
                logger.info("─────────────────────────────────────────────────────────────────");

                Double precioKm = 15.0;          // $15 por km
                Double recargoHora = 50.0;       // $50 por hora

                Double tarifa = (distancia1.getDistanciaKm() * precioKm)
                              + (distancia1.getDuracionHoras() * recargoHora);

                logger.info("Tarifa por km: ${}", precioKm);
                logger.info("Recargo por hora: ${}", recargoHora);
                logger.info("Subtotal km: ${}", String.format("%.2f", distancia1.getDistanciaKm() * precioKm));
                logger.info("Subtotal horas: ${}", String.format("%.2f", distancia1.getDuracionHoras() * recargoHora));
                logger.info("TARIFA TOTAL: ${}", String.format("%.2f", tarifa));

                logger.info("\n✅ Todos los ejemplos ejecutados exitosamente\n");

            } catch (RuntimeException e) {
                logger.error("❌ Error durante ejemplos: {}", e.getMessage());
                logger.error("Verificá que:", e);
                logger.error("1. La API key de Google Maps está configurada en application.properties");
                logger.error("2. La API key tiene habilitada la Distance Matrix API");
                logger.error("3. Hay conexión a internet");
            }
        };
    }
    */
}

/**
 * GUÍA PARA USAR ESTOS EJEMPLOS EN PRODUCCIÓN:
 *
 * 1. NO incluyas ejemplos en CommandLineRunner en producción
 * 2. USA el GoogleMapsService en tus servicios reales:
 *
 *    @Service
 *    public class CreacionPedidoServicio {
 *        private final GoogleMapsService googleMapsService;
 *
 *        public void crearPedido(Pedido pedido) {
 *            // Calcula distancia real
 *            DistanciaYDuracion distancia = googleMapsService
 *                .calcularDistanciaYDuracion(pedido.getOrigen(), pedido.getDestino());
 *
 *            // Usa la información
 *            pedido.setDistanciaKm(distancia.getDistanciaKm());
 *            pedido.setTarifa(calcularTarifa(distancia));
 *
 *            pedidoRepository.save(pedido);
 *        }
 *    }
 *
 * 3. MANEJO DE ERRORES:
 *    - Captura RuntimeException del servicio
 *    - Retorna errores 400/500 al cliente REST
 *    - Loguea para debugging
 *
 * 4. TESTING:
 *    - Mock el RestClient en tests unitarios
 *    - No llames a Google Maps en tests
 *
 *    @Mock
 *    private RestClient restClient;
 *
 *    @InjectMocks
 *    private GoogleMapsService googleMapsService;
 *
 * 5. PERFORMANCE:
 *    - RestClient es sincrónico (bloquea el thread)
 *    - Para muchas llamadas concurrentes, considera usar WebClient (reactivo)
 *    - Implementa caché si consultas las mismas rutas repetidamente
 */

