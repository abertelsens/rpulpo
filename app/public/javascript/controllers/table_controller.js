// setfield_controller.js

// ---------------------------------------------------------------------------------------  
// An STIMULUS A Controller for to control some keyboard events on a table and provide 
// some basic navigational functionality.
// See views/table/*.slim
// See https://stimulus.hotwired.dev/handbook
// 
// 
// last update: 2024-10-24 
// --------------------------------------------------------------------------------------- 

import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"

Stimulus.register("table", class extends Controller {
  
  static targets = ["table", "row", "newButton"]
  static values = { size: Number } //the total number of rows in the table.

  selected_row = -1 //an integer representing the selected row. -1 if no row is selected.

  connect() {
    console.log("Stimulus Controller Connected: table");
  }

  // Controls the key down arrow event.
  // in case a row is already selected we move to the next one.
  down(event) {

    event.preventDefault()
    const ROWS_OFFSET = 3 //always show  3 rows below the one being selected
    
    var row = this.rowTargets[this.selected_row]
    
    //if we reached the bottom of the table we simply return
    if(this.selected_row==this.sizeValue-1) { return; }
    
    
    //remove the highlight from the previously selected row
    if (this.selected_row>=0) {
      row.classList.remove("table-row-active")
    }

    //if we reached the bottom of the table we simply return
    if(this.selected_row==this.sizeValue-1) { return }
    
    // move the index and activate the next row
    this.selected_row = (this.selected_row+1)
    row = this.rowTargets[this.selected_row]
    row.classList.add("table-row-active")
    
    //if we reached the bottom of the table we simply return
    if(this.selected_row==this.sizeValue-1) { return }
    
    // while there are at least three more rows below we scroll down by the height of the last row
    // visible
    if (this.selected_row+ROWS_OFFSET < this.sizeValue) {
      var is_next_visible = (this.isElementVisibleInContainer(this.rowTargets[this.selected_row+ROWS_OFFSET], this.element))
      if(!is_next_visible) {
        this.element.scrollBy(0,this.rowTargets[this.selected_row+ROWS_OFFSET].offsetHeight)
      }
    }
  }

  up(event) {

    event.preventDefault()
    const ROWS_OFFSET = 3 //always show  3 rows below the one being selected
    
    var row = this.rowTargets[this.selected_row]
    
    // if we reached the top we simply return
    if(this.selected_row==0) { return; }

    if (this.selected_row>=0) {
      row.classList.remove("table-row-active")
      this.selected_row=this.selected_row-1
      row = this.rowTargets[this.selected_row]
      row.classList.add("table-row-active")
    }
 
    if (this.selected_row-ROWS_OFFSET<0) {
      this.element.scrollTop=0
    }
    else
    {
      var is_previous_visible = (this.isElementVisibleInContainer(this.rowTargets[this.selected_row-ROWS_OFFSET], this.element))
      if(!is_previous_visible) {
        this.element.scrollBy(0,-this.rowTargets[this.selected_row-ROWS_OFFSET].offsetHeight)
      }
    }
  }

  escape(event) {
    event.preventDefault()
    if(this.selected_row!=-1) {
      this.rowTargets[this.selected_row].classList.remove("table-row-active")
      this.selected_row=-1
    }
  }
  
  enter(event){
    event.preventDefault()
    if(this.selected_row!=-1) {
      this.rowTargets[this.selected_row].click()
    }
  }

  // if the mouse enters the table we reset the selected row.
  mouseover() {
    if(this.selected_row!=-1) {
      this.rowTargets[this.selected_row].classList.remove("table-row-active")
      this.selected_row=-1
    }
  }

  isElementVisibleInContainer(ele, container)
  {
    const rect = ele.getBoundingClientRect();
    const containerRect = container.getBoundingClientRect();
    return (
        rect.top >= containerRect.top &&
        rect.left >= containerRect.left &&
        rect.bottom <= containerRect.bottom &&
        rect.right <= containerRect.right
    );
  }
})
    
    