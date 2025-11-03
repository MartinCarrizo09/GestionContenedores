# Primera Entrega TPI - Diseño del Sistema 

- Gonzalo Maurino Medina 401062
- Ezequias Passon 402046
- Juan Martin Coutsierts 406128
- Martin Alejandro Carrizo 400562

A continuación, se detalla el diseño propuesto para el backend de la aplicación de logística, cubriendo la arquitectura de microservicios, el diseño de la base de datos y la definición de los endpoints de la API, conforme a lo solicitado para la primera entrega.

## 1. Diseño de Arquitectura y Diagrama de Contenedores

Para cumplir con los requisitos del proyecto, proponemos una arquitectura de microservicios que separa las responsabilidades del sistema en dominios lógicos y bien definidos. Esto promueve la escalabilidad, el mantenimiento y el despliegue independiente de cada parte del sistema.

## Componentes de la Arquitectura

- Clientes (Usuarios): Representa a los tres roles (Cliente, Operador, Transportista) que interactúan con el sistema.
- API Gateway: Será el único punto de entrada para todas las solicitudes. Se encargará de enrutar las peticiones al microservicio correspondiente, además de gestionar la autenticación inicial.
- Keycloak: Funcionará como nuestro proveedor de identidad y control de acceso. El API Gateway y los servicios validarán los tokens JWT emitidos por Keycloak para autorizar las operaciones según el rol del usuario.
- Microservicios: Se propone un desglose en tres servicios principales:
- Servicio de logística (logistics-service): Gestiona solicitudes, rutas y tramos.
- Servicio de Flota (fleet-service): Gestiona camiones y transportistas.
- Servicio de Gestión (management-service): Administra entidades maestras como clientes, contenedores, depósitos y tarifas.
- Base de Datos (Supabase/PostgreSQL): Se utilizará una instancia de base de datos en la nube gestionada por Supabase.
- API Externa (Google Distance Matrix): El servicio de logística se comunicará con esta API para calcular distancias y estimar tiempos de viaje.


## Estrategia de Contenerización con Docker

Para asegurar un entorno de desarrollo, pruebas y despliegue consistente y aislado, utilizaremos Docker para contenerizar cada componente de nuestra aplicación. Se definirá un archivo docker-compose.yml que orquestará el levantamiento de los siguientes servicios:

---

- Contenedor para el API Gateway.
- Contenedor para el Servicio de Gestión (management-service).
- Contenedor para el Servicio de Flota (fleet-service).
- Contenedor para el Servicio de Logística (logistics-service).

Este archivo docker-compose.yml nos permitirá levantar todo el entorno de backend con un solo comando, facilitando la colaboración y el despliegue.

# Flujo de una Petición Típica 

1. Un Usuario se autentica en Keycloak y obtiene un token JWT.
2. El Usuario envía una petición (ej. para crear un camión) al API Gateway, incluyendo el token.
3. El API Gateway valida el token con Keycloak.
4. Si el token es válido, el Gateway redirige la petición al microservicio correspondiente (en este caso, al servicio de flota).
5. El servicio de flota procesa la petición y se comunica con la Base de Datos en Supabase para guardar/actualizar la información.
6. Si un servicio necesita información externa (ej. el servicio de logística necesita calcular una distancia), consultará a la API de Google Maps.

Diagrama de Contenedores
![img-0.jpeg](assets/Primera%20Entrega%20TPI%20-%20Diseño%20del%20Sistema_img-0.jpeg)

---

Diagrama DER Completo
![img-1.jpeg](assets/Primera%20Entrega%20TPI%20-%20Diseño%20del%20Sistema_img-1.jpeg)

# 3. Documentación de Microservicios, Recursos y Endpoints 

A continuación, se describen las responsabilidades y los endpoints RESTful para cada microservicio. Todos los endpoints requieren autenticación y están protegidos por rol.

Requerimiento 1: Registrar una nueva solicitud de transporte de contenedor.

| Método y <br> Recurso | Descripción | Rol de <br> acceso | Datos <br> entrada <br> (Ejemplo) | Datos <br> respuesta <br> (Ejemplo) | Servicio |
| :-- | :-- | :-- | :-- | :-- | :-- |

---

| POST <br> /api/v1/solici <br> tudes | Registra una nueva solicitud. Si el cliente no existe, lo crea. Crea el contenedor asociado y deja la solicitud en estado "borrador". | Cliente | \{"cliente": <br> $\{\ldots\}$ <br> "contened or": $\{\ldots\}$ <br> "origen": <br> $\{\ldots\}$ <br> "destino": <br> $\{\ldots\}\}$ | \{"id": 501, <br> "numero_seg uimiento": <br> "XYZ-789", ... <br> \} | Logística |
| :--: | :--: | :--: | :--: | :--: | :--: |

Requerimiento 2: Consultar el estado del transporte de un contenedor.

| Método y <br> Recurso | Descripción | Rol de <br> acces <br> o | Datos entrada <br> (Ejemplo) | Datos <br> respuesta <br> (Ejemplo) | Servicio |
| :-- | :-- | :-- | :-- | :-- | :-- |
| GET <br> /api/v1/cont <br> enedores/\{i <br> d\}/estado | Permite al <br> cliente <br> consultar el <br> estado actual <br> del transporte <br> de su <br> contenedor, <br> incluyendo <br> ubicación y <br> datos del <br> tramo activo. | Cliente | /api/v1/contene <br> dores/34/estado | \{"estado": <br> "en_transit <br> o", <br> "ubicacion" <br> : "En viaje <br> a Depósito <br> B" \} | Logística |

Requerimiento 3 y 8: Consultar rutas tentativas y calcular costos.

| Método y <br> Recurso | Descripción | Rol de <br> acceso | Datos <br> entrada <br> (Ejemplo) | Datos <br> respuesta <br> (Ejemplo) | Servicio |
| :-- | :-- | :-- | :-- | :-- | :-- |

---

| POST <br> /api/v1/rutas/e <br> stimar | Devuelve <br> rutas <br> tentativas <br> con tramos, <br> tiempo y <br> costo <br> aproximado, <br> utilizando la <br> API externa <br> para calcular <br> distancias. | Operad <br> or | \{"origen": <br> (...), <br> "destino": <br> (...), <br> "pesoKg": <br> $4800, \ldots\}$ | \{ <br> "costo_estim <br> ado": <br> 98524.0, <br> "tramos": [...] <br> \} | Logística |
| :-- | :-- | :-- | :-- | :-- | :-- |

Requerimiento 4: Asignar una ruta con todos sus tramos a la solicitud.

| Método y Recurso | Descripció <br> n | Rol de <br> acceso | Datos <br> entrada <br> (Ejempl <br> o) | Datos <br> respues <br> ta <br> (Ejempl <br> o) | Servic <br> io |
| :-- | :-- | :-- | :-- | :-- | :-- |

Requerimiento 5: Consultar todos los contenedores pendientes de entrega.

---

| Método y Recurso | Descrip <br> ción | Rol <br> de <br> acces <br> 0 | Datos <br> entrada <br> (Ejemplo) | Datos <br> respue <br> sta <br> (Ejempl <br> o) | Servi <br> cio |
| :-- | :-- | :-- | :-- | :-- | :-- |
| GET <br> /api/v1/contenedores/pe <br> ndientes | Consulta <br> todos los <br> contened <br> ores no <br> entregad <br> os, con <br> su <br> estado y <br> ubicació <br> n. <br> Permite <br> filtros <br> opcional <br> es. | Opera <br> dor | ?estado=en_t <br> ransito | Lista de <br> DTOs <br> con <br> datos <br> de <br> Conten <br> edor, <br> Solicitu <br> d, etc. | Logís <br> tica |

Requerimiento 6 y 11: Asignar camión a un tramo y validar capacidad.

| Método y Recurso | Descripci <br> ón | Rol de <br> acceso | Datos <br> entrada <br> (Ejemplo) | Datos <br> respues <br> ta <br> (Ejempl <br> o) | Servic <br> io |
| :-- | :-- | :-- | :-- | :-- | :-- |

---

| PUT <br> /api/v1/tramos/{id}/asig <br> nar-camion | Asigna un camión a un tramo. Valida que el camión esté libre y que su capacidad no sea superada. Cambia el estado del tramo a "asignado ". | Operad or | \{ "camion_i d": 5 \} | DTO con datos del Tramo actualiza do y el Camión asignado | Logísti ca |
| :--: | :--: | :--: | :--: | :--: | :--: |

Requerimiento 7 y 9: Determinar inicio/fin de un tramo y registrar datos reales.

| Método y Recurso | Descripci <br> ón | Rol de <br> acceso | Datos <br> entrada <br> (Ejempl <br> o) | Datos <br> respuesta <br> (Ejemplo) | Servi <br> cio |
| :-- | :-- | :-- | :-- | :-- | :-- |
| PATCH <br> /api/v1/tramos/{id}/ini <br> ciar | Marca el <br> tramo <br> como <br> "iniciado", <br> registrand <br> o la fecha <br> y hora <br> real de <br> inicio. | Transporti <br> sta | $\}$ | \{ "tramo_id": <br> 20, <br> "estado": <br> "iniciado", <br> ...\} | Logísti <br> ca |

---

| PATCH <br> /api/v1/tramos/{id}/fin alizar | Marca el tramo como "finalizado". Si es el último, consolida y registra el costo y tiempo real en la solicitud, que pasa a "entregada". | Transporti sta | \{ <br> "kmRea <br> I": <br> 132.4, <br> $\ldots$ | $\begin{aligned} & \text { \{ "id_solicitu } \\ & \text { d": 501, } \\ & \text { "estado": } \\ & \text { "entregada } \\ & \text { ", ...\} } \end{aligned}$ | Logísti ca |
| :--: | :--: | :--: | :--: | :--: | :--: |

Requerimiento 10: Registrar y actualizar depósitos, camiones y tarifas.

Gestión de Depósitos

| Método y Recurso | Descripció <br> n | Rol de <br> acceso | Datos <br> entrada <br> (Ejemplo <br> ) | Datos <br> respuest <br> a <br> (Ejemplo <br> ) | Servici <br> 0 |
| :-- | :-- | :-- | :-- | :-- | :-- |
| POST <br> /api/v1/depositos | Registra un <br> nuevo <br> depósito. | Operad <br> or | \{ "nombre" <br> : <br> "Depósito <br> Central", <br> ...\} | \{ "id": 1, <br> "nombre" <br> : <br> "Depósito <br> Central", <br> ...\} | Gestión |
| GET <br> /api/v1/depositos | Obtiene <br> una lista de <br> todos los <br> depósitos. | Operad <br> or | N/A | [\{ "id": 1, <br> ...\}, \{ <br> "id": 2, ... <br> \}] | Gestión |

---

| GET <br> /api/v1/depositos/\{id <br> \} | Obtiene los <br> detalles de <br> un depósito <br> específico. | Operad <br> or | N/A | \{"id": 1, <br> "nombre" <br> : <br> "Depósito <br> Central", <br> $\ldots$... \} | Gestión |
| :-- | :-- | :-- | :-- | :-- | :-- |
| PUT <br> /api/v1/depositos/\{id <br> \} | Actualiza la <br> información <br> de un <br> depósito <br> existente. | Operad <br> or | \{
"nombre" <br> : <br> "Depósito <br> Central <br> MOD", ... <br> \} | \{"id": 1, <br> "nombre" <br> : <br> "Depósito <br> Central <br> MOD", ... <br> \} | Gestión |

Gestión de Camiones

| Método y Recurso | Descripci <br> ón | Rol de <br> acceso | Datos <br> entrada <br> (Ejemplo) | Datos <br> respuesta <br> (Ejemplo) | Servic <br> io |
| :-- | :-- | :-- | :-- | :-- | :-- |
| POST <br> /api/v1/camiones | Registra <br> un nuevo <br> camión en <br> el sistema. | Operad <br> or | \{"patente": <br> "AE456FG", <br> $\ldots$... \} | \{"id": 3, <br> "patente": <br> "AE456FG <br> ", ... \} | Flota |
| GET <br> /api/v1/camiones | Obtiene <br> una lista <br> de todos <br> los <br> camiones, <br> permitiend <br> o filtrar. | Operad <br> or | ?disponible=t <br> rue | [ \{"id": 1, <br> $\ldots$... \}, \{"id": <br> $3, \ldots]$ | Flota |
| GET <br> /api/v1/camiones/\{ <br> id\} | Obtiene <br> los <br> detalles de | Operad <br> or | N/A | \{"id": 3, <br> "patente": | Flota |

---

|  | un camión <br> específico. |  |  | "AE456FG <br> ", ...\} |  |
| :-- | :-- | :-- | :-- | :-- | :-- |
| PUT <br> /api/v1/camiones/{ <br> id\} | Actualiza <br> la <br> informació <br> n de un <br> camión <br> existente. | Operad <br> or | \{"costo_km": <br> 150.50, ... \} | \{"id": 3, <br> "costo_km <br> ": 150.50, <br> ...\} | Flota |

Gestión de Tarifas

| Método y <br> Recurso | Descripció <br> n | Rol de <br> acceso | Datos <br> entrada <br> (Ejemplo) | Datos <br> respuesta <br> (Ejemplo) | Servici <br> 0 |
| :-- | :-- | :-- | :-- | :-- | :-- |
| POST <br> /api/v1/tarifas | Registra <br> una nueva <br> tarifa. | Operad <br> or | \{\} <br> "descripcion <br> ": "Tarifa <br> Pesado", ... <br> \} | \{"id": 4, <br> "descripcion <br> ": "Tarifa <br> Pesado", ... <br> \} | Gestió <br> n |
| GET <br> /api/v1/tarifas | Obtiene <br> una lista de <br> todas las <br> tarifas <br> configurada <br> s. | Operad <br> or | N/A | [ \{"id": 1, ... <br> \}, \{"id": 4, ... <br> \}] | Gestió <br> n |
| GET <br> /api/v1/tarifas/\{i <br> d\} | Obtiene el <br> detalle de <br> una tarifa <br> específica. | Operad <br> or | N/A | \{"id": 4, <br> "descripcion <br> ": "Tarifa <br> Pesado", ... <br> \} | Gestió <br> n |

---

| PUT <br> /api/v1/tarifas/\{i <br> d\} | Actualiza una tarifa existente. | Operad or | \{"valor": <br> 55000, ... \} | \{"id": 4, <br> "valor": <br> 55000, ... \} | Gestió n |
| :--: | :--: | :--: | :--: | :--: | :--: |