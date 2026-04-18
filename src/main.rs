// ============================================================
// Proyecto-2050-Calico: Simulación de longevidad humana
// Rust Implementation - Translated from Python (Biopython)
// Autor: Implementación Rust
// Fecha: Marzo 2026
// Objetivo: Proyectar esperanza de vida bajo escenarios de intervención biotecnológica
// ============================================================

use std::fmt::Write;

// ============================================================
// Estructuras de Datos
// ============================================================

/// Parámetros biológicos y demográficos iniciales
#[derive(Debug, Clone)]
pub struct ParametrosLongevidad {
    pub esperanza_vida_actual: f64,      // años (promedio global aproximado 2025-2026)
    pub tasa_envejecimiento_base: f64,   // incremento anual aproximado sin intervención
    pub reduccion_tasa_por_avance: f64,  // reducción hipotética por intervenciones (ej. Calico-style: 40%)
    pub anio_inicio: i32,
    pub anio_horizonte: i32,             // proyección larga (extensible a 2500+ para "500 años")
    pub poblacion_inicial: f64,           // ~8 mil millones
}

impl Default for ParametrosLongevidad {
    fn default() -> Self {
        ParametrosLongevidad {
            esperanza_vida_actual: 78.5,      // años
            tasa_envejecimiento_base: 0.012,  // incremento anual
            reduccion_tasa_por_avance: 0.40,  // 40% reducción
            anio_inicio: 2026,
            anio_horizonte: 2100,              // extensible a 2500+
            poblacion_inicial: 8_000_000_000.0, // ~8 mil millones
        }
    }
}

/// Resultados de la simulación
#[derive(Debug, Clone)]
pub struct ResultadosSimulacion {
    pub anios: Vec<i32>,
    pub esperanza_vida: Vec<f64>,
    pub poblacion: Vec<f64>,
}

/// Motor de simulación de escenarios de longevidad
pub struct SimuladorLongevidad {
    params: ParametrosLongevidad,
    resultados: Option<ResultadosSimulacion>,
}

impl SimuladorLongevidad {
    /// Crea un nuevo simulador con los parámetros dados
    pub fn new(params: ParametrosLongevidad) -> Self {
        SimuladorLongevidad {
            params,
            resultados: None,
        }
    }

    /// Crea un simulador con parámetros por defecto
    pub fn new_default() -> Self {
        Self::new(ParametrosLongevidad::default())
    }

    /// Ejecuta la simulación para un escenario dado
    /// Escenarios disponibles:
    /// - "base": sin intervención biotecnológica
    /// - "intervencion_calico": con intervención estilo Calico (40% reducción)
    /// - "optimista": escenario optimista con mayor reducción
    pub fn simular(&mut self, escenario: &str) {
        let mut anios = vec![self.params.anio_inicio];
        let mut esperanza_vida = vec![self.params.esperanza_vida_actual];
        let mut poblacion = vec![self.params.poblacion_inicial];

        // Calcular la tasa de envejecimiento según el escenario
        let mut tasa_actual = self.params.tasa_envejecimiento_base;

        match escenario {
            "intervencion_calico" => {
                tasa_actual *= 1.0 - self.params.reduccion_tasa_por_avance;
            }
            "optimista" => {
                // Escenario más agresivo: 60% reducción
                tasa_actual *= 1.0 - 0.60;
            }
            "base" | _ => {
                // Sin intervención - tasa base sin cambios
            }
        }

        // Iterar desde el año de inicio hasta el horizonte
        let mut anio_actual = self.params.anio_inicio + 1;
        
        while anio_actual <= self.params.anio_horizonte {
            anios.push(anio_actual);

            // Modelo: esperanza de vida crece linealmente con reducción de tasa
            // Aceleración leve basada en el progreso temporal
            let progreso = (anio_actual - self.params.anio_inicio) as f64;
            let incremento = tasa_actual * (1.0 + 0.005 * progreso);
            
            // Factor de escala aproximado
            let nueva_esperanza = esperanza_vida.last().unwrap() + incremento * 10.0;
            
            // Límite realista basado en el escenario
            let limite = match escenario {
                "optimista" => 200.0,  // Límite más alto para escenario optimista
                _ => 150.0,
            };
            esperanza_vida.push(nueva_esperanza.min(limite));

            // Crecimiento poblacional simplificado (desaceleración demográfica)
            let crecimiento_pob = 0.008 - 0.0001 * (anio_actual - self.params.anio_inicio) as f64;
            let nueva_pob = poblacion.last().unwrap() * (1.0 + crecimiento_pob);
            poblacion.push(nueva_pob);

            anio_actual += 1;
        }

        self.resultados = Some(ResultadosSimulacion {
            anios,
            esperanza_vida,
            poblacion,
        });
    }

    /// Obtiene los resultados de la simulación
    pub fn obtener_resultados(&self) -> Option<&ResultadosSimulacion> {
        self.resultados.as_ref()
    }

    /// Genera visualización en texto de las proyecciones
    pub fn visualizar(&self) {
        if let Some(resultados) = &self.resultados {
            println!("\n{}", repeat_char('=', 70));
            println!(" PROYECCIÓN DE LONGEVIDAD: ESCENARIO INTERVENCIÓN BIOTECNOLÓGICA ");
            println!(" (Inspirado en Calico - Proyecto 2050)");
            println!("{}\n", repeat_char('=', 70));

            // Imprimir tabla de datos seleccionados (cada 5 años)
            println!(" {:^8} | {:^15} | {:^18} ", "Año", "Esperanza Vida", "Población");
            println!("{:-<8}-+-{:-<15}-+-{:-<18}", "", "", "");
            
            for i in 0..resultados.anios.len() {
                // Mostrar cada 5 años para legibilidad
                if i % 5 == 0 || resultados.anios[i] == 2050 || resultados.anios[i] == 2100 {
                    let anio = resultados.anios[i];
                    let esperanza = resultados.esperanza_vida[i];
                    let pob = resultados.poblacion[i] as i64;
                    println!(" {:^8} | {:>14.1} años | {:>17} ", anio, esperanza, format_poblacion(pob));
                }
            }

            println!("\n{}", repeat_char('-', 70));
            
            // Impresión de hitos clave
            self.imprimir_hitos();
            
            println!("{}\n", repeat_char('=', 70));
        } else {
            println!("Error: Primero debe ejecutar la simulación con el método simular()");
        }
    }

    /// Imprime los hitos clave de la simulación
    fn imprimir_hitos(&self) {
        if let Some(resultados) = &self.resultados {
            println!("\n📊 HITOS CLAVE DE LA PROYECCIÓN:\n");
            
            let hitos = vec![2030, 2040, 2050, 2060, 2070, 2080, 2090, 2100];
            
            for &hito in &hitos {
                if let Some(idx) = resultados.anios.iter().position(|&x| x == hito) {
                    let ev = resultados.esperanza_vida[idx];
                    let pob = resultados.poblacion[idx] as i64;
                    
                    let indicador = if hito == 2050 {
                        "🎯"
                    } else if ev > 100.0 {
                        "⭐"
                    } else {
                        "  "
                    };
                    
                    println!(" {} Año {}: Esperanza de vida = {:>6.1} años | Población = {:>12}", 
                        indicador, hito, ev, format_poblacion(pob));
                }
            }
            
            println!("\n📈 PROGRESIÓN ESPECIAL:");
            
            // Encontrar cuando se alcanza cierto umbral
            if let Some(idx) = resultados.esperanza_vida.iter().position(|&x| x >= 100.0) {
                println!(" ✨ Se alcanza los 100 años de esperanza de vida en el año: {}", 
                    resultados.anios[idx]);
            }
            
            if let Some(idx) = resultados.esperanza_vida.iter().position(|&x| x >= 120.0) {
                println!(" 🌟 Se alcanza los 120 años de esperanza de vida en el año: {}", 
                    resultados.anios[idx]);
            }
        }
    }

    /// Genera un gráfico ASCII simple de la esperanza de vida
    pub fn graficar_ascii(&self) {
        if let Some(resultados) = &self.resultados {
            println!("\n📉 GRÁFICO ASCII DE ESPERANZA DE VIDA:\n");
            
            // Escalar los valores para el gráfico
            let max_ev = resultados.esperanza_vida.iter().cloned().fold(0.0f64, f64::max);
            let max_anio = *resultados.anios.last().unwrap() as f64;
            let min_anio = resultados.anios[0] as f64;
            
            // Encabezado
            print!("Esperanza de vida (años)\n");
            
            // Graficar cada 10 años
            for i in (0..resultados.anios.len()).step_by(10) {
                let anio = resultados.anios[i];
                let ev = resultados.esperanza_vida[i];
                
                // Barra proporcional
                let longitud = ((ev / max_ev) * 40.0) as usize;
                let barra = "█".repeat(longitud);
                
                println!(" {} |{} {:>6.1} años", anio, barra, ev);
            }
            
            // Línea de referencia 2050
            println!("\n       |                                                               ▼ Horizonte 2050");
        }
    }
}

/// Función auxiliar para repetir un carácter n veces
fn repeat_char(c: char, n: usize) -> String {
    std::iter::repeat(c).take(n).collect()
}

/// Función auxiliar para formatear números grandes con separadores
fn format_poblacion(n: i64) -> String {
    let s = n.to_string();
    let mut result = String::new();
    let len = s.len();
    for (i, c) in s.chars().enumerate() {
        if i > 0 && (len - i) % 3 == 0 {
            result.push(',');
        }
        result.push(c);
    }
    result
}

// ============================================================
// Programa Principal
// ============================================================

fn main() {
    println!("\n");
    println!("╔══════════════════════════════════════════════════════════════════════╗");
    println!("║                                                                      ║");
    println!("║     ██████╗  ██████╗ ██████╗  █████╗ ██████╗ ██╗     ███████╗██╗      ║");
    println!("║     ██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗██║     ██╔════╝██║      ║");
    println!("║     ██████╔╝██║   ██║██████╔╝███████║██████╔╝██║     █████╗  ██║      ║");
    println!("║     ██╔═══╝ ██║   ██║██╔══██╗██╔══██║██╔═══╝ ██║     ██╔══╝  ██║      ║");
    println!("║     ██║     ╚██████╔╝██║  ██║██║  ██║██║     ███████╗███████╗███████╗║");
    println!("║     ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚══════╝╚══════╝╚══════╝║");
    println!("║                                                                      ║");
    println!("║              500 AÑOS DE HUMANIDAD                                   ║");
    println!("║                                                                      ║");
    println!("╚══════════════════════════════════════════════════════════════════════╝");
    println!("\n");
    println!("🦀 RUST Implementation - Simulación de Longevidad 🦀\n");

    // Crear parámetros personalizados
    let params = ParametrosLongevidad {
        esperanza_vida_actual: 78.5,
        tasa_envejecimiento_base: 0.012,
        reduccion_tasa_por_avance: 0.40, // 40% reducción estilo Calico
        anio_inicio: 2026,
        anio_horizonte: 2100,
        poblacion_inicial: 8_000_000_000.0,
    };

    // Crear simulador
    let mut simulador = SimuladorLongevidad::new(params);

    // Ejecutar simulación con escenario de intervención Calico
    println!("▶ Ejecutando simulación con escenario: INTERVENCIÓN CALICO (40% reducción)");
    println!("   Período: 2026 - 2100\n");
    
    simulador.simular("intervencion_calico");

    // Mostrar resultados
    simulador.visualizar();
    
    // Mostrar gráfico ASCII
    simulador.graficar_ascii();

    // ============================================================
    // Comparar escenarios adicionales
    // ============================================================
    println!("\n");
    println!("{}", repeat_char('=', 70));
    println!(" COMPARACIÓN DE ESCENARIOS");
    println!("{}\n", repeat_char('=', 70));

    // Escenario base (sin intervención)
    let params_base = ParametrosLongevidad::default();
    let mut simulador_base = SimuladorLongevidad::new(params_base);
    simulador_base.simular("base");
    
    // Escenario optimista
    let params_opt = ParametrosLongevidad::default();
    let mut simulador_opt = SimuladorLongevidad::new(params_opt);
    simulador_opt.simular("optimista");

    println!("Comparación de esperanza de vida en años clave:\n");
    println!(" {:^8} | {:^15} | {:^15} | {:^15} ", "Año", "Base", "Calico", "Optimista");
    println!("{:-<8}-+-{:-<15}-+-{:-<15}-+-{:-<15}", "", "", "", "");

    let anios_clave = vec![2026, 2050, 2075, 2100];
    
    if let (Some(r_base), Some(r_calico), Some(r_opt)) = (
        simulador_base.obtener_resultados(),
        simulador.obtener_resultados(),
        simulador_opt.obtener_resultados(),
    ) {
        for &anio in &anios_clave {
            if let (Some(i_base), Some(i_calico), Some(i_opt)) = (
                r_base.anios.iter().position(|&x| x == anio),
                r_calico.anios.iter().position(|&x| x == anio),
                r_opt.anios.iter().position(|&x| x == anio),
            ) {
                println!(" {:^8} | {:>14.1} años | {:>14.1} años | {:>14.1} años", 
                    anio, 
                    r_base.esperanza_vida[i_base],
                    r_calico.esperanza_vida[i_calico],
                    r_opt.esperanza_vida[i_opt]
                );
            }
        }
    }

    println!("\n");
    println!(" Leyenda:");
    println!("   • Base: Sin intervención biotecnológica (tasa de envejecimiento natural)");
    println!("   • Calico: Intervención estilo Calico (40% reducción en tasa de envejecimiento)");
    println!("   • Optimista: Escenario optimista (60% reducción - investigación avanzada)");
    println!("\n");

    // Mensaje final
    println!("{}", repeat_char('=', 70));
    println!("✅ Proyecto-2050-Calico: Simulación completada en RUST");
    println!("🌍 Visión: '500 años de Humanidad' como horizonte especulativo");
    println!("{}", repeat_char('=', 70));
    println!("\n");
}
