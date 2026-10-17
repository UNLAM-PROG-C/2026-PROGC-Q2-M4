# Data Model: Animación de Desbloqueo de Recompensa al Ganar Nivel

**Feature**: `015-animacion-desbloqueo-recompensa`  
**Date**: 2026-10-12

## Entities

### 1. `RewardData` (Resource / RefCounted)

Representa la información de recompensa asignada a un nivel completado.

- **Attributes**:
  - `level_number: int`: Número del nivel al que pertenece la recompensa (1..10).
  - `item_name: String`: Identificador temático de la recompensa (`Remembrall`, `Protego`, `Accio`, `Ron`, `Broomstick`, `Hermione`, `McGonagall`, `Dumbledore`, `PhilosophersStone`).
  - `texture: Texture2D`: Textura visual de la semilla, herramienta o trofeo.
  - `description_text: String`: Texto descriptivo explicativo en español mostrado debajo del elemento.
- **Constraints**:
  - `description_text` no debe estar vacío para niveles con recompensa.
  - `texture` debe ser una referencia válida a un recurso gráfico importado.

---

### 2. `RewardCatalog` (Helper / Const Dictionary)

Catálogo centralizado que mapea cada nivel a su respectivo `RewardData`.

```text
Level 1  --> Semilla Recordadora       ("Images/seed_remembrall.png")
Level 2  --> Semilla Protego           ("Images/seed_protego.png")
Level 3  --> Herramienta Accio         ("Images/elder_wand.png")
Level 4  --> Semilla Ron               ("Images/seed_ron.png")
Level 5  --> Semilla Escoba            ("Images/seed_broomstick.png")
Level 6  --> Semilla Hermione          ("Images/seed_hermione.png")
Level 7  --> Semilla McGonagall        ("Images/seed_mcgonagall.png")
Level 8  --> Semilla Dumbledore        ("Images/seed_dumbledore.png")
Level 9  --> null                      (Sin recompensa)
Level 10 --> Trofeo Piedra Filosofal   ("Images/trophy_philosophers_stone.png")
```

---

### 3. `RewardUnlockScreen` (Node: CanvasLayer / Control)

Escena visual que orquesta la presentación y cinemática en pantalla completa (1920x1080).

- **Node Hierarchy**:
  ```text
  RewardUnlockScreen (CanvasLayer, layer = 100)
  └── RootControl (Control, anchors = full_rect)
      ├── BlurBackground (ColorRect + ShaderMaterial / tint overlay)
      ├── SeedAnchor (Control, pivot_offset = centered)
      │   └── SeedIcon (TextureRect, expand_mode = keep_aspect_centered)
      ├── DescriptionLabel (Label, autowrap = true, align = center)
      └── ContinueButton (Button, text = "Continuar")
  ```

- **Lifecycle & States**:
  - `STATE_ANIMATING`: La semilla realiza rotación y zoom in mediante un `Tween`. El clic en pantalla provoca `skip_animation()`.
  - `STATE_RESTING`: La semilla se encuentra en reposo, el texto descriptivo está completamente visible y el botón "Continuar" está habilitado.
  - `STATE_DISMISSED`: El botón "Continuar" fue presionado; la pantalla emite `reward_dismissed` y se destruye (`queue_free()`).

- **Signals**:
  - `signal reward_dismissed(level_number: int)`: Notifica al nivel que el usuario terminó de revisar la recompensa.

---

### 4. `GameManager` (Autoload Extension)

Gestiona la persistencia de sesión de recompensas ya reclamadas para el control de rejugabilidad.

- **Attributes**:
  - `claimed_rewards: Dictionary`: Mapeo clave-valor (`level_number: int -> bool`).
- **Methods**:
  - `claim_reward(level_number: int) -> void`: Marca la recompensa del nivel como ya otorgada.
  - `is_reward_claimed(level_number: int) -> bool`: Retorna verdadero si la recompensa ya fue visualizada en la sesión actual.
