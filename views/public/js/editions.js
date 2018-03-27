jQuery(function($) {
  $("#document-text")
      .tabs({
        show: false,
        active: 0,
        activate: function(e, ui) {
          ui.oldTab.find("a")
              .toggleClass("element-text-language-selected element-text-language");
          ui.newTab.find("a")
              .toggleClass("element-text-language-selected element-text-language");
        }
      });

  var $itemTexts = $("#item-texts");
  var $all = $(".tei-entity");

  $(".tei-entity-ref").hoverIntent(function() {
    var url = $(this).data("ref");
    var $entities = $(".content-info-entity[data-ref='" + url + "']");
    $all.hide();
    if ($entities.length > 0) {
      $entities.css({
        position: "fixed",
        left: $itemTexts.offset().left + $itemTexts.width() + 50,
        top: 100,//$entities.offset().top
      }).show();
    } else {
        console.log("No info for", url);
    }
  });
});