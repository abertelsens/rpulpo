//------------------------------------------------------------------------------------------------  
//  A Controller to handle the behaviour of attachments to forms sucha as a picture and 
//  files uploaded.
//------------------------------------------------------------------------------------------------ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
Stimulus.register("attachment", class extends Controller {
  
  static targets = ["form", "photo_file", "photo_image", "photo_btn" ]

  connect() {
    console.log("Stimulus Connected: attachment controller");
  }

  select_image()
  {
    this.photo_fileTarget.click();
  }

  // the method is called once the field containig the image file changes.
  // We get as a parameter the id of the person being modified. This allows us to build
  // a specific post request.
  load_image({ params: { id } }) {
    if (this.hasPhoto_btnTarget) {
      this.photo_btnTarget.value = "File Selected"
    }
    this.submit_image(id)
  }

  // the function submits the image uploaded inmediately without waiting for the whole form to 
  // be sumbitted. This way the user will see the uploaded image appear inmediately.
  submit_image(person_id) {
    var url = `/people/${person_id}/image`
    var input = document.querySelector('input[type="file"]')
    var data = new FormData()
    data.append('file', input.files[0])
    fetch(url, {
      method: 'post',
      body: data,
    })
    .then(response => this.photo_imageTarget.src=`photos/${person_id}.jpg?v=${Math.random()}`)
    }
})
    
    