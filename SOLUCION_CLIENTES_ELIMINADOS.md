# Solución: Manejo de Clientes Eliminados

## 📋 Problema Original

Cuando se eliminaba un cliente, el sistema tenía dos opciones:
1. **Reorganizar los IDs**: Decrementar todos los IDs posteriores para mantener una secuencia continua
2. **Mantener los IDs y retornar error**: Eliminar el cliente sin reorganizar IDs y retornar 404 cuando se intente acceder

## ✅ Solución Implementada

Se implementó la **opción 2** (mantener IDs y retornar error 404), que es la práctica recomendada en desarrollo de APIs REST.

## 🎯 Ventajas de Esta Solución

### 1. **Integridad Referencial**
- Los IDs nunca cambian una vez asignados
- Las referencias históricas permanecen válidas
- No se rompen relaciones con otras entidades

### 2. **Rendimiento**
- Solo se elimina un registro (operación O(1))
- No se actualizan múltiples registros
- No hay necesidad de recalcular secuencias

### 3. **Auditoría y Trazabilidad**
- Se puede mantener un historial de qué IDs existieron
- Los logs y registros históricos permanecen consistentes
- Se preserva la cronología de creación

### 4. **Evita Problemas de Concurrencia**
- No hay condiciones de carrera al actualizar múltiples registros
- Operaciones más simples y atómicas
- Menor riesgo de inconsistencias

### 5. **Compatibilidad REST**
- Sigue las mejores prácticas de diseño de APIs RESTful
- Retorna códigos HTTP semánticamente correctos
- Comportamiento predecible y estándar

## 🔧 Cambios Realizados

### 1. Simplificación del Servicio (`ClienteServicio.java`)

**ANTES:**
```java
@Transactional
public void eliminar(Long id) {
    // Paso 1: Actualizar FK en contenedores
    repositorio.decrementContenedorClienteIds(id);
    
    // Paso 2: Eliminar el cliente
    repositorio.deleteById(id);
    
    // Paso 3: Decrementar IDs posteriores
    repositorio.decrementClienteIds(id);
    
    // Paso 4: Reiniciar secuencia
    repositorio.resetSequence(nuevoMaxId + 1);
}
```

**DESPUÉS:**
```java
@Transactional
public void eliminar(Long id) {
    if (!repositorio.existsById(id)) {
        throw new RecursoNoEncontradoException("Cliente", id);
    }
    repositorio.deleteById(id);
}
```

### 2. Limpieza del Repositorio (`ClienteRepositorio.java`)

**ANTES:**
```java
@Repository
public interface ClienteRepositorio extends JpaRepository<Cliente, Long> {
    boolean existsByEmail(String email);
    
    @Modifying
    @Query("UPDATE contenedores SET id_cliente = id_cliente - 1 WHERE id_cliente > :deletedId")
    void decrementContenedorClienteIds(@Param("deletedId") Long deletedId);
    
    @Modifying
    @Query("UPDATE clientes SET id = id - 1 WHERE id > :deletedId")
    void decrementClienteIds(@Param("deletedId") Long deletedId);
    
    @Modifying
    @Query("ALTER SEQUENCE clientes_id_seq RESTART WITH :nextId")
    void resetSequence(@Param("nextId") Long nextId);
}
```

**DESPUÉS:**
```java
@Repository
public interface ClienteRepositorio extends JpaRepository<Cliente, Long> {
    boolean existsByEmail(String email);
}
```

### 3. Uso de Excepciones Personalizadas

- Se reemplazó `RuntimeException` por `RecursoNoEncontradoException`
- El `GlobalExceptionHandler` convierte automáticamente esta excepción en respuesta HTTP 404
- Se usa `DatosInvalidosException` para errores de validación (HTTP 400)

## 📊 Comportamiento del Sistema

### Flujo Normal
```
1. POST /clientes → Crea cliente con ID 1
2. POST /clientes → Crea cliente con ID 2  
3. POST /clientes → Crea cliente con ID 3
4. DELETE /clientes/2 → Elimina cliente ID 2 (retorna 204)
5. GET /clientes → Retorna clientes con IDs: [1, 3]
6. POST /clientes → Crea cliente con ID 4 (NO reutiliza el 2)
```

### Manejo de Errores
```
GET /clientes/2 (eliminado)
↓
RecursoNoEncontradoException lanzada
↓
GlobalExceptionHandler captura la excepción
↓
Retorna HTTP 404 con mensaje:
{
  "timestamp": "2024-11-15T10:30:00",
  "status": 404,
  "error": "Recurso no encontrado",
  "mensaje": "Cliente con ID 2 no encontrado",
  "path": "/api-gestion/clientes/2"
}
```

## 🧪 Pruebas

Para verificar el comportamiento correcto, ejecuta:

```powershell
# Inicia el sistema
.\iniciar-sistema.ps1

# Ejecuta las pruebas
.\test-cliente-eliminado.ps1
```

Las pruebas verifican:
- ✅ Los IDs NO se reorganizan después de eliminar
- ✅ GET a un ID eliminado retorna 404
- ✅ PUT a un ID eliminado retorna 404
- ✅ DELETE a un ID eliminado retorna 404
- ✅ Los nuevos clientes reciben IDs incrementales (no reutilizan)

## 🔍 Validación en Casos de Prueba

El archivo `casos_prueba_tpi_backend.csv` ya incluye la validación:

```csv
Caso 011: DELETE /api-gestion/clientes/999
Esperado: 404 - "Cliente no encontrado con ID: 999"
```

## 📝 Notas Adicionales

### Relación con Contenedores
Los contenedores asociados se manejan mediante:
- **CASCADE**: Si está configurado, se eliminan automáticamente
- **RESTRICT**: Si está configurado, impide eliminar cliente con contenedores
- **SET NULL**: Si está configurado, establece la FK en NULL

Para verificar la configuración actual, revisa la entidad `Contenedor`:
```java
@ManyToOne
@JoinColumn(name = "id_cliente", nullable = false)
private Cliente cliente;
```

### IDs Auto-incrementales
La secuencia de PostgreSQL continúa incrementándose:
- No reutiliza IDs eliminados
- Garantiza unicidad histórica
- No requiere mantenimiento manual

## 🎓 Conclusión

Esta implementación sigue las mejores prácticas de:
- Diseño de APIs RESTful
- Integridad de datos
- Rendimiento de bases de datos
- Mantenibilidad del código

Es la solución estándar utilizada por frameworks modernos y servicios en producción.
