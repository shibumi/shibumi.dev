---
title:  "Smash the Stack 5"
date:   2014-10-17T13:13:13+01:00
draft: false
toc: false
---

Herzlich willkommen zurück zu Smash-the-Stack Level5. Dieses mal widmen wir uns folgendem C-Sourcecode (level05.c) :

```c
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    char buf[128];
    if(argc < 2) return 1;
    strcpy(buf, argv[1]);
    printf("%s\n", buf);	
    return 0;
}
```
Wie unschwer zu erkennen ist sieht das wieder verdammt nach einem guten alten Buffer-Overflow aus. Als erstes wird ein Char-Buffer mit 128 bytes als Festgröße intialisiert. Danach wird die Anzahl der Argumente überprüft. Wird kein Argument übergeben wird das Programm mit dem Returnwert 1 beendet. Nun wird mit der Funktion `strcpy` das erste Argument in den Buffer kopiert. Dieser Buffer wird dann ausgegeben und das Programm wird mit Returnwert 0 beendet.

Wie wir beim Sourcecode von level05.c sehen haben wir diesesmal keine extra-Funktion die eine Shell für uns spawnt. Also müssen wir dies diesesmal erledigen. Zum Generieren des nötigen Shellcodes nutze ich einige tolle Funktionen von `Metasploit`. `Metasploit` ist ein Framework zur Entwicklung und Ausführung von stabilen Exploits. Generieren wir uns also erstmal nötigen Shellcode. Dafür nutze ich bei mir lokal auf der Angreifer-Maschinen folgenden Befehl:

`ruby-1.9 msfpayload linux/x86/exec cmd=/bin/sh PrependSetresuid=true R|ruby-1.9 msfencode -e x86/shikata_ga_nai -b '\x04'`

`msfpayload` ist ein in der Programmiersprache `Ruby` geschriebener Payload-Generator. Der Payload ist der Schadcode der bei dem Exploit ausgeführt wird. Als Ziel-Architektur haben wir den Parameter `linux/x86/exec` gesetzt. Das heißt `mfspayload` wird einen Payload für eine 32bit Linux-Maschine generieren. Als Kommando setzen wir `/bin/sh`. Der Payload tut also nichts weiteres als `/bin/sh` ausführen. Das `PrependSetresuid` setzt die richtige real user id im shellcode. Das "R" steht für "Raw". Wir generieren also rohen Shellcode. Der Strich nach dem R ist eine Pipe. Damit pipen wir den Output von msfpayload nach msfencode und entfernen die Escapesequenz "\x04". "\x04" ist die Escape-Sequenz für EOT ( End of Transmission ) welcher mir im Shellcode einige Probleme bereitete. Andere nicht gewollte Escape-Sequenzen haben wir zum Glück nicht im Shellcode. So könnte zb die Escape-Sequenz: "\x00" dafür sorgen, dass der Payload nicht vollständig in den Buffer kopiert wird da `strcpy` denkt dort wäre der String zu Ende. "\x00" nennt man auch "Null-Terminator" und ist sowas wie das Symbol für "Hier ist der String zu Ende". Außerdem spezifizieren wir mit dem "-e" Parameter den richtigen Encoder. Wenn man diese Option vergisst benutzt msfencode gerne mal Powershell_base64 als default encoder was zu fehlerhaften shellcode auf linux Systemen führt. Der Output von msfpayload bzw msfencode sieht bei mir so aus:

```
[*] x86/shikata_ga_nai succeeded with size 80 (iteration=1)

buf = 
"\xd9\xce\xd9\x74\x24\xf4\x5e\x2b\xc9\xba\x52\x33\x98\x84" +
"\xb1\x0e\x31\x56\x18\x83\xee\xfc\x03\x56\x46\xd1\x6d\xb5" +
"\xaf\x24\x55\x41\xcc\xf7\xcd\x63\x92\x92\x06\x24\x0b\x30" +
"\x7f\xbc\x06\xd6\xf6\xdb\x30\x37\x7a\x4c\xc0\x2f\x53\xee" +
"\xa9\xc1\x22\x0d\x7b\xf6\x3d\xd2\x7b\x06\x11\xb0\x12\x68" +
"\x42\x47\x8c\x74\xcb\xf4\xc5\x94\x3e\x7a"
```

Damit ist der Payload genau 80 Bytes groß. Dies ist wichtig für uns, weil der Buffer nur 128 Bytes Platz bietet. 

Wir haben den Payload. Widmen wir uns also wieder der level05.c Binary. Ähnlich wie in Level03 generieren wir erstmal ein Pattern. Dazu benutzen wir aber diesesmal `pattern_create.rb`. Dieses kleine Ruby-Programm finden wir ebenfalls im `Metasploit`-Framework. Mit dem folgenden Befehl kreieren wir ein einzigartiges pattern:

`ruby-1.9 pattern_create.rb 170`

Wenn wir Level05 nun in gdb starten und das pattern als Argument übergeben und level05 ausführen erhalten wir folgenden Output:

![pattern](/img/pattern.png)

Anhand dieses Outputs können wir nun den Offset zum instruction pointer Register (EIP) berechnen den wir brauchen. Dazu nutzen wir `pattern_offset.rb` ebenfalls im `Metasploit`-Framework enthalten:

`ruby-1.9 pattern_offset.rb 37654136`

Der daraus berechnete Offset beträgt genau: 140 Bytes.

Als nächstes können wir nun anfangen den stabilen exploit zu bauen. Dafür benutzen wir eine sogenannte "nop-sled". Das sind ganz einfach mehrere "\x90" ( nop ) Operationen hintereinander als Einstiegspunkt. So brauchen wir nur eine nop-Operation treffen und gleiten praktisch in den Shellcode rein der dann die shell für uns ausführt. Die richtige Adresse, also die Adresse an der sich die nop-sled befindet finden wir durch breakpoints setzen und untersuchen des Stacks heraus. Als Layout habe ich mich für diesen Aufbau hier entschieden:

30 * nop + shellcode + 30 * nop + (return adresse die in den nop-sled zeigt)

Davor hatte ich folgendes Layout ausprobiert:

60 * nop + shellcode + (return adresse die in den nop-sled zeigt)

Dies hatte leider seltsamerweise zu segfaults gefühlt. Wieso sich der Exploit so verhalten hat kann ich mir nicht erklären. Aber anscheinend macht es einen Unterschied wo der Shellcode auf dem Stack liegt. Sehr interessant. Ein Vorfall der weiter untersucht werden möchte.

![creepy](/img/creepy.png)

Damit wäre Level05 auch endlich gelöst.
