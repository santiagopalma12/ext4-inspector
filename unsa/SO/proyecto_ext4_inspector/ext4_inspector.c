/**
 * @file ext4_inspector.c
 * @brief Herramienta forense y de inspección de bajo nivel para particiones e imágenes ext4.
 *
 * Curso: Sistemas Operativos - UNSA
 * Proyecto: Implementación y Análisis Físico de Sistemas de Archivos
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "ext4_structs.h"

static int g_fd = -1;
static ext4_super_block g_sb;
static uint32_t g_block_size = 0;
static uint32_t g_num_groups = 0;
static ext4_group_desc *g_gdt = NULL;

static void print_banner(void) {
    printf("======================================================================\n");
    printf("  EXT4 LOW-LEVEL INSPECTOR & FORENSICS TOOL - UNSA EPIS (SO 2026)     \n");
    printf("======================================================================\n");
}

static bool read_superblock(void) {
    if (lseek(g_fd, EXT4_SUPERBLOCK_OFFSET, SEEK_SET) == (off_t)-1) {
        perror("[-] Error en lseek hacia el Superbloque");
        return false;
    }

    ssize_t bytes_read = read(g_fd, &g_sb, sizeof(g_sb));
    if (bytes_read < (ssize_t)sizeof(g_sb)) {
        perror("[-] Error leyendo Superbloque");
        return false;
    }

    if (g_sb.s_magic != EXT4_SUPERBLOCK_MAGIC) {
        fprintf(stderr, "[-] Firma no válida: 0x%04X (esperado: 0x%04X - ext4)\n",
                g_sb.s_magic, EXT4_SUPERBLOCK_MAGIC);
        return false;
    }

    g_block_size = 1024 << g_sb.s_log_block_size;
    g_num_groups = (g_sb.s_blocks_count_lo + g_sb.s_blocks_per_group - 1) / g_sb.s_blocks_per_group;

    return true;
}

static bool read_gdt(void) {
    uint32_t gdt_block = (g_sb.s_first_data_block + 1);
    off_t gdt_offset = (off_t)gdt_block * g_block_size;

    g_gdt = (ext4_group_desc *)malloc(g_num_groups * sizeof(ext4_group_desc));
    if (!g_gdt) {
        perror("[-] Error asignando memoria para GDT");
        return false;
    }

    if (lseek(g_fd, gdt_offset, SEEK_SET) == (off_t)-1) {
        perror("[-] Error en lseek hacia GDT");
        return false;
    }

    uint16_t desc_size = g_sb.s_desc_size > 0 ? g_sb.s_desc_size : 32;

    for (uint32_t i = 0; i < g_num_groups; i++) {
        off_t entry_offset = gdt_offset + (off_t)i * desc_size;
        lseek(g_fd, entry_offset, SEEK_SET);
        if (read(g_fd, &g_gdt[i], sizeof(ext4_group_desc)) < 32) {
            perror("[-] Error leyendo descriptor de grupo");
            return false;
        }
    }

    return true;
}

static bool read_inode(uint32_t inode_num, ext4_inode *out_inode, off_t *out_physical_offset) {
    if (inode_num == 0 || inode_num > g_sb.s_inodes_count) {
        fprintf(stderr, "[-] Número de inodo %u fuera de rango (1 - %u)\n",
                inode_num, g_sb.s_inodes_count);
        return false;
    }

    uint32_t group = (inode_num - 1) / g_sb.s_inodes_per_group;
    uint32_t index = (inode_num - 1) % g_sb.s_inodes_per_group;

    uint64_t itable_block = g_gdt[group].bg_inode_table_lo;
    if (g_sb.s_desc_size >= 64) {
        itable_block |= ((uint64_t)g_gdt[group].bg_inode_table_hi << 32);
    }

    off_t inode_offset = (off_t)itable_block * g_block_size + (off_t)index * g_sb.s_inode_size;

    if (out_physical_offset) {
        *out_physical_offset = inode_offset;
    }

    if (lseek(g_fd, inode_offset, SEEK_SET) == (off_t)-1) {
        perror("[-] Error buscando inodo en disco");
        return false;
    }

    if (read(g_fd, out_inode, sizeof(ext4_inode)) < (ssize_t)sizeof(ext4_inode)) {
        perror("[-] Error leyendo estructura del inodo");
        return false;
    }

    return true;
}

static void cmd_info(void) {
    print_banner();
    printf("[+] SUPERBLOQUE (Offset físico: %d bytes):\n", EXT4_SUPERBLOCK_OFFSET);
    printf("    * Número Mágico           : 0x%04X (Integridad: %s)\n",
           g_sb.s_magic, (g_sb.s_magic == EXT4_SUPERBLOCK_MAGIC ? "VÁLIDO" : "CORRUPTO"));
    printf("    * Estado del Sistema       : %s\n",
           (g_sb.s_state == 1 ? "CLEAN (Limpio)" : "ERROR / DIRTY"));
    printf("    * Tamaño de Bloque Lógico  : %u bytes (%u KB)\n",
           g_block_size, g_block_size / 1024);
    printf("    * Conteo Total de Bloques  : %u\n", g_sb.s_blocks_count_lo);
    printf("    * Bloques Libres           : %u (%.2f%% libre)\n",
           g_sb.s_free_blocks_count_lo,
           (float)g_sb.s_free_blocks_count_lo * 100.0f / g_sb.s_blocks_count_lo);
    printf("    * Conteo Total de Inodos   : %u\n", g_sb.s_inodes_count);
    printf("    * Inodos Libres            : %u (%.2f%% libre)\n",
           g_sb.s_free_inodes_count,
           (float)g_sb.s_free_inodes_count * 100.0f / g_sb.s_inodes_count);
    printf("    * Tamaño de Inodo (FCB)    : %u bytes\n", g_sb.s_inode_size);
    printf("    * Bloques por Grupo        : %u\n", g_sb.s_blocks_per_group);
    printf("    * Inodos por Grupo         : %u\n", g_sb.s_inodes_per_group);
    printf("    * Total de Block Groups    : %u\n", g_num_groups);

    printf("\n[+] TABLA DE DESCRIPTORES DE GRUPO (GDT - Localidad de Metadatos):\n");
    printf("    ---------------------------------------------------------------------------------\n");
    printf("    Grupo | B-Bitmap Blk | I-Bitmap Blk | Inode Table Blk | Blks Libres | Inodes Libres \n");
    printf("    ---------------------------------------------------------------------------------\n");
    for (uint32_t i = 0; i < g_num_groups; i++) {
        printf("    %5u | %12u | %12u | %15u | %11u | %12u\n",
               i,
               g_gdt[i].bg_block_bitmap_lo,
               g_gdt[i].bg_inode_bitmap_lo,
               g_gdt[i].bg_inode_table_lo,
               g_gdt[i].bg_free_blocks_count_lo,
               g_gdt[i].bg_free_inodes_count_lo);
    }
    printf("    ---------------------------------------------------------------------------------\n");
}

static void decode_mode(uint16_t mode, char *out_str) {
    if (S_ISDIR(mode))  out_str[0] = 'd';
    else if (S_ISLNK(mode)) out_str[0] = 'l';
    else if (S_ISCHR(mode)) out_str[0] = 'c';
    else if (S_ISBLK(mode)) out_str[0] = 'b';
    else if (S_ISFIFO(mode)) out_str[0] = 'p';
    else if (S_ISSOCK(mode)) out_str[0] = 's';
    else out_str[0] = '-';

    out_str[1] = (mode & S_IRUSR) ? 'r' : '-';
    out_str[2] = (mode & S_IWUSR) ? 'w' : '-';
    out_str[3] = (mode & S_IXUSR) ? 'x' : '-';
    out_str[4] = (mode & S_IRGRP) ? 'r' : '-';
    out_str[5] = (mode & S_IWGRP) ? 'w' : '-';
    out_str[6] = (mode & S_IXGRP) ? 'x' : '-';
    out_str[7] = (mode & S_IROTH) ? 'r' : '-';
    out_str[8] = (mode & S_IWOTH) ? 'w' : '-';
    out_str[9] = (mode & S_IXOTH) ? 'x' : '-';
    out_str[10] = '\0';
}

static void cmd_inode(uint32_t inode_num) {
    ext4_inode in;
    off_t phys_offset = 0;

    if (!read_inode(inode_num, &in, &phys_offset)) return;

    print_banner();
    printf("[+] ANATOMÍA DEL INODO %u (Offset físico LBA: 0x%lX [%ld bytes]):\n",
           inode_num, (unsigned long)phys_offset, (long)phys_offset);

    char mode_str[11];
    decode_mode(in.i_mode, mode_str);

    printf("    * Modo / Permisos POSIX    : %s (Octal: 0%o)\n", mode_str, in.i_mode & 07777);
    printf("    * Dueño (UID:GID)          : %u : %u\n", in.i_uid, in.i_gid);
    printf("    * Tamaño Lógico del Archivo: %u bytes\n", in.i_size_lo);
    printf("    * Contador de Hard Links   : %u (i_links_count)\n", in.i_links_count);
    printf("    * Sectores Asignados (512B): %u (Bloques SO: %u)\n",
           in.i_blocks_lo, in.i_blocks_lo / (g_block_size / 512));
    printf("    * Flags Hexadecimal        : 0x%08X\n", in.i_flags);

    bool has_extents = (in.i_flags & EXT4_EXTENTS_FL) != 0;
    printf("    * Estructura de Asignación : %s\n",
           has_extents ? "EXTENTS (Árbol B+ moderno - ext4)" : "PUNTEROS INDEXADOS CLÁSICOS (ext2/ext3)");

    if (has_extents) {
        ext4_extent_header *eh = (ext4_extent_header *)in.i_block;
        printf("\n    [+] Árbol de Extents (Header en i_block[60]):\n");
        printf("        - Magic Number         : 0x%04X (%s)\n",
               eh->eh_magic, (eh->eh_magic == EXT4_EXTENTS_MAGIC ? "VÁLIDO 0xF30A" : "INVÁLIDO"));
        printf("        - Entradas Activas     : %u / Capacidad: %u\n", eh->eh_entries, eh->eh_max);
        printf("        - Profundidad (Depth)  : %u (%s)\n",
               eh->eh_depth, (eh->eh_depth == 0 ? "Nivel Hoja -> Punteros Directos a Datos" : "Nivel Índice"));

        if (eh->eh_depth == 0) {
            ext4_extent *exts = (ext4_extent *)(in.i_block + sizeof(ext4_extent_header));
            printf("        - Descriptores de Extent:\n");
            printf("          -----------------------------------------------------------------\n");
            printf("          # | Bloque Lógico | Cantidad Bloques | Bloque Físico | Offset Físico Disco \n");
            printf("          -----------------------------------------------------------------\n");
            for (uint16_t i = 0; i < eh->eh_entries; i++) {
                uint64_t phys_block = ((uint64_t)exts[i].ee_start_hi << 32) | exts[i].ee_start_lo;
                off_t block_byte_offset = (off_t)phys_block * g_block_size;
                printf("          %u | %13u | %16u | %13lu | 0x%lX (%ld B)\n",
                       i + 1,
                       exts[i].ee_block,
                       exts[i].ee_len,
                       (unsigned long)phys_block,
                       (unsigned long)block_byte_offset,
                       (long)block_byte_offset);
            }
            printf("          -----------------------------------------------------------------\n");
        }
    } else {
        printf("\n    [+] Lista de Punteros Directos (i_block[0..11]):\n");
        uint32_t *ptrs = (uint32_t *)in.i_block;
        for (int i = 0; i < 12; i++) {
            if (ptrs[i] != 0) {
                printf("        Directo [%2d] -> Bloque Físico: %u\n", i, ptrs[i]);
            }
        }
    }
}

static void cmd_cat(uint32_t inode_num) {
    ext4_inode in;
    if (!read_inode(inode_num, &in, NULL)) return;

    if (S_ISDIR(in.i_mode)) {
        fprintf(stderr, "[-] El inodo %u es un directorio. Use 'ls' para explorarlo.\n", inode_num);
        return;
    }

    uint32_t remaining_bytes = in.i_size_lo;
    uint8_t *buffer = (uint8_t *)malloc(g_block_size);
    if (!buffer) {
        perror("[-] Error asignando buffer de lectura");
        return;
    }

    if (in.i_flags & EXT4_EXTENTS_FL) {
        ext4_extent_header *eh = (ext4_extent_header *)in.i_block;
        if (eh->eh_depth == 0) {
            ext4_extent *exts = (ext4_extent *)(in.i_block + sizeof(ext4_extent_header));
            for (uint16_t i = 0; i < eh->eh_entries && remaining_bytes > 0; i++) {
                uint64_t phys_start = ((uint64_t)exts[i].ee_start_hi << 32) | exts[i].ee_start_lo;
                uint16_t len = exts[i].ee_len;

                for (uint16_t b = 0; b < len && remaining_bytes > 0; b++) {
                    off_t offset = (off_t)(phys_start + b) * g_block_size;
                    lseek(g_fd, offset, SEEK_SET);
                    uint32_t to_read = remaining_bytes > g_block_size ? g_block_size : remaining_bytes;
                    ssize_t r = read(g_fd, buffer, to_read);
                    if (r > 0) fwrite(buffer, 1, r, stdout);
                    remaining_bytes -= (r > 0) ? r : remaining_bytes;
                }
            }
        }
    } else {
        uint32_t *ptrs = (uint32_t *)in.i_block;
        for (int i = 0; i < 12 && remaining_bytes > 0; i++) {
            if (ptrs[i] == 0) break;
            off_t offset = (off_t)ptrs[i] * g_block_size;
            lseek(g_fd, offset, SEEK_SET);
            uint32_t to_read = remaining_bytes > g_block_size ? g_block_size : remaining_bytes;
            ssize_t r = read(g_fd, buffer, to_read);
            if (r > 0) fwrite(buffer, 1, r, stdout);
            remaining_bytes -= (r > 0) ? r : remaining_bytes;
        }
    }

    free(buffer);
}

static void cmd_ls(uint32_t dir_inode_num) {
    ext4_inode in;
    if (!read_inode(dir_inode_num, &in, NULL)) return;

    if (!S_ISDIR(in.i_mode)) {
        fprintf(stderr, "[-] El inodo %u no es un directorio (tipo: 0%o)\n", dir_inode_num, in.i_mode);
        return;
    }

    print_banner();
    printf("[+] CONTENIDO DEL DIRECTORIO (Inodo %u - Mapeo Nombre -> Inodo):\n", dir_inode_num);
    printf("    -------------------------------------------------------------------------\n");
    printf("    Inodo Destino | Tipo           | Long. Registro | Nombre de Archivo\n");
    printf("    -------------------------------------------------------------------------\n");

    uint8_t *buffer = (uint8_t *)malloc(g_block_size);
    if (!buffer) return;

    ext4_extent_header *eh = (ext4_extent_header *)in.i_block;
    if ((in.i_flags & EXT4_EXTENTS_FL) && eh->eh_depth == 0) {
        ext4_extent *exts = (ext4_extent *)(in.i_block + sizeof(ext4_extent_header));

        for (uint16_t e = 0; e < eh->eh_entries; e++) {
            uint64_t phys_block = ((uint64_t)exts[e].ee_start_hi << 32) | exts[e].ee_start_lo;

            for (uint16_t b = 0; b < exts[e].ee_len; b++) {
                off_t block_offset = (off_t)(phys_block + b) * g_block_size;
                lseek(g_fd, block_offset, SEEK_SET);
                if (read(g_fd, buffer, g_block_size) <= 0) break;

                uint32_t curr_offset = 0;
                while (curr_offset < g_block_size) {
                    ext4_dir_entry_2 *entry = (ext4_dir_entry_2 *)(buffer + curr_offset);
                    if (entry->rec_len == 0) break;

                    if (entry->inode != 0) {
                        char name[256];
                        memcpy(name, entry->name, entry->name_len);
                        name[entry->name_len] = '\0';

                        const char *type_name = "DESCONOCIDO";
                        switch (entry->file_type) {
                            case EXT4_FT_REG_FILE: type_name = "Regular File"; break;
                            case EXT4_FT_DIR:      type_name = "Directorio";   break;
                            case EXT4_FT_SYMLINK:  type_name = "Symbolic Link";break;
                            case EXT4_FT_BLKDEV:   type_name = "Block Device"; break;
                            case EXT4_FT_CHRDEV:   type_name = "Char Device";  break;
                            case EXT4_FT_FIFO:     type_name = "FIFO/Pipe";    break;
                            case EXT4_FT_SOCK:     type_name = "Socket";       break;
                        }

                        printf("    %13u | %-14s | %14u | %s\n",
                               entry->inode, type_name, entry->rec_len, name);
                    }
                    curr_offset += entry->rec_len;
                }
            }
        }
    }
    printf("    -------------------------------------------------------------------------\n");
    free(buffer);
}

static void cmd_diagnose_space(void) {
    print_banner();
    printf("[+] DIAGNÓSTICO PREVENTIVO DE ESPACIO Y CAPACIDAD DE METADATOS:\n\n");

    uint32_t used_blocks = g_sb.s_blocks_count_lo - g_sb.s_free_blocks_count_lo;
    float block_pct = (float)used_blocks * 100.0f / g_sb.s_blocks_count_lo;

    uint32_t used_inodes = g_sb.s_inodes_count - g_sb.s_free_inodes_count;
    float inode_pct = (float)used_inodes * 100.0f / g_sb.s_inodes_count;

    printf("    * Bloques de Datos: %u / %u usados (%.2f%% en uso)\n",
           used_blocks, g_sb.s_blocks_count_lo, block_pct);
    printf("    * Tabla de Inodos : %u / %u usados (%.2f%% en uso)\n\n",
           used_inodes, g_sb.s_inodes_count, inode_pct);

    if (inode_pct >= 95.0f && block_pct < 50.0f) {
        printf("    [!] ALERTA CRÍTICA: RIESGO DE AGOTAMIENTO DE INODOS (ENOSPC Anómalo)\n");
        printf("        El disco presenta gran cantidad de espacio libre en bloques (%.2f%%),\n", 100.0f - block_pct);
        printf("        pero la tabla de inodos está cerca de la saturación (%.2f%%).\n", inode_pct);
        printf("        Causa: Generación desmedida de archivos pequeños/vacíos.\n");
        printf("        Solución: Reformatar con mayor ratio de bytes-por-inodo (-i) o purgar archivos.\n");
    } else {
        printf("    [OK] Relación de consumo equilibrada entre datos y descriptores de metadatos.\n");
    }
}

static void print_usage(const char *prog) {
    print_banner();
    printf("Uso: %s <imagen_o_dispositivo> <comando> [argumentos]\n\n", prog);
    printf("Comandos disponibles:\n");
    printf("  info                 Muestra metadatos del Superbloque y distribución de GDT.\n");
    printf("  inode <nro_inodo>    Inspecciona a nivel binario un inodo y su árbol de Extents.\n");
    printf("  cat   <nro_inodo>    Extrae los bytes crudos del archivo siguiendo sus extents.\n");
    printf("  ls    <nro_inodo>    Lista las entradas de directorio mapeadas por un inodo.\n");
    printf("  diagnose-space       Analiza riesgos de agotamiento de inodos (ENOSPC).\n\n");
    printf("Ejemplo:\n");
    printf("  %s disco.img info\n", prog);
    printf("  %s disco.img inode 2\n", prog);
    printf("  %s disco.img ls 2\n", prog);
}

int main(int argc, char *argv[]) {
    if (argc < 3) {
        print_usage(argv[0]);
        return EXIT_FAILURE;
    }

    const char *img_path = argv[1];
    const char *cmd = argv[2];

    g_fd = open(img_path, O_RDONLY);
    if (g_fd < 0) {
        fprintf(stderr, "[-] No se pudo abrir la imagen '%s': %s\n", img_path, strerror(errno));
        return EXIT_FAILURE;
    }

    if (!read_superblock()) {
        close(g_fd);
        return EXIT_FAILURE;
    }

    if (!read_gdt()) {
        close(g_fd);
        return EXIT_FAILURE;
    }

    if (strcmp(cmd, "info") == 0) {
        cmd_info();
    } else if (strcmp(cmd, "inode") == 0) {
        if (argc < 4) {
            fprintf(stderr, "[-] Debe especificar el número de inodo. Ej: %s %s inode 2\n", argv[0], img_path);
            close(g_fd);
            return EXIT_FAILURE;
        }
        uint32_t in_num = (uint32_t)atoi(argv[3]);
        cmd_inode(in_num);
    } else if (strcmp(cmd, "cat") == 0) {
        if (argc < 4) {
            fprintf(stderr, "[-] Debe especificar el número de inodo. Ej: %s %s cat 12\n", argv[0], img_path);
            close(g_fd);
            return EXIT_FAILURE;
        }
        uint32_t in_num = (uint32_t)atoi(argv[3]);
        cmd_cat(in_num);
    } else if (strcmp(cmd, "ls") == 0) {
        uint32_t in_num = (argc >= 4) ? (uint32_t)atoi(argv[3]) : EXT4_ROOT_INO;
        cmd_ls(in_num);
    } else if (strcmp(cmd, "diagnose-space") == 0) {
        cmd_diagnose_space();
    } else {
        fprintf(stderr, "[-] Comando desconocido '%s'\n", cmd);
        print_usage(argv[0]);
        close(g_fd);
        return EXIT_FAILURE;
    }

    if (g_gdt) free(g_gdt);
    close(g_fd);
    return EXIT_SUCCESS;
}
