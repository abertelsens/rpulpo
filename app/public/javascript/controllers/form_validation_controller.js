// -------------------------------------------------------------------------------------  
// An STIMULUS STIMULUS used to validate forms. 
// See https://stimulus.hotwired.dev/handbook
//
// The controller must be defined in the form element, i.e.
// <form id="my_form" action="/my_app/my_url" data-controller="form-validator"> 
//
// The whole form will be sent to validation to the form url with a POST method
// appendign the suffix /validate to the form's action url i.e. 
// POST /my_app/my_url/validate
//
// The controller expects a json response ot type:
// {result: false, message:"invalid input"}
//
// In case of an error the error_frame will be shown and the submit btn of the form
// will be disabled. This will work only if these elements are defined as targets of the 
// controller. In order for this to work the submit button must have the attibute>
//
// data-form-validator-target="submit_btn"
//
// and the error frame the attribute
// data-form-validator-target="error_frame"
//
// The controller can be triggered by any event, but a typical case would be on the input
// event of a field, i.e. with the attribute
// data-action="input->form-validator#validate" 
// last update: 2024-02-23 
// -------------------------------------------------------------------------------------  

import { Controller } from "https://cdn.jsdelivr.net/npm/stimulus@3.2.2/dist/stimulus.js"

Stimulus.register("form-validator", class extends Controller {
  
  static targets = ["error_frame", "submit_btn"]
  warning_html = "<i class='fa-solid fa-triangle-exclamation'></i>"
  
  connect() {
    console.log("Stimulus Controller Connected: form-validator");
  }

  validate() {    
    console.log("validating form...")
    var form = this.element
    fetch(`${form.action}/validate`, {
      method: 'post',
      body:  new FormData(form),
      })
      .then(res =>  res.json())
      .then(out =>  { this.handle_response(out) })
      .catch(err => { throw err });
    }
  
  handle_response(validation_data)
  {
    console.log(`result ${validation_data.result}`)
    if(validation_data!=false) {
      
      //there was a validation problem
      if(!validation_data.result) {           
        if (this.hasError_frameTarget){ 
          this.show_frame(this.error_frameTarget)
          this.error_frameTarget.innerHTML = `${this.warning_html} ${validation_data.message}`
        }
        if (this.hasSubmit_btnTarget) { 
          this.submit_btnTarget.disabled=true
        }
        else {
          console.log("form/validator: no submit button defined as target")
        }
      }
      else {
        if (this.hasSubmit_btnTarget) { 
          this.submit_btnTarget.disabled=false
        }
        if (this.hasError_frameTarget){ 
          this.hide_frame(this.error_frameTarget)
        }
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
   