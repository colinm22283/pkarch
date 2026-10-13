#include <stdio.h>
#include <video.h>

int main() {
    for (int iter = 0; iter < 10; iter++) {
        for (int i = 0; i < VWIDTH; i++) {
            for (int j = 0; j < VHEIGHT; j++) {
                VRAM[i + j * VWIDTH] = i * j * iter;
            }
        }

        video_present();
    }

    return 0;
}

