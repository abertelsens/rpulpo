import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

  
    Stimulus.register("vela", class extends Controller {
      
      static targets = ["field", "form", "turnos_frame", "submit_btn", "copybtn"]
      
      default_action = ""
      
      connect() {
        console.log("Stimulus Controller Connected: vela");
        this.default_action = this.formTarget.action
        console.log(this.default_action)
      }
    
      save(event)
      {
        this.formTarget.action = this.default_action
        this.formTarget.method="POST"
        this.element.dataset.turboFrame = "_self"
        this.element.requestSubmit()
      }

      delete(event)
      {
        this.formTarget.action = this.default_action
        this.formTarget.method="POST"
        this.element.dataset.turboFrame = "_self"
        this.element.requestSubmit()
      }

      build_turnos(event) {    
          this.formTarget.action = `${this.default_action}/turnos` 
          this.element.dataset.turboFrame = "turnos_frame"
          this.element.requestSubmit()
      }

      export_pdf() {    
        this.formTarget.method="GET"
        this.formTarget.action = `${this.default_action}/pdf` 
        this.element.dataset.turboFrame = null
        this.element.target = "_self"
        this.element.requestSubmit()
      }

  
      build_url(action)
      {
        var object_name = "vela" //get the ruby object identifier i.e. department, user, etc...
        var query = ""
        for( var field of this.fieldTargets ){
          query = `${query}${field.name}=${field.value}&`
        }
        query.substring(0, query.length - 1); //remove the last character &
        return `/vela/${action}?${query}`;
      }

      handle_response(response_data) {
        if(response_data!=false) {
          console.log(`got response: ${response_data.result}`)
          if(!response_data.result) {                          //there was a validation problem
            //this.show_frame(this.error_frameTarget)
            //this.submit_btnTarget.disabled=true
            //this.error_frameTarget.innerHTML = `<i class='fa-solid fa-triangle-exclamation'></i> ${response_data.message}`
          }
          else {
            //this.submit_btnTarget.disabled=false
            //this.hide_frame(this.error_frameTarget)
            console.log(response_data.time)
          }  
        }
      } 

      copy() {    
        {
          console.log("copy button clicked");
          var url = this.build_copy_url();
          fetch(url)
          .then(res => res.json())
          .then(out => { this.handle_copy_response(out) })
          .catch(err => { throw err });
        }
      }

      build_copy_url()
      {
        var urlprefix = this.data.get("urlprefix") //get the ruby object identifier i.e. department, user, etc...
        return `${urlprefix}/clipboard/copy`;
      }

      handle_copy_response(validation_data) {
        if(validation_data!=false) {
          console.log(`got clipboard response: ${validation_data.result}`)
          if(!validation_data.result) {                          //there was a validation problem
            this.copybtnTarget.innerHTML = "<fa-solid fa-triangle-exclamation'></i> oops"
            this.copybtnTarget.classList.add("button-warning")
            setTimeout(() => {
              this.reset_button();
            }, "2000");
          }
          else {
            console.log(this.copybtnTarget)
            this.copybtnTarget.innerHTML = "<i class='fa-solid fa-copy'></i> done"
            this.copybtnTarget.classList.add("button-primary")
            this.copybtnTarget.classList.remove("button-success")
            setTimeout(() => {
              this.reset_button();
            }, "2000");

          }
        }
      } 
      reset_button()
      {
        this.copybtnTarget.innerHTML = "<i class='fa-solid fa-copy'></i> copy"
        this.copybtnTarget.classList.remove("button-primary")
        this.copybtnTarget.classList.add("button-success")
      }      

    })
    
    