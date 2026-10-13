#pragma once

#define VWIDTH  (32)
#define VHEIGHT (32)
#define VRAM    ((volatile char *) 0x2000000)

static inline void video_present(void) {
    VRAM[VWIDTH * VHEIGHT]++;
}

