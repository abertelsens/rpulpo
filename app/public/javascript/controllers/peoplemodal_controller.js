/************************************************************************************************  
    A Controller for a modal frame.
    It just shows or hides the modal
************************************************************************************************/ 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("peoplemodal", class extends Controller {
  
  static targets = ["peoplemodal", "modalframe"]
  
  connect() {
    console.log("Stimulus Controller Connected: peoplemodal");
  }

  open_modal(event) {    
    event.preventDefault();
    this.peoplemodalTarget.style.display="block";
    var task_id = event.target.dataset.task;
    var ds_id = event.target.dataset.ds;
    console.log(`opening modal`);
    console.log(`matrix/people_modal/ds/${ds_id}/task/${task_id}`);
    this.peoplemodalTarget.src=`matrix/people_modal/ds/${ds_id}/task/${task_id}`;
    this.sleep(50).then(() => { this.modalframeTarget.style.display="block";});
  }

  close_modal(event) {    
    console.log(`closing modal`);
    this.peoplemodalTarget.style.display="none";
  }  
  
  select(event) {    
    var person_id = event.target.dataset.personid;
    console.log(`person selected ${person_id}`);
    this.modalframeTarget.style.display="none";
  }  

  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }


})
    
    