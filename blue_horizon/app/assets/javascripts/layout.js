$(document).ready(function() {
  // enable bootstrap tooltips
  $('[data-toggle="tooltip"]').tooltip();
  // enable bootstrap alert dismissal
  $(".alert").alert();
  // set up sidebar tooltips
  $("#sidebar .list-group-item").tooltip("disable");
  // sidebar menu folding
  $("#sidebarCollapse").on("click", function() {
    $("#sidebar, #content").toggleClass("active");
    $(".collapse.in").toggleClass("in");
    $("a[aria-expanded=true]").attr("aria-expanded", "false");
    $("#sidebar .list-group-item").tooltip("toggleEnabled");
  });
});
