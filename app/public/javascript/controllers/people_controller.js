import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
    Stimulus.register("people", class extends Controller {
      
      static targets = ["search_field"] //the button to add a new object
      
      connect() {
        // set focus on 
        this.search_fieldTarget.focus();
        this.search_fieldTarget.selectionStart = this.search_fieldTarget.selectionEnd = this.search_fieldTarget.value.length;
      }

      search_focus(event)
      {
        event.preventDefault();
        this.search_fieldTarget.focus();
        this.search_fieldTarget.select();

      }

      add_person(event)
      {
        event.preventDefault();
        //Turbo.visit("/person/new/general", {frame: "main_frame"})
        let frame = document.querySelector("turbo-frame#main_frame")
        frame.src = "/person/new/general"
      }
      
      submit()
      {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
        this.element.requestSubmit()
        }, 200)
      }
      
    })
    
    