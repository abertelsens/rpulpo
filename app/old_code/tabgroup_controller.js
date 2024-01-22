import { Application, Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

    window.Stimulus = Application.start()   

    Stimulus.register("tabgroup", class extends Controller {
      static targets = ["general_btn", "general_frame", "personal_btn", "personal_frame", "studies_btn", "studies_frame", "crs_btn", "crs_frame"] //the button to add a new object
    
      connect() {
        console.log("Stimulus Connected: tabgroup controller");
      }
      
      activate(e) {
        var active_elements;
        var active_frames;
        //get all the tabs with class active
        active_elements = this.element.getElementsByClassName('active');
        console.log("got active elements")
        console.log(active_elements[0])
        if (typeof active_elements!== 'undefined' && active_elements.length > 0)
          {
          //remove the active class for the tab
          active_elements[0].classList.remove('active');
          //add the active class for the tab that generated the event, i.e. the tab that was clicked.
        }
        
        this.general_frameTarget.classList.add('idle-frame') 
        this.personal_frameTarget.classList.add('idle-frame') 
        this.studies_frameTarget.classList.add('idle-frame') 
        this.crs_frameTarget.classList.add('idle-frame') 
       
        e.target.classList.add('active');
        if (e.target==this.general_btnTarget) {
            console.log("showing: general frame");
            this.general_frameTarget.classList.remove('idle-frame') 
            this.general_frameTarget.classList.add('active-frame') 
        }
        if (e.target==this.personal_btnTarget) {
          console.log("showing: personal frame");
          this.personal_frameTarget.classList.remove('idle-frame') 
          this.personal_frameTarget.classList.add('active-frame') 
        }
      if (e.target==this.studies_btnTarget) {
        console.log("showing: studies frame");
        this.studies_frameTarget.classList.remove('idle-frame') 
        this.studies_frameTarget.classList.add('active-frame') 
      }
      if (e.target==this.crs_btnTarget) {
      console.log("showing: crs frame");
      this.crs_frameTarget.classList.remove('idle-frame') 
      this.crs_frameTarget.classList.add('active-frame') 
      }
      }


    })
    
    