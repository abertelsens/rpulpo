import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    window.Stimulus = Application.start()   

    Stimulus.register("tablesettings", class extends Controller {
      
      static targets = ["att_button", "att_name", "att_field"] //the button to add a new object
     
      connect() {
        console.log("Stimulus Controller Connected: tablesettings");
      }
    

    update(e)
    {
      console.log("update")
      console.log(e.params["id"])
      this.toggle(document.getElementsByName(e.params["id"])[0], e.currentTarget)
    }

    toggle(field, button)
    {
      console.log(field.value=="true")
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
    
    