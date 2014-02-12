require 'net/http'
require 'json'
require 'fileutils'

def get_github_org_repos(org)
  org_uri = URI("https://api.github.com/orgs/#{org}/repos?per_page=100")
  return JSON.parse(Net::HTTP.get(org_uri))
end

def init_github_org_repos(org_repos)
  org_repos.each do |repo|
    FileUtils.mkpath(repo['full_name'])
    `git clone #{repo['git_url']} #{repo['full_name']}`
    pwd = FileUtils.pwd
    FileUtils.chdir(repo['full_name'])
    `git remote add oschina git@git.oschina.net:#{repo['full_name']}`
    FileUtils.chdir(pwd)
  end
end

def update_github_org_repos(org_repos)
  org_repos.each do |repo|
    pwd = FileUtils.pwd
    FileUtils.chdir(repo['full_name'])
    `git remote update origin`
    `git merge origin/master`
    `git push --all oschina`
    `git push --tags oschina`
    FileUtils.chdir(pwd)
  end
end

def main
  org, action = ARGV
  case action
  when 'init'
    org_repos = get_github_org_repos(org)
    init_github_org_repos(org_repos)
  when 'update'
    org_repos = get_github_org_repos(org)
    update_github_org_repos(org_repos)
  else
    puts "#{$0} github-org action"
  end
end

main
