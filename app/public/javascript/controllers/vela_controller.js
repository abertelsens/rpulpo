import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

  
Stimulus.register("vela", class extends Controller {
  
  static targets = ["field", "form", "turnosFrame"]
  
  default_action = ""
  
  connect() {
    this.default_action = this.formTarget.action
    this.element[this.identifier] = this
  }

  //saves the form  
  save()
  {
    this.formTarget.action = this.default_action
    this.formTarget.method="POST"
    this.element.dataset.turboFrame = "_self"
    this.element.requestSubmit()
  }

  reloadturnos()
  {
    this.turnosFrameTarget.src = `${this.data.get("urlprefix")}/update_drag`
  }  
  // submits the form with a delete commit
  delete()
  {
    this.formTarget.action = this.default_action
    this.formTarget.method="POST"
    this.element.dataset.turboFrame = "_self"
    this.element.requestSubmit()
  }

  updateTurnos(event) {
    event.preventDefault()    
    this.formTarget.action = `${this.default_action}/turnos/update` 
    this.formTarget.method="POST"
    this.element.dataset.turboFrame = "turnos_frame"
    this.element.requestSubmit()
  }
})

    