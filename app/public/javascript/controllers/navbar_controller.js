import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
    Stimulus.register("navbar", class extends Controller {
      
      static targets = ["adminnavbar"]; //the button to add a new object
      
      connect() {
        console.log("Stimulus Connected: navbar controller");
      }

      toggle()
      {
        console.log("togling")
        if (this.adminnavbarTarget.classList.contains('hidden-frame')) {
          this.show_frame(this.adminnavbarTarget)
        }
        else {
          this.hide_frame(this.adminnavbarTarget)
        }    
      }

      hide_frame(frame) {
        frame.classList.add('hidden-frame')
      }

      show_frame(frame) {
        frame.classList.remove('hidden-frame')
      }

    })
    
    