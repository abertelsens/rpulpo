import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
  Stimulus.register("setfield", class extends Controller {
    
    static targets = ["att_name", "att_field"] //the button to add a new object

    connect() {
      console.log("Stimulus Connected: setfield controller");
    }

    initialize() {
      this.active_field_name = "title"
      var field = document.getElementsByName(this.active_field_name)[0]
      field.style.display="block"
    }

    update(e)
    {
      console.log("update")
      console.log("att_nameTarget.value")
      console.log(this.att_nameTarget.value)
      var field = document.getElementsByName(this.att_nameTarget.value)[0]
      console.log("field")
      console.log(field)
      field.style.display="block"
      
      var old_field = document.getElementsByName(this.active_field_name)[0]
      old_field.style.display="none"
      this.active_field_name = field.name
    }
    
    
  })
  