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
    var task_id = event.target.dataset.task;
    var ds_id = event.target.dataset.ds;
    console.log(`opening modal`);
    console.log(`matrix/people_modal/ds/${ds_id}/task/${task_id}`);
    this.peoplemodalTarget.src=`matrix/people_modal/ds/${ds_id}/task/${task_id}`;
    this.peoplemodalTarget.reload();
    //this.peoplemodalTarget.style.display="block";
    
    //this.sleep(200).then(() => { this.modalframeTarget.style.display="block";});
  }

  close_modal(event) {    
    console.log(`closing modal`);
    this.modalframeTarget.style.display="none";
  }  
 
  selectds(event)
  {
    console.log(event.currentTarget)
    var ds = event.params["ds"] //get the day_schedule id 
    var schedule = event.currentTarget.value //get the day_schedule id 
    var url = `/matrix/day_schedule/${ds}/schedule/${schedule}`;
    console.log(url)
    fetch(url, 
      {
        method: "POST", 
      })
      .then(res =>  { console.log("schedule updated") })
      .catch(err => { throw err });
    return true
  }
    


  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }


})
    
    