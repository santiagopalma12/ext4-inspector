# Arquitectura Física y Métodos de Asignación en Sistemas de Archivos (Linux ext4)

[![Language](https://img.shields.io/badge/Language-C11-blue.svg)](https://en.wikipedia.org/wiki/C11_(C_standard_revision))
[![POSIX](https://img.shields.io/badge/POSIX-Conformance-brightgreen.svg)](https://pubs.opengroup.org/)
[![Course](https://img.shields.io/badge/UNSA-Sistemas_Operativos-red.svg)](https://www.unsa.edu.pe/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

Repositorio oficial para la entrega y sustentación del tema **"Implementación y Administración de Sistemas de Archivos - Parte II: Arquitectura Física, Inodos y Asignación"**.

---

## 🏛️ Información Institucional
- **Universidad:** Universidad Nacional de San Agustín de Arequipa (UNSA)
- **Facultad:** Facultad de Ingeniería de Producción y Servicios (FIPS)
- **Escuela:** Escuela Profesional de Ingeniería de Sistemas (EPIS)
- **Curso:** Sistemas Operativos (VI Semestre - 2026B)
- **Docente:** Ing. Norman Patrick Harvey Arce
- **Grupo de Trabajo:** Grupo 8 (Parte II: Capa Física y Software Forense)

### 👥 Integrantes
1. **Santiago Enrique Palma Apaza** (CUI: 20240689)
2. **Rodolfo Paul Soria Soncco**

---

## 📁 Estructura del Repositorio

```
.
├── README.md                                   # Documentación principal del repositorio
└── unsa/
    └── SO/
        ├── exposicion/                         # 📽️ Diapositivas de Exposición (Typst y PDF)
        │   ├── presentacion_ext4_sistemas_operativos.pdf
        │   ├── presentacion_ext4_sistemas_operativos.typ
        │   └── slides_png/                     # Renders individuales de diapositivas
        │
        ├── informe/                            # 📄 Informe Académico Formal (Formato EPIS - UNSA)
        │   ├── informe_sistemas_archivos.pdf   # Documento compilado listo para entrega
        │   ├── informe_sistemas_archivos.typ   # Código fuente en Typst
        │   ├── unsa_logo.png                   # Escudo oficial UNSA
        │   ├── sistemas.png                    # Logo EPIS
        │   └── abet.png                        # Sello ABET
        │
        └── proyecto_ext4_inspector/            # 💻 Herramienta Forense en C (ext4-inspector)
            ├── ext4_inspector.c                # Implementación en C11 puro (POSIX)
            ├── ext4_structs.h                  # Definición binaria de estructuras de ext4
            ├── Makefile                        # Script de compilación estricta
            └── README.md                       # Manual técnico del software
```

---

## 🚀 Inicio Rápido: Compilación del Analizador Forense

El proyecto `ext4-inspector` está escrito en **C11 puro** y no requiere librerías externas:

```bash
# 1. Ingresar al directorio del proyecto
cd unsa/SO/proyecto_ext4_inspector

# 2. Compilar con advertencias estrictas
make

# 3. Ver ayuda y comandos disponibles
./ext4_inspector
```

### Comandos Principales de la Herramienta:
- `./ext4_inspector <disco.img> info`: Inspecciona el Superbloque (`0xEF53`) y los Descriptores de Grupo (GDT).
- `./ext4_inspector <disco.img> inode <N>`: Analiza el inodo $N$ a nivel de bytes y decodifica su árbol de Extents (`0xF30A`).
- `./ext4_inspector <disco.img> cat <N>`: Extrae los bytes de datos directamente de los bloques físicos LBA del medio.
- `./ext4_inspector <disco.img> ls <N>`: Mapea el contenido del directorio `(Nombre -> Inodo)`.
- `./ext4_inspector <disco.img> diagnose-space`: Detecta riesgos de colapso por agotamiento estático de inodos (`ENOSPC`).

---

## 📚 Documentos Disponibles
- [Descargar Informe Técnico en PDF](unsa/SO/informe/informe_sistemas_archivos.pdf)
- [Descargar Diapositivas de Exposición en PDF](unsa/SO/exposicion/presentacion_ext4_sistemas_operativos.pdf)
