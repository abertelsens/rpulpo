// form.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of the some kwy bindings
// See also https://stimulus.hotwired.dev/handbook
// 
// last update: 2024-10-24 
// ---------------------------------------------------------------------------------------  

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("form", class extends Controller {
  
  static targets = ["form", "fieldset", "modal", "newButton", "tableSettingsButton", "submitButton", "newButton", "deleteButton", "cancelButton", "firstField"]
  
  connect() {
    console.log("Stimulus Controller Connected: form");
  }

  enter(event) {
    event.preventDefault()
    event.stopPropagation();   
    console.log("subimitting form");
    this.submitButtonTarget.click(); // if we submit the form directly the commit parameter will not be submitted
  }

  blockEnter(event) {
    event.preventDefault();
    event.stopPropagation();
    // Optionally, you can show a message or just silently block
    return false;
  }

  escape() {  
    if (!this.hasModalTarget) {
      this.cancelButtonTarget.click();
      return;
    }
    if (this.modalTarget.classList.contains('hidden-frame')) {
      this.cancelButtonTarget.click();
    }
    else {
      this.close_modal();
    }
  }

  delete(event) {
    if (!(event.ctrlKey && event.key === "d")) return;
    event.preventDefault();
    event.stopPropagation();   
    this.deleteButtonTarget.click();  
  }

  open_modal(event) {
    event.preventDefault();
    event.stopPropagation();
    this.modalTarget.classList.remove('hidden-frame')
    this.fieldsetTarget.disabled=true
  }
  
  close_modal() {   
   this.modalTarget.classList.add('hidden-frame') 
   this.fieldsetTarget.disabled=false
   this.firstFieldTarget.focus();
  }  
  
  add(event) {
    event.preventDefault();
    event.stopPropagation();
    this.newButtonTarget.click();
    /*Turbo.visit(this.newButtonTarget.href)*/
  }

  table_settings(event) {
    event.preventDefault();
    event.stopPropagation();
    this.tableSettingsButtonTarget.click();
  }

  // The method is triggered when the user hits the ctrl-f keys. We prevent the default action of 
  // the browser (i.e.) to search in the page, set the focus on the search field
  search_focus(event) {
    event.preventDefault();
    this.firstFieldTarget.focus();
    this.firstFieldTarget.select();
  }


})

