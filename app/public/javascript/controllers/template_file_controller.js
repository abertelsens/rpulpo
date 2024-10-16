import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

  Stimulus.register("template-file", class extends Controller {
    
    static targets = ["template_file", "template_btn","view_btn", "path"]
  
    connect() {
      console.log("Stimulus Connected: template-file controller");
    }
    
    select_file() {
      this.template_fileTarget.click();
    }

    load_file(){
      this.pathTarget.value = this.template_fileTarget.value.replace(/^.*[\\/]/, '')
      this.template_btnTarget.innerHTML = "Change"
      if (this.hasView_btnTargetTarget) {
        this.view_btnTarget.disabled = (this.pathTarget.value==="")
      }
    }
  })
    
    