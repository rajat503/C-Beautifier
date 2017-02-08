%option noyywrap
%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<assert.h>
    #include<string.h>
    #define INDENT (4)
    int line = 1;
    int column = 4;
    int paren = 0;

    #define MAXSYMBOLS 200
    struct entry {
        char *lexptr;
        int token;
    };
    struct entry symtable[MAXSYMBOLS];
    int lookup(char *lexeme); // returns index of the symbol table where the lexeme appears, -1 otherwise
    int insert(char *a, int token); // inserts a new entry into a symbol table
    void init(); // initializes the symbol table with preloaded keywords
    int insert_index = 0;

    void indent();
    void write_html();
    void write_html_char(char);

    void write_string();
    void write_char();
    void write_oct();
    void write_hex();
    void write_int();
    void write_fp();
    void write_id();
    void write_begin();
    void write_end();
    void write_open();
    void write_close();
    void write_bopen();
    void write_bclose();
    void write_sep();
    void write_op();
    void write_inline();
    void write_comment();
    void write_directive();
    void error();

%}

quote '
ditto   \"
back    \\
digit   [0-9]
exp [eE]([+-]?)({digit}+)
hex [0-9a-fA-F]
alpha   [a-zA-Z_]
ch  [^\\'\"\n]

%%
{ditto}({back}{ch}|{back}{back}|{back}{quote}|{back}{ditto}|{ch}|{quote})*{ditto}   { write_string(); }
{quote}({back}{ch}|{back}{back}|{back}{quote}|{back}{ditto}|{ch}|{ditto}){quote}    { write_char(); }
0([0-7]+)   { write_oct();}
0[xX]({hex})+   { write_hex(); }
{digit}+    { write_int(); }
{digit}+"."({digit}*)({exp}?) { write_fp();  }
{alpha}({alpha}|{digit})*(" "|"\n")? { write_id();  }
"{" { write_begin(); }
"}" { write_end(); }
"(" { write_open(); }
")" { write_close(); }
"[" { write_bopen(); }
"]" { write_bclose(); }
";" { write_sep(); }
(\.|\-\>|\+\+|\-\-|&|\*|\+|\-|~|!|\/|\%|\<\<|\>\>|\<|\>|=|==|"||"|"|"|\<=|\>=|!=|\^\||&&|\|\|\?|\*=|\/=|\%=|\+=|\-=|\<\<=|\>\>=|&=|\^=|\|=|,|#|##|;|:|\"|\.\.\.) { write_op(); }

"\/\/"[^\n]*	{ write_inline(); }
"/*" { write_comment(); }
#[^\n]* { write_directive(); }

[ \t\v\n\r\f] ;
{ch} { error(); }
%%

void write_string() {
    printf("<font color='#FF0000'>");
    write_html();
    printf("</font>");
}

void write_char() {
    printf("<font color='#00FFFF'><u>");
    write_html();
    printf("</u></font>");
}

void write_oct() {
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_hex() {
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_int() {
    printf("<font color='#00FFFF'><i>");
    write_html();
    printf("</i></font>");
}

void write_fp() {
    printf("<font color='#00FFFF'>");
    write_html();
    printf("</font>");
}

void write_id() {
    /*
    printf("<font color='#0000FF'>");
    write_html();
    printf("</font>");
    */
    char *s = yytext;
	int flag=0;
	if(s[strlen(s)-1]==' ' || s[strlen(s)-1]=='\n') {
		flag=1;
		s[strlen(s)-1]='\0';
	}
    int x = lookup(s);
    if(x==-1) {
        insert(s, 1);
		if(flag==1)
        	printf("<font color='#0000FF'><a name=\"%s\">%s</a> ", s, s);
		else
			printf("<font color='#0000FF'><a name=\"%s\">%s</a>", s, s);
        printf("</font>");
    }
    else {
        if(symtable[x].token==0) {
            printf("<font color='#0000FF'><b>");
            while(*s)
                write_html_char(*s++);
			if(flag==1)
				write_html_char(' ');
            printf("</b></font>");
        }
        else {
			if(flag==1)
            	printf("<font color='#0000FF'><a href=\"#%s\">%s</a> ", s, s);
			else
				printf("<font color='#0000FF'><a href=\"#%s\">%s</a>", s, s);
            printf("</font>");
        }
    }
}

void write_begin() {
    indent();
    write_html();
    column += INDENT;
    indent();
}

void write_end() {
    column -= INDENT;
    indent();
    write_html();
    indent();
}

void write_open() {
    write_html();
    //putchar(' ');
    paren++;
}

void write_close() {
	write_html();
	//putchar(' ');
	paren--;
}

void write_bopen() {
    write_html();
}

void write_bclose() {
    write_html();
}

void write_sep() {
	write_html();
	if(!paren)
		indent();
	else
		putchar(' ');
}

void write_op() {
    printf("<b>");
    write_html();
    printf("</b>");
}

void write_inline() {
	printf("<font color='#00FF00'>");
	write_html();
	printf("</font>");
	indent();
}

void write_comment() {
    char c, c1;
    printf("<font color='#00FF00'>/*");
    loop:
    while ((c = input()) != '*' && c != 0)
    write_html_char(c);
    write_html_char('*');
    if ((c1 = input()) != '/' && c != 0) {
        unput(c1);
        goto loop;
    }
    if (c != 0)
	write_html_char(c1);
    printf("</font>");
	indent();
}

void write_directive() {
	printf("<font color='#FF00FF'><b>");
	write_html();
	printf("</b></font>");
	indent();
}

void error() {
    assert(0);
}

void write_html_char(char c) {
	switch(c) {
		case '<': printf("&lt;");break;
		case '>': printf("&gt;");break;
		case '"': printf("&quot;");break;
		case '&': printf("&amp;");break;
		default: putchar(c);
	}
}

void write_html() {
	char *s = yytext;
	while(*s)
		write_html_char(*s++);
}

void indent() {
	printf("\n%-*d",column,line++);
}

int lookup(char *lexeme) {
    int i=0;
    int flag = 0;
    for(i=0;i<insert_index;i++) {
        if(strcmp(symtable[i].lexptr, lexeme)==0) {
            flag=1;
            break;
        }
    }
    if(flag==0) {
        return -1;
    }
    else {
        return i;
    }
}

int insert(char *a, int token) {
    symtable[insert_index].lexptr = (char *) malloc(10);
    strcpy(symtable[insert_index].lexptr, a);
    symtable[insert_index++].token=token;
    return insert_index - 1;
}

void init() {
    char keywords[32][10] = {"auto", "double","int","struct","break","else","long","switch", "case","enum","register",
    	"typedef", "char", "extern", "return", "union","const","float","short","unsigned",
        "continue","for","signed","void", "default","goto","sizeof","volatile","do","if","static","while"};
    int i=0;
    for(i=0;i<32;i++) {
        insert(keywords[i],0);
    }
}


int main() {
	FILE *fp;
	fp = freopen("output.html","w",stdout);
    printf("<html><pre>\n");
    indent();
    init();
	yyin = fopen("input.c", "r");
    yylex();
    printf("\n</pre></html>\n");
	fclose(fp);
	fclose(yyin);
    return 0;
}
