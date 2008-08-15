class LoginController < ApplicationController

  before_filter :load_context

  def add_account
	  @account = Account.new(params[:account])
	  if request.post? and @account.save
		  flash[:notice] = "Account #(@account.name) created"
		  @account = Account.new
	  end
  end

  def login
          session[:account_id] =nil
          if request.post?
            account = Account.authenticate(params[:name], params[:password])
            if account
              session[:account_id] = account.id
              session[:account_name] = account.name
              redirect_to(:action => "index")
            else
              flash[:notice] = "Invalid account/password combination"
            end
          end
  end

  def logout
           session[:account_id] = nil
           flash[:notice] = "Logged out"
           redirect_to(:action => "login")
  end

  def index
        @name = session[:account_name]
  end

  def delete_account
        if request.post?
           account = Account.find(params[:id])
           account.destroy
        end
        redirect_to(:action => :list_accounts)
  end

  def list_accounts
        @all_accounts = Account.find(:all)
  end

  protected
  def load_context
    #Keane: added for ticket 42

    @vector = RspMetadata.rsp_keys
    
            #Keane: added for ticket 43
    if session[:account_id]
      @account_flag = session[:account_name]
    else
      @account_flag = nil
    end

  end
end
