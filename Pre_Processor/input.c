#include <stdio.h>

int main() {
    // Integer hexadecimal numbers
    unsigned int hex_int1 = 0xA;       // Decimal 10
    unsigned int hex_int2 = 0xFF;      // Decimal 255
    unsigned int hex_int3 = 0x7F;      // Decimal 127
    int neg_hex_int = -0x8000;         // Negative decimal -32768 (16-bit min signed)

    // Floating-point hexadecimal numbers
    float hex_float1 = 0x1.8p2;        // 1.5 × 2^2 = 6.0
    float hex_float2 = 0x0.5p-1;       // 0.5 × 2^-1 = 0.25
    float hex_float3 = -0x1.0p-2;      // Negative 1.0 × 2^-2 = -0.25
    float hex_float4 = 0x1.Cp4;        // 1.75 × 2^4 = 28.0

    // Large integer values
    unsigned int max_32bit = 0xFFFFFFFF; // Maximum unsigned 32-bit value
    int neg_max_32bit = 0x80000000;      // Minimum signed 32-bit value (-2^31)

    // Display results
    printf("Hexadecimal Integers:\n");
    printf("hex_int1 = 0x%X (Decimal: %u)\n", hex_int1, hex_int1);
    printf("hex_int2 = 0x%X (Decimal: %u)\n", hex_int2, hex_int2);
    printf("hex_int3 = 0x%X (Decimal: %u)\n", hex_int3, hex_int3);
    printf("neg_hex_int = -0x%X (Decimal: %d)\n", -neg_hex_int, neg_hex_int);

    printf("\nHexadecimal Floating-Point Numbers:\n");
    printf("hex_float1 = %f\n", hex_float1);
    printf("hex_float2 = %f\n", hex_float2);
    printf("hex_float3 = %f\n", hex_float3);
    printf("hex_float4 = %f\n", hex_float4);

    printf("\nLarge Integer Hex Values:\n");
    printf("max_32bit = 0x%X (Decimal: %u)\n", max_32bit, max_32bit);
    printf("neg_max_32bit = 0x%X (Decimal: %d)\n", neg_max_32bit, neg_max_32bit);

    return 0;
}
