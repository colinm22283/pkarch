#include <stdio.h>
#include <video.h>

int main() {
    for (int i = 0; i < VWIDTH; i++) {
        printf("%d\n", i);

        for (int j = 0; j < VHEIGHT; j++) {
            VRAM[i + j * VWIDTH] = 10;
        }
    }

    return 0;
}

