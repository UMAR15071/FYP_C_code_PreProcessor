#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct node {
	char* typedef_name;
	struct node* next;
} list_node;

list_node *typedef_list = NULL;

int is_typedef_name(char* id) {
	list_node* current = typedef_list;//instance of the struct define above. List_node is an alias to node.
	while (current != NULL) {
		if (strcmp(current->typedef_name, id) == 0) {
			return 1;
		}
		current = current->next; // "->" keyword is used when accessing a member in struct with its pointer.
	}
	return 0;
}