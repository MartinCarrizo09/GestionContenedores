package com.tpi.logistica.dto.googlemaps;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.List;

/**
 * DTO para respuesta de Google Maps Distance Matrix API.
 * https://developers.google.com/maps/documentation/distance-matrix/overview
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@SuppressWarnings("deprecation")
public class GoogleMapsDistanceResponse {

    private List<Row> rows;
    private String status;

    @JsonProperty("origin_addresses")
    private List<String> originAddresses;

    @JsonProperty("destination_addresses")
    private List<String> destinationAddresses;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Row {
        private List<Element> elements;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Element {
        private Distance distance;
        private Duration duration;
        private String status;
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Distance {
        private Long value;  // en metros
        private String text; // "702 km"
    }

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Duration {
        private Long value;  // en segundos
        private String text; // "7 hours 30 mins"
    }
}

