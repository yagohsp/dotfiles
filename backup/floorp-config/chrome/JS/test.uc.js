const sidebar = document.getElementsByClassName("sidebar-browser-stack")[0];
const sidebarBox = document.getElementById("sidebar-box");
const tabBrowser = document.getElementById("tabbrowser-tabbox");
const toolbar = document.getElementById("navigator-toolbox");

sidebarBox.addEventListener("mouseenter", function () {
  sidebar.classList.add("open");
});

tabBrowser.addEventListener("mouseenter", function () {
  sidebar.classList.remove("open");
});
toolbar.addEventListener("mouseenter", function () {
  sidebar.classList.remove("open");
});
