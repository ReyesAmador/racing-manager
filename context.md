# 🏎️ Racing Manager - Contexto del Proyecto

Este documento centraliza la visión, mecánicas y arquitectura técnica del juego extraída de la documentación oficial. Sirve como referencia rápida para el desarrollo con IA.

## 📋 Visión General
- **Género**: Gestión deportiva / Simulación de carreras de monoplazas.
- **Plataforma**: PC.
- **Motor**: Godot 4.x.
- **Estética**: Interfaz limpia, minimalista pero informativa. Carreras inicialmente en 2D (con proyección a 3D en el futuro).

---

## 🗺️ Roadmap de Desarrollo (Fases)

1. **Fase 0 - Setup y base técnica**: Proyecto en Godot, estructura de carpetas (core vs game), escena inicial.
2. **Fase 1 - MVP (Carrera simulada básica)**: Lógica de simulación por vueltas, atributos básicos del piloto. Interfaz simple de simulación. *No incluir: neumáticos, estrategia, clima.*
3. **Fase 2 - Profundidad básica**: Neumáticos (blando/medio/duro), desgaste simple, pit stops básicos, diferencias entre pilotos.
4. **Fase 3 - Estrategia**: Estrategias de 1 o 2 paradas, IA de pit stop, influencia de neumáticos en rendimiento, interfaz de selección de estrategia pre-carrera.
5. **Fase 4 - Manager layer**: Creación del modo manager (equipos, presupuesto, mejora de coche, desarrollo de piezas, pilotos complejos, HQ).
6. **Fase 5 - Mundo persistente**: Temporadas completas, clasificación, guardado/carga, paso del tiempo.
7. **Fase 6 - Profundidad avanzada**: Clima dinámico, safety car, eventos, fallos mecánicos complejos, telemetría. *(No prioritario por ahora)*.

---

## ⚙️ Mecánicas Core

### 1. Simulación de Carrera
El cálculo del tiempo por vuelta (LapTime) se define con la siguiente fórmula base:
`LapTime = BaseTime + (FricciónPista) + (EstadoClima) - (HabilidadPiloto * RendimientoCoche)`

- **Variables de Pista**: Grip evolutivo (la pista se engoma) y 4 estados de agua (Seco, Húmedo, Agua, Mojado).
- **Estrategia en Tiempo Real**: 
  - *Modo Motor/Rendimiento*: Ahorro, Normal, Push (afecta a gomas, gasolina y motor).
  - *Gestión ERS*: Uso de energía eléctrica.
  - *Órdenes de equipo*.
  - *Comportamiento de Piloto*: Defender, Normal, Atacar (solo activo si hay un coche a menos de 1.5s).

### 2. Gestión de Sede (HQ) y Equipo
La clase `Equipo` es central en la partida.
- **Atributos de Equipo**: Presupuesto, prestigio (afecta negociaciones), fan base, instalaciones.
- **Relaciones**: Plantilla de pilotos, staff técnico (Ingeniero Jefe, Jefe Mecánicos), coche actual, motor.

### 3. I+D y Desarrollo del Coche (Piezas)
El rendimiento del coche está dictado por sus piezas. Las características del circuito dictan qué piezas son más relevantes (ej. Mónaco vs Monza).
- **Atributos de Pieza**: Rendimiento, Fiabilidad (riesgo de DNF), Nivel de Riesgo (ilegalidad/sanción), Peso (afecta desgaste y aceleración).
- **Categorías**:
  - *Alerones (Delantero/Trasero)*: Afectan a curvas rápidas y velocidad punta.
  - *Chasis*: Afecta consistencia y desgaste de neumáticos.
  - *Suspensión*: Clave para curvas lentas y pianos.
  - *Pontones*: Refrigeración (afecta fiabilidad general).
  - *Frenos*: Afectan estadísticas de adelantamiento y defensa.
- **I+D**: Se puede elegir desarrollar la fiabilidad de una pieza vs su rendimiento puro.

### 4. Sistema de Motores
- **Modelo Cliente**: Comprar un motor a proveedores existentes. Más barato y fiable (al usarlo más equipos), pero con poco control sobre su desarrollo.
- **Modelo Constructor**: Fabricar un motor propio. Control total de evolución y venta a clientes, pero más costoso y con mayor riesgo de baja fiabilidad.
- **Atributos**: Rendimiento, Fiabilidad, Desgaste, Peso, Riesgo, Potencia, Velocidad Punta, Gestión Energía (híbridos). Evoluciona entre temporadas basado en el "Market Share".

---

## 🏗️ Arquitectura de Datos en Godot

El proyecto hace un uso intensivo de **Resources** (`Resource` en Godot) para almacenar datos puros:
- `res_piloto.gd`: Guarda estadísticas del piloto (habilidad, agresividad, desempeño en lluvia, etc).
- `res_pieza.gd`: Guarda los atributos y rendimiento de un componente específico.
- `res_circuito.gd`: Configuración de la pista (longitud, tipos de curvas, clima base).
- `clase_equipo.gd` / `clase_race.gd`: Gestores del estado de la escudería y de la sesión de carrera.

### Escenas Principales
- **Main Menu**: Gestión de inicio de partida, carga y opciones.
- **Sede (HQ)**: Interfaz pesada de gestión (botones, tablas, I+D, staff).
- **Carrera**: Interfaz de simulación (timers, menús de piloto/coche, neumáticos, tiempos de vuelta).

---

> **Nota para la IA**: Respeta las versiones de herramientas, prioriza código limpio y estructurado. Si un `if` o `for` básico se puede hacer en una línea, hazlo. Cada función debe incluir un comentario descriptivo. No asumas características no descritas en este documento o en los prompts del usuario.