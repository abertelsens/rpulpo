import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

  Stimulus.register("template-file", class extends Controller {
    
    static targets = ["template_file", "template_btn", "path","view_btn"]
  
    connect() {
      console.log("Stimulus Connected: mdfile controller");
    }
    
    select_file() {
      this.mdfileTarget.click();
    }

    load_file(){
      this.pathTarget.value = this.template_fileTarget.value.replace(/^.*[\\/]/, '')
      this.template_btnTarget.innerHTML = "Change"
      this.view_btnTarget.disabled = (this.pathTarget.value==="")
    }
  })
    
    