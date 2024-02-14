/************************************************************************************************  
    A Controller for a the navigation bar.
    It just shows or hides the secondary navigation bar.
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
Stimulus.register("navbar", class extends Controller {
  
  static targets = ["secondary_navbar"]; //the button to add a new object
  hide_class = 'hidden-frame'
  
  connect() {
    console.log("Stimulus Connected: navbar controller");
  }

  toggle() {
    console.log("toggling")
    if (this.adminnavbarTarget.classList.contains(hide_class)) {
      this.adminnavbarTarget.classList.remove(hide_class)
    }
    else {
      this.adminnavbarTarget.classList.add(hide_class)
    }    
  }
})
    
    