import { Controller } from "https://unpkg.com/@hotwired/stimulus/dist/stimulus.js"
    
    Stimulus.register("search", class extends Controller {
      
      static targets = ["sort_order"]; //the button to add a new object
      
      connect() {
        console.log("Stimulus Connected: search controller");
      }

      sort_by_label(event)
      {
        console.log("label clicked", event.currentTarget.id);
        this.sort_orderTarget.value = this.parse_sort_order(event.currentTarget.id);
        this.submit();
      }

      parse_sort_order(attribute_name)
      {
        if (this.sort_orderTarget.value.length===0)
        {
          return attribute_name + " " + "ASC";
        }
        else 
        {
          var attribute_array = this.sort_orderTarget.value.split(" ");
          if (attribute_name===attribute_array[0])
          {
            return this.toggle_sort_order(attribute_array);
          }
          else
          {
            return attribute_name+" ASC"
          }
        }
      }

      toggle_sort_order(attribute_array)
      {
        if (attribute_array[1]==="")
        {
          attribute_array[1]="ASC"
        }
        else if (attribute_array[1]==="ASC")
        {
          attribute_array[1]="DESC";
        }
        else if (attribute_array[1]==="DESC")
        {
          attribute_array[1]="ASC"
        }
        return attribute_array.join(" ")
      }  

      submit()
      {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
        this.element.requestSubmit()
        }, 200)
      }
      
    })
    
    