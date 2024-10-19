/************************************************************************************************  
  A Controller used to validate forms.
  All the field targets will be submitted for validation
************************************************************************************************/ 


import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("validate", class extends Controller {
  
  static targets = ["field", "error_frame", "submit_btn"]
  warning_html = "<i class='fa-solid fa-triangle-exclamation'></i>"
  
  connect() {
    console.log("Stimulus Controller Connected: validate");
  }

  validate() {    
    {
      var url = this.build_url();
      fetch(url)
      .then(res => res.json())
      .then(out => { this.handle_response(out) })
      .catch(err => { throw err });
    }
  }

  build_url()
  {
    //get the ruby object identifier i.e. department, user, etc...
    var object_name = this.data.get("objectname") 
    var query = ""
    
    // iterate through all the fiedl targets and add their values to the query string
    for( var field of this.fieldTargets ){
      query = `${query}${field.name}=${field.value}&`
    }
    query.substring(0, query.length - 1); //remove the last character &
    return `/${object_name}/validate?${query}`;
  }

  handle_response(validation_data) {
    if(validation_data!=false) {
      //console.log(`got validation response: ${validation_data.result}`)
      if(!validation_data.result) {                          //there was a validation problem
        this.show_frame(this.error_frameTarget)
        this.submit_btnTarget.disabled=true
        this.error_frameTarget.innerHTML = `${this.warning_html} ${validation_data.message}`
      }
      else {
        this.submit_btnTarget.disabled=false
        this.hide_frame(this.error_frameTarget)
      }  
    }
  } 

  hide_frame(frame) {
    frame.classList.add('hidden-frame')
  }
  
  show_frame(frame) {
    frame.classList.remove('hidden-frame')
  }
})

    