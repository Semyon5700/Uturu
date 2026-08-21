#include <types.h>

size_t strlen(const char* s) {
    size_t len = 0;
    while (s[len]) len++;
    return len;
}

int strcmp(const char* s1, const char* s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(unsigned char*)s1 - *(unsigned char*)s2;
}

char* strcpy(char* dest, const char* src) {
    char* d = dest;
    while ((*d++ = *src++));
    return dest;
}

char* strncpy(char* dest, const char* src, size_t n) {
    size_t i;
    for (i = 0; i < n && src[i]; i++)
        dest[i] = src[i];
    for (; i < n; i++)
        dest[i] = '\0';
    return dest;
}

void* memset(void* s, int c, size_t n) {
    unsigned char* p = s;
    while (n--) *p++ = (unsigned char)c;
    return s;
}

void* memcpy(void* dest, const void* src, size_t n) {
    unsigned char* d = dest;
    const unsigned char* s = src;
    while (n--) *d++ = *s++;
    return dest;
}

int atoi(const char* s) {
    int result = 0;
    int sign = 1;
    while (*s == ' ') s++;
    if (*s == '-') { sign = -1; s++; }
    while (*s >= '0' && *s <= '9') {
        result = result * 10 + (*s - '0');
        s++;
    }
    return sign * result;
}

void itoa(int value, char* str, int base) {
    char* p = str;
    char* p1 = str;
    int tmp;
    if (base < 2 || base > 36) { *str = '\0'; return; }
    if (value < 0 && base == 10) {
        *p++ = '-';
        value = -value;
    }
    do {
        tmp = value % base;
        *p++ = (tmp < 10) ? '0' + tmp : 'a' + tmp - 10;
        value /= base;
    } while (value);
    *p-- = '\0';
    while (p1 < p) {
        char c = *p1;
        *p1 = *p;
        *p = c;
        p1++;
        p--;
    }
}
