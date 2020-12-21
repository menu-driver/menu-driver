let baseLineHeight = 28;

let lastId;
let cur = [];
let navScrollTimeout;

function desktopMode() {
  return window.innerWidth >= 768
}

let categoriesElementsArray = document.querySelectorAll("nav.category-nav ul li");
let locationHasCategories = categoriesElementsArray.length > 0;

// Set the 'current' menu in the nav to reflect the current scroll position.
function setCurrentNav(setScrollPosition=false) {
  // Don't do this for multi-category locations.  The behavior is more
  // app-like for those locations: you can't scroll from one menu to the next.
  // if(!locationHasCategories){ return; }

  let mainNavLinks = document.querySelectorAll("nav.menu-nav ul li a");

  // Exclude any nav links that are hidden,
  // or that link to menus that are hidden.
  mainNavLinks = Array.from(mainNavLinks).
    filter(link => !link.parentElement.classList.contains('hidden') )
  // mainNavLinks = mainNavLinks.filter(link =>
  //   !document.querySelector("#" + link.getAttribute("data-menu")).
  //     classList.contains('hidden') )

  let fromTop = window.scrollY;

  for (let i = 0; i < mainNavLinks.length; i++) {
    let link = mainNavLinks[i];

    let menu =
      document.querySelector(
        "#" + link.getAttribute("data-menu"));

    // Is the menu for this link visible?
    let hidden =
      document.querySelector("#" + link.getAttribute("data-menu")).
        classList.contains('hidden')

    let positionOfBottomOfMenu = menu.offsetTop + menu.offsetHeight;
    // Adjust the bottom position to match the start position of the next
    // menu, if the next menu is visible.
    if(typeof mainNavLinks[i+1] != 'undefined') {
      let nextMenu = document.querySelector(
        "#" + mainNavLinks[i+1].getAttribute("data-menu"));
      if(!nextMenu.classList.contains('hidden')) {
        positionOfBottomOfMenu = nextMenu.offsetTop - (2 * baseLineHeight);
      }
    }
    if (
      !hidden && // No invisible menu should ever be 'current'.
      (menu.offsetTop - 4 * baseLineHeight) <= fromTop &&
      positionOfBottomOfMenu > fromTop
    ) {

      if(!link.classList.contains("current")) {
        link.classList.add("current");

        if(navScrollTimeout) {
          clearTimeout(navScrollTimeout);
          navScrollTimeout = null;
        }
        navScrollTimeout =
          setTimeout(() => {
              setCurrentNav(true);
            }, 1000);
      }

      if(setScrollPosition) {
        let nav = link.parentNode.parentNode.parentNode;
        let scroller = nav.getElementsByTagName('ul')[0]
        if(desktopMode()) {
          scroller.scrollTo({
            top: link.parentNode.offsetTop - nav.offsetTop - 28,
            left: 0,
            behavior: 'smooth'
          });
        } else {
          scroller.scrollTo({
            top: 0,
            left: link.parentNode.offsetLeft - nav.offsetLeft - 28,
            behavior: 'smooth'
          });
        }
      }

    } else {
      link.classList.remove("current");
    }
  }
}

window.addEventListener("scroll", event => {
  setCurrentNav();
});

setCurrentNav();

let previousWidth = window.innerWidth;
window.onresize = function(event){
  if(window.innerWidth != previousWidth) {
    reorientCategories();
    orientScrollThumbs('category-nav')
    orientScrollThumbs('menu-nav')
    previousWidth = window.innerWidth;
  }
}

/* Push the scroll position to the right if the user's
   preferred language is Arabic (a right-to-left language)
   and if the viewport is narrow enough to be showing the
   horizontally-scrolling navigation. */
if (/^ar\b/.test(navigator.language)) {
  console.log("Web browser prefers Arabic.");
  let mainSections = document.querySelectorAll(".menus .menu");
  menusArray = Array.prototype.slice.call(mainSections)
  let firstRTLMenu = menusArray.find(element => element.classList.contains('rtl'));
  if(typeof firstRTLMenu != 'undefined') {
    console.log("Scrolling to first RTL menu at: " + firstRTLMenu.offsetTop)
    let nav = document.querySelectorAll("nav")[0]
    let offset = 84;
    if(window.innerWidth >= 768) {
      offset= 56
    }
    window.scrollTo({
      top: firstRTLMenu.offsetTop + offset,
      left: 0
    });
  }
}

// Categories.
if(locationHasCategories) {
  categoriesElementsArray.forEach(function(link) {
    link.addEventListener('click', function() {
      showCurrentCategory(link.getAttribute("data-category"));

      // Remove 'current' from classes of other category links.
      document.querySelectorAll("nav.category-nav ul li").
        forEach(function(link) {
          link.classList.remove("current")
        });
      link.classList.add("current");
    });
  });

  // Add a class to the entire menu so that styles can target only menus
  // with categories.
  document.getElementById("menu-driver").classList.add('has-categories');
}

function showCurrentCategory(category) {
  let listItems =
    Array.from(document.querySelectorAll("nav.menu-nav .menus li"));
  let didSetCurrentMenu = false;
  listItems.forEach(function(menu) {
    if(menu.getAttribute("data-category") == category ||
       typeof(category) == 'undefined') {
      menu.classList.remove("hidden");

      // Reset the 'current' menu after changing categories.
      let navigationLink = menu.getElementsByTagName('a')[0]
      if(typeof navigationLink !== 'undefined') {

        if(!didSetCurrentMenu &&
          !navigationLink.classList.contains("category_header")) {
          navigationLink.click();
          didSetCurrentMenu = true;
        } else {
          navigationLink.classList.remove("current");
        }
      }
    } else {
      menu.classList.add("hidden");
    }
  });
  setCurrentNav();
  orientScrollThumbs('category-nav')
  orientScrollThumbs('menu-nav')
}

function showCurrentMenu(id) {
  // ONLY hide non-current menus if there is more than one category.
  if(!locationHasCategories){ return; }

  // Show / hide menus.
  let listItems =
    Array.from(document.querySelectorAll(".menus .menu"));
  listItems.forEach(function(menu) {
    if(menu.id == "menu-" + id) {
      menu.classList.remove("hidden");
    } else {
      menu.classList.add("hidden");
    }
  });

  // Set the 'current' menu navigation link.
  let navItems = Array.from(document.querySelectorAll("nav.menu-nav ul li a"))
  navItems.forEach(function(link) {
    if(link.getAttribute("data-menu").substring(5) == id &&
      !link.classList.contains('category_header')) {
      link.classList.add("current")
    } else {
      link.classList.remove("current")
    }
  })
}

function reorientCategories() {
  if(!locationHasCategories) { return; }
  let categoryNav = document.getElementById("category-nav")
  let categoryNavStyles = getComputedStyle(categoryNav, 'display');

  // If the category nav is not visible then show all menus.
  if(categoryNavStyles.getPropertyValue('display') == 'none') {
    // Show all categories.
    showCurrentCategory()

  // If it is visible then make sure that the menus and menu navigation items
  // that are showing reflect the current category selection.
  } else {
    // If there is a 'current' category nav then show / hide the appropriate menus.
    let currentNavs = document.querySelectorAll("nav.category-nav ul li.current");
    // (There should only be one.)
    currentNavs.forEach(function(nav){
      showCurrentCategory(nav.getAttribute("data-category"))
    })
  }
}

function showImage(image_id) {
  console.log("Showing image: " + image_id);

  let imagePanel = document.getElementById("menu-item-image-panel").innerHTML =

'<img class="lg-object lg-image" ' +
'src="https://photos.singleplatform.com/w_640/' + image_id +
'.jpg" sizes="100vw" srcset="https://photos.singleplatform.com/w_320/' + image_id +
'.jpg 320w,https://photos.singleplatform.com/w_640/' + image_id +
'.jpg 640w,https://photos.singleplatform.com/w_1280/' + image_id +
'.jpg 1280w,https://photos.singleplatform.com/w_1920/' + image_id +
'.jpg 1920w,https://photos.singleplatform.com/w_2400/' + image_id +
'.jpg 2400w,https://photos.singleplatform.com/w_4800/' + image_id +
'.jpg 4800w,">';

  document.getElementById("menu-item-image").classList.add('visible');
}

// Feature: Hide image icons on menu.
let searchParams = new URLSearchParams(window.location.search)
let itemImagesParamName = 'item-images'
if(searchParams.has(itemImagesParamName)){
  let itemImages = searchParams.get(itemImagesParamName)
  console.log("URL parameter: item-images: " + itemImages);
  if(itemImages == 'false') {
    console.log("Appending style to hide .item-images-link elements.");
    var style = document.createElement('style');
    style.innerHTML = `
      .item-image-link {
        display: none;
      }
    `;
    document.head.appendChild(style);
  }
}

function scrollNavRight(nav) {
  // Scroll the UL under the specified nav.
  let scroller = document.getElementById(nav).getElementsByTagName('ul')[0]
  scroller.scrollTo({
    top: 0,
    left: scroller.scrollLeft + (scroller.scrollWidth / 2),
    behavior: 'smooth'
  });
}
function scrollNavLeft(nav) {
  // Scroll the UL under the specified nav.
  let scroller = document.getElementById(nav).getElementsByTagName('ul')[0]
  scroller.scrollTo({
    top: 0,
    left: scroller.scrollLeft - (scroller.scrollWidth / 2),
    behavior: 'smooth'
  });
}
// Figure out which of the left / right scroll thumbs should be visible based
// on the current scroll position of the nav, and make the right ones visible.
function orientScrollThumbs(nav) {
  let scroller = document.getElementById(nav).getElementsByTagName('ul')[0]
  let leftButton = document.getElementById(nav).getElementsByClassName('left')[0]
  if(scroller.scrollLeft > baseLineHeight) {
    leftButton.style.display = 'flex'
  } else {
    leftButton.style.display = 'none'
  }
  let rightButton = document.getElementById(nav).getElementsByClassName('right')[0]
  if(scroller.scrollLeft < (scroller.scrollWidth - scroller.clientWidth)) {
    rightButton.style.display = 'flex'
  } else {
    rightButton.style.display = 'none'
  }
}
if(locationHasCategories){ orientScrollThumbs('category-nav') }
orientScrollThumbs('menu-nav')

// Click the default 'current' menu to trigger the onclick that will
// hide the other menus, only for multiple-category locations shown through
// mobile viewports.
if(location.hash !== undefined && location.hash.length > 1) {
  showCurrentMenu(location.hash.substring(2))
} else {
  // Show the one that was marked 'current' by default in the HTML.
  showCurrentMenu(
    document.querySelectorAll("nav.menu-nav a.current")[0].
      getAttribute('data-menu').substring(5))
}

$(document).ready(function(){
  $('#nav-icon').click(function(){
    $(this).toggleClass('open');
    $('.nav-overlay').toggleClass('show');
  });
});
