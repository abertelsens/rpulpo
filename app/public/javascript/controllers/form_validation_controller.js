// form_validation.js

// -------------------------------------------------------------------------------------  
// An STIMULUS STIMULUS used to validate forms. 
// See https://stimulus.hotwired.dev/handbook
//
// last update: 2024-10-24 
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
  
  static targets = ["form", "errorFrame", "submitButton"]
  warning_html = "" //"<i class='fa-solid fa-triangle-exclamation'></i>"
  
  connect() {
    console.log("stimulus controller form-validator connected");
  }

  validate(event) {    
    // prevent form submission
    event.preventDefault();
    fetch(`${this.element.action}/validate`, {
      method: 'post',
      body:   new FormData(this.element),
      })
      .then(res =>  res.json())
      .then(out =>  { this.handle_response(out) })
      .catch(err => { throw err });
    }
  
  handle_response(validation_data) {
    console.log(`result ${validation_data.result}`)
    if(!validation_data) {
      this.showAlert("form-validator controller warning: there was a problem with the server's response.");
      return false;
    }

    //there was a validation problem
    if(!validation_data.result) {       
      this.showAlert(`${this.warning_html} ${validation_data.message}`)
      return false;
    }
    // validation succeeded
    
    var previousAction = this.element.action
    if (this.hasSubmitButtonTarget) { 
      var form = this.element
      form.action += "?" + this.submitButtonTarget.name + "=" + this.submitButtonTarget.value; 
    }
    else {
      console.log("form-validator controller warning: no submitButton target defined. submitting form anyway...")
    }
    // submit the form.
    this.element.requestSubmit();
    // restore the action of the form
    this.element.action = previousAction;
    return true;
    
  }
  
  showAlert(alert){
    if(this.hasErrorFrameTarget) {
      this.errorFrameTarget.classList.remove('hidden-alert');
      this.errorFrameTarget.innerHTML = alert;
    }
  }
})
   