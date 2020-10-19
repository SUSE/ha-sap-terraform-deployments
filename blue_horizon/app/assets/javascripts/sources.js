// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function editor_for_form_field(editor_id, form_field_id) {
  var editor;
  // CSS ids usually start with '#', but Ace doesn't like that
  if (editor_id.charAt(0) === "#") {
    editor = ace.edit(editor_id.substr(1));
  } else {
    editor = ace.edit(editor_id);
  }
  var form_field = $(form_field_id);
  // editor style
  editor.setOption("fontSize", "13pt");
  editor.setOption("vScrollBarAlwaysVisible", true);
  //
  $(editor_id).show();
  editor.getSession().on("change", function() {
    form_field.val(editor.getSession().getValue());
  });
  return editor;
}
