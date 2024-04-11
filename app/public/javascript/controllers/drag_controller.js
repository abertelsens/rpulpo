import { Controller }  from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("drag", class extends Controller {

  connect() {
    console.log("drag controller connected")
  }

  drop(event)
  {
    event.preventDefault()
    let velaid = this.data.get("velaid")
    var data = event.dataTransfer.getData("application/drag-key")
    const dropTarget = event.currentTarget
    const draggedItem = this.element.querySelector(`[data-room-id='${data}']`);
    var roomId = draggedItem.dataset.roomId
    var turnoId = dropTarget.dataset.turnoId
    var url = `/vela/${velaid}/turno/${turnoId}/room/${roomId}`;
    fetch(url, 
      {
        method: "POST", 
      })
      .then(res =>  { this.reload_turnos() })
      .catch(err => { throw err });
    return true
  }

  delete(event)
  {
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

  dragstart(event)
  {
    event.dataTransfer.setData("application/drag-key", event.currentTarget.getAttribute("data-room-id"))
    event.dataTransfer.effectAllowed = "move"
  }

  dragenter(event) {
    event.preventDefault()
}

  dragover(event)
  {
    event.preventDefault()
    return true
  }

  reload_turnos()
  {
    const trigger = new CustomEvent("turnosreload");
    window.dispatchEvent(trigger);
  }

});