// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".


import "phoenix_html";
import jQuery from "jquery";


jQuery(document).ready(()=>{
    

    let message = document.getElementById("silly-message");

    function pollMessage() {
        var xmlhttp = new XMLHttpRequest();

        message.className = `silly-message animated fadeOut`;

        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == XMLHttpRequest.DONE ) {
                if (xmlhttp.status == 200) {
	                  let payload = JSON.parse(xmlhttp.responseText);


	                  setTimeout(function(){
	                      message.innerHTML = payload.data.message;
                        message.className = `silly-message animated fadeIn`;
	                  }, 1000);
                }
            }
        };

        xmlhttp.open("GET", "/silly", true);
        xmlhttp.send();
    }


    setInterval(pollMessage, 10000);

    pollMessage();
    
    Soon.create(document.getElementById('the-counter'),{
        "due" : jQuery('.next-date').data('date'),
        "layout": "inline label-uppercase",
        "format": "w,d,h,m,s",
        "labelsDays": "días",
        "labelsHours": "horas",
        "labelsMinutes": "minutos",
        "labelsSeconds": "segundos",
        "labelsWeeks": "semanas",
        "face": "flip color-light shadow-soft fast corners-round"
    });
});
