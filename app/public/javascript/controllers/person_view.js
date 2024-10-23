/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

// hash thta defines the shortcuts mappings to the differente modules
// i.e. cts+g will go to the general module as it has index 0
const SHORTCUTS = {g: 0, s:1, p:2, c:3, m:4 }

Stimulus.register("person-view", class extends Controller {
  
  static targets = ["submitButton", "module"]
  
  
  connect() {
    console.log("Stimulus Controller Connected: person-view");
  }

  escape(event) {
    event.preventDefault();
    event.stopPropagation();
    this.submitButtonTarget.click();
  }

  navigate(event){
    event.preventDefault();
    event.stopPropagation();
    (this.moduleTargets[SHORTCUTS[event["key"]]]).click()
  }
  

})
    
    