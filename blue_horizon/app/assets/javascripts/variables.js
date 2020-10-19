$(function() {
  // Remove map entries
  $("form#new_variable").on("click", ".remove", function() {
    $(this)
      .closest(".input-group")
      .remove();
  });
  // Prevent submitting with Enter key
  $(document).on("keydown", ":input:not(textarea)", function(event) {
    if (event.key == "Enter") {
      event.preventDefault();
    }
  });
  // Show/hide passwords
  $("button.peek").click(function() {
    var group = $(this).closest(".input-group");
    $(this)
      .hide()
      .tooltip("hide");
    group.find("button.unpeek").show();
    group.find("input[type='password'").attr("type", "text");
  });
  $("button.unpeek").click(function() {
    var group = $(this).closest(".input-group");
    $(this)
      .hide()
      .tooltip("hide");
    group.find("button.peek").show();
    group.find("input[type='text'").attr("type", "password");
  });
});
