$( document ).ready(function() {

	// REMOVE EVENT FROM LIST
	$( ".eventDelete" ).click(function() {
		$(this).closest('tr').fadeOut();
	});

	$( ".unarchive" ).click(function() {
		$(this).closest('.panel-default').fadeOut();
	});

	$( ".panel-title a" ).click(function() {
		$(this).find('.glyphicon-plus').toggleClass('glyphicon-minus');
	});

	$('.deleteEventTemp').on('click', function(e){
	    var eventTemp = $(this).closest('.panel');
	    $('#confirm').modal({ backdrop: 'static', keyboard: false }).one('click', '.confrmDeleteEventTemp', function (e) {
	    	$(eventTemp).fadeOut();
	    });
	    $('body').keyup(function(event){
	    	if(event.keyCode == 13){
	    		$(eventTemp).fadeOut();
	    		$('#confirm').modal('toggle');
	    	}
	    });
	});

	// COACH ASSIGN
	$("#btnLeft").click(function () {
    	var selectedItem = $("#rightValues option:selected");
    	$("#leftValues").append(selectedItem);
	});

	$("#btnRight").click(function () {
	    var selectedItem = $("#leftValues option:selected");
	    $("#rightValues").append(selectedItem);
	});

	$("#rightValues").change(function () {
	    var selectedItem = $("#rightValues option:selected");
	    $("#txtRight").val(selectedItem.text());
	});


	// POPOVER EVENT DETAILS
	$(".eventTitle").popover({
		trigger: "manual",
		placement: "bottom",
		title: "",
		html : true,
		content: function() {
			return $('#eventPopoverContent').html();
		}
		}).on("click", function(e) {
			e.preventDefault();
		}).on("mouseenter", function() {
			$(this).popover("show");
			$(this).siblings(".popover").on("mouseleave", function() {
				$(this).hide();
			});
		}).on("mouseleave", function() {
			var _this = this;
			setTimeout(function() {
				if (!$(".popover:hover").length) {
					$(_this).popover("hide")
				}
			}, 100);
		});
});