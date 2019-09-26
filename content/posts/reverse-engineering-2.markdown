---
title:  "Reverse-Engineering mit radare2 - Teil 2"
date:   2015-02-26T13:13:13+01:00
draft: false
toc: false
---

Auf zur zweiten Runde mit dem Crackme. Hier nochmal der Downloadlink:

[http://nullday.de/img/IOLI-crackme.tar.gz](/storage/IOLI-crackme.tar.gz)

Level4
------

Schauen wir uns die binary erstmal an was sie tut:

![level4](/img/crackme-level0x41.png)

Der interessante Teil scheint in der sym.check function zu stehen. Schauen wir
uns diese mal genauer an:

![level4 check](/img/crackme-level0x42.png)

Wenn wir das ganze etwas kommentieren sieht sym.check so aus:

![level4 commented](/img/crackme-level0x43.png)

Wie man erkennen kann ist das entscheidende die Operation bei Offset
`0x080484d6`:`cmp dword [ebp - 8], 0xf`. Dort wird praktisch die Summe der
Eingabe in Dezimalform mit 0xf (dec. 15) verglichen. Wir brauchen also nur eine
Eingabe dessen Quersumme 15 ergibt und wir sind durch:

Nehmen wir also einfach mal die Eingabe: 12345

![level4 ende](/img/crackme-level0x44.png)


Level5
------

Das fünfte Level scheint ähnlich dem Vierten zu sein. Hier ist die
check-Funktion des fünften Levels:

![level5 anfang](/img/crackme-level0x51.png)

Das Erste was mir spontan einfällt ist der veränderte Wert an Offset
`0x0804851a`. Statt einem compare mit 15 machen wir nun einen mit 16.
Desweiteren fällt auf, dass wir danach nicht am Ende sind. Dieses mal scheint
eine Funktion namens `parell` aufgerufen zu werden anstatt nur ein printf.

Schauen wir uns diese Funktion mal an:

![level5 dis](/img/crackme-level0x52.png)

Bei Offset `0x080484a4` wird ein Pointer mit unserer Eingabe nach eax
verschoben. Diese Eingabe wird dann via einem logischen AND mit dem Wert 1
verknüpft. Ist die Eingabe gerade kommt 0 raus, ist die Eingabe ungerade kommt
dabei 1 raus. Dieses Ergebnis wird danach in eax geschrieben. Beim Offset
`0x080484aa` wird dann getestet ob das Ergebnis 1 oder 0 ist. Ist es 1 würde das
Zero Flag (ZF) nicht gesetzt werden und via `jne 0x80484c6` wird ans Ende der
Funktion gesprungen. Ist es 0 wird das Zero Flag gesetzt und printf mit
"Password OK" und exit(0) werden aufgerufen. Was wir also benötigen ist eine
Eingabe die gerade ist **und** dessen Quersumme 16 ergibt. 

Level6
------

Im dritten Level scheint neben der `parell`-Funktion noch eine 3. Funktion
hinzugekommen zu sein. In der `parell`-Funktion finden wir nämlich eine Funktion
namens `dummy`.

![level 6 anfang](/img/crackme-level0x61.png)

Ansonsten scheint sich nichts verändert zu haben. Es wird immer noch auf
Gerade/Ungerade überprüft. Es wurde nur eine weitere Funktion davor geschaltet
die sozusagen den Zugang zum interessanten Teil der `parell`-Funktion überprüft.
Schauen wir uns also mal die `dummy`-Funktion an:

![level6 dummy](/img/crackme-level0x62.png)

Interessant ist Offset `0x080484cb` hier wird scheinbar die erste
ENVIRONMENT-Variable nach `eax` geladen. Bei Offset `0x080484ce` wird `[edx+eax]`
dann mit 0 verglichen. Anscheinend dient das dazu das Ende der Liste der
ENV-Variablen zu ermitteln. Falls das Ende erreicht ist wird direkt ans Ende
gesprungen und 0 an `[ebp-8]` geschrieben. Der Wert aus dieser Position wird
dann wiederum nach `eax` verschoben und die Funktion wird beendet. Der Wert aus
eax wird dann wiederum als Return-Wert zurück gegeben. Wenn die Funktion also 0
zurück gibt würde der anschließende Test in der `parell`-Funktion mit dem Zero
Flag ausfallen und das Program würde beendet werden ohne unseren "Password
OK"-String auszugeben. Was wir natürlich nicht wollen. Also müssen wir versuchen
der Funktion beizubringen, dass sie den Wert 1 zurück gibt. Interessant dafür
ist die Zeile bei Offset `0x080484ee` : `mov dword [esp + 4], str.LOLO`. Hier
wird der String "LOLO" auf eine Position auf den Stack geschoben. Kurze Zeit
danach wird strncmp aufgerufen. Diese Funktion vergleicht zwei Strings
miteinander. Wenn 0/False zurück gegeben wird sind die Strings nicht gleich,
wenn 1/True zurückgegeben wird sind die beiden Strings gleich. Anscheinend
brauchen wir also eine ENV-Variable mit dem Namen "LOLO". Wenn wir diese
Variable setzen **und** einen Wert eingeben der ungerade ist sowie dessen
Quersumme 16 ergibt sind wir durch und haben es geschafft. Aber Moment, nach
unserer Funktion finden noch einige Vergleiche statt:

![level6 vergleiche](/img/crackme-level0x63.png)

das `test eax, eax` und `je 0x8048586` prüft wie oben bereits erwähnt den
Return-Wert der `dummy`-Funktion. Wenn da eine 1 steht können wir passieren.
Aber danach wird eine 0 auf an eine Adresse auf den Stack geladen und diese 0
wird dann verglichen mit 9. Danach wird überprüft ob der Wert 9 größer als 0
ist. Scheint eine Art von unnötigem code zu sein um etwas Verwirrung zu stiften.
Das scheint auch nicht der einzige code mit der Aufgabe zu sein. Denn danach
findet noch ein Test statt. In `mov eax, dword [ebp - 4]` wird unsere Eingabe
geladen und mit 1 AND-verknüpft. Dies scheint der Test auf gerade/ungerade zu
sein. Wenn wir den also wie oben erwähnt passieren sind wir durch.


Die restlichen drei crackmes gibt es dann im nächsten Teil ;-). Happy Hacking.
