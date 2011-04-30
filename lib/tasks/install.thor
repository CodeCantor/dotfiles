class DotFiles < Thor
  include Thor::Actions

  EXCLUDE_FILES = %w{Rakefile README.rdoc LICENSE}

  method_option :force, :type => :boolean, :aliases => '-f'
  
  desc 'install', 'installs all dotfiles for current user'
  def install
    Dir[File.join(root_dir, '*')].each do |file|
      next unless valid_file? file

      source_file = source_file_for(file)
      dest_file = dest_file_for(file)
      unless File.exist?(dest_file)
        say "#{dest_file} => #{source_file}"
#        link_file dest_file, source_file
      else
        if File.identical? source_file, dest_file
          say "identical #{dest_file}"
        elsif options.force?
          overwrite_file(dest_file, source_file)          
        else
          if yes?("overwrite #{dest_file}?")
            overwrite_file(dest_file, source_file)
          else
            say("skipping #{dest_file}")
          end
        end
      end
      
    end
  end

  no_tasks do

    def overwrite_file(dest_file, source_file)
      remove_file dest_file
      say "removed #{dest_file}"
      link_file dest_file, source_file
    end
        
    def only_filename(filename)
      File.basename(filename)
    end
    
    def dest_file_for(filename)
      File.join(ENV['HOME'], ".#{only_filename(filename).sub('.erb', '')}")
    end

    def source_file_for(filename)
      File.join(root_dir, only_filename(filename))
    end
    
    def valid_file?(filename)
      !EXCLUDE_FILES.include? only_filename(filename)
    end
    
    def root_dir
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
    end
  end
end
