---
title:  "Private Data Mining"
date:   2014-08-18T13:13:13+01:00
draft: false
description: "This article describes how to use whatsapp and facebook for data mining"
toc: false
---

I've got some good news for everybody who dreamed of mining data like the big agencies do. The key to this data is **WhatsApp**. Whatsapp is the leader of mobil instant messaging in Germany. According to the "Netzoekonom" there are 32 million germans who use Whatsapp. This is a dizzying number when you compare it to the 80 million citizens in Germany. Facebook has 27,38 million users in Germany. This is a important fact, because you can query with the help of WhatsApp and Facebook millions of names with phonenumbers and profile-pictures. 

Let me explain how to do this:

You need for this some phonenumbers, some IP-Adresses and [Yowsup](https://github.com/shibumi/yowsup). Yowsup provides an unofficial API for WhatsApp. So you can with Yowsup the same things as with WhatsApp. The difference is: You can automatize this functions. 

In Germany we have different prefix numbers for mobile phone numbers(+49 is the country code for Germany change this to 0 if you are living in Germany):

+49151,+49161,+49171,...

The mobile phonenumber-ranges are from +4915X up to +4917X. After this prefix numbers we have a suffix-number with 7 or 8 digits. With this knowledge we can simple bruteforce the phone numbers and send queries via Yowsup to the WhatsApp server. 
So we can get from the Server the following information:

* Is this phonenumber registered at WhatsApp?
* Is the profil-picture public? In case of 'yes' we can download it.
* Is the Online-Activity public? In case of 'yes' we can query if the user is online or not.
* Is the status public? In case of 'yes' we can query the status.
* Is the profile-name public? In case of 'yes' we can query the name.

Let's summarize this: We can gather thousands of profile-pictures with phonenumbers. But thats not enough. How can we use this information to gather more information? 

We can use Facebook! The Facebook-Messenger asks the user for connecting the phone number with the Facebook-Account. We can use this feature to link phonenumbers to full names, pictures, hobbies, friends, relationships, sexual preference, political preference etc. Facebook provides a login via email and phonenumber. We can use this loginform:

[https://www.facebook.com/login/identify?ctx=login](https://www.facebook.com/login/identify?ctx=login)

Just insert the phonenumber with countrycode without "+" at the beginning and you get the full name with profile picture if the profile is public. With this name we can use google for more information about the person.

![facebook login form](/img/facebook_en.png)

But how can we automatize this query? We can use *curl* to query the login-form. But I haven't tried it. Maybe we must solve solve captcha for more quries. If so we can generate a cookie for this with solving one captcha. We can use this cookie with curl too. 

