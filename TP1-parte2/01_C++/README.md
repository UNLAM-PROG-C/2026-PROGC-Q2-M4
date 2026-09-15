# Naruto - Entrenamiento de clones (C++20)

Simula el entrenamiento de `N` clones de sombra. Cada clon corre en
su propio hilo, acumula chakra de forma aleatoria y, al terminar, se suman los
niveles alcanzados por todos los clones.

## `std::jthread`

Se usa `std::jthread` (`<thread>`, C++20) en lugar de `std::thread`.
`jthread` hace join automático en su destructor:
al salir del scope del `std::vector<std::jthread>` en `Entrenar`, el programa
espera a que todos los clones terminen antes de sumar los resultados, sin
necesidad de llamar `.join()` manualmente en cada uno.

Por eso el código necesita compilarse con el estándar **C++20** (`-std=c++20`),
ya que `std::jthread` no existe en estándares anteriores.

## Compilación

### Linux / macOS

Requiere un compilador con soporte de C++20 (GCC 10+ o Clang 12+) y `make`.

```bash
make
```

El ejecutable queda en `build/naruto`.

Para limpiar los artefactos de compilación:

```bash
make clean
```

### Windows

**Opción A - WSL:** instalar WSL con Ubuntu y seguir los pasos
de Linux de arriba.

**Opción B - MSYS2/MinGW:** instalar [MSYS2](https://www.msys2.org/), abrir la
terminal MSYS2 UCRT64 e instalar `make` y `g++`:

```bash
pacman -S mingw-w64-ucrt-x86_64-gcc make
make
```

El ejecutable queda en `build\naruto.exe`.

## Ejecución

El programa recibe la cantidad de clones a entrenar como argumento:

```bash
./build/naruto 5      # Linux / macOS
build\naruto.exe 5    # Windows
```

Salida esperada:

```text
Nivel alcanzado: <suma de niveles>
Tiempo de ejecución: <ms> ms
```
