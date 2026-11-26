# ext4-inspector: Herramienta de Análisis Forense y Cirugía de Bajo Nivel en Linux ext4

![Language](https://img.shields.io/badge/Language-C11-blue.svg)
![Standard](https://img.shields.io/badge/POSIX-Conformance-brightgreen.svg)
![Course](https://img.shields.io/badge/UNSA-Sistemas_Operativos-red.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

Herramienta de análisis forense desarrollada en **C puro (C11)** para la inspección quirúrgica de estructuras físicas, metadatos y asignación de bloques en sistemas de archivos **Linux ext4**. Diseñada sin dependencias externas de librerías de usuario (`libext2fs`), interactúa directamente con los sectores binarios del medio de almacenamiento mediante llamadas al sistema POSIX (`open`, `lseek`, `read`).

---

## 🏛️ Contexto Académico
- **Institución:** Universidad Nacional de San Agustín de Arequipa (UNSA)
- **Facultad:** Facultad de Ingeniería de Producción y Servicios (FIPS)
- **Escuela:** Escuela Profesional de Ingeniería de Sistemas (EPIS)
- **Curso:** Sistemas Operativos (VI Semestre)
- **Tema:** Implementación y Administración de Sistemas de Archivos (Grupo 8 - Parte II)

---

## 🎯 Capacidades y Características

1. **Inspección del Superbloque (`0xEF53`):**
   - Lectura en offset $1024$ bytes.
   - Validación de la firma binaria del sistema de archivos.
   - Extracción de geometría: tamaño de bloque lógico ($4\text{ KB}$), inodos totales, bloques totales y contadores libres.
2. **Navegación de la Tabla de Descriptores de Grupo (GDT):**
   - Mapeo de la segmentación en *Block Groups*.
   - Localización física de los bitmaps de bloques e inodos y el inicio de la Tabla de Inodos de cada grupo.
3. **Cirugía del Inodo (FCB - 256 bytes):**
   - Resolución matemática del offset físico de cualquier inodo:
     $$\text{Grupo} = \left\lfloor\frac{\text{inode} - 1}{\text{inodes\_per\_group}}\right\rfloor, \quad \text{Índice} = (\text{inode} - 1) \pmod{\text{inodes\_per\_group}}$$
   - Decodificación de permisos POSIX (`i_mode`), dueños (`i_uid`, `i_gid`), tamaño en bytes (`i_size`) y contador de referencias (`i_links_count`).
4. **Decodificación del Árbol B+ de Extents (`0xF30A`):**
   - Comprobación del flag `EXT4_EXTENTS_FL` (`0x80000`).
   - Parseo del `ext4_extent_header` y extracción de descriptores directos de extents:
     $$\{\text{bloque\_lógico}, \text{longitud}, \text{bloque\_físico\_LBA}\}$$
5. **Extracción Directa de Datos (`cat` LBA):**
   - Lectura cruda de los sectores físicos del disco apuntados por los extents, volcando los datos a `stdout` sin pasar por el subsistema de archivos del kernel.
6. **Exploración de Directorios (`ls`):**
   - Decodificación de entradas `ext4_dir_entry_2`, demostrando que los nombres de archivo residen en el directorio y no en el inodo.
7. **Diagnóstico Preventivo de Agotamiento de Inodos (`ENOSPC`):**
   - Detección de asimetrías críticas entre consumo de bloques de datos y consumo de la tabla de inodos.

---

## 📐 Arquitectura Física de Disco en ext4

```
+---------------------------------------------------------------------------------------------------+
|                                 DISCO / PARTICIÓN ext4                                            |
+------------+--------------------------------------------------------------------------------------+
| Boot Block | Block Group 0 | Block Group 1 | Block Group 2 | ... | Block Group N                  |
|  (1024 B)  |   (128 MB)    |   (128 MB)    |   (128 MB)    |     |   (128 MB)                     |
+------------+---------------+---------------+---------------+-----+--------------------------------+

                                    Anatomía de un Block Group
+--------------+------------------+--------------+--------------+------------------+----------------+
| Superbloque  | Descriptores GDT | Block Bitmap | Inode Bitmap | Tabla de Inodos  | Bloques Datos  |
|  (1 bloque)  |    (N bloques)   |  (1 bloque)  |  (1 bloque)  |  (~512 bloques)  | (~32k bloques) |
+--------------+------------------+--------------+--------------+------------------+----------------+
```

---

## 🛠️ Compilación e Instalación

Requisitos: Compilador compatible con C11 (`gcc` o `clang`) y `make`.

```bash
# Clonar o situarse en el directorio
cd unsa/SO/proyecto_ext4_inspector

# Compilar con nivel de optimización y advertencias estrictas (-Wall -Wextra -Werror)
make
```

El binario ejecutable `ext4_inspector` se generará en la raíz del proyecto.

---

## 🚀 Guía de Uso

### 1. Obtener Metadatos Globales y Block Groups
```bash
./ext4_inspector imagen_disco.img info
```
*Salida esperada:*
```text
======================================================================
  EXT4 LOW-LEVEL INSPECTOR & FORENSICS TOOL - UNSA EPIS (SO 2026)     
======================================================================
[+] SUPERBLOQUE (Offset físico: 1024 bytes):
    * Número Mágico           : 0xEF53 (Integridad: VÁLIDO)
    * Estado del Sistema       : CLEAN (Limpio)
    * Tamaño de Bloque Lógico  : 4096 bytes (4 KB)
    * Conteo Total de Bloques  : 16384
    * Bloques Libres           : 15802 (96.45% libre)
    * Conteo Total de Inodos   : 4096
    * Inodos Libres            : 4085 (99.73% libre)
    * Tamaño de Inodo (FCB)    : 256 bytes
    * Bloques por Grupo        : 32768
    * Inodos por Grupo         : 4096
    * Total de Block Groups    : 1
```

### 2. Inspeccionar un Inodo Específico y sus Extents
```bash
./ext4_inspector imagen_disco.img inode 12
```
*Muestra:*
- Permisos POSIX decodificados (`-rw-r--r--`).
- Contador de enlaces duros `i_links_count`.
- Verificación del flag `0x80000` (EXTENTS).
- Tabla de extents: bloque lógico inicial, longitud y bloque físico LBA real en el medio.

### 3. Extraer Datos Crudos del Archivo
```bash
./ext4_inspector imagen_disco.img cat 12
```
Lee directamente los sectores físicos indicados por los extents y emite el contenido exacto del archivo a la terminal.

### 4. Listar Entradas de un Directorio
```bash
./ext4_inspector imagen_disco.img ls 2
```
Lee el inodo del directorio raíz (inodo 2) y parsea la lista de tuplas `(Número Inodo, Tipo, Longitud, Nombre)`.

### 5. Diagnóstico de Capacidad
```bash
./ext4_inspector imagen_disco.img diagnose-space
```
Evalúa si el sistema de archivos corre riesgo de arrojar `No space left on device` por falta de inodos teniendo bloques libres disponibles.

---

## 👥 Autores - Grupo 8 (Parte II)
- **Santiago Enrique Palma Apaza** (CUI: 20240689)
- **Rodolfo Paul Soria Soncco**
- **Docente:** Ing. Norman Patrick Harvey Arce
- **Escuela Profesional de Ingeniería de Sistemas - UNSA**
- Arequipa, Perú - 2026
