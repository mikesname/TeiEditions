jQuery(document).ready(function() {

  var $itemTexts = $("#item-texts");
  var $all = $(".tei-entity-data");

  $(".tei-text").on("mouseenter", ".tei-entity", function() {
    var url = $(this).data("ref");
    var $entities = $(".tei-entity-data[data-ref='" + url + "']");
    $all.hide();
    $entities.css({
      position: "fixed",
      left: $itemTexts.offset().left + $itemTexts.width(),
      top: $entities.offset().top
    }).show();
  }).on("mouseleave", ".tei-entity", function() {
    // ?
  });
});