---
title: "Automated Website Testing with Selenium"
date: 2021-06-18T01:50:14+02:00
draft: false
description:
tags:
 - linux
 - devops
---

Today's blog article is a more unusual one. If you know me in person you would not connect me to web development,
but yet here we are. So, how do I got here? One student at my university has asked me if I could help and have a look on their code.
He was working on unit tests with Selenium on a very beginner friendly level. This is how I got more interested in this
topic.

As usual, first a few questions:

* What is automated website testing?
* What is Selenium?
* Why do I need all of this?

If you or your company works with websites you usually find yourself in the same situation over and over again.
You work on a new feature, you push it and ... you hope that nothing breaks. Most cases can be catched via
traditional unit testing on the code layer, but sometimes you want end-to-end tests. End-to-end means
in this context that you test the actual behavior of the website. You takeover the role of the customer
or visitor and you verify that everything works as expected. This work can be toilsome and tedious, because
if you do many websites or if you have a fast development cycle you will find yourself over and over in the situation
that you need to test the website manually. Automated website testing tries to solve this problem and Selenium
is the biggest library (correct me I am wrong) that helps achieving this goal.

With Selenium you can simulate everything:

* Different browser versions
* Different operating system versions
* Different browsers (Firefox, Chrome, ...)
* You can even do things that have nothing to do with testing (automating website visits or pentesting for example)

If I recall correctly, you can even insert some chaos and/or performance glitches.

I do not want to talk too much so let us dive directly into some code. All code can be found at [https://github.com/shibumi/selenium-demo/](https://github.com/shibumi/selenium-demo/).

First, you need a webdriver. The most common webdrivers are the geckodriver (by Mozilla/Firefox) and the chromedriver (by Google).
For the next code snippets you need to have have the webdriver in your PATH (I recommend using the geckodriver, because it is in the Arch Linux repositories).

Our first example is really easy one. We will just connect to a website and get its title. The title is being displayed in the browser tab.
The following code consists of everything what you need for your first selenium experience. I use the unittest library here, because I am used to it, but
of course you can just call your own functions. However, the unittest library has a few advantages. Every function that start with a `test` will get executed automatically.
In my example the function `test_title` is expecting a string and compares it to the title in the variable `self.browser.title`. On success we return True on failure we return
False. Executing this example gives us nice output via the unittest library (so much about its advantages).

```python
import unittest
from selenium import webdriver

class TestMain(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.browser = webdriver.Firefox()
        cls.browser.get("https://shibumi.dev")

    @classmethod
    def tearDownClass(cls):
        cls.browser.quit()

    def test_title(self):
        expected = "Christian Rebischke"
        if self.browser.title != expected:
            print("invalid title got {}, but want {}".format(self.browser.title, expected))
            return False
        return True

if __name__ == "__main__":
    unittest.main()
```

But what about the other two methods? The other two methods are class methods in the context of the unittest library. We cannot utilize the `__init__` method
for initializing the class TestMain at this point, because it is already being used internally by the library (well, we could overwrite.. but this would get ugly).
Hence, we are defining two class methods in the context of TestMain (recognizable by the `@classmethod` attribute and the `cls` argument). These two methods
take care of setting up and tearing down our test environment. The methods `setUpClass` and `tearDownClass` get executed exactly **once**, even if we have more than one test.
Using these two methods gives us the possibility to create a test environment. In this example we define our webdriver (firefox) and do a first website call via the
HTTP method **GET**. In our first test `test_title` we just compare the title. The `tearDownClass` method closes the browser. Why closing? If you execute this snippet
you will see how firefox calls my blog. The last two lines just start the test routine.

So what about a more complicated example. Our next example will utilize a demo website by Sauce Labs [https://saucedemo.com](https://saucedemo.com).
If you have a closer look on it, it does not look that different. In `setUpClass` we initialize the browser and a few variables (passwords, usernames, valid URLs).
We have four new methods in this code. Two helper methods and two test methods. The helper methods do not need to start with `helper`, I just named them like this, because
I thought it is easier to read. We remember, everything what starts with `test` gets executed. Additionally, we have two new test methods called `test_valid_logins`
and `test_invalid_logins`. Both methods make use of the helper methods for the login and logout. In these four methods we see seleniums full potential.
We can directly refer to elements in the website's HTML code and we can submit actions on that website (sending keys or clicking a button).
With the first function we select the target and with the chained function we can directly call an action on that item.
For example, if we want to fill out a form that asks for the username and the password, we simply look via the browser's dev tools for the
IDs of these elements. In Chromium this works via ctrl+shift+I for opening the dev tools and ctrl+shift+c for inspecting elements via the mouse.
If you click on those elements in the inspection mode the corresponding element will be highlighted on the right revealing the id.
The same works for CSS classes. Just select the element, for example an error button (like in the `test_invalid_login` method) and use the `find_element_by_css_selector` method
for executing actions on that element.

```python
import unittest
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.select import Select

class TestMain(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.base_url = "https://www.saucedemo.com/"
        cls.browser = webdriver.Firefox()
        cls.browser.get(cls.base_url)
        cls.password = "secret_sauce" # one password for all users
        cls.valid_users = ["standard_user", "problem_user", "performance_glitch_user"]
        cls.invalid_users = ["locked_out_user"]
        cls.valid_url = "/inventory.html"

    @classmethod
    def tearDownClass(cls):
        cls.browser.quit()

    def helper_login(self, user, password):
        self.browser.find_element_by_id('user-name').send_keys(user)
        self.browser.find_element_by_id('password').send_keys(password)
        self.browser.find_element_by_id('login-button').click()

    def helper_logout(self):
        self.browser.find_element_by_id('react-burger-menu-btn').click()
        self.browser.find_element_by_id('logout_sidebar_link').click()

    def test_valid_logins(self):
        for user in self.valid_users:
            self.helper_login(user, self.password)
            if self.valid_url not in self.browser.current_url:
                return False
            self.helper_logout()

    def test_invalid_logins(self):
        for user in self.invalid_users:
            self.helper_login(user, self.password)
            if not self.browser.find_element_by_css_selector('.error-button').is_displayed():
                # if we accidently login logout
                if self.valid_url in self.browser.current_url:
                    self.helper_logout()
                self.browser.get(self.base_url)
                return False
            self.browser.get(self.base_url)

    def test_connection(self):
        expected = "Swag Labs"
        if self.browser.title != expected:
            print("Title is invalid")
            return False
        return True

if __name__ == "__main__":
    unittest.main()
```

This is the blog article for today. It got a little bit longer as expected and I am writing this down at 02:30AM, so forgive me a few grammar or spelling mistakes.
If you find mistakes or even better, you have some cool advice for me regarding Selenium, feel free to drop me an email. I would be happy to hear some tricks.

As Site Reliability Engineer I am not really responsible for website testing, but I consider this topic as helpful in propagating a culture of less toil
and more automation. Site Reliability Engineering itself might be a nice topic for one of my next blog articles. Stay tuned!


