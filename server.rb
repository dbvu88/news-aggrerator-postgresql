require "sinatra"
require "pg"
require_relative "./app/models/article"
require "pry"

set :bind, '0.0.0.0'  # bind to all interfaces
set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end
get "/articles" do
  # @articles = db_connection { |conn| conn.exec("SELECT title, url, description FROM articles")}
  @articles = Article.all
  erb :index
end

get "/articles/new" do
  erb :new
end

post "/create" do
  params[:Title].nil? ? title = "" : title = params[:Title]
  url = params[:URL]
  description = params[:Description]

  new_article = {
    "title" => params[:Title],
    "url" => params[:URL],
    "description" => params[:Description].strip
   }
  article = Article.new(new_article)
  if article.valid?
    article.save
    redirect "/articles"
  elsif !article.title.empty? && article.url.empty? && article.description.empty?
    @title = article.title
    erb :new
  else
    @errors_message = article.errors_message
    erb :errors
  end

end
