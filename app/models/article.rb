require "pg"
require "pry"
class Article
  attr_reader :title, :url, :description, :errors_message

  def initialize(
    article_data = {
      "title"=>nil,
      "url"=>nil,
      "description"=>nil}
      )
    @title = article_data["title"]
    @url = article_data["url"]
    @description = article_data["description"]
    @errors_message = []
  end

  def self.all
    articles = []
    articles_data = db_connection do
      |conn| conn.exec(
      "SELECT Title, URL, Description FROM articles"
      )
    end
    articles_data.each do |article|
      articles << Article.new(article)
    end
    articles
  end

  def errors
    @errors_message
  end

  def valid?
    validity = true
    if @title.strip.empty? && @url.strip.empty? && @description.strip.empty?
      @errors_message.push("Please completely fill out form")
      return false
    end
    if @title.strip.empty? || @url.strip.empty? || @description.strip.empty?
      @errors_message.push("Please completely fill out form")
      validity = false
    end
    if !@url.include?("http")
      @errors_message.push("Invalid URL")
      validity = false
    end

    if Article.all.bsearch{|article| article.url == @url} != nil
      @errors_message.push("Article with same url already submitted")
      validity = false
    end

    if @description.size < 20
      @errors_message.push("Description must be at least 20 characters long")
      validity = false
    end

    validity
  end

  def save
    validity = valid?
      if validity == true
        db_connection do |conn|
          conn.exec_params(
          "INSERT INTO articles (Title, URL, Description) VALUES ($1,$2,$3)",
          [@title, @url, @description]
          )
        end
      end
    return validity
  end

end
