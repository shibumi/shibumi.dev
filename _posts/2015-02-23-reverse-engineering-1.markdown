---
layout: post
title:  "Reverse-Engineering mit radare2 - Teil 1"
date:   2015-02-23 13:13:13
categories: IT-Sec
---

Nach langer Pause bin ich wieder zurück mit einem kleinen crackme. Ein Backup
von dem crackme findet ihr unter: 

[http://www.nullday.de/img/IOLI-crackme.tar.gz]({{ sitebase.url }}/img/IOLI-crackme.tar.gz)

Als Werkzeug zum Reverse-Engineeren werde ich radare2 einsetzen. 
Also dann, Happy Hacking!

Level0
------

Schauen wir uns die binary erstmal an was sie tut:

![level0]({{ sitebase.url }}/img/crackme-level0x01.png")

Wie man sieht erwartet uns eine Passwort-Prompt. Schauen wir uns also mal
standardmäßig als erstes die Strings an. Ist ja schließlich Level 1 ;-)

![level0 string]({{ sitebase.url }}/img/crackme-level0x02.png)

Und sie an wir haben das Passwort gefunden: 250382.

![level0 ende]({{ sitebase.url }}/img/crackme-level0x03.png)

Level1
------

Diesesmal scheinen wir schon nicht so leichtes Spiel zu haben:

![level1 anfang]({{ sitebase.url }}/img/crackme-level0x11.png)

Schauen wir uns also mal den Disassembly an:

![level1 dis]({{ sitebase.url }}/img/crackme-level0x12.png)

Was sofort auffällt ist der Vergleich an Offset *0x0804842b*. Wenn wir 
das Level also in C-Code darstellen müssten, würde dieser ungefähr so
aussehen:

{% highlight c %}
#include <stdio.h>

int main() {
  int input;
  printf("IOLI Crackme Level 0x01\n");
  printf("Password: ");
  scanf("%d", &input);
  //hex(5274) == 0x149a
  if(input == 5274) {
    printf("Password OK\n");
  } else {
    printf("Invalid Password\n");
  }
  return 0;
}
{% endhighlight %}

Das Passwort lautet also 5274.

![level1 ende]({{ sitebase.url }}/img/crackme-level0x13.png)

Level2
------

Im zweiten Level ist die Sache wieder etwas komplizierter. Dieses mal wird vor
dem Vergleich wild umher gerechnet um die zu vergleichende Zahl etwas zu
verschleiern. Der entscheidende Part des Disassembly ist also der Teil nach dem
scanf-Aufruf.

![level 2 anfang]({{ sitebase.url }}/img/crackme-level0x21.png)

Die Lösung ist also 0x52b24 in dezimaler Form: 338724.

Level3
------

Im dritten Level sehen wir ebenfalls wieder unser wildes umhergerechne. Der
Unterschied zu Level2 liegt allerdings in dem Funktions-Aufruf: *call sym.test*.
Vor dem Aufruf werden via *mov* unsere beiden Werte auf den Stack manövriert.
Schauen wir uns also mal *sym.test* an:

![level3 sym.test]({{ sitebase.url }}/img/crackme-level0x31.png)

Vor dem *cmp* sehen wir das unsere Eingabe an der Stelle *[ebp+0x8]* in das
Register *eax* geschoben wird. Danach wird bei Offset *0x8048477* der Wert in
Register *eax*, also unsere Eingabe, mit dem Wert 0x52b24 auf dem Stack
verglichen. Je nach dem wie das Ergebnis ausfällt wird gesprungen. Es hat sich
also nichts verändert. Das Passwort ist genau das Gleiche wie im Level zuvor.
Das einzige was sich verändert hat sind die Strings in der Binary. Diese wurden
diesesmal etwas obfuscated. Die Funktion *sym.shift* scheint die
"verschlüsselten" Strings zu "entschlüsseln". Schauen wir uns diese spaßeshalber
auch mal an:

![level3 sym.shift]({{ sitebase.url }}/img/crackme-level0x32.png)

Entscheidend am disassembly ist das *sub al, 3* hier wird jeder Char im String
um den wert 0x3 dekrementiert. Die Funktion kann man sich so in C-Code
vorstellen:

{% highlight c %}

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void shift(char* string) {
  size_t length = strlen(string);
  size_t i;
  for (i = 0; i < length; ++i) {
    string[i] -= 0x3;

  }
  printf("%s\n", string);
}

int main() {
  char string1[] = "Lqydolg_Sdvvzrug";
  char string2[] = "Sdvvzrug_RN";
  printf("%s = ", string1 );
  shift(string1);
  printf("%s = ", string2 );
  shift(string2);
  return 0;
}

{% endhighlight %}

Wenn man dies nun ausführt, sieht das Ergebnis so aus:

![level3 decoded string]({{ sitebase.url }}/img/crackme-level0x33.png)

Den Rest gibt es dann im zweiten Teil. Stay tuned ;-)

