# AGENTS.md

Este archivo define las condiciones de codificación exigidas por la cátedra para todo el repositorio. Aplica a todas las carpetas (`TP1-*`, `TP2-*`, `TP-Integrador`, etc.) y a todos los lenguajes usados (C++, Python, Java, otros). Cualquier agente o persona que escriba código en este repo debe seguir estas reglas.

## 1. Coding Standard

Base: [Google Style Guide](https://google.github.io/styleguide/) para el lenguaje correspondiente:

- C++: [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html) — ver `.clang-format` en la raíz, ya configurado sobre esta base.
- Python: [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html).
- Java: [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html).

## 2. Ajustes específicos de la cátedra

- Llaves (`{`/`}`) en la misma columna (estilo Allman), no al final de línea como indica Google por defecto. Ya reflejado en `.clang-format` (`BreakBeforeBraces: Allman`).

## 3. Indentación

- Espacios, nunca tabulaciones.
- 2 espacios por nivel de indentación, en todos los lenguajes.

## 4. Tamaño de métodos/funciones

- Ningún método o función debe superar las 15 líneas. Si una función crece más allá de eso, dividirla en funciones más pequeñas con responsabilidad única.

## 5. Patrones de diseño

- Cuando el problema lo justifique, aplicar patrones de diseño reconocidos (Strategy, Factory, Observer, etc.) en lugar de soluciones ad-hoc. Justificar la elección del patrón cuando no sea evidente.

## 6. Números mágicos

- Prohibido el uso de números (o strings) mágicos embebidos en la lógica.
- Usar constantes con nombres descriptivos que expliquen su significado.

## 7. Idioma del código

- Todo el código (identificadores, nombres de variables/funciones/clases, comentarios) debe estar en inglés, sin excepción.
- La documentación del repositorio (README, enunciados, este archivo) puede mantenerse en español.

## Referencias

- `.clang-format` (raíz del repo): configuración formal para C++, alineada a los puntos 1 y 2.
- `README.md`: resumen de criterios de validación usados en los code-reviews.
