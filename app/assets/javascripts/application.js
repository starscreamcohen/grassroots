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

// Global Variables 

var _commentBox;


jQuery(function() {
  return $('#user_organization_name_box').autocomplete({
    source: $('#user_organization_name_box').data('autocomplete-source')
  });
 });

$(document).ready(function() {
  return $('#skill_name').autocomplete({
    source: $('#skill_name').data('autocomplete-source')
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

  $('.newsfeed-new-comment').on('click', function() {
    $(this).addClass('new-comment-field-expanded');
    $(this).siblings('.comment-button').show();
  });
  $('.newsfeed-new-comment').on('keypress', function() {
    $(this).siblings('.comment-button').addClass('comment-button-active');
  });
  $('.newsfeed-new-comment').on('change', function () {
    
  });
});

// Create function that finds if comment field is empty


