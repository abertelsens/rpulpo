// document_links_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the documents related to a mail.
// Used in views/form/mail/document_links.slim
//
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
//----------------------------------------------------------------------------------------

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("document-links", class extends Controller {
  
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
    if (this.hasNotesTarget)      { this.deactivateFrame(this.notesTarget)      } 
    if (this.hasReferencesTarget) { this.deactivateFrame(this.referencesTarget) } 
    if (this.hasAnswersTarget)    { this.deactivateFrame(this.answersTarget)    } 
    
    if (value=="references")  { this.activateFrame(this.referencesTarget) }
    if (value=="notes")       { this.activateFrame(this.notesTarget)      }
    if (value=="answers")     { this.activateFrame(this.answersTarget)    } 
  }
})
    
    