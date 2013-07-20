require 'sinatra'
require 'sinatra/static_assets'
require 'git'
require 'json'

set :bind, '0.0.0.0'

def configured_repos
  d = Dir.new("repos")
  repos = d.entries.reject {|e| e =~ /\A\./ }.map {|e| {:key => e, :name => e.capitalize} }
end

def configured_timeframes
  [ { :key => 'alltime', :name => 'All Time' },
    { :key => 'lastyear', :name => 'Last Year' } ]
end

def author_substitutions
  { "luke" => "Luke Kanies",
    "Luke Kaines" => "Luke Kanies",
    "mccune" => "Jeff McCune",
    "lutter" => "David Lutterkort",
    "nfagerlund" => "Nick Fagerlund",
    "cprice" => "Chris Price",
    "pcarlisle" => "Patrick Carlisle",
    "Matthaus Litteken" => "Matthaus Owens",
    "Rahul" => "Rahul Gopinath",
    "rahul" => "Rahul Gopinath",
    "Lindsey" => "Lindsey Smith",
    "stahnma" => "Mike Stahnke",
    "rlinehan" => "Ruth Linehan",
  }
end

def transform(log)
  commits = log.reject {|l| l.parents.size > 1}
  authors = commits.map {|c| c.author.name }
  authors = authors.map { |elem| author_substitutions.include?(elem) ? author_substitutions[elem] : elem }
  counts = authors.group_by {|x| x}.map { |k, v| { :name => k, :count => v.count} }
  counts.sort_by {|hash| hash[:name] }
end

get '/repo/:repo/alltime' do
  g = Git.open("repos/#{params[:repo]}")
  log = g.log(50000)
  transform(log).to_json
end

get '/repo/:repo/lastyear' do
  g = Git.open("repos/#{params[:repo]}")
  log = g.log(50000).since('1 year ago')
  transform(log).to_json
end

get '/' do
  erb :index, :locals => { :repos => configured_repos, :times => configured_timeframes }
end

get '/meta/repos' do
  configured_repos.to_json
end
 
get '/meta/times' do
  configured_timeframes.to_json
end
