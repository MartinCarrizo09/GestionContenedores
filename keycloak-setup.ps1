# Script para configurar Keycloak automáticamente
# Uso: powershell -ExecutionPolicy Bypass -File keycloak-setup.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Configuración Automática de Keycloak" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Variables de configuración
$KEYCLOAK_URL = "http://localhost:8080"
$ADMIN_USER = "admin"
$ADMIN_PASSWORD = "admin"
$REALM_NAME = "TPI-Realm"
$CLIENT_ID = "api-gateway-client"

# Paso 1: Obtener token de admin (realm master)
Write-Host "[1/6] Obteniendo token de administrador..." -ForegroundColor Yellow

try {
    $tokenResponse = Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/realms/master/protocol/openid-connect/token" `
      -Method Post `
      -ContentType "application/x-www-form-urlencoded" `
      -Body @{
        grant_type = "password"
        client_id = "admin-cli"
        username = $ADMIN_USER
        password = $ADMIN_PASSWORD
      } `
      -ErrorAction Stop

    $adminToken = $tokenResponse.access_token
    Write-Host "  ✓ Token obtenido exitosamente" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error al obtener token: $_" -ForegroundColor Red
    Write-Host "  Asegúrate que Keycloak esté corriendo en $KEYCLOAK_URL" -ForegroundColor Red
    exit 1
}

# Paso 2: Crear Realm
Write-Host "[2/6] Creando realm '$REALM_NAME'..." -ForegroundColor Yellow

$realmData = @{
    realm = $REALM_NAME
    enabled = $true
    displayName = "TPI Backend"
    displayNameHtml = "Plataforma de Transporte Integrada"
    accessTokenLifespan = 300
    refreshTokenLifespan = 1800
    ssoSessionIdleTimeout = 1800
} | ConvertTo-Json

try {
    Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/admin/realms" `
      -Method Post `
      -Headers @{
        "Authorization" = "Bearer $adminToken"
        "Content-Type" = "application/json"
      } `
      -Body $realmData `
      -ErrorAction Stop

    Write-Host "  ✓ Realm '$REALM_NAME' creado" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "  ⚠ Realm '$REALM_NAME' ya existe" -ForegroundColor Yellow
    } else {
        Write-Host "  ✗ Error al crear realm: $_" -ForegroundColor Red
    }
}

# Paso 3: Crear Roles
Write-Host "[3/6] Creando roles..." -ForegroundColor Yellow

$roles = @(
    @{ name = "admin-tpi"; description = "Administrador del sistema TPI" },
    @{ name = "driver"; description = "Conductor de transporte" },
    @{ name = "dispatcher"; description = "Despachador de rutas" },
    @{ name = "manager"; description = "Gerente / Manager" },
    @{ name = "customer"; description = "Cliente / Usuario final" }
)

foreach ($role in $roles) {
    try {
        $roleData = @{
            name = $role.name
            description = $role.description
            composite = $false
        } | ConvertTo-Json

        Invoke-RestMethod `
          -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles" `
          -Method Post `
          -Headers @{
            "Authorization" = "Bearer $adminToken"
            "Content-Type" = "application/json"
          } `
          -Body $roleData `
          -ErrorAction Stop

        Write-Host "    ✓ Rol '$($role.name)' creado" -ForegroundColor Green
    } catch {
        Write-Host "    ⚠ Error al crear rol '$($role.name)': $_" -ForegroundColor Yellow
    }
}

# Paso 4: Crear Cliente API Gateway
Write-Host "[4/6] Creando cliente '$CLIENT_ID'..." -ForegroundColor Yellow

$clientData = @{
    clientId = $CLIENT_ID
    name = "API Gateway"
    description = "Cliente para API Gateway del sistema TPI"
    enabled = $true
    publicClient = $false
    clientAuthenticatorType = "client-secret-basic"
    redirectUris = @(
        "http://localhost:8080/*"
        "http://localhost:9000/*"
        "http://localhost:9001/*"
        "http://localhost:9002/*"
        "https://localhost/*"
    )
    validPostLogoutRedirectUris = @(
        "http://localhost:8080/*"
        "https://localhost/*"
    )
    webOrigins = @(
        "http://localhost:8080"
        "http://localhost:9000"
        "http://localhost:9001"
        "http://localhost:9002"
        "https://localhost"
    )
    standardFlowEnabled = $true
    directAccessGrantsEnabled = $true
    serviceAccountsEnabled = $true
    implicitFlowEnabled = $false
    authorizationServicesEnabled = $true
} | ConvertTo-Json -Depth 10

try {
    $clientResponse = Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients" `
      -Method Post `
      -Headers @{
        "Authorization" = "Bearer $adminToken"
        "Content-Type" = "application/json"
      } `
      -Body $clientData `
      -ErrorAction Stop

    $clientUUID = $clientResponse.id
    Write-Host "  ✓ Cliente '$CLIENT_ID' creado (ID: $clientUUID)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Error al crear cliente: $_" -ForegroundColor Red
    exit 1
}

# Obtener Client Secret
Write-Host "[5/6] Obteniendo credenciales del cliente..." -ForegroundColor Yellow

try {
    $credentialsResponse = Invoke-RestMethod `
      -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/clients/$clientUUID/client-secret" `
      -Method Get `
      -Headers @{
        "Authorization" = "Bearer $adminToken"
      } `
      -ErrorAction Stop

    $clientSecret = $credentialsResponse.value
    Write-Host "  ✓ Client Secret obtenido" -ForegroundColor Green
    Write-Host "  📋 Client Secret: $clientSecret" -ForegroundColor Cyan
} catch {
    Write-Host "  ✗ Error al obtener credenciales: $_" -ForegroundColor Red
}

# Paso 6: Crear Usuarios de Prueba
Write-Host "[6/6] Creando usuarios de prueba..." -ForegroundColor Yellow

$users = @(
    @{
        username = "admin-tpi"
        email = "admin@tpi.local"
        firstName = "Admin"
        lastName = "TPI"
        password = "Admin123!"
        roles = @("admin-tpi")
    },
    @{
        username = "driver1"
        email = "driver1@tpi.local"
        firstName = "Juan"
        lastName = "Conductor"
        password = "Driver123!"
        roles = @("driver")
    },
    @{
        username = "dispatcher1"
        email = "dispatcher1@tpi.local"
        firstName = "Maria"
        lastName = "Despachadora"
        password = "Dispatcher123!"
        roles = @("dispatcher")
    },
    @{
        username = "manager1"
        email = "manager1@tpi.local"
        firstName = "Carlos"
        lastName = "Manager"
        password = "Manager123!"
        roles = @("manager")
    }
)

foreach ($user in $users) {
    try {
        # Crear usuario
        $userData = @{
            username = $user.username
            email = $user.email
            emailVerified = $true
            firstName = $user.firstName
            lastName = $user.lastName
            enabled = $true
            credentials = @(
                @{
                    type = "password"
                    value = $user.password
                    temporary = $false
                }
            )
        } | ConvertTo-Json -Depth 10

        $userResponse = Invoke-RestMethod `
          -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users" `
          -Method Post `
          -Headers @{
            "Authorization" = "Bearer $adminToken"
            "Content-Type" = "application/json"
          } `
          -Body $userData `
          -ErrorAction Stop

        $userId = $userResponse.id

        # Asignar roles
        foreach ($role in $user.roles) {
            try {
                $roleData = Invoke-RestMethod `
                  -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/roles/$role" `
                  -Headers @{
                    "Authorization" = "Bearer $adminToken"
                  } `
                  -ErrorAction Stop

                $rolesPayload = @($roleData) | ConvertTo-Json -Depth 10

                Invoke-RestMethod `
                  -Uri "$KEYCLOAK_URL/admin/realms/$REALM_NAME/users/$userId/role-mappings/realm" `
                  -Method Post `
                  -Headers @{
                    "Authorization" = "Bearer $adminToken"
                    "Content-Type" = "application/json"
                  } `
                  -Body $rolesPayload `
                  -ErrorAction Stop

                Write-Host "    ✓ Usuario '$($user.username)' creado con rol '$role'" -ForegroundColor Green
            } catch {
                Write-Host "    ⚠ Error al asignar rol '$role' a '$($user.username)': $_" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "    ✗ Error al crear usuario '$($user.username)': $_" -ForegroundColor Red
    }
}

# Resumen final
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✓ Configuración Completada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📌 Información importante:" -ForegroundColor Cyan
Write-Host "  - URL Keycloak: $KEYCLOAK_URL" -ForegroundColor White
Write-Host "  - Admin Console: $KEYCLOAK_URL/admin" -ForegroundColor White
Write-Host "  - Realm: $REALM_NAME" -ForegroundColor White
Write-Host "  - Cliente: $CLIENT_ID" -ForegroundColor White
Write-Host "  - Client Secret: $clientSecret" -ForegroundColor Yellow
Write-Host ""
Write-Host "👥 Usuarios creados:" -ForegroundColor Cyan
Write-Host "  1. admin-tpi (Admin123!) - Rol: admin-tpi" -ForegroundColor White
Write-Host "  2. driver1 (Driver123!) - Rol: driver" -ForegroundColor White
Write-Host "  3. dispatcher1 (Dispatcher123!) - Rol: dispatcher" -ForegroundColor White
Write-Host "  4. manager1 (Manager123!) - Rol: manager" -ForegroundColor White
Write-Host ""
Write-Host "📝 Guarda el Client Secret en un lugar seguro:" -ForegroundColor Yellow
Write-Host "  Lo necesitarás para la integración con Spring Boot" -ForegroundColor Yellow
Write-Host ""

