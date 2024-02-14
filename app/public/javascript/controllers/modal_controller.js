/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("modal", class extends Controller {
  
  static targets = ["modal"]
  
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
    
    