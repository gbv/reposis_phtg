
$(document).ready(function() {

  // spam protection for mails
  $('span.madress').each(function(i) {
      var text = $(this).text();
      var address = text.replace(" [at] ", "@");
      $(this).after('<a href="mailto:'+address+'">'+ address +'</a>')
      $(this).remove();
  });

  // activate empty search on start page
  $("#project-searchMainPage").submit(function (evt) {
    $(this).find(":input").filter(function () {
          return !this.value;
      }).attr("disabled", true);
    return true;
  });

  // replace placeholder USERNAME with username
  var userID = $("#currentUser strong").html();
  var newHref = 'https://reposis-test.gbv.de/PROJECT/servlets/solr/select?q=createdby:' + userID + '&fq=objectType:mods';
  $("a[href='https://reposis-test.gbv.de/PROJECT/servlets/solr/select?q=createdby:USERNAME']").attr('href', newHref);

  // unhide person extended box at reload
  $('.personExtended-container').removeClass('d-none');
  $('.mir-fieldset-legend').removeClass('hiddenDetail');
  $('.mir-fieldset-expand-item').removeClass('fa-chevron-down');
  $('.mir-fieldset-expand-item').addClass('fa-chevron-up');

});

$( document ).ajaxComplete(function() {
  // change default selection of host to journal from publish/index.xml
  if($("select#host option[value='journal']").length > 0){
    $("select#host option[value='standalone']").removeAttr("selected");
    $("select#host option[value='journal']").attr("selected", "selected");
  };

});