# ext4-inspector: Herramienta de Analisis Forense de Bajo Nivel en Linux ext4

![Language](https://img.shields.io/badge/Language-C11-blue.svg)
![Standard](https://img.shields.io/badge/POSIX-Conformance-brightgreen.svg)
![Course](https://img.shields.io/badge/UNSA-Sistemas_Operativos-red.svg)
![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)

Herramienta de análisis forense desarrollada en C puro (C11) para la inspección quirúrgica de estructuras físicas, metadatos y asignación de bloques en sistemas de archivos Linux ext4. Diseñada sin dependencias de librerías de usuario (`libext2fs`), interactúa directamente con los sectores binarios del medio de almacenamiento mediante llamadas al sistema POSIX (`open`, `lseek`, `read`).

---

## Contexto Academico
- **Institucion:** Universidad Nacional de San Agustín de Arequipa (UNSA)
- **Facultad:** Facultad de Ingeniería de Producción y Servicios (FIPS)
- **Escuela:** Escuela Profesional de Ingeniería de Sistemas (EPIS)
- **Curso:** Sistemas Operativos (VI Semestre - 2026B)
- **Docente:** Ing. Norman Patrick Harvey Arce
- **Tema:** Implementación y Administración de Sistemas de Archivos (Grupo 8)

---

## Capacidades y Caracteristicas

1. **Inspeccion del Superbloque (0xEF53):**
   - Lectura en offset 1024 bytes.
   - Validación de la firma binaria del sistema de archivos.
   - Extracción de geometría: tamaño de bloque lógico (4 KB), inodos totales, bloques totales y contadores libres.
2. **Navegacion de la Tabla de Descriptores de Grupo (GDT):**
   - Mapeo de la segmentación en Block Groups.
   - Localización física de los bitmaps de bloques e inodos y el inicio de la Tabla de Inodos de cada grupo.
3. **Cirugia del Inodo (FCB - 256 bytes):**
   - Resolución matemática del offset físico de cualquier inodo:
     $$\text{Grupo} = \left\lfloor\frac{\text{inode} - 1}{\text{inodes\_per\_group}}\right\rfloor, \quad \text{Indice} = (\text{inode} - 1) \pmod{\text{inodes\_per\_group}}$$
   - Decodificación de permisos POSIX (`i_mode`), dueños (`i_uid`, `i_gid`), tamaño en bytes (`i_size`) y contador de referencias (`i_links_count`).
4. **Decodificacion del Arbol B+ de Extents (0xF30A):**
   - Comprobación del flag `EXT4_EXTENTS_FL` (`0x80000`).
   - Parseo del `ext4_extent_header` y extracción de descriptores directos de extents:
     $$\{\text{bloque\_logico}, \text{longitud}, \text{bloque\_fisico\_LBA}\}$$
5. **Extraccion Directa de Datos (cat LBA):**
   - Lectura cruda de los sectores físicos del disco apuntados por los extents, volcando los datos a `stdout` sin pasar por el subsistema de archivos del kernel.
6. **Exploracion de Directorios (ls):**
   - Decodificación de entradas `ext4_dir_entry_2`, demostrando que los nombres de archivo residen en el directorio y no en el inodo.
7. **Diagnostico Preventivo de Agotamiento de Inodos (ENOSPC):**
   - Detección de asimetrías críticas entre consumo de bloques de datos y consumo de la tabla de inodos.

---

## Arquitectura Fisica de Disco en ext4

```
+---------------------------------------------------------------------------------------------------+
|                                 DISCO / PARTICION ext4                                            |
+------------+--------------------------------------------------------------------------------------+
| Boot Block | Block Group 0 | Block Group 1 | Block Group 2 | ... | Block Group N                  |
|  (1024 B)  |   (128 MB)    |   (128 MB)    |   (128 MB)    |     |   (128 MB)                     |
+------------+---------------+---------------+---------------+-----+--------------------------------+

                                    Anatomia de un Block Group
+--------------+------------------+--------------+--------------+------------------+----------------+
| Superbloque  | Descriptores GDT | Block Bitmap | Inode Bitmap | Tabla de Inodos  | Bloques Datos  |
|  (1 bloque)  |    (N bloques)   |  (1 bloque)  |  (1 bloque)  |  (~512 bloques)  | (~32k bloques) |
+--------------+------------------+--------------+--------------+------------------+----------------+
```

---

## Compilacion e Instalacion

Requisitos: Compilador compatible con C11 (`gcc` o `clang`) y `make`.

```bash
# Ingresar al directorio del software
cd unsa/SO/proyecto_ext4_inspector

# Compilar con nivel de optimizacion y advertencias estrictas (-Wall -Wextra -Werror)
make
```

El binario ejecutable `ext4_inspector` se generará en la raíz del proyecto.

---

## Guia de Uso

### 1. Obtener Metadatos Globales y Block Groups
```bash
./ext4_inspector imagen_disco.img info
```

### 2. Inspeccionar un Inodo Especifico y sus Extents
```bash
./ext4_inspector imagen_disco.img inode 12
```

### 3. Extraer Datos Crudos del Archivo
```bash
./ext4_inspector imagen_disco.img cat 12
```

### 4. Listar Entradas de un Directorio
```bash
./ext4_inspector imagen_disco.img ls 2
```

### 5. Diagnostico de Capacidad
```bash
./ext4_inspector imagen_disco.img diagnose-space
```

---

## Autores - Grupo 8
- **Santiago Enrique Palma Apaza** (CUI: 20240689) - Parte II: Arquitectura Física y Software Forense
- **Rodolfo Paul Soria Soncco** - Parte I: Capa Lógica, VFS y Consistencia
- **Docente:** Ing. Norman Patrick Harvey Arce
- **Escuela Profesional de Ingeniería de Sistemas - UNSA**
- Arequipa, Perú - 2026
