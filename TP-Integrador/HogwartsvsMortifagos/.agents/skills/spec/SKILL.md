---
name: spec
description: Alias para speckit-specify. Crea o actualiza una especificación de funcionalidad técnica (Spec) usando el estándar de Spec Kit.
compatibility: "Requiere la estructura de Spec Kit (.specify/)"
---

## Entrada del usuario

```text
$ARGUMENTS
```

## Procedimiento

Este comando es el atajo canónico para `/speckit-specify`.

Al invocarse `/spec`:
1. Toma el texto proporcionado como la descripción de la funcionalidad.
2. Sigue de forma estricta el flujo de ejecución, plantillas y reglas definidas en [.agents/skills/speckit-specify/SKILL.md](../speckit-specify/SKILL.md).
3. Utiliza la plantilla de `.specify/templates/spec-template.md` y guarda la especificación en `specs/<NNN>-<nombre>/spec.md`.
4. Genera la checklist de calidad correspondiente en `specs/<NNN>-<nombre>/checklists/requirements.md`.
