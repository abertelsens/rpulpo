/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("form", class extends Controller {
  
  static targets = ["form", "modal", "submit_btn", "delete_btn", "cancel_btn", "first_field"]
  
  connect() {
    console.log("Stimulus Controller Connected: form");
  }

  enter(event) {
    event.preventDefault()   
    this.formTarget.requestSubmit();  
  }

  escape() {  
    if (this.modalTarget.classList.contains('hidden-frame')) {
      this.cancel_btnTarget.click();
    }
    else {
      this.close_modal();
    }
  }

  delete() {   
    this.delete_btnTarget.click();  
  }

  move_down()
  {

  }

  open_modal(event) {
    event.preventDefault();
    event.stopPropagation();
    this.modalTarget.classList.remove('hidden-frame')
  }
  
  close_modal() {   
   this.modalTarget.classList.add('hidden-frame') 
   this.first_fieldTarget.focus();
  }  

})
    
    