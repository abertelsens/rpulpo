/************************************************************************************************  
    A Controller for a search form.
    It just submits the form after a delay of 200 milisenconds. We use it after an input event to 
    provide inmediate feeback on the search results.
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
Stimulus.register("search", class extends Controller {
  
  static targets = [];
  
  connect() {
    console.log("Stimulus Connected: search controller");
  }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
    this.element.requestSubmit()
    }, 200)
  }
  
})
    
    