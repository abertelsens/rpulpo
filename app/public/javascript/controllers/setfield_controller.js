// setfield_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the set field form. 
// See views/form/setfield.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"
    
  Stimulus.register("set-field", class extends Controller {
    
    static targets = ["attributeName", "attributeField"] //the button to add a new object

    connect() {
      console.log("Stimulus Connected: set-field controller");
    }

    update(e)
    {
      var attributeName = this.attributeNameTarget.value
      this.attributeFieldTarget.src = `/people/field/${attributeName}`
      this.attributeFieldTarget.refresh
    }
  })
  