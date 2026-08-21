#include <kernel.h>
#include <fs/uramfs.h>
#include <types.h>

static file_entry_t fs_table[MAX_FILES];

void fs_init(void) {
    memset(fs_table, 0, sizeof(fs_table));
}

int fs_create(const char* name) {
    if (name[0] == '\0') return -1;
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs_table[i].used && strcmp(fs_table[i].name, name) == 0)
            return -1;
    }
    for (int i = 0; i < MAX_FILES; i++) {
        if (!fs_table[i].used) {
            strncpy(fs_table[i].name, name, MAX_FILENAME-1);
            fs_table[i].name[MAX_FILENAME-1] = '\0';
            fs_table[i].size = 0;
            fs_table[i].used = 1;
            memset(fs_table[i].data, 0, MAX_FILESIZE);
            return 0;
        }
    }
    return -1;
}

int fs_remove(const char* name) {
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs_table[i].used && strcmp(fs_table[i].name, name) == 0) {
            fs_table[i].used = 0;
            fs_table[i].size = 0;
            return 0;
        }
    }
    return -1;
}

int fs_file_exists(const char* name) {
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs_table[i].used && strcmp(fs_table[i].name, name) == 0)
            return 1;
    }
    return 0;
}

int fs_file_size(const char* name) {
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs_table[i].used && strcmp(fs_table[i].name, name) == 0)
            return fs_table[i].size;
    }
    return -1;
}

int fs_read(const char* name, char* buffer, int max_size) {
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs_table[i].used && strcmp(fs_table[i].name, name) == 0) {
            int len = fs_table[i].size;
            if (len > max_size-1) len = max_size-1;
            memcpy(buffer, fs_table[i].data, len);
            buffer[len] = '\0';
            return len;
        }
    }
    return -1;
}

int fs_write(const char* name, const char* data, int size) {
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs_table[i].used && strcmp(fs_table[i].name, name) == 0) {
            if (size > MAX_FILESIZE) size = MAX_FILESIZE;
            memcpy(fs_table[i].data, data, size);
            fs_table[i].size = size;
            return 0;
        }
    }
    if (fs_create(name) == 0) {
        return fs_write(name, data, size);
    }
    return -1;
}

int fs_count_used(void) {
    int count = 0;
    for (int i = 0; i < MAX_FILES; i++)
        if (fs_table[i].used) count++;
    return count;
}

int fs_list_to_buffer(char* buffer, int max_size) {
    int pos = 0;
    for (int i = 0; i < MAX_FILES; i++) {
        if (fs_table[i].used) {
            int len = strlen(fs_table[i].name);
            if (pos + len + 3 >= max_size) break;
            memcpy(buffer+pos, fs_table[i].name, len);
            pos += len;
            buffer[pos++] = ' ';
            buffer[pos++] = '(';
            char sizebuf[10];
            itoa(fs_table[i].size, sizebuf, 10);
            int slen = strlen(sizebuf);
            memcpy(buffer+pos, sizebuf, slen);
            pos += slen;
            buffer[pos++] = ')';
            buffer[pos++] = '\n';
        }
    }
    buffer[pos] = '\0';
    return pos;
}