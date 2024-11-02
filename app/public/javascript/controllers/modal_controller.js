// modal_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of modal frames. 
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("modal", class extends Controller {
  
  static targets = ["form", "modal", "firstField"]
  
  connect() {
    console.log("Stimulus Controller Connected: modal");
  }

  open_modal(event) {    
    event.preventDefault();
    event.stopPropagation();
    this.modalTarget.style.display="block";
    if(this.hasFormTarget) { this.formTarget.setAttribute("data-action", ""); }
    this.modalTarget.setAttribute("data-action", "keydown.esc@window->modal#close_modal"); 
  }
  close_modal(event) {    
    this.modalTarget.setAttribute("data-action", "");
    if(this.hasFormTarget) { this.formTarget.setAttribute("data-action", "keydown.esc@window->keys#escape"); } 
    this.modalTarget.style.display="none";
    if(this.hasFirstFieldTarget) { this.firstFieldTarget.focus(); } 
  }  
})
    
    