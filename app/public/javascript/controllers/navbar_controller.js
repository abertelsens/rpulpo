/************************************************************************************************  
A Controller for a the navigation bar.
It just shows or hides the secondary navigation bar.
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
 
const hide_class = 'hidden-frame'

Stimulus.register("navbar", class extends Controller {
  
  static targets = ["navbar"]

 
  
  connect() {
    console.log("Stimulus Connected: navbar controller");
  }

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
    
    