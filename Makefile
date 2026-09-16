LEX  ?= flex
YACC ?= bison
CC   ?= gcc

BUILD = build

all: $(BUILD)/minipy

$(BUILD)/minipy: src/lexical.l src/synt.y src/ts.h src/quad.h
	mkdir -p $(BUILD)
	$(YACC) -d -o $(BUILD)/synt.tab.c src/synt.y
	$(LEX) -o $(BUILD)/lex.yy.c src/lexical.l
	$(CC) -std=gnu11 -Isrc -I$(BUILD) $(BUILD)/lex.yy.c $(BUILD)/synt.tab.c -o $@

run: $(BUILD)/minipy
	./$(BUILD)/minipy < examples/somme.txt

clean:
	rm -rf $(BUILD)

.PHONY: all run clean
