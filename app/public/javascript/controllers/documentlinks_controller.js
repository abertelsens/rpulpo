//import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

    Stimulus.register("documentlinks", class extends Controller {
      
      static targets = ["notes", "references", "answers"]
      
      connect() {
        console.log("Stimulus Connected: documentlinks controller");
      }

      activateFrame(frame) {
        frame.classList.add('active-ref-box')
      }

      deactivateFrame(frame) {
        frame.classList.remove('active-ref-box')
      }
    

      activatebox(event)
      {
        const value = event.target.dataset.value
        if (this.hasNotesTarget) { this.deactivateFrame(this.notesTarget) } 
        if (this.hasReferencesTarget) { this.deactivateFrame(this.referencesTarget) } 
        if (this.hasAnswersTarget) { this.deactivateFrame(this.answersTarget) } 
        
        if (value=="referencelink") {
          this.activateFrame(this.referencesTarget)
        }
        if (value=="noteslink") {
          this.activateFrame(this.notesTarget)
        }
        if (value=="answerslink") {
          this.activateFrame(this.answersTarget)
        }
            
      }

    })
    
    