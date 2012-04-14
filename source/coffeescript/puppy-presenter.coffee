# puppy-presenter client-side namespace
this.Presenter =
  puppies: null
  selected: null

  thumbMargin: 6

  # apply CSS directly
  thumb:
    width: 150
    height: 150
  medium:
    width: 306
    height: 306
  full:
    width: 612
    height: 612

  init: (puppies, container) =>
    Presenter.container = container
    # map to jQuerified objects
    Presenter.puppies = ($(puppy) for puppy in puppies)
    # set all puppies to absolute position so we have full layout control
    puppy.css {position: "absolute"} for puppy in Presenter.puppies

    Presenter.reflow()

    maxLeft = Math.max puppy.position().left for puppy in Presenter.puppies
    maxTop = Math.max puppy.position().top for puppy in Presenter.puppies

    swap = (outgoing, incoming) ->
      incoming.css
        left: outgoing.position().left
        top: outgoing.position().left
        width: outgoing.width()
        height: outgoing.height()
      outgoing.replaceWith incoming

    _(Presenter.puppies).each (puppy) ->
      left = puppy.position().left
      top = puppy.position().top
      thumbImg = puppy.find("img")
      mediumImg = $("<img>").one "load", ->
        swap thumbImg, mediumImg

      puppy.toggle(
        (event) ->
          event.preventDefault()

          # enlarge image to medium
          if mediumImg.attr("src")?
            swap thumbImg, mediumImg

          puppy
            .css("z-index", 1000)
            .find("img").animate(
              Presenter.medium
              complete: ->
                mediumImg.attr("src", puppy.data("medium"))
            )

          # move to stay in grid area
          compensation = {}
          if left is maxLeft
            compensation.left =
              left - Presenter.medium.width / 2 - Presenter.thumbMargin / 2
          if top is maxTop
            compensation.top =
              top - Presenter.medium.height / 2 - Presenter.thumbMargin / 2
          puppy.animate compensation

        (event) ->
          event.preventDefault()

          # reduce image to thumb
          swap mediumImg, thumbImg

          puppy
            .find("img").animate(
              Presenter.thumb
              complete: ->
                puppy.css("z-index", 0)
            )

          # move to return to grid order if needed
          compensation = {}
          if left is maxLeft
            compensation.left = left
          if top is maxTop
            compensation.top = top
          puppy.animate compensation
      )

  reflow: ->
    layoutFunction = Presenter.layoutFunction()
    layoutFunction puppy for puppy in Presenter.puppies

  layoutFunction: ->
    row = 1
    column = 1
    maxColumns = 4

    # assume equal puppy thumbnail dimensions
    (puppy) ->
      # begin a new column if adding a puppy would overflow
      if column > maxColumns
        row += 1
        column = 1

      puppy.css
        left: column * (Presenter.thumb.width + Presenter.thumbMargin)
        top: row * (Presenter.thumb.height + Presenter.thumbMargin)
      column += 1
