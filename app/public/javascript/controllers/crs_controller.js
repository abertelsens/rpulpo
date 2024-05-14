import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"


Stimulus.register("crs", class extends Controller {
  
  static targets = ["cfiframe"]
  
  
  connect() {
    console.log("controller connected: crs")
    //this.default_action = this.formTarget.action
    //this.element[this.identifier] = this
  }
  
  drop(event)
  {
    event.preventDefault()
    console.log("drop")
    //get the id of the person that was dropped
    var data = event.dataTransfer.getData("application/drag-key")
    const dropTarget = event.currentTarget
    const draggedItem = this.element.querySelector(`[data-crs-id='${data}']`);
    var personId = draggedItem.dataset.crsId
    var cfiId = dropTarget.dataset.crsId
    var url = `/crs/cfi/update/${personId}/${cfiId}`;
    fetch(url, 
      {
        method: "POST", 
      })
      .then(res =>  { this.reload_cfis() })
      .catch(err => { throw err });
      return true
    }
    
    
      
      dragstart(event)
      {
        console.log("dragstart")
        event.dataTransfer.setData("application/drag-key", event.currentTarget.getAttribute("data-crs-id"))
        event.dataTransfer.effectAllowed = "move"
      }
      
      dragenter(event) {
        //console.log("dragenter")
        event.preventDefault()
      }
      
      dragover(event)
      {
        //console.log("dragover")
        event.preventDefault()
        return true
      }
      
      reload_cfis()
      {
        this.cfiframeTarget.reload()
        //const trigger = new CustomEvent("turnosreload");
        //window.dispatchEvent(trigger);
      }
      
    })
    
    