// Adapted from https://github.com/sifive/benchmark-dhrystone/tree/master

#define structassign(d, s)      memcpy(&(d), &(s), sizeof(d))

typedef enum {Ident_1, Ident_2, Ident_3, Ident_4, Ident_5} Enumeration;

typedef struct record {
    struct record *Ptr_Comp;

    Enumeration    Discr;

    union {
        struct {
            Enumeration Enum_Comp;
            int         Int_Comp;
            char        Str_Comp [31];
        } var_1;
        struct {
            Enumeration E_Comp_2;
            char        Str_2_Comp [31];
        } var_2;
        struct {
            char        Ch_1_Comp;
            char        Ch_2_Comp;
        } var_3;
    } variant;
} Rec_Type, *Rec_Pointer;

Rec_Pointer     Ptr_Glob, Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
char            Ch_1_Glob, Ch_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];


