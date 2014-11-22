$( document ).ready(function() {

	var buttonsSpan = $("button.plus").children("span");

	// REMOVE EVENT FROM LIST
	$( ".eventDelete" ).click(function() {
		$(this).closest('tr').fadeOut();
	});

	$( ".unarchive" ).click(function() {
		$(this).closest('.panel-default').fadeOut();
	});

	$(".panel-title a").click(function(){
		value = $(this).find("span.glyphicon").attr("class");

		switch (value){

			case "glyphicon glyphicon-plus":

				minusSpans = $("div.panel-heading").find("span.glyphicon-minus");
				minusSpans.each(function(index){
					minusSpans[index].className = "glyphicon glyphicon-plus";
				});
				$(this).find("span.glyphicon").attr("class","glyphicon glyphicon-minus");
				break;
			case "glyphicon glyphicon-minus":
				$(this).find("span.glyphicon").attr("class","glyphicon glyphicon-plus");
				break;
			}
	});


	// $( "span.glyphicon" ).click(function() {
	//  	//console.log(this.className);
	// 	switch (this.className){
	//
	// 		case "glyphicon glyphicon-plus":
	//
	// 			minusSpans = $("div.panel-heading").find("span.glyphicon-minus");
	// 			minusSpans.each(function(index){
	// 				minusSpans[index].className = "glyphicon glyphicon-plus";
	// 			});
	// 			this.className = "glyphicon glyphicon-minus";
	// 			break;
	// 		case "glyphicon glyphicon-minus":
	// 			this.className = "glyphicon glyphicon-plus";
	// 			break;
	// 		}
	//  });





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
	// $(".eventTitle").popover({
	// 	trigger: "manual",
	// 	placement: "bottom",
	// 	title: "",
	// 	html : true,
	// 	content: function() {
	// 		return $('#eventPopoverContent').html();
	// 	}
	// 	}).on("click", function(e) {
	// 		e.preventDefault();
	// 	}).on("mouseenter", function() {
	// 		$(this).popover("show");
	// 		$(this).siblings(".popover").on("mouseleave", function() {
	// 			$(this).hide();
	// 		});
	// 	}).on("mouseleave", function() {
	// 		var _this = this;
	// 		setTimeout(function() {
	// 			if (!$(".popover:hover").length) {
	// 				$(_this).popover("hide")
	// 			}
	// 		}, 100);
	// 	});
});
