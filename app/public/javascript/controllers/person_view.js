// navbar_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the person view frame. 
// See views/view/person.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

// hash thta defines the shortcuts mappings to the differente modules
// i.e. cts+g will go to the general module as it has index 0
const SHORTCUTS = {g: 0, c:1, e:2, m:3, p:4, q:5 }

Stimulus.register("person-view", class extends Controller {
  
  static targets = ["submitButton", "module"]
  
  
  connect() {
    console.log("Stimulus Controller Connected: person-view");
  }

  escape(event) {
    event.preventDefault();
    event.stopPropagation();
    this.submitButtonTarget.click();
  }

  navigate(event){
    event.preventDefault();
    event.stopPropagation();
    (this.moduleTargets[SHORTCUTS[event["key"]]]).click()
  }


})
    
    