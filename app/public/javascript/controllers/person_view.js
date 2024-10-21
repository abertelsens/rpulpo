/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

const SHORTCUTS = {g: 0, s:1, p:2, c:3, m:4 }

Stimulus.register("person-view", class extends Controller {
  
  static targets = ["submitButton", "module"]
  
  
  connect() {
    console.log("Stimulus Controller Connected: person-view");
  }

  escape(event) {
    event.preventDefault();
    this.submitButtonTarget.click();
  }

  navigate(event){
    (this.moduleTargets[SHORTCUTS[event["key"]]]).click()
  }
  

})
    
    