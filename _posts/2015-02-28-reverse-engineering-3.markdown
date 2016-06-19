---
layout: post
title:  "Reverse-Engineering mit radare2 - Teil 3"
date:   2015-02-28 13:13:13
categories: IT-Sec
---

Hier die dritte Runde von meinem kleinen crackme-special. Die crackmes findet
ihr hier:

[http://www.nullday.de/img/crackme.tar.gz]({{ sitebase.url }}/img/crackme.tar.gz)

Level7
------

Bei Level7 schreckt man Anfang vielleicht etwas zusammen. Weil man recht schnell
feststellt, dass in der binaries keine symbols sind. Das liegt daran, dass die
binary gestripped worden ist. 'gestripped' bedeutet, dass alle Symbole aus der
binary entfernt worden sin. Dies spart plattenplatz und erhöht die
Ausführungsgeschwindigkeit. Eine Menge systemwichtiger binaries zb *cp* oder
*ls* liegen gestripped vor. Ob eine binary gestripped worden ist oder nicht,
kann man mit dem *file* command überprüfen:

crackme0x07: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV),
dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 2.6.9,
stripped

Wie man sehen kann liegt Level7 also stripped vor. Dies erschwert uns etwas,
dass Reverse Engineering aber macht es bei weitem nicht unmöglich. Da die binary
gestripped ist können wir kein *pdf@sym.main* in radare2 benutzen um die main
Methode zu disassemblieren. Wir schauen uns also einfach den *entry-point* via
*pd* an:

![level7]({{ sitebase.url }}/img/crackme-level0x71.png")
![level7]({{ sitebase.url }}/img/crackme-level0x72.png")
![level7]({{ sitebase.url }}/img/crackme-level0x73.png")
![level7]({{ sitebase.url }}/img/crackme-level0x74.png")
![level7]({{ sitebase.url }}/img/crackme-level0x75.png")
![level7]({{ sitebase.url }}/img/crackme-level0x76.png")

Das scheint eine Menge zusammenhangloser Code zu sein. Räumen wir also mal auf.
Wir können mit dem Befehl *af+ <offset> <size> <func name>* neue Funktionen
erstellen. Fangen wir also mal mit der Main-Methode an. Radare war bereits schon
so freundlich und hat uns die main-Funktion markiert. Wir müssen nur nach einem
*;-- main* suchen. Dies ist unser Kandidat für die main-Funktion. Wir nehmen
also den Offset vom Anfang und subtrahieren diesen vom Offset+1 vom *ret* von der
Main-Funktion und schon haben wir die Größe der Main-Funktion. Danach können wir
den Rahmen der Funktionen bauen via *af+ 0x0804867d 99 main*. Hier ist das
fertige Ergebnis:

![level7]({{ sitebase.url }}/img/crackme-level0x77.png)

Die Main-Funktion scheint sich nicht weit verändert zu haben. Alles was passiert
ist, ist bei Offset *0x080486d4*. Dort fehlt natürlich wegen dem stripping der
Funktionsname *sym.check*. Schauen wir uns diese Funktion mal an und passen die
auch gleich mal an:

![level7]({{ sitebase.url }}/img/crackme-level0x78.png)
![level7]({{ sitebase.url }}/img/crackme-level0x79.png)

Anscheinend gibt es noch mehr Functions. Versuchen wir diese also auch mal zu
identifizieren. Dies hier scheint unsere *parell*-Funktion zu sein:

![level7]({{ sitebase.url }}/img/crackme-level0x711.png)

Das hier ist unsere *dummy*-Funktion:

![level7]({{ sitebase.url }}/img/crackme-level0x712.png)

Und das hier scheint eine Art *exit*-Funktion zu sein:

![level7]({{ sitebase.url }}/img/crackme-level0x713.png)

De facto handelt es sich also um unser crackme0x06 mit einigen Extra-Funktionen  
in gestrippter Version. Diese Extra-Funktionen scheinen nur in Funktionen
ausgelagerte Code-Abschnitte zu sein. Dennoch habe ich noch was hinzuzufügen. 
Dieser Auszug aus der *parell*-Funktion scheint dennoch eine Funktion zu erfüllen. 
Nicht wie im letzten Teil behauptet:

![level7]({{ sitebase.url }}/img/crackme-level0x714.png)

Es handelt sich dabei offenbar um eine Überprüfung wie lang die eingegeben Zahl
ist. Wenn sie länger als 9 Chars ist, ist die Eingabe nämlich ungültig. Dies
wollte ich nur nochmal anmerken. 

Level8
------

Da wir Level 7 nun endlich beendet haben widmen wir uns Level 8. Auch hier
scheint sich nicht viel verändert zu haben. Nur in der Funktion *check* scheint
es eine neue Funktion namens *che* zu geben. Schauen wir uns diese Funktion doch
mal an:

![level8]({{ sitebase.url }}/img/crackme-level0x81.png)

Bei der *che*-Funktion scheint es sich um nichts neues zu handeln. Es handelt
sich einfach nur um alten Code der in eine Funktion ausgelagert worden ist. Wir
haben ähnliches in crackme0x07 gesehen. Vermutlich ist das hier die ungestrippte
Version von crackme0x07. Wenn wir uns mal den Diff von den beiden binaries
ansehen sieht man auch gut, dass die beiden binaries sich ziemlich ähnlich sind.
Nur dass eine Version gestripped ist und die andere nicht:

![level8]({{ sitebase.url }}/img/crackme-level0x82.png)

Level 8 scheint also erledigt zu sein. Hier gelten die gleichen Bedingungen wie
in Level 7 und Level 6.

Level9
------

Das letzte Level scheint ein komisches Verhalten an den Tag zu legen wenn die
ENV-Variable "LOLO" nicht gesetzt ist. 

![level9]({{ sitebase.url }}/img/crackme-level0x91.png)

So wird das Programm entweder beendet mit Fehlerstatus 255 oder es gibt den
String "Incorrect!" aus wenn die Eingabe an sich falsch ist. Setzt man die
ENV-Variable "LOLO" aber scheint es genau das gleiche Programm zu sein wie zuvor. 
Wenn man das programm mal mit gdb und PEDA durchgeht erhält man am Ende folgende Message:

"[Inferior 1 (process 21285) exited with code 0377]"

Die Funktion die überprüft ob "LOLO" vorhanden ist oder nicht ist diese hier:

![level9]({{ sitebase.url }}/img/crackme-level0x92.png)

Fazit: Die binary crackme0x09 scheint also den binaries zuvor ähnlich zu sein.
crackme0x09 reagiert allerdings deutlich agressiver wenn man die ENV-Variable
nicht setzt. Anstatt einfach nur ein "Incorrect" auszugeben wird das ganze
Programm mit Fehlercode beendet.
