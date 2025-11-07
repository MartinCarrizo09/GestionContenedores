# 🧪 Pruebas de API Gateway con Postman

## 🔐 Tokens de Autenticación

### Token OPERADOR
```
eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIwZC1OVzhmRld0X1pYYVZkcEgwUE9yd3NOcEVGUGZYMDZaaURkbmh0RTc0In0.eyJleHAiOjE3NjI0ODAwODYsImlhdCI6MTc2MjQ3OTc4NiwianRpIjoiNzE4NDY2ZjctNjI0My00MmE4LTlhMjctMTU1YWExZTE3NDEyIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo5MDkwL3JlYWxtcy90cGktYmFja2VuZCIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiI4ZTM1NmQzNy0xZjQxLTQ3NTMtOTk1Yi00YjA1YzI0NmVjMDIiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJ0cGktY2xpZW50Iiwic2lkIjoiNDlhYzg2YjAtNzgxNS00OTllLTg2YzQtZTEzODM1Y2FmYzA4IiwiYWNyIjoiMSIsImFsbG93ZWQtb3JpZ2lucyI6WyIqIl0sInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsIk9QRVJBRE9SIiwidW1hX2F1dGhvcml6YXRpb24iLCJkZWZhdWx0LXJvbGVzLXRwaS1iYWNrZW5kIl19LCJyZXNvdXJjZV9hY2Nlc3MiOnsiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJlbWFpbCBwcm9maWxlIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJPcGVyYWRvciBUUEkiLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJvcGVyYWRvckB0cGkuY29tIiwiZ2l2ZW5fbmFtZSI6Ik9wZXJhZG9yIiwiZmFtaWx5X25hbWUiOiJUUEkiLCJlbWFpbCI6Im9wZXJhZG9yQHRwaS5jb20ifQ.EcaZA67ZxllD0ng9iHijTSAkNIMp3-7ZDYB7ftILU58blBdNDq_or9fgLR5tBp-iwMevW6YOAOJTo9B4lVPbRjMxiC-h_1NEapmQuNUP7B3eAkjx82JGEXHtaaYOb2z0CPVm2vPcUr1MkiSnsGebojLWv3MVHiPYF4nKZnvLeyADpAPDu_1B0LR086W5BAOv32bPyNipbEOsFzgXZaMpYL39VWPiHOxdp2xAJdFd-3n5zQTxJr27TYIPUDr856OyYKTISoNpmksp3kRbPrCPuseGfuccI4rQ5ec4e60DqcC01urZhE6H5GL8LnfScVMATbtsNIbUjBCycnknIOO7Sw
```

### Token CLIENTE
```
eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIwZC1OVzhmRld0X1pYYVZkcEgwUE9yd3NOcEVGUGZYMDZaaURkbmh0RTc0In0.eyJleHAiOjE3NjI0ODAxMDcsImlhdCI6MTc2MjQ3OTgwNywianRpIjoiMGM1MjRlNzAtNDBkNS00ZTZlLTlhOTgtYzQyNmMxMmZiYWRiIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo5MDkwL3JlYWxtcy90cGktYmFja2VuZCIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiIyODZjYWFjNy0yNzI1LTRiYzAtOTBmMC1hMDM3ZDVkMTdhNGUiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJ0cGktY2xpZW50Iiwic2lkIjoiZDNlZTBkNWUtNDEwNC00MjY0LWE5ZjYtNmIwZWY3OGFhNmE1IiwiYWNyIjoiMSIsImFsbG93ZWQtb3JpZ2lucyI6WyIqIl0sInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJvZmZsaW5lX2FjY2VzcyIsInVtYV9hdXRob3JpemF0aW9uIiwiZGVmYXVsdC1yb2xlcy10cGktYmFja2VuZCIsIkNMSUVOVEUiXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6ImVtYWlsIHByb2ZpbGUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IkNsaWVudGUgVFBJIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiY2xpZW50ZUB0cGkuY29tIiwiZ2l2ZW5fbmFtZSI6IkNsaWVudGUiLCJmYW1pbHlfbmFtZSI6IlRQSSIsImVtYWlsIjoiY2xpZW50ZUB0cGkuY29tIn0.cHWtwUwomtCthST0g2SJ2FVjqupUpBF4odzBBrEY-bCPDLMSQQyj76ChEQiNm7Ji7imyNZq6j8OFYvu--R2Bl3NPvDras4GHExZKM_nR7U8pFCPx1M6vapV1tP61iOvH7SEXl6e20-BDJ5ftFKzdrtu9fxkaK4kY-STnhJ3D_BvnEFCXsiWxL03sg6ekvBMDvbL8_7gUtlzjlyG00RWrgDIF4p2HCl4ZaoodqPib2j_UyHggmITHBC_VQaavVRykR43Z25cRa3YIsb_0gv4GLEseLMlNAr9s0M1hfT7cP8LjWSxIt5zdNRyGdR4LZw8oXmOrrEUKYtk8L4V65Q812g
```

### Token TRANSPORTISTA
```
eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIwZC1OVzhmRld0X1pYYVZkcEgwUE9yd3NOcEVGUGZYMDZaaURkbmh0RTc0In0.eyJleHAiOjE3NjI0ODAwNDcsImlhdCI6MTc2MjQ3OTc0NywianRpIjoiZDE4OGEwOWQtYjJjNC00N2I5LWJiYmItMTQ0ZWY1M2EzOTRmIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo5MDkwL3JlYWxtcy90cGktYmFja2VuZCIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiI1NTI0ZWRkZi0wOGU0LTQ4ZWQtOGE0NS00NGQwZDVhMGQyZGEiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJ0cGktY2xpZW50Iiwic2lkIjoiOGQ5YWY4ZGEtZTk0Ni00YjAzLTg5MDYtYjg4MDljNzAwNmVkIiwiYWNyIjoiMSIsImFsbG93ZWQtb3JpZ2lucyI6WyIqIl0sInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJUUkFOU1BPUlRJU1RBIiwib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsImRlZmF1bHQtcm9sZXMtdHBpLWJhY2tlbmQiXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6ImVtYWlsIHByb2ZpbGUiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwibmFtZSI6IlRyYW5zcG9ydGlzdGEgVFBJIiwicHJlZmVycmVkX3VzZXJuYW1lIjoidHJhbnNwb3J0aXN0YUB0cGkuY29tIiwiZ2l2ZW5fbmFtZSI6IlRyYW5zcG9ydGlzdGEiLCJmYW1pbHlfbmFtZSI6IlRQSSIsImVtYWlsIjoidHJhbnNwb3J0aXN0YUB0cGkuY29tIn0.JlZBKoNf8o9wLI6iBONQO73uujh_bS019NCaLryoTST8QMV4-RnPatiRc2_dy8qZHU3prQOCtOqsj_UOk-yKsm1XBivt0xIY9_S0ejscxBNzY9nBvkJOorTqItdmfs2ceoHu-DEStw0eS5aDwtNbwuRqN7Tec0yRz6r586MdQz1_vttiKxBwJKI-gIxhcwG3_BFk9plMpxOsQ-7HAjS676l6nsg8gI7AqV_PBgTgN6anQRWtJsUAvfpDpaWmoT4xGtsv9fDWBSVAxtV9sV7djX_XhQccc4kMjdRujcbx1YqeiyFWtYadMqmKngiVphPrFr5P0hdaRXXukr4dqQftzQ
```

---

## 📋 Endpoints para Probar

### 🔹 1. Servicio Gestión - Clientes

#### ✅ GET `/api/gestion/clientes` - Listar todos los clientes
- **URL**: `http://localhost:8080/api/gestion/clientes`
- **Método**: `GET`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN>`
- **Permisos**: 
  - ✅ OPERADOR
  - ❌ CLIENTE (403 Forbidden)
  - ❌ TRANSPORTISTA (403 Forbidden)
- **Respuesta esperada**: `200 OK` con array de clientes

#### ✅ GET `/api/gestion/clientes/{id}` - Obtener cliente por ID
- **URL**: `http://localhost:8080/api/gestion/clientes/1`
- **Método**: `GET`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN_OPERADOR>`
- **Permisos**: OPERADOR
- **Respuesta esperada**: `200 OK` con datos del cliente

---

### 🔹 2. Servicio Flota - Camiones

#### ✅ GET `/api/flota/camiones` - Listar todos los camiones
- **URL**: `http://localhost:8080/api/flota/camiones`
- **Método**: `GET`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN>`
- **Permisos**: 
  - ✅ OPERADOR (control total)
  - ❌ TRANSPORTISTA (403 Forbidden por configuración actual)
  - ❌ CLIENTE (403 Forbidden)
- **Respuesta esperada**: `200 OK` con array de camiones

#### ✅ GET `/api/flota/camiones/{patente}` - Obtener camión por patente
- **URL**: `http://localhost:8080/api/flota/camiones/ABC123`
- **Método**: `GET`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN_OPERADOR>`
- **Permisos**: OPERADOR
- **Respuesta esperada**: `200 OK` con datos del camión

---

### 🔹 3. Servicio Gestión - Contenedores

#### ✅ GET `/api/gestion/contenedores` - Listar todos los contenedores
- **URL**: `http://localhost:8080/api/gestion/contenedores`
- **Método**: `GET`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN>`
- **Permisos**: 
  - ✅ OPERADOR (control total)
  - ❌ CLIENTE (403 Forbidden)
  - ❌ TRANSPORTISTA (403 Forbidden)
- **Respuesta esperada**: `200 OK` con array de contenedores

#### ✅ GET `/api/gestion/contenedores/{id}/estado` - Consultar estado de un contenedor
- **URL**: `http://localhost:8080/api/gestion/contenedores/CONT001/estado`
- **Método**: `GET`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN_CLIENTE>`
- **Permisos**: CLIENTE (Requisito 2 del TPI)
- **Respuesta esperada**: `200 OK` con estado del contenedor

---

### 🔹 4. Servicio Logística - Solicitudes

#### ✅ POST `/api/logistica/solicitudes` - Crear solicitud de transporte
- **URL**: `http://localhost:8080/api/logistica/solicitudes`
- **Método**: `POST`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN_CLIENTE>`
- **Permisos**: CLIENTE (Requisito 1 del TPI)
- **Body**: (JSON con datos de solicitud)
- **Respuesta esperada**: `201 Created`

#### ✅ GET `/api/logistica/solicitudes/pendientes` - Listar solicitudes pendientes
- **URL**: `http://localhost:8080/api/logistica/solicitudes/pendientes`
- **Método**: `GET`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN_OPERADOR>`
- **Permisos**: OPERADOR (Requisito 3 del TPI)
- **Respuesta esperada**: `200 OK` con array de solicitudes

---

### 🔹 5. Servicio Logística - Tramos

#### ✅ PATCH `/api/logistica/tramos/{id}/iniciar` - Iniciar tramo de transporte
- **URL**: `http://localhost:8080/api/logistica/tramos/1/iniciar`
- **Método**: `PATCH`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN_TRANSPORTISTA>`
- **Permisos**: TRANSPORTISTA (Requisito 7 del TPI)
- **Respuesta esperada**: `200 OK`

#### ✅ PATCH `/api/logistica/tramos/{id}/finalizar` - Finalizar tramo de transporte
- **URL**: `http://localhost:8080/api/logistica/tramos/1/finalizar`
- **Método**: `PATCH`
- **Headers**:
  - `Authorization`: `Bearer <TOKEN_TRANSPORTISTA>`
- **Permisos**: TRANSPORTISTA (Requisito 9 del TPI)
- **Respuesta esperada**: `200 OK`

---

## 📝 Cómo Configurar en Postman

### Paso 1: Crear una Nueva Colección
1. Abrí Postman
2. Click en **New** → **Collection**
3. Nombrala "TPI Gateway - Gestión de Contenedores"

### Paso 2: Configurar Variables de Entorno
1. Click en **Environments** → **New Environment**
2. Nombralo "TPI Local"
3. Agregá estas variables:
   - `base_url`: `http://localhost:8080`
   - `token_operador`: `<pega el token de OPERADOR>`
   - `token_cliente`: `<pega el token de CLIENTE>`
   - `token_transportista`: `<pega el token de TRANSPORTISTA>`

### Paso 3: Crear Requests
1. Para cada endpoint listado arriba, creá un nuevo request
2. En la pestaña **Authorization**:
   - Tipo: `Bearer Token`
   - Token: `{{token_operador}}` (o el rol correspondiente)
3. En la URL usá: `{{base_url}}/api/gestion/clientes`

---

## 🧪 Pruebas de Autorización Recomendadas

### Test 1: OPERADOR accede a Clientes ✅
- Endpoint: `GET /api/gestion/clientes`
- Token: OPERADOR
- Resultado esperado: **200 OK**

### Test 2: CLIENTE intenta acceder a Clientes ❌
- Endpoint: `GET /api/gestion/clientes`
- Token: CLIENTE
- Resultado esperado: **403 Forbidden**

### Test 3: TRANSPORTISTA accede a Vehículos ✅
- Endpoint: `GET /api/flota/vehiculos`
- Token: TRANSPORTISTA
- Resultado esperado: **200 OK**

### Test 4: CLIENTE accede a Pedidos ✅
- Endpoint: `GET /api/logistica/pedidos`
- Token: CLIENTE
- Resultado esperado: **200 OK**

### Test 5: TRANSPORTISTA intenta acceder a Pedidos ❌
- Endpoint: `GET /api/logistica/pedidos`
- Token: TRANSPORTISTA
- Resultado esperado: **403 Forbidden**

---

## ⏰ Nota sobre Tokens
- Los tokens tienen una duración de **5 minutos** (300 segundos)
- Si recibís un error **401 Unauthorized**, generá nuevos tokens desde:
  ```bash
  curl -X POST http://localhost:9090/realms/tpi-backend/protocol/openid-connect/token \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=tpi-client" \
    -d "grant_type=password" \
    -d "username=operador@tpi.com" \
    -d "password=operador123"
  ```

---

## 🎯 Resumen de Permisos

| Endpoint | OPERADOR | CLIENTE | TRANSPORTISTA |
|----------|----------|---------|---------------|
| `/api/gestion/clientes` | ✅ | ❌ | ❌ |
| `/api/flota/camiones` | ✅ | ❌ | ❌ |
| `/api/gestion/contenedores` | ✅ | ❌ | ❌ |
| `/api/gestion/contenedores/{id}/estado` | ✅ | ✅ | ❌ |
| `/api/logistica/solicitudes` (POST) | ❌ | ✅ | ❌ |
| `/api/logistica/solicitudes/pendientes` | ✅ | ❌ | ❌ |
| `/api/logistica/tramos/{id}/iniciar` | ❌ | ❌ | ✅ |
| `/api/logistica/tramos/{id}/finalizar` | ❌ | ❌ | ✅ |
