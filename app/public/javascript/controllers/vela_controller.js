import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

  
    Stimulus.register("vela", class extends Controller {
      
      static targets = ["field", "form", "turnos_frame", "submit_btn", "copybtn"]
      
      default_action = ""
      
      connect() {
        this.default_action = this.formTarget.action
        this.element[this.identifier] = this
      }
    
      //saves the form  
      save()
      {
        this.formTarget.action = this.default_action
        this.formTarget.method="POST"
        this.element.dataset.turboFrame = "_self"
        this.element.requestSubmit()
      }

      reloadturnos()
      {
        this.turnos_frameTarget.src = `${this.data.get("urlprefix")}/update_drag`
      }  
      // submits the form with a delete commit
      delete()
      {
        this.formTarget.action = this.default_action
        this.formTarget.method="POST"
        this.element.dataset.turboFrame = "_self"
        this.element.requestSubmit()
      }

      update_turnos(event) {    
          this.formTarget.action = `${this.default_action}/turnos/update` 
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

      // sends a request to copy the turnos data
      copy() {    
        {
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
    
    