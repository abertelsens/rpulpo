import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    window.Stimulus = Application.start()   

    Stimulus.register("confirm", class extends Controller {
      
      static targets = ["field", "error_frame", "submit_btn"]
     
      connect() {
        console.log("Stimulus Controller Connected: confirm");
      }
    
      confirm(event) {    
        {
          let confirmed = confirm("Are you sure you want to delete this item?")
          if (!confirmed)
          {
            event.preventDefault();
          }  
          
        }
      }


    })
    
    