#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Biomedicina y Biologia Molecular - Programa Educativo
Este programa muestra los conceptos fundamentales de la biomedicina y biologia molecular
"""

import tkinter as tk
from tkinter import ttk, scrolledtext
import math

class BiomedicinaMolecularApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Biomedicina y Biologia Molecular")
        self.root.geometry("900x700")
        self.root.configure(bg="#f0f0f0")
        
        # Datos biomedicos
        self.datos_biomedicina = {
            "ADN": {
                "descripcion": "El Acido Desoxirribonucleico (ADN) es la molecula que contiene la informacion genetica de los seres vivos.",
                "estructura": "Double helix composed of nucleotides: adenine (A), thymine (T), guanine (G) and cytosine (C).",
                "funcion": "Almacena y transmite la informacion genetica de generacion en generacion.",
                "emparejamiento": "A-T (2 hydrogen bonds), G-C (3 hydrogen bonds)"
            },
            "ARN": {
                "descripcion": "El Acido Ribonucleico (ARN) es una molecula esencial para la sintesis de proteinas.",
                "estructura": "Single chain of nucleotides: adenine (A), uracil (U), guanine (G) and cytosine (C).",
                "funcion": "Transfiere la informacion del ADN al ribosoma para la sintesis de proteinas.",
                "tipos": "ARNm, ARNt, ARNr, ARNmi, ARNsi"
            },
            "Proteinas": {
                "descripcion": "Las proteinas son macromoleculas formadas por aminoacidos.",
                "estructura": "Chain of amino acids joined by peptide bonds. They have primary, secondary, tertiary and quaternary structure.",
                "funcion": "Catalyze reactions (enzymes), provide structure, transport molecules, regulate genes and protect against disease.",
                "aminoacidos": "20 standard amino acids"
            },
            "Enzimas": {
                "descripcion": "Las enzimas son biocatalizadores que aceleran las reacciones quimicas en los seres vivos.",
                "estructura": "Usually proteins, some RNA (ribozymes). They have a specific active site.",
                "funcion": "Reducen la energia de activacion de las reacciones metabolicas.",
                "cinetica": "Follows Michaelis-Menten equation: v = (Vmax * [S]) / (Km + [S])"
            },
            "Metabolismo": {
                "descripcion": "El metabolismo es el conjunto de reacciones quimicas que ocurren en los seres vivos.",
                "estructura": "Interconnected metabolic pathways: glycolysis, Krebs cycle, electron transport chain.",
                "funcion": "Convierte los alimentos en energia y bloques de construccion para las celulas.",
                "ATP": "ATP is the main energy molecule of the cell"
            },
            "Genetica": {
                "descripcion": "La genetica es el estudio de los genes, la herencia y la variacion genetica.",
                "estructura": "Gene segments of DNA that encode proteins. Human genome: ~20,000-25,000 genes.",
                "funcion": "Determina las caracteristicas heredadas y la funcion celular.",
                "mutaciones": "Changes in DNA sequence that can cause diseases"
            },
            "Celula": {
                "descripcion": "La celula es la unidad basica de la vida.",
                "estructura": "Cell membrane, cytoplasm, nucleus (eukaryotic cells), organelles: mitochondria, endoplasmic reticulum, Golgi apparatus.",
                "funcion": "Realiza todas las funciones vitales: nutricion, relacion, reproduccion.",
                "tipos": "Prokaryotic cells (without nucleus) and eukaryotic cells (with nucleus)"
            },
            "Inmunologia": {
                "descripcion": "La inmunologia es el estudio del sistema inmunitario.",
                "estructura": "Lymphoid organs: bone marrow, thymus, spleen, lymph nodes. Cells: T lymphocytes, B lymphocytes, macrophages.",
                "funcion": "Protege contra pathogenos y celulas anormales.",
                "anticuerpos": "Immunoglobulins (IgG, IgM, IgA, IgD, IgE) that recognize specific antigens"
            }
        }
        
        self.setup_ui()
    
    def setup_ui(self):
        # Titulo principal
        titulo = tk.Label(self.root, text="Biomedicina y Biologia Molecular", 
                         font=("Arial", 20, "bold"), bg="#2c3e50", fg="white", pady=10)
        titulo.pack(fill=tk.X)
        
        # Marco principal
        main_frame = tk.Frame(self.root, bg="#f0f0f0")
        main_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Panel izquierdo - Menu de temas
        left_frame = tk.Frame(main_frame, bg="#f0f0f0")
        left_frame.pack(side=tk.LEFT, fill=tk.Y, padx=(0, 10))
        
        tk.Label(left_frame, text="Temas", font=("Arial", 14, "bold"), 
                bg="#f0f0f0").pack(pady=5)
        
        # Botones de temas
        for tema in self.datos_biomedicina.keys():
            btn = tk.Button(left_frame, text=tema, font=("Arial", 11),
                           command=lambda t=tema: self.mostrar_tema(t),
                           bg="#3498db", fg="white", padx=15, pady=5,
                           relief=tk.FLAT, cursor="hand2")
            btn.pack(fill=tk.X, pady=2)
        
        # Panel derecho - Informacion
        right_frame = tk.Frame(main_frame, bg="#f0f0f0")
        right_frame.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)
        
        # Titulo del tema
        self.lbl_titulo = tk.Label(right_frame, text="Seleccione un tema", 
                                   font=("Arial", 16, "bold"), bg="#f0f0f0", 
                                   fg="#2c3e50")
        self.lbl_titulo.pack(pady=5)
        
        # Area de texto con scroll
        self.texto_info = scrolledtext.ScrolledText(right_frame, font=("Arial", 11),
                                                    wrap=tk.WORD, bg="white",
                                                    padx=10, pady=10)
        self.texto_info.pack(fill=tk.BOTH, expand=True)
        self.texto_info.config(state=tk.DISABLED)
        
        # Panel inferior - Informacion adicional
        bottom_frame = tk.Frame(main_frame, bg="#f0f0f0")
        bottom_frame.pack(side=tk.BOTTOM, fill=tk.X, pady=10)
        
        # Canvas para visualizacion
        self.canvas = tk.Canvas(bottom_frame, width=800, height=150, bg="#ecf0f1")
        self.canvas.pack()
        
        # Texto inicial
        self.mostrar_tema("ADN")
    
    def mostrar_tema(self, tema):
        datos = self.datos_biomedicina[tema]
        
        # Actualizar titulo
        self.lbl_titulo.config(text=tema)
        
        # Actualizar texto
        self.texto_info.config(state=tk.NORMAL)
        self.texto_info.delete(1.0, tk.END)
        
        info = f"=== {tema} ===\n\n"
        
        for clave, valor in datos.items():
            info += f"{clave}:\n{valor}\n\n"
        
        self.texto_info.insert(tk.END, info)
        self.texto_info.config(state=tk.DISABLED)
        
        # Dibujar visualizacion
        self.dibujar_visualizacion(tema)
    
    def dibujar_visualizacion(self, tema):
        self.canvas.delete("all")
        width = 800
        height = 150
        
        if tema == "ADN":
            # Doble helic del ADN
            for i in range(0, 200, 20):
                x = 50 + i
                # Cadena 1
                y1 = 75 + 30 * math.sin(i * 0.1)
                # Cadena 2
                y2 = 75 - 30 * math.sin(i * 0.1)
                
                self.canvas.create_oval(x-3, y1-3, x+3, y1+3, fill="#e74c3c", outline="#e74c3c")
                self.canvas.create_oval(x-3, y2-3, x+3, y2+3, fill="#3498db", outline="#3498db")
                
                # Puentes de hidrogeno
                if i % 40 == 0:
                    self.canvas.create_line(x, y1, x, y2, fill="#f39c12", width=2, dash=(4, 2))
            
            self.canvas.create_text(400, 130, text="Double helix structure of DNA", font=("Arial", 10))
        
        elif tema == "ARN":
            # Cadena simple de ARN
            for i in range(0, 200, 15):
                x = 50 + i
                y = 75 + 20 * math.sin(i * 0.15)
                colors = ["#e74c3c", "#3498db", "#2ecc71", "#f39c12"]
                self.canvas.create_oval(x-4, y-4, x+4, y+4, fill=colors[i % 4], outline=colors[i % 4])
            
            self.canvas.create_text(400, 130, text="Single RNA chain", font=("Arial", 10))
        
        elif tema == "Proteinas":
            # Estructura de proteina
            for i in range(0, 180, 20):
                x = 60 + i
                y = 75 + 25 * math.sin(i * 0.2)
                self.canvas.create_oval(x-6, y-6, x+6, y+6, fill="#9b59b6", outline="#8e44ad", width=2)
                self.canvas.create_line(x, y, x+20, 75, fill="#34495e", width=2)
            
            self.canvas.create_text(400, 130, text="Tertiary protein structure", font=("Arial", 10))
        
        elif tema == "Enzimas":
            # Modelo de enzima-sustrato
            # Enzima
            self.canvas.create_oval(200, 40, 280, 100, fill="#e67e22", outline="#d35400", width=2)
            self.canvas.create_text(240, 70, text="Enzyme", font=("Arial", 9))
            
            # Sustrato
            self.canvas.create_oval(320, 50, 360, 90, fill="#1abc9c", outline="#16a085")
            self.canvas.create_text(340, 70, text="S", font=("Arial", 9))
            
            # Producto
            self.canvas.create_oval(420, 50, 460, 90, fill="#1abc9c", outline="#16a085")
            self.canvas.create_oval(440, 50, 480, 90, fill="#1abc9c", outline="#16a085")
            self.canvas.create_text(450, 70, text="P+P", font=("Arial", 9))
            
            # Flecha
            self.canvas.create_line(360, 70, 420, 70, arrow=tk.LAST, fill="#2c3e50", width=2)
            
            self.canvas.create_text(400, 130, text="Enzymatic catalysis", font=("Arial", 10))
        
        elif tema == "Metabolismo":
            # Ciclo simplificado
            self.canvas.create_oval(150, 40, 230, 100, fill="#3498db", outline="#2980b9", width=2)
            self.canvas.create_text(190, 70, text="Glycolysis", font=("Arial", 8))
            
            self.canvas.create_oval(350, 40, 430, 100, fill="#e74c3c", outline="#c0392b", width=2)
            self.canvas.create_text(390, 70, text="Krebs Cycle", font=("Arial", 8))
            
            self.canvas.create_oval(550, 40, 630, 100, fill="#f39c12", outline="#d68910", width=2)
            self.canvas.create_text(590, 70, text="e- Chain", font=("Arial", 8))
            
            # Flechas
            self.canvas.create_line(230, 70, 350, 70, arrow=tk.LAST, fill="#2c3e50")
            self.canvas.create_line(430, 70, 550, 70, arrow=tk.LAST, fill="#2c3e50")
            
            self.canvas.create_text(400, 130, text="Main metabolic pathways", font=("Arial", 10))
        
        elif tema == "Genetica":
            # Representacion de genes
            for i in range(5):
                x = 100 + i * 150
                self.canvas.create_rectangle(x, 50, x+80, 100, fill="#16a085", outline="#1abc9c", width=2)
                self.canvas.create_text(x+40, 75, text=f"Gene {i+1}", font=("Arial", 9))
            
            self.canvas.create_text(400, 130, text="Gene structure", font=("Arial", 10))
        
        elif tema == "Celula":
            # Celula eucariota
            self.canvas.create_oval(250, 25, 550, 125, fill="#ecf0f1", outline="#2c3e50", width=3)
            self.canvas.create_oval(320, 50, 420, 100, fill="#e74c3c", outline="#c0392b", width=2)
            self.canvas.create_text(370, 75, text="Nucleus", font=("Arial", 8))
            
            # Mitocondria
            self.canvas.create_oval(480, 40, 520, 80, fill="#f39c12", outline="#d68910", width=2)
            self.canvas.create_text(500, 60, text="M", font=("Arial", 7))
            
            self.canvas.create_text(400, 130, text="Eukaryotic cell", font=("Arial", 10))
        
        elif tema == "Inmunologia":
            # Celulas inmunitarias
            # Linfocito T
            self.canvas.create_oval(150, 50, 210, 90, fill="#9b59b6", outline="#8e44ad", width=2)
            self.canvas.create_text(180, 70, text="T Cell", font=("Arial", 8))
            
            # Linfocito B
            self.canvas.create_oval(280, 50, 340, 90, fill="#3498db", outline="#2980b9", width=2)
            self.canvas.create_text(310, 70, text="B Cell", font=("Arial", 8))
            
            # Macrofago
            self.canvas.create_oval(410, 40, 490, 100, fill="#e67e22", outline="#d35400", width=2)
            self.canvas.create_text(450, 70, text="Macrophage", font=("Arial", 8))
            
            # Anticuerpo
            self.canvas.create_rectangle(550, 50, 620, 90, fill="#1abc9c", outline="#16a085", width=2)
            self.canvas.create_text(585, 70, text="Ab", font=("Arial", 8))
            
            self.canvas.create_text(400, 130, text="Immune system", font=("Arial", 10))

def main():
    root = tk.Tk()
    app = BiomedicinaMolecularApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
