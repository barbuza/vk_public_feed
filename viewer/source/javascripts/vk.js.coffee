#= require "domready"

current_page = 1
first_run = yes
comment_tags = []

Array::shuffle = ->
  ary = []
  clone = @slice 0
  while clone.length
    ary.push clone.pop Math.round(Math.random() * clone.length)
  ary

$ = (id) -> document.getElementById id

delay = (val, fn) -> setTimeout fn, val

child = (tag, cls) -> tag.getElementsByClassName(cls)[0]

el = (name, props) ->
  tag = document.createElement name
  tag.setAttribute key, value for key, value of props
  return tag

set_text = (tag, text) ->
  while tag.firstChild
    tag.removeChild tag.firstChild
  tag.appendChild document.createTextNode text
  null

move = (tag, to) ->
  top = parseInt tag.offsetTop
  if top != to
    delay 20, ->
      dir = if to > top then 1 else -1
      distance = Math.ceil Math.abs (to - top) / 4
      distance = if distance > 5 then 5 else distance
      tag.style.top = top + dir * distance + "px"
      move tag, to

update_comment = (comment, data, invert=false) ->
  set_text (child comment, "text"), data.text
  set_text (child comment, "username"), data.username
  comment.setAttribute "class", if invert then "invert" else ""
  delay 0, ->
    if comment.offsetTop > 512
      row = 3
    else if comment.offsetTop > 256
      row = 2
    else
      row = 1
    y = (row - 1) * 256 + 10 + Math.floor(Math.random() * (236 - comment.offsetHeight))
    move comment, y
  null

load_json = (url, cb) ->
  xmlhttp = new XMLHttpRequest
  xmlhttp.open "GET", url, no
  xmlhttp.onreadystatechange = ->
    cb eval xmlhttp.responseText if xmlhttp.readyState is 4 and xmlhttp.status is 200
  xmlhttp.send()
  null

load_page = (page) ->
  load_json "/pages/#{page}.json", (comments) ->
    if first_run
      first_run = no
      document.body.removeChild $ "greet"
      for i in [1..9]
        tag = el "div", id: "c#{i}"
        tag.appendChild el "div", class: "text"
        tag.appendChild el "div", class: "username"
        comment_tags.push tag
        update_comment tag, comments[i - 1]
        document.body.appendChild tag
      delay 5000, -> load_page 2
    else
      for c in [0..8]
        do (c) ->
          delay 1500 * c, ->
            update_comment comment_tags[c], comments[c], (Math.random() < 0.3 and c > 2)
      delay 15000, -> load_page if page == 30 then 1 else page + 1
    null

window.ready -> load_page 1
