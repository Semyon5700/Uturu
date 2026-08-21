#include <kernel.h>
#include <types.h>

void calculator_run(void) {
    char buf[32];
    int op1, op2;
    char op;
    printf("Uturu Calculator\nOperations: + - * / (q to quit)\n");
    while (1) {
        printf("Enter first number: ");
        read_line(buf, sizeof(buf));
        if (buf[0] == 'q' || buf[0] == 'Q') break;
        op1 = atoi(buf);

        printf("Enter operator: ");
        op = keyboard_getchar();
        terminal_putchar(op);
        terminal_putchar('\n');
        if (op == 'q' || op == 'Q') break;

        printf("Enter second number: ");
        read_line(buf, sizeof(buf));
        if (buf[0] == 'q' || buf[0] == 'Q') break;
        op2 = atoi(buf);

        int result;
        switch (op) {
            case '+': result = op1 + op2; break;
            case '-': result = op1 - op2; break;
            case '*': result = op1 * op2; break;
            case '/': 
                if (op2 == 0) { printf("Division by zero!\n"); continue; }
                result = op1 / op2; break;
            default:
                printf("Invalid operator.\n");
                continue;
        }
        printf("Result: %d\n", result);
    }
    printf("Calculator exited.\n");
}
