# 🔧 Guía Rápida para Reparar la Colección de Postman

## Problema: Los GET no funcionan después de los POST

### ✅ Solución Rápida:

#### Paso 1: Verificar que el Token se Guardó

1. Ejecuta primero: **"1. Autenticación > Obtener Token - Operador"**
2. En la respuesta, verifica que hay un `access_token` en el JSON
3. Ve a la pestaña **"Tests"** del request (abajo en Postman) - NO debería tener errores

#### Paso 2: Verificar la Variable `authToken`

1. Haz clic en el ícono de **ojo** 👁️ arriba a la derecha en Postman (Variables)
2. O ve a: **Colección > Variables**
3. Verifica que `authToken` tenga un valor (debe ser un string largo como `eyJhbGc...`)

#### Paso 3: Configurar Manualmente el Token en Cada Request

Si los GET siguen dando 401, haz esto manualmente:

1. Abre cualquier request GET (ej: "Listar Clientes")
2. Ve a la pestaña **"Authorization"**
3. Selecciona **"Bearer Token"** en el tipo
4. En el campo **"Token"**, escribe: `{{authToken}}`
5. Repite para TODOS los requests GET

#### Paso 4: Alternativa - Usar Script de Pre-request

Si nada funciona, agrega esto al **Pre-request Script** de cada carpeta:

```javascript
// Pre-request Script (en cada carpeta)
if (!pm.collectionVariables.get("authToken")) {
    console.log("⚠️ No hay token guardado. Ejecuta primero 'Obtener Token - Operador'");
}
```

---

## 🔍 Diagnóstico

### Verificar si el Token se Guarda:

1. Ejecuta "Obtener Token - Operador"
2. Abre la consola de Postman: **View > Show Postman Console** (o Ctrl+Alt+C)
3. Busca mensajes que digan `authToken`
4. Si no ves nada, el script de test no se ejecutó correctamente

### Ver el Token Actual:

En cualquier request, en la pestaña **"Headers"**, deberías ver:
```
Authorization: Bearer {{authToken}}
```

Si ves `{{authToken}}` literal (sin reemplazar), significa que la variable no existe.

---

## ✅ Solución Definitiva - Importar Colección Actualizada

1. **Elimina** la colección actual de Postman
2. **Importa** de nuevo `TPI-Backend.postman_collection.json`
3. Verifica que TODOS los requests tengan la pestaña **"Authorization"** configurada

---

## 🎯 Pasos para Probar (en Orden):

1. ✅ Ejecuta: **"Obtener Token - Operador"**
   - Verifica Status 200
   - Verifica que hay `access_token` en la respuesta

2. ✅ Verifica Variable:
   - Ve a: Colección > Variables
   - `authToken` debe tener un valor largo

3. ✅ Ejecuta: **"Listar Clientes"** (GET)
   - Debe funcionar con Status 200

4. ✅ Si sigue dando 401:
   - Ve al request "Listar Clientes"
   - Authorization > Bearer Token > Token: `{{authToken}}`
   - Guarda
   - Ejecuta de nuevo

---

## 💡 Tip Extra: Usar Environment Variables

Si las Collection Variables no funcionan, usa Environment:

1. Crea un Environment nuevo en Postman
2. Agrega variable: `authToken` = (vacío)
3. En el script de test de "Obtener Token", cambia:
   ```javascript
   pm.environment.set('authToken', jsonData.access_token);
   ```
4. En cada request, usa: `{{authToken}}` (funciona igual)

---

## 🆘 Si Nada Funciona:

1. **Reinicia Postman** completamente
2. **Importa la colección de nuevo**
3. Verifica que estás usando la **versión más reciente** de Postman
4. Prueba con **Postman Web** en lugar de la app de escritorio

