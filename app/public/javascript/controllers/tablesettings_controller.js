// setfield_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS A Controller for to control some keyboard events on a table and provide 
// some basic navigational functionality.
// See views/form/table_settings.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("table-settings", class extends Controller {
  
  static targets = ["attributeButton"]
  
  connect() {
    console.log("Stimulus Controller Connected: table-settings");
  }
  

  update(event) {
    this.toggle(document.getElementsByName(event.params["id"])[0], event.currentTarget)
  }

  toggle(field, button) {
    if(field.value=="true")
    {
      field.value="false";
      button.classList.remove("active")
    }
    else
    {
      field.value="true";
      button.classList.add("active")
    }
  }
})
  
    