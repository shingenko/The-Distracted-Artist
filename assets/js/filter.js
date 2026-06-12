/**
 * Tag filtering for the comic grid on the homepage.
 * Click a tag pill → hide cards that don't have that tag.
 * Click the active tag again → show all.
 */
(function () {
  var tagBar = document.querySelector(".js-tag-bar");
  var cards = document.querySelectorAll(".comic-card");
  if (!tagBar || !cards.length) return;

  var tags = tagBar.querySelectorAll(".tag");
  var activeTag = null;

  // Check if there's a hash on load
  var hash = window.location.hash.slice(1);
  if (hash) {
    var match = tagBar.querySelector('[data-tag="' + hash + '"]');
    if (match) activateTag(match, /* updateHash */ false);
  }

  tags.forEach(function (tag) {
    tag.addEventListener("click", function () {
      if (activeTag === tag) {
        deactivateTag();
      } else {
        activateTag(tag, true);
      }
    });
  });

  function activateTag(tag, updateHash) {
    if (activeTag) activeTag.classList.remove("active");
    tag.classList.add("active");
    activeTag = tag;

    var slug = tag.getAttribute("data-tag");
    if (updateHash && history.replaceState) {
      history.replaceState(null, "", "#" + slug);
    }

    cards.forEach(function (card) {
      var cardTags = card.getAttribute("data-tags") || "";
      if (cardTags.split(",").indexOf(slug) === -1) {
        card.classList.add("hidden");
      } else {
        card.classList.remove("hidden");
      }
    });
  }

  function deactivateTag() {
    if (activeTag) activeTag.classList.remove("active");
    activeTag = null;
    if (history.replaceState) {
      history.replaceState(null, "", window.location.pathname);
    }
    cards.forEach(function (card) {
      card.classList.remove("hidden");
    });
  }
})();
