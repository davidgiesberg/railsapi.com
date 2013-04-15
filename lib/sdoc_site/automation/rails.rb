require "rake"
require "sdoc_site/automation/github"

class SDocSite::Automation::Rails < SDocSite::Automation::Github
  def initialize automation
    super automation, 'git://github.com/rails/rails.git'
  end

protected
  def run_sdoc target
    options = []
    options << "-o" << target
    options << '--line-numbers'
    options << '--charset' << 'utf-8'
    options << "--title" << "Ruby on Rails"
    options << '-f' << 'sdoc'
    options << '--main' << 'README'

    file_list = Rake::FileList.new
    extract_rdoc_includes.each {|i| file_list.include(i) }
    extract_rdoc_excludes.each {|i| file_list.exclude(i) }

    # dirty hack for missing lines in rails 3-beta
    if @version == SDocSite::Version.new('v3.0.0.beta1')
      file_list.include('activemodel/README')
      file_list.include('activemodel/CHANGELOG')
      file_list.include('activemodel/lib/active_model/**/*.rb')
    end

    FileUtils.cp 'railties/README', './README' if File.exists? 'railties/README'
    options << './README'
    options << './README.rdoc'
    options += file_list
    RDoc::RDoc.new.document(options)
    FileUtils.rm './README' if File.exists? 'railties/README'
  end

  def extract_rdoc_includes &block
    extract_lines(/\.include\(['"]([^'"]+)['"]\)/, &block)
  end

  def extract_rdoc_excludes &block
    extract_lines(/\.exclude\(['"]([^'"]+)['"]\)/, &block)
  end

  def extract_lines(regexp, &block)
    lines = []
    File.open('Rakefile') do |f|
      f.each_line do |l|
        if m = l.match(regexp)
          lines.push m[1]
        end
      end
    end
    lines
  end

end
