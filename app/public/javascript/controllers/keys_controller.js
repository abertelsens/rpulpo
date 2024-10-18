/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("keys", class extends Controller {
  
  static targets = ["form", "submit_btn", "delete_btn", "cancel_btn"]
  
  connect() {
    console.log("Stimulus Controller Connected: keys");
  }

  enter(event) {
    event.preventDefault()   
    this.formTarget.requestSubmit();  
  }

  escape() {  
    this.cancel_btnTarget.click();  
  }

  delete() {   
    this.delete_btnTarget.click();  
  }

  move_down()
  {

  }
})
    
    