/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("form", class extends Controller {
  
  static targets = ["form", "fieldset", "modal", "submitButton", "deleteButton", "cancelButton", "modalCancelButton", "firstField"]
  
  connect() {
    console.log("Stimulus Controller Connected: form");
  }

  enter(event) {
    console.log(event)
    console.log(event.target)
    event.preventDefault()
    event.stopPropagation();   
    console.log("subimitting form");
    this.submitButtonTarget.click(); // if we submit the form directly the commit parameter will not be submitted
  }

  escape() {  
    if (!this.hasModalTarget) {
      this.cancelButtonTarget.click();
      return;
    }
    if (this.modalTarget.classList.contains('hidden-frame')) {
      this.cancelButtonTarget.click();
    }
    else {
      this.close_modal();
    }
  }

  delete(event) {
    event.preventDefault();
    event.stopPropagation();   
    this.deleteButtonTarget.click();  
  }

  open_modal(event) {
    event.preventDefault();
    event.stopPropagation();
    this.modalTarget.classList.remove('hidden-frame')
    this.fieldsetTarget.disabled=true
  }
  
  close_modal() {   
   this.modalTarget.classList.add('hidden-frame') 
   this.fieldsetTarget.disabled=false
   this.firstFieldTarget.focus();
   
  }  

})
    
    