// navbar_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the mail frame. 
// See views/form/mail.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
 
const hide_class = 'hidden-frame'

Stimulus.register("navbar", class extends Controller {
  
  static targets = ["navbar"]
  
  connect() {
    console.log("Stimulus Connected: navbar controller");
  }

  //toggles the visibility of the secondary navbar
  toggle() {
    console.log("toggling")
    if (this.navbarTarget.classList.contains(hide_class)) {
      this.navbarTarget.classList.remove(hide_class)
    }
    else {
      this.navbarTarget.classList.add(hide_class)
    }    
  }
})
    
    