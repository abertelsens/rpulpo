// drag_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the darag and drop capabilities of the
// form vela. See views/for/vela.slim
// See also https://stimulus.hotwired.dev/handbook
// 
// last update: 2025-03-24 
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
    var roomId = event.dataTransfer.getData("application/drag-room")
    

    //get the id of the turno where the room was dropped 
    const dropTarget = event.currentTarget
    var turnoId = dropTarget.dataset.turnoId
    
    // If the elemement is droppeed in an element that has no turnoIS then it is a delete operation
    if (turnoId == null) { return this.delete(event) } 
    else
    {
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
  }

  delete(event) {
    console.log("delete")
    var velaid = this.data.get("velaid")
    var roomId = event.dataTransfer.getData("application/drag-room")
    var turnoId = event.dataTransfer.getData("application/drag-turno")
    var url = `/vela/${velaid}/turno/${turnoId}/room/${roomId}/delete`;
    fetch(url, 
      {
        method: "POST", 
      })
      .then(res =>  { this.reload_turnos() })
      .catch(err => { throw err });
    return true
  }

  // handle the drag start. We set the data to be transfered.
  dragstart(event) {
    event.dataTransfer.setData("application/drag-room", event.currentTarget.getAttribute("data-room-id"))
    var turnoID = event.currentTarget.getAttribute("data-turno-id")
    if (turnoID != null) {
      event.dataTransfer.setData("application/drag-turno", turnoID)
    }
    else
    event.dataTransfer.effectAllowed = "move"
  }

  dragenter(event) { event.preventDefault()
  }

  dragover(event) {
    event.preventDefault()
    event.currentTarget.classList.add("drag-over")
    return true
  }

  dragleave(event) {
    event.preventDefault()
    event.currentTarget.classList.remove("drag-over")
    return true
  }

  reload_turnos() {
    //console.log("reload turnos")
    const trigger = new CustomEvent("turnosreload");
    window.dispatchEvent(trigger);
  }

});