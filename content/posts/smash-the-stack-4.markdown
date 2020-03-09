---
title:  "Smash the Stack 4"
date:   2014-10-15T13:13:13+01:00
draft: false
description: "Smash the stack Level 4 Auflösung"
toc: false
tags:
  - ctf
---

So nach einer längeren Pause bin ich wieder zurück und habe neue Levels für io.smashthestack.org mitgebracht.

Heute widmen wir uns Level4 ( um genauer zu sein level04.c und der zugehörigen binary. Level04_alt.c funktioniert so ähnlich). Der Code dafür sieht folgendermaßen aus:


```c
//writen by bla
#include <stdlib.h>
#include <stdio.h>

int main() {
    char username[1024];
    FILE* f = popen("whoami","r");
    fgets(username, sizeof(username), f);
    printf("Welcome %s", username);
    return 0;
}
```



Gehen wir den Code durch. In Zeile 1 der `main` Funktion wird Platz für den username angelegt in Form eines 1024 bytes großen Char-Arrays. Zeile 2 öffnet einen stream mit Leserechten zum Prozess `whoami`. In Zeile 3 wird `fgets` benutzt um den usernamen aus dem Befehl `whoami` zu lesen und in dem Char-Array zu speichern. Danach wird `printf` benutzt um eine simple Willkommensnachricht auszugeben mit passendem Usernamen.

Wenn wir die Binary `level04` normal ausführen erhalten wir folgende Ausgabe:

"Welcome level5"

Dies zeigt uns, dass die Binary wie bisher in jedem Level mit Benutzer-Rechten ausgeführt wir
d. Die Binary hat also das `Setuid`-Flag.

Da diesesmal die einzige Eingabe der Befehl `whoami` darstellt, können wir keinen Buffer-Overflow herbeiführen. Der einzige Weg das Programm zu manipulieren läuft also über diesen `whoami` Befehl. Die Binary für den `whoami` Befehl liegt aber in /usr/bin und da haben wir keine Schreibrechte drauf. Was also tun? Naja, wir bauen uns ganz einfach ein eigenes `whoami`. Dieses `whoami` führt dann eine shell oder einen anderen Befehl für uns aus.

Nach dieser Erkenntnis habe ich auf verschiedenen Wegen verursacht mir das zu Nutze zu machen und zum Beispiel eine Shell zu spawnen. Irgendwann begriff ich jedoch, dass eine Shell gar nicht nötig ist. Ich will ja nur das Passwort. Seltsamerweise funktioniert der Exploit nicht wenn man eine Shebang-zeile im Script hat und generell wird nur die erste Zeile des `whoami`-Klons ausgeführt. Also kam ich zu dem folgendem Ergebnis:

Zu Erst habe ich im `/tmp`-Verzeichnis einen Unterordner erstellt und diesen einfach `foobar` genannt. Danach habe ich in diesem `/tmp/foobar`-Verzeichnis einen `whoami`-Klon platziert. Dieser führt folgende Code-Zeile aus:

```bash
echo $(cat /home/level5/.pass)
```

Man beachte, dass dort die Shebang-Zeile fehlt. Es darf wirklich nur eine Zeile im Script stehen. Ansonsten verläuft der Exploit nicht stabil. Danach habe ich die PATH-Variable geändert. Die PATH-Variable ist als Environment-Variable in der Shell gesetzt. Über die PATH-Variable findet die Shell die absoluten Pfade von Befehlen. So reicht es zb aus `whoami` einzutippen anstatt `/usr/bin/whoami`. Meine neue PATH-Variable habe ich über folgenden Befehl neugesetzt:

`PATH=/tmp/foobar:$PATH`

Mit diesem Befehl setze ich den Pfad zu meinem `whoami`-Klon vor dem eigentlichen Standard-Pfad. Mein Klon hat also Vorrang und wird zuerst ausgeführt. Nun müssen wir nur noch die `Level04` Binary ausführen und wir werden mit einer netten Willkommens-Nachricht begrüßt die uns das Passwort für Level5 verrät.
