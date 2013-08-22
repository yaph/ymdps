# Extract basic information from a web page and summarize in markdown.
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
url = title.toLowerCase().replace(/\W+/g, '-')
link = document.location.href


# description
description = meta_property 'description'


# images
images = []
image = meta_property 'image'
if image
    images.push image


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


# Create markdown summary compatible with jekyll and logya.
headers = []
md_header = '---\nCONTENT\n---\n\n'
headers.push markdown_property 'title', title
headers.push markdown_property 'description', description
headers.push markdown_property 'url', url
headers.push markdown_property 'link', link
if images.length > 0
    headers.push markdown_property 'image', images[0]


html = """
<div id="markdownsummary" style="position:relative;padding:10px;border:5px solid #eee;width:80%;margin-left:10%;">
<button style="position:absolute;top:5px;right:5px;cursor:pointer;font-weight:bold;" onclick="javascript:document.getElementById('markdownsummary').remove();">Close preview</button>
<textarea style="width:98%;height:600px;margin:1%;">MARKDOWN</textarea>
</div>
"""
markdown = md_header.replace('CONTENT', headers.join('\n')) + paragraphs.join('\n\n')
html = html.replace('MARKDOWN', markdown)

div = document.createElement('div')
div.innerHTML = html

document.body.insertBefore div, document.body.firstChild