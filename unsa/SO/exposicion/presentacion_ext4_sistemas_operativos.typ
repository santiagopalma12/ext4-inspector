// ==============================================================================
// PRESENTACIÓN ACADÉMICA - SISTEMAS OPERATIVOS (UNSA)
// Tema: Arquitectura Física en Disco, Inodos, Asignación y Forense en ext4
// Estilo: Rigor académico, monocromático (blanco/negro), Times New Roman & Mono
// ==============================================================================

#set page(
  paper: "presentation-16-9",
  margin: (x: 2cm, top: 1.6cm, bottom: 1.3cm),
  header: context {
    let p = counter(page).get().first()
    if p > 1 [
      #grid(
        columns: (1fr, 1fr),
        align(left)[
          #text(font: "Times New Roman", size: 8.5pt, fill: luma(60))[
            *SISTEMAS OPERATIVOS* | UNSA -- EPIS | PARTE II: ARQUITECTURA FÍSICA Y EXT4
          ]
        ],
        align(right)[
          #text(font: "Times New Roman", size: 8.5pt, fill: luma(60))[
            #datetime.today().display("[day]/[month]/[year]")
          ]
        ]
      )
      #v(-3pt)
      #line(length: 100%, stroke: 0.6pt + luma(100))
    ]
  },
  footer: context {
    let p = counter(page).get().first()
    if p > 1 [
      #line(length: 100%, stroke: 0.6pt + luma(100))
      #v(2pt)
      #grid(
        columns: (1fr, 1fr),
        align(left)[
          #text(font: "Times New Roman", size: 8.5pt, style: "italic", fill: luma(80))[
            Implementación y Administración de Sistemas de Archivos
          ]
        ],
        align(right)[
          #text(font: "Times New Roman", size: 8.5pt, weight: "bold")[
            #counter(page).display("1 / 1", both: true)
          ]
        ]
      )
    ]
  }
)

#set text(font: "Times New Roman", size: 12.5pt, lang: "es")
#set par(justify: true, leading: 0.65em)

// --- COMPONENTES AUXILIARES ACADÉMICOS ---

#let slide-title(title, subtitle) = [
  #v(-6pt)
  #text(font: "Times New Roman", size: 17pt, weight: "bold")[#title]
  #if subtitle != "" [
    \ #text(font: "Times New Roman", size: 10.5pt, style: "italic", fill: luma(60))[#subtitle]
  ]
  #v(4pt)
  #line(length: 100%, stroke: 1.2pt + black)
  #v(6pt)
]

#let terminal-block(title, cmd, output) = [
  #block(
    width: 100%,
    stroke: 0.8pt + black,
    fill: luma(252),
    inset: (x: 10pt, y: 8pt),
    radius: 0pt,
    [
      #if title != "" [
        #text(font: "DejaVu Sans Mono", size: 7.5pt, weight: "bold", fill: luma(50))[#title]
        #v(-4pt)
        #line(length: 100%, stroke: 0.4pt + luma(160))
        #v(2pt)
      ]
      #if cmd != "" [
        #text(font: "DejaVu Sans Mono", size: 8.5pt, weight: "bold")[#cmd]
        \
      ]
      #text(font: "DejaVu Sans Mono", size: 7.8pt, fill: luma(20))[#output]
    ]
  )
]

#let concept-box(title, body) = [
  #block(
    width: 100%,
    stroke: 0.8pt + black,
    fill: luma(255),
    inset: (x: 10pt, y: 8pt),
    radius: 0pt,
    [
      #text(font: "Times New Roman", size: 10.5pt, weight: "bold")[#title]
      #v(3pt)
      #text(font: "Times New Roman", size: 10pt)[#body]
    ]
  )
]

// ==============================================================================
// DIAPOSITIVA 1: PORTADA ACADÉMICA
// ==============================================================================

#align(center + horizon)[
  #text(font: "Times New Roman", size: 11pt, weight: "bold", tracking: 0.5pt)[
    UNIVERSIDAD NACIONAL DE SAN AGUSTÍN DE AREQUIPA
  ]
  \
  #text(font: "Times New Roman", size: 10pt)[
    FACULTAD DE INGENIERÍA DE PRODUCCIÓN Y SERVICIOS \
    ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS
  ]

  #v(14pt)
  #line(length: 80%, stroke: 1.5pt + black)
  #v(8pt)

  #text(font: "Times New Roman", size: 21pt, weight: "bold")[
    Arquitectura Física y Métodos de Asignación\ en Sistemas de Archivos
  ]
  \ #v(2pt)
  #text(font: "Times New Roman", size: 12.5pt, style: "italic")[
    Anatomía de Disco, Inodos y Estructuras de Asignación con Extents en Linux ext4
  ]

  #v(8pt)
  #line(length: 80%, stroke: 0.8pt + black)
  #v(16pt)

  #grid(
    columns: (1fr, 1fr),
    align(left)[
      #text(size: 9.5pt)[
        *Curso:* Sistemas Operativos (VI Semestre) \
        *Tema:* Implementación y Adm. de Archivos \
        *Foco:* Arquitectura Física, Inodos y Extents \
        *Docente:* Ing. Norman Patrick Harvey Arce
      ]
    ],
    align(right)[
      #text(size: 9.5pt)[
        *Expositores (Grupo 8):* \
        - Santiago Enrique Palma Apaza \
        - Rodolfo Paul Soria Soncco \
        *Fecha:* 25 de Noviembre de 2026
      ]
    ]
  )
]

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 2: GEOMETRÍA DEL DISCO Y TRADUCCIÓN DE DIRECCIONES
// ==============================================================================

#slide-title(
  "1. Geometría de Almacenamiento y Traducción de Direcciones",
  "De la física del disco (LBA) a la abstracción de bloques lógicos del Sistema Operativo"
)

#grid(
  columns: (1.1fr, 0.9fr),
  column-gutter: 14pt,
  [
    #concept-box("Jerarquía de Mapeo: Sector vs. Bloque", [
      - *Sector Físico (Hardware):* Unidad mínima atómica de transferencia en el medio de almacenamiento ($512$ B tradicional o $4$ KB en discos _Advanced Format 4Kn_).
      - *Bloque Lógico del SO (ext4):* Unidad mínima de asignación del kernel (típicamente $4$ KB = $4096$ bytes = 8 sectores de 512 B).
      - *Alineación de Página 1:1:* El bloque de $4$ KB coincide con el tamaño estándar de página de memoria virtual x86_64 (`PAGE_SIZE`), eliminando sobrecargas de conversión en el Page Cache.
    ])

    #v(6pt)
    #concept-box("Patología: Fragmentación Interna", [
      - Ocurre cuando el tamaño del archivo no es múltiplo exacto del bloque.
      - Para un archivo de 50 bytes, el SO reserva un bloque completo ($4096$ B), desperdiciando $4046$ bytes ($98.7\%$).
      $ text("Pérdida media por archivo") = frac(text("Block Size"), 2) approx 2048 text(" bytes") $
    ])
  ],
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[Mapeo de Direcciones en Bloques Lógicos (LBA)]
      #v(4pt)
      #table(
        columns: (1fr),
        stroke: 0.8pt + black,
        fill: (col, row) => if row == 0 { luma(230) } else { luma(255) },
        align: center,
        [*Archivo Lógico (Offset 0 .. 9200 bytes)*],
        [Bloque Lógico 0 ($0 dots 4095$ B) $arrow.r$ LBA 10528 (8 sectores)],
        [Bloque Lógico 1 ($4096 dots 8191$ B) $arrow.r$ LBA 10536 (8 sectores)],
        [Bloque Lógico 2 ($8192 dots 9200$ B) $arrow.r$ LBA 10544 (8 sectores)],
        [#text(fill: luma(90), style: "italic")[Espacio No Utilizado (Fragmentación Interna: 3087 B)]]
      )
    ]
    #v(4pt)
    #text(size: 8.5pt, style: "italic")[
      *Conclusión Técnica:* Reducir el tamaño de bloque a 1 KB atenúa la fragmentación interna pero dispara el tamaño de las tablas de asignación y fragmenta lecturas secuenciales.
    ]
  ]
)

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 3: ANATOMÍA DE LA PARTICIÓN ext4: BLOCK GROUPS
// ==============================================================================

#slide-title(
  "2. Anatomía de una Partición ext4: Grupos de Bloques",
  "Segmentación del disco en 'Block Groups' contiguos para maximizar la localidad espacial"
)

#concept-box("Problema de Escala en Discos Grandes", [
  En sistemas de archivos tempranos con una única tabla global al inicio del disco, el cabezal lector sufre desplazamientos mecánicos continuos (*seek time*) entre metadatos y datos. En SSDs, genera contención y cuellos de botella en estructuras centralizadas.
])

#v(8pt)

#align(center)[
  #text(size: 9.5pt, weight: "bold")[Distribución Física en Disco de un Grupo de Bloques (Block Group)]
  #v(4pt)
  #table(
    columns: (1fr, 1.2fr, 1.5fr, 1.35fr, 1.25fr, 1.4fr, 2.3fr),
    stroke: 0.8pt + black,
    fill: (col, row) => if row == 0 { luma(225) } else { luma(252) },
    align: center + horizon,
    [#text(size: 8.5pt)[*Boot Block*]],
    [#text(size: 8.5pt)[*Superbloque*]],
    [#text(size: 8.5pt)[*Descriptores Grupo*]],
    [#text(size: 8.5pt)[*Bitmap Bloques*]],
    [#text(size: 8.5pt)[*Bitmap Inodos*]],
    [#text(size: 8.5pt)[*Tabla Inodos*]],
    [#text(size: 8.5pt)[*Bloques de Datos*]],
    [Primeros\ 1024 B], [Copia BG0\ (1 bloque)], [GDT Array\ (N bloques)], [Uso espacio\ (1 bloque)], [Uso inodos\ (1 bloque)], [Metadatos FCB\ (~512 bloques)], [Archivos y dir.\ (~32,250 bloques)]
  )
]

#v(6pt)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 14pt,
  [
    *Principio de Localidad de Referencia:*
    - Cada grupo administra su propio subconjunto de inodos y bloques.
    - El asignador ubica preferentemente los bloques de un archivo dentro del _mismo grupo_ que aloja su inodo.
  ],
  [
    *Mitigación de Puntos Únicos de Fallo:*
    - El *Superbloque* y la *GDT* se replican en grupos estratégicos (BG0, BG3, BG5, BG7 mediante la característica `sparse_super`).
    - Permite reconstrucción ante daños sectoriales con `fsck.ext4 -b <offset>`.
  ]
)

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 4: EL SUPERBLOQUE Y AGOTAMIENTO DE INODOS
// ==============================================================================

#slide-title(
  "3. El Superbloque y la Patología de Agotamiento de Inodos",
  "El descriptor maestro del sistema de archivos y las limitaciones de la asignación estática de metadatos"
)

#grid(
  columns: (1.1fr, 0.9fr),
  column-gutter: 14pt,
  [
    #concept-box("Anatomía del Superbloque (Offset 1024 bytes)", [
      - *Magic Number (`0xEF53`):* Identificador hexadecimal de sistemas ext2/3/4.
      - *Geometría:* Conteo total de bloques (`s_blocks_count`) e inodos (`s_inodes_count`).
      - *Estado:* Marcas de montaje limpio (`s_state = 1`), contadores libres y tamaño de bloque (`s_log_block_size`).
    ])

    #v(6pt)
    #concept-box("Patología: 'No space left on device' con Gigabytes Libres", [
      - Durante `mkfs.ext4`, la cantidad de inodos queda *fijada estáticamente* según el ratio `bytes-per-inode` (por defecto 16 KB).
      - *Escenario Real:* Servidores con millones de microarchivos agotan la Tabla de Inodos ($100\%$ de uso en inodos) teniendo decenas de GB libres de almacenamiento de datos.
    ])
  ],
  [
    #terminal-block("DIAGNÓSTICO EN PRODUCCIÓN: COLAPSO POR INODOS", "",
      "$ df -h /datos\n" +
      "Filesystem      Size  Used Avail Use% Mounted on\n" +
      "/dev/sdb1        50G  2.1G   45G   5% /datos\n\n" +
      "$ touch /datos/prueba.txt\n" +
      "touch: cannot touch '/datos/prueba.txt': No space left on device\n\n" +
      "$ df -i /datos\n" +
      "Filesystem       Inodes   IUsed   IFree IUse% Mounted on\n" +
      "/dev/sdb1       3276800 3276800       0  100% /datos"
    )
    #v(2pt)
    #text(size: 8.5pt, style: "italic")[
      *Causa de Fondo:* `ENOSPC` no distingue entre falta de bloques de datos libres (`s_free_blocks_count == 0`) o falta de slots de inodo libres (`s_free_inodes_count == 0`).
    ]
  ]
)

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 5: EL INODO (FCB) VS. DIRECTORIOS
// ==============================================================================

#slide-title(
  "4. El Inodo (FCB) vs. Directorios",
  "Separación arquitectónica estricta entre la identidad del archivo y su namespace jerárquico"
)

#grid(
  columns: (1.2fr, 0.8fr),
  column-gutter: 14pt,
  [
    #text(size: 10pt, weight: "bold")[Estructura del Inodo en ext4 (`struct ext4_inode` -- 256 Bytes)]
    #v(3pt)
    #table(
      columns: (1.2fr, 0.75fr, 2.05fr),
      stroke: 0.6pt + black,
      fill: (col, row) => if row == 0 { luma(225) } else { luma(255) },
      align: (col, row) => if col == 0 { left } else { left },
      [*Campo*], [*Tamaño*], [*Propósito Arquitectónico*],
      [`i_mode`], [16 bits], [Tipo de archivo (regular, directorio, link) y permisos],
      [`i_uid` / `i_gid`], [16/32 bits], [Identificadores de usuario y grupo propietario],
      [`i_size_lo/hi`], [64 bits], [Tamaño lógico del archivo en bytes],
      [`i_blocks_lo/hi`], [64 bits], [Conteo real de sectores de 512 B asignados],
      [`i_atime/mtime/ctime`], [32/64 bits], [Marcas temporales (acceso, modificación, cambio inodo)],
      [`i_links_count`], [16 bits], [Contador de referencias de directorios (Hard Links)],
      [`i_block[15]` / Extent], [60 bytes], [Punteros a bloques directos o raíz del árbol de extents]
    )
  ],
  [
    #concept-box("Regla Axiomática de Diseño", [
      *El inodo NO contiene el nombre del archivo ni sus datos de usuario.*
    ])
    #v(6pt)
    #concept-box("El Directorio como Función de Mapeo", [
      Un directorio es un archivo regular cuyo contenido es una lista/árbol (*HTree* B-Tree) de tuplas de enlace:
      #align(center)[
        $f: text("Nombre de Archivo") arrow.long.r text("Número de Inodo") (i_n)$
      ]
      Cada entrada almacena: `inode_num` (4 B), `rec_len` (2 B), `name_len` (1 B), `file_type` (1 B) y el string `name`.
    ])
  ]
)

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 6: SEMÁNTICA OPERACIONAL: mv, HARD LINKS Y SYMLINKS
// ==============================================================================

#slide-title(
  "5. Semántica Operacional: mv, Hard Links y Symlinks",
  "Implicancias prácticas de la separación entre nombre e inodo en el espacio de usuario"
)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 14pt,
  [
    #concept-box("1. Operación 'mv' Intramount es O(1)", [
      - Mover un archivo dentro de la misma partición *no traslada ningún bloque de datos*.
      - Solo implica eliminar la entrada en el directorio origen y escribir una nueva en el destino vinculada al mismo número de inodo.
      - Si se cruzan particiones distintas (`cross-device`), `mv` se degrada a copia física $O(n)$ más borrado.
    ])

    #v(6pt)
    #concept-box("2. Hard Links: Múltiples Nombres, Una Identidad", [
      - Crea una entrada de directorio adicional apuntando al *mismo inodo*.
      - Incrementa `i_links_count` en 1.
      - La desasignación física de bloques ocurre únicamente cuando `i_links_count == 0` *y* no existen descriptores abiertos en la tabla global del kernel.
    ])
  ],
  [
    #concept-box("3. Symbolic (Soft) Links: Punteros por Ruta", [
      - Es un archivo nuevo independiente con su propio inodo (`S_IFLNK`).
      - Su contenido es la cadena de texto de la ruta destino.
      - Si el archivo original se elimina, el symlink queda *huérfano (dangling)*.
    ])

    #v(4pt)
    #align(center)[
      #text(size: 9pt, weight: "bold")[Comparación Estructural: Hard Link vs. Symlink]
      #v(2pt)
      #table(
        columns: (0.9fr, 1fr, 1.4fr),
        stroke: 0.6pt + black,
        fill: (col, row) => if row == 0 { luma(230) } else { luma(255) },
        align: center,
        [*Propiedad*], [*Hard Link*], [*Symbolic Link*],
        [Inodo], [Mismo número], [Nuevo inodo propio],
        [Particiones], [Sólo local], [Permitido (rutas)],
        [Borrado Origen], [Datos preservados], [Enlace roto (huérfano)],
        [Espacio Disco], [0 bytes extra], [Ruta string ($< 60$ B Fast)]
      )
    ]
  ]
)

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 7: ASIGNACIÓN EN DISCO: CONTIGUA VS. ENLAZADA / FAT
// ==============================================================================

#slide-title(
  "6. Métodos de Asignación en Disco: Contigua vs. Enlazada y FAT",
  "Evolución histórica de los mecanismos de asignación de bloques y sus compromisos de rendimiento"
)

#grid(
  columns: (1fr, 1fr),
  column-gutter: 14pt,
  [
    #concept-box("Asignación Contigua (Arreglo Lineal)", [
      - *Mecanismo:* Los archivos ocupan bloques adyacentes continuos `(bloque_inicio, longitud)`.
      - *Ventajas:* Acceso secuencial óptimo y acceso aleatorio directo en $O(1)$ sin sobrecarga.
      - *Fallas Críticas:*
        1. *Fragmentación Externa:* Huecos libres dispersos requieren algoritmos First-Fit / Best-Fit y compactación costosa.
        2. *Preasignación Rígida:* Requiere estimar el tamaño final del archivo al crearlo.
    ])

    #v(6pt)
    #text(size: 8.5pt, style: "italic")[
      *Uso Moderno:* CD-ROMs (ISO 9660) y buffers estáticos de alta velocidad donde el tamaño es inmutable.
    ]
  ],
  [
    #concept-box("Asignación Enlazada y FAT (File Allocation Table)", [
      - *Enlazada Pura:* Cada bloque físico almacena un puntero de 4 bytes hacia el siguiente bloque.
        - Elimina fragmentación externa, pero el acceso aleatorio es $O(n)$ y requiere múltiples I/Os mecánicos.
      - *Solución FAT (MS-DOS / FAT32):*
        - Extrae todos los punteros de los bloques y los consolida en una tabla centralizada al inicio de la partición.
        - *Cuello de Botella:* Para un acceso rápido, la tabla completa debe residir en RAM. Escala de forma deficiente en discos de gran capacidad (FAT32 no soporta archivos $> 4$ GB ni particiones modernas eficientes).
    ])
  ]
)

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 8: ASIGNACIÓN INDEXADA CLÁSICA (ext2/ext3): MATEMÁTICAS
// ==============================================================================

#slide-title(
  "7. Asignación Indexada Clásica (ext2/ext3): Árbol Multinivel",
  "Resolución de bloques mediante bloques índices indirectos y límites matemáticos de capacidad"
)

#grid(
  columns: (1.1fr, 0.9fr),
  column-gutter: 14pt,
  [
    #concept-box("Estructura de 15 Punteros en el Inodo (Bloque = 4 KB)", [
      Con punteros de bloque de 32 bits ($4$ bytes), cada bloque de datos puede contener exactamente:
      $ frac(4096 text(" bytes"), 4 text(" bytes/puntero")) = 1024 text(" punteros por bloque índice") $

      1. *12 Punteros Directos:* Mapean $12 times 4$ KB = *48 KB* ($1$ salto de lectura).
      2. *1 Indirecto Simple:* Mapea $1024 times 4$ KB = *4 MB* ($2$ saltos de lectura).
      3. *1 Indirecto Doble:* Mapea $1024^2 times 4$ KB = *4 GB* ($3$ saltos de lectura).
      4. *1 Indirecto Triple:* Mapea $1024^3 times 4$ KB = *4 TB* ($4$ saltos de lectura).
    ])
  ],
  [
    #align(center)[
      #text(size: 9pt, weight: "bold")[Jerarquía de Saltos de I/O en ext2/ext3]
      #v(4pt)
      #table(
        columns: (1.2fr, 1fr, 1.4fr),
        stroke: 0.6pt + black,
        fill: (col, row) => if row == 0 { luma(230) } else { luma(255) },
        align: center,
        [*Nivel de Puntero*], [*Capacidad*], [*I/Os para Resolver*],
        [Directos (0--11)], [48 KB], [1 acceso físico],
        [Indirecto Simple], [4 MB], [2 accesos físicos],
        [Indirecto Doble], [4 GB], [3 accesos físicos],
        [Indirecto Triple], [4 TB], [4 accesos físicos]
      )
    ]
    #v(6pt)
    #concept-box("Problema de Escalabilidad", [
      Un archivo de 500 GB requiere crear miles de bloques indirectos intermedios para almacenar solo punteros, generando sobrecarga masiva de metadatos e I/O de búsqueda.
    ])
  ]
)

#pagebreak()

// ==============================================================================
// DIAPOSITIVA 9: ASIGNACIÓN MODERNA: EXTENTS EN ext4
// ==============================================================================

#slide-title(
  "8. Asignación Moderna: Extents en ext4",
  "Sustitución de listas de bloques individuales por descriptores de rangos continuos"
)

#grid(
  columns: (1.1fr, 0.9fr),
  column-gutter: 14pt,
  [
    #concept-box("El Paradigma de Extent", [
      En lugar de indexar cada bloque individualmente `[blk 500, blk 501, blk 502...]`, un *Extent* define un descriptor compacto de bloques contiguos:
      #align(center)[
        `{ logical_block_start, block_count, physical_block_start }`
      ]
    ])

    #v(4pt)
    #text(size: 9.5pt, weight: "bold")[Estructura `struct ext4_extent` (12 Bytes)]
    #table(
      columns: (1fr, 0.8fr, 2fr),
      stroke: 0.6pt + black,
      fill: (col, row) => if row == 0 { luma(225) } else { luma(255) },
      align: left,
      [*Campo*], [*Tamaño*], [*Descripción*],
      [`ee_block`], [32 bits], [Primer bloque lógico del archivo cubierto],
      [`ee_len`], [16 bits], [Cantidad de bloques contiguos (hasta $32,768$ = 128 MB)],
      [`ee_start_hi/lo`], [48 bits], [Bloque físico de inicio en el disco (LBA)]
    )
  ],
  [
    #concept-box("Árbol de Extents Dentro del Inodo", [
      - El espacio de 60 bytes en `i_block` aloja directamente:
        - $1$ cabecera de extent (`ext4_extent_header`, 12 B).
        - Hasta $4$ descriptores directos de extent ($4 times 12$ B = 48 B).
      - *Resultado:* Un archivo continuo de hasta *512 MB* se describe enteramente dentro del inodo sin gastar un solo bloque extra de metadatos ($O(1)$ sin I/O indirecto).
    ])
    #v(6pt)
    #text(size: 8.5pt, style: "italic")[
      *Ventaja de Rendimiento:* Reducción drástica del tamaño de la tabla de asignación, preasignación contigua y aceleración del tiempo de lectura secuencial.
    ]
  ]
)

