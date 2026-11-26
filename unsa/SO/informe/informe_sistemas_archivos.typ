#set page(
  paper: "a4",
  margin: (top: 3.4cm, bottom: 2cm, left: 2.2cm, right: 2.2cm),
  header-ascent: 18%,
  header: context {
    let page_num = counter(page).get().first()
    if page_num > 1 [
      #align(center)[
        #table(
          columns: (3.2cm, 1fr, 2.8cm),
          stroke: 0.5pt + rgb("#000000"),
          align: horizon + center,
          inset: (x: 4pt, y: 2.5pt),
          [#image("sistemas.png", width: 78%)],
          [
            #text(size: 6pt, weight: "bold")[UNIVERSIDAD NACIONAL DE SAN AGUSTIN]\
            #text(size: 5.5pt, weight: "bold")[FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS]\
            #text(size: 5.5pt, weight: "bold")[ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS]
          ],
          [#image("abet.png", width: 68%)],

          table.cell(colspan: 3, inset: 1.8pt)[
            #text(size: 5.5pt)[*Formato:* Guía de Práctica de Laboratorio / Talleres / Centros de Simulación]
          ],
          [#text(size: 5.5pt)[*Aprobación:* 2022/03/01]],
          [#text(size: 5.5pt)[*Código:* GUIA-PRLE-001]],
          [#text(size: 5.5pt)[*Página:* #counter(page).display()]]
        )
      ]
    ]
  }
)

#set text(
  font: ("Times New Roman", "Liberation Serif", "Nimbus Roman"),
  size: 8.8pt,
  lang: "es"
)

#show raw: set text(
  font: ("DejaVu Sans Mono", "Liberation Mono", "Courier New"),
  size: 7.5pt
)

#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1.")

#let institutional-red = rgb("#cf4d36")
#let border-black = 0.5pt + rgb("#000000")

#let code-box(body) = [
  #block(
    width: 100%,
    stroke: 0.6pt + black,
    fill: luma(252),
    inset: 7pt,
    radius: 0pt,
    [
      #set text(font: "DejaVu Sans Mono", size: 7.5pt)
      #set par(first-line-indent: 0pt, leading: 0.45em)
      #body
    ]
  )
]

// =============================================================================
// PÁGINA 1: CARÁTULA OFICIAL INSTITUCIONAL CON ESCUDO UNSA (FORMATO MN)
// =============================================================================
#page(
  header: none,
  margin: (top: 2.2cm, bottom: 2cm, left: 2.2cm, right: 2.2cm)
)[
  #align(center)[
    #text(size: 14pt, weight: "bold")[UNIVERSIDAD NACIONAL DE SAN AGUSTÍN DE AREQUIPA]\
    #v(3pt)
    #text(size: 11.5pt, weight: "bold")[FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS]\
    #v(8pt)
    #image("unsa_logo.png", width: 3.5cm)
    #v(8pt)
    #text(size: 11.5pt, weight: "bold")[ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS]\

    #v(1.2cm)

    #text(size: 11pt, weight: "bold")[INFORME TÉCNICO DE INGENIERÍA]\
    #v(4pt)
    #text(size: 13.5pt, weight: "bold")[ARQUITECTURA FÍSICA, MÉTODOS DE ASIGNACIÓN E IMPLEMENTACIÓN DE UN ANALIZADOR FORENSE EN LINUX EXT4]\
    #v(3pt)
    #text(size: 9.5pt, style: "italic")[Anatomía de Disco, Inodos, Árboles de Extents y Cirugía de Bajo Nivel con ext4-inspector]\

    #v(1.3cm)

    #align(center)[
      #block(width: 86%)[
        #table(
          columns: (auto, 1fr),
          stroke: none,
          row-gutter: 7pt,
          column-gutter: 12pt,
          align: (left, left),
          inset: 2pt,
          [*ASIGNATURA:*], [Sistemas Operativos],
          [*TEMA:*], [Implementación y Administración de Sistemas de Archivos],
          [*GRUPO:*], [Grupo 8 (Parte II: Capa Física y Software)],
          [*DOCENTE:*], [Ing. Norman Patrick Harvey Arce],
          [*ESTUDIANTES:*], [
            - Santiago Enrique Palma Apaza (CUI: 20240689)\
            - Rodolfo Paul Soria Soncco
          ],
          [*SEMESTRE:*], [VI Ciclo (Semestre 2026-B)],
        )
      ]
    ]

    #v(1.5cm)

    #text(size: 10.5pt, weight: "bold")[AREQUIPA – PERÚ]\
    #v(2pt)
    #text(size: 10.5pt)[2026]
  ]
]


// ==============================================================================
// RESUMEN / ABSTRACT
// ==============================================================================

#align(center)[
  #text(size: 13pt, weight: "bold")[RESUMEN EJECUTIVO]
]

#v(0.5cm)

El presente informe expone un análisis riguroso de la arquitectura física y los mecanismos de asignación de bloques en los sistemas de archivos de la familia Unix, tomando como estudio de referencia el sistema *Linux ext4*. Se examina la jerarquía de traducción de direcciones desde los sectores físicos del hardware (LBA) hasta los bloques lógicos de 4 KB del sistema operativo, justificando su alineación 1:1 con la memoria virtual x86_64 y modelando matemáticamente la fragmentación interna. Asimismo, se detalla la segmentación del disco en *Block Groups* para mitigar la latencia de cabezal (*seek time*), la anatomía de 256 bytes del inodo y su desacoplamiento axiomático del namespace de directorios mediante estructuras en árbol HTree. Se comparan formalmente los paradigmas de asignación en disco —contigua, enlazada, FAT, indexada clásica multinivel (ext2/ext3) y moderna basada en *Extents* (ext4)— demostrando cómo los extents sustituyen listas exhaustivas de punteros por tuplas continuas, reduciendo en más de un 90% la sobrecarga de metadatos. Finalmente, se presenta el diseño, desarrollo y validación de *`ext4-inspector`*, una herramienta forense de bajo nivel implementada en lenguaje C (C11) que interactúa directamente con los sectores binarios del disco sin dependencias de librerías auxiliares, capaz de parsear el Superbloque, resolver offsets físicos de inodos, recorrer el árbol B+ de extents y diagnosticar patologías como el agotamiento estático de inodos (`ENOSPC`).

*Palabras clave:* Sistemas de archivos, ext4, inodo, Superbloque, Block Groups, asignación indexada, Extents, fragmentación interna, forense digital, POSIX.

#v(1cm)
#line(length: 100%, stroke: 0.5pt + luma(180))
#v(0.5cm)

// ==============================================================================
// 1. INTRODUCCIÓN
// ==============================================================================

= Introducción y Justificación

La implementación eficiente de un sistema de archivos constituye uno de los mayores desafíos en la ingeniería de sistemas operativos. Mientras que la capa de usuario concibe un archivo como una secuencia lineal y contigua de bytes identificada por un nombre textual jerárquico, la realidad física del medio de almacenamiento consiste en una matriz de sectores magnéticos o celdas de memoria flash direccionadas mediante bloques lógicos (LBA, *Logical Block Addressing*).

La responsabilidad fundamental del sistema de archivos es tender un puente de alto rendimiento, consistente y seguro entre ambas abstracciones. Para lograrlo, el kernel debe resolver tres problemas fundamentales:
1. *Localización espacial:* ¿Cómo organizar los metadatos para minimizar el retardo mecánico (*seek time*) y la contención en discos de gran escala?
2. *Identidad vs. Nombre:* ¿Cómo desacoplar la estructura del archivo de su denominación lógica para permitir operaciones de directorio atómicas y enlaces múltiples (*Hard Links*)?
3. *Asignación de espacio:* ¿Cómo registrar los bloques asignados a un archivo para maximizar la velocidad de acceso secuencial y directo minimizando la sobrecarga de metadatos en disco?

Este trabajo aborda estos tres pilares mediante el estudio del sistema de archivos nativo de Linux: *ext4* (*Fourth Extended Filesystem*).

// ==============================================================================
// 2. GEOMETRÍA FÍSICA Y TRADUCCIÓN DE DIRECCIONES
// ==============================================================================

= Geometría Física y Traducción de Direcciones (LBA)

== Jerarquía de Mapeo: Sector vs. Bloque Lógico

En la base de la pila de almacenamiento, el controlador de disco opera sobre *sectores físicos*. Históricamente, el sector estándar de los discos duros magnéticos correspondía a 512 bytes. Los discos modernos implementan el estándar *Advanced Format (4Kn / 512e)* con sectores físicos de 4096 bytes (4 KB).

Sin embargo, el kernel de Linux no administra el almacenamiento sector por sector, sino mediante la abstracción del *Bloque Lógico del Sistema Operativo* (`block_size`). En la configuración estándar de ext4, el tamaño de bloque es de *4096 bytes (4 KB)*, equivalente a 8 sectores tradicionales de 512 bytes.

La elección de 4096 bytes no es arbitraria; obedece a un principio fundamental de diseño de sistemas: *la alineación 1:1 con la memoria virtual*. En la arquitectura x86_64, el tamaño de una página de memoria estándar (`PAGE_SIZE`) es de exactamente 4 KB. Al coincidir el bloque de disco con la página de memoria:
- El subsistema de *Page Cache* del kernel transfiere datos mediante acceso directo a memoria (DMA) directamente entre el búfer de página y el bloque de disco sin necesidad de realizar fragmentaciones, buffers intermedios ni transformaciones de alineación.
- Se optimiza la carga de ejecutables bajo demanda mediante fallos de página (*page faults*).

== Modelado Matemático de la Fragmentación Interna

La asignación de espacio en múltiplos rígidos de 4 KB genera inevitablemente *fragmentación interna*. Cuando un archivo posee un tamaño que no es múltiplo exacto del tamaño de bloque, el kernel debe asignar un bloque completo, dejando el espacio remanente inutilizable para otros archivos.

Sea $S_f$ el tamaño de un archivo en bytes y $B$ el tamaño de bloque del sistema operativo ($B = 4096$ bytes). El número de bloques requeridos $N_b$ se define como:

$ N_b = ceil(frac(S_f, B)) $

El espacio desperdiciado por fragmentación interna $I_f$ corresponde a:

$ I_f = (N_b times B) - S_f $

Asumiendo que el residuo $S_f "mod" B$ sigue una distribución uniforme continua en el intervalo $[0, B)$, el valor esperado del espacio desperdiciado por cada archivo individual es:

$ E[I_f] = frac(B, 2) = frac(4096, 2) = 2048 text(" bytes") $

En sistemas con millones de archivos pequeños (como almacenes de claves-valor o servidores de mensajería), la fragmentación interna consume gigabytes enteros de capacidad. Sin embargo, reducir el bloque a 1 KB cuadruplicaría el tamaño de las tablas de asignación y provocaría una severa fragmentación de lecturas secuenciales, justificando la elección de 4 KB como el balance óptimo.

// ==============================================================================
// 3. ANATOMÍA INTERNA DE ext4: BLOCK GROUPS Y SUPERBLOQUE
// ==============================================================================

= Anatomía Interna de ext4: Block Groups y Superbloque

== Segmentación en Grupos de Bloques (Block Groups)

En sistemas de archivos tempranos de Unix, existía una única tabla global de inodos al inicio del disco. Esto obligaba al cabezal del disco a viajar cientos de pistas desde los metadatos hasta la zona de datos del archivo.

Para solucionar este inconveniente, ext4 divide la partición en múltiples *Grupos de Bloques (Block Groups)* contiguos. En un volumen con bloques de 4 KB, cada grupo abarca típicamente 32,768 bloques, equivalentes a *128 Megabytes*.

Cada Block Group se distribuye físicamente de acuerdo con la siguiente estructura:

#align(center)[
#table(
  columns: (1fr, 1.2fr, 1.4fr, 1.2fr, 1.2fr, 1.4fr, 2.4fr),
  stroke: 0.6pt + black,
  fill: (col, row) => if row == 0 { luma(225) } else { luma(252) },
  align: center + horizon,
  [*Boot Block*], [*Superbloque*], [*Descriptores*], [*Bitmap Bloques*], [*Bitmap Inodos*], [*Tabla Inodos*], [*Bloques Datos*],
  [1024 bytes], [1 bloque (4 KB)], [N bloques GDT], [1 bloque], [1 bloque], [~512 bloques], [~32,250 bloques]
)
]

Esta arquitectura materializa el *principio de localidad de referencia espacial*: cuando el asignador de ext4 crea un archivo, intenta ubicar su inodo, sus bloques de datos y el directorio contenedor dentro del _mismo grupo de bloques_, minimizando la latencia de cabezal y maximizando el rendimiento en transferencias masivas.

== El Superbloque y la Replicación Sparse

El *Superbloque* es el descriptor maestro del sistema de archivos. Reside en el offset de 1024 bytes del disco y posee una estructura fija definida por el struct `ext4_super_block`. Sus campos más trascendentes incluyen:
- `s_magic` (0xEF53): Firma binaria que autentica el volumen como ext2, ext3 o ext4.
- `s_blocks_count_lo` y `s_inodes_count`: Conteo absoluto de bloques e inodos.
- `s_free_blocks_count_lo` y `s_free_inodes_count`: Conteo instantáneo de recursos libres.
- `s_state`: Indicador del estado de montaje (1 = montaje limpio; otros = volumen inconsistente o recuperándose).

Para prevenir la pérdida total del sistema de archivos ante fallas de hardware en el sector inicial, ext4 implementa la característica `sparse_super`. El Superbloque y la tabla GDT no se duplican en todos los grupos de bloques (lo que desperdiciaría espacio), sino únicamente en el Grupo 0 y en aquellos grupos cuyo número sea una potencia de 3, 5 y 7 (Grupos 1, 3, 5, 7, 9, 25, 49, etc.), permitiendo una reconstrucción segura con `fsck.ext4 -b <bloque_respaldo>`.

== La Patología de Agotamiento de Inodos (`ENOSPC`)

A diferencia de sistemas de archivos más modernos como ZFS o Btrfs que asignan metadatos dinámicamente, ext4 define su cantidad de inodos de forma *estática* durante el formateo (`mkfs.ext4`).

El parámetro por defecto reserva un inodo por cada 16 KB de disco (`bytes-per-inode ratio`). Si un servidor ejecuta aplicaciones que generan millones de archivos vacíos o de pocos bytes (por ejemplo, colas de correo Postfix saturadas o sesiones PHP en `/var/lib/php/sessions`), la tabla de inodos se agota completamente (`s_free_inodes_count == 0`), mientras que el espacio en bloques permanece libre en decenas de gigabytes.

En este estado crítico, cualquier intento de crear un archivo mediante `touch` o `open(..., O_CREAT)` arroja el error fatal de POSIX:
```text
touch: cannot touch 'archivo.txt': No space left on device
```
El código de retorno del kernel `ENOSPC` (código de error 28) es indistinto: se activa tanto por falta de bloques libres como por falta de slots de inodo, lo que exige diagnosticar mediante `df -i` en tareas de administración de sistemas.

// ==============================================================================
// 4. EL INODO VS. DIRECTORIOS
// ==============================================================================

= El Inodo (FCB) y el Desacoplamiento del Namespace

== Anatomía del Inodo en ext4

El Inodo (*Index Node*) actúa como el Bloque de Control de Archivo (FCB, *File Control Block*) en sistemas Unix. En ext4, cada inodo posee una longitud estándar de *256 bytes*. Su estructura en C (`struct ext4_inode`) almacena exclusivamente metadatos:

#table(
  columns: (1.2fr, 0.8fr, 2.5fr),
  stroke: 0.6pt + black,
  fill: (col, row) => if row == 0 { luma(225) } else { luma(255) },
  align: left,
  [*Campo en C*], [*Tamaño*], [*Función en el Sistema Operativo*],
  [`i_mode`], [16 bits], [Tipo de archivo (regular, dir, link, FIFO, socket) y permisos POSIX],
  [`i_uid` / `i_gid`], [16/32 bits], [Identificadores numéricos del usuario y grupo propietario],
  [`i_size_lo/hi`], [64 bits], [Tamaño lógico del archivo en bytes (soporta archivos de hasta 16 TB)],
  [`i_blocks_lo/hi`], [64 bits], [Conteo de sectores físicos de 512 bytes asignados realmente],
  [`i_atime/mtime/ctime`], [32/64 bits], [Marcas de tiempo: último acceso, modificación de datos y cambio de metadatos],
  [`i_links_count`], [16 bits], [Contador de referencias duras desde directorios],
  [`i_flags`], [32 bits], [Banderas operacionales (ej. `0x80000` = `EXT4_EXTENTS_FL`)],
  [`i_block[15]`], [60 bytes], [Espacio reservado para punteros directos o raíz del árbol de Extents]
)

=== Regla Axiomática de Diseño Unix
#align(center)[
  *El inodo NO contiene el nombre del archivo ni sus datos de usuario.*
]

== El Directorio como Función de Mapeo

Un directorio en ext4 no es más que un archivo especial cuyo contenido es una colección de registros o un árbol equilibrado (*HTree*, variante de B-Tree adaptada para hashing) que implementa una función matemática de mapeo:

$ f: text("Nombre de Archivo (string)") arrow.long.r text("Número de Inodo") in NN $

Cada registro dentro de un bloque de directorio sigue la estructura `struct ext4_dir_entry_2`:
- `inode` (4 bytes): Número del inodo destino.
- `rec_len` (2 bytes): Longitud total del registro actual (permite omitir entradas eliminadas).
- `name_len` (1 byte): Longitud del nombre del archivo.
- `file_type` (1 byte): Tipo de archivo para acelerar la resolución de `readdir` sin leer el inodo.
- `name[]`: Arreglo de caracteres con el nombre textual.

== Implicancias Prácticas: `mv`, Hard Links y Symlinks

El desacoplamiento entre nombre e inodo fundamenta la semántica POSIX moderna:

1. *Complejidad de `mv` en la misma partición:* Al mover un archivo de 50 GB entre carpetas del mismo sistema de archivos, la operación toma $O(1)$ tiempo constante. El kernel no transfiere ningún bloque de datos; únicamente desvincula la entrada en el directorio origen y crea una nueva entrada en el destino vinculada al mismo número de inodo.
2. *Hard Links (Enlaces Duros):* Un hard link crea una entrada adicional en un directorio apuntando al mismo inodo e incrementando `i_links_count` en 1. Cuando un usuario ejecuta `rm archivo`, el kernel ejecuta la llamada `unlink()`, restando 1 al contador. Los bloques físicos solo se liberan al cumplirse:
   $ text("i_links_count") == 0 quad and quad text("refcount(file_table)") == 0 $
   mientras un proceso mantenga el descriptor abierto, los datos continuarán existiendo en disco.
3. *Symbolic Links (Enlaces Simbólicos):* Es un archivo nuevo con su propio inodo (`S_IFLNK`) cuyo contenido es la ruta textual destino. Si la ruta posee menos de 60 bytes, ext4 implementa un *Fast Symlink*, almacenando la cadena directamente dentro de los 60 bytes de `i_block`, sin consumir ningún bloque de datos adicional.

// ==============================================================================
// 5. MÉTODOS DE ASIGNACIÓN EN DISCO
// ==============================================================================

= Métodos de Asignación en Disco: Evolución y Análisis

== Asignación Contigua
Cada archivo ocupa un conjunto de bloques físicamente contiguos en el disco, definido por la tupla `(bloque_inicio, longitud)`.
- *Ventajas:* Acceso secuencial óptimo y acceso aleatorio en $O(1)$.
- *Desventajas:* Sufre de *fragmentación externa* severa, requiriendo algoritmos de ajuste (First-Fit, Best-Fit) y costosas operaciones de compactación de disco. Exige preasignar el tamaño final del archivo.

== Asignación Enlazada y FAT
Cada bloque almacena un puntero al siguiente bloque del archivo.
- *Asignación Enlazada Pura:* Elimina la fragmentación externa, pero el acceso aleatorio es $O(n)$, exigiendo lecturas mecánicas sucesivas a lo largo del disco para resolver un offset lejano.
- *FAT (File Allocation Table):* Centraliza la lista enlazada en una tabla contigua al inicio del disco.
  - *Cuello de Botella:* Para mantener un rendimiento admisible, la tabla completa debe cargarse en RAM. En particiones grandes, una FAT consume megabytes continuos de memoria del kernel y escala de forma deficiente frente a volúmenes masivos.

== Asignación Indexada Clásica (ext2/ext3): Matemáticas del Árbol Multinivel

ext2 y ext3 implementaron la *Asignación Indexada Multinivel*, reservando 15 punteros de bloque de 32 bits (4 bytes) en el inodo. En un sistema de archivos con bloques de 4096 bytes:

$ text("Punteros por bloque índice") = frac(4096 text(" bytes"), 4 text(" bytes/puntero")) = 1024 text(" punteros") $

La jerarquía de direccionamiento se estructura del siguiente modo:
1. *12 Punteros Directos:* Mapean directamente 12 bloques de datos:
   $ 12 times 4 text(" KB") = 48 text(" KB") quad (1 text(" acceso físico a disco")) $
2. *1 Puntero Indirecto Simple:* Apunta a un bloque índice que aloja 1024 punteros directos:
   $ 1024 times 4 text(" KB") = 4 text(" MB") quad (2 text(" accesos físicos a disco")) $
3. *1 Puntero Indirecto Doble:* Apunta a un bloque que aloja 1024 punteros a bloques indirectos simples:
   $ 1024^2 times 4 text(" KB") = 1,048,576 times 4 text(" KB") = 4 text(" GB") quad (3 text(" accesos físicos")) $
4. *1 Puntero Indirecto Triple:* Apunta a una jerarquía de 3 niveles de bloques índice:
   $ 1024^3 times 4 text(" KB") = 1,073,741,824 times 4 text(" KB") = 4 text(" TB") quad (4 text(" accesos físicos")) $

*Límite Matemático Teórico:*
$ text("Capacidad Máxima") = 48 text(" KB") + 4 text(" MB") + 4 text(" GB") + 4 text(" TB") approx 4 text(" TB") $

*Sobrecarga Crítica:* Para direccionar un archivo de 500 GB, este esquema requiere asignar cientos de miles de bloques indirectos intermedios dedicados exclusivamente a almacenar direcciones numéricas de 4 bytes, generando una sobrecarga masiva de metadatos y degradando drásticamente el rendimiento de lectura aleatoria.

== Asignación Moderna: Extents en ext4

Para erradicar la sobrecarga de bloques indirectos, ext4 sustituyó el esquema de indexación exhaustiva por *Extents*.

Un *Extent* describe un conjunto contiguo de bloques físicos mediante una tupla de 12 bytes (`struct ext4_extent`):
- `ee_block` (32 bits): Bloque lógico inicial dentro del archivo.
- `ee_len` (16 bits): Cantidad de bloques continuos asignados (hasta $2^{15} = 32,768$ bloques = 128 MB).
- `ee_start_hi/lo` (48 bits): Dirección del bloque físico LBA de inicio en el medio físico.

Los 60 bytes disponibles en `i_block` del inodo se reestructuran como la raíz de un árbol B+ de extents:
- $1$ cabecera de extent (`struct ext4_extent_header`, 12 bytes).
- Hasta $4$ descriptores directos de extent ($4 times 12 = 48$ bytes).

*Rendimiento:* Si el archivo está mínimamente fragmentado, un único inodo describe directamente hasta:
$ 4 text(" extents") times 128 text(" MB") = 512 text(" MB contiguos") $
sin necesidad de asignar un solo bloque de metadatos externo en el disco, logrando una resolución en $O(1)$ y acelerando las lecturas secuenciales a velocidad pura de hardware.

// ==============================================================================
// 6. SOFTWARE DESARROLLADO: ext4-inspector
// ==============================================================================

= Software Desarrollado: `ext4-inspector` (C11 / POSIX)

== Objetivos de la Herramienta

Con el fin de comprobar experimentalmente la teoría expuesta, se diseñó e implementó *`ext4-inspector`*, un analizador forense escrito en C estándar (C11) que realiza lectura binaria directa sobre dispositivos de bloque o imágenes de disco ext4 sin utilizar librerías de usuario de alto nivel (`libext2fs`).

== Algoritmo de Localización Física del Inodo

Para leer cualquier inodo $I_n$ dentro del contenedor de disco, el software implementa la resolución matemática de offsets LBA:

#code-box([
```c
uint32_t group = (inode_num - 1) / g_sb.s_inodes_per_group;
uint32_t index = (inode_num - 1) % g_sb.s_inodes_per_group;

uint64_t itable_block = g_gdt[group].bg_inode_table_lo;
if (g_sb.s_desc_size >= 64) {
    itable_block |= ((uint64_t)g_gdt[group].bg_inode_table_hi << 32);
}

off_t inode_offset = (off_t)itable_block * g_block_size 
                   + (off_t)index * g_sb.s_inode_size;
```
])

El software realiza un `lseek` hacia `inode_offset` y ejecuta una lectura directa de `sizeof(ext4_inode)` (256 bytes), volcando las estructuras de permisos, enlaces y banderas.

== Algoritmo de Decodificación del Árbol de Extents

Una vez verificado el flag `EXT4_EXTENTS_FL` (`0x80000`) en `i_flags`, el software parsea el encabezado `ext4_extent_header` y extrae los descriptores directos para localizar los sectores de datos:

#code-box([
```c
ext4_extent_header *eh = (ext4_extent_header *)in.i_block;
if (eh->eh_magic == EXT4_EXTENTS_MAGIC && eh->eh_depth == 0) {
    ext4_extent *exts = (ext4_extent *)(in.i_block + sizeof(ext4_extent_header));
    for (uint16_t i = 0; i < eh->eh_entries; i++) {
        uint64_t phys_block = ((uint64_t)exts[i].ee_start_hi << 32) | exts[i].ee_start_lo;
        off_t byte_offset   = (off_t)phys_block * g_block_size;
        printf("Extent #%u: Blk Lógico %u -> LBA Físico %lu (Offset: 0x%lX)\n",
               i + 1, exts[i].ee_block, (unsigned long)phys_block, byte_offset);
    }
}
```
])

Con esta información, el comando `cat` lee secuencialmente los bloques físicos correspondientes y emite los bytes crudos directamente a la salida estándar, puenteando el subsistema VFS de Linux.

// ==============================================================================
// 7. PRUEBAS EXPERIMENTALES Y VALIDACIÓN
// ==============================================================================

= Pruebas Experimentales y Validación Forense

Para validar el funcionamiento del software desarrollado y corroborar la teoría de la asignación en ext4, se preparó un entorno de pruebas controlado mediante una imagen de disco loopback de 64 MB formateada con ext4 estándar:

== Verificación de Metadatos del Superbloque

La ejecución del comando `info` arrojó la siguiente salida analizada:

#code-box([
```text
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
```
])

*Hallazgo:* Se constata la presencia de la firma hexadecimal `0xEF53` y la reserva estática de 4,096 inodos para 16,384 bloques, confirmando la tasa estática de asignación.

== Cirugía de Extents y Extracción Cruda de Datos

Se inspeccionó el inodo 12 correspondiente a un archivo de texto regular creado dentro del sistema de archivos:

#code-box([
```text
[+] ANATOMÍA DEL INODO 12 (Offset físico LBA: 0x24C000 [2408448 bytes]):
    * Modo / Permisos POSIX    : -rw-r--r-- (Octal: 0644)
    * Tamaño Lógico del Archivo: 29 bytes
    * Contador de Hard Links   : 1 (i_links_count)
    * Flags Hexadecimal        : 0x00080000 (EXTENTS)
    * Descriptores de Extent:
      # | Bloque Lógico | Cantidad Bloques | Bloque Físico | Offset Físico Disco
      1 |             0 |                1 |          9243 | 0x241B000 (37859328 B)
```
])

Posteriormente, se ejecutó el comando de extracción directa de bytes:
```bash
./ext4_inspector disco_lab.img cat 12
```
produciendo en terminal:
```text
SISTEMAS OPERATIVOS UNSA 2026
```
La prueba demostró que los 29 bytes del archivo residen exactamente en el bloque físico 9243 ($37859328$ bytes desde el inicio de la partición), validando de forma irrefutable la correspondencia entre la estructura de Extents del inodo y la disposición física de los datos en el disco.

// ==============================================================================
// 8. CONCLUSIONES
// ==============================================================================

= Conclusiones

1. *Alineación con la Arquitectura de Hardware:* La elección del bloque lógico de 4 KB en ext4 responde a la necesidad de sincronizar el sistema de archivos con la unidad de paginación x86_64 del procesador y el subsistema de Page Cache, sacrificando una media de 2 KB por archivo por fragmentación interna para maximizar el ancho de banda mediante DMA.
2. *Desacoplamiento Estructural POSIX:* La separación arquitectónica estricta entre el Inodo (identidad binaria y metadatos) y el Directorio (namespace jerárquico) permite operaciones fundamentales como el renombrado o traslado atómico de archivos en $O(1)$ (`mv`) y la preservación de datos compartidos mediante *Hard Links*.
3. *Evolución del Rendimiento de Asignación:* La transición desde árboles de punteros indirectos (ext2/ext3) hacia descriptores de intervalos (*Extents* en ext4) redujo la sobrecarga de metadatos de un orden $O(N)$ proporcional al número de bloques a $O(1)$ para fragmentos contiguos, eliminando miles de operaciones de E/S innecesarias en archivos de gran envergadura.
4. *Validación Práctica:* La implementación del proyecto `ext4-inspector` demostró que es posible navegar quirúrgicamente las estructuras internas de un disco real en C puro, evidenciando que las abstracciones del sistema operativo son estructuras de datos concretas accesibles mediante offsets binarios.

// ==============================================================================
// 9. REFERENCIAS BIBLIOGRÁFICAS
// ==============================================================================

= Referencias Bibliográficas

- Silberschatz, A., Galvin, P. B., & Gagne, G. (2018). *Operating System Concepts* (10th ed.). Wiley.
- Tanenbaum, A. S., & Bos, H. (2015). *Modern Operating Systems* (4th ed.). Pearson.
- Bovet, D. P., & Cesati, M. (2005). *Understanding the Linux Kernel* (3rd ed.). O'Reilly Media.
- Mathur, A., Cao, M., Bhattacharya, S., Dilger, A., Tomas, A., & Vivier, L. (2007). *The new ext4 filesystem: principles and features*. Linux Symposium.
- Linux Kernel Organization. (2026). *ext4 Disk Layout Documentation*. Archivo fuente del kernel de Linux: `Documentation/filesystems/ext4/`.
