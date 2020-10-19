$(function() {
  $("#submit-plan")
    .bind("ajax:beforeSend", function() {
      $("code.output").text("");
      $(this).addClass("no-hover");
      $(".eos-icon-loading").show();
      $("a[data-toggle]").tooltip("hide");
      $(".steps-container .btn").addClass("disabled");
      $(".list-group-flush a").addClass("disabled");
    })
    .bind("ajax:success", function(evt) {
      var output = evt.detail[0];

      if (output.error) {
        $("#flash").show();
        $("#error_message").text(output.error.message);
        $("code.output").text(JSON.stringify(output, null, 4));
      } else {
        $("code.output").text(output);
      }
    })
    .bind("ajax:complete", function() {
      $(this).removeClass("no-hover");
      $(".eos-icon-loading").addClass("hide");
      $(".list-group-flush a").removeClass("disabled");
      $(".steps-container .btn").removeClass("disabled");
      $('a[data-original-title="Next steps"]').addClass("disabled");
    });

  $("#flash .close").click(function() {
    $("#flash").hide();
  });
});
