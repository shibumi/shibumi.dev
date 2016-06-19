---
layout: page
title: Blog
permalink: /blog/
---

**Posts**

{% for post in site.posts %}
{{ post.date | date: "%b %-d, %Y" }}
[{{ post.title }}]({{ post.url | prepend: site.baseurl }})
{% endfor %}

<p class="rss-subscribe">subscribe <a href="{{ "/feed.xml" | prepend: site.baseurl }}">via RSS</a></p>

