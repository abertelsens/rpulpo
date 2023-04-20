import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    window.Stimulus = Application.start()   

    Stimulus.register("attachment", class extends Controller {
      static targets = ["form", "photo_file", "photo_image", "photo_btn" ] //the button to add a new object
    
      connect() {
        console.log("Stimulus Connected: attachment controller");
      }
      
      select_image()
      {
        //document.getElementById('photo_file').click();
        this.photo_fileTarget.click();
        //this.load_image()
      }

      load_image({ params: { id } }){
        console.log("this.photo_fileTarget.value")
        console.log(this.photo_fileTarget.value)
        if (this.hasPhoto_btnTarget) {this.photo_btnTarget.value = "File Selected"}
        this.submit_image(id)
      }
    
      submit_image(person_id)
      {
      var url = `/people/${person_id}/image`
      console.log(url)
      var input = document.querySelector('input[type="file"]')
      var data = new FormData()
      data.append('file', input.files[0])
      fetch(url, {
        method: 'post',
        body: data,
      })
    .then(response => this.photo_imageTarget.src=`photos/${person_id}.jpg`)
    //.then(data => window.open(URL.createObjectURL(data)))
    }
    
    })
    
    