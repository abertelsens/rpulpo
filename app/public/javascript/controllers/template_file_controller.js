// setfield_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS A Controller for the template files.
// See views/form/table_settings.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 
import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

  Stimulus.register("template-file", class extends Controller {
    
    static targets = ["templateFile", "templateButton","viewButton", "path"]
  
    connect() {
      console.log("Stimulus Connected: template-file controller");
    }
    
    selectFile() {
      this.templateFileTarget.click();
    }

    loadFile(){
      this.pathTarget.value = this.templateFileTarget.value.replace(/^.*[\\/]/, '')
      this.templateButtonTarget.innerHTML = "Change"
      if (this.hasViewButtonTargetTarget) {
        this.viewButtonTarget.disabled = (this.pathTarget.value==="")
      }
    }
  })
    
    