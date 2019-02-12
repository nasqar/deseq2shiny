
/////////////// Image modal
// Get the modal

$(function() {
		$('.pop').on('click', function() {
			$('.imagepreview').attr('src', $(this).find('img').attr('src'));
			$('#imagemodal').modal('show');
		});
});


/*window.addEventListener("beforeunload", function (e) {
  if(Cookies.get('_TRAEFIK_BACKEND') !== undefined)
    Cookies.remove("_TRAEFIK_BACKEND");
});*/