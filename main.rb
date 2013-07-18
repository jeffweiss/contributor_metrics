require 'sinatra'
require 'sinatra/static_assets'
require 'git'
require 'json'

set :bind, '0.0.0.0'

get '/repo/:repo/alltime' do
  g = Git.open("repos/#{params[:repo]}")
  commits = g.log(50000).reject {|l| l.parents.size > 1}
  authors = commits.map {|c| c.author.name }
  counts = authors.group_by {|x| x}.map { |k, v| { :name => k, :count => v.count} }
  counts.to_json
end

get '/repo/:repo/lastyear' do
  g = Git.open("repos/#{params[:repo]}")
  commits = g.log(50000).since('1 year ago').reject {|l| l.parents.size > 1}
  authors = commits.map {|c| c.author.name }
  counts = authors.group_by {|x| x}.map { |k, v| { :name => k, :count => v.count} }
  counts.to_json
end
