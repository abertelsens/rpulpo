// setfield_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the set field form. 
// See views/form/setfield.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
  Stimulus.register("setfield", class extends Controller {
    
    static targets = ["att_name", "att_field","attributeName", "attributeField" ] //the button to add a new object

    connect() {
      console.log("Stimulus Connected: setfield controller");
    }

    initialize() {
      console.log("Stimulus Controller Connected: setfield");
    }

    update(e)
    {
      var attributeName = this.attributeNameTarget.value
      this.attributeFieldTarget.src = `/people/field/${attributeName}`
      this.attributeFieldTarget.refresh
      console.log(`/people/field/${attributeName}`)
    }
  })
  