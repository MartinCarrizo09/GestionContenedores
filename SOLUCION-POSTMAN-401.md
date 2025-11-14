# 🚨 Solución: Error 401 en Requests GET de Postman

## 🔍 El Problema

Los POST funcionan pero los GET dan error 401 (Unauthorized). Esto significa que el token no se está usando correctamente en los GET.

## ✅ Solución PASO A PASO

### Paso 1: Verificar que el Token se Guardó

1. **Ejecuta** "Obtener Token - Operador"
2. Abre la **consola de Postman**: `View` > `Show Postman Console` (o `Ctrl+Alt+C`)
3. Debes ver mensajes como:
   ```
   ✅ Token OPERADOR guardado correctamente
      Token: eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldU...
   ```

### Paso 2: Verificar la Variable `authToken`

1. Haz clic en el ícono de **ojo** 👁️ arriba a la derecha (Variables)
2. O ve a: **Colección > Variables** (click derecho en la colección > Edit)
3. Verifica que `authToken` tenga un valor (debe ser un string largo como `eyJhbGc...`)
4. Si está vacío, vuelve al **Paso 1**

### Paso 3: Verificar que los GET Usen el Token

1. Abre cualquier request GET (ej: "Listar Clientes")
2. Ve a la pestaña **"Authorization"**
3. Debe estar configurado como:
   - **Type**: `Bearer Token`
   - **Token**: `{{authToken}}`
4. Si no está así, cámbialo manualmente

### Paso 4: Ver el Header que se Envía

1. Abre cualquier request GET
2. Ve a la pestaña **"Headers"**
3. Debe mostrar:
   ```
   Authorization: Bearer {{authToken}}
   ```
4. **IMPORTANTE**: Cuando ejecutas el request, en la consola debe mostrar:
   ```
   Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldU...
   ```
   (con el token real, NO literalmente `{{authToken}}`)

### Paso 5: Si Sigue Dando 401 - Solución Manual

Si después de todo lo anterior sigue dando 401, haz esto:

1. **Ejecuta** "Obtener Token - Operador" de nuevo
2. En la **respuesta**, copia el `access_token` completo
3. Ve a **Colección > Variables**
4. Pega el token completo en el campo `Value` de `authToken`
5. Guarda
6. Ejecuta cualquier GET de nuevo

---

## 🎯 Checklist Rápido

- [ ] Ejecuté "Obtener Token - Operador" y vi Status 200
- [ ] Vi mensajes en la consola confirmando que se guardó el token
- [ ] Verifiqué que `authToken` tiene un valor en Colección > Variables
- [ ] Verifiqué que los requests GET tienen Authorization > Bearer Token > `{{authToken}}`
- [ ] En la consola, veo que el header `Authorization` se envía con el token real (no `{{authToken}}` literal)

---

## 🔧 Solución Alternativa: Usar Environment

Si Collection Variables no funciona:

1. Crea un **Environment** nuevo:
   - Click en "Environments" (izquierda)
   - "+" para crear nuevo
   - Nombre: "TPI Local"

2. Agrega variable:
   - Variable: `authToken`
   - Initial Value: (vacío)
   - Current Value: (vacío)

3. **Selecciona** el Environment (dropdown arriba a la derecha)

4. En los scripts de "Obtener Token", asegúrate de que guarda en environment:
   ```javascript
   pm.environment.set('authToken', jsonData.access_token);
   ```

5. Usa `{{authToken}}` en todos los requests (igual que antes)

---

## 🐛 Debugging

### Ver qué se está enviando:

1. Abre la **consola de Postman** (`Ctrl+Alt+C`)
2. Ejecuta un request GET
3. Busca la sección "Request Headers"
4. Verifica que `Authorization` tenga el token real (no `{{authToken}}`)

### Si ves `{{authToken}}` literal:

- La variable no existe o no se resolvió
- Solución: Vuelve al Paso 1 y verifica que el token se guardó

### Si ves el token pero sigue 401:

- El token podría estar expirado
- Solución: Ejecuta "Obtener Token" de nuevo

### Si el token no se guarda:

1. Verifica que la respuesta tenga `access_token`
2. Verifica que no haya errores JavaScript en la consola
3. Verifica que el script de test se ejecutó (mensajes en consola)

---

## ✅ Verificación Final

Después de seguir estos pasos, deberías poder:

1. ✅ Ejecutar "Obtener Token - Operador" → Status 200
2. ✅ Ver mensaje en consola: "✅ Token OPERADOR guardado correctamente"
3. ✅ Ver que `authToken` tiene valor en Variables
4. ✅ Ejecutar "Listar Clientes" (GET) → Status 200 (no 401)

---

## 🆘 Si Nada Funciona

1. **Reinicia Postman** completamente
2. **Elimina** la colección actual
3. **Importa** de nuevo `TPI-Backend.postman_collection.json`
4. **Sigue los pasos desde el Paso 1**

---

**Nota**: La colección fue actualizada con scripts de debugging que mostrarán mensajes en la consola para ayudarte a identificar el problema.

