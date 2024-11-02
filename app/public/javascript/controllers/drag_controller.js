// drag_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the darag and drop capabilities of the
// form vela. See views/for/vela.slim
// See also https://stimulus.hotwired.dev/handbook
// 
// last update: 2024-10-24 
// ---------------------------------------------------------------------------------------  

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"


Stimulus.register("drag", class extends Controller {

  connect() {
    console.log("drag controller connected")
  }

  // handle the drop event of a room in a specific turno.
  drop(event)
  {
    event.preventDefault()
    // get the id of the vela object being edited.
    let velaid = this.data.get("velaid")
    
    // get the room id of the element being draged
    var data = event.dataTransfer.getData("application/drag-key")
    const draggedItem = this.element.querySelector(`[data-room-id='${data}']`);
    var roomId = draggedItem.dataset.roomId
    
    //get the id of the turno where the room was dropped 
    const dropTarget = event.currentTarget
    var turnoId = dropTarget.dataset.turnoId
    
    // post the changes, i.e. tell the server roomId now belongs to turnoId
    var url = `/vela/${velaid}/turno/${turnoId}/room/${roomId}`;
    fetch(url, 
      {
        method: "POST", 
      })
      .then(res =>  { this.reload_turnos() })
      .catch(err => { throw err });
    return true
  }

  delete(event) {
    var velaid = this.data.get("velaid")
    var roomId =event.currentTarget.getAttribute("data-room-id")
    var turnoId =event.currentTarget.getAttribute("data-turno-id")
    var url = `/vela/${velaid}/turno/${turnoId}/room/${roomId}/delete`;
    fetch(url, 
      {
        method: "POST", 
      })
      .then(res =>  { this.reload_turnos() })
      .catch(err => { throw err });
    return true
  }

  dragstart(event) {
    event.dataTransfer.setData("application/drag-key", event.currentTarget.getAttribute("data-room-id"))
    event.dataTransfer.effectAllowed = "move"
  }

  dragenter(event) { event.preventDefault()
  }

  dragover(event) {
    event.preventDefault()
    return true
  }

  reload_turnos() {
    const trigger = new CustomEvent("turnosreload");
    window.dispatchEvent(trigger);
  }

});