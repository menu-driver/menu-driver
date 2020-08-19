let mainNavLinks = document.querySelectorAll("nav ul li a");
let mainSections = document.querySelectorAll(".menus .menu");

let lastId;
let cur = [];
let navScrollTimeout;

function setCurrentNav(setScrollPosition=false) {
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
      positionOfBottomOfMenu = nextMenu.offsetTop;
    }

    if (
      menu.offsetTop <= fromTop &&
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
            }, 500);
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
}

/* Do it now. */
fullheight(elements);

/* Push the scroll position to the right if the user's
   preferred language is Arabic (a right-to-left language)
   and if the viewport is narrow enough to be showing the
   horizontally-scrolling navigation. */
if (/^ar\b/.test(navigator.language)) {
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