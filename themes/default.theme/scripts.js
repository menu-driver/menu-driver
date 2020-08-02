let mainNavLinks = document.querySelectorAll("nav ul li a");
let mainSections = document.querySelectorAll("menus menu");

let lastId;
let cur = [];
let navScrollTimeout;

function setCurrentNav(setScrollPosition=false) {
  console.log("setCurrentNav: " + setScrollPosition);
  
  let fromTop = window.scrollY;

  mainNavLinks.forEach(link => {
    let menu =
      document.querySelector(
        "#" + link.getAttribute("data-menu"));

    if (
      menu.offsetTop <= fromTop &&
      menu.offsetTop + menu.offsetHeight > fromTop
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
        console.log("SCROLLING!");
        let nav = link.parentNode.parentNode.parentNode;
        console.log("Setting to: " + (link.parentNode.offsetLeft - nav.offsetLeft));
        if(window.innerWidth >= 768) {
          nav.scrollTo({
            top: link.parentNode.offsetTop - nav.offsetTop,
            left: 0,
            behavior: 'smooth'
          });
        } else {
          nav.scrollTo({
            top: 0,
            left: link.parentNode.offsetLeft - nav.offsetLeft,
            behavior: 'smooth'
          });
        }
      }

    } else {
      link.classList.remove("current");
    }
  });
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