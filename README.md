# MiniPy — compilateur d'un mini-langage à la Python (Flex / Bison)

Projet du module *Compilation* de Licence 3 informatique (USTHB, 2022–2023). Il s'agit de la partie avant d'un compilateur pour un petit langage typé à indentation significative :

- analyse **lexicale** avec Flex ;
- analyse **syntaxique** avec Bison ;
- **table des symboles** ;
- début de génération de **code intermédiaire** en quadruplets.

```python
# Somme des X premiers entiers
int X = 50
int Res = 0
if (X == 0):
    X = 0

while (X != 0):
    Res = Res + X
    X = X - 1
```

## Le langage

| Élément | Règle |
|---|---|
| Types | `int`, `float`, `char`, `bool` ; tableaux `int Tab[10]` |
| Identifiants | commencent par une **majuscule**, lettres et chiffres, 8 caractères au plus |
| Constantes | entiers < 32000, négatifs entre parenthèses `(-5)` ; réels `3.14`, `(-2.5)` ; caractères `'a'` ; booléens `true` / `false` |
| Déclarations | `int X`, `int A, B, Cpt = 0`, `float Pi = 3.14` |
| Opérateurs | `+ - * /`, `> >= == != <= <`, `and or not`, affectation `=` |
| Blocs | `:` puis indentation de 4 espaces par niveau |
| Instructions | affectation, `if … : … else: …`, `while (…):`, `for I in range (a, b):`, `for I in T:` |
| Commentaires | `# …` jusqu'à la fin de la ligne |

## Ce que produit le compilateur

1. La trace de l'analyse lexicale, avec chaque entité reconnue et les erreurs localisées par ligne et colonne.
2. Les structures reconnues par l'analyse syntaxique (affectations, conditions, boucles), ou `Erreur Syntaxique a ligne L a colonne C`.
3. Les tables des symboles : identifiants et constantes avec type et valeur, mots-clés, séparateurs.
4. Les quadruplets des branchements du `if / else` : `BZ` (saut si faux) et `BR` (saut inconditionnel) avec mise à jour des adresses.

## Compiler et exécuter

Prérequis : `flex`, `bison` et un compilateur C (GCC).

```bash
make                                  # génère build/minipy
./build/minipy < examples/somme.txt   # ou : make run
```

Exemples fournis dans [`examples/`](examples) : `somme.txt`, `if_else.txt`, `for_range.txt`, `declarations.txt`. Ils sont tous analysés sans erreur.

## Organisation

```
src/lexical.l   analyseur lexical (Flex) : entités, indentation, remplissage des tables
src/synt.y      grammaire (Bison), actions de génération des quadruplets, programme principal
src/ts.h        table des symboles : insertion, recherche, affichage
src/quad.h      quadruplets : création, mise à jour d'adresse, affichage
```

## Limites connues

- Les contrôles sémantiques (double déclaration, variable non déclarée) sont seulement esquissés en commentaire dans la grammaire : les fonctions correspondantes ne sont pas implémentées.
- Seuls les branchements du `if / else` produisent des quadruplets ; les affectations et les boucles n'en génèrent pas encore.
- La grammaire contient des conflits (10 décalage/réduction, 5 réduction/réduction) résolus par les choix par défaut de Bison.

**Modifications par rapport à la version rendue en 2023 :**
- ajout des prototypes nécessaires aux compilateurs C récents (GCC ≥ 14 refuse les déclarations implicites) ;
- correction de la règle `else`, qui exigeait une indentation devant le mot-clé et rejetait tout `if / else` ;
- ajout des exemples et du Makefile.

## Licence

Code distribué sous [licence MIT](LICENSE).

## Auteurs

**Amar Merabti** — Licence 3 informatique, USTHB.
