# Extract basic information from a web page and summarize in markdown for use
# in static site generators.
# Open graph information has the highest priority.


# Return content value of meta tag for given property. Use open graph if exists.
meta_property = (name) ->
    element = document.querySelector 'meta[property="og:' + name + '"]'
    if element is null
        element = document.querySelector 'meta[name="' + name + '"]'
    if element and element.content
        return element.content


markdown_property = (name, value) ->
    return name + ': ' + "'" + value + "'"


# title
title = meta_property 'title'
title = document.title unless title


# url and link
url = '/' + title.toLowerCase().replace(/\W+/g, '-') + '/'
link = document.location.href


# description
description = meta_property 'description'


# images
images = []
image = meta_property 'image'
if image
    images.push image


# video
video = meta_property 'video'


# Add all body images that have a source set and a minimum size.
body_images = document.querySelectorAll 'img:not([src=""])'
for i in body_images
    if i.src.match 'https?://' and (i.width * i.height > 40000)
        images.push i.src


# body text for now the content of the paragraphs
paragraphs = []
for p in document.getElementsByTagName 'p'
    if p.textContent
        paragraphs.push p.textContent.trim()


# Create markdown summary compatible with logya.
headers = []
headers.push markdown_property 'title', title
headers.push markdown_property 'url', url
headers.push markdown_property 'link', link

if description
    headers.push markdown_property 'description', description

if images.length > 0
    headers.push markdown_property 'image', images[0]

if video
    headers.push markdown_property 'video', video

# use current date and time for created header
now = new Date()
headers.push markdown_property 'created', now.toISOString()

yaml_header = """
---
CONTENT
template: page.html
---

"""

markdown = yaml_header.replace('CONTENT', headers.join('\n')) + paragraphs.join('\n\n')

ymdps = document.createElement 'div'
ymdps.id = 'ymdps'
ymdps.setAttribute 'style', 'position:relative;padding:20px;border:5px solid #eee;width:80%;margin-left:10%;'

button = document.createElement 'button'
button.setAttribute 'style', 'position:absolute;top:5px;right:5px;cursor:pointer;font-weight:bold;'
button.setAttribute 'onclick', "javascript:document.getElementById('ymdps').remove();"
button.textContent = 'Close preview'

textarea = document.createElement 'textarea'
textarea.setAttribute 'style', 'width:98%;height:600px;margin:1%;'
textarea.textContent = markdown

ymdps.appendChild button
ymdps.appendChild textarea

document.body.insertBefore ymdps, document.body.firstChild
window.scroll 0, 0