/**
 * @file ext4_structs.h
 * @brief Definiciones de estructuras binarias para inspección de bajo nivel en ext4.
 *
 * Basado en la especificación del kernel de Linux (fs/ext4/ext4.h).
 * Alineado para arquitectura x86_64 con empaquetamiento estricto.
 */

#ifndef EXT4_STRUCTS_H
#define EXT4_STRUCTS_H

#include <stdint.h>

#define EXT4_SUPERBLOCK_OFFSET 1024
#define EXT4_SUPERBLOCK_MAGIC  0xEF53
#define EXT4_EXTENTS_MAGIC     0xF30A
#define EXT4_EXTENTS_FL        0x00080000

#define EXT4_ROOT_INO          2
#define EXT4_GOOD_OLD_FIRST_INO 11

#define EXT4_FT_UNKNOWN  0
#define EXT4_FT_REG_FILE 1
#define EXT4_FT_DIR      2
#define EXT4_FT_CHRDEV   3
#define EXT4_FT_BLKDEV   4
#define EXT4_FT_FIFO     5
#define EXT4_FT_SOCK     6
#define EXT4_FT_SYMLINK  7

#pragma pack(push, 1)

/**
 * @brief Superbloque de ext4 (primeros campos críticos).
 */
typedef struct {
    uint32_t s_inodes_count;          /* Conteo total de inodos */
    uint32_t s_blocks_count_lo;       /* Conteo total de bloques (bits bajos) */
    uint32_t s_r_blocks_count_lo;     /* Conteo de bloques reservados */
    uint32_t s_free_blocks_count_lo;  /* Conteo de bloques libres */
    uint32_t s_free_inodes_count;     /* Conteo de inodos libres */
    uint32_t s_first_data_block;      /* Primer bloque de datos (0 si 4KB, 1 si 1KB) */
    uint32_t s_log_block_size;        /* Tamaño de bloque: 1024 << s_log_block_size */
    uint32_t s_log_cluster_size;      /* Tamaño de cluster */
    uint32_t s_blocks_per_group;      /* Bloques por cada Block Group */
    uint32_t s_clusters_per_group;    /* Clusters por grupo */
    uint32_t s_inodes_per_group;      /* Inodos por cada Block Group */
    uint32_t s_mtime;                 /* Tiempo de montaje */
    uint32_t s_wtime;                 /* Tiempo de escritura */
    uint16_t s_mnt_count;             /* Montajes desde última verificación */
    int16_t  s_max_mnt_count;         /* Máximo conteo de montajes */
    uint16_t s_magic;                 /* Número mágico (0xEF53) */
    uint16_t s_state;                 /* Estado del FS (1 = limpio) */
    uint16_t s_errors;                /* Comportamiento ante errores */
    uint16_t s_minor_rev_level;       /* Nivel de revisión menor */
    uint32_t s_lastcheck;             /* Último fsck */
    uint32_t s_checkinterval;         /* Intervalo de verificación */
    uint32_t s_creator_os;            /* OS creador (0 = Linux) */
    uint32_t s_rev_level;             /* Nivel de revisión (1 = dinámico) */
    uint16_t s_def_resuid;            /* UID por defecto para bloques reservados */
    uint16_t s_def_resgid;            /* GID por defecto para bloques reservados */
    uint32_t s_first_ino;             /* Primer inodo utilizable (usualmente 11) */
    uint16_t s_inode_size;            /* Tamaño en bytes de cada inodo (ej. 256) */
    uint16_t s_block_group_nr;        /* N° de bloque de grupo de este superbloque */
    uint32_t s_feature_compat;        /* Características compatibles */
    uint32_t s_feature_incompat;      /* Características incompatibles */
    uint32_t s_feature_ro_compat;     /* Características read-only compatibles */
    uint8_t  s_uuid[16];              /* Identificador UUID de 128 bits */
    char     s_volume_name[16];       /* Nombre del volumen */
    char     s_last_mounted[64];      /* Última ruta de montaje */
    uint32_t s_algorithm_usage_bitmap;/* Para compresión */
    uint8_t  s_prealloc_blocks;       /* Bloques de preasignación */
    uint8_t  s_prealloc_dir_blocks;   /* Bloques de preasignación para directorios */
    uint16_t s_reserved_gdt_blocks;   /* Bloques reservados para GDT */
    uint8_t  s_journal_uuid[16];      /* UUID del journal */
    uint32_t s_journal_inum;          /* Inodo del journal */
    uint32_t s_journal_dev;           /* Dispositivo del journal */
    uint32_t s_last_orphan;           /* Lista de inodos huérfanos */
    uint32_t s_hash_seed[4];          /* Semillas para HTree */
    uint8_t  s_def_hash_version;      /* Versión de hash */
    uint8_t  s_jnl_backup_type;
    uint16_t s_desc_size;             /* Tamaño del descriptor de grupo (32 o 64 B) */
    uint32_t s_default_mount_opts;
    uint32_t s_first_meta_bg;
    uint32_t s_mkfs_time;
    uint32_t s_jnl_blocks[17];
    uint32_t s_blocks_count_hi;       /* 64-bit blocks count */
    uint32_t s_r_blocks_count_hi;
    uint32_t s_free_blocks_count_hi;
    uint16_t s_min_extra_isize;
    uint16_t s_want_extra_isize;
    uint32_t s_flags;
} ext4_super_block;

/**
 * @brief Descriptor de Grupo de Bloques (GDT).
 */
typedef struct {
    uint32_t bg_block_bitmap_lo;      /* Bloque del bitmap de bloques libres */
    uint32_t bg_inode_bitmap_lo;      /* Bloque del bitmap de inodos libres */
    uint32_t bg_inode_table_lo;       /* Bloque inicial de la tabla de inodos */
    uint16_t bg_free_blocks_count_lo; /* Conteo de bloques libres en el grupo */
    uint16_t bg_free_inodes_count_lo; /* Conteo de inodos libres en el grupo */
    uint16_t bg_used_dirs_count_lo;   /* Conteo de directorios */
    uint16_t bg_flags;                /* Flags (ej. INODE_UNINIT) */
    uint32_t bg_exclude_bitmap_lo;
    uint16_t bg_block_bitmap_csum_lo;
    uint16_t bg_inode_bitmap_csum_lo;
    uint16_t bg_itable_unused_lo;
    uint16_t bg_checksum;
    /* Campos para descriptores de 64 bits */
    uint32_t bg_block_bitmap_hi;
    uint32_t bg_inode_bitmap_hi;
    uint32_t bg_inode_table_hi;
    uint16_t bg_free_blocks_count_hi;
    uint16_t bg_free_inodes_count_hi;
    uint16_t bg_used_dirs_count_hi;
    uint16_t bg_itable_unused_hi;
    uint32_t bg_exclude_bitmap_hi;
    uint16_t bg_block_bitmap_csum_hi;
    uint16_t bg_inode_bitmap_csum_hi;
    uint32_t bg_reserved;
} ext4_group_desc;

/**
 * @brief Inodo en ext4 (256 bytes típicos).
 */
typedef struct {
    uint16_t i_mode;                  /* Formato y permisos de acceso */
    uint16_t i_uid;                   /* UID propietario (16 bits bajos) */
    uint32_t i_size_lo;               /* Tamaño del archivo en bytes (32 bits bajos) */
    uint32_t i_atime;                 /* Marca temporal de acceso */
    uint32_t i_ctime;                 /* Marca temporal de cambio de inodo */
    uint32_t i_mtime;                 /* Marca temporal de modificación */
    uint32_t i_dtime;                 /* Marca temporal de eliminación */
    uint16_t i_gid;                   /* GID propietario (16 bits bajos) */
    uint16_t i_links_count;           /* Conteo de Hard Links */
    uint32_t i_blocks_lo;             /* Conteo de sectores de 512B */
    uint32_t i_flags;                 /* Flags (0x80000 = EXTENTS) */
    uint32_t i_osd1;                  /* Específico del SO */
    uint8_t  i_block[60];             /* Punteros de bloque o árbol de extents */
    uint32_t i_generation;           /* Generación del archivo (para NFS) */
    uint32_t i_file_acl_lo;           /* Bloque de ACL */
    uint32_t i_size_high;             /* Tamaño alto (para archivos > 4 GB) */
    uint32_t i_obso_faddr;
    uint8_t  i_osd2[12];
    uint16_t i_extra_isize;
    uint16_t i_checksum_hi;
    uint32_t i_ctime_extra;
    uint32_t i_mtime_extra;
    uint32_t i_atime_extra;
    uint32_t i_crtime;
    uint32_t i_crtime_extra;
    uint32_t i_version_hi;
} ext4_inode;

/**
 * @brief Cabecera de árbol de extents (12 bytes).
 */
typedef struct {
    uint16_t eh_magic;                /* Número mágico: 0xF30A */
    uint16_t eh_entries;              /* Cantidad de entradas válidas siguientes */
    uint16_t eh_max;                  /* Capacidad máxima de entradas */
    uint16_t eh_depth;                /* Profundidad: 0 = hoja hacia datos, >0 = índice */
    uint32_t eh_generation;           /* Generación */
} ext4_extent_header;

/**
 * @brief Descriptor de Extent en hoja (12 bytes).
 */
typedef struct {
    uint32_t ee_block;                /* Primer número de bloque lógico en el archivo */
    uint16_t ee_len;                  /* Cantidad de bloques contiguos asignados */
    uint16_t ee_start_hi;             /* 16 bits altos de la dirección física del bloque */
    uint32_t ee_start_lo;             /* 32 bits bajos de la dirección física del bloque */
} ext4_extent;

/**
 * @brief Nodo índice del árbol de extents (12 bytes).
 */
typedef struct {
    uint32_t ei_block;                /* Bloque lógico cubierto por este subárbol */
    uint32_t ei_leaf_lo;              /* Bloque físico donde reside el siguiente nivel */
    uint16_t ei_leaf_hi;
    uint16_t ei_unused;
} ext4_extent_idx;

/**
 * @brief Entrada de Directorio en ext4 (formato versión 2).
 */
typedef struct {
    uint32_t inode;                   /* Número de inodo apuntado */
    uint16_t rec_len;                 /* Longitud de esta entrada en bytes */
    uint8_t  name_len;                /* Longitud del nombre del archivo */
    uint8_t  file_type;               /* Tipo de archivo (1=reg, 2=dir, 7=symlink) */
    char     name[];                  /* Nombre del archivo (sin terminador null obligatorio) */
} ext4_dir_entry_2;

#pragma pack(pop)

#endif /* EXT4_STRUCTS_H */
