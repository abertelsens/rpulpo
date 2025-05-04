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

Stimulus.register("login", class extends Controller {
  
  static targets = ["errorFrame", "form", "submitButton"]
  warning_html = "<i class='fa-solid fa-triangle-exclamation'></i>"
  
  connect() { console.log("Stimulus Controller Connected: login");}

  login(event) {
    event.preventDefault(); //prevent the form from being submitted    
    //console.log("validating form...")
    var form = this.formTarget
    fetch(`${form.action}/check_credentials`, {
      method: 'post',
      body:   new FormData(form),
      })
      .then(res   => res.json())
      .then(out   => { this.handle_response(out) })
      .catch(err  => { throw err });
    }
  
  handle_response(validation_data)
  {
    if (validation_data==false) {return;}
    
    //there was a validation problem
    if(!validation_data.result) {           
      if (this.hasErrorFrameTarget) {this.show_frame(this.errorFrameTarget)}
    }
    else {
      if (this.hasSubmitButtonTarget) { this.formTarget.requestSubmit()}
      if (this.hasErrorFrameTarget){ this.hide_frame(this.errorFrameTarget)}
    }  
    
  }
  
  hide_frame(frame) { frame.classList.add('hidden-alert') }
  
  show_frame(frame) {
    console.log("activationg frame")
    frame.classList.remove('hidden-alert')
  } 

})
   