### 3️⃣ Ejecutar Setup Completo

Abrir **PowerShell** en la carpeta del proyecto y ejecutar:

```powershell
.\setup-completo.ps1
```

⏱️ **Tiempo estimado: 10-15 minutos** (la primera vez)

El script hará automáticamente:
- ✅ Eliminar contenedores/volúmenes existentes
- ✅ Rebuildear todas las imágenes Docker
- ✅ Iniciar servicios
- ✅ Reiniciar BD a 0
- ✅ Configurar Keycloak
- ✅ Obtener tokens

### 4️⃣ Verificar

Una vez terminado, verifica que todo funciona(SOBRETODO VEAN SI ANDAN LOS REALMS DE KEYCLOACK):

```powershell
# Ver contenedores corriendo
docker ps

# Deberías ver 6 contenedores:
# - tpi-postgres
# - tpi-keycloak  
# - tpi-gateway
# - tpi-gestion
# - tpi-flota
# - tpi-logistica
```

### 5️⃣ Usar Postman

1. Abrir Postman
2. Importar colecciones desde `pruebas-postman/`
3. Ejecutar "Obtener Token - [ROL]" en la sección de Autenticación
4. ¡Listo para usar!


