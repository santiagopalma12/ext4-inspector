# ==============================================================================
# Makefile - ext4_inspector (UNSA - Sistemas Operativos 2026)
# ==============================================================================

CC ?= gcc
CFLAGS ?= -Wall -Wextra -Werror -O2 -std=c11 -D_GNU_SOURCE
TARGET = ext4_inspector
SRC = ext4_inspector.c
HEADERS = ext4_structs.h

.PHONY: all clean help

all: $(TARGET)

$(TARGET): $(SRC) $(HEADERS)
	$(CC) $(CFLAGS) $(SRC) -o $(TARGET)
	@echo "[+] Compilación exitosa: ./$(TARGET)"

clean:
	rm -f $(TARGET) *.o *.img
	@echo "[+] Limpieza completada."

help:
	@echo "Uso del Makefile:"
	@echo "  make        - Compila el inspector binario de ext4"
	@echo "  make clean  - Elimina binarios y archivos temporales"
	@echo "  make help   - Muestra este menú de ayuda"
