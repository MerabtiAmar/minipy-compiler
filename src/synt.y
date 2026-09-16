%{
	#include <stdio.h>
	#include <string.h>

	/* Prototypes : le lexer et les tables sont compilés dans lex.yy.c */
	int yylex(void);
	int yyerror(char *msg);
	void initialisation(void);
	void afficher(void);
	void afficher_qdr(void);
	void quadr(char opr[], char op1[], char op2[], char res[]);
	void ajour_quad(int num_quad, int colon_quad, char val[]);

    int ligne=1, colonne=1,niv=0;
	
	int Fin_if=0,deb_else=0;
	int qc=0;
	char tmp [20]; 
	int fin_while = 0,sauv_deb = 0,sauv_bz = 0;
%}

%union {
         int     entier;
         char*   str;
         float reel;
}
%token mc_int mc_float mc_char mc_bool mc_if mc_else mc_in mc_in_range mc_while mc_for tableau op_log_bin op_log_uni op_comp <entier>constante
		<str>idf <reel>val_reel <str>val_char <str>val_bool affect indent po pf vg pts saut plus minus divv mul

%left plus minus
%left mul divv
%left op_comp

%start CODE
%%
CODE : DEC CODE 
     | INST CODE
	 |
;
DEC  : DEC_VAR
     | DEC_TAB
;
DEC_VAR : TYPE  LISTE_IDF saut
        | idf affect Val saut 
		// { 
	// if(doubleDeclaration($1)==0) insererTYPE($1,sauvType);
	// else
	// printf("err semantique: double declaration de %s a la ligne %d\n",$1,ligne);
// }
;
LISTE_IDF : IDF vg LISTE_IDF
          | IDF
;
IDF: idf 
// { 
	// if(doubleDeclaration($1)==0) insererTYPE($1,sauvType);
	// else
	// printf("err semantique: double declaration de %s a la ligne %d\n",$1,ligne);
// }
| idf affect Val
// { 
	// if(doubleDeclaration($1)==0) insererTYPE($1,sauvType);
	// else
	// printf("err semantique: double declaration de %s a la ligne %d\n",$1,ligne);
// }
;
DEC_TAB : TYPE idf tableau saut
// { 
	// if(doubleDeclaration($2)==0) insererTYPE($2,sauvType);
	// else
	// printf("err semantique: double declaration de %s a la ligne %d\n",$2,ligne);
// }
;
TYPE : mc_int	//{strcpy(sauvType,"int");}
     | mc_bool  //{strcpy(sauvType,"bool");}
     | mc_char  //{strcpy(sauvType,"char");}
     | mc_float //{strcpy(sauvType,"float");}
;
Val : constante
    | val_bool
    | val_char
    | val_reel
;
INST : INST_AFF  {printf("\n AFF RECONNUE \n ");}
     | IFCOND    {printf("\n CONDITION RECONNUE \n ");}
	 | While     {printf("\n BOUCLE WHILE RECONNUE \n ");}
	 | For
	 | saut 
;
INST_AFF : idf affect EXPRESSION saut 
// { 
	// if(doubleDeclaration($1)==0) insererTYPE($1,sauvType);
	// else
	// printf("err semantique: double declaration de %s a la ligne %d\n",$1,ligne);
// }
| po INST_AFF pf
;
EXPRESSION : CONDITION 
		   | EXPArith
;
EXPLog: Bool op_log_bin EXPLog 
      | Bool
	  | po EXPLog pf
;
Bool: val_bool 
    | idf
	// { 
	// if(doubleDeclaration($1)==0) printf("err semantique: non declaration de %s a la ligne %d\n",$1,ligne);
// }
	| op_log_uni Bool
;
CONDITION : EXPLog 
          | EXPLog op_log_bin COMP
		  | COMP op_log_bin EXPLog
		  | COMP
		  | op_log_uni COMP
		  | po CONDITION pf
;
COMP: EXPArith op_comp EXPArith
     | po COMP pf
;
Op_arith: plus | minus | divv | mul
;
EXPArith:idf Op_arith EXPArith
        | idf 
		// { 
	// if(doubleDeclaration($1)==0) printf("err semantique: non declaration de %s a la ligne %d\n",$1,ligne);
// }
		| constante Op_arith EXPArith 
		| val_reel Op_arith EXPArith 
		| val_reel 
		| constante
		| po EXPArith pf
;
					 
IFCOND: B Else{  
					sprintf(tmp,"%d",qc);  
                    ajour_quad(Fin_if,1,tmp);
					printf("pgm juste");
}
;
B: A saut indent INST BLOCKS{  
					Fin_if=qc;
					quadr("BR", "","vide", "vide"); 
					sprintf(tmp,"%d",qc); 
					ajour_quad(deb_else,1,tmp);
}
;
A: mc_if po CONDITION pf pts {
					deb_else=qc;
					quadr("BZ", "","temp_cond", "vide"); 	
}
;

BLOCKS : indent INST BLOCKS
	   | 
;
Else: mc_else pts saut indent INST BLOCKS
    |
;
While: mc_while po CONDITION pf pts saut indent INST BLOCKS
;
// C: D pf pts saut indent INST 
// {
	// quadr("BR",sauv_deb,"vide","vide");
	// qc++;
	// sprintf(tmp,"%d",qc); 
	// ajour_quad(sauv_bz,2,tmp);
// }
//;
//D: E po CONDITION 
// {
	// quadr("BZ","","temp_cond","vide");
	// sauv_bz = qc;
	// qc++;
// }
//;
//E: mc_while
// {
	// sauv_deb = qc;
// }
//;
For: For1 {printf("\n BOUCLE FOR 1 RECONNUE \n ");}
   | For2 {printf("\n BOUCLE FOR 2 RECONNUE \n ");}
;
For1: mc_for idf mc_in_range po constante vg constante pf pts saut indent INST BLOCKS
;
For2: mc_for idf mc_in idf pts saut indent INST BLOCKS
;
%%
int main(void)
{
   initialisation();
   yyparse();
   afficher();
   afficher_qdr();
   return 0;
}
int yywrap(void)
{
   return 1;
}
int yyerror(char *msg)
{
    (void)msg;
    printf ("Erreur Syntaxique a ligne %d a colonne %d \n", ligne,colonne);
    return 0;
}
