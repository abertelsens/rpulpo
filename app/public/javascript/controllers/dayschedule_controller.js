import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
Stimulus.register("dayschedule", class extends Controller {
      
  static targets = ["scheduleselect", "taskassignmentsframe"]; //the button to add a new object
  
  connect() {
    console.log("Stimulus Connected: dayschedule controller");
  }

  updateschedule(event)
  {
    console.log("updating schedule")
    var dayscheduleid = event.target.dataset.dayscheduleid 
    console.log(dayscheduleid)
    var scheduleid = this.scheduleselectTarget.value
    var url = `/matrix/day_schedule/${dayscheduleid}/update?schedule=${scheduleid}`
    fetch(url)
      .then(res => res.json())
      .then(out => { this.handle_response(out) })
      .catch(err => { throw err });  
  }

  handle_response(parse_data) {
    console.log(`got response ${parse_data.result} entity:${parse_data.entity}`)
    if(parse_data!=false) {
      console.log(`got validation response: ${parse_data.result}`)
      if(!parse_data.result) {                          //there was a validation problem
      }
      else {
        this.taskassignmentsframeTarget.reload();
      }  
    }
  }  

})
    
    