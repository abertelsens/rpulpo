// navbar_controller.js

// ---------------------------------------------------------------------------------------  
// A Controller for a search form.
// It just submits the form after a delay of 200 milisenconds. We use it after an input event to 
// provide inmediate feeback on the search results.
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 


import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"
    
Stimulus.register("search", class extends Controller {
  
  static targets = [];
  
  connect() {
    console.log("Stimulus Connected: search controller");
    //var width = window.innerWidth
    //|| document.documentElement.clientWidth
    //|| document.body.clientWidth;

    //var height = window.innerHeight
    //|| document.documentElement.clientHeight
    //|| document.body.clientHeight;

    //console.log(width)
    //console.log(height)
  }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
    this.element.requestSubmit()
    }, 200)
  }
  
})
    
    