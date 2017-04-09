---
layout: post
title:  "Private Data Mining"
date:   2014-08-18 13:13:13
categories: IT-Sec
---

Ich habe erfreuliche Nachrichten für alle die schonmal davon geträumt haben im großen Stil Data Mining zu betreiben. Wir leben im Zeitalter des Post-Privacy. Facebook, Whatsapp, Google, Amazon,.. Jeder Mensch hinterlässt im Internet einen unverwechselbaren Fingerabdruck. Den Wenigsten ist überhaupt bewusst wie einfach man an ihre Daten kommt und was für Schaden man damit anrichten kann. Im Folgenden möchte ich auf die technischen Möglichkeiten eingehen im großen Stil Telefonnummern + Namen + Adressen + Hobbys + privates Umfeld zu sammeln. 

Der Schlüssel zu diesen Datensätzen ist: **Whatsapp**

Whatsapp ist Marktführer für mobiles Instant Messaging in Deutschland. Wenn man dem [Netzoekonom](http://netzoekonom.de/2014/04/12/whatsapp-jetzt-bei-32-mio-nutzer-in-deutschland/) glauben schenkt nutzen 32 Millionen Nutzer in Deutschland Whatsapp. Bei circa 80 Millionen Einwohnern ist dies eine unglaubliche Zahl. Damit wäre die Zahl sogar höher als die der aktiven Facebook-Nutzer. Laut [statista.com](http://de.statista.com/statistik/daten/studie/70189/umfrage/nutzer-von-facebook-in-deutschland-seit-2009/) sind es 27,38 Nutzer. Ich gehe stark davon aus, dass die meisten Whatsapp-Nutzer auch Facebook-Nutzer sind. Diese Annahme ist wichtig für den späteren Verlauf meines Textes. Nun aber zu den technischen Details:

Es existieren seit Monaten inoffizielle Whatsapp APIs im Netz. Die weitverbreiteste davon ist [Yowsup](https://github.com/shibumi/yowsup). Ich habe Yowsup geforked und zum Beispiel das runterladen von Profilbildern etwas vereinfacht. Unter Zuhilfenahme von Yowsup hat man alle Möglichkeiten wie mit der offiziellen Whatsapp Application. Der Vorteil ist allerdings, dass man mit Yowsup die meisten Vorgänge automatisieren kann. So können wir gezielt ganze Rufnummer-ranges durchscannen und testen welche Nummer Whatsapp nutzt und welche nicht. Dazu einfach uns bekannte Rufnummer-Vorwahlen von mobilen Telefonen nehmen und den Rest bruteforcen. Wenn die Nummer Whatsapp nutzt kommt man auch mit Leichtigkeit an das Profilbild, den Statustext, die Zeit wann die Nummer das letzte Mal online war. Das Profilbild  kann man allerdings in den Datenschutz-Funktionen der App nur für Freunde sichtbar schalten, die Online-Zeit kann man komplett ausschalten und wie es mit dem Status aussieht weiß ich nicht genau. Aber das Kernproblem ist, dass alle 3 Funktionen standardmäßig aktiviert und frei sichtbar für alle sind. Es ist also mit etwas Zeit und der nötigen technischen Expertise möglich alle 32 Millionen Telefonnummern, die Whatsapp nutzen, herauszufinden und samt Profilbild, Status und Online-Zeit abzuspeichern. Es ist ebenso möglich, sofern die Online-Zeit eingeschaltet ist, einen Nutzer für längere Zeit zu überwachen und seine Online-Zeiten zu archivieren. Man könnte somit also gut feststellen wann der Nutzer mal nicht das Handy in seiner Hand hält. Wer mir nicht glaubt, dass dies so einfach ist, der schreibe mir eine Email. Ein Freund hat testweise 50.000 Telefonnummern+Profilbilder gesammelt. Es ist also technisch möglich und auch umsetzbar. Alles was man braucht sind mehrere Telefonnummern, einen Computer und etwas Programmierkenntnisse. Mit diesen Fähigkeiten ausgestattet kann man innerhalb von wenigen Wochen Millionen von Telefonnummern samt Daten abschnorcheln.

Interessant wird diese Entdeckung allerdings in Verbindung mit Facebook. Ich sagte weiter oben, dass ich denke, dass die meisten Facebook-Nutzer auch Whatsapp nutzen und andersherum. Wenn ein Facebook-Nutzer seine Handy-Nummer mit dem Facebook-Profil verknüpft hat, dies haben die meisten Leute die nebenbei noch die mobile App benutzen, kann man anhand der Telefonnummer die bei Whatsapp registriert ist den echten Namen, das private Umfeld und über Google wahrscheinlich noch die Adresse rauskriegen. 

Dies funktioniert in dem man ganz einfach die Passwort-Vergessen Funktion von Facebook benutzt. Man kann sich nämlich seit einigen Monaten bei Facebook auch mit der Telefonnummer einloggen. Wenn man dies mit einer vorher über Yowsup gesammelten Whatsapp-Telefonnummer versucht erhält man nach mehreren Versuchen den Vollen Namen + Profilbild samt der netten Frage ob man wirklich diese Person ist. Man muss allerdings fairerweise sagen, dass diese Funktionen nur verfügbar sind wenn das Profil öffentlich ist. Wenn nicht wird kein Name+Profilbild angezeigt. Standardmäßig ist das Profil jedoch ähnlich wie bei Whatsapp öffentlich.

![invalid facebook auth]({{ sitebase.url }}/img/facebook.png)

Ein [Freund](http://klassikercodes.wordpress.com/) hat mich vorhin auch noch auf eine schnellere Möglichkeit hingewiesen:

Über folgenden Link kommt man zu einem Login-Feld.

[https://www.facebook.com/login/identify?ctx=login](https://www.facebook.com/login/identify?ctx=login)

Wenn man dort die Telefonnummer einträgt kommt man zu folgendem Anmeldeformular. Ebenfalls mit vollen Namen und Profilbild:

![facebook login form]({{ sitebase.url }}/img/facebook2.png)

Anhand dieses vollen Namens hat man dann auch das Facebook-Profil und durch Google noch andere private Daten wie beispielsweise die Adresse. Das man anhand des Facebook-Profils noch mehr Bilder, Freunde, Hobbys, Orte, politische Ausrichtung, Sexuelle Ausrichtung etc bekommt hängt davon ab wie weit die Person die Datenschutzfunktionen von Facebook nutzt. Die meisten tun es leider nicht! Interessant ist dies auch im Zusammenhang mit dem Facebook Messenger, welcher einen praktisch dazu drängt seine Nummer mit dem Facebook-Profil zu verknüpfen. 

Um nochmal alles zusammenzufassen:

Es ist also als Privatmann innerhalb von Wochen, abhängig von der technischen Ausrüstung, möglich wie ein großer Geheimdienst Millionen Telefonnummern + Profilbild + Onlinezeiten + Statustext abzuschnorcheln und diesen Nummern Klarnamen zuzuordnen. Anhand diesen Klarnamen kann dann die Überwachung noch ausgedehnt werden.

Ich bin mir übrigens sicher, dass man auch die Facebook-Abfrage nach den Klarnamen unter Zuhilfenahme der Telefonnummern automatisieren kann. Alles was man braucht ist vielleicht ein kleines Botnet das Captchas lösen kann bzw Facebook-Cookies die einen als Menschen identifizieren. 



