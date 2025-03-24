import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("vela", class extends Controller {
  
  static targets = ["field", "form", "turnosFrame"]
  
  default_action = ""
  
  connect() {
    this.default_action = this.formTarget.action
    this.element[this.identifier] = this
  }

 
  reloadturnos()
  {
    this.turnosFrameTarget.src = `${this.data.get("urlprefix")}/update_drag`
  }  
 
  
  updateTurnos(event) {
    event.preventDefault()    
    this.formTarget.action = `${this.default_action}/turnos/update` 
    this.formTarget.method="POST"
    this.element.dataset.turboFrame = "turnos_frame"
        // Small delay to ensure the form submits before resetting
        setTimeout(() => {
          this.element.dataset.turboFrame = "main_frame"
          this.formTarget.action = this.default_action; // Reset to previous value
      }, 1000); 

    this.element.requestSubmit()
  }
})

    