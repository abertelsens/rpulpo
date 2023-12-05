import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    window.Stimulus = Application.start()   

    Stimulus.register("validate", class extends Controller {
      
      static targets = ["field", "error_frame", "submit_btn"]
     
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
        var object_name = this.data.get("objectname") //get the ruby object identifier i.e. department, user, etc...
        var query = ""
        for( var field of this.fieldTargets ){
          query = `${query}${field.name}=${field.value}&`
        }
        query.substring(0, query.length - 1); //remove the last character &
        return `/${object_name}/validate?${query}`;
      }

      handle_response(validation_data) {
        if(validation_data!=false) {
          console.log(`got validation response: ${validation_data.result}`)
          if(!validation_data.result) {                          //there was a validation problem
            this.show_frame(this.error_frameTarget)
            this.submit_btnTarget.disabled=true
            this.error_frameTarget.innerHTML = `<i class='fa-solid fa-triangle-exclamation'></i> ${validation_data.message}`
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
    
    