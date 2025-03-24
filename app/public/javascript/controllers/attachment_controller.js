// attachment_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS Controller to handle the behaviour of attachments to forms sucha as a
// picture and files uploaded.
// Used in views/form/general.slim
//
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
//----------------------------------------------------------------------------------------

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"
    
Stimulus.register("attachment", class extends Controller {
  
  static targets = ["photoFile", "photoImage", "photoFile"]

  connect() {
    console.log("Stimulus Connected: attachment controller");
  }

  select_image()
  {
    this.photoFileTarget.click();
  }

  // the method is called once the field containig the image file changes.
  // We get as a parameter the id of the person being modified. This allows us to build
  // a specific post request.
  load_image({ params: { id } }) {
    var url = `/people/${id}/image`
    var input = document.querySelector('input[type="file"]')
    var data = new FormData()
    data.append('file', input.files[0])
    fetch(url, {
      method: 'post',
      body: data,
    })
    .then(response => this.photoImageTarget.src=`photos/${id}.jpg?v=${Math.random()}`)    }
})
    
    