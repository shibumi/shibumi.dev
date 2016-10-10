---
layout: post
title:  "Smash the Stack 2"
date:   2014-08-15 13:13:13
categories: IT-Sec
---

Willkommen zur zweiten Runde von [http://io.smashthestack.org/](http://io.smashthestack.org/)
. In meinem ersten Post haben wir bereits Level 1 gelöst nun ist Level 2 dran. Wie du sicher bemerkt hast haben wir dieses Mal mehrere Dateien für Level 2.

* level02_alt
* level02_alt.c
* level02
* level02.c

Wir könnten uns eine Aufgabe aussuchen. Aber wir werden beide Aufgaben bearbeiten. Widmen wir uns zu erst *level02_alt*. Anders als beim ersten Mal haben wir dieses Mal den Sourcecode dabei. Sehen wir uns den doch mal an:

{% highlight c %}
/* submitted by noname */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>


#define answer 3.141593

void main(int argc, char **argv) {
    float a = (argc - 2)?: strtod(argv[1], 0); 
    printf("You provided the number %f which is too ", a); 
    if(a < answer) 
        puts("low"); 
    else if(a > answer) 
        puts("high"); 
    else execl("/bin/sh", "sh", "-p", NULL);
}
{% endhighlight %}

Was tut der Code? Der Code macht nichts anderes als einen Parameter entgegenzunehmen und diesen auszuwerten. Ist der Parameter höher oder niedriger als unsere Konstante *answer* wird ein entsprechender Text ausgegeben. Wenn der Wert irgendetwas anderes ist spawnt eine Shell.
Ich benutze hier mit Absicht die Klausel "irgendetwas anderes". Vielleicht denkst du dir schon wieso. Der per Parameter übergebene Wert muss nicht die Konstante *answer* treffen. Dies ist auch gar nicht möglich. Natürlich denkst du jetzt:" Wieso denn das? Ich kann doch einfach 3.141593 als Parameter übergeben und bin drin!" - Nein bist du eben nicht! Da es sich bei 3.141593 um eine Gleitkommazahl handelt kann sie binär nicht richtig dargestellt werden. Wenn wir nun also 3.141593 als Parameter übergeben würden, wäre dieser Wert ein anderer als in der Konstanten *answer* gespeichert ist. Das Rätsel ist also komplizierter als man denkt. Die Lösung ist aber relativ einfach, wenn man sie denn weiß. Der eingebene Parameter wird vom Typ String in den Typ Float umgewandelt mit der Funktion *strod*. Dies können wir uns zu Nutze machen. Im technischen Standard IEEE 754 ist festgesetzt, dass neben Gleitkommazahlen auch andere Werte möglich sind. Dazu gehören zum Beispiel "Infinity" ( unendlich ) und "NaN". "NaN" ist die Abkürzung für "Not a Number" ( Keine Zahl ). Wenn wir also den Wert "NaN" als Parameter übergeben ist der Parameter nicht größer und auch nicht kleiner als *answer* und damit spawnt unsere Shell. 

Soviel zu Aufgabe *level02_alt*. Nun widmen wir uns *level02*. Dazu schauen wir uns wieder den Sourcecode an:

{% highlight c %}
//a little fun brought to you by bla

#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <setjmp.h>

void catcher(int a)
{
    setresuid(geteuid(),geteuid(),geteuid());
    printf("WIN!\n");
    system("/bin/sh");
    exit(0);
}

int main(int argc, char **argv)
{
    puts("source code is available in level02.c\n");

    if (argc != 3 || !atoi(argv[2]))
        return 1;
    signal(SIGFPE, catcher);
    return abs(atoi(argv[1])) / atoi(argv[2]);
}
{% endhighlight %}

Dieser Code nimmt 2 Parameter entgegen. Nimmt man weniger oder mehr als 2 Parameter beendet das Programm. Das Programm beendet aber auch wenn die Zahlen nicht zum Typ Integer umgewandelt werden können. Danach wird ein Hook initialisiert um das Signal *SIGFPE* abzufangen, wenn dieses auftritt wird zur Funktion *catcher* gesprungen und eine Shell spawnt. Danach wird der erste Parameter durch den Zweiten geteilt und der Betrag vom Ergebnis zurückgegeben.

Von immenser Bedeutung für das Programm ist also das potenzielle Abfangen des Signals *SIGFPE*. Das Signal *SIGFPE* ( FPE für "Floating Point Exception ) wird bei fehlerhaften arithmetischen Operationen geschmissen. Darunter fällt das Teilen durch Null, aber auch das überschreiten des Wertebereichs der Variable. Auf dem ersten Blick könnte man also einfach eine Teilung durch Null provozieren. Dies geht aber deshalb schief weil damit das zweite Argument Null wäre und damit wäre die Bedingung in der If-Klausel wahr und das Programm beendet. Deshalb ist die Lösung des Rätsels den Wertebereich des Datentyps Integer zu sprengen. Um festzustellen wie die Grenzen des Wertebereichs festgelegt sind können wir uns ein kleines C-Programm schreiben:

{% highlight c %}
#include <limits.h>
#include <stdio.h>

int main(void){
  printf("Obere Grenze von Integer %d\n", INT_MAX);
  printf("Untere Grenze von Integer %d\n", INT_MIN);
  return 0;
  }
{% endhighlight %}

Das Programm tut nichts anderes als die Konstanten *INT_MAX* und *INT_MIN* auszugeben, welche in der headerfile *limits.h* definiert sind. In den Konstanten stehen der höchste Wert und der niedrigste Wert für Integer. Die Ausgabe des Programms sieht so aus:

*Obere Grenze von Integer 2147483647*  
*Untere Grenze von Integer -2147483648*  

Was auffällt ist, dass die untere Grenze vom Betrag her größer als die Obere ist. Wir müssen also nur die untere Grenze durch -1 teilen. Dies würde +2147483648 ergeben und damit den Zahlenbereich von Integer sprengen. Somit hätten wir das Rätsel gelöst.
