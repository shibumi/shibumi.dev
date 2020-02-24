---
title:  "Smash the Stack 3"
date:   2014-09-01T13:13:13+01:00
draft: false
description: "Smash the stack Level 3 Auflösung"
toc: false
---

Willkommen zur dritten Runde von [http://io.smashthestack.org/](http://io.smashthestack.org/)
. In dieser Runde geht es um folgende beiden Dateien:

* level03
* level03.c

Schauen wir uns also mal den Programmcode an:

```c
//bla, based on work by beach

#include <stdio.h>
#include <string.h>

void good()
{
        puts("Win.");
        execl("/bin/sh", "sh", NULL);
}
void bad()
{
        printf("I'm so sorry, you're at %p and you want to be at %p\n", bad, good);
}

int main(int argc, char **argv, char **envp)
{
        void (*functionpointer)(void) = bad;
        char buffer[50];
        if(argc != 2 || strlen(argv[1]) < 4)
                return 0;
        memcpy(buffer, argv[1], strlen(argv[1]));
        memset(buffer, 0, strlen(argv[1]) - 4);
        printf("This is exciting we're going to %p\n", functionpointer);
        functionpointer();
        return 0;
}
```


Was wir hier sehen sind 3 Funktionen. Eine Funktion namens `good` die eine shell spawnt. Eine Funktion namens `bad` die einen Hilfetext ausgibt und den Standardeinstiegspunkt in C Programmen: die `main`-Funktion.

In der `main`-Funktion wird zu erst ein sogenannter "Functionpointer" initialisiert. Das ist ein einfacher zeiger den man wie eine Funktion benutzen kann. Dieser Zeiger zeigt auf die Funktion `bad`. Danach wird ein Char-Array der Größe 50 namens Buffer definiert. Im weiteren if-Abschnitt werden die Argumente geprüft. Sind es mehr als ein zusätzliches Argument und hat dieses Argument eine Länger kleiner als 4 beendet das Programm mit dem Returnwert 0. Als nächstes wird via `memcpy` speicher kopiert. Um genauer zu sein wird das erste Argument in den buffer kopiert. Wir merken uns, dass das Array nur 50 bytes groß ist. Das ist wichtig. Wieso 50 bytes? nun ja weil ein char ein byte groß ist. Mit `memset` können wir gezielt in den Speicher Werte schreiben. Da wird einfach alles auf 0 gesetzt bis auf die letzten 4 bytes. Danach kommt ein normales ein `printf` mit Adresse des functionspointers und der functionpointer wird aufgerufen.

Bei level03 handelt es sich um ein klassisches Beispiel für einen Buffer-Overflow. Es wird nirgends überprüft ob wir uns an die 50 byte des Arrays halten. Wir können also das erste Argument beliebig groß machen und so da Programm zum Absturz bringen. Hier ein kleines Beispiel:

![Bild des disassemblierten Programms](/img/level03_1.png)

Wir benutzen hier folgende Zeile als Argument:

`$(python2 -c "print 'A' * 80")`  

Dadurch, dass diese Zeile in $() Klammern steht wird sie direkt von der Shell ausgeführt. Wir schleusen also sogesagt ein Argument über ein kleines Python-Programm ein. Das Python-Program tut nichts anderes als 100 mal 'A' als Argument zu schreiben. Dementsprechend haben wir 100 mal den Buchstaben A in der Variable `argv[1]` und sprengen damit den Buffer der nur 50 bytes groß ist. Also nur für 50 Zeichen Platz bietet. Interessanter ist jedoch die erste Zeile des Outputs:

`This is exciting we're going to 0x41414141`  

0x41 ist der Hexwert für 'A'. Wir haben es also geschafft den Programmfluss zu ändern. Man kann sich das so vorstellen wie ein Auto was einer Klippe entgegenfährt und circa 100 meter über die klippe hinausschießt. Unser Ziel ist es, dass Auto kurz vor der Klippe zu übernehmen und neuzuprogrammieren. Die nächste Zeile des Outputs ist ein `Segmentation fault` oder kurz `segfault`. Das ist ein Speicherzugriffsfehler. Unser Programm beispielsweise versucht an die Adresse 0x41414141 zu springen. Da an diesem Ort kein gültige Funktion ist beziehungsweise dieser Speicherbereich gesichert ist stürzt das Programm mit einem `segfault` ab.

Was wir also geschafft haben ist den functionpointer zu überschreiben. Betrachten wir den Stack etwas genauer um den Sachverhalt besser nachvollziehen zu können:

Der Stack wächst von hohen Adressen zu den niedrigen Adressen (Der Heap, ebenfalls ein Speicher wächst übrigens genau andersherum beide Speichersegmente wachsen gegeneinander. Damit spart man Speicher und trennt beide Segmente gezielt voneinander. Außerdem befindet sich zwischen den beiden random Offset und das Memory Mapping Segment für file mappings etc aber dazu später). Der Stack sollte von unten nach oben (von hohen Adressen zu niedrigen Adressen) so aussehen:

```
char buffer[50] : 50 bytes  
void(*functionpointer) : 4 bytes  
saved Frame Pointer  
return Adress  
int argc  
char **argv : 4 bytes  
```

Wenn wir den Stack von unten nach oben durchgehen wird uns klar, dass beim Aufruf der `main`-Funktion zu erst die Argumente auf den Stack gepushed werden. Danach die return-Adresse, danach der Frame Pointer und danach die lokalen Variablen. Dadurch, dass der functionpointer vor dem Buffer auf den Stack gepushed wird können wir ihn überschreiben. Der `buffer` wächst nämlich von oben nach unten, also um vom Stack auszugehen, von den niedrigen Adressen zu den hohen Adressen. Um den Programmfluss zu übernehmen müssen wir also nur den functionpointer überschreiben. Damit wird am Ende eine andere Funktion aufgerufen und wir haben es geschafft. Die Funktion die wir uns auserkoren haben ist natürlich keine andere als die `good`-Funktion.

Als Erstes besorgen wir uns die Adresse der `good`-Funktion. Dabei hilft uns gdb:

![Bild des disassemblierten Programms](/img/level03_2.png)

Die Adresse ist einfach die Adresse an Stelle Null: `0x08048474`.
Als nächstes starten wir das Programm mal mit einem spezifischen Pattern als Argument. Dadurch finden wir das Argument schnell im Speicher wieder. Am besten bietet sich dafür 'AAAA' an.
Davor setzen wir aber noch einen Breakpoint genau an die Stelle hinter `memcpy`. Dadurch lokalisieren wir wo das Argument in den Speicher geschrieben wird:

![Bild des disassemblierten Programms](/img/level03_3.png)

Dann starten wir das Programm mit "AAAA" als Argument und holen uns die Adresse der `bad`-Funktion. Danach geben wir uns den Stack aus und berechnen den Offset also die Entfernung zwischen unserem Pattern und der `bad`-Funktion auf dem Stack:

![Bild des disassemblierten Programms](/img/level03_4.png)

Nun kennen wir den Offset und können den Exploit weiterausbauen. Wir schreiben also den kompletten Offset in den Speicher + die Adresse von der `good`-Funktion und wir haben es geschafft. Dafür nutzen wir wieder Python. Falls ihr euch über die komische Adresse im hinteren Teil wundert, dass ist die gleiche Adresse wie oben nur aufgeteilt in Hex-Ziffern und im `Little-Endian`-Format. Die ganze Adresse also praktisch einmal verkehrtherum. Es wird also zuerst das kleinstwertige byte genannt und dann die Größeren.

![Bild des disassemblierten Programms](/img/level03_5.png)

Damit spawnt die Shell und wir haben level03 gelöst. 
