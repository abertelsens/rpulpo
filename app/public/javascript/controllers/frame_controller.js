/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("frame", class extends Controller {
  
  static targets = ["newButton"]
  
  connect() {
    console.log("Stimulus Controller Connected: frame");
  }

  add(event) {
    event.preventDefault();
    event.stopPropagation();
    this.newButtonTarget.click();
  }

})
    
    