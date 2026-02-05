const sidebar = document.getElementsByClassName("sidebar-browser-stack")[0];
const sidebarBox = document.getElementById("sidebar-box");
const tabBrowser = document.getElementById("tabbrowser-tabbox");
const toolbar = document.getElementById("navigator-toolbox");
const browser = document.getElementById("browser");

let mouse_on_left = false;

browser.addEventListener("pointermove", function (e) {
  if (e.clientX < 150) {
    mouse_on_left = true;
  } else {
    mouse_on_left = false;
  }
});

browser.addEventListener("pointerleave", function () {
  if (mouse_on_left) {
    sidebar.classList.add("open");
  }
});

tabBrowser.addEventListener("pointerenter", function () {
  sidebar.classList.remove("open");
});
toolbar.addEventListener("pointerenter", function () {
  sidebar.classList.remove("open");
});
