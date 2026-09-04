# Pruebas y defensa

## Casos mínimos

| ID | Caso | Resultado esperado |
|---|---|---|
| CP-01 | Login válido | abre el sistema |
| CP-02 | Login inválido | muestra error |
| CP-03 | Crear reporte | aparece en lista y BD |
| CP-04 | GPS permitido | captura coordenadas |
| CP-05 | GPS denegado | muestra mensaje controlado |
| CP-06 | API disponible | guarda clima |
| CP-07 | API falla | se puede continuar sin romper la app |
| CP-08 | Cargar imagen | aparece en Storage y detalle |
| CP-09 | Editar propio | actualiza fila |
| CP-10 | Eliminar propio | elimina fila |
| CP-11 | Usuario normal edita ajeno | RLS impide la operación |
| CP-12 | Preferencia tema | sobrevive al reinicio |
| CP-13 | APK release | instala y ejecuta |

## Defensa de 7 minutos

1. Problema: 40 s.
2. Arquitectura: 50 s.
3. Demo funcional: 3 min.
4. Seguridad y datos: 1 min.
5. Pruebas: 40 s.
6. Git + APK: 50 s.

No memorices código. Explica el viaje de los datos.
