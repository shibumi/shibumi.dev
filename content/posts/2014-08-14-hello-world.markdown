---
title:  "Hello World"
date:   2014-08-14T13:13:13+01:00
draft: false
toc: false
images:
tags:
  - untagged
---

Hey, schön das du da bist. Dies ist mein erster Blog-Eintrag. Ich habe lange Zeit darüber nachgedacht was ich in meinem ersten Blog-Eintrag schreibe. Nach viel hin und her kam ich also dann zu dem Schluss, dass ich doch einfach mit einem kleinen Spiel anfangen könnte. Das Spiel nennt sich `SmashTheStack`. Du kannst gerne mit spielen du findest das Spiel hier:  

[http://io.smashthestack.org/](http://io.smashthestack.org/)

Wie du sicher an der Subdomain bemerkt hast widmen wir uns dem Server `io`. Also dann loggen wir uns doch mal ein:  

`ssh io.smashthestack.org -l level1`

Das Passwort lautet wie wir der Seite entnehmen können: `level1`. Als nächstes manövrieren wir uns in das `levels`-Verzeichnis.

`cd /levels/`

Dort angekommen finden wir auch schon unsere erste Aufgabe. Wir sollen ein Programm namens `level01` knacken. Das Programm liegt als ELF-Binärdatei (Executive and Linked Format) vor. Das ist die Standard-Binärdatei unter den meisten auf UNIX basierten Systemen. Dies ist aber nicht weiter von Bedeutung im Augenblick.  
Führen wir das Programm doch mal aus:  

`./level01`

Was wir nun als Ausgabe sehen ist eine einfache Eingabeaufforderung:  

`Enter the 3 digit passcode to enter:`  

Unsere Aufgabe ist es also einen 3-stelligen Zahlencode zu erraten. Nun das können wir auf drei Möglichkeiten machen:  

1. Wir erraten die Zahl einfach. Das wären bei 3 stelligen Zahlen im uns bekannten Zehnersystem 10^3 Möglichkeiten. De facto also 1000 verschiedene Kombinationen. Auf sowas hätte ich natürlich keine Lust

2. Wir erraten die Zahl. Moment! Das steht doch schon bei Erstens. Ja. Das ist richtig. Der Unterschied ist aber das wir in Möglichkeit 2 nicht selbst raten. Stattdessen lassen wir den Computer für uns raten. Wir machen uns dabei zu Nutze, dass das `level01` Programm keine Ausgabe ausspuckt aber wir eine Ausgabe vermuten. Dazu habe ich folgendes script geschrieben:  

```bash
#!/bin/bash

list=$( echo {0..9}{0..9}{0..9} )
re=': [A-Za-z0-9]'

for n in $list
  do  
  output=$(echo $n | /levels/level01)
  if [[ $output =~ $re ]]
  then
    echo $n
    exit 
  fi  
done
```

Das script testet alle Zahlen durch und wenn das `level01` Programm etwas ausgibt stoppt es und nennt mir die Zahl, bei der gestoppt worden ist.  

Damit hätten wir Level1 bereits gelöst. Aber diese Variante ist äußerst unschön, weil viele Faktoren außen vor gelassen werden. Was ist zum Beispiel wenn das Programm nichts ausgeben würde wenn die richtige Zahl getroffen wird? Was ist wenn die Kombinationsmöglichkeiten der Zahlen weit aus höher sind? Hier waren es nur 3 Stellen. Aber was machen wir bei 300 Stellen?
All diese Faktoren sind in unserem script nicht berücksichtigt. Deshalb kommen wir zu Möglichkeit 3.

Wir debuggen das Programm. Dafür starten wir `gdb` den standard debugger auf Linux und disassemblieren die `main`-Funktion. Die `main`-Funktion ist bei C-Programmen sowas wie der Einstiegspunkt. Jedes C-Programm hat eine `main`-Funktion:  

![Bild des disassemblierten Programms](storage/img/level01.png) 

Gehen wir den disassemblierten Code mal Schritt für Schritt durch. Fangen wir mit der ersten Zeile an:  

`0x08048080 <+0>: push   $0x8049128`

Hier wird ein Zeiger auf die Adresse 0x8049128 auf den Stack gepushed. An der Adresse 0x8049128 finden wir die visuelle Ausgabe des Programms. Unter anderem den String von oben.  

`0x08048085 <+5>: call   0x804810f <puts>`

Mit `call` wird die Funktion `puts` aufgerufen. Der vorher auf den Stack gepushte Zeiger dient dabei als Argument fü die Funktion `puts`, welche dann den String an der Adresse auf die der Zeiger zeigt ausgibt.

`0x0804808a <+10>:  call   0x804809f <fscanf>`

Hier wird wieder eine Funktion aufgerufen. Diesesmal ist es `fscanf`. `fscanf` dient dazu unsere Eingabe entgegenzunehmen. 

`0x0804808f <+15>:  cmp    $0x10f,%eax`

Mit `cmp` ( von Englisch: compare ) werden zwei Werte verglichen. In diesem Fall der Hexwert `0x10F` mit dem Wert im Akkumulatorregister `eax`. Daraus schließen wir, dass `fscanf` die Eingabe in `eax` gespeichert hat und die Eingabe nun mit einem festen Wert verglichen wird. 

`0x08048094 <+20>:  je     0x80480dc <YouWin>`

Anhand der Instruction `je` wissen wir das auf Gleichheit geprüft wird. `je` heißt soviel wie `jump if equal`. Wenn die Werte also gleich sind die zuvor verglichen wurden springt das Programm an die Funktion `YouWin`.

`0x0804809a <+26>:  call   0x8048103 <exit>`

In dieser Zeile wird die Funkion `exit` aufgerufen, welche das Programm beendet.

Nun haben wir das Programm vollständig disassembliert und können mit Sicherheit sagen, dass die gesuchte dreistellige Zahl, die Zahl `0x10F` ist. Wenn wir `0x10F` umrechnen erhalten wir die Dezimalzahl 271. Damit haben wir die Lösung gefunden. Und das erste Level gelöst.
Den Schlüssel für das nächste Level finden wir unter:

`/home/level2/.pass`
