require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::RSpec < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/dchelimsky/rspec.git'
  end

protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers'
    options << '--charset' << 'utf-8'
    options << '--title' << 'RSpec'
    options << '-T' << 'sdoc'
    if File.exists? 'README.rdoc'
      options << '--main' << 'README.rdoc'
    else
      options << '--main' << 'README'
    end

    file_list = Rake::FileList.new
    file_list.include('*.txt')
    file_list.include('*.rdoc')
    file_list.include('SPEC')
    file_list.include('RDOX')
    file_list.include('lib/**/*.rb')

    options += file_list
    RDoc::RDoc.new.document(options)
  end
end
