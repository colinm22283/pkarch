#include <print.h>

#define N (5)
#define M (5)

int mat1[N][M];
int mat2[M][N];
int mat3[M][N];

int main() {
    for (int j = 0; j < N; j++) {
        for (int i = 0; i < M; i++) {
            mat1[j][i] = (i + j) % 63;
            mat2[i][j] = (i + j) % 47;
        }
    }

    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            int total = 0;

            for (int k = 0; k < M; k++) {
                total += mat1[i][k] * mat1[k][j];
            }

            mat3[j][i] = total;
        }
    }

    for (int j = 0; j < N; j++) {
        for (int i = 0; i < M; i++) {
            print_dec(mat3[i][j]);
            print_str(" ");
        }
        print_str("\n");
    }
}

