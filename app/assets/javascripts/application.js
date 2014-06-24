// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require bootstrap
//= require jquery.ui.widget
//= require jquery.iframe-transport
//= require jquery.fileupload
//= require cloudinary/jquery.cloudinary
//= require attachinary

jQuery(function() {
  return $('#user_organization_name_box').autocomplete({
    source: $('#user_organization_name_box').data('autocomplete-source')
  });
 });

$(document).ready(function() {
  return $('#user_skills').autocomplete({
    source: $('#user_skills').data('autocomplete-source')
  });
  $('.attachinary-input').attachinary()
});


$(document).ready(function() {
  $('.navbar-toggle').on('click', function() {
    if($('.navbar-collapse').hasClass('in')) {
      $('#active-pane').removeClass('col-xs-offset-4');
      $('.navbar-toggle').removeClass('navbar-toggle-collapse'); 
    }
    else {
      $('#active-pane').addClass('col-xs-offset-4');
      $('.navbar-toggle').addClass('navbar-toggle-collapse'); 
    }
  });

  $('.comment-link').on('click', function() {
    $(this).siblings('.comment-form').toggle();
    $(this).toggle();
  });
});



