// clipboard_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle to prepare data to be copied as cvs
// used in views/frame/mail.slim and viewa/frame/rooms
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
//----------------------------------------------------------------------------------------

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("clipboard", class extends Controller {
  
  static targets = ["copyButton" ,"copyField", "modal"]
  
  connect() {
    console.log("Stimulus Controller Connected: clipboard");
  }

  closeModal() {
    this.hideFrame(this.modalTarget);      
  }
  
  copy() {    
    var table_name = this.data.get("tablename");
    var url = `/${table_name}/clipboard/copy`
    fetch(url)
    .then(res => res.json())
    .then(out => { this.handleResponse(out) })
    .catch(err => {alert(err) });
  }


  handleResponse(response) {
    if (!response) {
      console.log("clipboard controller: error from server request");
      return
    }

    if(!response.result) {             
      this.copyButtonTarget.innerHTML = "<fa-solid fa-triangle-exclamation'></i> oops"
      this.copyButtonTarget.classList.add("button-warning")
      this.copyButtonTarget.style.width = w
      setTimeout(() => {
        this.reset_button();
      }, "2000");
    }
    else {
      this.copyFieldTarget.value = response.data
      this.copyButtonTarget.innerHTML = "<i class='fa-solid fa-copy'></i> done"
      this.copyButtonTarget.classList.add("button-primary")
      this.copyButtonTarget.classList.remove("button-success")
      this.showFrame(this.modalTarget);   
      this.copyFieldTarget.innerHTML =  response.data
      setTimeout(() => {
        this.reset_button();
      }, "2000");
    }
  } 

  reset_button()
  {
    this.copyButtonTarget.innerHTML = "<i class='fa-solid fa-copy'></i> copy"
    this.copyButtonTarget.classList.remove("button-primary")
    this.copyButtonTarget.classList.add("button-success")
  }


  hideFrame(frame) {
    frame.classList.add('hidden-frame')
  }

  showFrame(frame) {
    frame.classList.remove('hidden-frame')
  }
})
    
    