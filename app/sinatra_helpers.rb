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
            puts Rainbow("error while updating").yellow
            puts Rainbow(result.error_messages).yellow
        else
            puts Rainbow("success when updating").yellow
        end
    end
    
    def check_permission(resource)
        @user = User.get_user(session[:current_user_id])
        partial :"/login" if @user.nil?
        
        @auth = @user.check_permission(resource)
        return (partial :"unauthorized") if @auth==User::NONE #if the authorization was not found we redirect to unauthorized page
        return @auth
      end

    #def get_current_user()
        #ADMIN_USER
    #    session[:current_user_id].nil? ? nil : User.find(session[:current_user_id])
    #end

    def get_current_user()
        #ADMIN_USER
        #return User.find(1)
        (cookies[:current_user_id].nil? || cookies[:current_user_id]&.blank?) ? nil : User.find(cookies[:current_user_id])
    end

    #checks if the edit/new/delete action produced any errors and redirects to the 
    #corresponding error page
    def error_screen(object)
        partial "screen/error", locals: {error: object.error}
    end
    
    def print_controller_log()
        case SINATRA_LOG_LEVEL
            when 1 
                puts Rainbow("--------------------------------------------").red
                puts Rainbow("#{request.fullpath}").red
                puts Rainbow("route: #{request.path_info}").red
                puts Rainbow("--------------------------------------------").red
            when 2
                puts Rainbow("--------------------------------------------").red
                puts Rainbow("#{request.fullpath}").red
                puts Rainbow("route: #{request.path_info}").red
                puts Rainbow("params: #{params}").yellow
                puts Rainbow("--------------------------------------------").red
        end
    end

end