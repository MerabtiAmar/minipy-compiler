%{
#include "synt.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "ts.h" 
#include "quad.h"
extern YYSTYPE yylval;
extern int ligne;
extern int colonne;
extern int niv;
int inst = 0;
int satr = 0; 
%}
lettreMaj [A-Z]
lettre [a-zA-Z] 
chiffre [0-9]
idf {lettreMaj}({lettre}|{chiffre})*
cst ({chiffre}+)|("(-"{chiffre}+")")
taille_tab {chiffre}+
reel ({chiffre}+"."{chiffre}+)|("(-"{chiffre}+"."{chiffre}+")")
valchar \'.\'
valbool "true"|"false"
tab "["{taille_tab}"]"
cmntr #.*
aff "="
PLUS "+"
MINUS "-"
MUL "*"
DIV "/"
oplog_bin "and"|"or"
oplog_uni "not"
opcomp ">"|">="|"=="|"!="|"<="|"<"
bloc "    "*
%option noyywrap
%%
"int" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;return mc_int;} 
"float" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;return mc_float;} 
"char" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;return mc_char;}
"bool" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;return mc_bool;}
"if" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);
	if (satr == 1) niv = 0;
	colonne=colonne+yyleng;
	niv++;
	inst = 2;
	return mc_if;
}
"else" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;
    if (satr == 1) niv = 0;
	niv++;
	inst = 2;
    return mc_else;
}
"in" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng; return mc_in;}
"in range" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;return mc_in_range; }
"while" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;
	if (satr == 1) niv = 0;
	niv++;
	inst = 2;
    return mc_while;}
"for" {rechercher(yytext,"Mot cle","",0, 1); printf("mot cle reconnu %s \n", yytext);colonne+=yyleng;
	if (satr == 1) niv = 0;
	niv++;
	inst = 2;
    return mc_for;}
{cmntr} {printf("commentaire reconnu %s \n", yytext);colonne+=yyleng;}
{tab} {printf("tableau reconnu %s \n", yytext);colonne+=yyleng;return tableau;}
{PLUS} {rechercher(yytext,"sep",0,0,2);printf("PLUS reconnu  %s \n", yytext);colonne+=yyleng;return plus;}
{MINUS} {rechercher(yytext,"sep",0,0,2);printf("MINUS reconnu  %s \n", yytext);colonne+=yyleng;return minus;}
{DIV} {rechercher(yytext,"sep",0,0,2);printf("DIV reconnu  %s \n", yytext);colonne+=yyleng;return divv;}
{MUL} {rechercher(yytext,"sep",0,0,2);printf("MUL reconnu  %s \n", yytext);colonne+=yyleng;return mul;}
{oplog_bin} {rechercher(yytext,"sep",0,0,2);printf("operateur logique reconnu  %s \n", yytext);colonne+=yyleng;return op_log_bin;}
{oplog_uni} {rechercher(yytext,"sep",0,0,2);printf("operateur logique reconnu  %s \n", yytext);colonne+=yyleng;return op_log_uni;}
{opcomp} {rechercher(yytext,"sep",0,0,2);printf("operateur comparaison reconnu  %s \n", yytext);colonne+=yyleng;return op_comp;}
{cst} {
	if(atoi(yytext) < 32000){
		rechercher(yytext,"Cst entiere","INTEGER",atoi(yytext),0);
		printf("CST reconnu  %s \n", yytext);colonne+=yyleng;return constante;
	}else{
		printf("%s entite non reconnu a la ligne %d la colonne %d\n",yytext,ligne,colonne);
	}
	}
{idf} {rechercher(yytext,"IDF","",0,0);  
    if(yyleng <= 8){
        printf("IDF reconnu  %s \n", yytext);colonne+=yyleng;
		return idf;
    }else{
        printf("%s entite non reconnu a la ligne %d la colonne %d\n",yytext,ligne,colonne);
    }
}
{reel} {rechercher(yytext,"Cst reelle","FLOAT",atof(yytext),0); printf("Reel reconnu  %s  \n", yytext);colonne+=yyleng;return val_reel;}
{valchar} {rechercherCh(yytext,"caractere","CHAR", yytext); printf("caractere reconnu %s \n", yytext);colonne+=yyleng;return val_char;}
{valbool} {rechercherCh(yytext,"booleen","BOOL", yytext); printf("booleen reconnu %s \n", yytext);colonne+=yyleng;return val_bool;}

{aff} {rechercher(yytext,"sep",0,0,2); printf("affectation reconnu  %s  \n", yytext);colonne+=yyleng;return affect;}
{bloc} {printf("indentation reconnue  %s  \n", yytext);colonne+=yyleng;
	satr = 0;
	if(inst == 1){
		if(yyleng/4 == niv){
			inst = 0;
			return indent;
		}
	}else{
		if(yyleng/4 <= niv){
			niv = yyleng/4;
			return indent;
		}
		};}
":" {rechercher(yytext,"sep",0,0,2); printf("Deux points reconnu  %s  \n", yytext);colonne+=yyleng;return pts;}
"(" {rechercher(yytext,"sep",0,0,2); printf("parenthese ouvrante reconnu %s \n", yytext);colonne+=yyleng;return po;}
")" {rechercher(yytext,"sep",0,0,2); printf("parenthese fermante reconnu %s \n", yytext);colonne+=yyleng;return pf;}
"," {rechercher(yytext,"sep",0,0,2); printf("virgule reconnu %s \n", yytext);colonne+=yyleng;return vg;}
\n  {ligne=ligne+1;colonne=1;if (inst ==2) inst = 1;satr = 1;return saut;}
" " {colonne++;}
. printf ("erreur lexical, ligne %d, colonne %d, %s. \n",ligne,colonne,yytext);

