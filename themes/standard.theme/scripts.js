let baseLineHeight = 28;

let lastId;
let cur = [];
let navScrollTimeout;

function setCurrentNav(setScrollPosition=false) {
  let mainNavLinks = document.querySelectorAll("nav.menu-nav ul li a");

  // Exclude any nav links that are hidden.
  mainNavLinks = Array.from(mainNavLinks).
    filter(link => !link.parentElement.classList.contains('hidden-category') )

  console.log("setCurrentNav: " + setScrollPosition);

  let fromTop = window.scrollY;

  for (let i = 0; i < mainNavLinks.length; i++) {
    let link = mainNavLinks[i];

    let menu =
      document.querySelector(
        "#" + link.getAttribute("data-menu"));

    let positionOfBottomOfMenu = menu.offsetTop + menu.offsetHeight;
    if(typeof mainNavLinks[i+i] != 'undefined') {
      let nextMenu = document.querySelector(
        "#" + mainNavLinks[i+1].getAttribute("data-menu"));
      positionOfBottomOfMenu = nextMenu.offsetTop - 4 * baseLineHeight;
    }

    if (
      (menu.offsetTop - 4 * baseLineHeight) <= fromTop &&
      positionOfBottomOfMenu > fromTop
    ) {

      if(!link.classList.contains("current")) {
        console.log("moving cursor");
        link.classList.add("current");

        if(navScrollTimeout) {
          console.log("clearing");
          clearTimeout(navScrollTimeout);
          navScrollTimeout = null;
        }
        console.log("setting");
        navScrollTimeout =
          setTimeout(() => {
              setCurrentNav(true);
            }, 1000);
      }

      if(setScrollPosition) {
        let nav = link.parentNode.parentNode.parentNode;
        console.log("Scrolling to: " + (link.parentNode.offsetLeft - nav.offsetLeft- 28));
        if(window.innerWidth >= 768) {
          nav.scrollTo({
            top: link.parentNode.offsetTop - nav.offsetTop - 28,
            left: 0,
            behavior: 'smooth'
          });
        } else {
          nav.scrollTo({
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

/* Do it when... */
window.addEventListener("scroll", event => {
  setCurrentNav();
});

/* Do it now. */
setCurrentNav();

/* Set height of menu list for wide screens so that it can scroll. */
var elements = document.getElementsByClassName('menu-nav');
var windowheight = window.innerHeight + "px";

fullheight(elements);
function fullheight(elements) {
  /* This 1024 must match the breakpoint in the CSS for going
     from a top nav to a side nav. */
  if(window.innerWidth >= 768) {
    for(let el in elements){
      if(elements.hasOwnProperty(el)){
        elements[el].style.height = windowheight;
      }
    }
  } else {
    for(let el in elements){
      if(elements.hasOwnProperty(el)){
        elements[el].style.height = null;
      }
    }
  }
}

/* Do it when. */
window.onresize = function(event){
  fullheight(elements);
  reorientCategories();
}

/* Do it now. */
fullheight(elements);

/* Push the scroll position to the right if the user's
   preferred language is Arabic (a right-to-left language)
   and if the viewport is narrow enough to be showing the
   horizontally-scrolling navigation. */
if (/^ar\b/.test(navigator.language)) {
  let mainSections = document.querySelectorAll(".menus .menu");
  menusArray = Array.prototype.slice.call(mainSections)
  let firstRTLMenu = menusArray.find(element => element.classList.contains('rtl'));
  console.log('first RTL menu: ' + firstRTLMenu)
  if(typeof firstRTLMenu != 'undefined') {
    console.log('Scrolling to first RTL menu at: ' + firstRTLMenu.offsetTop)
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
let elementsArray = document.querySelectorAll("nav.category-nav ul li");
elementsArray.forEach(function(link) {
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

function showCurrentCategory(category) {
  let listItems =
    Array.from(document.querySelectorAll("nav.menu-nav .menus li")).concat(
    Array.from(document.querySelectorAll(".menus .menu")));
  listItems.forEach(function(menu) {
    console.log('category: ' + menu.getAttribute("data-category") + ', innerText: ' + category)
    if(menu.getAttribute("data-category") == category ||
       typeof(category) == 'undefined') {
      menu.classList.remove("hidden-category");
    } else {
      menu.classList.add("hidden-category");
    }
  });
  setCurrentNav();
}

function reorientCategories() {
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
reorientCategories();

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
