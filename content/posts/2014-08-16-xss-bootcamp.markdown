---
title:  "XSS Bootcamp"
date:   2014-08-16T13:13:13+01:00
draft: false
toc: false
images:
tags:
  - untagged
---

Bevor wir zum nächsten Level von [http://io.smashthestack.org/](http://io.smashthestack.org/) kommen möchte ich ein kleines XSS-Wargame einschieben auf das mich ein Kommilitone aufmerksam gemacht hat. Zu finden ist das hier: [https://xss-game.appspot.com/](https://xss-game.appspot.com/). 

Fangen wir auch gleich mal an mit Level 1:

![XSS-Level](storage/img/xss-level1.png)

Was wir in Level 1 sehen ist eine einfaches Suchfeld, in dieses können wir Javascript injezieren umrahmt von HTML-tags. 

```html
<script>alert("nullday.de");</script>
```

Und weiter gehts zu Level 2:

![XSS-Level](storage/img/xss-level2.png)

Level 2 ähnelt einer einfachen Kommentarfunktion wie sie auf vielen Websiten zu finden ist. Was uns sofort beim ersten Testen auffällt: Wir können HTML-tags in den Kommentaren benutzen.
Allerdings funktioniert die gleiche Eingabe wie oben hier nicht. Auch wenn wir die Sonderzeichen durch ihre Hex-Werte ersetzen kommen wir hier nicht weiter. Stattdessen müssen wir uns die standard HTML-tags zu Nutze machen und diese etwas feintunen. Am Besten eignet sich hier für der <img>-tag:

```
<img src="" onerror=javascript:alert("nullday.de")>
```

Level 3:

![XSS-Level](storage/img/xss-level3.png)

In Level 3 sehen wir eine stupide Bilder-Gallerie. Was uns natürlich gleich auffällt ist, dass die Zahl am Ende des Links die Bildnummer angibt: 

Zum Beispiel für Bild 3:

```
https://xss-game.appspot.com/level3/frame#3
```

Hier können wir wieder das `onerror`-Attribut benutzen um javascript zu injezieren:

```
https://xss-game.appspot.com/level3/frame#' onerror="alert('nullday.de')">
```

Dies ist deshalb möglich weil über die Variable `num` die Bildauswahl gesteuert wird.

Level 4:

![XSS-Level](storage/img/xss-level4.png)

Auf der Website für Level 4 befindet sich ein Timer. Wenn wir uns den Code ansehen sehen wir, dass die Funktion `startTimer` einen Parameter benötigt. Dies sind die Sekunden die wir ins `Create Timer`-Feld eintragen können. Wenn wir dort zum Beispiel 3 eintragen erhalten wir folgende URL:

```
https://xss-game.appspot.com/level4/frame?timer=3
```

Die Seite wartet 3 Sekunden und gibt dann über javascript aus, dass der Timer um ist und kehrt zum Normalzustand zurück. Wenn wir statt der 3 also einen String einfügen sieht das ganze im Script ungefähr so aus: startTimer('irgendein string'). Wir können also unter Zuhilfenahme von single Quotes code einschmuggeln:

```
https://xss-game.appspot.com/level4/frame?timer=');alert('nullday.de
```

Wichtig ist allerdings das wir nur single quotes benutzen und keine double quotes.
Allerdings funktioniert die obere Zeile noch nicht. Verantwortlich dafür ist das Semikolon. Dieses müssen wir erstmal noch in seine Hex-Gestalt umwandeln:

```
https://xss-game.appspot.com/level4/frame?timer=')%3Balert('nullday.de
```

Nun klappt es.

Level 5:

![XSS-Level](storage/img/xss-level5.png)

Level 5 soll einen Link zu einem Registrier-formular darstellen. Auffallend ist die `next` Variable im javascript die via DOM (Document Object Model) in HTML-tags eingebettet ist. Wenn wir also es schaffen die Variable `next` im folgenden Abschnitt zu ändern haben wir es geschafft:

```html
<a href="{{ next }}">Next >></a>
```

Dazu ändern wir einfach den Wert hinter `signup?next=`. Der ganze Link sieht dann so aus:

```
https://xss-game.appspot.com/level5/frame/signup?next=javascript:alert("nullday.de");
```

Level 6:

![XSS-Level](storage/img/xss-level6.png)

Level 6 lädt eine externe Javascript-Datei. 

```
https://xss-game.appspot.com/level6/frame#/static/gadget.js
```

Den Pfad zu der Datei finden wir hinter dem `frame#`. Wir können also ganz einfach von einer URL code nachladen oder sogar direkt injezieren. Zum Code-Nachladen via URL müssen wir allerdings darauf achten, dass wir den `http://`-Abschnitt in der URL etwas obfuscaten, weil genau darauf im javascript geprüft wird. Dafür ist diese Zeile hier verantwortlich:

```javascript
if (url.match(/^https?:\/\//)) {
```

Allerdings ist ein Fehler im Regex. Es werden nur kleine Buchstaben gematched. Wenn wir also statt `https://` einfach `hTTPs://` schreiben oder `hTpS://` können wir eine URL übergeben.
Aber auch dies sehe ich als unnötig an. Stattdessen können wir direkt Code injezieren ohne eine externe Seite zu benutzen. Dazu benutzen wir einfach `data:text/plain`. Damit könnnen wir den javascript-code direkt einschleuse:

```
https://xss-game.appspot.com/level6/frame#data:text/plain,alert("nullday.de");
```

