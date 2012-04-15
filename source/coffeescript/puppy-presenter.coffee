# puppy-presenter client-side namespace
class Puppy
  constructor: (@element) ->
    @element = $(@element) #jQuerify
    @origin = @element.position()

    @imagePaths =
      thumb: @element.data "thumb"
      medium: @element.data "medium"
      full: @element.data "full"

    @thumbImg = @element.find("img")
    @mediumImg = $("<img>")
    @fullImg = $("<img>")

    @currentImage = @thumbImg

    # grant full layout control
    @element.css {position: "absolute"}

    # wire up events
    @element.click (event) =>
      event.preventDefault()
      Presenter.deactivateAllBut(this)
      switch @currentImage
        when @thumbImg then @toMedium()
        when @mediumImg then @toFull()
        when @fullImg then @toThumb()

  swap: (outgoing, incoming) ->
    incoming.css
      left: outgoing.position().left
      top: outgoing.position().left
      width: outgoing.width()
      height: outgoing.height()
    outgoing.replaceWith incoming
    @currentImage = incoming

  # adjust position to compensate for being scaled
  compensateFor: (dimensions) ->
    offsets = {}
    {left, top} = @element.position()

    rightEdge = Presenter.container.width()
    rightOverflow = left + dimensions.width - rightEdge
    if rightOverflow > 0
      offsets.left = left - rightOverflow + Presenter.thumbMargin

    bottomEdge = Presenter.container.height()
    bottomOverflow = top + dimensions.height - bottomEdge
    if bottomOverflow > 0
      offsets.top = top - bottomOverflow + Presenter.thumbMargin

    @element.animate offsets

  toMedium: ->
    if @mediumImg.attr("src")?
      @swap @currentImage, @mediumImg
    else
      @mediumImg.one "load", =>
        @swap @currentImage, @mediumImg

    # bring to front and size to new dimensions
    @element.css("z-index", Presenter.surface()).find("img").animate(
      Presenter.medium
      complete: =>
        @mediumImg.attr("src", @imagePaths.medium) unless @mediumImg.attr("src")?
    )

    @compensateFor Presenter.medium

  toFull: ->
    if @fullImg.attr("src")?
      @swap @currentImage, @fullImg
    else
      @fullImg.one "load", =>
        @swap @currentImage, @fullImg

    # bring to front and size to new dimensions
    @element.css("z-index", Presenter.surface()).find("img").animate(
      Presenter.full
      complete: =>
        @fullImg.attr("src", @imagePaths.full) unless @fullImg.attr("src")?
    )

    @compensateFor Presenter.full

  toThumb: ->
    unless @currentImage is @thumbImg
      # reduce image to thumb
      @swap @currentImage, @thumbImg

      @element.find("img").animate(
        Presenter.thumb
        complete: =>
          @element.css("z-index", 0)
      )

      @element.animate @origin

this.Presenter =
  puppies: null
  container: null

  columns: 4

  # apply CSS directly
  thumb:
    width: 150
    height: 150
  medium:
    width: 306
    height: 306
  full:
    width: 618 # 6 more than actual image size
    height: 618 # 6 more than actual image size

  thumbMargin: 6
  _surface: 1 # z-index which puts element on top

  # returns the next highest z-index available
  surface: ->
    return Presenter._surface += 1

  init: (puppies, container) ->
    Presenter.container = container
    # map to jQuerified objects
    Presenter.puppies = (new Puppy(puppy) for puppy in puppies)
    Presenter.reflow()

  reflow: ->
    layoutFunction = Presenter.layoutFunction()
    layoutFunction puppy for puppy in Presenter.puppies

  layoutFunction: ->
    row = 0
    column = 0

    # assume equal puppy thumbnail dimensions
    (puppy) ->
      # begin a new column if adding a puppy would overflow
      if column >= Presenter.columns
        row += 1
        column = 0

      # apply new position and update origin point
      puppy.element.css
        left: column * (Presenter.thumb.width + Presenter.thumbMargin)
        top: row * (Presenter.thumb.height + Presenter.thumbMargin)

      puppy.origin = puppy.element.position()

      # advance to next column
      column += 1

  deactivateAllBut: (exception) ->
    console.log "Deactivating all puppies but #{exception}"
    puppy.toThumb() for puppy in Presenter.puppies when puppy isnt exception
