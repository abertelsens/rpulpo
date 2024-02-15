/************************************************************************************************  
  A Controller for the people frame
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
Stimulus.register("people", class extends Controller {
  
  static targets = ["search_field"] //the button to add a new object
  
  connect() {
    // Each time we connect the controller (i.e. we come back to the frame) we set the focus on the search field.
    // and select its content
    this.search_fieldTarget.focus();
    this.search_fieldTarget.selectionStart = this.search_fieldTarget.selectionEnd = this.search_fieldTarget.value.length;
  }

  // The method is triggered when the user hits the ctrl-f keys. We prevent the default action of 
  // the browser (i.e.) to search in the page, set the focus on the search field
  search_focus(event) {
    event.preventDefault();
    this.search_fieldTarget.focus();
    this.search_fieldTarget.select();
  }
  
  // The method is triggered when the user hits the ctrl-a keys. We prevent the default action of 
  // the browser (i.e.) to search select all and navigate to the new frame by replacinng the source 
  // of the main frame.
  add_person(event)
  {
    event.preventDefault();
    //Turbo.visit("/person/new/general", {frame: "main_frame"})
    let frame = document.querySelector("turbo-frame#main_frame")
    frame.src = "/person/new/general"
  }
  
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
    this.element.requestSubmit()
    }, 200)
  }
  
})
    
    