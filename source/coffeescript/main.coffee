# main script for puppy-presenter; requires puppy-presenter.js
$ ->
  console.log "Generating puppy list"
  Presenter.init $("div.puppy"), $("#content")
