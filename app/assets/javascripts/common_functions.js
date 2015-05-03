var alertObject = {};
  $(document).ready(function(){
    /* ajax setup for csrf token */
    $.ajaxSetup({
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        }
      ,
        beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))}
      });
  });
  
  
  /* ajax setup for Global Errors */
   $(function () {
        //setup ajax error handling
        $.ajaxSetup({
            error: function (x, status, error) {
                if (x.status == 403) {
                    alert("Sorry, your session has expired. Please login again to continue");
                    window.location.href ="/";
                }
                else {
                    alert("status: " + status + ". Message: " + error);
                }
            }
        });
   });
   
   
  
   /*------ Grab colors from Report Controller------- */
   

   function grabColors() {
    $.ajax({
  		async: false,
        method: 'GET',
		url: '/project_colors',
        dateType: 'json',
        success: function(data){
        	var empty = [];
			$.each(data, function (key, value) { 
				empty.push([key, value]);
				
			});
			colorHash = empty;
			console.log('color hash: ' + colorHash);
		        }
    });
    }
    
     function assignColors(array) {
    	var colors = [];
    	$(array).each(function(i, value){
    		$(colorHash).each(function(j, obj) {
    			if ($.inArray(value[0], obj) != -1){
    				colors.push(obj[1]);
    			}
    		});
    	});
    	return colors;
    }
    
    
    google.load("visualization", "1", {packages:["corechart"]});
    //google.setOnLoadCallback(drawChart);
	var pieArray;
	var colorArray;
	
    var  currentBannerClass = 'alert-info';


    /*------- Create Google Pie Chart with date from pieChart trigger -----*/
    function createPieChart(pieHash) {
    	if (pieHash != 'blank'){
    	pieArray = [['Project Title', 'Hours']];
    	colorArray = assignColors(pieHash);
    	pieArray = $.merge(pieArray, pieHash);
    	drawChart(false);	
    	}
    	else {
    		drawChart(true);
    	}
	}
          	
      	function drawChart(blank) {
      		if (blank == false){
        		var data = google.visualization.arrayToDataTable(pieArray);
       		 	var options = {
        			colors: colorArray,
        			chartArea: {width: 1000, height:150}
       	 		};
			}
			else {
				var data = google.visualization.arrayToDataTable([['header','fake'],['fake', 0]]);
				options = {};
			}
        var chart = new google.visualization.PieChart(document.getElementById('piechart'));

        chart.draw(data, options);
        
        
       
      }          	
      
  
	function updateAlerts() {	
	// msg, and type, class= function called from
	// when fixed, remove from.
	//if alertObject.length == 0 , hide alert
	var banner = $('.alertBanner');
	var alertDropDown = $('.alert-dropdown');
	var length = Object.keys(alertObject).length;
	if (length == 0) {
		banner.hide();
		alertDropDown.hide();
	}
	else if (length == 1) {
		alertDropDown.hide();
		$.each(alertObject, function(alert, infoArray) {
			banner.addClass('alert-' + infoArray[0]).html(infoArray[1]).show();
		});
	}
	else if (length > 1) {
			banner.hide();

		$('.alert-count').html(length);
		var alertHtml = '';
		$.each(alertObject, function(alert, infoArray) {
			alertHtml += '<li class="alert-' + infoArray[0] + '">' + infoArray[1] + '</li>';
		});
		$('ul.main-alerts').html(alertHtml);
		alertDropDown.show();
				}
       } 
      
	function validateHours(lastInput) {
    	lastInput = parseFloat(lastInput);   
    	if ((lastInput % 0.25) != 0) {
    		alert('Hourly input must be in increments of .25 (Example: 3:00pm to 4:15pm is 1.25 hours.)');
    		return false;
    	}
    	var sumDayHours = 0.0;  
    	$('.today').each( function() {
    		sumDayHours += parseFloat($(this).val());
    	});
    	if ((sumDayHours) > 24.0) {
    	    alert('Daily hours may not exceed 24.');
    		return false;
    	}
    	else {
    		return true;
    	}
    }
	  
   var data = [[48803, "DSK1", "", "02200220", "OPEN"], [48769, "APPR", "", "77733337", "ENTERED"]];

    /*$("#grid").jqGrid({
        datatype: "local",
        height: 250,
        colNames: ['Inv No', 'Thingy', 'Blank', 'Number', 'Status'],
        colModel: [{
            name: 'id',
            index: 'id',
            width: 60,
            sorttype: "int"},
        {
            name: 'thingy',
            index: 'thingy',
            width: 90,
            sorttype: "date"},
        {
            name: 'blank',
            index: 'blank',
            width: 30},
        {
            name: 'number',
            index: 'number',
            width: 80,
            sorttype: "float"},
        {
            name: 'status',
            index: 'status',
            width: 80,
            sorttype: "float"}
        ],
        caption: "Stack Overflow Example",
        // ondblClickRow: function(rowid,iRow,iCol,e){alert('double clicked');}
    });

var names = ["id", "thingy", "blank", "number", "status"];
var mydata = [];

for (var i = 0; i < data.length; i++) {
    mydata[i] = {};
    for (var j = 0; j < data[i].length; j++) {
        mydata[i][names[j]] = data[i][j];
    }
}

for (var i = 0; i <= mydata.length; i++) {
    $("#grid").jqGrid('addRowData', i + 1, mydata[i]);
}


$("#grid").jqGrid('setGridParam', {ondblClickRow: function(rowid,iRow,iCol,e){alert('double clicked');}});
*/
  
  $("document").ready(function(){
    $("a#help_link").click(function(){
		   	$.ajax({
    		   	type: "POST",
			url: "process.php",
			data: $('form.contact').serialize(),
        		success: function(msg){
 	          		  $("#thanks").html(msg)
 		        	$("#form-content").modal('hide');	
 		        },
			error: function(){
				alert("failure");
				}
      			});
	});
    
    
    
    
    
    
  });
	$(document).ready(function(){
            $.ajaxSetup({
              beforeSend: function(xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
              }
            });
            

            
             //$("#help_link").attr("href","/help?page="+window.location.pathname);
                       
                
            
            var colorHash = [];
			
			blinking($('.blink'));
			blinkedOut($('.blinkedOut'));
			
			function blinkedOut(elm) {
				elm.css({backgroundColor:'#d2322d', color: 'white' });
			}
			
			 function quitBlink(elm) {
        		setTimeout( function() {
        			clearInterval(timer);
        			elm.css({backgroundColor:'#d2322d', color: 'white' });
        			}, 3000 );
        	
        	}
			function blinking(elm) {
    			var colors = ['#d2322d', 'white'];
    			var textColors = ['white', '#428bca'];
    			timer = setInterval(blink, 250);
    			quitBlink(elm);
    			var count = 0;
    			function blink() {
    				(count == 0)? count=1:count=0;
    				setTimeout(function() { elm.css({backgroundColor: colors[count]});
    										elm.css({color: textColors[count]});}, 0);
        		}
        		   				elm.css({backgroundColor:'#d2322d', color: 'white' });
        		}
        	
    		  $('.active > a').addClass('keepBlue');		
    		  
 close = $("#close");
 close.trigger('click', function() {
   note = $(".flash");
   note.hide();
 });
 
    		});

/* Help Manual Setup */
$(document).ready(function(){
          $("#myModal").modal('hide');               
        });
        function loadHelpManual(){       
                if(window.location.pathname == "/welcome/index"){
                  manual_src = "/assets/time_input_of_Effort_Tracker.pdf";
                }
                else if(window.location.pathname == "/manager"){
                  manual_src = "/assets/manager_home.pdf";
                }
                else if(window.location.pathname == "/admin/users"){
                  manual_src = "/assets/admin_users.pdf";
                }
                else if(window.location.pathname == "/admin/projects"){
                  manual_src = "/assets/Admin_projects.pdf";
                }
                else if(window.location.pathname == "/ProjectsPersonnel"){
                  manual_src = "/assets/projects_personnel.pdf";
                }
                else if(window.location.pathname == "/TimeSummaries"){
                  manual_src = "/assets/time_summaries.pdf";
                }
                else if(window.location.pathname == "/manageReports"){
                  manual_src = "/assets/manager_verify_reports.pdf";
                }
                else if(window.location.pathname == "/tsmanageReports"){
                  manual_src = "/assets/tsmanagermanagereports.pdf";
                }
                else if(window.location.pathname == "/time_sheet_reports"){
                  manual_src = "/assets/tscollabtsreports.pdf";
                }
                else if(window.location.pathname == "/submit_report"){
                  manual_src = "/assets/submit_reports.pdf";
                }
                else if(window.location.pathname == "/work_order_admin"){
                  manual_src = "/assets/wo_admin.pdf";
                }
                else if(window.location.pathname == "/WorkOrderTracking"){
                  manual_src = "/assets/woadmin_wotracking.pdf";
                }
          
                  
                $("#help_manual_frame").attr("src",manual_src);
                $("#myModal").modal('show');
         }    


