# Mapa de renombres

Fuente única para el renombrado de la User Story 2 y para `tools/check_rules.gd`. El chequeo lee la primera columna (**Actual**) de todas las tablas y la busca como palabra completa (sensible a mayúsculas) en el alcance definido en [research.md R1](./research.md#r1-alcance-de-archivos). Ignora las líneas `text = ...` de los `.tscn`, las constantes `*_TEXT` de los `.gd` (textos visibles en español) y las rutas bajo `res://Imagenes/` (assets fuera de alcance).

Reglas:

- Solo figuran identificadores que cambian. `Harry`, `Draco`, `Protego`, `Snitch`, `Dementor`, `Sprite2D`, `TOTAL_FRAMES`, `escape_*`, etc. ya cumplen y no se listan.
- `Level.snitches` pasa a `_snitches` (solo cambia la visibilidad) y no figura porque la palabra también es texto de UI.
- Las variables locales y los parámetros no figuran: se traducen en el mismo commit que su función y se revisan a mano (ver [quickstart.md](./quickstart.md)).
- **Nuevo** = `—` indica que el identificador se elimina (código muerto, ver [research.md R12](./research.md#r12-código-muerto-y-depuración)) o pasa a otra estructura en la User Story 3 (columna Notas).

## Archivos

El `.uid` de cada script se mueve con él. Las escenas conservan su `uid://`.

| Actual | Nuevo | Notas |
| --- | --- | --- |
| `alumno_slytherin` | `slytherin_student` | `.gd`, `.gd.uid`, `.tscn` |
| `caja_snitch` | `snitch_box` | `.gd`, `.gd.uid`, `.tscn` |
| `recordadora` | `remembrall` | `.gd`, `.gd.uid`, `.tscn` |
| `Proyectil` | `projectile` | `.gd`, `.gd.uid`, `.tscn`. La textura `Imagenes/Proyectil.png` no cambia (R1) |
| `huella` | `footprint` | `.gd`, `.gd.uid` |
| `menu_niveles` | `level_select_menu` | `.gd`, `.gd.uid`, `.tscn` |
| `nivel_principal` | `level` | `.gd`, `.gd.uid`. Script compartido por los tres niveles |
| `NivelPrincipal` | `level_1` | `.tscn` (también nombre de clase y de nodo raíz, ver abajo) |
| `nivel_2` | `level_2` | `.tscn` |
| `nivel_3` | `level_3` | `.tscn` |
| `pergamino` | `parchment` | `.gdshader`, `.gdshader.uid` |

## Clases (`class_name`)

| Actual | Nuevo | Notas |
| --- | --- | --- |
| `AlumnoSlytherin` | `SlytherinStudent` | `extends Enemy` en la User Story 3 |
| `CajaSnitch` | `SnitchBox` | `extends Ally` en la User Story 3 |
| `Proyectil` | `Projectile` | |
| `Huella` | `Footprint` | |
| `MenuNiveles` | `LevelSelectMenu` | |
| `NivelPrincipal` | `Level` | |
| — | `Remembrall` | `recordadora.gd` hoy no tiene `class_name` |

## Grupos

| Actual | Nuevo | Notas |
| --- | --- | --- |
| `aliados` | `allies` | `.tscn`, `project.godot` `[global_group]`, constante `Groups.ALLIES` |
| `enemigos` | `enemies` | ídem, `Groups.ENEMIES` |
| `hechizos` | `spells` | ídem, `Groups.SPELLS` |
| `dementores` | `dementors` | `dementor.tscn`, `Groups.DEMENTORS` |

## Señales

| Actual | Nuevo | Notas |
| --- | --- | --- |
| `derrotado` | `defeated` | Aliados y enemigos. Pasa a `Ally` y `Enemy` |
| `invasion_jardin` | `garden_invaded` | Pasa a `Enemy` |
| `snitch_soltada` | `snitch_dropped` | `SnitchBox` |
| `snitches_generadas` | — | Código muerto |
| `recogida` | `collected` | `Snitch` |
| `activado` | `activated` | `Dementor` |
| `agotado` | `exhausted` | `Dementor` |
| `destruida_sin_explotar` | — | Pasa a `defeated` de `Ally` |
| `detonada` | `detonated` | `Remembrall` |
| `nivel_seleccionado` | `level_selected` | `LevelSelectMenu` |

## Métodos

| Actual | Nuevo | Notas |
| --- | --- | --- |
| `recibir_danio` | `take_damage` | Firma `(amount: float) -> void` en todas las entidades |
| `_on_timer_animacion_timeout` | `_on_animation_timer_timeout` | Enemigos, `Snitch` |
| `_on_area_deteccion_area_entered` | `_on_detection_area_area_entered` | Pasa a `Enemy` |
| `_on_area_deteccion_area_exited` | `_on_detection_area_area_exited` | Pasa a `Enemy` |
| `_on_timer_disparo_timeout` | `_on_shoot_timer_timeout` | `Harry` |
| `_hay_enemigo_en_linea` | `_has_enemy_in_lane` | `Harry`, usa `Lane` |
| `_on_timer_generacion_snitches_timeout` | `_on_snitch_timer_timeout` | `SnitchBox` |
| `iniciar_detona` | `start_fuse` | `Remembrall` |
| `_on_TimerDetonate_timeout` | `_on_fuse_timer_timeout` | `Remembrall` |
| `detonar` | `detonate` | `Remembrall` |
| `activar` | `activate` | `Dementor` |
| `_verificar_enemigos_en_posicion` | `_check_enemies_at_position` | `Dementor` |
| `_barrer_fila` | `_sweep_lane` | `Dementor` |
| `_eliminar_enemigo` | `_kill_enemy` | `Dementor` |
| `configurar_de_caja` | `setup_from_box` | `Snitch` |
| `_recoger` | `_collect` | `Snitch` |
| `configurar` | `setup` | `Footprint` |
| `_generar_puntos_elipse` | `_build_ellipse_points` | `Footprint` |
| `desvanecer` | `fade_out` | `Footprint` |
| `_sincronizar_progresion_global` | — | Reemplazado por `GameManager` |
| `_inicializar_botones` | `_setup_level_buttons` | `LevelSelectMenu` |
| `_aplicar_estilo_pergamino_boton` | — | Reemplazado por `level_button_theme.tres` |
| `_actualizar_estado_niveles` | `_refresh_level_buttons` | |
| `_on_boton_nivel_pressed` | `_on_level_button_pressed` | |
| `_iniciar_huellas_camino` | `_start_path_footprints` | |
| `_animar_pasos_en_camino` | `_schedule_path_steps` | |
| `_crear_huella_en_posicion` | `_spawn_path_footprint` | |
| `_configurar_timer_ambiental` | `_setup_ambient_timer` | |
| `_reiniciar_timer_ambiental` | `_restart_ambient_timer` | |
| `_on_timer_ambiental_timeout` | `_on_ambient_footprints_timer_timeout` | |
| `_generar_caminante_ambiental` | `_spawn_ambient_walker` | |
| `_instanciar_huella_ambiental` | `_spawn_ambient_footprint` | |
| `_obtener_huella_del_pool` | `_take_footprint_from_pool` | |
| `_devolver_huella_al_pool` | `_return_footprint_to_pool` | |
| `_crear_dementores` | `_spawn_dementors` | `Level` |
| `_actualizar_hud` | `_refresh_hud` | |
| `_intentar_plantar` | `_try_place_ally` | |
| `_on_snitch_soltada` | `_on_snitch_dropped` | |
| `_on_snitches_generadas` | — | Código muerto |
| `_on_spawner_de_snitches_timeout` | `_on_snitch_spawn_timer_timeout` | |
| `_on_snitch_recogida` | `_on_snitch_collected` | |
| `_on_aliado_eliminado` | `_on_ally_removed` | |
| `_on_timer_spawneo_timeout` | `_on_enemy_spawn_timer_timeout` | |
| `_on_enemigo_derrotado` | `_on_enemy_defeated` | |
| `_on_invasion_jardin` | `_on_garden_invaded` | |
| `_verificar_victoria` | `_check_victory` | |
| `_victoria` | `_win` | |
| `_derrota` | `_lose` | |
| `_on_boton_siguiente_nivel_pressed` | `_on_next_level_button_pressed` | |
| `_on_boton_volver_mapa_pressed` | `_on_back_to_map_button_pressed` | |
| `_on_boton_reintentar_pressed` | `_on_retry_button_pressed` | |
| `_volver_al_mapa` | `_go_to_map` | |
| `_on_boton_harry_pressed` | — | Reemplazado por `AllyCardButton.card_pressed` |
| `_on_boton_caja_snitch_pressed` | — | ídem |
| `_on_boton_recordadora_pressed` | — | ídem |
| `_on_boton_protego_pressed` | — | ídem |
| `_actualizar_seleccion_visual` | `_refresh_card_selection` | |

## Variables exportadas

Cada una se renombra también en las líneas de propiedades de los `.tscn` que la asignan.

| Actual | Nuevo | Notas |
| --- | --- | --- |
| `salud_maxima` | `max_health` | `Enemy`. `draco.tscn` fija `max_health = 400.0` |
| `velocidad` | `speed` | Enemigos, `Projectile`, `Dementor` |
| `danio_por_segundo` | `damage_per_second` | `Enemy` |
| `textura_lastimado` | `hurt_texture` | `Enemy` |
| `coste` | — | Se conserva en US2 y se elimina en US3 (T047–T050): pasa a `AllyCard.cost` |
| `tiempo_recarga` | — | En `Harry` se renombra a `shot_interval` en US2 (T018). En `Protego` y `Remembrall` se conserva hasta US3 y se elimina: pasa a `AllyCard.cooldown` (T048, T050) |
| `salud` | `health` | Pasa a `Ally` |
| `escena_proyectil` | `projectile_scene` | `Harry` |
| `snitches_por_generacion` | `snitches_per_drop` | `SnitchBox` |
| `tiempo_generacion` | `drop_interval` | `SnitchBox` |
| `escena_snitch` | `snitch_scene` | `SnitchBox`, `Level` |
| `danio` | `damage` | `Projectile`, `Dementor` |
| `valor` | `value` | `Snitch` |
| `velocidad_caida` | `fall_speed` | `Snitch` |
| `tiempo_vida` | `lifetime` | `Snitch` |
| `zigzag_amplitud` | `zigzag_amplitude` | `Snitch` |
| `zigzag_frecuencia` | `zigzag_frequency` | `Snitch` |
| `color_tinta` | `ink_color` | `Footprint` (y uniform del shader) |
| `es_pie_derecho` | `is_right_foot` | `Footprint` |
| `radio_suela` | `sole_radius` | `Footprint` |
| `radio_talon` | `heel_radius` | `Footprint` |
| `distancia_talon` | `heel_distance` | `Footprint` |
| `nivel_maximo_desbloqueado` | — | Pasa a `GameManager.max_unlocked_level` |
| `escena_nivel_principal` | — | Pasa a `level_scenes[0]` |
| `escena_nivel_2` | — | Pasa a `level_scenes[1]` |
| `escena_nivel_3` | — | Pasa a `level_scenes[2]` |
| `paso_distancia` | `step_distance` | `LevelSelectMenu` |
| `separacion_lateral` | `foot_spacing` | |
| `intervalo_paso_camino` | `path_step_interval` | |
| `huellas_ambientales_activas` | `ambient_footprints_enabled` | |
| `tiempo_aparicion_min` | `walker_spawn_min_time` | |
| `tiempo_aparicion_max` | `walker_spawn_max_time` | |
| `max_caminantes_simultaneos` | `max_active_walkers` | |
| `pasos_minimos` | `walker_min_steps` | |
| `pasos_maximos` | `walker_max_steps` | |
| `snitches_iniciales` | `starting_snitches` | `Level` |
| `total_enemigos` | `total_enemies` | |
| `escena_harry` | — | Pasa a `harry_card.tres` |
| `escena_caja_snitch` | — | Pasa a `snitch_box_card.tres` |
| `escena_recordadora` | — | Pasa a `remembrall_card.tres` |
| `escena_protego` | — | Pasa a `protego_card.tres` |
| `escena_alumno_slytherin` | — | Pasa a `enemy_scenes` |
| `escena_draco` | — | Pasa a `enemy_scenes` |
| `tiempo_recarga_protego` | — | Pasa a `protego_card.tres` |
| `escena_dementor` | `dementor_scene` | |
| `escena_menu_niveles` | `level_select_scene` | |
| `filas_activas` | `active_rows` | |
| `spawners_activos` | `spawn_points` | Nivel 1 pasa a tener `[Spawners/Marker2D3]` |
| `nivel_siguiente_desbloqueo` | `next_level_to_unlock` | |

## Variables de miembro y constantes no exportadas

| Actual | Nuevo | Notas |
| --- | --- | --- |
| `salud_actual` | `_health` | `Enemy` |
| `aliado_objetivo` | `_target_ally` | `Enemy` |
| `_lastimado` | `_is_hurt` | `Enemy` |
| `_tiempo_flash` | — | Pasa a `DamageFlash` |
| `_cooldown_flash` | — | Pasa a `DamageFlash` |
| `_esta_activo` | `_is_active` | `Dementor` |
| `_impacto_registrado` | `_has_hit` | `Projectile` |
| `_tiempo_restante` | `_time_left` | `Snitch` |
| `_fue_recogida` | `_is_collected` | `Snitch` |
| `_tiempo_total` | `_elapsed` | `Snitch` |
| `_tiempo_escape_restante` | `_escape_time_left` | `Snitch` |
| `_dir_escape` | `_escape_direction` | `Snitch` |
| `animada` | `_is_animated` | `Snitch` |
| `_opacidad_base` | `_base_opacity` | `Footprint` |
| `progreso_desbloqueado` | — | Variable estática, pasa a `GameManager` |
| `path_camino` | `level_path` | `LevelSelectMenu` |
| `contenedor_botones` | `level_buttons_container` | |
| `capa_huellas_camino` | `path_footprints_layer` | |
| `capa_huellas_ambientales` | `ambient_footprints_layer` | |
| `timer_ambiental` | `ambient_footprints_timer` | |
| `botones_niveles` | `_level_buttons` | |
| `_pool_huellas` | `_footprint_pool` | |
| `_caminantes_activos` | `_active_walkers` | |
| `aliado_seleccionado` | `_selected_card` | Pasa de `String` a `AllyCard` |
| `celdas_ocupadas` | `_occupied_cells` | |
| `tiempo_recarga_recordadora` | — | Pasa a `AllyCardButton` |
| `tiempo_recarga_protego_actual` | — | Pasa a `AllyCardButton` |
| `enemigos_generados` | `_spawned_enemies` | |
| `enemigos_derrotados` | `_defeated_enemies` | |
| `nivel_terminado` | `_is_level_over` | |
| `spawner_central` | — | Reemplazado por `spawn_points` |
| `timer_spawneo` | `enemy_spawn_timer` | |
| `timer_spawner_snitches` | `snitch_spawn_timer` | |
| `label_snitches` | `snitches_label` | |
| `boton_harry` | — | Los botones se recorren como `AllyCardButton` |
| `boton_caja_snitch` | — | ídem |
| `boton_recordadora` | — | ídem |
| `boton_protego` | — | ídem |
| `label_estado` | `status_label` | |
| `panel_fin_nivel` | `level_end_panel` | |
| `label_titulo_fin` | `end_title_label` | |
| `label_mensaje_fin` | `end_message_label` | |
| `boton_siguiente_nivel` | `next_level_button` | |
| `boton_reintentar` | `retry_button` | |
| `boton_volver_mapa` | `back_to_map_button` | |

## Nodos

Cambia el nombre del nodo en el `.tscn`, toda ruta `$...` o `get_node(...)` que lo use y los `from=`/`parent=` de las conexiones.

| Actual | Nuevo | Escenas |
| --- | --- | --- |
| `AlumnoSlytherin` | `SlytherinStudent` | `slytherin_student.tscn` (raíz) |
| `CajaSnitch` | `SnitchBox` | `snitch_box.tscn` (raíz) |
| `Recordadora` | `Remembrall` | `remembrall.tscn` (raíz) |
| `Proyectil` | `Projectile` | `projectile.tscn` (raíz) |
| `MenuNiveles` | `LevelSelectMenu` | `level_select_menu.tscn` (raíz) |
| `Nivel2` | `Level2` | `level_2.tscn` (raíz) y `level_select_menu.tscn` (botón) |
| `Nivel3` | `Level3` | `level_3.tscn` (raíz) y menú (botón) |
| `Nivel1` | `Level1` | `level_select_menu.tscn` (botón) |
| `Nivel4` | `Level4` | ídem |
| `Nivel5` | `Level5` | ídem |
| `Nivel6` | `Level6` | ídem |
| `Nivel7` | `Level7` | ídem |
| `Nivel8` | `Level8` | ídem |
| `Nivel9` | `Level9` | ídem |
| `Nivel10` | `Level10` | ídem |
| `AreaDeteccion` | `DetectionArea` | Enemigos |
| `TimerAnimacion` | `AnimationTimer` | Enemigos, `snitch.tscn` |
| `PuntoDisparo` | `ShootPoint` | `harry.tscn` |
| `TimerDisparo` | `ShootTimer` | `harry.tscn` |
| `TimerGeneracionSnitches` | `SnitchTimer` | `snitch_box.tscn` |
| `AreaExplosion` | `ExplosionArea` | `remembrall.tscn` |
| `TimerDetonate` | `FuseTimer` | `remembrall.tscn` |
| `ParticulasEscape` | `EscapeParticles` | `snitch.tscn` |
| `Capa` | `Cloak` | `dementor.tscn` |
| `Ojos` | `Eyes` | `dementor.tscn` |
| `Ojos2` | `Eyes2` | `dementor.tscn` |
| `BloqueoMagico` | `MagicBarrier` | Niveles |
| `Fila2` | `Row2` | Niveles |
| `Fila3` | `Row3` | Niveles |
| `Fila5` | `Row5` | Niveles |
| `Fila6` | `Row6` | Niveles |
| `TimerSpawneoMortifagos` | `EnemySpawnTimer` | Niveles |
| `SpawnerDeSnitches` | `SnitchSpawnTimer` | Niveles |
| `LabelSnitches` | `SnitchesLabel` | Niveles |
| `BotonHarry` | `HarryCardButton` | Niveles |
| `BotonCajaSnitch` | `SnitchBoxCardButton` | Niveles |
| `BotonRecordadora` | `RemembrallCardButton` | Niveles |
| `BotonProtego` | `ProtegoCardButton` | `level_3.tscn` |
| `LabelEstado` | `StatusLabel` | Niveles |
| `PanelFinNivel` | `LevelEndPanel` | Niveles |
| `FondoOscuro` | `DarkOverlay` | Niveles |
| `CajaModal` | `ModalBox` | Niveles |
| `LabelTitulo` | `TitleLabel` | Niveles |
| `LabelMensaje` | `MessageLabel` | Niveles |
| `Espaciador` | `Spacer` | Niveles |
| `HBoxBotones` | `ButtonsRow` | Niveles |
| `BotonSiguienteNivel` | `NextLevelButton` | Niveles |
| `BotonReintentar` | `RetryButton` | Niveles |
| `BotonVolverMapa` | `BackToMapButton` | Niveles |
| `FondoPergamino` | `ParchmentBackground` | Menú |
| `CapaHuellasAmbientales` | `AmbientFootprintsLayer` | Menú |
| `CaminoNiveles` | `LevelPath` | Menú |
| `CapaHuellasCamino` | `PathFootprintsLayer` | Menú |
| `Titulo` | `Title` | Menú |
| `Subtitulo` | `Subtitle` | Menú |
| `ContenedorBotones` | `LevelButtons` | Menú |
| `TimerHuellasAmbientales` | `AmbientFootprintsTimer` | Menú |

## Uniforms y funciones del shader

Cada uniform se renombra también en las líneas `shader_parameter/...` de `level_select_menu.tscn`. Las variables locales del shader (`luminosidad`, `manchas`, `ruido`, `tinta_factor`, `vinieta`, `dist_centro`, `uv_centrada`, `uv_mapa`) se traducen en el mismo commit.

| Actual | Nuevo |
| --- | --- |
| `color_pergamino_arriba` | `parchment_top_color` |
| `color_pergamino_medio` | `parchment_middle_color` |
| `color_pergamino_abajo` | `parchment_bottom_color` |
| `color_mancha` | `stain_color` |
| `mapa_texture` | `map_texture` |
| `opacidad_mapa` | `map_opacity` |
| `escala_mapa` | `map_scale` |
| `desplazamiento_mapa` | `map_offset` |
| `contraste_tinta` | `ink_contrast` |
| `intensidad_vinieta` | `vignette_intensity` |
| `radio_vinieta` | `vignette_radius` |
| `intensidad_manchas` | `stain_intensity` |
| `intensidad_grano` | `grain_intensity` |
| `mancha_radial` | `radial_stain` |
