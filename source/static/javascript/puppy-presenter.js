(function() {
  var Puppy;

  Puppy = (function() {

    function Puppy(element) {
      var _this = this;
      this.element = element;
      this.element = $(this.element);
      this.origin = this.element.position();
      this.imagePaths = {
        thumb: this.element.data("thumb"),
        medium: this.element.data("medium"),
        full: this.element.data("full")
      };
      this.thumbImg = this.element.find("img");
      this.mediumImg = $("<img>");
      this.fullImg = $("<img>");
      this.currentImage = this.thumbImg;
      this.element.css({
        position: "absolute"
      });
      this.element.click(function(event) {
        event.preventDefault();
        switch (_this.currentImage) {
          case _this.thumbImg:
            return _this.toMedium();
          case _this.mediumImg:
            return _this.toFull();
          case _this.fullImg:
            return _this.toThumb();
        }
      });
    }

    Puppy.prototype.swap = function(outgoing, incoming) {
      incoming.css({
        left: outgoing.position().left,
        top: outgoing.position().left,
        width: outgoing.width(),
        height: outgoing.height()
      });
      outgoing.replaceWith(incoming);
      return this.currentImage = incoming;
    };

    Puppy.prototype.compensateFor = function(dimensions) {
      var bottomEdge, bottomOverflow, left, offsets, rightEdge, rightOverflow, top, _ref;
      offsets = {};
      _ref = this.element.position(), left = _ref.left, top = _ref.top;
      rightEdge = Presenter.container.width();
      rightOverflow = left + dimensions.width - rightEdge;
      if (rightOverflow > 0) {
        offsets.left = left - rightOverflow + Presenter.thumbMargin;
      }
      bottomEdge = Presenter.container.height();
      bottomOverflow = top + dimensions.height - bottomEdge;
      if (bottomOverflow > 0) {
        offsets.top = top - bottomOverflow + Presenter.thumbMargin;
      }
      return this.element.animate(offsets);
    };

    Puppy.prototype.toMedium = function() {
      var _this = this;
      if (this.mediumImg.attr("src") != null) {
        this.swap(this.currentImage, this.mediumImg);
      } else {
        this.mediumImg.one("load", function() {
          return _this.swap(_this.currentImage, _this.mediumImg);
        });
      }
      this.element.css("z-index", 1000).find("img").animate(Presenter.medium, {
        complete: function() {
          if (_this.mediumImg.attr("src") == null) {
            return _this.mediumImg.attr("src", _this.imagePaths.medium);
          }
        }
      });
      return this.compensateFor(Presenter.medium);
    };

    Puppy.prototype.toFull = function() {
      var _this = this;
      if (this.fullImg.attr("src") != null) {
        this.swap(this.currentImage, this.fullImg);
      } else {
        this.fullImg.one("load", function() {
          return _this.swap(_this.currentImage, _this.fullImg);
        });
      }
      this.element.css("z-index", 1000).find("img").animate(Presenter.full, {
        complete: function() {
          if (_this.fullImg.attr("src") == null) {
            return _this.fullImg.attr("src", _this.imagePaths.full);
          }
        }
      });
      return this.compensateFor(Presenter.full);
    };

    Puppy.prototype.toThumb = function() {
      var _this = this;
      this.swap(this.currentImage, this.thumbImg);
      this.element.find("img").animate(Presenter.thumb, {
        complete: function() {
          return _this.element.css("z-index", 0);
        }
      });
      return this.element.animate(this.origin);
    };

    return Puppy;

  })();

  this.Presenter = {
    puppies: null,
    container: null,
    columns: 4,
    thumb: {
      width: 150,
      height: 150
    },
    medium: {
      width: 306,
      height: 306
    },
    full: {
      width: 618,
      height: 618
    },
    thumbMargin: 6,
    init: function(puppies, container) {
      var puppy;
      Presenter.container = container;
      Presenter.puppies = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = puppies.length; _i < _len; _i++) {
          puppy = puppies[_i];
          _results.push(new Puppy(puppy));
        }
        return _results;
      })();
      return Presenter.reflow();
    },
    reflow: function() {
      var layoutFunction, puppy, _i, _len, _ref, _results;
      layoutFunction = Presenter.layoutFunction();
      _ref = Presenter.puppies;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        puppy = _ref[_i];
        _results.push(layoutFunction(puppy));
      }
      return _results;
    },
    layoutFunction: function() {
      var column, row;
      row = 0;
      column = 0;
      return function(puppy) {
        if (column >= Presenter.columns) {
          row += 1;
          column = 0;
        }
        puppy.element.css({
          left: column * (Presenter.thumb.width + Presenter.thumbMargin),
          top: row * (Presenter.thumb.height + Presenter.thumbMargin)
        });
        puppy.origin = puppy.element.position();
        return column += 1;
      };
    }
  };

}).call(this);
