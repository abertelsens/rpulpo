/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("modal", class extends Controller {
  
  static targets = ["form", "modal", "first_field"]
  
  connect() {
    console.log("Stimulus Controller Connected: modal");
  }

  open_modal(event) {    
    event.preventDefault();
    this.modalTarget.style.display="block";
    this.formTarget.setAttribute("data-action", ""); 
    this.modalTarget.setAttribute("data-action", "keydown.esc@window->modal#close_modal"); 
  }
  close_modal(event) {    
    this.modalTarget.setAttribute("data-action", "");
    this.formTarget.setAttribute("data-action", "keydown.esc@window->keys#escape");  
    this.modalTarget.style.display="none";
    this.first_fieldTarget.focus();
  }  
})
    
    