import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
    Stimulus.register("search", class extends Controller {
      
      static targets = ["sort_order"]; //the button to add a new object
      
      connect() {
        console.log("Stimulus Connected: search controller");
      }

      submit()
      {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
        this.element.requestSubmit()
        }, 200)
      }
      
    })
    
    