const sidebar = document.getElementsByClassName("sidebar-browser-stack")[0];
const sidebarBox = document.getElementById("sidebar-box");

sidebar.addEventListener("dragenter", function () {
  console.log("dragenter");
  sidebar.classList.add("dragging");
});
sidebar.addEventListener("dragend", function () {
  console.log("dragend");
  sidebar.classList.remove("dragging");
});

