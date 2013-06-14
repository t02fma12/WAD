require 'sinatra'
require 'data_mapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/quote.db")

class Conversation
   include DataMapper::Resource
   property :id, Serial
   property :message, Text, :required => true
   property :complete, Boolean, :required => true, :default => 0
   property :written_at, DateTime
end

DataMapper.finalize.auto_upgrade!

#prevents viewers from writing or altering the html code
helpers do  
    include Rack::Utils  
    alias_method :h, :escape_html  
end  

#also the user is the only authorized person to edit or create a new blog
helpers do
def protected!
unless authorized?
response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
throw(:halt, [401, "Not authorized\n"])
end
end

def authorized?
@auth ||= Rack::Auth::Basic::Request.new(request.env)
@auth.provided? && @auth.basic? && @auth.credentials &&@auth.credentials == ['admin', 'admin']
end

end

get '/' do
   @conversations = Conversation.all :order => :id.desc
   @title = 'All Conversations'
   erb :home
end

get '/about' do
   @title = 'All Conversations'
   erb :view1about
end

 get '/help' do
    @title = 'All Conversations'
    erb :view1help
 end

post '/' do
   n = Conversation.new
   n.message = params[:message]
   n.written_at = Time.now
   n.save
   redirect '/'
end

get '/protected' do
protected!
   @conversations = Conversation.all :order => :id.desc
   @title = 'All Conversations'
   erb :protected
end

get '/:id' do
   @conversation = Conversation.get params[:id]
   @title = "Edit conversation ##{params[:id]}"
   erb :edit
end

put '/:id' do
    n = Conversation.get params[:id]
    n.message = params[:message]
    n.complete = params[:complete] ? 1 : 0
    n.save
    redirect '/'
end

get '/:id/delete' do
   @conversation = Conversation.get params[:id]
   @title = "confirm deletion of conversation ##{params[:id]}"
   erb :delete
end

delete '/:id' do
n = Conversation.get params[:id]
n.destroy
redirect '/'
end

get '/:id/complete' do  
  n = Conversation.get params[:id]  
  n.complete = c.complete ? 0 : 1     
  n.save  
  redirect '/'  
end


