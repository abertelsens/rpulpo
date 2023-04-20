helpers do
    
    def get_current_peopleset
        if session[:current_people_set].nil?            #there is no current set of selected people
            current_peopleset = Peopleset.get_temporary_set()
            session[:current_people_set] = current_peopleset.id
            return current_peopleset
        else
            return Peopleset.find(session[:current_people_set])
        end
    end

    def set_current_peopleset(set)
        session[:current_people_set] = set.id
    end

    def check_update_result(result)
        if !result
            puts "error while updating".yellow
            puts @person.error_messages.yellow
        else
            puts "success when updating".yellow
        end
    end
    
    def check_permission(resource)
        @user = User.get_user(session[:current_user_id])
        partial :"/login" if @user.nil?
        
        @auth = @user.check_permission(resource)
        return (partial :"unauthorized") if @auth==User::NONE #if the authorization was not found we redirect to unauthorized page
        return @auth
      end

    def get_user()
        puts "asking for user. got #{User.get_user(session[:current_user_id])}"
        return User.get_user(session[:current_user_id])
    end

    #checks if the edit/new/delete action produced any errors and redirects to the 
    #corresponding error page
    def error_screen(object)
        partial "screen/error", locals: {error: object.error}
    end

    def get_screen(object_type)
        case object_type 
            when "settings" then partial :"screen/settings"
            when "transactions" then partial :"screen/transactions"
            when "reports" then partial :"screen/reports"
            when "shop" then partial :"screen/shop"
            when "regular_supplier" then partial :"screen/regular_supplier"
            when "user", "department", "budget_item", "ccard", "cashbox" then partial :"screen/settings", locals: {active_object: object_type}
            when "payment", "pending_request", "paid_request", "payment_request", "request" then partial :"screen/transactions", locals: {active_object: object_type}
            when "ccard_report", "cashbox_report" then partial :"screen/reports", locals: {active_object: object_type}
        end
    end


    def get_viewer object_name
        case object_name
        when "movement", "shop", "regular_supplier", "ccard_report", "cashbox_report"
            partial :"view/#{object_name}"  #if viewer
        else
            redirect "#{object_name}/table"
        end
    end
    
    def print_controller_log()
        case SINATRA_LOG_LEVEL
            when 1 
                puts "--------------------------------------------".red
                puts "route: #{request.fullpath}".red
                puts "route: #{request.request.path_info}".red
                puts "--------------------------------------------".red
            when 2
                puts "--------------------------------------------".red
                puts "#{request.fullpath}".red
                puts "route: #{request.path_info}".red
                puts "params: #{params}".yellow
                puts "--------------------------------------------".red
        end
    end

end