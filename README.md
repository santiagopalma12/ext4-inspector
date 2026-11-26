# Implementación y Administración de Sistemas de Archivos: Linux ext4

[![Language](https://img.shields.io/badge/Language-C11-blue.svg)](https://en.wikipedia.org/wiki/C11_(C_standard_revision))
[![POSIX](https://img.shields.io/badge/POSIX-Conformance-brightgreen.svg)](https://pubs.opengroup.org/)
[![Course](https://img.shields.io/badge/UNSA-Sistemas_Operativos-red.svg)](https://www.unsa.edu.pe/)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

Repositorio oficial para la entrega, informe técnico y sustentación del tema **"Implementación y Administración de Sistemas de Archivos"**, correspondiente al Grupo 8 del curso de Sistemas Operativos.

---

## Informacion Institucional

- **Universidad:** Universidad Nacional de San Agustín de Arequipa (UNSA)
- **Facultad:** Facultad de Ingeniería de Producción y Servicios (FIPS)
- **Escuela:** Escuela Profesional de Ingeniería de Sistemas (EPIS)
- **Curso:** Sistemas Operativos (VI Semestre - 2026B)
- **Docente:** Ing. Norman Patrick Harvey Arce
- **Grupo de Trabajo:** Grupo 8

---

## Division de Trabajo del Grupo 8

El tema general comprende la arquitectura completa de sistemas de archivos en entornos tipo Unix/Linux, estructurado en dos partes complementarias:

### Parte I: Capa Logica en Kernel, VFS y Consistencia
**Responsable:** Rodolfo Paul Soria Soncco

1. **Capa del Virtual File System (VFS):** Abstracción unificada del kernel para múltiples sistemas de archivos.
2. **Estructuras en Memoria RAM:**
   - Tabla de descriptores de archivo por proceso (`fd table`).
   - Tabla global de archivos abiertos en el kernel (`file table`).
   - Inodos activos en RAM, Page Cache y Dentry Cache.
3. **Gestion de Espacio Libre:** Bitmaps de bloques libres vs. Listas enlazadas libres.
4. **Consistencia y Recuperacion ante Fallos:** Verificación offline mediante `fsck` frente a mecanismos de registro previo (*Journaling / Write-Ahead Logging*).

### Parte II: Arquitectura Fisica en Disco, Inodos y Asignacion (ext4)
**Responsable:** Santiago Enrique Palma Apaza (CUI: 20240689)

1. **Geometria Fisica y Mapeo LBA:**
   - Sectores físicos (512 B / 4 KB) y bloques lógicos del SO (4 KB alineados 1:1 con memoria virtual x86_64).
   - Modelado de fragmentación interna.
2. **Distribucion en Disco por Grupos de Bloques (Block Groups):**
   - Segmentación de 128 MB para optimizar localidad espacial y reducir *seek time*.
   - El Superbloque (firma `0xEF53`, dimensionamiento estático de inodos y diagnóstico de `ENOSPC`).
3. **El Inodo (FCB) vs. Directorios:**
   - Anatomía de `ext4_inode` (256 bytes) y separación estricta entre identidad y nombres.
   - Directorios como árboles HTree `(Nombre -> Inodo)`.
   - Semántica operacional: atomicidad $O(1)$ de `mv`, Hard Links (`i_links_count`) y Symbolic Links (Fast Symlinks).
4. **Metodos de Asignacion de Bloques:**
   - Asignación contigua (fragmentación externa).
   - Asignación enlazada y tablas FAT (cuello de botella en RAM).
   - Asignación indexada clásica multinivel de ext2/ext3 (matemáticas de punteros directos, indirectos simples, dobles y triples).
   - Asignación moderna mediante Extents en ext4 (tuplas de intervalos `{bloque_logico, longitud, bloque_fisico}`).
5. **Herramienta Forense en C (ext4-inspector):**
   - Desarrollo de un analizador binario en C11 puro para inspección directa de sectores de disco sin dependencias de librerías externas.

---

## Estructura del Repositorio

```
.
|-- README.md                                   # Documentacion principal del repositorio
`-- unsa/
    `-- SO/
        |-- exposicion/                         # Diapositivas de Exposicion (Typst y PDF)
        |   |-- presentacion_ext4_sistemas_operativos.pdf
        |   |-- presentacion_ext4_sistemas_operativos.typ
        |   `-- slides_png/                     # Renders individuales de diapositivas
        |
        |-- informe/                            # Informe Tecnico Formal (Formato EPIS - UNSA)
        |   |-- informe_sistemas_archivos.pdf   # Documento compilado listo para entrega
        |   |-- informe_sistemas_archivos.typ   # Codigo fuente en Typst
        |   |-- unsa_logo.png                   # Escudo oficial UNSA
        |   |-- sistemas.png                    # Logo EPIS
        |   `-- abet.png                        # Sello ABET
        |
        `-- proyecto_ext4_inspector/            # Herramienta Forense en C (ext4-inspector)
            |-- ext4_inspector.c                # Implementacion en C11 puro (POSIX)
            |-- ext4_structs.h                  # Definicion binaria de estructuras de ext4
            |-- Makefile                        # Script de compilacion estricta
            `-- README.md                       # Manual tecnico del software
```

---

## Compilacion y Uso del Analizador Forense

El proyecto `ext4-inspector` se compila con el estándar C11 sin requerir librerías auxiliares:

```bash
# 1. Ingresar al directorio del software
cd unsa/SO/proyecto_ext4_inspector

# 2. Compilar
make

# 3. Visualizar comandos disponibles
./ext4_inspector
```

### Comandos de Inspeccion:
- `./ext4_inspector <disco.img> info`: Inspecciona el Superbloque (`0xEF53`) y los Descriptores de Grupo (GDT).
- `./ext4_inspector <disco.img> inode <N>`: Analiza el inodo $N$ a nivel de bytes y decodifica su árbol de Extents (`0xF30A`).
- `./ext4_inspector <disco.img> cat <N>`: Extrae los bytes de datos directamente de los bloques físicos LBA del medio.
- `./ext4_inspector <disco.img> ls <N>`: Mapea el contenido del directorio `(Nombre -> Inodo)`.
- `./ext4_inspector <disco.img> diagnose-space`: Detecta riesgos de colapso por saturación de inodos (`ENOSPC`).

---

## Documentos del Proyecto
- [Informe Tecnico en PDF](unsa/SO/informe/informe_sistemas_archivos.pdf)
- [Diapositivas de Exposicion en PDF](unsa/SO/exposicion/presentacion_ext4_sistemas_operativos.pdf)
