// modal_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of modal frames. 
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("modal", class extends Controller {
  
  static values = { name: String };

  static targets = ["form", "modal", "firstField"]
  
  connect() {
    console.log("Stimulus Controller Connected: modal");
  }

  open_modal(event) {    
    event.preventDefault();
    event.stopPropagation();
    const modalId = event.params.modalId;
    const modal = this.element.querySelector(`[data-modal-id="${modalId}"]`);
    this.activeModal = modal;

    modal.style.display="block";
    modal.setAttribute("data-action", "keydown.esc@window->modal#close_modal"); 

    console.log("active modal", this.activeModal);
    if(this.hasFormTarget) { this.formTarget.setAttribute("data-action", ""); }
    //this.modalTarget.setAttribute("data-action", "keydown.esc@window->modal#close_modal"); 
  }
  close_modal(event) {    
    console.log("active modal", this.activeModal);
    this.activeModal.style.display="none";

    if(this.hasFormTarget) { this.formTarget.setAttribute("data-action", "keydown.esc@window->keys#escape"); } 
    //this.modalTarget.style.display="none";
    //if(this.hasFirstFieldTarget) { this.firstFieldTarget.focus(); } 
  }  
})
    
    