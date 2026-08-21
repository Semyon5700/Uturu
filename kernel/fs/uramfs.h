#ifndef URAMFS_H
#define URAMFS_H

#include <types.h>

#define MAX_FILES 16
#define MAX_FILESIZE 1024
#define MAX_FILENAME 13

typedef struct {
    char name[MAX_FILENAME];
    uint32_t size;
    uint8_t used;
    uint8_t data[MAX_FILESIZE];
} file_entry_t;

void fs_init(void);
int fs_create(const char* name);
int fs_remove(const char* name);
int fs_file_exists(const char* name);
int fs_file_size(const char* name);
int fs_read(const char* name, char* buffer, int max_size);
int fs_write(const char* name, const char* data, int size);
int fs_count_used(void);
int fs_list_to_buffer(char* buffer, int max_size);

#endif