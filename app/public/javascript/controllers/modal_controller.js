import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    // There is no need to import the Application because we already did it in application.js
    Stimulus.register("modal", class extends Controller {
      
      static targets = ["field", "error_frame", "submit_btn", "modal"]
     
      connect() {
        console.log("Stimulus Controller Connected: modal");
      }
    
      open_modal(event) {    
        event.preventDefault();
        this.modalTarget.style.display="block";
      }
      close_modal(event) {    
        event.preventDefault();
        this.modalTarget.style.display="none";
      }  

    })
    
    